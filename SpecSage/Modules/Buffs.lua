-- Modules/Buffs.lua
-- Flags raid buffs and personal consumables that are currently missing.
--
-- Brought across from the Upkeep addon (the same author's later fork of the
-- overlay). Unlike the other sections, this one shows nothing when
-- everything is fine: an empty rows table hides the section entirely
-- (UI/Overlay.lua's LayoutSection), so it only ever asks for attention when
-- something actually needs fixing.

local ADDON, ns = ...

local Buffs = ns:NewModule("Buffs")

local UPDATE_INTERVAL = 1

-- One raid buff per source, so at most one of these is ever missing per raid
-- regardless of which class provides it. Blizzard has temporarily excluded
-- these five specifically from its "secret value" restriction so addons can
-- keep tracking them; if that ever changes, GetPlayerAuraBySpellID failing
-- reads as "can't tell" (see IsBuffActive), not "missing".
local RAID_BUFFS = {
    { spellID = 6673,   label = "Battle Shout",     class = "WARRIOR" },
    { spellID = 1459,   label = "Arcane Intellect", class = "MAGE" },
    { spellID = 21562,  label = "Fortitude",        class = "PRIEST" },
    { spellID = 1126,   label = "Mark of the Wild", class = "DRUID" },
    { spellID = 462854, label = "Skyfury",          class = "SHAMAN" },
}

-- The class tokens present in the player's group, the player included, or
-- nil when any member's class cannot be read (the caller then flags every
-- buff, as before). A buff nobody in the group can cast is not "missing" in
-- any sense the player can act on: a Mythic+ group with no Mage used to
-- show "Arcane Intellect missing" for the whole run.
local function GroupClasses()
    local classes = {}
    local ok, _, token = pcall(UnitClass, "player")
    if not ok or type(token) ~= "string" then return nil end
    classes[token] = true

    local inRaid = IsInRaid and IsInRaid()
    local count = (GetNumGroupMembers and GetNumGroupMembers()) or 0
    local prefix, last = "party", count - 1
    if inRaid then prefix, last = "raid", count end
    for i = 1, last do
        local okMember, _, memberToken = pcall(UnitClass, prefix .. i)
        if not okMember then return nil end
        if type(memberToken) == "string" then classes[memberToken] = true end
    end
    return classes
end

-- Personal consumables, matched by name rather than spell ID: every food
-- item's buff is named "Well Fed" regardless of which one was eaten, and
-- every flask is named "Flask of <something>" - both survive next season's
-- flask/food items changing without a spell ID to update.
local SELF_BUFF_PATTERNS = {
    { pattern = "^Well Fed$", label = "Well Fed" },
    { pattern = "^Flask of ", label = "Flask" },
}

-- Tri-state: true/false when the read succeeded, nil when it could not be
-- attempted (blocked, or the API is unavailable). The caller treats nil as
-- "can't tell" rather than "missing" - a restricted-content refusal must
-- never render as a wall of "missing" rows.
local function IsBuffActive(spellID)
    if not (C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID) then return nil end
    if not ns.AurasReadable() then return nil end

    local ok, aura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, spellID)
    if not ok then
        ns.NoteAurasBlocked()
        return nil
    end
    return aura ~= nil
end

-- Returns a set of SELF_BUFF_PATTERNS labels currently matched by some buff
-- on the player, or nil if the read could not be attempted.
local function MatchSelfBuffs()
    if not AuraUtil or not AuraUtil.ForEachAura then return {} end
    if not ns.AurasReadable() then return nil end

    local matched = {}
    -- The whole iteration is wrapped, not just the per-aura callback: a
    -- refusal is thrown from inside ForEachAura itself, before the callback
    -- below ever runs. The name is read under SafeCall too - an aura's
    -- fields can be secret even when the iteration itself is allowed.
    local ok = pcall(AuraUtil.ForEachAura, "player", "HELPFUL", nil, function(aura)
        local name = aura and ns.SafeCall(function() return aura.name end)
        if type(name) ~= "string" then return end
        for _, entry in ipairs(SELF_BUFF_PATTERNS) do
            if name:find(entry.pattern) then
                matched[entry.label] = true
            end
        end
    end, true)

    if not ok then
        ns.NoteAurasBlocked()
        return nil
    end
    return matched
end

-- From the shared palette in Core/Theme.lua, read once at load (the TOC
-- loads Theme before this file).
local COLOR_MISSING = ns.Colors.bad

function Buffs:Update()
    local db = ns.db.buffs
    if not db.enabled then
        ns.UI:SetSection("buffs", nil)
        return
    end

    -- The section exists only on the overlay.
    if not ns.OverlayActive() then return end

    local rows = {}

    -- Solo, nobody else can hand these out, and several of them cannot be
    -- self-cast either; asking about them would just nag a player who has no
    -- way to fix it.
    if db.showRaidBuffs and IsInGroup and IsInGroup() then
        local classes = GroupClasses()
        for _, buff in ipairs(RAID_BUFFS) do
            local provided = classes == nil or classes[buff.class]
            if provided and IsBuffActive(buff.spellID) == false then
                rows[#rows + 1] = { label = buff.label, value = "missing", valueColor = COLOR_MISSING }
            end
        end
    end

    if db.showSelfBuffs then
        local matched = MatchSelfBuffs()
        if matched then
            for _, entry in ipairs(SELF_BUFF_PATTERNS) do
                if not matched[entry.label] then
                    rows[#rows + 1] = { label = entry.label, value = "missing", valueColor = COLOR_MISSING }
                end
            end
        end
    end

    ns.UI:SetSection("buffs", rows)
end

function Buffs:OnEnable()
    -- UNIT_AURA's unit token can itself be a secret value while auras are
    -- secret, and comparing one errors (see Modules/Procs.lua). An
    -- unreadable unit is treated as "might be us"; Update is cheap and
    -- fully guarded, so the spurious refresh costs nothing.
    ns:RegisterUnitEvent("UNIT_AURA", "player", function(_, unit)
        local isPlayer = ns.SafeCall(function() return unit == "player" end)
        if isPlayer ~= false then
            Buffs:Update()
        end
    end)

    ns:RegisterEvent("GROUP_ROSTER_UPDATE", function()
        Buffs:Update()
    end)

    -- A slow ticker, not Procs' 0.1s one: nothing here has a countdown to
    -- keep smooth, it only needs to notice a buff falling off between
    -- UNIT_AURA deliveries.
    self.ticker = C_Timer.NewTicker(UPDATE_INTERVAL, ns.ProtectedCallback(function()
        if ns.db.buffs.enabled then
            Buffs:Update()
        end
    end))

    self:Update()
end

function Buffs:OnConfigChanged()
    self:Update()
end

-- Modules/Procs.lua
-- Proc and cooldown tracking.
--
-- Two sources feed this list:
--   * a per-character watch list of spell IDs, always shown with aura or
--     cooldown state;
--   * optional auto-detection, which surfaces any short player buff so common
--     trinket and talent procs show up with no configuration at all.

local ADDON, ns = ...

local Procs = ns:NewModule("Procs")

local UPDATE_INTERVAL = 0.1

--------------------------------------------------------------------------------
-- API shims
--
-- Retail moved these into the C_Spell namespace; keep working either way.
--------------------------------------------------------------------------------

local function GetSpellName(spellID)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        return info and info.name
    end
    return (GetSpellInfo(spellID))
end

local function GetSpellIcon(spellID)
    if C_Spell and C_Spell.GetSpellTexture then
        return C_Spell.GetSpellTexture(spellID)
    end
    return select(3, GetSpellInfo(spellID))
end

-- Cooldown starts, aura durations and expiration times are all secret values
-- in Midnight's restricted content, and comparing or doing arithmetic on one
-- errors - on this module's 0.1s ticker that would mean an error per tick,
-- thousands deep within one fight. ns.SafeCall (Core/Init.lua) is the shared
-- guard for those expressions.
local SafeCall = ns.SafeCall

-- Returns remaining cooldown in seconds, 0 when ready, or true when the
-- spell is on cooldown but the time left cannot be read. In restricted
-- content C_Spell.GetSpellCooldown's startTime and duration are secret
-- (SecretWhenCooldownsRestricted, 12.0.5), and treating an unreadable
-- cooldown as ready showed a spell that was on cooldown as "ready".
-- SpellCooldownInfo.isActive and isOnGCD are NeverSecret, so the on/off
-- state survives even when the timing does not.
local function GetCooldownRemaining(spellID)
    local start, duration, info
    if C_Spell and C_Spell.GetSpellCooldown then
        info = C_Spell.GetSpellCooldown(spellID)
        if not info then return 0 end
        start, duration = info.startTime, info.duration
    else
        start, duration = GetSpellCooldown(spellID)
    end

    local remaining = SafeCall(function()
        if not start or not duration or duration <= 0 then return 0 end

        -- The 1.5s global cooldown is not worth reporting as "on cooldown".
        if duration <= 1.5 then return 0 end

        local left = start + duration - GetTime()
        return left > 0 and left or 0
    end)
    if remaining ~= nil then return remaining end

    if info and info.isActive == true and info.isOnGCD ~= true then return true end
    return 0
end

--------------------------------------------------------------------------------
-- Aura availability
--
-- The refusal back-off (why the aura calls are pcall-wrapped and then parked
-- for a few seconds) lives in Core/Init.lua as ns.AurasReadable /
-- ns.NoteAurasBlocked, shared with Modules/Buffs.lua so one refusal backs
-- both modules off together and the notice is said once, not once per
-- module. This module keeps a method-shaped wrapper for the slash commands.
--------------------------------------------------------------------------------

local AurasReadable = ns.AurasReadable
local NoteAurasBlocked = ns.NoteAurasBlocked

-- True when aura access is currently being refused. Lets callers (the slash
-- commands) explain an empty result rather than implying there are no buffs.
function Procs:AurasBlocked()
    return ns.AurasBlocked()
end

local function GetPlayerAura(spellID)
    if not (C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID) then return nil end
    if not AurasReadable() then return nil end

    local ok, aura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, spellID)
    if not ok then
        NoteAurasBlocked()
        return nil
    end
    return aura
end

--------------------------------------------------------------------------------
-- Aura collection
--------------------------------------------------------------------------------

-- Collects short-duration buffs on the player, newest procs included, so the
-- caller can show them without the player configuring anything.
local function CollectAutoProcs(watchedSet, maxDuration)
    local found = {}

    if not AuraUtil or not AuraUtil.ForEachAura then return found end
    if not AurasReadable() then return found end

    -- The whole iteration is wrapped, not just the per-aura work: the
    -- refusal comes from GetAuraSlots inside ForEachAura, so it throws
    -- before the callback below is ever reached.
    local ok = pcall(AuraUtil.ForEachAura, "player", "HELPFUL", nil, function(aura)
        if not aura or not aura.spellId then return end
        if watchedSet[aura.spellId] then return end

        -- An aura whose duration is secret cannot be classified as "short"
        -- at all; skip it rather than error (see SafeCall above).
        local keep = SafeCall(function()
            local duration = aura.duration or 0
            return duration > 0 and duration <= maxDuration
        end)
        if not keep then return end

        found[#found + 1] = {
            spellID = aura.spellId,
            name = aura.name,
            icon = aura.icon,
            expirationTime = aura.expirationTime or 0,
            count = aura.applications or 0,
        }
    end, true)

    if not ok then
        NoteAurasBlocked()
        -- Whatever the iteration managed before it was refused is a partial
        -- view of the player's buffs; showing half a proc list is worse than
        -- showing none.
        return {}
    end

    -- Shortest remaining first, so the thing about to fall off is on top.
    -- Sorted under pcall as one unit: a comparator that errors partway
    -- through (a secret expirationTime) would otherwise take the whole
    -- Update down, and pcalling inside the comparator instead would feed
    -- sort an inconsistent order. Unsorted is a fine fallback.
    pcall(table.sort, found, function(a, b) return a.expirationTime < b.expirationTime end)

    return found
end

--------------------------------------------------------------------------------
-- Rows
--------------------------------------------------------------------------------

-- From the shared, colour-blind-safe palette in Core/Theme.lua (which the
-- TOC loads before this file - these are read once, here, at load).
local COLOR_ACTIVE = ns.Colors.good
local COLOR_COOLDOWN = ns.Colors.warn
local COLOR_READY = ns.Colors.neutral

-- Proc rows show the game's own spell tooltip on hover.
local function TooltipProvider(spellID)
    return { spellID = spellID }
end

local function BuildWatchedRow(spellID)
    local name = GetSpellName(spellID)
    if not name then
        -- Unknown or invalid ID; show the raw value so the player can fix it.
        return {
            label = "Spell " .. spellID,
            value = "?",
            valueColor = COLOR_READY,
            alpha = 0.6,
        }
    end

    local icon = GetSpellIcon(spellID)
    local aura = GetPlayerAura(spellID)

    if aura then
        local label = name
        if ns.KnownPast(aura.applications, 1, true) then
            label = format("%s (%d)", name, aura.applications)
        end

        -- A secret duration/expiration renders as a plain "on" - active is
        -- the one thing we still know for sure.
        local value = "on"
        if ns.KnownPast(aura.duration, 0, true) then
            local remaining = SafeCall(function() return (aura.expirationTime or 0) - GetTime() end)
            if remaining then value = ns.FormatTime(remaining) end
        end

        return {
            label = label,
            value = value,
            icon = icon,
            valueColor = COLOR_ACTIVE,
            tooltipKey = spellID,
        }
    end

    local cooldown = GetCooldownRemaining(spellID)
    if cooldown == true or cooldown > 0 then
        return {
            label = name,
            value = cooldown == true and "cooldown" or ns.FormatTime(cooldown),
            icon = icon,
            desaturate = true,
            valueColor = COLOR_COOLDOWN,
            alpha = 0.7,
            tooltipKey = spellID,
        }
    end

    if not ns.db.procs.showInactiveWatched then return nil end

    return {
        label = name,
        value = "ready",
        icon = icon,
        desaturate = true,
        valueColor = COLOR_READY,
        alpha = 0.5,
        tooltipKey = spellID,
    }
end

-- The watch list for the spec the player is on. It used to be one list per
-- character, so after a spec swap the other spec's spells sat in the
-- overlay as "ready" forever. The first spec seen after the change adopts
-- the old shared list (chardb.watch), so nobody loses their watches;
-- every other spec starts empty. chardb.watch stays the list used while no
-- spec can be read (a fresh character).
function Procs:WatchList()
    local chardb = ns.chardb
    local specID = ns.PlayerSpecID()
    if not specID then return chardb.watch end
    chardb.watchBySpec = chardb.watchBySpec or {}
    local list = chardb.watchBySpec[specID]
    if not list then
        list = {}
        if not chardb.watchMigrated then
            for i, id in ipairs(chardb.watch or {}) do list[i] = id end
            chardb.watchMigrated = true
        end
        chardb.watchBySpec[specID] = list
    end
    return list
end

function Procs:Update()
    local db = ns.db
    if not db.procs.enabled then
        ns.UI:SetSection("procs", nil)
        return
    end
    -- Aura scans ten times a second only feed the overlay.
    if not ns.OverlayActive() then return end

    local rows = {}
    local watchedSet = {}

    for _, spellID in ipairs(self:WatchList()) do
        watchedSet[spellID] = true
        -- One watched spell's row failing to build (an unexpected secret
        -- value, say) must not cost every other row - this loop has no
        -- outer pcall of its own the way Stats.lua's per-reader calls do.
        local ok, row = pcall(BuildWatchedRow, spellID)
        if ok and row then
            rows[#rows + 1] = row
        end
    end

    if db.procs.autoDetect then
        local auto = CollectAutoProcs(watchedSet, db.procs.maxDuration)
        local limit = math.min(#auto, db.procs.maxAuto)
        for index = 1, limit do
            local proc = auto[index]
            local remaining = SafeCall(function() return proc.expirationTime - GetTime() end)
            local label = proc.name
            if ns.KnownPast(proc.count, 1, true) then
                label = format("%s (%d)", proc.name, proc.count)
            end
            rows[#rows + 1] = {
                label = label,
                value = remaining and ns.FormatTime(remaining) or "on",
                icon = proc.icon,
                valueColor = COLOR_ACTIVE,
                tooltipKey = proc.spellID,
            }
        end
    end

    ns.UI:SetSection("procs", rows, TooltipProvider)
end

--------------------------------------------------------------------------------
-- Watch list management
--------------------------------------------------------------------------------

function Procs:Watch(spellID)
    local list = self:WatchList()
    for _, existing in ipairs(list) do
        if existing == spellID then
            return false, "already watched"
        end
    end

    local name = GetSpellName(spellID)
    if not name then
        return false, "no spell with that ID"
    end

    table.insert(list, spellID)
    self:Update()
    return true, name
end

function Procs:Unwatch(spellID)
    local list = self:WatchList()
    for index, existing in ipairs(list) do
        if existing == spellID then
            table.remove(list, index)
            self:Update()
            return true, GetSpellName(spellID) or tostring(spellID)
        end
    end
    return false, "not watched"
end

function Procs:ListWatched()
    local list = {}
    for _, spellID in ipairs(self:WatchList()) do
        list[#list + 1] = format("%s |cff888888(%d)|r", GetSpellName(spellID) or "?", spellID)
    end
    return list
end

-- Dumps current player buffs so the player can find the spell ID to watch.
-- Returns the list plus a `blocked` flag, so /sage scan can say "this
-- content hides auras" instead of the misleading "no buffs on you right now".
function Procs:ScanAuras()
    local results = {}
    if not AuraUtil or not AuraUtil.ForEachAura then return results, false end

    -- Player-invoked, so it retries immediately rather than waiting out the
    -- back-off a ticker refusal may have started.
    local ok = pcall(AuraUtil.ForEachAura, "player", "HELPFUL", nil, function(aura)
        if aura and aura.spellId then
            results[#results + 1] = format("%s |cff888888(%d)|r", aura.name or "?", aura.spellId)
        end
    end, true)

    if not ok then
        NoteAurasBlocked()
        return {}, true
    end

    return results, false
end

--------------------------------------------------------------------------------
-- Lifecycle
--------------------------------------------------------------------------------

function Procs:OnEnable()
    -- Aura events drive correctness; the ticker only keeps the timers ticking.
    --
    -- UNIT_AURA now delivers a fully secret payload while auras are secret,
    -- so even the unit token can be a secret value - comparing one errors.
    -- An unreadable unit is treated as "might be us" and updates anyway;
    -- Update itself is cheap and fully guarded.
    ns:RegisterUnitEvent("UNIT_AURA", "player", function(_, unit)
        local isPlayer = SafeCall(function() return unit == "player" end)
        if isPlayer ~= false then
            Procs:Update()
        end
    end)
    -- A spec swap changes which watch list applies.
    ns:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", function() Procs:Update() end)

    self.ticker = C_Timer.NewTicker(UPDATE_INTERVAL, ns.ProtectedCallback(function()
        if ns.db.procs.enabled then
            Procs:Update()
        end
    end))

    self:Update()
end

function Procs:OnConfigChanged()
    self:Update()
end

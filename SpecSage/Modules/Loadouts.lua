-- Modules/Loadouts.lua
-- The talent loadout vault: save, label, import and export talent strings
-- per spec. This module is a plain data API deliberately kept frame-free
-- (see Core/Init.lua's module conventions) so it is fully testable without
-- the Tome UI, which is the only thing that calls it.

local ADDON, ns = ...

-- Reached only via ns:GetModule("Loadouts") (the pattern UI/Tome.lua uses
-- throughout); no separate ns.Loadouts alias, so there is exactly one path
-- to this module.
local Loadouts = ns:NewModule("Loadouts")

-- These moved into C_SpecializationInfo in modern retail but the globals are
-- still around; prefer the namespaced versions when present (same pattern as
-- Modules/Stats.lua's GetPrimaryStatIndex).
local GetSpecialization = (C_SpecializationInfo and C_SpecializationInfo.GetSpecialization) or GetSpecialization
local GetSpecializationInfo = (C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo) or GetSpecializationInfo

local VALID_CATEGORIES = {
    Raid = true, ["Mythic+"] = true, Delves = true, PvP = true, Other = true,
}
Loadouts.VALID_CATEGORIES = VALID_CATEGORIES

-- Ordered for UI cycling (e.g. a category-picker button in the Tome).
Loadouts.CATEGORY_ORDER = { "Raid", "Mythic+", "Delves", "PvP", "Other" }

local function Trim(text)
    return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

--------------------------------------------------------------------------------
-- Storage: SpecSageDB.loadouts[specID] = { {name=, category=, export=}, ... }
--------------------------------------------------------------------------------

-- Returns the saved loadouts for a spec, oldest first. The array returned is
-- the live saved-variable table when one exists (so index-based Delete stays
-- in sync with what was just listed) or a fresh empty table when it does not
-- — reading a spec with nothing saved must never create clutter in the DB.
function Loadouts:GetForSpec(specID)
    if type(specID) ~= "number" then return {} end
    return ns.db.loadouts[specID] or {}
end

-- Adds a loadout, validating input the way Data/API.lua validates guide data:
-- return false plus a reason on bad input, never error, so a bad dialog entry
-- cannot take the addon down. `category` falls back to "Other" rather than
-- being rejected, since it is a convenience field, not one worth blocking on.
function Loadouts:Add(specID, name, category, exportString)
    if type(specID) ~= "number" then
        return false, "specID must be a number"
    end

    if type(name) ~= "string" or Trim(name) == "" then
        return false, "name must be a non-empty string"
    end

    if type(exportString) ~= "string" or Trim(exportString) == "" then
        return false, "exportString must be a non-empty string"
    end

    if type(category) ~= "string" or not VALID_CATEGORIES[category] then
        category = "Other"
    end

    local list = ns.db.loadouts[specID]
    if not list then
        list = {}
        ns.db.loadouts[specID] = list
    end

    local entry = { name = Trim(name), category = category, export = exportString }
    list[#list + 1] = entry
    return true, entry
end

-- Deletes the loadout at `index` (1-based, in the order GetForSpec returns)
-- for `specID`. Returns false rather than erroring for an out-of-range index
-- or a spec with nothing saved, so a stale UI reference cannot throw.
function Loadouts:Delete(specID, index)
    local list = ns.db.loadouts[specID]
    if type(list) ~= "table" or type(index) ~= "number" then
        return false
    end
    if not list[index] then
        return false
    end
    table.remove(list, index)
    return true
end

-- Deletes `entry` (a table GetForSpec returned) from the spec's list,
-- wherever it sits now. A row captures its entry at render time; an index
-- captured then goes stale as soon as the other window (the Tome or the
-- docked panel) deletes a row above it, and would remove a different build.
function Loadouts:DeleteEntry(specID, entry)
    local list = ns.db.loadouts[specID]
    if type(list) ~= "table" or type(entry) ~= "table" then return false end
    for index, existing in ipairs(list) do
        if rawequal(existing, entry) then
            table.remove(list, index)
            return true
        end
    end
    return false
end

--------------------------------------------------------------------------------
-- Current character / talents
--------------------------------------------------------------------------------

-- The specialization ID the player is currently playing, or nil if unknown
-- (e.g. no spec chosen yet, very low level). Shared by the Tome to decide
-- whether "Save current" / live stat values apply to the spec being viewed.
function Loadouts:GetCurrentSpecID()
    return ns.PlayerSpecID()
end

-- Reads an export string for the player's active talent loadout. Retail's
-- talent export surface has moved between API names across patches, so this
-- tries each in turn and is fully pcall-wrapped: a client without any of
-- these (or a temporary API hiccup) must return nil, not error.
function Loadouts:ExportCurrent()
    if not C_ClassTalents or not C_ClassTalents.GetActiveConfigID then
        return nil
    end

    local ok, configID = pcall(C_ClassTalents.GetActiveConfigID)
    if not ok or not configID then return nil end

    if not C_Traits then return nil end

    -- GenerateImportString takes the configID; GenerateInspectImportString
    -- takes a unit token instead ("player" here) - passing configID to it
    -- would hand it a number where a string is expected and it would just
    -- fail silently under the pcall below, making the "fallback" a dead link.
    if C_Traits.GenerateImportString then
        local ok, result = pcall(C_Traits.GenerateImportString, configID)
        if ok and type(result) == "string" and result ~= "" then
            return result
        end
    end

    if C_Traits.GenerateInspectImportString then
        local ok, result = pcall(C_Traits.GenerateInspectImportString, "player")
        if ok and type(result) == "string" and result ~= "" then
            return result
        end
    end

    return nil
end

--------------------------------------------------------------------------------
-- Showing a build in Blizzard's talent window
--------------------------------------------------------------------------------

-- The talent tab frame, under whichever name this client uses: the
-- PlayerSpells window (11.0+) or the older ClassTalent window. Loads the
-- Blizzard addon first, since it is load-on-demand.
local function TalentsFrame()
    if C_AddOns and C_AddOns.LoadAddOn then
        -- Blizzard_ClassTalentUI was merged into Blizzard_PlayerSpells in
        -- 11.0 and no longer exists; loading it only returned "MISSING".
        pcall(C_AddOns.LoadAddOn, "Blizzard_PlayerSpells")
    end
    if PlayerSpellsFrame and PlayerSpellsFrame.TalentsFrame then return PlayerSpellsFrame.TalentsFrame end
    if ClassTalentFrame and ClassTalentFrame.TalentsTab then return ClassTalentFrame.TalentsTab end
    return nil
end

-- Whether the talent tab is actually on screen. The addon never opens the
-- window itself: showing PlayerSpellsFrame runs Blizzard's
-- ShowAllActionButtonGrids, which sets a protected attribute on every
-- action button, and doing that from addon code is what BugSack reported
-- as "SpecSage tried to call the protected function
-- ActionButton4:SetAttribute". Switching its tab from the spellbook hides
-- the grids the same way. So the player opens it (the talent keybind), the
-- addon only draws into it once it is up.
local function TalentsFrameVisible(frame)
    local ok, shown = pcall(frame.IsVisible, frame)
    return ok and shown and true or false
end

-- Puts `exportString` in front of the player in the talent window. Returns
--   "viewed" - the window is showing the build (Blizzard's own
--              view-a-loadout mode: nothing is saved or applied until the
--              player chooses to), or
--   nil, reason - could not (the talent window is not open - see
--              TalentsFrameVisible for why the addon will not open it -
--              in combat, a string for another spec, or no view mode). The
--              Tome then offers the string in its own copy box for the
--              talent window's Import button.
--
-- The view is one call, the same one Blizzard's inspect path makes
-- (PlayerSpellsFrame: TalentsFrame:ViewLoadout(inspectString, level)): in
-- 12.1 ClassTalentImportExportMixin:ViewLoadout(importText, level) reads the
-- header and content and converts the entries itself, and returns success,
-- specID. The addon used to run those steps by hand and call
-- ViewLoadout(entries) with the pre-12 argument shape, which failed inside
-- its pcall every time, so View always fell back.
--
-- There is deliberately no StaticPopupSpecial_Show fallback any more: showing
-- Blizzard's import dialog from addon code writes into
-- StaticPopup_DisplayedFrames, the same kind of addon write into a Blizzard
-- table that tainted every ESC press through UISpecialFrames.
function Loadouts:OpenInTalentUI(exportString, label)
    if type(exportString) ~= "string" or exportString == "" then return nil, "no talent string" end
    if InCombatLockdown and InCombatLockdown() then return nil, "cannot open the talent window in combat" end

    local frame = TalentsFrame()
    if not frame then return nil, "this client has no talent window the addon can draw into" end
    if not TalentsFrameVisible(frame) then
        return nil, "open your talent window to the Talents tab first, then click View"
    end

    -- The string has to be for the spec the player is on: Blizzard's own
    -- import refuses otherwise, and a view of another spec's tree would be
    -- meaningless.
    local currentSpecID = self:GetCurrentSpecID()
    if frame.ReadLoadoutHeader and ExportUtil and ExportUtil.MakeImportDataStream then
        local ok, headerValid, _, specID = pcall(function()
            local stream = ExportUtil.MakeImportDataStream(exportString)
            return frame:ReadLoadoutHeader(stream)
        end)
        if ok and headerValid == false then return nil, "that is not a valid talent string" end
        if ok and headerValid and type(specID) == "number" and currentSpecID and specID ~= currentSpecID then
            local specName = GetSpecializationInfoByID and select(2, GetSpecializationInfoByID(specID))
            return nil, format("that build is for %s - switch to that spec first", specName or ("spec " .. specID))
        end
    end

    if frame.ViewLoadout then
        local level = UnitLevel and UnitLevel("player") or nil
        local ok, success = pcall(frame.ViewLoadout, frame, exportString, level)
        if ok and success then return "viewed" end
    end

    return nil, "this client's talent window cannot show a build from an addon"
end

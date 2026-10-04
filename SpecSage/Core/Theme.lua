-- Core/Theme.lua
-- Shared status-colour palette and overlay-chrome theme presets.
--
-- Brought across from the Upkeep addon (the same author's later fork of the
-- overlay), which had kept refining this half while SpecSage grew the Tome.
-- Centralising colours here means a palette fix applies everywhere at once
-- instead of being repeated (and drifting) across every module, and a new
-- theme is one table added to THEMES rather than a change scattered across
-- UI/Overlay.lua, Core/Options.lua and UI/Tome.lua.
--
-- Load order: this file sits right after Core/Config.lua in the TOC, and
-- Modules/Combat.lua and Modules/Procs.lua read ns.Colors at file load, so
-- it must stay ahead of them. Core/Config.lua, which loads BEFORE this file,
-- therefore never reads ns.THEMES at load time: its Theme option resolves
-- its choices lazily (see ns.OptionChoices there).

local ADDON, ns = ...

--------------------------------------------------------------------------------
-- Status colours
--
-- Blue-green/orange rather than green/red: under deuteranopia and
-- protanopia, the two most common forms of colour blindness, red and green
-- collapse toward the same hue at similar brightness. Blue-green and orange
-- stay distinguishable, so "good" and "bad" states read correctly either way.
--------------------------------------------------------------------------------

ns.Colors = {
    good    = { 0.13, 0.71, 0.55 }, -- HPS, active procs, buffs present
    bad     = { 0.89, 0.59, 0.04 }, -- damage taken, missing buffs
    warn    = { 0.84, 0.45, 0.04 }, -- on cooldown
    gold    = { 1, 0.82, 0 },       -- DPS, headline numbers
    neutral = { 0.6, 0.6, 0.6 },    -- ready / inactive / dim
}

--------------------------------------------------------------------------------
-- Overlay chrome presets
--
-- Each theme describes how the overlay's backdrop is built: a texture pair
-- SetBackdrop can use directly, plus a border colour. GetEdgeColor is a
-- function rather than a fixed table so a theme can compute its colour at
-- apply time - class-coloured reads the player's actual class each time
-- rather than baking in whichever class built the addon.
--------------------------------------------------------------------------------

local function ClassAccent()
    -- Both reads are guarded: UnitClass("player") can be called before the
    -- player exists on a very early load, and C_ClassColor is a namespace
    -- that has moved before. The fallback is the overlay's old header blue.
    local ok, _, classFilename = pcall(UnitClass, "player")
    local color
    if ok and classFilename and C_ClassColor and C_ClassColor.GetClassColor then
        local colorOk, result = pcall(C_ClassColor.GetClassColor, classFilename)
        if colorOk then color = result end
    end
    if not color and ok and classFilename and RAID_CLASS_COLORS then
        color = RAID_CLASS_COLORS[classFilename]
    end
    if color then return color.r, color.g, color.b end
    return 0.4, 0.8, 1.0
end

ns.THEMES = {
    minimal = {
        label = "Minimal",
        bgTexture = "Interface\\Buttons\\WHITE8X8",
        bgColor = { 0, 0, 0 },
        edgeTexture = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        GetEdgeColor = function() return 1, 1, 1, 0.12 end,
    },
    bordered = {
        label = "Bordered",
        bgTexture = "Interface\\Tooltips\\UI-Tooltip-Background",
        bgColor = { 0.05, 0.04, 0.03 },
        edgeTexture = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        GetEdgeColor = function() return 0.79, 0.63, 0.36, 1 end,
    },
    classcolor = {
        label = "Class-coloured",
        bgTexture = "Interface\\Buttons\\WHITE8X8",
        bgColor = { 0, 0, 0 },
        edgeTexture = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        GetEdgeColor = function()
            local r, g, b = ClassAccent()
            return r, g, b, 0.9
        end,
    },
}

-- Display order for the Theme option on both surfaces; add a new theme here
-- (and above) and nothing else needs to change to offer it.
ns.THEME_ORDER = { "minimal", "bordered", "classcolor" }

-- An unknown key (a theme renamed or removed between versions, or a saved
-- variable hand-edited) falls back to minimal rather than erroring inside
-- SetBackdrop.
function ns.GetTheme(key)
    return ns.THEMES[key] or ns.THEMES.minimal
end

--------------------------------------------------------------------------------
-- Tome skins (2026-10-03)
--
-- The Tome and the docked gearing panel read every colour from ns.TomePalette
-- (UI/Tome.lua and UI/CharacterPanel.lua alias its tables as locals). A skin
-- is a palette plus how the cover and pages are drawn; applying one rewrites
-- the palette tables IN PLACE, so every `unpack(TEXT_PRIMARY_COLOR)` in the
-- renderers picks the new colours up on the next redraw, and the handful of
-- things drawn once at build time (cover, pages, plates, backdrops) are
-- revisited by Tome:ApplySkin / CharacterPanel:ApplySkin.
--
-- Palette keys:
--   ink      body text, headings and muted text (the Tome has no grey text)
--   accent   emphasis: conditions, the active tab, hovered buttons
--   rule     hairline rules and dividers
--   leather  button plates and side tabs (the dark object on the page)
--   edge     the cover's edge and button borders
--   card     darker paper for cards
--   gold     the active-tab marker and other small highlights
--   button   text on a button plate
--   good     "equipped" and other good states, readable on this page
-- Surfaces: `cover` and `page` are { texture = path, tile = bool,
-- vertex = {r,g,b} } for an image, or { color = {r,g,b} } for flat colour.
--------------------------------------------------------------------------------

local TEXTURES = "Interface\\AddOns\\SpecSage\\Textures\\"

-- A class colour pulled down until it reads as ink on parchment: Priest
-- white, Rogue yellow and Paladin pink have no contrast against paper as
-- they are, so the colour is scaled toward black by `depth`.
local function DarkClassAccent(depth)
    local r, g, b = ClassAccent()
    return { r * depth, g * depth, b * depth }
end

ns.TOME_SKINS = {
    tome = {
        label = "Tome",
        description = "Leather cover, parchment pages, ink and wax red.",
        cover = { texture = TEXTURES .. "leather.png", tile = true },
        page = { texture = TEXTURES .. "parchment.png" },
        spine = { 0.10, 0.07, 0.04, 0.55 },
        roseAlpha = 0.45,
        palette = {
            ink = { 0.169, 0.122, 0.078 },
            accent = { 0.478, 0.184, 0.122 },
            rule = { 0.431, 0.353, 0.227 },
            leather = { 0.231, 0.165, 0.110, 1 },
            edge = { 0.102, 0.071, 0.043, 1 },
            card = { 0.804, 0.733, 0.573, 1 },
            gold = { 0.851, 0.706, 0.416 },
            good = { 0.250, 0.420, 0.230 },
            button = { 0.941, 0.894, 0.784 },
        },
    },
    midnight = {
        label = "Midnight",
        description = "Night-blue pages with pale text and a silver-blue accent; easy on the eyes in the dark.",
        cover = { color = { 0.055, 0.063, 0.090 } },
        page = { color = { 0.114, 0.125, 0.165 } },
        spine = { 0.02, 0.02, 0.04, 0.70 },
        roseAlpha = 0.12,
        palette = {
            ink = { 0.886, 0.867, 0.820 },
            accent = { 0.537, 0.729, 0.949 },
            rule = { 0.322, 0.357, 0.439 },
            leather = { 0.188, 0.208, 0.275, 1 },
            edge = { 0.031, 0.035, 0.055, 1 },
            card = { 0.157, 0.173, 0.224, 1 },
            gold = { 0.851, 0.737, 0.478 },
            good = { 0.478, 0.804, 0.557 },
            button = { 0.929, 0.918, 0.886 },
        },
    },
    vellum = {
        label = "Vellum",
        description = "Clean cream pages in a slate cover, near-black text, a deep blue accent.",
        cover = { color = { 0.255, 0.290, 0.345 } },
        page = { color = { 0.965, 0.945, 0.898 } },
        spine = { 0.10, 0.12, 0.15, 0.55 },
        roseAlpha = 0.20,
        palette = {
            ink = { 0.110, 0.114, 0.129 },
            accent = { 0.149, 0.337, 0.596 },
            rule = { 0.620, 0.600, 0.545 },
            leather = { 0.243, 0.282, 0.345, 1 },
            edge = { 0.110, 0.125, 0.157, 1 },
            card = { 0.902, 0.878, 0.820, 1 },
            gold = { 0.749, 0.600, 0.302 },
            good = { 0.180, 0.447, 0.251 },
            button = { 0.965, 0.953, 0.925 },
        },
    },
    classbound = {
        label = "Class-bound",
        description = "The Tome's parchment, bound in your class colour, with that colour as the accent.",
        cover = { texture = TEXTURES .. "leather.png", tile = true, vertexFromClass = 0.75 },
        page = { texture = TEXTURES .. "parchment.png" },
        spine = { 0.10, 0.07, 0.04, 0.55 },
        roseAlpha = 0.45,
        palette = {
            ink = { 0.169, 0.122, 0.078 },
            accentFromClass = 0.55,
            rule = { 0.431, 0.353, 0.227 },
            leatherFromClass = 0.32,
            edge = { 0.102, 0.071, 0.043, 1 },
            card = { 0.804, 0.733, 0.573, 1 },
            gold = { 0.851, 0.706, 0.416 },
            good = { 0.250, 0.420, 0.230 },
            button = { 0.941, 0.894, 0.784 },
        },
    },
}

-- Display order for the Tome skin option; add a skin above and here.
ns.TOME_SKIN_ORDER = { "tome", "midnight", "vellum", "classbound" }

-- An unknown key falls back to the original Tome look.
function ns.GetTomeSkin(key)
    return ns.TOME_SKINS[key] or ns.TOME_SKINS.tome
end

-- The live palette. Every table here is shared by reference with the
-- renderers, so it must only ever be written in place (CopyInto), never
-- replaced. Starts as the Tome skin.
local function CopyInto(target, source)
    target[1], target[2], target[3] = source[1], source[2], source[3]
    target[4] = source[4] or 1
end

ns.TomePalette = {}
for key, color in pairs(ns.TOME_SKINS.tome.palette) do
    ns.TomePalette[key] = { color[1], color[2], color[3], color[4] or 1 }
end

-- The palette `skin` resolves to right now (class-derived colours read the
-- player's class at call time).
function ns.ResolveTomePalette(skin)
    local p = skin.palette
    local resolved = {}
    for key, color in pairs(p) do
        if type(color) == "table" then resolved[key] = color end
    end
    if p.accentFromClass then resolved.accent = DarkClassAccent(p.accentFromClass) end
    if p.leatherFromClass then
        local c = DarkClassAccent(p.leatherFromClass)
        resolved.leather = { c[1], c[2], c[3], 1 }
    end
    return resolved
end

-- Rewrites ns.TomePalette in place for the skin `key`; returns the skin.
function ns.LoadTomePalette(key)
    local skin = ns.GetTomeSkin(key)
    for name, color in pairs(ns.ResolveTomePalette(skin)) do
        local target = ns.TomePalette[name]
        if target then CopyInto(target, color) end
    end
    return skin
end

-- A cover tint from the player's class, for skins that ask for one.
function ns.TomeCoverVertex(skin)
    local cover = skin.cover or {}
    if cover.vertexFromClass then return DarkClassAccent(cover.vertexFromClass) end
    return cover.vertex or { 1, 1, 1 }
end

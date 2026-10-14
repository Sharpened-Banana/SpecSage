local ADDON, ns = ...

-- SpecSage guide data: Shaman (Elemental 262, Enhancement 263, Restoration 264)
-- 12.1.5 pass (2026-10-13): every spec's overview, rotation, cooldowns
-- and tips here were re-checked against SimC's `midnight` branch (client
-- data 12.1.5.70391: action priority lists, talent and spell tables),
-- spell tooltips and the 12.1.5 patch notes, and corrected where they had
-- drifted; every spellID resolves to the ability its step names. Where an
-- older note further down disagrees with a spec block, the block is current.
-- Restoration has no SimC action list; it was checked against the guide
-- site's 12.1 page, tooltips and patch notes.
-- Content targets Midnight (patch 12.1.5). Specs below with an `mplusLoadout`
-- field have that talent string (only) cross-checked against
-- SimulationCraft's public profiles (github.com/simulationcraft/simc,
-- GPLv3) as of patch 12.1; specs without one have no such reference.
-- Rotation/overview/tips/gear prose throughout this file is hand-authored
-- and was reviewed for Midnight ability changes, not derived from or
-- checked against SimC's APLs, and was not re-verified against current
-- tuning this pass — EXCEPT Elemental (262), Enhancement (263), and Restoration (264),
-- which each gained an `mplusMetaLoadout` (DESIGN.md's v1.4 section) this
-- pass: pulled live from Blizzard's own Battle.net Game Data API
-- (client-credentials OAuth, US region) rather than SimC, on 2026-08-30.
-- Methodology: every current-season Mythic+ leaderboard (8-dungeon pool,
-- period 1078; refreshed 2026-10-04 at
-- period 1083, and 2026-10-13 at period 1085, 12.1.5's first day - a
-- field whose `source` carries an older date was kept because the newer
-- sample had no clear most-common build) across all 83 US connected realms was scanned (top 20 groups
-- per realm/dungeon) for each spec's group members; the top-observed-keystone
-- characters (up to 50 per spec) had their live `specializations` looked up
-- for their active loadout's `talent_loadout_code`. See each field's own
-- `source` comment for the resulting distribution.
-- Elemental's overview/rotation/tips were also corrected this pass: they
-- described Earth Shock as the Maelstrom spender, but in SimC's current
-- `midnight` branch profile it appears once, well behind Elemental Blast
-- and Tempest (10 references) - a free, automatically-triggered empowered
-- Lightning Bolt/Chain Lightning the guide never mentioned at all, despite
-- it now carrying a large share of the spec's damage baseline (no talent
-- gate on it in the APL).
-- A later pass (2026-09-01) enriched all three specs' overview/rotation/
-- cooldowns/tips with opener sequences, single-target-vs-AoE priority
-- nuances, cooldown-syncing notes, and hero-talent-caused differences,
-- drawing on guide sites (Wowhead/Icy Veins/Maxroll/Method/Boostmatch),
-- now a permitted source per repo policy (see
-- .claude/skills/specsage-refresh/SKILL.md). All prose was rewritten in
-- SpecSage's own words rather than copied from any source, and every
-- spellID added was verified against Wowhead rather than guessed. This
-- pass built on top of the already-corrected Tempest/Elemental Blast
-- priority above (Earth Shock stays deprioritized, no stale mechanics
-- reintroduced).
-- This is community-maintained conventional guidance (stat priorities and
-- rotations that match the spec's long-standing design) — not a claim of
-- bleeding-edge sim-perfect optimization.
-- To edit: change the strings/tables below and reload. To add a spec pack,
-- call ns.GuideStore:RegisterSpec(classToken, specID, guideTable) from any
-- addon that loads after SpecSage; see Data/API.lua for validation rules.

-- Consumables/gear pass (2026-09-01, same session as the rotation-guide
-- enrichment above): every spec's Flask/Food/Potion/Augment Rune entries
-- were refreshed to the current Season 2 consumable system (stat-matched
-- "Flask of Tempered <X>" flasks rather than the old generic "Flask of
-- Alchemical Chaos" placeholder used everywhere; current food/potion/
-- augment-rune names), and specs with concrete Season 2 tier-set 2pc/4pc
-- effects (per the same guide-site sources) had that detail appended to
-- their Head gear entry - specs the sources gave no specific tier numbers
-- for were left with their existing generic tier-set mention rather than
-- inventing specifics. statPriority was deliberately NOT touched in this
-- pass either: stat-priority orderings are exactly the kind of contested
-- judgment call (not a mechanically-determined fact) this repo's policy
-- says to flag rather than silently adopt, and neither source gave a
-- confident order clearly better than what already shipped.
if not ns.GuideStore then return end

-- 12.1.5 pass (2026-10-13): overview, rotation, cooldowns and tips rechecked
-- against SimC's midnight-branch shaman_elemental APL and Icy Veins'
-- Elemental rotation page (12.1); Fire/Storm Elemental are summoned by
-- Ascendance/Stormkeeper, not cast.
ns.GuideStore:RegisterSpec("SHAMAN", 262, {
  specName = "Elemental",
  role = "DAMAGER",
  overview = {
    "Elemental Shaman is a ranged caster built around Flame Shock, Lava Burst and Lightning Bolt: Flame Shock feeds Lava Surge procs and makes Lava Burst always crit, Lava Burst and Lightning Bolt build Maelstrom, and Earth Shock or Elemental Blast (single target) or Earthquake (multi-target) spend it.",
    "The core resource is Maelstrom; never let it overcap. Master of the Elements is the main sequencing rule: a Lava Burst empowers your next spell, so you cast Lava Burst when you have room for its Maelstrom and spend the buff on Tempest, a Stormkeeper-charged Lightning Bolt or a spender. Tempest is a free empowered Lightning Bolt/Chain Lightning that becomes available as you spend Maelstrom. Voltaic Blaze applies Flame Shock for you, and in AoE it spreads it across the pack.",
    "Fire Elemental and Storm Elemental are no longer buttons of their own: Ascendance calls a Fire Elemental (Call of Fire) and Stormkeeper calls a Storm Elemental (Fury of the Storms), which is why the two cooldowns are cast close together. Farseer is the recommended hero tree for both raid and Mythic+; Stormbringer is playable but harder to manage in AoE.",
  },
  statPriority = {
    { stat = "mastery" },
    { stat = "haste" },
    { stat = "crit" },
    { stat = "versatility" },
    { stat = "primary" },
  },
  rotation = {
    { title = "Opener", steps = {
        { spellID = 191634, text = "Stormkeeper about 3 seconds before the pull" },
        { spellID = 51505, text = "Lava Burst about 1.5 seconds before the pull so it lands as combat starts" },
        { spellID = 443454, text = "Ancestral Swiftness" },
        { spellID = 114050, text = "Ascendance with on-use trinkets and your potion" },
        { spellID = 188196, text = "Lightning Bolt, Tempest, then Lava Burst, and on into the priority list (Elemental Blast as early as you can, if talented)" },
    }},
    { title = "Single Target", steps = {
        { spellID = 191634, text = "Stormkeeper — hold it for Ascendance if that's a GCD or two away, but not longer than about 10 seconds" },
        { spellID = 443454, text = "Ancestral Swiftness on cooldown" },
        { spellID = 114050, text = "Ascendance with trinkets, Bloodlust and your potion" },
        { spellID = 188389, text = "Flame Shock (or Voltaic Blaze) when it has 6 seconds or less left, or when Fire Elemental is about to leave" },
        { spellID = 117014, text = "Elemental Blast or Earth Shock straight away when both 4-piece buffs (Flowing Elements and Overcharge) are up" },
        { spellID = 51505, text = "Lava Burst with Flame Shock up, when Master of the Elements isn't already up and it won't overcap Maelstrom", condition = "Without Master of the Elements: only with a Lava Surge proc, never hard-cast" },
        { spellID = 454009, text = "Tempest or a Stormkeeper-empowered Lightning Bolt to spend Master of the Elements" },
        { spellID = 8042, text = "Earth Shock or Elemental Blast (whichever you talented) with Master of the Elements up or to avoid overcapping Maelstrom" },
        { spellID = 454009, text = "Tempest whenever it's available" },
        { spellID = 188196, text = "Lightning Bolt as filler" },
        { spellID = 196840, text = "Frost Shock (or a Flame Shock refresh) while moving with nothing instant left" },
    }},
    { title = "AoE (4+ targets)", steps = {
        { spellID = 191634, text = "Stormkeeper, then Ancestral Swiftness" },
        { spellID = 470057, text = "Voltaic Blaze on cooldown to spread Flame Shock" },
        { spellID = 114050, text = "Ascendance with trinkets, Bloodlust and your potion" },
        { spellID = 117014, text = "Elemental Blast on a target without Lightning Rod if you have no Elemental Blast buff and at most 1 Tempest stack" },
        { spellID = 61882, text = "Earthquake with at most 1 Tempest stack, or whenever Ancestors are up or you're on 6+ targets" },
        { spellID = 454009, text = "Tempest at 2 stacks (with fewer than 4 Stormkeeper charges), and whenever it's available" },
        { spellID = 188443, text = "Chain Lightning with Stormkeeper if it won't overcap Maelstrom, otherwise as filler" },
        { spellID = 51505, text = "Lava Burst with a Lava Surge to consume Purging Flames" },
        { text = "On exactly 2-3 targets the single-target list mostly holds: keep one Flame Shock up, use Chain Lightning instead of Lightning Bolt, and Earthquake only while Ancestors are up (Farseer)" },
    }},
  },
  cooldowns = {
    { spellID = 114050, text = "Ascendance — main burst cooldown; with Call of Fire it brings a Fire Elemental. Line it up with Bloodlust, your potion, trinkets and a Stormkeeper cast just before" },
    { spellID = 191634, text = "Stormkeeper — empowers your next Lightning Bolts/Chain Lightnings and, with Fury of the Storms, calls a Storm Elemental; near on cooldown in single target, can be held for a 5-target Chain Lightning in AoE" },
    { spellID = 443454, text = "Ancestral Swiftness — free instant cast (and an Ancestor on Farseer); use it on cooldown" },
    { spellID = 79206, text = "Spiritwalker's Grace — cast while moving, so you keep casting through forced movement during Ascendance" },
    { spellID = 108271, text = "Astral Shift — defensive damage-reduction cooldown" },
    { spellID = 2825, text = "Bloodlust — raid-wide haste cooldown, coordinate timing with the raid" },
    { spellID = 51514, text = "Hex — crowd control utility for dangerous adds" },
  },
  consumables = {
    { slot = "Flask", items = { 241322, 241324 }, text = "Flask of the Magisters for Mastery, this spec's top secondary; Flask of the Blood Knights if your gear already leans hard into Mastery and Haste is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 271887, 241308, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Mastery for this spec. If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting)." },
    { slot = "Weapon Enchant", items = { 244029, 244031, 273072 }, text = "Acuity of the Ren'dorei procs +67 primary stat for 15s; Arcane Mastery procs +124 Mastery instead and wins if your stat weights put Mastery well clear of the rest. Rite of the Hash'ey (12.1: +139 of a random secondary, favouring your highest above 80% health) is the third option." },
    { slot = "Ring Enchants", items = { 243957, 243959 }, text = "Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; Zul'jin's Mastery (+29 Mastery) if your sim says otherwise - the difference is tiny." },
    { slot = "Chest Enchant", items = { 243977 }, text = "Mark of the Worldsoul (+50 primary stat)." },
    { slot = "Leg Enchant", items = { 240133 }, text = "Sunfire Silk Spellthread (+41 Intellect, +115 Stamina)." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240896, 240900, 240967 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Masterful Amethyst (+17 Mastery) in every other socket, or Flawless Quick Amethyst (+16 Mastery, +7 Haste) if you're balancing the two. With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "Tier set piece — the set bonus usually matters more than a small item-level gap" },
    { slot = "Neck", text = "Favor Haste to chain Lava Surge procs and generate Maelstrom faster" },
    { slot = "Back", text = "Secondary stats matching Haste and Mastery outweigh a pure item-level chase" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece leaning Haste and Mastery" },
    { slot = "Ring", text = "Haste or Mastery rings depending on your current stat weights" },
    { slot = "Trinket", text = "One on-use Intellect or damage trinket lined up with Ascendance" },
    { slot = "Trinket", text = "A passive stat-stick trinket for consistent Lava Burst and Elemental Blast/Earth Shock damage" },
    { slot = "Weapon", text = "A one-hander with strong Intellect and secondary stats" },
    { slot = "Off-hand", text = "An off-hand caster stat stick for extra Intellect and secondary stats" },
  },
  mplusLoadout = {
    string = "CYQAAAAAAAAAAAAAAAAAAAAAAAAAAAzMbbzMmZmZZbZMMjBAAAAsYmNYADY2YCZWAgZbmZGjtFTYmxYxMzMmZWsMjFzMMzyAAGGAzMGGGA",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CYQALMl7AwW51MWzGneuHE3tPCAAAAzMbLzMGjZZbZMmhZAAAAgFzsBDYAzGTIzCAMbzMzYstYajZmtxyMzMjhFLzMLDjZmFAgBAmZMMMA",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Elemental Shamans by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (3/50, 6%); 50/50 (100%) ran Farseer overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Keep Flame Shock active on the target at all times — it adds damage through Inferno Arc, procs Lava Surge, and makes Lava Burst always crit.",
    "Don't cap Maelstrom: cast your spender before a generator (Lava Burst overloads especially) would push you over the cap.",
    "Master of the Elements sequencing is the heart of single target: Lava Burst, then spend the buff on Tempest, an empowered Lightning Bolt or a spender.",
    "Cast Stormkeeper shortly before Ascendance so both elementals and both buffs overlap, but don't delay Stormkeeper more than about 10 seconds waiting for it.",
    "With the Season 2 4-piece, spend the free spender charge right away — a new proc can overwrite it.",
    "Coordinate Bloodlust timing with your raid rather than using it purely on your own cooldowns.",
  },
})

-- 12.1.5 pass (2026-10-13): overview, rotation, cooldowns and tips rechecked
-- against SimC's midnight-branch shaman_enhancement APL and Icy Veins'
-- Enhancement rotation page (reviewed for 12.1.5, 2026-10-12); Feral Spirit
-- and Fire Nova are passive now.
ns.GuideStore:RegisterSpec("SHAMAN", 263, {
  specName = "Enhancement",
  role = "DAMAGER",
  overview = {
    "Enhancement Shaman is a dual-wield melee spec that builds Maelstrom Weapon stacks from its attacks and weapon imbues, then spends them on instant Lightning Bolt, Chain Lightning, Tempest or Primordial Storm. Stormstrike, Lava Lash, Crash Lightning and Voltaic Blaze are the short-cooldown buttons in between.",
    "Maelstrom Weapon stacks to 10, and spells become instant at 5. Spend at 10 (9+ for Chain Lightning) unless Elemental Tempo would bring Lava Lash or Stormstrike back in time to use — spending takes time off both. Never hard-cast a spender below 5 stacks. Crash Lightning is a core button: its buff adds a cleave to Stormstrike and Lava Lash, and the Apex talent Storm Unleashed gives spenders a chance to reset it.",
    "Doom Winds is the base 1-minute cooldown; Ascendance replaces it on a longer cooldown (3 minutes before talents), triggering Doom Winds itself and turning Stormstrike into Windstrike. Feral Spirit is now passive (Sundering and Doom Winds summon the wolves) and Fire Nova is a Voltaic Blaze proc rather than a button. Stormbringer (Tempest, burst every two minutes, best at 5-6 targets) is the recommended hero tree everywhere in Season 2; Totemic plays around Surging Totem every minute.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "crit" },
    { stat = "mastery" },
    { stat = "haste" },
    { stat = "versatility" },
  },
  rotation = {
    { title = "Opener", steps = {
        { spellID = 187874, text = "Pre-cast Crash Lightning just before the pull without hitting anything, and pre-pot" },
        { spellID = 470057, text = "Voltaic Blaze on the way into melee" },
        { spellID = 17364, text = "Stormstrike once for Maelstrom Weapon", condition = "Totemic: then Surging Totem, Sundering and Lava Lash for Hot Hand" },
        { spellID = 197214, text = "Sundering to trigger Surging Elements, then Lava Lash to apply Lashing Flames" },
        { spellID = 114051, text = "Ascendance with trinkets and racials (Doom Winds instead without Ascendance)" },
        { spellID = 187874, text = "Crash Lightning whenever it's ready and Windstrike every other GCD, Voltaic Blaze as it comes back, Primordial Storm at 10 stacks before it expires" },
    }},
    { title = "Single Target (Stormbringer)", steps = {
        { spellID = 470057, text = "Voltaic Blaze if Flame Shock isn't up — and on cooldown with the Season 2 2-piece" },
        { spellID = 1218090, text = "Primordial Storm at 10 Maelstrom Weapon (5+ if the buff is about to expire)" },
        { spellID = 197214, text = "Sundering, aligned with Ascendance where you can" },
        { spellID = 187874, text = "Crash Lightning whenever it's available" },
        { spellID = 114051, text = "Ascendance, then Windstrike every other GCD during it", condition = "Doom Winds builds: Stormstrike during Doom Winds instead" },
        { spellID = 454009, text = "Tempest, or Lightning Bolt, at 10 Maelstrom Weapon" },
        { spellID = 17364, text = "Stormstrike" },
        { spellID = 60103, text = "Lava Lash as your last-resort generator" },
        { spellID = 188196, text = "Lightning Bolt at 5+ Maelstrom Weapon when nothing else is ready" },
    }},
    { title = "Single Target (Totemic)", steps = {
        { spellID = 470057, text = "Voltaic Blaze if Flame Shock isn't up" },
        { spellID = 455630, text = "Surging Totem as close to every minute as possible" },
        { spellID = 197214, text = "Sundering, every other cast synced with Surging Totem" },
        { spellID = 60103, text = "Lava Lash with Hot Hand or Whirling Fire" },
        { spellID = 384352, text = "Doom Winds, with Lava Lash every other GCD during it" },
        { spellID = 1218090, text = "Primordial Storm at 10 Maelstrom Weapon" },
        { spellID = 187874, text = "Crash Lightning, then Stormstrike during Doom Winds" },
        { spellID = 188196, text = "Lightning Bolt at 10 Maelstrom Weapon, or at 5+ if Elemental Tempo will reset Lava Lash" },
        { spellID = 17364, text = "Stormstrike, Sundering, Lava Lash as fillers" },
    }},
    { title = "AoE", steps = {
        { spellID = 470057, text = "Voltaic Blaze if Flame Shock isn't up, and on cooldown with the 2-piece" },
        { spellID = 455630, text = "Surging Totem, then Sundering", condition = "Totemic only" },
        { spellID = 114051, text = "Ascendance (or Doom Winds), primed for Chain Lightning — cast a Chain Lightning first if your last spender was a Lightning Bolt" },
        { spellID = 60103, text = "Lava Lash with Hot Hand or Whirling Fire" },
        { spellID = 1218090, text = "Primordial Storm at 10 Maelstrom Weapon" },
        { spellID = 187874, text = "Crash Lightning whenever it's available — Fire Nova's 4-piece cooldown reduction can reset it outright" },
        { spellID = 454009, text = "Tempest at 10 Maelstrom Weapon, otherwise Chain Lightning at 9+" },
        { spellID = 17364, text = "Stormstrike, then Lava Lash and Sundering as fillers" },
        { spellID = 188443, text = "Chain Lightning at 5+ when nothing else is ready — switch from Lightning Bolt as soon as there's a second target" },
    }},
  },
  cooldowns = {
    { spellID = 114051, text = "Ascendance — longer cooldown (3 minutes before talents) that replaces Doom Winds and triggers it; Windstrike and Crash Lightning dump your Maelstrom Weapon through Thorim's Invocation. Activates Tempest on Stormbringer" },
    { spellID = 384352, text = "Doom Winds — 1-minute option if you don't take Ascendance; fill it with Stormstrike and Crash Lightning, and line it up with Surging Totem on Totemic" },
    { spellID = 197214, text = "Sundering — 30-second line burst that also summons a fire Feral Spirit and, with Surging Elements, grants haste and 5 Maelstrom Weapon" },
    { spellID = 455630, text = "Surging Totem — Totemic's 1-minute burst anchor" },
    { spellID = 108271, text = "Astral Shift — defensive damage-reduction cooldown" },
    { spellID = 2825, text = "Bloodlust — raid-wide haste cooldown, coordinate timing with the raid" },
    { spellID = 51514, text = "Hex — crowd control utility for dangerous adds" },
  },
  consumables = {
    { slot = "Flask", items = { 241326, 241322 }, text = "Flask of the Shattered Sun for Critical Strike, this spec's top secondary; Flask of the Magisters if your gear already leans hard into Critical Strike and Mastery is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 271887, 241308, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Critical Strike for this spec. If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 237371, 237369 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from Blacksmithing, if the oil is scarce." },
    { slot = "Weapon Enchant", items = { 273072, 244029, 243971 }, text = "Rite of the Hash'ey (12.1) procs +139 of a random secondary for 15s, and favours your highest one while you're above 80% health - the guides' pick for most physical specs, on both weapons if you dual-wield. Acuity of the Ren'dorei (+67 primary stat) is close behind; Jan'alai's Precision (+124 Critical Strike) if your sim puts Critical Strike well clear." },
    { slot = "Ring Enchants", items = { 243957, 243987 }, text = "Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; Nature's Fury (+29 Critical Strike) if your sim says otherwise - the difference is tiny." },
    { slot = "Chest Enchant", items = { 243977, 243975 }, text = "Mark of the Worldsoul (+50 primary stat); Mark of the Rootwarden (+40 Agility, +15 Speed) trades a little stat for movement." },
    { slot = "Leg Enchant", items = { 244641, 244643 }, text = "Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides split between them." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240904, 240908, 240967 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Deadly Garnet (+17 Critical Strike) in every other socket, or Flawless Masterful Garnet (+16 Critical Strike, +7 Mastery) if you're balancing the two. With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "Tier set piece — the set bonus usually matters more than a small item-level gap" },
    { slot = "Neck", text = "Favor Haste to generate Maelstrom Weapon stacks faster" },
    { slot = "Back", text = "Secondary stats matching Haste and Mastery outweigh a pure item-level chase" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece leaning Haste and Mastery" },
    { slot = "Ring", text = "Haste or Mastery rings depending on your current stat weights" },
    { slot = "Trinket", text = "One on-use Agility or damage trinket lined up with Ascendance or Doom Winds" },
    { slot = "Trinket", text = "A passive stat-stick trinket for consistent Stormstrike and Lava Lash damage" },
    { slot = "Weapon", text = "Two matched, high item level one-handers, kept imbued — both weapons carry Enhancement's melee damage" },
  },
  mplusLoadout = {
    string = "CcQAAAAAAAAAAAAAAAAAAAAAAMzMzgZmZmZmhZmZAAAAAAAAA2AsZGDLkFYGGawCAzyMmxYZZGYmZbsMzMzMGGzAAMDjZGGBmZwgxA",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CcQALMl7AwW51MWzGneuHE3tPOzMzgZmZmZmhZmZAAAAAAAAA2AsZGDbkFYGGawCAz2MmxYZZGbMzsNWmZmZYsMmBAYGGzMMCMzgBjB",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Enhancement Shamans by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick, tied with 1 other build (5/50, 10% each); 47/50 (94%) ran Stormbringer overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Never hard-cast a Maelstrom Weapon spender under 5 stacks — it's weaker and resets your swing timer.",
    "Keep Crash Lightning on cooldown even on one target: its buff adds a cleave to Stormstrike and Lava Lash, and Storm Unleashed resets let you chain it.",
    "Before Ascendance or Doom Winds, make sure Thorim's Invocation is primed for the right spell — Lightning Bolt on one target, Chain Lightning on several.",
    "Weapon imbues matter a lot for Enhancement's damage — Lightning Shield applies both with Instinctive Imbuements, so don't let them lapse.",
    "Earth Elemental isn't worth casting for damage; keep it for survival.",
  },
})

-- Restoration (264): revised for 12.1 from Blizzard patch-note content
-- reached via search summaries, not from a directly-fetched patch-notes
-- page, and not SimC-cross-checked (no SimC profile exists for this spec —
-- SimC does not publish healer profiles). The specific numbers/mechanics
-- below are UNVERIFIED against a primary source and should be treated as
-- provisional pending direct confirmation. No mplusLoadout is shipped for
-- this spec for the same reason; see the file header and DESIGN.md's
-- "BiS / Gear" section.
-- 12.1.5 pass (2026-10-13): overview, rotation, cooldowns and tips rechecked
-- against Icy Veins' Restoration Shaman rotation page (12.1), the 12.1.5
-- patch notes and SimC 12.1.5.70391 talent data; Mana Tide Totem is gone and
-- Healing Wave replaces Healing Surge.
ns.GuideStore:RegisterSpec("SHAMAN", 264, {
  specName = "Restoration",
  role = "HEALER",
  overview = {
    "Restoration Shaman is a reactive healer that mixes Riptide, Healing Rain and Chain Heal for group healing with Healing Wave for single targets, plus totems for both throughput and utility. Its Mastery, Deep Healing, makes every heal stronger the lower its target's health, so it shines on triage.",
    "The core resource is Mana. The short cooldowns carry the healing: Healing Stream Totem (and its Apex upgrade, Stormstream Totem, which Riptide and Nature's Swiftness can proc), Unleash Life before a Chain Heal or Healing Wave, Nature's Swiftness, Healing Rain placed where the group will stand, and Riptide on cooldown so Chain Heal benefits from Flow of the Tides. Patch 12.1.5 made extending Riptide through Swelling Tides add to its timer rather than reset it, and fixed Nature's Swiftness/Ancestral Swiftness not making Healing Rain instant.",
    "Totemic is the recommended hero tree for raid and Mythic+: it adds Surging Totem (place it on as many allies and enemies as you can, and move it with Totemic Projection) and pairs with Healing Tide Totem. Farseer turns Nature's Swiftness into Ancestral Swiftness and spawns Ancestors from Unleash Life and Ancestral Swiftness, and pairs with Ascendance. Healing Tide Totem and Ascendance share a choice node.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "crit" },
    { stat = "haste" },
    { stat = "versatility" },
    { stat = "mastery" },
  },
  rotation = {
    { title = "Pre-Pull", steps = {
        { spellID = 52127, text = "Water Shield on yourself" },
        { spellID = 974, text = "Earth Shield on the tank and yourself" },
        { spellID = 73920, text = "Healing Rain and as many Riptides as you can just before the pull, if it opens with heavy damage" },
    }},
    { title = "Priorities", steps = {
        { spellID = 392916, text = "Healing Stream Totem (or a Stormstream Totem proc) for emergencies and whenever you'd hit max charges" },
        { spellID = 73685, text = "Unleash Life for a buffed next heal — best on Chain Heal or Healing Wave", condition = "Farseer: also Ancestral Swiftness, both spawn an Ancestor" },
        { spellID = 378081, text = "Nature's Swiftness on cooldown for a Stormstream Totem proc, preferably on Chain Heal" },
        { spellID = 73920, text = "Healing Rain where several allies will stand for most of its duration" },
        { spellID = 455630, text = "Surging Totem on as many allies and enemies as possible; move it with Totemic Projection", condition = "Totemic only" },
        { spellID = 61295, text = "Riptide on cooldown" },
        { spellID = 1064, text = "Chain Heal on an injured ally with Riptide (for Flow of the Tides) when group healing is needed" },
        { spellID = 77472, text = "Healing Wave on the most injured single player" },
        { spellID = 188196, text = "Lightning Bolt or Flame Shock when nobody is in danger — Lightning Bolt costs no mana" },
    }},
    { title = "Cooldown Usage", steps = {
        { spellID = 108280, text = "Healing Tide Totem during a heavy group-damage phase — it heals for most with at least 5 allies in range, and you can keep moving and casting", condition = "Totemic pick of the Healing Tide Totem / Ascendance choice node" },
        { spellID = 114052, text = "Ascendance for a sustained heavy phase: Healing Wave always crits and hits an extra ally, Chain Heal jumps further with less falloff", condition = "Farseer pick of the choice node" },
        { spellID = 98008, text = "Spirit Link Totem to even out health across the group — also a 10% damage reduction inside it" },
        { text = "Stack your strongest raid cooldown with the fight's known heaviest damage window" },
    }},
  },
  cooldowns = {
    { spellID = 108280, text = "Healing Tide Totem — group healing cooldown (Totemic); shares a choice node with Ascendance" },
    { spellID = 114052, text = "Ascendance — throughput cooldown (Farseer); shares a choice node with Healing Tide Totem" },
    { spellID = 98008, text = "Spirit Link Totem — redistributes health and reduces damage taken, use for spread burst damage" },
    { spellID = 378081, text = "Nature's Swiftness — free instant cast every minute plus a Stormstream Totem proc (Ancestral Swiftness on Farseer)" },
    { spellID = 108271, text = "Astral Shift — personal defensive cooldown" },
    { spellID = 2825, text = "Bloodlust — raid-wide haste cooldown, coordinate timing with the raid" },
  },
  consumables = {
    { slot = "Flask", items = { 241326, 241324 }, text = "Flask of the Shattered Sun for Critical Strike, this spec's top secondary; Flask of the Blood Knights if your gear already leans hard into Critical Strike and Haste is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 241300, 241294, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Critical Strike for this spec, so use it with your healing cooldowns. Mana potions are weak this season: Lightfused Mana Potion (26,200 mana) is the safe one, Potion of Devoured Dreams gives more over 10s but leaves you defenceless while it channels. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 243736 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Oil of Dawn instead if you'd rather your heals proc a small absorb on their target." },
    { slot = "Weapon Enchant", items = { 244029, 243971, 273072, 243997 }, text = "Acuity of the Ren'dorei procs +67 primary stat for 15s; Jan'alai's Precision procs +124 Critical Strike instead and wins if your stat weights put Critical Strike well clear of the rest. Rite of the Hash'ey (12.1: +139 of a random secondary, favouring your highest above 80% health) is the third option. Worldsoul Cradle (heals proc a 12.5k barrier on the target) is the healer-flavoured alternative." },
    { slot = "Ring Enchants", items = { 243987, 244015 }, text = "Nature's Fury (+29 Critical Strike) on both rings; Silvermoon's Alacrity (+29 Haste) if you're topping up your second stat instead. Use the greater tier - the lesser one is +24." },
    { slot = "Chest Enchant", items = { 243977, 244003 }, text = "Mark of the Worldsoul (+50 primary stat); Mark of the Magister (+40 Intellect, +5% mana) if mana is what runs out." },
    { slot = "Leg Enchant", items = { 240133, 240155 }, text = "Sunfire Silk Spellthread (+41 Intellect, +115 Stamina); Arcanoweave Spellthread (+41 Intellect, +4% mana) if you'd rather have the mana than the health." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240904, 240906 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Deadly Garnet (+17 Critical Strike) in every other socket, or Flawless Quick Garnet (+16 Critical Strike, +7 Haste) if you're balancing the two." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "Tier set piece — the set bonus usually matters more than a small item-level gap" },
    { slot = "Neck", text = "Favor Crit and Haste to strengthen burst heals and Riptide cycling" },
    { slot = "Back", text = "Pick up Intellect and secondary stats over a pure item-level upgrade" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece leaning Crit and Mastery" },
    { slot = "Ring", text = "Crit or Mastery rings depending on whether burst or sustained healing needs more support" },
    { slot = "Trinket", text = "One mana-efficiency trinket for long fights" },
    { slot = "Trinket", text = "One throughput trinket timed with Healing Tide Totem or Ascendance windows" },
    { slot = "Weapon", text = "A one-hander with strong Intellect and secondary stats" },
    { slot = "Off-hand", text = "An off-hand caster stat stick for extra Intellect and secondary stats" },
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CgQALMl7AwW51MWzGneuHE3tPCAAAgBAAAAzMzsssNjZGjZGzMDjFYDmxiGbDIzAbmhZwyYMTz2yMzmZMLsYegZGzwsMAAAwMzgZGAYwM",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Restoration Shamans by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick, tied with 1 other build (2/50, 4% each); 50/50 (100%) ran Totemic overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Treat Healing Stream Totem, Unleash Life, Nature's Swiftness, Healing Rain and Riptide as your rotation, and Chain Heal and Healing Wave as what you cast in between.",
    "Stormstream Totem procs last 60 seconds and stack twice — spend them before both regular Healing Stream Totem charges are ready so none go to waste.",
    "Earth Shield only boosts the first target of a Chain Heal, not the whole chain.",
    "Deep Healing rewards healing low-health targets — triage the lowest players first.",
    "Pace your mana to roughly match the boss's health percentage, so you finish near empty without running dry early.",
    "Keep Earth Shield on your tank and yourself — it's easy to let it lapse once you're busy with group healing.",
  },
})

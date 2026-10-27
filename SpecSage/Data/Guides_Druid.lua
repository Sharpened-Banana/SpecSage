local ADDON, ns = ...

-- SpecSage guide data: Druid
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
-- tuning this pass — EXCEPT Balance (102), Feral (103), Guardian (104), and Restoration (105),
-- which each gained an `mplusMetaLoadout` (DESIGN.md's v1.4 section) this
-- pass: pulled live from Blizzard's own Battle.net Game Data API
-- (client-credentials OAuth, US region) rather than SimC, on 2026-08-30.
-- Methodology: every current-season Mythic+ leaderboard (8-dungeon pool,
-- period 1078; refreshed 2026-10-04 at
-- period 1083, 2026-10-13 at period 1085 (12.1.5's first day) and
-- 2026-10-27 at period 1086, the end of its second week - a
-- field whose `source` carries an older date was kept because the newer
-- sample had no clear most-common build) across all 83 US connected realms was scanned (top 20 groups
-- per realm/dungeon) for each spec's group members; the top-observed-keystone
-- characters (up to 50 per spec) had their live `specializations` looked up
-- for their active loadout's `talent_loadout_code`. See each field's own
-- `source` comment for the resulting distribution.
-- This pass also added an "Opener Notes" rotation entry naming each spec's
-- two hero talent trees, for the three specs that didn't already have one
-- inline (Feral, Guardian, Restoration - Balance already carried a hero-tree
-- note and was left as-is). Unlike the hand-authored prose above, these new
-- notes ARE cross-checked against SimC's current `midnight` branch profiles
-- (github.com/simulationcraft/simc) where a real action-list branch exists
-- per hero tree; where SimC's profile set has no branch (an identical
-- actions= list either way, or no profile for the spec at all), the note
-- says so honestly instead of inventing a rotation change.
-- Feral's overview was also corrected this pass: it credited "Bloodtalons
-- and similar talents" for rewarding ability sequencing. Blizzard's own
-- Midnight Pre-Expansion Content Update Notes list Bloodtalons among
-- talents removed outright, and SimC's current Feral profile has zero
-- Bloodtalons references - that damage is now baseline rather than
-- conditional on sequencing.
-- Balance's Eclipse description was also corrected this pass: it described
-- passively alternating Wrath/Starfire to shift Eclipse states, but SimC's
-- current profile treats Eclipse as a directly-cast ability with its own
-- recharging cooldown (cooldown.eclipse.full_recharge_time, charges),
-- confirmed against a Blizzard forum explainer thread on how Eclipse
-- currently works — Wrath/Starfire now only prime which Eclipse comes next.
-- This is community-maintained, conventional guidance (keep-it-simple stat
-- priorities, long-standing rotation patterns) and is NOT a claim of
-- sim-perfect or bleeding-edge optimal play.
-- To edit: find the RegisterSpec(...) block for the spec you want to change
-- and edit the table in place. To add a new tip/step, insert a new entry in
-- the relevant array. Keep this file data-only — no logic beyond the calls
-- below. See DESIGN.md "Guide data schema" for the full table shape.

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

-- Balance ------------------------------------------------------------------
-- 12.1.5 pass (2026-10-13): overview, rotation, cooldowns and tips rechecked
-- against SimC's midnight-branch druid_balance APL and Icy Veins' Balance
-- rotation page (12.1).
ns.GuideStore:RegisterSpec("DRUID", 102, {
  specName = "Balance",
  role = "DAMAGER",
  overview = {
    "Balance Druid is a ranged caster spec built around Solar and Lunar Eclipse states: casting Wrath or Starfire primes which one comes next, then pressing Eclipse itself (a directly-cast ability on its own recharging cooldown, not a passive alternation) enters it, while building Astral Power to spend on Starsurge and Starfall.",
    "The core mechanic is Astral Power, generated by Wrath/Starfire and by keeping Sunfire/Moonfire ticking, spent on Starsurge (single target, and up to 3 targets) and Starfall (multi-target). Celestial Alignment and Incarnation: Chosen of Elune grant both Eclipse states' benefits simultaneously for a periodic burst window that empowers the whole kit.",
    "Bring Balance when you want a spec with strong sustained ranged damage, good AoE via Starfall/Wild Mushroom setups, and burst windows that scale well with raid cooldowns, at the cost of some setup time before damage ramps up. Elune's Chosen always casts Starfire and plays entirely out of Lunar Eclipse (Lunar Calling blocks it from entering Solar at all), pushing it toward Lunar Eclipse at 4+ targets, while Keeper of the Grove keeps the standard Solar/Lunar cycle and is the more single-target-focused of the two.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "mastery" },
    { stat = "haste" },
    { stat = "crit" },
    { stat = "versatility" },
  },
  rotation = {
    { title = "Opener", steps = {
        { spellID = 24858, text = "Moonkin Form and Mark of the Wild before the pull, then pre-cast two Wrath at about 4 seconds on the pull timer" },
        { spellID = 93402, text = "Sunfire and Moonfire on the target", condition = "Keeper of the Grove: Sunfire only — Force of Nature applies Moonfire" },
        { spellID = 202770, text = "Fury of Elune" },
        { spellID = 205636, text = "Force of Nature", condition = "Elune's Chosen: enter Lunar Eclipse and cast a Starfire just before it" },
        { spellID = 194223, text = "Celestial Alignment (or Incarnation: Chosen of Elune) with trinkets and potion" },
        { spellID = 391528, text = "Starsurge to drop under 40 Astral Power, then Convoke the Spirits", condition = "If talented into Convoke the Spirits" },
        { spellID = 78674, text = "Starsurge to spend and Wrath (Starfire on Elune's Chosen) to build from there" },
    }},
    { title = "Single Target", steps = {
        { text = "Never cap Astral Power — spend even outside Eclipse if you would" },
        { spellID = 93402, text = "Keep Sunfire up, refreshing before Celestial Alignment/Incarnation" },
        { spellID = 8921, text = "Keep Moonfire up, refreshing before Celestial Alignment/Incarnation", condition = "Keeper of the Grove: Force of Nature applies it" },
        { spellID = 202770, text = "Fury of Elune and Force of Nature before you enter Eclipse or Celestial Alignment", condition = "Elune's Chosen: cast Fury of Elune inside Eclipse, as soon as it's ready" },
        { spellID = 194223, text = "Celestial Alignment (or Incarnation: Chosen of Elune)" },
        { spellID = 391528, text = "Convoke the Spirits inside Celestial Alignment with under 40 Astral Power" },
        { text = "Enter Eclipse: Solar (after Wrath) on Keeper of the Grove, Lunar on Elune's Chosen — Lunar Calling blocks Solar entirely" },
        { spellID = 191034, text = "Starfall on a Starweaver or Touch the Cosmos proc" },
        { spellID = 78674, text = "Starsurge to spend Astral Power, mostly inside Eclipse" },
        { spellID = 190984, text = "Wrath to build Astral Power", condition = "Elune's Chosen: Starfire instead" },
        { text = "Before an Eclipse ends, hold Astral Power if you'll re-enter soon, or spend it if you'll be outside for a while" },
    }},
    { title = "AoE", steps = {
        { spellID = 8921, text = "Moonfire the targets as they're gathered (Force of Nature spreads it to 6 more on Keeper of the Grove); only dot targets that will live 8+ seconds" },
        { spellID = 93402, text = "Sunfire once they're stacked, on targets that will live 5+ seconds" },
        { spellID = 202770, text = "Fury of Elune and Force of Nature, then Celestial Alignment (or Incarnation)" },
        { spellID = 391528, text = "Convoke the Spirits on fewer than 8 targets with under 40 Astral Power" },
        { text = "Enter Lunar Eclipse whenever Starfire hits 3+ targets" },
        { spellID = 191034, text = "Starfall to spend Astral Power, and on Starweaver or Touch the Cosmos procs (always Starfall on 3+ targets)" },
        { spellID = 194153, text = "Starfire to build Astral Power" },
    }},
  },
  cooldowns = {
    { spellID = 194223, text = "Celestial Alignment — both Eclipses at once; stack Force of Nature, Fury of Elune and Convoke the Spirits inside it" },
    { spellID = 390414, text = "Incarnation: Chosen of Elune (talent, replaces Celestial Alignment) — a longer, stronger version of the same window" },
    { spellID = 202770, text = "Fury of Elune — Astral Power and damage; before Eclipse on Keeper of the Grove, inside Eclipse and on cooldown on Elune's Chosen" },
    { spellID = 205636, text = "Force of Nature — Keeper of the Grove's core button: Dream Surge, a 4% damage bonus and Moonfire on up to 8 targets; pair it with Celestial Alignment or your next Eclipse" },
    { spellID = 391528, text = "Convoke the Spirits (talent) — always inside Celestial Alignment/Incarnation, from range (45 yards)" },
    { spellID = 22812, text = "Barkskin — your main defensive, on a short cooldown" },
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
    { slot = "Head", text = "One of your tier-set slots — the four-piece bonus reinforces your Eclipse/Astral Power engine, worth prioritizing" },
    { slot = "Chest", text = "A large stat budget and often your other tier piece — lean Haste first for a faster Eclipse cycle" },
    { slot = "Neck", text = "Usually carries a socket — favor Haste, then Mastery" },
    { slot = "Ring", text = "No set bonus attached — use rings to round out Haste and Mastery" },
    { slot = "Trinket", text = "One on-use trinket timed with Celestial Alignment/Incarnation so its burst overlaps your merged-Eclipse window" },
    { slot = "Trinket", text = "A passive secondary-stat trinket to hold sustained dot-and-filler damage between burst windows" },
    { slot = "Weapon", text = "Take the highest weapon damage staff or one-hand-plus-off-hand — Balance's damage scales off spellpower and stats, not weapon type" },
    { slot = "Off-hand", text = "A caster off-hand leaning Haste keeps your Eclipse cycling and Astral Power flowing" },
  },
  -- MID1 fallback: SimC has not yet published a MID2 (12.1) default profile
  -- for Balance, so this loadout is pulled from the MID1 (12.0) profile set
  -- instead. Swap to a MID2 profile once SimC publishes one.
  mplusLoadout = {
    string = "CYGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWoMbNjxMDwsYmZmZhBjZZmlZYmZswyMLzMGzshhBYstMzgxsNCMBAAAYxMzMzgNDjxAAwMDMA",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.0 (MID1, previous tier)",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CYGADBD3hSPCL9Y9gz68WcKvMAAAAAAAAAAAAAAAAAWoMbNjxMDwsYmZmZhBjZZmlZWYmxGLzsMmZM2wwAM22mZwY2GBmAAAAsYmZmZwmhxYAAYmBLDA",
    source = "Blizzard Battle.net API, US region, 2026-10-27: top 50 current-season Mythic+ Balance Druids by best keystone level in the second week of patch 12.1.5 (period 1086), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (7/50, 14%); 46/50 (92%) ran Elune's Chosen overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Never let Sunfire or Moonfire fall off targets that will live long enough to be worth dotting — dot uptime is a large share of Balance's damage.",
    "Don't sit at capped Astral Power; spend it on Starsurge/Starfall before it overflows.",
    "Eclipse is a button with charges: don't let it cap, and time it for when the damage matters — sitting outside Eclipse to build Astral Power for a priority target is fine.",
    "Starsurge on one target, Starfall on three or more; two targets depends on your talents (Meteorites or Starweaver builds Starfall).",
    "Elune's Chosen can't enter Solar Eclipse at all — Lunar Calling blocks it — so just lean into Lunar and Starfire.",
    "With the Season 2 4-piece, hold spenders for the start or end of an Eclipse, where its damage bonus peaks.",
  },
})

-- Feral ----------------------------------------------------------------
-- 12.1.5 pass (2026-10-13): overview, rotation, cooldowns and tips rechecked
-- against SimC's midnight-branch druid_feral APL and Icy Veins' Feral
-- rotation page (reviewed for 12.1.5, 2026-10-12); Feral no longer has
-- Thrash.
ns.GuideStore:RegisterSpec("DRUID", 103, {
  specName = "Feral",
  role = "DAMAGER",
  overview = {
    "Feral Druid is a bleed-based melee spec that builds and spends Combo Points on finishers, keeping Rip and Rake active as bleeds while weaving in Ferocious Bite and Tiger's Fury-powered burst windows.",
    "The core resources are Energy and Combo Points: Shred, Rake, Swipe and Moonfire (with Lunar Inspiration) build them, and finishers spend all five at once — always spend at 5, which the Apex talent Unseen Predator strongly rewards. Rake and Rip (Primal Wrath in AoE) are the bleeds to keep up at all times. Thrash is no longer part of Feral's kit, and Bloodtalons was removed in Midnight. Tiger's Fury is now the main snapshot: bleeds applied while it's up keep its damage bonus for their full duration, so refresh Rake, Rip and Moonfire inside it.",
    "Bring Feral when you want a mobile melee spec with strong sustained bleed damage, solid stealth-openers, and good multi-dot AoE, at the cost of a rotation that punishes dropped bleeds heavily. In Season 2 the two hero trees are very close: Wildstalker is recommended for raid, where cleave is common, and Druid of the Claw for Mythic+, with Ravage procs to spend and slightly lower execution demands.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "mastery" },
    { stat = "haste" },
    { stat = "crit" },
    { stat = "versatility" },
  },
  rotation = {
    { title = "Opener", steps = {
        { spellID = 5215, text = "Prowl before combat" },
        { spellID = 5217, text = "Tiger's Fury while still in Prowl, then open with Rake for a maximum-strength snapshot" },
        { spellID = 106951, text = "Berserk with your potion and on-use trinkets" },
        { spellID = 274837, text = "Feral Frenzy (or Frantic Frenzy) to jump to 5 Combo Points" },
        { spellID = 1079, text = "Rip" },
        { spellID = 391528, text = "Convoke the Spirits, then Ferocious Bite, and on into the priority list" },
    }},
    { title = "Single Target", steps = {
        { spellID = 5217, text = "Tiger's Fury on cooldown — ideally at 5 Combo Points or about 50 Energy below cap" },
        { spellID = 106951, text = "Berserk (or Incarnation: Avatar of Ashamane) on cooldown, always alongside Tiger's Fury" },
        { spellID = 274837, text = "Feral Frenzy on cooldown during Tiger's Fury, at 0-2 Combo Points", condition = "Frantic Frenzy builds: on cooldown, during Tiger's Fury when possible" },
        { spellID = 1244258, text = "Chomp on cooldown (usable after dropping below 30% Energy) — dump Energy just before it's ready" },
        { spellID = 22568, text = "Ferocious Bite with an Apex Predator's Craving proc, right away" },
        { spellID = 1079, text = "Rip at 5 Combo Points if it's missing or in pandemic range (last 30%), ideally with Tiger's Fury up" },
        { spellID = 391528, text = "Convoke the Spirits during Berserk and Tiger's Fury, at low Combo Points, with Rip lasting the whole channel" },
        { spellID = 22568, text = "Ferocious Bite at 5 Combo Points and 50+ Energy with Rip up", condition = "Druid of the Claw: Ravage when it has replaced Ferocious Bite" },
        { spellID = 1822, text = "Rake if missing or in pandemic range — refresh before Tiger's Fury fades if it would improve the snapshot" },
        { spellID = 155625, text = "Moonfire on the same rules as Rake", condition = "Lunar Inspiration talent" },
        { spellID = 5221, text = "Shred to build Combo Points" },
    }},
    { title = "AoE", steps = {
        { spellID = 5217, text = "Tiger's Fury on cooldown, ideally 70+ Energy below cap" },
        { spellID = 22568, text = "Ferocious Bite (or Ravage) on an Apex Predator's Craving proc, with Rips out for Rampant Ferocity" },
        { spellID = 106951, text = "Berserk with Tiger's Fury, then Frantic Frenzy or Feral Frenzy" },
        { spellID = 285381, text = "Primal Wrath at 5 Combo Points if Rip is missing or in pandemic range on the pack" },
        { spellID = 391528, text = "Convoke the Spirits during Berserk and Tiger's Fury, at low Combo Points, with Rips that will outlast the channel" },
        { spellID = 22568, text = "Ferocious Bite (or Ravage) at 5 Combo Points and 50+ Energy with Rips active" },
        { spellID = 213764, text = "Swipe during Berserk or with Clearcasting", condition = "Druid of the Claw — it fishes for Claw Rampage procs" },
        { spellID = 1822, text = "Rake, cycling between targets (Moonfire too with Lunar Inspiration)" },
        { spellID = 213764, text = "Swipe once Rake is on every target" },
        { spellID = 1244258, text = "Chomp when you're out of Energy" },
    }},
  },
  cooldowns = {
    { spellID = 5217, text = "Tiger's Fury — 30-second cooldown, off the GCD: 50 Energy, 15% damage and the bleed snapshot; press it with low Energy so none of the refund is wasted" },
    { spellID = 106951, text = "Berserk — major burst cooldown (2 minutes with Heart of the Lion), always with Tiger's Fury and Convoke; Incarnation: Avatar of Ashamane is the longer alternative but the weaker pick with the Season 2 set" },
    { spellID = 391528, text = "Convoke the Spirits — inside Berserk and Tiger's Fury; with Ashamane's Guidance it's a 1-minute cooldown, so keep it on that timer" },
    { spellID = 274837, text = "Feral Frenzy — 5 Combo Points in one press; Focused Frenzy pairs it with every Tiger's Fury, Frantic Frenzy is the AoE version" },
    { spellID = 22812, text = "Barkskin — defensive, reduces damage taken while still attacking" },
    { spellID = 61336, text = "Survival Instincts — major defensive cooldown for heavy incoming damage" },
  },
  consumables = {
    { slot = "Flask", items = { 241322, 241324 }, text = "Flask of the Magisters for Mastery, this spec's top secondary; Flask of the Blood Knights if your gear already leans hard into Mastery and Haste is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 271887, 241308, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Mastery for this spec. If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 237371, 237369 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from Blacksmithing, if the oil is scarce." },
    { slot = "Weapon Enchant", items = { 273072, 244029, 244031 }, text = "Rite of the Hash'ey (12.1) procs +139 of a random secondary for 15s, and favours your highest one while you're above 80% health - the guides' pick for most physical specs, on both weapons if you dual-wield. Acuity of the Ren'dorei (+67 primary stat) is close behind; Arcane Mastery (+124 Mastery) if your sim puts Mastery well clear." },
    { slot = "Ring Enchants", items = { 243957, 243959 }, text = "Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; Zul'jin's Mastery (+29 Mastery) if your sim says otherwise - the difference is tiny." },
    { slot = "Chest Enchant", items = { 243977, 243975 }, text = "Mark of the Worldsoul (+50 primary stat); Mark of the Rootwarden (+40 Agility, +15 Speed) trades a little stat for movement." },
    { slot = "Leg Enchant", items = { 244641, 244643 }, text = "Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides split between them." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240896, 240900, 240967 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Masterful Amethyst (+17 Mastery) in every other socket, or Flawless Quick Amethyst (+16 Mastery, +7 Haste) if you're balancing the two. With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "One of your tier-set slots — the four-piece bonus is built around your bleed-and-combo-point loop, worth prioritizing" },
    { slot = "Chest", text = "A large stat budget and often your other tier piece — push Critical Strike first since it scales both bleeds and finishers" },
    { slot = "Neck", text = "Usually carries a socket — favor Critical Strike, then Mastery" },
    { slot = "Ring", text = "No set bonus attached — use rings to round out Critical Strike and Mastery" },
    { slot = "Trinket", text = "One on-use trinket timed with Tiger's Fury/Berserk so its burst lands inside your window" },
    { slot = "Trinket", text = "A passive Agility stat-stick trinket to keep bleed damage strong between cooldowns" },
    { slot = "Weapon", text = "Cat Form normalizes weapon speed, so simply take the highest weapon damage item — type doesn't matter for your attacks" },
    { slot = "Feet", text = "Look for an itemization roll that keeps Critical Strike or Mastery flowing since Feral has few other stat-heavy accessory options" },
  },
  -- Matches SimC's MID2 (12.1) profile, profiles/MID2/MID2_Druid_Feral.simc
  -- on the `midnight` branch (rechecked 2026-10-13, unchanged for 12.1.5).
  mplusLoadout = {
    string = "CcGADBD3hSPCL9Y9gz68WcKvMAAAAAAwYMjHwYmZMmtFPwyYbmZGzMDAAAALBzmhxMjaGzyYmZmtxMAAAAAAwADAAAgmZZ2mZmZ2mZpZZmlNwMDwiZwAAYmBzshB",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CcGADBD3hSPCL9Y9gz68WcKvMAAAAAAgZmZ2YmZmxY2M2mZZGzMmZAAAAYJY2M8AmZUzYWMzMzsMmhBAAAAAwADAAAgmZZWmZmBEYBmZGgFGMAAAmZDD",
    source = "Blizzard Battle.net API, US region, 2026-10-27: top 50 current-season Mythic+ Feral Druids by best keystone level in the second week of patch 12.1.5 (period 1086), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (13/50, 26%); 45/50 (90%) ran Druid of the Claw overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Never let Rip or Rake fall off the target — and don't overwrite a stronger Tiger's Fury snapshot with a weaker one before it expires.",
    "Always spend at 5 Combo Points, and bring 50+ Energy to Ferocious Bite or Ravage for the bonus damage.",
    "Spend Apex Predator's Craving procs immediately so follow-up procs aren't wasted.",
    "Run your Energy low right before Tiger's Fury so its 50-Energy refund isn't capped.",
    "In AoE, Rip (via Primal Wrath) has to be on the targets before Ferocious Bite, since Rampant Ferocity only splashes onto bleeding enemies.",
    "Your action bar icon changes when a stronger snapshot is available — use it to decide when to refresh.",
  },
})

-- Guardian ---------------------------------------------------------------
-- 12.1.5 pass (2026-10-13): overview, rotation, cooldowns and tips rechecked
-- against SimC's midnight-branch druid_guardian APL and Icy Veins' Guardian
-- rotation page (12.1).
ns.GuideStore:RegisterSpec("DRUID", 104, {
  specName = "Guardian",
  role = "TANK",
  overview = {
    "Guardian Druid tanks in Bear Form, relying on high armor and health along with Ironfur, Frenzied Regeneration, Barkskin and Survival Instincts for mitigation, while Thrash and Mangle generate Rage and threat.",
    "The core resource is Rage: Bear Form grants 25 on entry, and Mangle, Thrash and auto-attacks (dealt and taken) build it from there. Spend it on Ironfur (stacking armor) defensively or Raze (or Ravage, on Druid of the Claw) offensively; spending above 80 Rage feeds Harnessed Rage, which can reset Mangle through Gore. The Apex talent Wild Guardian adds a spirit you keep active by casting Maul or Mangle — spending Rage can also reset Thrash and Mangle, so avoid spending right before either comes off cooldown.",
    "Bring Guardian when you want a tank with high physical damage mitigation, strong self-healing and solid AoE threat. Single-target builds take Red Moon, which replaces Moonfire and should be kept up via frequent Mangles; AoE builds take Twin Moonfire instead. The hero trees change little: Druid of the Claw adds Ravage, Elune's Chosen leans on Lunar Beam.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "haste" },
    { stat = "versatility" },
    { stat = "crit" },
    { stat = "mastery" },
  },
  rotation = {
    { title = "Single Target", steps = {
        { spellID = 77758, text = "Thrash on cooldown, keeping its stacks at maximum" },
        { spellID = 33917, text = "Mangle on cooldown" },
        { spellID = 204066, text = "Lunar Beam on cooldown, lined up with Red Moon if it's close" },
        { spellID = 1252871, text = "Red Moon on cooldown (it replaces Moonfire)", condition = "Red Moon talent" },
        { spellID = 1261867, text = "Heart of the Wild in Cat Form, every 2 minutes if it's safe" },
        { spellID = 102558, text = "Incarnation: Guardian of Ursoc" },
        { spellID = 400254, text = "Raze offensively above 80 Rage (Ravage when it procs on Druid of the Claw), or Ironfur when you need the defense" },
        { spellID = 213771, text = "Swipe as filler" },
    }},
    { title = "AoE", steps = {
        { spellID = 77758, text = "Thrash the moment the pack reaches you, then on cooldown" },
        { spellID = 33917, text = "Mangle on cooldown" },
        { spellID = 204066, text = "Lunar Beam on cooldown" },
        { spellID = 1261867, text = "Heart of the Wild — Cat Form on bosses, Moonkin Form on trash packs" },
        { spellID = 102558, text = "Incarnation: Guardian of Ursoc — Mangle hits 3 targets and Thrash/Mangle cool down faster" },
        { spellID = 400254, text = "Raze offensively, or Ironfur defensively" },
        { spellID = 8921, text = "Moonfire or Swipe as filler", condition = "Twin Moonfire builds" },
    }},
    { title = "Mitigation", steps = {
        { spellID = 192081, text = "Ironfur to stack physical mitigation before the hit — 7-8 stacks reaches the armor cap; it does nothing against most bleeds and magic" },
        { spellID = 22812, text = "Barkskin — short cooldown, use it on cooldown as much as you can" },
        { spellID = 61336, text = "Survival Instincts — 50% damage reduction for 6 seconds; save it for the heaviest spikes" },
        { spellID = 22842, text = "Frenzied Regeneration to heal through bleeds, magic or sustained damage" },
        { text = "Don't overlap defensive cooldowns unless you'd die otherwise — rotate them across the fight" },
    }},
  },
  cooldowns = {
    { spellID = 102558, text = "Incarnation: Guardian of Ursoc — main cooldown every 2-3 minutes; usually best used on cooldown offensively, but can be held for a dangerous stretch" },
    { spellID = 22812, text = "Barkskin — 40-60 second defensive; use it often (it deals damage with Brambles)" },
    { spellID = 61336, text = "Survival Instincts — your biggest defensive: 50% less damage taken for 6 seconds" },
    { spellID = 22842, text = "Frenzied Regeneration — self-healing, use when sustained damage is outpacing external healing" },
    { spellID = 204066, text = "Lunar Beam — on cooldown in both single target and AoE" },
  },
  consumables = {
    { slot = "Flask", items = { 241324, 241320, 241320 }, text = "Flask of the Blood Knights for Haste, this spec's top secondary; Flask of Thalassian Resistance if your gear already leans hard into Haste and Versatility is the stat you're short on. Flask of Thalassian Resistance (Versatility) is the survivability pick for progression." },
    { slot = "Food", items = { 255846, 275265, 242275, 275259 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina), or the 12.1 Loa's Gathering, Feast of Knowledge or Amani Cornucopia (about +72 of your highest secondary, +108 Stamina) - for a tank the two families come out about even, so eat whichever is down. Personal: Royal Roast (+50 primary) or Hearty Venom-Spiced Cutlets / Hearty Puffer Plate (+65 highest secondary); only feasts give Stamina, and Hearty food persists through death." },
    { slot = "Potion", items = { 241288, 241308, 241286, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Haste for this spec. Light's Potential (+695 primary stat) is a hair behind and never picks the wrong stat. Light's Preservation (a 121k absorb for 30s) for the pull that actually threatens you. Skip Draught of Rampant Abandon - its void zone silences you where you stand, the last thing a tank positioning a pack needs. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 237371, 237369 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from Blacksmithing, if the oil is scarce." },
    { slot = "Weapon Enchant", items = { 273072, 244029, 243973, 243999 }, text = "Rite of the Hash'ey (12.1) procs +139 of a random secondary for 15s, and favours your highest one while you're above 80% health - the guides' pick for most physical specs, on both weapons if you dual-wield. Acuity of the Ren'dorei (+67 primary stat) is close behind; Berserker's Rage (+124 Haste) if your sim puts Haste well clear. Worldsoul Aegis (a 14k barrier that erupts when it breaks) is the defensive alternative." },
    { slot = "Ring Enchants", items = { 244015, 244017 }, text = "Silvermoon's Alacrity (+29 Haste) on both rings; Silvermoon's Tenacity (+29 Versatility) if you're topping up your second stat instead. Use the greater tier - the lesser one is +24." },
    { slot = "Chest Enchant", items = { 243977, 243975 }, text = "Mark of the Worldsoul (+50 primary stat); Mark of the Rootwarden (+40 Agility, +15 Speed) trades a little stat for movement." },
    { slot = "Leg Enchant", items = { 244641, 244643 }, text = "Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides split between them." },
    { slot = "Helm, Shoulders and Boots", items = { 244007, 244021, 243983, 243951, 243991, 243953 }, text = "Helm: Empowered Rune of Avoidance (+37) or Empowered Hex of Leeching (+55). Shoulders: Silvermoon's Mending (+166 Leech) or Amirdrassil's Grace (+111 Avoidance). Boots: Shaladrassil's Roots (+28 Leech, +232 Stamina) or Lynx's Dexterity (+19 Avoidance, +232 Stamina). Leech is the stronger sustain pick for a tank; Avoidance for dungeons heavy on unavoidable AoE. Speed (Empowered Blessing of Speed, Akil'zon's Swiftness, Farstrider's Hunt) is just as valid if you'd rather move faster." },
    { slot = "Gems", items = { 240983, 240888, 240894 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Quick Peridot (+17 Haste) in every other socket, or Flawless Versatile Peridot (+16 Haste, +7 Versatility) if you're balancing the two." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "One of your tier-set slots — the four-piece bonus strengthens your Ironfur/Rage loop, worth prioritizing" },
    { slot = "Chest", text = "A large stat budget and often your other tier piece — balance Stamina for your health pool against Versatility for flat mitigation" },
    { slot = "Neck", text = "Usually carries a socket — lean Versatility first, then Mastery" },
    { slot = "Ring", text = "No set bonus attached — use rings to fill out Versatility and Mastery wherever your gear is light" },
    { slot = "Trinket", text = "One trinket built around avoidance, armor, or a defensive proc rather than pure Agility, to smooth out incoming spikes" },
    { slot = "Trinket", text = "A second trinket that adds Stamina or a passive mitigation effect so survivability doesn't get sacrificed entirely for threat" },
    { slot = "Weapon", text = "Bear Form normalizes weapon speed, so take the highest weapon damage item available regardless of type" },
    { slot = "Waist", text = "An easy slot to fill in an extra gem toward whichever secondary — Versatility or Mastery — your build is short on" },
  },
  -- MID1 fallback: SimC has not yet published a MID2 (12.1) default profile
  -- for Guardian, so this loadout is pulled from the MID1 (12.0) profile set
  -- instead. Swap to a MID2 profile once SimC publishes one.
  mplusLoadout = {
    string = "CgGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgZmxsYmZMzmZZgZbZgxMMaimZmFzMzMLjZeADAAAAgZYGLzAAAAQNzysMzMDAgFMDgFzgBsYZbAwMbwA",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.0 (MID1, previous tier)",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CgGADBD3hSPCL9Y9gz68WcKvMAAAAAAAAAAAAgZmxsYmZMziZxMmZZZgZzwoJamZWmZmZmlxMAAAAAAMjNDYZbmBjZZAMFAAAYDzMALGDDYxCAzMAG",
    source = "Blizzard Battle.net API, US region, 2026-10-27: top 50 current-season Mythic+ Guardian Druids by best keystone level in the second week of patch 12.1.5 (period 1086), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (11/50, 22%); 50/50 (100%) ran Elune's Chosen overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Keep Ironfur stacked proactively rather than reactively — mitigation applied before the hit lands is what matters, and Ironfur after the damage is wasted.",
    "Don't neglect Thrash even on single-target fights; its bleed adds meaningful sustained damage and threat.",
    "Use Frenzied Regeneration to smooth out damage between healer cooldowns rather than saving it indefinitely.",
    "Pool Rage slightly before a telegraphed damage spike so you can pump Ironfur right before it lands.",
    "Bear Form itself grants 25 Rage on entry — use that head start rather than opening with an empty Rage bar.",
    "Catweaving is a DPS loss in Midnight — beyond Heart of the Wild every 2 minutes, stay in Bear Form.",
    "On Druid of the Claw, consume Ravage procs as soon as they appear.",
  },
})

-- Restoration --------------------------------------------------------------
-- Revised for 12.1 (Curse of Ula'tek) from Blizzard patch-note content
-- reached via search summaries; the official article could not be fetched
-- directly from this environment, so the specific numbers/mechanics below
-- are UNVERIFIED against the source page and should be treated as
-- provisional pending direct confirmation. No SimC profile exists for this
-- spec, so it is NOT SimC-cross-checked — see the mplusLoadout note in the
-- header above. Innervate is redesigned (now a flat mana-regen effect
-- instead of making spells free); Abundance gets a clearer Regrowth-
-- efficiency threshold and Swiftmend is restored to a punchier single-target
-- emergency heal; Overgrowth's interaction with Nature's Swiftness was
-- changed.
-- 12.1.5 pass (2026-10-13): overview, rotation, cooldowns and tips rechecked
-- against Icy Veins' Restoration Druid rotation page (12.1) and the 12.1.5
-- patch notes (Nature's Bounty redesign).
ns.GuideStore:RegisterSpec("DRUID", 105, {
  specName = "Restoration",
  role = "HEALER",
  overview = {
    "Restoration Druid heals primarily through layered heal-over-time effects (Rejuvenation, Lifebloom, Wild Growth) that cover the whole raid, supplemented by direct heals like Regrowth for spot healing and Swiftmend for instant emergency top-ups.",
    "The core loop is efficient maintenance plus the Abundance cycle. Keep Lifebloom up (on yourself in raid, since the Apex talent Everbloom makes it stack and cleave its bloom healing), Efflorescence under the group (with Lifetreading it follows your Lifebloom target), and 1-2 self-cast Rejuvenations for Photosynthesis. Swiftmend on cooldown followed by Rejuvenation spreads it to three targets through Power of the Archdruid. With 5 Rejuvenations out, Abundance makes Regrowth much cheaper with a much higher crit chance, and the current playstyle is heavily Regrowth-focused.",
    "Patch 12.1.5 redesigned Nature's Bounty: Regrowth now also heals up to 3 allies who have Rejuvenation, for 15% of its healing, lowest health first. Innervate restores 20% of the target healer's maximum mana over 8 seconds — cast it first at about 75% mana and fit in as many as the fight allows. With Flourish, Tranquility extends all your HoTs as it channels, which makes a Rejuvenation-heavy ramp into Tranquility one of the strongest healing cooldowns in the game.",
    "Bring Restoration when you want a mobile healer with strong HoT coverage, near-immortal Lifebloom targets, good mana efficiency, and utility like Ironbark, Innervate, Stampeding Roar and a combat rebirth. Wildstalker is the recommended hero tree; the healing rotation doesn't meaningfully change with Keeper of the Grove.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "haste" },
    { stat = "mastery" },
    { stat = "versatility" },
    { stat = "crit" },
  },
  rotation = {
    { title = "Raid Maintenance", steps = {
        { spellID = 33763, text = "Lifebloom on yourself, plus 1-2 Rejuvenations on yourself to proc Photosynthesis" },
        { spellID = 145205, text = "Efflorescence under a group of players (it follows your Lifebloom target with Lifetreading)" },
        { spellID = 18562, text = "Swiftmend on cooldown on yourself, then Rejuvenation — Power of the Archdruid puts it on three targets" },
        { spellID = 774, text = "Rejuvenation up to 5 active to hold Abundance, and no more than you need" },
        { spellID = 8936, text = "Regrowth with Abundance active as your main heal" },
        { spellID = 48438, text = "Wild Growth during heavier damage — it's your biggest mana cost, so cast fewer when mana runs short" },
    }},
    { title = "Dungeon Healing", steps = {
        { spellID = 33763, text = "Lifebloom on the tank or whoever is taking heavy damage (a central player if the tank wanders, to keep Efflorescence useful)" },
        { spellID = 18562, text = "Swiftmend on cooldown, followed by Rejuvenation if the group is healthy or Regrowth if they're struggling" },
        { spellID = 48438, text = "Wild Growth on cooldown for light to moderate group damage" },
        { spellID = 774, text = "Before predictable heavy group damage: Rejuvenation on the DPS to reach 5 for Abundance, then Swiftmend into Regrowth as it lands and more Regrowth until it's over" },
        { spellID = 132158, text = "Nature's Swiftness into Regrowth for a sudden big hit on one player", condition = "With Overgrowth, that Regrowth also applies Lifebloom, Rejuvenation and Wild Growth" },
        { spellID = 5176, text = "Wrath (or Starsurge if talented) when nobody needs healing" },
    }},
    { title = "Cooldown Usage", steps = {
        { spellID = 740, text = "Tranquility after a ramp of Rejuvenations, a Wild Growth and a few Regrowths — with Flourish it extends all of them, opening a long Abundance window" },
        { spellID = 391528, text = "Convoke the Spirits during dangerous damage; Flourish gives it a chance to extend your HoTs too" },
        { spellID = 33891, text = "Incarnation: Tree of Life for a long healing phase or heavy movement (instant Regrowth)", condition = "Choice node with Convoke the Spirits" },
        { spellID = 29166, text = "Innervate starting around 75% mana, as many times as the fight allows; self-cast in most cases" },
        { spellID = 102342, text = "Ironbark on anyone about to take heavy damage — the cooldown is short, so use it often" },
    }},
  },
  cooldowns = {
    { spellID = 740, text = "Tranquility — group heal that, with Flourish, extends all your HoTs; plan a ramp before it" },
    { spellID = 391528, text = "Convoke the Spirits — short-cooldown burst of random Druid spells; use it during the most dangerous moments" },
    { spellID = 33891, text = "Incarnation: Tree of Life — choice-node alternative to Convoke for longer healing phases" },
    { spellID = 29166, text = "Innervate — restores 20% of a healer's maximum mana over 8 seconds, on a 3-minute cooldown" },
    { spellID = 132158, text = "Nature's Swiftness — instant, stronger Regrowth for emergencies" },
    { spellID = 102342, text = "Ironbark — 20% damage reduction on an ally for 12 seconds, off the GCD" },
    { spellID = 22812, text = "Barkskin — personal defensive on a short cooldown" },
  },
  consumables = {
    { slot = "Flask", items = { 241324, 241322 }, text = "Flask of the Blood Knights for Haste, this spec's top secondary; Flask of the Magisters if your gear already leans hard into Haste and Mastery is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 241300, 241294, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Haste for this spec, so use it with your healing cooldowns. Mana potions are weak this season: Lightfused Mana Potion (26,200 mana) is the safe one, Potion of Devoured Dreams gives more over 10s but leaves you defenceless while it channels. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 243736 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Oil of Dawn instead if you'd rather your heals proc a small absorb on their target." },
    { slot = "Weapon Enchant", items = { 244029, 243973, 273072, 243997 }, text = "Acuity of the Ren'dorei procs +67 primary stat for 15s; Berserker's Rage procs +124 Haste instead and wins if your stat weights put Haste well clear of the rest. Rite of the Hash'ey (12.1: +139 of a random secondary, favouring your highest above 80% health) is the third option. Worldsoul Cradle (heals proc a 12.5k barrier on the target) is the healer-flavoured alternative." },
    { slot = "Ring Enchants", items = { 244015, 243959 }, text = "Silvermoon's Alacrity (+29 Haste) on both rings; Zul'jin's Mastery (+29 Mastery) if you're topping up your second stat instead. Use the greater tier - the lesser one is +24." },
    { slot = "Chest Enchant", items = { 243977, 244003 }, text = "Mark of the Worldsoul (+50 primary stat); Mark of the Magister (+40 Intellect, +5% mana) if mana is what runs out." },
    { slot = "Leg Enchant", items = { 240133, 240155 }, text = "Sunfire Silk Spellthread (+41 Intellect, +115 Stamina); Arcanoweave Spellthread (+41 Intellect, +4% mana) if you'd rather have the mana than the health." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240888, 240892 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Quick Peridot (+17 Haste) in every other socket, or Flawless Masterful Peridot (+16 Haste, +7 Mastery) if you're balancing the two." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "One of your tier-set slots — the four-piece bonus adds real throughput to your HoT coverage, worth prioritizing" },
    { slot = "Chest", text = "A large stat budget and often your other tier piece — lean Haste first to smooth HoT ticks and cast times" },
    { slot = "Neck", text = "Usually carries a socket — favor Haste, then Mastery" },
    { slot = "Ring", text = "No set bonus attached — use rings to round out Haste and Mastery" },
    { slot = "Trinket", text = "One mana-efficiency or passive-throughput trinket to stretch your HoT-based healing across a long fight" },
    { slot = "Trinket", text = "A second trinket built around a burst-healing proc or on-use effect you can align with Tranquility/Incarnation" },
    { slot = "Weapon", text = "Take the highest weapon damage staff or one-hand-plus-off-hand — Restoration's healing scales off spellpower and stats, not weapon type" },
    { slot = "Off-hand", text = "A caster off-hand leaning Haste keeps your HoT rolling and cast-heavy spot healing smooth" },
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CkGADBD3hSPCL9Y9gz68WcKvMYMmZZmZMzMmthZwsZsNmBAAAAAAAAAAbDa2YMNzY4BMLzMzMDDzAAAAAAAAAAIAAgZbmlmtZ2sxYmZwMwoZAAmZAYA",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Restoration Druids by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick, tied with 1 other build (2/50, 4% each); 48/50 (96%) ran Wildstalker overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Hold 5 Rejuvenations for Abundance, then lean on Regrowth — but don't cast more Rejuvenations than you need.",
    "Mana trouble usually means Regrowths cast without Abundance, too many Wild Growths in quiet moments, or too few Innervates.",
    "Don't let Lifebloom fall off — Everbloom makes its target nearly immortal and cleaves its bloom to nearby allies.",
    "Pre-HoT the group before known damage so Swiftmend, Regrowth and Tranquility land on top of existing coverage.",
    "Keep Efflorescence down under the group as close to permanently as you can; it's easy to let it lapse while moving.",
    "Go into Cat Form for Heart of the Wild even if you otherwise DPS with Wrath.",
  },
})

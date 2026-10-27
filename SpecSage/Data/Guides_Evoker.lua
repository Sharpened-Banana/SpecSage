local ADDON, ns = ...

-- SpecSage guide data: Evoker
-- 12.1.5 pass (2026-10-13): every spec's overview, rotation, cooldowns
-- and tips here were re-checked against SimC's `midnight` branch (client
-- data 12.1.5.70391: action priority lists, talent and spell tables),
-- spell tooltips and the 12.1.5 patch notes, and corrected where they had
-- drifted; every spellID resolves to the ability its step names. Where an
-- older note further down disagrees with a spec block, the block is current.
-- Preservation has no SimC action list, so its order rests on ability
-- data and patch notes, not a simulated priority.
-- Content targets Midnight (patch 12.1.5). Specs below with an `mplusLoadout`
-- field have that talent string (only) cross-checked against
-- SimulationCraft's public profiles (github.com/simulationcraft/simc,
-- GPLv3) as of patch 12.1; specs without one have no such reference.
-- Rotation/overview/tips/gear prose throughout this file is hand-authored
-- and was reviewed for Midnight ability changes, not derived from or
-- checked against SimC's APLs, and was not re-verified against current
-- tuning this pass — EXCEPT Devastation (1467), Preservation (1468), and Augmentation (1473),
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
-- two hero talent trees, for the two specs that didn't already have one
-- inline (Preservation, Augmentation). Devastation already carried a
-- hero-tree note; a same-session earlier pass incorrectly "corrected" its
-- Mass Disintegrate claim away, on the mistaken belief that Scalecommander
-- and Flameshaper ran an identical actions= list - textually true (both
-- names point at the same file), but the file's own action list dispatches
-- on `talent.mass_disintegrate` internally, a real behavioral branch a
-- flat text diff between two files' output can't see. Re-confirmed
-- directly (grep for `run_action_list,name=sc,if=talent.mass_disintegrate`
-- in MID1_Evoker_Devastation.simc) and restored the original claim.
-- These notes ARE cross-checked against SimC's current `midnight` branch
-- profiles (github.com/simulationcraft/simc) where a real action-list
-- branch exists per hero tree - whether that branch lives across two
-- separate files or as a `talent.X`/`hero_tree.X` conditional inside one -
-- and where SimC's profile set truly has no such branch, or ships no
-- profile for the spec at all, the note says so honestly instead of
-- inventing a rotation change.
-- Later pass (2026-09-01): as of this date guide sites (Wowhead, Icy
-- Veins, Maxroll, Method, Boostmatch) are a permitted source for rotation
-- logic, hero-talent recommendations, and stat priorities. Devastation,
-- Preservation, and Augmentation's overview/rotation/cooldowns/tips were
-- rewritten this pass with real opener sequences, single-target/AoE
-- priority splits, and hero-talent-caused differences pulled from those
-- sites, cross-checked against current spell data for spell IDs. One
-- correction worth flagging: a compendium synthesized from those sites
-- for this pass named "Engulf" as a Flameshaper cooldown for Devastation;
-- direct lookup confirmed Engulf was removed from the game entirely in
-- Midnight (12.1) - Flameshaper's healing-side signature ability, not a
-- Devastation tool to begin with, and gone either way - so it was left
-- out rather than reintroduced. Survival's own file has a similar note
-- for Butchery -> Raptor Swipe. statPriority fields were left untouched
-- throughout, since the sources didn't give a confident order beyond
-- what was already there.
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

-- Devastation ------------------------------------------------------------
ns.GuideStore:RegisterSpec("EVOKER", 1467, {
  specName = "Devastation",
  role = "DAMAGER",
  overview = {
    "Devastation Evoker is a ranged caster spec that blends direct blue-dragonflight spellcasting with red-dragonflight breath attacks, managing Essence as its resource while empowered spells (channel-and-release casts with multiple power levels) add a layer of cast-time tactics.",
    "The core mechanic is Essence, spent on Disintegrate and Pyre and regenerated over time, plus Empower spells (Fire Breath, Eternity Surge) that you can hold longer for a stronger effect at the cost of a longer cast. Dragonrage is the main burst window: it fires Pyres at 3 enemies and makes Essence Burst proc 100% of the time for 18 seconds. With Animosity, each empower cast during it extends the window (by less each time). Shattering Star is no longer a button since Midnight: Shattering Stars makes Eternity Surge release one automatically.",
    "Devastation's two hero trees genuinely change the priority list, not just the flavor: Scalecommander (the most-played tree in high keys) makes each empower spell turn your next Disintegrate into a 3-target Mass Disintegrate that spreads Bombardments, and builds around Deep Breath; Flameshaper gives Fire Breath a second charge through Legacy of the Lifebinder and leans on Pyre in AoE. Both still run the same Essence/empower core described above, and the Rising Fury apex talent turns Dragonrage into Unbound Flame after it ends.",
    "Bring Devastation when you want strong ranged burst damage with excellent AoE via Pyre/Fire Breath, good mobility via Hover, and a rotation that rewards judging empower levels correctly for the situation.",
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
        { spellID = 361469, text = "Pre-cast Living Flame just before the pull to have some Essence banked" },
        { spellID = 357210, text = "Deep Breath first, so Strafing Run's second cast is ready again soon",
          condition = "Scalecommander hero talent only" },
        { spellID = 375087, text = "Dragonrage right on pull — delay it a beat if Bloodlust/Heroism is about to go out so the window lines up" },
        { spellID = 359073, text = "Eternity Surge at rank 1 on a single target — it also releases a Shattering Star" },
        { spellID = 357208, text = "Fire Breath at rank 1 on a single target, using Tip the Scales to fire it instantly" },
        { spellID = 356995, text = "Disintegrate until Essence and Essence Burst run dry" },
        { spellID = 361469, text = "Living Flame as filler once you're out of other resources" },
        { text = "Opener Notes: Devastation splits along the Flameshaper and Scalecommander hero trees — Scalecommander's Mass Disintegrate talent turns your next Disintegrate into a multi-target strike, giving it a genuinely different priority list from Flameshaper, so check which one your loadout uses" },
    }},
    { title = "Single Target", steps = {
        { spellID = 357210, text = "Deep Breath whenever Strafing Run's window to recast it is about to run out",
          condition = "Scalecommander hero talent only" },
        { spellID = 375087, text = "Dragonrage on cooldown unless adds are about to spawn" },
        { spellID = 359073, text = "Eternity Surge on cooldown — with Animosity, it and Fire Breath both extend Dragonrage, so don't skip them for filler" },
        { spellID = 357208, text = "Fire Breath on cooldown, at rank 1 on a single target" },
        { spellID = 370553, text = "Tip the Scales on Fire Breath (Scalecommander), or during Dragonrage (Flameshaper)" },
        { spellID = 356995, text = "Disintegrate as your Essence spender — chain it into the next cast on its last tick instead of always running it to completion, and spend Mass Disintegrate charges first on Scalecommander" },
        { spellID = 1292321, text = "Unbound Flame (Dragonrage's replacement after it ends, with the Rising Fury apex talent) while Essence Burst isn't capped" },
        { spellID = 361469, text = "Living Flame on Burnout procs, or as filler when nothing else is up" },
        { spellID = 1265872, text = "Azure Sweep when you have it, then Azure Strike while moving" },
        { text = "Don't let Essence or Essence Burst sit capped — spend it before it overflows" },
    }},
    { title = "AoE", steps = {
        { spellID = 359073, text = "Eternity Surge, matching the empower level to the target count (rank 2 for 2 targets, 3 for 3, and so on; Eternity's Span doubles those counts)" },
        { spellID = 357208, text = "Fire Breath ranked up for more targets, to spread its damage-over-time across the pack" },
        { spellID = 357211, text = "Pyre replaces Disintegrate at about 5 targets (4 with two points in Volatility); Flameshaper with Legacy of the Lifebinder starts at 3 with full Volatility or Feed the Flames" },
        { spellID = 356995, text = "Mass Disintegrate still beats Pyre while you have a charge of it",
          condition = "Scalecommander hero talent only" },
        { spellID = 357210, text = "Deep Breath on cooldown at 2+ targets",
          condition = "Scalecommander hero talent only" },
        { spellID = 1265872, text = "Azure Sweep / Azure Strike as filler" },
    }},
  },
  cooldowns = {
    { spellID = 375087, text = "Dragonrage — main burst cooldown, open with it on pull (delaying slightly to catch Bloodlust); with the Rising Fury apex talent it becomes Unbound Flame for the rest of its cooldown" },
    { spellID = 357208, text = "Fire Breath — empowered breath; on a single target rank 1 is fine, rank up for more targets; also extends Dragonrage if you're talented into Animosity" },
    { spellID = 359073, text = "Eternity Surge — empowered burst spell that also launches a Shattering Star; match the empower level to the target count" },
    { spellID = 370553, text = "Tip the Scales — makes your next empower spell instant at max rank; pair it with Fire Breath" },
    { spellID = 357210, text = "Deep Breath — Scalecommander's cooldown; with Strafing Run it can be cast a second time within 18 seconds" },
    { spellID = 363916, text = "Obsidian Scales — defensive, reduces damage taken" },
    { text = "Zephyr / Renewing Blaze (talent-dependent) — situational defensive/mobility cooldowns" },
  },
  consumables = {
    { slot = "Flask", items = { 241326, 241322 }, text = "Flask of the Shattered Sun for Critical Strike, this spec's top secondary; Flask of the Magisters if your gear already leans hard into Critical Strike and Mastery is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 271887, 241308, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Critical Strike for this spec. If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting)." },
    { slot = "Weapon Enchant", items = { 244029, 243971, 273072 }, text = "Acuity of the Ren'dorei procs +67 primary stat for 15s; Jan'alai's Precision procs +124 Critical Strike instead and wins if your stat weights put Critical Strike well clear of the rest. Rite of the Hash'ey (12.1: +139 of a random secondary, favouring your highest above 80% health) is the third option." },
    { slot = "Ring Enchants", items = { 243957, 243987 }, text = "Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; Nature's Fury (+29 Critical Strike) if your sim says otherwise - the difference is tiny." },
    { slot = "Chest Enchant", items = { 243977 }, text = "Mark of the Worldsoul (+50 primary stat)." },
    { slot = "Leg Enchant", items = { 240133 }, text = "Sunfire Silk Spellthread (+41 Intellect, +115 Stamina)." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240904, 240908, 240967 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Deadly Garnet (+17 Critical Strike) in every other socket, or Flawless Masterful Garnet (+16 Critical Strike, +7 Mastery) if you're balancing the two. With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "One of your tier-set slots — the four-piece bonus reinforces your Essence/empower-spell engine, worth prioritizing" },
    { slot = "Chest", text = "A large stat budget and often your other tier piece — push Critical Strike first for Disintegrate/Pyre payoff" },
    { slot = "Neck", text = "Usually carries a socket — favor Critical Strike, then Haste for faster Essence regeneration" },
    { slot = "Ring", text = "No set bonus attached — use rings to round out Critical Strike and Haste" },
    { slot = "Trinket", text = "One on-use trinket timed with Dragonrage so its burst overlaps your main damage window" },
    { slot = "Trinket", text = "A passive secondary-stat trinket to hold sustained damage between Dragonrage windows" },
    { slot = "Weapon", text = "Evokers wield ranged caster weapons — take the highest item level available, since it functions as a stat stick rather than a melee weapon" },
    { slot = "Off-hand", text = "A caster off-hand leaning Critical Strike or Haste keeps your empower spells and Essence spenders hitting hard" },
  },
  -- MID1 fallback: SimC has not yet published a MID2 (12.1) default profile
  -- for Devastation, so this loadout is pulled from the MID1 (12.0) profile
  -- set instead. Swap to a MID2 profile once SimC publishes one.
  mplusLoadout = {
    string = "CsbBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAzMDMDzgBmZGjZaYmpZMWmxMzMz8AzMzAmxMGzMLzMDMwYwCsMGN2GQmBBbYGMzghB",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.0 (MID1, previous tier)",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CsbBPJc41CfcseY0baneJ1IHrBAAAAAAAAAAAjZwgZGmBGYMTjZmpZmZ2mZmZmZmZmZGwMzMzYmZbmZgBGD2glxox2AyMBYDzgZGM8AA",
    source = "Blizzard Battle.net API, US region, 2026-10-27: top 50 current-season Mythic+ Devastation Evokers by best keystone level in the second week of patch 12.1.5 (period 1086), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (5/50, 10%); 48/50 (96%) ran Scalecommander overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Only hold an empowered cast to a higher level when it's safe to stand still that long — a lower, on-time empower often beats a perfect one that gets interrupted by movement.",
    "Open Dragonrage close to pull rather than saving it — line it up with Bloodlust if you can, but don't delay it far past its own cooldown chasing a perfect setup.",
    "Don't let Essence or Essence Burst sit at cap — Living Flame, Disintegrate, and Pyre all exist to keep it flowing.",
    "If you're talented into Animosity, treat Fire Breath and Eternity Surge as Dragonrage-extenders, not just damage — skipping them shortens your burst window.",
    "Shattering Star is passive now (Shattering Stars, from Eternity Surge) — if an old macro or action bar still has it, it's gone.",
    "Use Hover proactively for movement-heavy mechanics rather than eating a cast interruption.",
  },
})

-- Preservation -------------------------------------------------------------
-- Revised for 12.1 (Curse of Ula'tek) from Blizzard patch-note content
-- reached via search summaries; the official article could not be fetched
-- directly from this environment, so the specific numbers below are
-- UNVERIFIED against the source page and should be treated as provisional
-- pending direct confirmation. No SimC profile exists for this spec, so it
-- is NOT SimC-cross-checked — see the mplusLoadout note in the header above.
-- 12.1 buffs Preservation's single-target/triage kit in PvE: Living Flame
-- healing +25%, Verdant Embrace +25% (each buffed again by a 2026-08-25
-- hotfix), and Consume Flame (talent) heals for 240% of the Dream Breath it
-- consumes. Rechecked 2026-10-13 against warcraft.wiki.gg for 12.1.5:
-- Spiritbloom was removed in 12.0.0 and Emerald Communion is now a PvP
-- talent, so both were taken out of this guide; 12.1.5 cut Merithra's
-- Blessing's proc duration to 30s and raised Consume Flame healing by 20%
-- (after fixing it double-dipping on healing increases).
ns.GuideStore:RegisterSpec("EVOKER", 1468, {
  specName = "Preservation",
  role = "HEALER",
  overview = {
    "Preservation Evoker heals through a mix of direct heals, the Echo mechanic (which doubles a future heal on the same target), and strong cooldown-driven raid healing via Dream Breath and Rewind/Time Dilation-style talents.",
    "The core mechanic is Essence, spent on Echo and Emerald Blossom and regenerated over time, plus Echo itself — a buff on an ally that makes your next healing spell cast an extra time on them at 70% strength, rewarding pre-planning rather than purely reactive healing. Temporal Anomaly applies Echo to the first 5 allies it passes through. Essence Burst procs (from Living Flame and Reversion) make your next Essence spell free, and the Merithra's Blessing apex talent upgrades Reversion into a bloom that heals five allies.",
    "Patch 12.1 pushed extra healing into Preservation's single-target/triage tools: Living Flame and Verdant Embrace both hit noticeably harder (and were buffed again by a later hotfix), and Dream Breath moved most of its healing into its heal-over-time. Spiritbloom was removed in Midnight, so Dream Breath, Emerald Blossom and Merithra's Blessing now cover group healing.",
    "Preservation's two hero trees push the kit in different directions: Flameshaper adds a second Dream Breath charge (Legacy of the Lifebinder), and with Consume Flame your Verdant Embrace, Emerald Blossom and Fluttering Seedlings detonate the Dream Breath on allies they heal for extra healing (20% stronger in 12.1.5). Chronowarden leans on Chrono Flame (Living Flame repeats part of your recent healing), Double-time (Dream Breath and Fire Breath crits extend their duration) and Afterimage (empower spells send Chrono Flames).",
    "Bring Preservation when you want a healer with excellent raid cooldown throughput (Dream Breath, Rewind), useful utility like Time Dilation (damage smoothing) and Blessing of the Bronze (movement cooldowns), and a rotation that rewards proactive Echo placement.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "crit" },
    { stat = "mastery" },
    { stat = "haste" },
    { stat = "versatility" },
  },
  rotation = {
    { title = "Priorities", steps = {
        { text = "Ramp pattern for a damage phase: Temporal Anomaly to Echo the group, Dream Breath (which, with 4 ranks of Merithra's Blessing, always upgrades your next Reversion), then Merithra's Blessing, Emerald Blossom on Essence Burst procs, and Verdant Embrace" },
        { spellID = 373861, text = "Temporal Anomaly on cooldown outside a planned ramp too — it's your main Echo engine and a group-wide shield in one cast" },
        { spellID = 355936, text = "Dream Breath (empowered) on cooldown for strong group-wide healing — most of it now comes from the heal-over-time" },
        { spellID = 1256581, text = "Merithra's Blessing (your upgraded Reversion) as soon as it procs — the proc only lasts 30 seconds since 12.1.5" },
        { spellID = 366155, text = "Reversion on your priority targets when it isn't upgraded" },
        { spellID = 360995, text = "Verdant Embrace on cooldown to reposition to and top off an ally at range — buffed in 12.1; on Flameshaper it also detonates their Dream Breath through Consume Flame" },
        { spellID = 355913, text = "Emerald Blossom on Essence Burst procs when the group needs healing" },
        { spellID = 357208, text = "Fire Breath on cooldown — its Leaping Flames makes your next Living Flame hit extra targets, and on Flameshaper, Essence Well gives it a chance at Essence Burst" },
        { spellID = 361469, text = "Living Flame for efficient single-target healing (or damage when topped off) — buffed in 12.1, a stronger filler than before" },
    }},
    { title = "Cooldown usage", steps = {
        { spellID = 363534, text = "Rewind (talent) — your strongest cooldown, heals back part of the damage the group took in the last 5 seconds, so use it right after a spike lands rather than before" },
        { spellID = 359816, text = "Dream Flight for a big raid-wide cooldown window (a choice node with Stasis)" },
        { spellID = 370537, text = "Stasis (talent) to bank 3 helpful spells and unleash them together for an extra burst window" },
        { spellID = 370553, text = "Tip the Scales for an on-demand, fully-empowered Dream Breath or Fire Breath outside your normal cooldown timing" },
        { spellID = 357170, text = "Time Dilation to spread out the damage an ally is about to take" },
        { spellID = 364343, text = "Pre-place Echo on multiple raid members before a known damage phase" },
    }},
    { title = "Opener Notes", steps = {
        { text = "Preservation's two hero talent trees are Flameshaper (also Devastation's) and Chronowarden (also Augmentation's) — check which one your loadout uses" },
        { spellID = 444088, text = "Flameshaper (by far the most-played tree in high keys) adds a second Dream Breath charge and, with Consume Flame, turns Verdant Embrace, Emerald Blossom and Fluttering Seedlings into detonators for the Dream Breath on their targets",
          condition = "Flameshaper hero talent only" },
        { spellID = 431442, text = "Chronowarden shifts your filler toward Living Flame through Chrono Flame, and Double-time extends Dream Breath and Fire Breath when they crit",
          condition = "Chronowarden hero talent only" },
    }},
  },
  cooldowns = {
    { spellID = 363534, text = "Rewind (talent) — the strongest cooldown available, heals back part of the damage the group took in the last 5 seconds; use it right after unavoidable burst damage lands rather than before" },
    { spellID = 359816, text = "Dream Flight — raid-wide healing cooldown, use for a scripted heavy damage phase" },
    { spellID = 370537, text = "Stasis (talent) — banks 3 helpful spells to unleash together for an extra burst window" },
    { spellID = 363916, text = "Obsidian Scales — personal defensive, reduces damage taken" },
    { spellID = 357170, text = "Time Dilation — proactively spreads half of an ally's incoming damage over 8 seconds" },
  },
  consumables = {
    { slot = "Flask", items = { 241326, 241322 }, text = "Flask of the Shattered Sun for Critical Strike, this spec's top secondary; Flask of the Magisters if your gear already leans hard into Critical Strike and Mastery is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 241300, 241294, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Critical Strike for this spec, so use it with your healing cooldowns. Mana potions are weak this season: Lightfused Mana Potion (26,200 mana) is the safe one, Potion of Devoured Dreams gives more over 10s but leaves you defenceless while it channels. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 243736 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Oil of Dawn instead if you'd rather your heals proc a small absorb on their target." },
    { slot = "Weapon Enchant", items = { 244029, 243971, 273072, 243997 }, text = "Acuity of the Ren'dorei procs +67 primary stat for 15s; Jan'alai's Precision procs +124 Critical Strike instead and wins if your stat weights put Critical Strike well clear of the rest. Rite of the Hash'ey (12.1: +139 of a random secondary, favouring your highest above 80% health) is the third option. Worldsoul Cradle (heals proc a 12.5k barrier on the target) is the healer-flavoured alternative." },
    { slot = "Ring Enchants", items = { 243987, 243959 }, text = "Nature's Fury (+29 Critical Strike) on both rings; Zul'jin's Mastery (+29 Mastery) if you're topping up your second stat instead. Use the greater tier - the lesser one is +24." },
    { slot = "Chest Enchant", items = { 243977, 244003 }, text = "Mark of the Worldsoul (+50 primary stat); Mark of the Magister (+40 Intellect, +5% mana) if mana is what runs out." },
    { slot = "Leg Enchant", items = { 240133, 240155 }, text = "Sunfire Silk Spellthread (+41 Intellect, +115 Stamina); Arcanoweave Spellthread (+41 Intellect, +4% mana) if you'd rather have the mana than the health." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240904, 240908 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Deadly Garnet (+17 Critical Strike) in every other socket, or Flawless Masterful Garnet (+16 Critical Strike, +7 Mastery) if you're balancing the two." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "One of your tier-set slots — the four-piece bonus adds real throughput to your Echo/Dream Breath loop, worth prioritizing" },
    { slot = "Chest", text = "A large stat budget and often your other tier piece — lean Haste first to smooth cast times and empowered heal levels" },
    { slot = "Neck", text = "Usually carries a socket — favor Haste, then Mastery" },
    { slot = "Ring", text = "No set bonus attached — use rings to round out Haste and Mastery" },
    { slot = "Trinket", text = "One mana-efficiency or passive-throughput trinket to stretch your healing across a long fight" },
    { slot = "Trinket", text = "A second trinket built around a burst-healing proc you can align with Dream Flight/Rewind" },
    { slot = "Weapon", text = "Evokers wield ranged caster weapons — take the highest item level available as a pure stat stick" },
    { slot = "Off-hand", text = "A caster off-hand leaning Haste keeps your empowered casts and Echo-based healing flowing smoothly" },
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CwbBPJc41CfcseY0baneJ1IHrBAAAAAmZmZ2WmZGDjxsZGw2wAAAzYmZmZMMTMmBAAAMzMTGzMzMGzAAjZgFwGYGmQ2YsZYGgZGGA",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Preservation Evokers by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (7/50, 14%); 48/50 (96%) ran Flameshaper overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Place Echo ahead of expected damage rather than reactively — it rewards planning over reacting.",
    "Use empowered Dream Breath at a higher level when it's safe to hold the cast, for stronger group healing.",
    "Save Rewind for right after a big, already-landed damage spike since it heals retroactively.",
    "Blessing of the Bronze is raid utility — keep it up on the group.",
    "Living Flame and Verdant Embrace both got real healing buffs in 12.1 — use them more freely for single-target/triage healing between Dream Breath windows rather than treating them as pure filler.",
    "Spend Essence Burst procs on Emerald Blossom when the group needs healing, or Disintegrate when it doesn't — don't let the proc sit unused either way.",
    "Merithra's Blessing procs only last 30 seconds since 12.1.5 — cast the upgraded Reversion promptly instead of saving it for later.",
  },
})

-- Augmentation ---------------------------------------------------------
-- Revised for 12.1 (Curse of Ula'tek) from Blizzard patch-note content
-- reached via search summaries; the official article could not be fetched
-- directly from this environment, so the specific numbers/mechanics below
-- are UNVERIFIED against the source page and should be treated as
-- provisional pending direct confirmation. No mplusLoadout is shipped for
-- this spec — Augmentation's value is in ally buffs, which SimC's default
-- profiles model poorly, so a SimC-derived talent string would be a weak
-- reference here; see the mplusLoadout note in the header above.
-- Augmentation is a support-damage hybrid, not a pure DPS or healer spec —
-- see the overview below for how it actually plays. 12.1's documented
-- Augmentation-specific change is to the Double-time talent: the bonus
-- stats an ally gains when your Ebon Might critically strikes now last a
-- flat 15 seconds (scaled by Mastery: Timewalker) and refresh if you
-- reapply Ebon Might while the buff is still active.
ns.GuideStore:RegisterSpec("EVOKER", 1473, {
  specName = "Augmentation",
  role = "DAMAGER",
  overview = {
    "Augmentation Evoker is a support-damage hybrid, not a conventional DPS spec: most of its value doesn't come from its own damage meter position, it comes from making everyone else's damage bigger. It casts a moderate amount of direct damage itself, but its actual job is buffing allies through Ebon Might and Prescience.",
    "The core mechanic is keeping Ebon Might rolling — since Midnight it automatically gives every damage-dealing ally nearby 8% of your primary stat (split when more than 2 allies are covered) and raises your own damage by 20% — and placing Prescience, a 3% crit buff with 2 charges, on damage dealers whose own cooldowns are active. Eruption, Deep Breath/Breath of Eons and your empower spells (Fire Breath, Upheaval) all extend Ebon Might, so they are only worth casting while it is up. Living Flame and Azure Strike fill the gaps.",
    "Patch 12.1's change specific to this spec touches the Chronowarden Double-time talent: when Ebon Might procs its 50% bonus stats (a chance equal to your critical strike chance), the bonus now lasts a flat 15 seconds and extends if you reapply Ebon Might while it's still active, so a well-timed refresh keeps it rolling.",
    "Augmentation's two hero trees split it further: Chronowarden (Double-time, Temporality and Temporal Burst, the latter two lengthened by Mastery in 12.1.5) pushes buff strength and favors Critical Strike, while Scalecommander turns Eruption into a 3-target Mass Eruption after each empower spell and spreads Bombardments, with Melt Armor's damage doubled in 12.1.5.",
    "Bring Augmentation when your group wants a force-multiplier spec that boosts the whole raid's damage output, especially in coordinated cooldown-stacking compositions, rather than pure personal damage.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "mastery" },
    { stat = "crit" },
    { stat = "haste" },
    { stat = "versatility" },
  },
  rotation = {
    { title = "Priorities", steps = {
        { spellID = 360827, text = "Before the pull: Blistering Scales on your tank, then pre-cast Living Flame" },
        { spellID = 395152, text = "Refresh Ebon Might once it has about 4 seconds or less remaining — don't clip it early; with Double-time, refreshing while its bonus is up also extends the bonus" },
        { spellID = 409311, text = "Prescience on damage dealers early in the fight, then on whoever has a big cooldown coming up — it has 2 charges, so don't let both sit" },
        { spellID = 370553, text = "Tip the Scales with Fire Breath ready, but not while Breath of Eons is about to come off cooldown" },
        { spellID = 403631, text = "Breath of Eons on cooldown, lined up with your group's burst (it replaces Deep Breath once talented)" },
        { spellID = 357208, text = "Fire Breath only while Ebon Might is up — rank 1 if Upheaval is ready, rank 3 otherwise" },
        { spellID = 396286, text = "Upheaval at rank 1, also only while Ebon Might is up" },
        { spellID = 404977, text = "Time Skip to recover your cooldowns faster, outside the Breath of Eons window" },
        { spellID = 395160, text = "Eruption whenever Ebon Might will outlast its cast — it extends Ebon Might, so don't let Essence sit unspent; on Scalecommander, aim it at the target marked by Bombardments" },
        { spellID = 361469, text = "Living Flame as filler, Azure Strike while moving" },
    }},
    { title = "AoE / Cooldown usage", steps = {
        { text = "The single-target priority above barely changes in AoE — the job is still maximizing Ebon Might uptime on the group" },
        { spellID = 403631, text = "Breath of Eons is worth prioritizing even more here since it applies a Temporal Wound to every enemy it flies through" },
        { text = "Time Prescience and Breath of Eons with allies' cooldown windows rather than a fixed rotation — this is the spec's actual damage output, not a buff bolted onto a DPS rotation" },
        { text = "Keep moving to stay within range of the group so Ebon Might and Prescience reach everyone" },
    }},
    { title = "Opener Notes", steps = {
        { text = "Augmentation's two hero talent trees are Chronowarden (also Preservation's) and Scalecommander (also Devastation's) — check which one your loadout uses" },
        { text = "Chronowarden pushes buff strength further and favors Critical Strike, while Scalecommander adds Mass Eruption and Bombardments to your own damage — the Ebon Might/Prescience priority above holds for both" },
    }},
  },
  cooldowns = {
    { spellID = 395152, text = "Ebon Might — core primary-stat buff for every damage dealer nearby, refresh once it has ~4 seconds left" },
    { spellID = 403631, text = "Breath of Eons — major burst cooldown on a 2-minute cycle (replaces Deep Breath), coordinate with allies' own cooldowns" },
    { spellID = 409311, text = "Prescience — 3% crit buff with 2 charges, prioritize damage dealers with strong burst cooldowns of their own" },
    { spellID = 404977, text = "Time Skip — makes your cooldowns recover 10 times faster for 2 seconds" },
    { spellID = 363916, text = "Obsidian Scales — personal defensive, reduces damage taken" },
  },
  consumables = {
    { slot = "Flask", items = { 241322, 241326 }, text = "Flask of the Magisters for Mastery, this spec's top secondary; Flask of the Shattered Sun if your gear already leans hard into Mastery and Critical Strike is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 271887, 241308, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Mastery for this spec. If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting)." },
    { slot = "Weapon Enchant", items = { 244029, 244031, 273072 }, text = "Acuity of the Ren'dorei procs +67 primary stat for 15s; Arcane Mastery procs +124 Mastery instead and wins if your stat weights put Mastery well clear of the rest. Rite of the Hash'ey (12.1: +139 of a random secondary, favouring your highest above 80% health) is the third option." },
    { slot = "Ring Enchants", items = { 243957, 243959 }, text = "Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; Zul'jin's Mastery (+29 Mastery) if your sim says otherwise - the difference is tiny." },
    { slot = "Chest Enchant", items = { 243977 }, text = "Mark of the Worldsoul (+50 primary stat)." },
    { slot = "Leg Enchant", items = { 240133 }, text = "Sunfire Silk Spellthread (+41 Intellect, +115 Stamina)." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240896, 240898, 240967 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Masterful Amethyst (+17 Mastery) in every other socket, or Flawless Deadly Amethyst (+16 Mastery, +7 Critical Strike) if you're balancing the two. With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "One of your tier-set slots — the four-piece bonus strengthens your Ebon Might/Prescience uptime, worth prioritizing" },
    { slot = "Chest", text = "A large stat budget and often your other tier piece — push Critical Strike first, since your buffs scale partly off your own stats" },
    { slot = "Neck", text = "Usually carries a socket — favor Critical Strike, then Haste for more frequent buff refreshes" },
    { slot = "Ring", text = "No set bonus attached — use rings to round out Critical Strike and Haste" },
    { slot = "Trinket", text = "One on-use trinket timed with Breath of Eons so its burst lines up with the raid's coordinated cooldown window" },
    { slot = "Trinket", text = "A passive secondary-stat trinket to keep your own direct damage relevant between cooldown windows" },
    { slot = "Weapon", text = "Evokers wield ranged caster weapons — take the highest item level available as a stat stick" },
    { slot = "Off-hand", text = "A caster off-hand leaning Critical Strike or Haste supports both your own damage and your buff uptime" },
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CEcBPJc41CfcseY0baneJ1IHrNMzMbzMzMzyMYmlZYmxMAAAAAAAAwM8AmBjpGzMzAAAAgZmZMmZ2GzMwMbGYMjFWgBmhhGxCYmZGAYA",
    source = "Blizzard Battle.net API, US region, 2026-10-27: top 31 current-season Mythic+ Augmentation Evokers by best keystone level in the second week of patch 12.1.5 (period 1086), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (2/31, 6%); 27/31 (87%) ran Chronowarden overall.",
    patch = "12.1.5",
    sampleSize = 31,
  },
  tips = {
    "Communicate with the allies you're buffing so Ebon Might and Prescience land while their own cooldowns are active.",
    "Don't treat this as a pure personal-damage spec — your buff uptime on the raid matters more than your own damage meter position.",
    "Reapply Prescience before it expires, and consider swapping targets if a different ally's cooldown window is coming up.",
    "Coordinate your major cooldowns with the raid's overall burst plan rather than using them purely on cooldown.",
    "If you've talented Double-time, refresh Ebon Might while its bonus-stat proc is still active rather than letting it lapse — since 12.1 the refresh extends the bonus instead of needing a new proc to restart it.",
    "Spend Essence and Essence Burst on Eruption rather than banking it — Eruption is what keeps Ebon Might rolling, so treat it as maintenance, not just damage.",
    "Only fire off Fire Breath or Upheaval while Ebon Might is active; casting them outside the window gives up their scaling.",
  },
})

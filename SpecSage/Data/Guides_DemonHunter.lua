local ADDON, ns = ...

-- SpecSage guide data: Demon Hunter
-- 12.1.5 pass (2026-10-13): every spec's overview, rotation, cooldowns
-- and tips here were re-checked against SimC's `midnight` branch (client
-- data 12.1.5.70391: action priority lists, talent and spell tables),
-- spell tooltips and the 12.1.5 patch notes, and corrected where they had
-- drifted; every spellID resolves to the ability its step names. Where an
-- older note further down disagrees with a spec block, the block is current.
-- Inertia now reads: The Hunt or Vengeful Retreat empowers your next Fel
-- Rush or Felblade, which grants 12% damage for 5 sec.
-- Content targets Midnight (patch 12.1.5). Specs below with an `mplusLoadout`
-- field have that talent string (only) cross-checked against
-- SimulationCraft's public profiles (github.com/simulationcraft/simc,
-- GPLv3) as of patch 12.1; specs without one have no such reference.
-- Rotation/overview/tips/gear prose throughout this file is hand-authored
-- and was reviewed for Midnight ability changes, not derived from or
-- checked against SimC's APLs, and was not re-verified against current
-- tuning this pass — EXCEPT Havoc (577) and Vengeance (581),
-- which each gained an `mplusMetaLoadout` (DESIGN.md's v1.4 section) this
-- pass: pulled live from Blizzard's own Battle.net Game Data API
-- (client-credentials OAuth, US region) rather than SimC, on 2026-08-30;
-- Devourer (1480) got its first one on 2026-10-27.
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
-- Both specs' overview/rotation were also corrected this pass, confirmed
-- against SimC's current `midnight` branch profiles (zero hits for the old
-- terms, dozens for the new) and Blizzard's own forums: Havoc's Momentum
-- talent is gone, replaced by Inertia (a Fel Rush/Vengeful Retreat trigger
-- your next action consumes), and Fel Barrage was removed outright, leaving
-- Glaive Tempest as the AoE talent; Vengeance's resource was unified into
-- Fury (not a separate "Pain" resource) long before this patch, and Shear
-- was replaced by Fracture as the baseline Fury/Soul Fragment generator.
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

-- Devourer added (2026-09-02): Demon Hunter's third spec, specID 1480 (see
-- SimC's engine/dbc/generated/sc_specialization_data.inc). See that spec's
-- own block below for full sourcing notes - unlike Havoc/Vengeance above,
-- this is a from-scratch SimC-only pass with no prior community consensus
-- to check it against, since the spec is brand new this pass discovered it.
if not ns.GuideStore then return end

-- Havoc ----------------------------------------------------------------
ns.GuideStore:RegisterSpec("DEMONHUNTER", 577, {
  specName = "Havoc",
  role = "DAMAGER",
  overview = {
    "Havoc Demon Hunter is a fast, highly mobile melee spec that generates and spends Fury to fuel Chaos Strike/Annihilate and Blade Dance, with Eye Beam and Metamorphosis providing large periodic burst windows.",
    "The core resource is Fury, generated passively by Demon Blades (your auto attacks - baseline since Midnight, replacing Demon's Bite) and actively by Felblade and Immolation Aura, and spent on Chaos Strike (Annihilation while transformed) for damage and Blade Dance (Death Sweep) for cleave. Inertia (Momentum's replacement) rewards mobility: The Hunt or Vengeful Retreat empowers your next Fel Rush or Felblade, which then grants 12% damage for 5 seconds. On the Aldrachi Reaver hero tree, Reaver's Glaive empowers your next Blade Dance and Chaos Strike; Fel-Scarred instead turns Metamorphosis into a burst of Demonsurge explosions (each empowered ability's first cast in demon form detonates), upgrades Eye Beam to Abyssal Gaze in demon form through Demonic Intensity, and grants Student of Suffering (Mastery and Fury) whenever you cast Eye Beam.",
    "Bring Havoc when you want extremely high mobility, strong burst windows via Eye Beam and Metamorphosis, and good AoE where Glaive Tempest procs passively off a 3+ target Blade Dance rather than needing its own button, in exchange for a rotation that rewards careful Fury management.",
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
        { spellID = 258920, text = "Immolation Aura just before the pull to start building Fury" },
        { spellID = 370965, text = "The Hunt to close in — with the Eternal Hunt apex talent it also empowers your next Eye Beam" },
        { spellID = 442294, text = "Reaver's Glaive, then the empowered Chaos Strike/Annihilation and Blade Dance it sets up",
          condition = "Aldrachi Reaver hero talent only" },
        { spellID = 198013, text = "Eye Beam to enter demon form through the Demonic talent" },
        { spellID = 191427, text = "Metamorphosis once Blade Dance and Eye Beam are both on cooldown (Chaotic Transformation resets them)" },
        { spellID = 210152, text = "Death Sweep and Annihilation to spend inside demon form — with 4 ranks of Eternal Hunt, a fully channeled Eye Beam lets your next Death Sweep refresh its own cooldown, so you get two" },
        { text = "Opener Notes: Havoc splits along the Aldrachi Reaver and Fel-Scarred hero trees — both keep this opener shape; Aldrachi Reaver adds the Reaver's Glaive step, while Fel-Scarred spends its demon form on the first-cast Demonsurge of each empowered ability (Death Sweep, Annihilation, Abyssal Gaze, Consuming Fire) and gets Student of Suffering from every Eye Beam" },
    }},
    { title = "Single Target", steps = {
        { spellID = 370965, text = "The Hunt on cooldown, unless Reaver's Glaive is already waiting to be thrown" },
        { spellID = 198793, text = "Vengeful Retreat just before Eye Beam comes off cooldown, for Initiative's critical strike buff and an Inertia trigger" },
        { spellID = 442294, text = "Reaver's Glaive whenever its empowered Chaos Strike/Blade Dance buffs aren't already up",
          condition = "Aldrachi Reaver hero talent only" },
        { spellID = 258860, text = "Essence Break, then Death Sweep and Annihilation into the debuff — on Fel-Scarred, save it for when a Demonsurge is ready on those two" },
        { spellID = 452497, text = "Abyssal Gaze (Eye Beam's demon-form upgrade) once your Death Sweep/Annihilation Demonsurges are spent",
          condition = "Fel-Scarred hero talent with Demonic Intensity" },
        { spellID = 198013, text = "Eye Beam on cooldown" },
        { spellID = 232893, text = "Felblade to cash in an Inertia trigger as soon as you have one" },
        { spellID = 188499, text = "Blade Dance / Death Sweep on cooldown" },
        { spellID = 162794, text = "Chaos Strike (Annihilation in demon form) to spend Fury" },
        { spellID = 232893, text = "Felblade as a Fury generator when nothing else is ready — on Fel-Scarred, use it before Chaos Strike while you're at 100 Fury or less" },
        { spellID = 258920, text = "Immolation Aura as the last filler" },
    }},
    { title = "AoE", steps = {
        { text = "The priority barely changes in AoE — Eye Beam and Blade Dance/Death Sweep simply hit more targets" },
        { spellID = 188499, text = "Blade Dance / Death Sweep — Glaive Tempest procs passively once it connects with 3+ targets (spending 25 Fury), it's no longer its own button" },
        { spellID = 258920, text = "Immolation Aura moves ahead of Chaos Strike with 2+ targets if you have A Fire Inside or Burning Wound — and don't sit on 2 charges" },
        { spellID = 185123, text = "Throw Glaive to spread Burning Wound to up to 3 targets if you aren't spreading it with auto attacks" },
    }},
  },
  cooldowns = {
    { spellID = 191427, text = "Metamorphosis — major burst cooldown with extra mobility; if you have Chaotic Transformation, make sure both Blade Dance and Eye Beam are on cooldown before pressing it, and on Fel-Scarred don't recast it while Demonsurges are still unspent" },
    { spellID = 198013, text = "Eye Beam — strong AoE/cleave burst on a 30-second cooldown, and enters demon form through the Demonic talent" },
    { spellID = 370965, text = "The Hunt (talent) — gap closer with burst damage on a 1.5-minute cooldown (shorter with Eternal Hunt), use to open a fight or reposition into a pack" },
    { spellID = 258860, text = "Essence Break (talent) — makes Chaos Strike/Blade Dance deal extra Chaos damage to the target for 4 seconds; fill it with Death Sweep/Annihilation" },
    { spellID = 198793, text = "Vengeful Retreat — repositioning plus Initiative's crit buff and an Inertia trigger; time it just before Eye Beam" },
    { spellID = 198589, text = "Blur — defensive, reduces damage taken and helps with kiting" },
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
    { slot = "Head", text = "One of your tier-set slots — the four-piece bonus reinforces your Fury/burst-window engine, worth prioritizing. Season 2's set bonus specifically: Blade Dance, Chaos Strike, and Essence Break all hit harder, and the four-piece adds a bigger, longer Essence Break debuff." },
    { slot = "Chest", text = "A large stat budget and often your other tier piece — push Critical Strike first for Chaos Strike/Blade Dance payoff" },
    { slot = "Neck", text = "Usually carries a socket — favor Critical Strike, then Haste" },
    { slot = "Ring", text = "No set bonus attached — use rings to round out Critical Strike and Haste" },
    { slot = "Trinket", text = "One on-use trinket timed with Metamorphosis/Eye Beam so its burst overlaps your biggest window" },
    { slot = "Trinket", text = "A passive Agility stat-stick trinket to keep pressure up between cooldowns" },
    { slot = "Weapon", text = "Warglaives (fast one-handers) fit Havoc's dual-wield Fury generation — take the pair with the highest weapon damage" },
    { slot = "Off-hand", text = "Match your off-hand glaive's secondary stats to your main-hand's Critical Strike lean" },
  },
  mplusLoadout = {
    string = "CEkAAAAAAAAAAAAAAAAAAAAAAYAzMzmxMzMmZmMmZAAAAAAAzyDMmtZYmxyMzYZm5BmZWmZWGjBWmFzYY200wMjhNAAAAAAAAmZwAAAAwA",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CEkAvaDi4uyGvRjRjFbhHwBCvYGMzMz2MmZmxYmMmZAAAAAAAzixsNDzMz2MzYZmxMWmZYsMz2MYYstxkMmZMjFAAAAAAEgZGgBgAAAD",
    source = "Blizzard Battle.net API, US region, 2026-10-27: top 50 current-season Mythic+ Havoc Demon Hunters by best keystone level in the second week of patch 12.1.5 (period 1086), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick, tied with 1 other build (6/50, 12% each); 42/50 (84%) ran Aldrachi Reaver overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Don't let Fury sit capped — Demon Blades keeps generating it from auto attacks whether you're ready to spend or not.",
    "With Inertia, follow every The Hunt or Vengeful Retreat with Felblade (or Fel Rush) promptly to turn the trigger into its 12% damage buff.",
    "Press Metamorphosis only after Blade Dance and Eye Beam are on cooldown if you have Chaotic Transformation, since it resets both.",
    "Keep an eye on Blade Dance/Death Sweep cooldown — it's both damage and a defensive parry chance, so don't hold it too long.",
    "On Aldrachi Reaver, throw Reaver's Glaive before Blade Dance and Chaos Strike so both land empowered.",
    "On Fel-Scarred, use each empowered ability once in demon form to trigger its Demonsurge, and spend Fury with Felblade-backed Chaos Strikes rather than pooling it.",
    "Glaive Tempest no longer needs its own button — it procs on its own once Blade Dance connects with 3 or more targets.",
  },
})

-- Vengeance --------------------------------------------------------------
ns.GuideStore:RegisterSpec("DEMONHUNTER", 581, {
  specName = "Vengeance",
  role = "TANK",
  overview = {
    "Vengeance Demon Hunter tanks by building Fury from taking and dealing damage, spending it on Soul Cleave for both damage and self-healing, while Fiery Brand and Demon Spikes provide strong scheduled mitigation.",
    "The core mechanic is Fury, generated by Fracture — the baseline generator since Midnight, two charges, 25 Fury and 2 Soul Fragments per cast — plus Sigil of Flame, Immolation Aura and Felblade, and spent on Soul Cleave, which heals you based on damage dealt. Soul Fragments (from Fracture, Sigil of Spite and Soul Carver) are consumed by Soul Cleave and Spirit Bomb for extra damage and healing. Fiery Brand now brands both you and the target, cutting all damage you take by 40% while it burns.",
    "Bring Vengeance when you want a tank with strong self-sustain through Soul Cleave healing, good burst AoE threat via Spirit Bomb/Fel Devastation, and a scheduled mitigation cooldown (Demon Spikes) that's easy to weave into any rotation. Annihilator (SimulationCraft's default and by far the most-played tree in high keys) builds Voidfall stacks from Fracture and, at 3 stacks, turns Soul Cleave into meteor strikes; Aldrachi Reaver plays around the Reaver's Glaive combo, which empowers your next Fracture and Soul Cleave.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "stamina" },
    { stat = "haste" },
    { stat = "crit" },
    { stat = "versatility" },
    { stat = "mastery" },
  },
  rotation = {
    { title = "Opener", steps = {
        { spellID = 204596, text = "Sigil of Flame placed just before the pull lands" },
        { spellID = 390163, text = "Sigil of Spite precombat too if you're on Aldrachi Reaver or talented into Soul Carver" },
        { spellID = 258920, text = "Immolation Aura as you engage" },
        { spellID = 203720, text = "Demon Spikes once you're in combat, to establish your baseline mitigation" },
        { spellID = 442294, text = "Reaver's Glaive to start the Art of the Glaive combo, then the empowered Fracture and Soul Cleave (10% bonus on whichever comes first, 20% on the second)",
          condition = "Aldrachi Reaver hero talent only" },
        { spellID = 204021, text = "Fiery Brand woven in early to start its damage-reduction window" },
        { text = "Opener Notes: Vengeance splits along the Annihilator and Aldrachi Reaver hero trees — Aldrachi Reaver opens with the Reaver's Glaive combo above, while Annihilator instead builds Voidfall stacks from Fracture and spends them once it reaches 3" },
    }},
    { title = "Single Target", steps = {
        { spellID = 247454, text = "At 3 Voidfall stacks, Spirit Bomb and then Soul Cleave right behind it for a bonus meteor; keep spending stacks with Soul Cleave while Spirit Bomb is on cooldown",
          condition = "Annihilator hero talent only" },
        { spellID = 442294, text = "Reaver's Glaive whenever its Fracture/Soul Cleave empowerments aren't already up, then spend both",
          condition = "Aldrachi Reaver hero talent only" },
        { spellID = 204596, text = "Sigil of Flame when you're low on Soul Fragments" },
        { spellID = 204021, text = "Fiery Brand at 2 charges, or whenever it isn't already burning" },
        { spellID = 390163, text = "Sigil of Spite for 3 more Soul Fragments — on Aldrachi Reaver, while Reaver's Glaive isn't ready" },
        { spellID = 212084, text = "Fel Devastation for burst damage and healing, ideally with Fiery Brand up" },
        { spellID = 207407, text = "Soul Carver, ideally with Fiery Brand already active" },
        { spellID = 263642, text = "Fracture before it caps at 2 charges" },
        { spellID = 247454, text = "Spirit Bomb at 5 Soul Fragments (3 while Fiery Demise is active, 4 in Metamorphosis)",
          condition = "Annihilator hero talent: also in single target; Aldrachi Reaver only uses it in AoE" },
        { spellID = 258920, text = "Immolation Aura on cooldown for damage and Fury" },
        { spellID = 228477, text = "Soul Cleave to spend Fury for damage and self-healing" },
        { spellID = 232893, text = "Felblade, then Throw Glaive, as fillers when nothing else is ready" },
    }},
    { title = "AoE", steps = {
        { text = "The priority stays close to single-target — generating as many Soul Fragments as possible becomes the goal" },
        { spellID = 247454, text = "Spirit Bomb (25-second cooldown) to detonate up to 5 Soul Fragments across the pack, in place of Soul Cleave when 3+ enemies are in range" },
        { spellID = 263642, text = "Fracture to build Soul Fragments quickly across a pack" },
        { spellID = 204596, text = "Sigil of Flame to hit and debuff a group of adds on pull" },
        { spellID = 258920, text = "Immolation Aura on cooldown, it hits everything nearby passively" },
        { spellID = 212084, text = "Fel Devastation for strong AoE burst and self-healing" },
    }},
    { title = "Mitigation", steps = {
        { spellID = 203720, text = "Demon Spikes as your maintenance defensive — use proactively and never let its charges sit at cap" },
        { spellID = 204021, text = "Fiery Brand cuts all damage you take by 40% while it's active on you and the target" },
        { spellID = 228477, text = "Soul Cleave for reliable self-healing on top of raw damage reduction tools" },
        { spellID = 187827, text = "Metamorphosis (tank form) for a major defensive/offensive cooldown" },
        { text = "Alternate Metamorphosis and Fiery Brand so at least one is active whenever possible, rather than stacking both together" },
    }},
  },
  cooldowns = {
    { spellID = 204021, text = "Fiery Brand — major defensive, brands you and the target to cut all damage you take by 40%; alternate it with Metamorphosis so one of the two is up whenever possible" },
    { spellID = 187827, text = "Metamorphosis — 2-minute cooldown that heals you, raises max health and armor and boosts Fracture; with the Untethered Rage apex talent, Soul Cleave/Spirit Bomb can proc a free cast, so use those procs" },
    { spellID = 203720, text = "Demon Spikes — frequent mitigation charge, use proactively rather than reactively; keep it recharging rather than sitting at cap" },
    { spellID = 207407, text = "Soul Carver — burst damage and Soul Fragments, line it up with Fiery Brand when you can" },
    { spellID = 390163, text = "Sigil of Spite — 1-minute burst that shatters 3 Soul Fragments" },
    { spellID = 212084, text = "Fel Devastation — damage + self-healing cooldown, use when a healing boost is valuable, ideally with Fiery Brand up" },
  },
  consumables = {
    { slot = "Flask", items = { 241324, 241326, 241320 }, text = "Flask of the Blood Knights for Haste, this spec's top secondary; Flask of the Shattered Sun if your gear already leans hard into Haste and Critical Strike is the stat you're short on. Flask of Thalassian Resistance (Versatility) is the survivability pick for progression." },
    { slot = "Food", items = { 255846, 275265, 242275, 275259 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina), or the 12.1 Loa's Gathering, Feast of Knowledge or Amani Cornucopia (about +72 of your highest secondary, +108 Stamina) - for a tank the two families come out about even, so eat whichever is down. Personal: Royal Roast (+50 primary) or Hearty Venom-Spiced Cutlets / Hearty Puffer Plate (+65 highest secondary); only feasts give Stamina, and Hearty food persists through death." },
    { slot = "Potion", items = { 241288, 241308, 241286, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Haste for this spec. Light's Potential (+695 primary stat) is a hair behind and never picks the wrong stat. Light's Preservation (a 121k absorb for 30s) for the pull that actually threatens you. Skip Draught of Rampant Abandon - its void zone silences you where you stand, the last thing a tank positioning a pack needs. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 237371, 237369 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from Blacksmithing, if the oil is scarce." },
    { slot = "Weapon Enchant", items = { 273072, 244029, 243973, 243999 }, text = "Rite of the Hash'ey (12.1) procs +139 of a random secondary for 15s, and favours your highest one while you're above 80% health - the guides' pick for most physical specs, on both weapons if you dual-wield. Acuity of the Ren'dorei (+67 primary stat) is close behind; Berserker's Rage (+124 Haste) if your sim puts Haste well clear. Worldsoul Aegis (a 14k barrier that erupts when it breaks) is the defensive alternative." },
    { slot = "Ring Enchants", items = { 244015, 243987 }, text = "Silvermoon's Alacrity (+29 Haste) on both rings; Nature's Fury (+29 Critical Strike) if you're topping up your second stat instead. Use the greater tier - the lesser one is +24." },
    { slot = "Chest Enchant", items = { 243977, 243975 }, text = "Mark of the Worldsoul (+50 primary stat); Mark of the Rootwarden (+40 Agility, +15 Speed) trades a little stat for movement." },
    { slot = "Leg Enchant", items = { 244641, 244643 }, text = "Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides split between them." },
    { slot = "Helm, Shoulders and Boots", items = { 244007, 244021, 243983, 243951, 243991, 243953 }, text = "Helm: Empowered Rune of Avoidance (+37) or Empowered Hex of Leeching (+55). Shoulders: Silvermoon's Mending (+166 Leech) or Amirdrassil's Grace (+111 Avoidance). Boots: Shaladrassil's Roots (+28 Leech, +232 Stamina) or Lynx's Dexterity (+19 Avoidance, +232 Stamina). Leech is the stronger sustain pick for a tank; Avoidance for dungeons heavy on unavoidable AoE. Speed (Empowered Blessing of Speed, Akil'zon's Swiftness, Farstrider's Hunt) is just as valid if you'd rather move faster." },
    { slot = "Gems", items = { 240983, 240888, 240890 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Quick Peridot (+17 Haste) in every other socket, or Flawless Deadly Peridot (+16 Haste, +7 Critical Strike) if you're balancing the two." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "One of your tier-set slots — the four-piece bonus strengthens your Fury/Soul Cleave self-healing loop, worth prioritizing" },
    { slot = "Chest", text = "A large stat budget and often your other tier piece — balance Stamina for your health pool against Versatility for flat mitigation" },
    { slot = "Neck", text = "Usually carries a socket — lean Versatility first, then Mastery" },
    { slot = "Ring", text = "No set bonus attached — use rings to fill out Versatility and Mastery wherever your gear is light" },
    { slot = "Trinket", text = "One trinket built around avoidance, armor, or a defensive proc rather than pure Agility, to smooth out incoming spikes" },
    { slot = "Trinket", text = "A second trinket that adds Stamina or a passive mitigation effect so Soul Cleave healing isn't your only cushion" },
    { slot = "Weapon", text = "Warglaives fit Vengeance's dual-wield Fury generation — take the pair with the highest weapon damage" },
    { slot = "Waist", text = "An easy slot to fill in an extra gem toward whichever secondary — Versatility or Mastery — your build is short on" },
  },
  mplusLoadout = {
    string = "CUkAAAAAAAAAAAAAAAAAAAAAAAAYMzMjZmZkZmZY2MzMjBjZGzYmZGDzYmx2YmtxAAAAAAAABMzM2AAAAwgxMzMzSbzMzAgBAAAgB",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CUkAvaDi4uyGvRjRjFbhHwBCvAAMjZmZMMjMzMGWmZmZgZMzYmZmZGDGmxmZmtxYGAAAAAAABMzM2AAAAwgZmZmZ2abmZGAAAAAgB",
    source = "Blizzard Battle.net API, US region, 2026-10-27: top 49 current-season Mythic+ Vengeance Demon Hunters by best keystone level in the second week of patch 12.1.5 (period 1086), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick, tied with 1 other build (2/49, 4% each); 49/49 (100%) ran Annihilator overall.",
    patch = "12.1.5",
    sampleSize = 49,
  },
  tips = {
    "Use Demon Spikes proactively before damage lands — its charges regenerate, so don't hoard them.",
    "Time Fiery Brand for the highest sustained-damage portion of the fight for maximum value.",
    "Soul Cleave is both your main spender and your primary self-heal — don't neglect it while chasing pure damage.",
    "Keep Immolation Aura on cooldown even outside AoE — the passive damage and Fury generation add up.",
    "Never let Fracture sit at max charges — spend it into Soul Cleave or Spirit Bomb before it caps.",
    "On Aldrachi Reaver, open every Art of the Glaive combo with Reaver's Glaive so both the Fracture and Soul Cleave that follow land empowered.",
    "On Annihilator, once Voidfall reaches 3 stacks, spend them right away — Spirit Bomb followed by Soul Cleave — rather than banking them.",
  },
})

-- Devourer ---------------------------------------------------------------
-- Added 2026-09-02: Devourer (specID 1480) is a new-this-session addition,
-- Demon Hunter's third spec. Unlike Havoc/Vengeance, this entire block is
-- sourced fresh from SimC's `midnight` branch (engine/class_modules/apl/
-- demon_hunter/devourer.simc and profiles/MID2/MID2_Demon_Hunter_Devourer.simc,
-- GPLv3) rather than corrected from older prose, since there is no prior
-- community consensus to check it against yet - flagged as such rather than
-- written with the same confidence as the other two specs. Two notable,
-- APL-confirmed facts: Devourer is the first Intellect/ranged Demon Hunter
-- spec (role=spell, position=back, and a ~3000 Intellect budget in SimC's
-- default gearset vs. low triple-digit Agility on Havoc/Vengeance). (An
-- earlier version of this note said the Hunt talent flipped both hero trees
-- into separate melee action lists; the 12.1.5 APL, rechecked 2026-10-13,
-- has no such split - one list per hero tree, split only by whether Void
-- Metamorphosis is active.) Devourer's own hero trees
-- are Annihilator (hero_tree.annihilator - also referenced by Vengeance's
-- APL, so this tree is shared across Vengeance/Devourer rather than being
-- Devourer-exclusive) and Void-Scarred (hero_tree.voidscarred, exclusive to
-- Devourer in the files checked). mplusLoadout below is Void-Scarred only:
-- SimC has not yet published a separate MID2 Annihilator profile for this
-- spec (only one, internally-named "..._Void-Scarred", exists under MID2 as
-- of this pass). Separately, MID2 profiles for every spec (not just this
-- one) carry a new `omnium_talents=` field with no equivalent in this file's
-- schema or in any MID1 profile - an apparent new patch-12.1 "Omnium" trait
-- layer this pass did not investigate further or attempt to represent here.
-- mplusMetaLoadout: first pulled 2026-10-27 (period 1086), the 2026-09-02
-- pass having had no Battle.net API credentials; same method as the others.
ns.GuideStore:RegisterSpec("DEMONHUNTER", 1480, {
  specName = "Devourer",
  role = "DAMAGER",
  overview = {
    "Devourer is Demon Hunter's newest spec and its first built around Intellect rather than Agility: a void-corrupted caster that fights at range by default, channeling void energy to devour Soul Fragments instead of shredding with glaives up close.",
    "The core loop still runs on Fury, but Devourer spends it differently: outside demon form, Consume builds Fury and Soul Fragments, Reap gathers up to 4 nearby souls, and Void Ray spends Fury. Collect 50 Soul Fragments to fill your Void Metamorphosis stack, then transform. Unlike Havoc/Vengeance's fixed-duration Metamorphosis, Void Metamorphosis drains Fury continuously and ends at 0 Fury; inside it Consume becomes Devour, Reap becomes Cull, Void Ray stops costing Fury and slows the drain, and Collapsing Star becomes your big nuke.",
    "Devourer's two hero talent trees are Annihilator (shared with Vengeance; Voidfall meteors off Reap) and Void-Scarred (Fel-Scarred's counterpart for this spec, adding melee-range Hungering Slash and Voidblade and their demon-form upgrades). Bring Devourer when you want a Demon Hunter that plays like a void-flavored spellcaster rather than Havoc's mobility or Vengeance's tanking. This is still a young spec - treat this guide as a SimulationCraft-APL starting point, not settled best practice.",
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
        { spellID = 1241937, text = "Soul Immolation precombat for its Fury and 3 Soul Fragments" },
        { spellID = 473662, text = "Consume as you pull, building Fury and Soul Fragments" },
        { text = "Pick up Soul Fragments to fill the Void Metamorphosis stack (50 fragments), using Reap at 4+ souls and Void Ray to spend Fury along the way" },
        { spellID = 1217605, text = "Void Metamorphosis as soon as the stack is full" },
        { text = "Opener Notes: both hero trees open this way; Void-Scarred adds Hungering Slash (and a Voidstep-empowered Vengeful Retreat after it) outside demon form, and with The Hunt talented it opens single target with Voidblade, Vengeful Retreat, then The Hunt once the stack is full" },
    }},
    { title = "Outside Void Metamorphosis", steps = {
        { text = "Pick up nearby Soul Fragments as the Void Metamorphosis stack nears full" },
        { spellID = 1217605, text = "Void Metamorphosis once the stack is full" },
        { spellID = 473662, text = "Consume while Soulburst is up — don't let the buff sit" },
        { spellID = 1239123, text = "Hungering Slash on cooldown, then Vengeful Retreat while Voidstep is up",
          condition = "Void-Scarred hero talent only" },
        { spellID = 1226019, text = "Reap (Eradicate if talented) once it can gather 4+ souls — or earlier on Void-Scarred if it would cap your Fury" },
        { spellID = 473728, text = "Void Ray to spend Fury" },
        { spellID = 1241937, text = "Soul Immolation when it isn't already active" },
        { spellID = 473662, text = "Consume as filler" },
    }},
    { title = "Inside Void Metamorphosis", steps = {
        { spellID = 473728, text = "Void Ray at least once per window — it costs no Fury here and slows the drain" },
        { spellID = 1221150, text = "Collapsing Star — on Annihilator, in AoE or whenever Void Ray is on cooldown; on Void-Scarred, right after your first Void Ray" },
        { spellID = 1245470, text = "Reaper's Toll (Hungering Slash's upgrade), Predator's Wake and Pierce the Veil, the demon-form upgrades from Demonic Intensity",
          condition = "Void-Scarred hero talent only" },
        { spellID = 1217610, text = "Devour while Soulburst is up" },
        { spellID = 1245453, text = "Cull (Reap's demon-form version, or Eradicate if talented) once it can gather 4+ souls" },
        { spellID = 1241937, text = "Soul Immolation when your Fury is running low and it isn't already active" },
        { spellID = 1217610, text = "Devour as filler — it generates Fury and shortens Reap's cooldown" },
    }},
    { title = "AoE", steps = {
        { text = "The same priority, with three changes:" },
        { spellID = 1225826, text = "With Eradicate talented, get its buff with Void Ray before you enter demon form and before you Cull/Eradicate — it turns Reap into a 25-yard cone" },
        { spellID = 1221150, text = "Collapsing Star moves to the top of the demon-form priority" },
        { spellID = 1241937, text = "Soul Immolation is used whenever it isn't active, not just when Fury is low" },
    }},
  },
  cooldowns = {
    { spellID = 1217605, text = "Void Metamorphosis - not a flat-duration burst window like Havoc/Vengeance's; it drains Fury until it hits 0, so feed it with Devour, Void Ray and Soul Immolation" },
    { spellID = 1221150, text = "Collapsing Star - your demon-form nuke; since 12.1.5 a cancelled cast no longer triggers a 5-second cooldown, but it only slows the Fury drain for about 1.5 casts' worth of channeling" },
    { spellID = 1246167, text = "The Hunt (talent) - gap closer and burst on a 1.5-minute cooldown; moved to the middle of the talent tree in 12.1.5, and on Void-Scarred with Demonic Intensity, Collapsing Star resets its cooldown" },
    { spellID = 198793, text = "Vengeful Retreat - reposition, and on Void-Scarred spend the Voidstep buff from Hungering Slash on it right away" },
    { spellID = 198589, text = "Blur - defensive, reduces damage taken" },
  },
  consumables = {
    { slot = "Flask", items = { 241324, 241322 }, text = "Flask of the Blood Knights for Haste, this spec's top secondary; Flask of the Magisters if your gear already leans hard into Haste and Mastery is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 271887, 241308, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Haste for this spec. If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 237371, 237369 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from Blacksmithing, if the oil is scarce." },
    { slot = "Weapon Enchant", items = { 273072, 244029, 243973 }, text = "Rite of the Hash'ey (12.1) procs +139 of a random secondary for 15s, and favours your highest one while you're above 80% health - the guides' pick for most physical specs, on both weapons if you dual-wield. Acuity of the Ren'dorei (+67 primary stat) is close behind; Berserker's Rage (+124 Haste) if your sim puts Haste well clear." },
    { slot = "Ring Enchants", items = { 243957, 244015 }, text = "Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; Silvermoon's Alacrity (+29 Haste) if your sim says otherwise - the difference is tiny." },
    { slot = "Chest Enchant", items = { 243977, 243975 }, text = "Mark of the Worldsoul (+50 primary stat); Mark of the Rootwarden (+40 Agility, +15 Speed) trades a little stat for movement." },
    { slot = "Leg Enchant", items = { 244641, 244643 }, text = "Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides split between them." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240888, 240892, 240967 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Quick Peridot (+17 Haste) in every other socket, or Flawless Masterful Peridot (+16 Haste, +7 Mastery) if you're balancing the two. With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "One of your tier-set slots — SimC's default profile has Season 2's set bonus active, but this spec is new enough that the exact 2pc/4pc effects weren't confirmed by the sources checked this pass. Check your in-game tooltip." },
    { slot = "Chest", text = "A large stat budget and often your other tier piece — push your top secondary first" },
    { slot = "Neck", text = "Usually carries a socket — favor Mastery, then Haste" },
    { slot = "Ring", text = "No set bonus attached — use rings to round out Mastery and Haste" },
    { slot = "Trinket", text = "One on-use trinket timed with Metamorphosis so its burst overlaps your transformation window" },
    { slot = "Trinket", text = "A passive Intellect stat-stick trinket to keep pressure up between cooldowns" },
    { slot = "Weapon", text = "Warglaives (fast one-handers) fit Devourer's dual-wield Fury generation, same as Havoc — take the pair with the highest weapon damage" },
    { slot = "Off-hand", text = "Match your off-hand glaive's secondary stats to your main-hand's Mastery lean" },
  },
  mplusLoadout = {
    string = "CgcBAAAAAAAAAAAAAAAAAAAAAAAWMzMzMzMzMwMAAAAAAALzYMYGAAAAAAAAmxMMmZmZYmZGzsNzYsptFAEwAMjZmZbmZa2mZbmZMjBA",
    source = "SimulationCraft default profile, Void-Scarred hero tree (credit, not endorsement of 'best') - SimC has not yet published a separate MID2 Annihilator profile for this brand-new spec",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CgcBvaDi4uyGvRjRjFbhHwBCvAA2mxMzMzYmxwMAAAAAAALGz2gZAAAAAAAAYGzwMzMzMzMzMMziZMWkFmZmZ2abmZGADDABegxMMmB",
    source = "Blizzard Battle.net API, US region, 2026-10-27: top 49 current-season Mythic+ Devourer Demon Hunters by best keystone level in the second week of patch 12.1.5 (period 1086), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (10/49, 20%); 32/49 (65%) ran Annihilator overall.",
    patch = "12.1.5",
    sampleSize = 49,
  },
  tips = {
    "This spec is still young — everything here follows SimulationCraft's current APL, not settled best practice.",
    "Devourer is Intellect, not Agility — don't carry over Havoc/Vengeance gear or gem/enchant choices by habit.",
    "Track your Void Metamorphosis stack, not just Fury — you transform once it's full (50 Soul Fragments), and skipping fragment pickups delays your next window.",
    "Void Metamorphosis drains Fury the whole time it's active and ends at 0 — Void Ray costs nothing inside it and slows the drain, so never skip it.",
    "Reap, Cull and Eradicate are one button (Cull in demon form, Eradicate if talented) — wait until it can gather 4 or more souls.",
    "Soul Immolation isn't a damage-over-time effect: it heals you and generates Fury and Soul Fragments, so use it to feed demon form.",
  },
})

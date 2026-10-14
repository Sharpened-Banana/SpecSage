local ADDON, ns = ...

-- SpecSage guide data: Rogue (Assassination 259, Outlaw 260, Subtlety 261)
-- 12.1.5 pass (2026-10-13): every spec's overview, rotation, cooldowns
-- and tips here were re-checked against SimC's `midnight` branch (client
-- data 12.1.5.70391: action priority lists, talent and spell tables),
-- spell tooltips and the 12.1.5 patch notes, and corrected where they had
-- drifted; every spellID resolves to the ability its step names. Where an
-- older note further down disagrees with a spec block, the block is current.
-- Content targets Midnight (patch 12.1.5). Specs below with an `mplusLoadout`
-- field have that talent string (only) cross-checked against
-- SimulationCraft's public profiles (github.com/simulationcraft/simc,
-- GPLv3) as of patch 12.1; specs without one have no such reference.
-- Rotation/overview/tips/gear prose throughout this file is hand-authored
-- and was reviewed for Midnight ability changes, not derived from or
-- checked against SimC's APLs, and was not re-verified against current
-- tuning this pass — EXCEPT Assassination (259), Outlaw (260), and Subtlety (261),
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
-- Subtlety's overview/rotation/tips were also corrected this pass: Symbols
-- of Death has zero references in SimC's current `midnight` branch
-- profile, confirmed via a Blizzard forum thread on the ability's removal
-- ("It got removed this patch!") — its energy refund and combo-point boost
-- were folded directly into Shadow Dance, which now carries that role
-- alone.
-- A later pass (2026-09-01) enriched all three specs' overview/rotation/
-- cooldowns/tips with opener sequences, single-target-vs-AoE priority
-- nuances, cooldown-syncing notes, and hero-talent-caused differences,
-- drawing on guide sites (Wowhead/Icy Veins/Maxroll/Method/Boostmatch),
-- now a permitted source per repo policy (see
-- .claude/skills/specsage-refresh/SKILL.md). All prose was rewritten in
-- SpecSage's own words rather than copied from any source, and every
-- spellID added was verified against Wowhead rather than guessed. This
-- pass built on top of the already-corrected mechanic names above (no
-- stale Symbols of Death references were reintroduced).
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

ns.GuideStore:RegisterSpec("ROGUE", 259, {
  specName = "Assassination",
  role = "DAMAGER",
  overview = {
    "Assassination Rogue is a poison- and bleed-focused melee spec built around keeping Garrote and Rupture active on the target while spending combo points on Envenom for direct damage. It rewards careful DoT upkeep and combo point discipline over raw button-mashing.",
    "The core resource is Energy, regenerating over time and spent to build combo points with Mutilate/Fan of Knives, which are then spent on finishers like Envenom and Rupture. The defining mechanic is bleed and poison uptime — Garrote, Rupture, and your poisons all need to be refreshed before falling off to avoid a significant damage loss. Deathmark (2-minute cooldown) opens the spec's main burst window and Kingsbane (1-minute cooldown) goes out inside every Deathmark, plus once on its own in between. Envenom is spent to keep its own buff rolling and to dump Energy, rather than the instant you reach 5 combo points.",
    "Assassination brings strong sustained single-target damage, solid AoE by opening a pull with Crimson Tempest to spread bleeds before settling into Fan of Knives, and good execute-phase scaling, making it a reliable pick for longer fights where consistent uptime matters more than burst windows.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "crit" },
    { stat = "haste" },
    { stat = "mastery" },
    { stat = "versatility" },
  },
  rotation = {
    { title = "Opener", steps = {
        { spellID = 2823, text = "Deadly Poison applied to your weapon before you engage" },
        { spellID = 381664, text = "Amplifying Poison applied alongside it — both should already be active when you open" },
        { spellID = 703, text = "Garrote to open from Stealth for its bonus damage" },
        { spellID = 1329, text = "Mutilate to start building combo points" },
        { spellID = 1943, text = "Rupture once you're at 5 or more combo points" },
        { spellID = 32645, text = "Envenom at 5+ combo points so its buff is up before Deathmark" },
        { spellID = 360194, text = "Deathmark alongside trinkets, potions, and racials once Garrote and Rupture are both ticking and Envenom's buff is up" },
        { spellID = 385627, text = "Kingsbane right after Deathmark, while Envenom's buff is still up" },
    }},
    { title = "Single Target", steps = {
        { spellID = 703, text = "Garrote kept up — refresh before it falls off, and re-apply from Stealth (Vanish with Improved Garrote) for the stronger version" },
        { spellID = 1943, text = "Rupture kept up at 5+ combo points — refresh before it falls off" },
        { spellID = 360194, text = "Deathmark on cooldown once Garrote, Rupture and Envenom's buff are all up and Kingsbane is ready" },
        { spellID = 385627, text = "Kingsbane inside Deathmark, and again on its own when Deathmark still has most of its cooldown left" },
        { spellID = 32645, text = "Envenom at 5+ combo points when its buff is about to drop, during Deathmark, or above 70% Energy" },
        { text = "Darkest Night (Deathstalker): build to a full combo-point bar before that Envenom instead of stopping at 5", condition = "Deathstalker hero talent only" },
        { spellID = 5938, text = "Shiv as a builder with Toxic Stiletto when topping up combo points for Darkest Night", condition = "Deathstalker hero talent only" },
        { spellID = 1298826, text = "Thistle Tea when Energy drops below 30% (or let it drink itself, if you took the passive version)" },
        { text = "Ambush whenever Blindside makes it free" },
        { spellID = 1329, text = "Mutilate as the primary combo point builder" },
        { text = "Refresh poisons before they expire — lost uptime is a real DPS loss" },
    }},
    { title = "AoE", steps = {
        { spellID = 1247227, text = "Crimson Tempest first to spread your bleeds — it's a combo point builder that copies your longest Garrote and Rupture onto up to 2 more enemies" },
        { spellID = 51723, text = "Fan of Knives as the primary combo point builder against 3+ targets" },
        { spellID = 2823, text = "Deadly Poison spread to all engaged targets" },
        { spellID = 1943, text = "Rupture and Garrote maintained on priority targets once poisons are spread" },
        { spellID = 421975, text = "Caustic Spatter passively cleaves a share of your Envenom/Kingsbane damage to nearby targets — no priority change needed, it just works alongside your normal finishers" },
        { spellID = 32645, text = "Envenom to spend combo points when Rupture upkeep isn't needed — with 4+ targets you can spend above 30% Energy" },
    }},
    { title = "Opener Notes", steps = {
        { text = "Open from Stealth with Garrote for its bonus damage, then build toward Rupture" },
        { text = "Get Envenom's buff up before Deathmark — Deathmark and Kingsbane both want it active" },
        { text = "Deathmark hits hardest once both Garrote and Rupture are already ticking — don't fire it before your bleeds are established" },
        { text = "Your hero talent choice changes the Envenom threshold: Deathstalker builds to a full combo-point bar for the Envenom that consumes Darkest Night (Shiv with Toxic Stiletto tops it off), while Fatebound plays the same builder/finisher loop without that cap change" },
    }},
  },
  cooldowns = {
    { spellID = 360194, text = "Deathmark — core 2-minute offensive cooldown; press it with Garrote, Rupture and Envenom's buff up and Kingsbane ready" },
    { spellID = 385627, text = "Kingsbane — 1-minute poison burst cooldown; one inside every Deathmark, one on its own in between" },
    { spellID = 1298826, text = "Thistle Tea — three charges of 100 Energy; drink one when you fall below 30% Energy (the passive version drinks itself)" },
    { spellID = 31224, text = "Cloak of Shadows — major magic defensive, clears many magic effects" },
    { spellID = 5277, text = "Evasion — physical defensive cooldown" },
    { spellID = 1856, text = "Vanish — reset positioning, re-open with a stealth opener, or drop aggro" },
  },
  consumables = {
    { slot = "Flask", items = { 241326, 241324 }, text = "Flask of the Shattered Sun for Critical Strike, this spec's top secondary; Flask of the Blood Knights if your gear already leans hard into Critical Strike and Haste is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 271887, 241308, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Critical Strike for this spec. If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 237371, 237369 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from Blacksmithing, if the oil is scarce." },
    { slot = "Weapon Enchant", items = { 273072, 244029, 243971 }, text = "Rite of the Hash'ey (12.1) procs +139 of a random secondary for 15s, and favours your highest one while you're above 80% health - the guides' pick for most physical specs, on both weapons if you dual-wield. Acuity of the Ren'dorei (+67 primary stat) is close behind; Jan'alai's Precision (+124 Critical Strike) if your sim puts Critical Strike well clear." },
    { slot = "Ring Enchants", items = { 243957, 243987 }, text = "Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; Nature's Fury (+29 Critical Strike) if your sim says otherwise - the difference is tiny." },
    { slot = "Chest Enchant", items = { 243977, 243975 }, text = "Mark of the Worldsoul (+50 primary stat); Mark of the Rootwarden (+40 Agility, +15 Speed) trades a little stat for movement." },
    { slot = "Leg Enchant", items = { 244641, 244643 }, text = "Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides split between them." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240904, 240906, 240967 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Deadly Garnet (+17 Critical Strike) in every other socket, or Flawless Quick Garnet (+16 Critical Strike, +7 Haste) if you're balancing the two. With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "Tier set piece — the set bonus usually matters more than a small item-level gap" },
    { slot = "Neck", text = "Favor Haste to speed up combo point generation and DoT ticks" },
    { slot = "Back", text = "Secondary stats matching Haste and Crit outweigh a pure item-level chase" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece leaning Haste and Crit" },
    { slot = "Ring", text = "Haste or Crit rings depending on your current stat weights" },
    { slot = "Trinket", text = "One on-use Agility or damage trinket lined up with Deathmark" },
    { slot = "Trinket", text = "A passive stat-stick trinket for consistent bleed and poison damage" },
    { slot = "Weapon", text = "Two matched, high item level daggers or one-handers — both weapons carry Assassination's bleed and poison damage equally" },
  },
  mplusLoadout = {
    string = "CMQAAAAAAAAAAAAAAAAAAAAAAYmlxsNDGAAAAAYWGsNDAAAAAIbzMzMzMjxyMzMbzsMzMzYGzYMmZMMAbmlBGwSwywEYYxgZGgxYA",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CMQA5HmDzx68KWyrW/8Y781L7bmlZmFDAAAAAAzygtZAAAAAAttNzMzMzMGLzMzsNzyMz8AmxMjxMmZMGADsAzY0YWAZbAbGAMzMDfA",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Assassination Rogues by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (3/50, 6%); 37/50 (74%) ran Fatebound overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Never let Rupture or Garrote fall off a target you'll be attacking for more than a few seconds.",
    "Keep your weapon poisons refreshed — a lapsed poison is a silent DPS loss.",
    "Kingsbane comes back twice per Deathmark — use one inside Deathmark and don't sit on the other waiting for the next window.",
    "Pool Energy heading into a Deathmark window so you can chain Mutilate into Envenom the instant it's up; Envenom freely during Deathmark.",
    "Running Darkest Night, build to a full combo-point bar before the empowered Envenom rather than spending at 5.",
    "Crimson Tempest and Fan of Knives spread your bleeds efficiently — seed DoTs across a pull before settling into single-target finishers.",
  },
})

ns.GuideStore:RegisterSpec("ROGUE", 260, {
  specName = "Outlaw",
  role = "DAMAGER",
  overview = {
    "Outlaw Rogue is a swashbuckling melee spec built around Roll the Bones buffs and Combat Potency-style resource generation from off-hand swings. It plays as a flexible, high-mobility spec with Pistol Shot and Between the Eyes providing ranged options unusual for a Rogue.",
    "The core resource is Energy, spent to build combo points with Sinister Strike and Pistol Shot, which are then spent on Dispatch and Between the Eyes. The defining mechanic is Roll the Bones, a buff roll that grants a randomized set of damage buffs — you re-roll it when few buffs are active and hold it when a strong roll lands. Restless Blades means every combo point you spend also shaves time off Adrenaline Rush, Between the Eyes, Blade Rush, Killing Spree, and Roll the Bones, so spending finishers promptly keeps your own cooldowns cycling faster.",
    "Outlaw brings strong burst through Adrenaline Rush and Blade Flurry cleave, solid mobility via Grappling Hook and Sprint, and simple execute-phase scaling with Between the Eyes, making it a versatile pick for both single-target and cleave-heavy fights.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "haste" },
    { stat = "crit" },
    { stat = "versatility" },
    { stat = "mastery" },
  },
  rotation = {
    { title = "Opener", steps = {
        { text = "Open from Stealth with Instant Poison already applied" },
        { spellID = 13750, text = "Adrenaline Rush a second before the pull if you run Improved Adrenaline Rush (with Slice and Dice), otherwise on the pull" },
        { spellID = 1214909, text = "Roll the Bones to establish its bonus before your first finisher" },
        { spellID = 193315, text = "Ambush from Stealth (or Sinister Strike) to start building combo points" },
        { spellID = 315341, text = "Between the Eyes as your first finisher, for its damage buff" },
        { spellID = 2098, text = "Dispatch to close out the opener" },
    }},
    { title = "Single Target", steps = {
        { spellID = 13750, text = "Adrenaline Rush whenever it isn't already running" },
        { spellID = 1214909, text = "Roll the Bones when it isn't up, or when it only gave you a single bonus" },
        { spellID = 381989, text = "Keep It Rolling when Roll the Bones is showing 3 or more bonuses" },
        { spellID = 271877, text = "Blade Rush on cooldown for extra damage and Energy" },
        { text = "Finish at one combo point below your maximum (Fatebound: two below while Between the Eyes is on cooldown)" },
        { spellID = 315341, text = "Between the Eyes — first finisher whenever it's ready" },
        { spellID = 51690, text = "Killing Spree as the next finisher (a 3-minute finishing channel)" },
        { text = "Coup de Grace whenever Unseen Blade has readied it", condition = "Trickster hero talent only" },
        { spellID = 2098, text = "Dispatch as your main finisher otherwise" },
        { text = "Ambush whenever Audacity makes it usable (Hidden Opportunity builds)" },
        { spellID = 185763, text = "Pistol Shot with Opportunity — with Fan the Hammer, before the 6 charges cap or expire" },
        { spellID = 193315, text = "Sinister Strike as the default combo point builder" },
    }},
    { title = "AoE", steps = {
        { spellID = 13877, text = "Blade Flurry to cleave your attacks across nearby targets — refresh it before it drops; 12.1.5 made Deft Maneuvers cost 5 extra Energy per target hit (up to 30) instead of a flat 30" },
        { text = "Otherwise play the near-identical single-target priority — Blade Flurry does the cleaving for you" },
        { spellID = 51690, text = "Killing Spree or equivalent burst tool during add waves" },
        { spellID = 1214909, text = "Roll the Bones for its buffs, especially cleave-relevant ones" },
        { spellID = 2098, text = "Dispatch/finishers to spend combo points across the pull" },
        { text = "Turn on Blade Flurry as soon as 2+ targets are engaged" },
    }},
    { title = "Opener Notes", steps = {
        { text = "Open with Roll the Bones to establish buffs before committing to your main cooldowns" },
        { text = "Line up Adrenaline Rush with a strong Roll the Bones result for maximum burst" },
        { text = "If you're talented into Fan the Hammer, Pistol Shot chains take over as your main combo point builder instead of Sinister Strike — check your build before assuming a fixed generator" },
        { text = "Your hero talent choice also shapes the loop beyond Fan the Hammer: Trickster's Unseen Blade strikes periodically turn a Dispatch into Coup de Grace, while Fatebound finishes a point earlier while Between the Eyes is on cooldown — the Roll the Bones/finisher priority above holds for both" },
    }},
  },
  cooldowns = {
    { spellID = 13750, text = "Adrenaline Rush — core 3-minute offensive cooldown, use on cooldown" },
    { spellID = 51690, text = "Killing Spree — 3-minute finishing channel; spend it right after Between the Eyes" },
    { spellID = 1277933, text = "Preparation (talent) — resets Adrenaline Rush, Between the Eyes, Blade Flurry, Blade Rush and Killing Spree; press it once Adrenaline Rush has more than 30 seconds left and Between the Eyes and Killing Spree are both on cooldown" },
    { text = "Restless Blades (passive) — spending combo points reduces the cooldown of Adrenaline Rush, Between the Eyes, Blade Rush, Killing Spree, and Roll the Bones, so don't sit on finishers" },
    { spellID = 31224, text = "Cloak of Shadows — major magic defensive, clears many magic effects" },
    { spellID = 5277, text = "Evasion — physical defensive cooldown" },
    { spellID = 1856, text = "Vanish — reset positioning or drop aggro" },
  },
  consumables = {
    { slot = "Flask", items = { 241324, 241326 }, text = "Flask of the Blood Knights for Haste, this spec's top secondary; Flask of the Shattered Sun if your gear already leans hard into Haste and Critical Strike is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 271887, 241308, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Haste for this spec. If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 237371, 237369 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from Blacksmithing, if the oil is scarce." },
    { slot = "Weapon Enchant", items = { 273072, 244029, 243973 }, text = "Rite of the Hash'ey (12.1) procs +139 of a random secondary for 15s, and favours your highest one while you're above 80% health - the guides' pick for most physical specs, on both weapons if you dual-wield. Acuity of the Ren'dorei (+67 primary stat) is close behind; Berserker's Rage (+124 Haste) if your sim puts Haste well clear." },
    { slot = "Ring Enchants", items = { 243957, 244015 }, text = "Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; Silvermoon's Alacrity (+29 Haste) if your sim says otherwise - the difference is tiny." },
    { slot = "Chest Enchant", items = { 243977, 243975 }, text = "Mark of the Worldsoul (+50 primary stat); Mark of the Rootwarden (+40 Agility, +15 Speed) trades a little stat for movement." },
    { slot = "Leg Enchant", items = { 244641, 244643 }, text = "Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides split between them." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240888, 240890, 240967 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Quick Peridot (+17 Haste) in every other socket, or Flawless Deadly Peridot (+16 Haste, +7 Critical Strike) if you're balancing the two. With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "Tier set piece — the set bonus usually matters more than a small item-level gap" },
    { slot = "Neck", text = "Favor Haste for faster combo point generation and quicker ability weaving" },
    { slot = "Back", text = "Secondary stats matching Haste and Mastery outweigh a pure item-level chase" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece leaning Haste and Mastery" },
    { slot = "Ring", text = "Haste or Mastery rings depending on your current stat weights" },
    { slot = "Trinket", text = "One on-use Agility or damage trinket lined up with Adrenaline Rush" },
    { slot = "Trinket", text = "A passive stat-stick trinket for consistent damage between cooldowns" },
    { slot = "Weapon", text = "Two matched, high item level one-handers, since Sinister Strike and your finishers scale off both weapons" },
  },
  mplusLoadout = {
    string = "CQQAAAAAAAAAAAAAAAAAAAAAAAgx2MMzMmZmtZmZmZMmF4BmZbaZw2MAAAAAALLzMzwMzMziZmZbAAAAYmBAjZxwQGYWYhWYjBYmBDMA",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CQQA5HmDzx68KWyrW/8Y781L7Dgx2MMzMjZmtZmZMzMzsAmZbaZw2MAAAAAAbbzMzwMzMziZmZbAAAAYmBAjZxwQGYWYhWYjBYmBDMA",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 49 current-season Mythic+ Outlaw Rogues by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (6/49, 12%); 48/49 (98%) ran Trickster overall.",
    patch = "12.1.5",
    sampleSize = 49,
  },
  tips = {
    "Don't re-roll Roll the Bones just because it feels weak — check whether it's actually below the keep threshold first.",
    "Blade Flurry is worth toggling on immediately when a second target joins the fight.",
    "Line up Adrenaline Rush with your best Roll the Bones roll when timing allows.",
    "Between the Eyes' debuff is valuable raid utility — don't only think of it as a finisher.",
    "Spend combo points promptly rather than hoarding them — Restless Blades only shortens your cooldowns when you actually spend a finisher.",
    "Don't let Opportunity stacks sit unused — cash them in with Pistol Shot once they're capped.",
  },
})

ns.GuideStore:RegisterSpec("ROGUE", 261, {
  specName = "Subtlety",
  role = "DAMAGER",
  overview = {
    "Subtlety Rogue is a Shadow-infused melee spec built around Shadow Dance windows, spending combo points on Eviscerate while weaving in Shadowstrike from stealth. Symbols of Death was removed and its energy/combo-point boost folded directly into Shadow Dance itself, so Shadow Dance alone now carries that role. It plays as a burst-window spec, dealing much of its damage inside timed cooldown windows rather than a flat sustained rotation.",
    "The core resource is Energy, spent to build combo points with Shadowstrike and Backstab, then spent on Secret Technique, Eviscerate and Black Powder (Eviscerate also extends Slice and Dice through Cut to the Chase) — combo points cap at 7 instead of the usual 5, so never sit on a full bar without spending. The defining mechanic is Shadow Dance, which grants stealth-like access to Shadowstrike outside of true stealth, making burst windows repeatable throughout a fight rather than limited to the opener.",
    "Subtlety brings strong burst damage inside cooldown windows, good AoE through Black Powder, and useful utility (Shroud of Concealment, Distract), making it a good pick for fights with clear burst phases or add windows to dump cooldowns into.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "mastery" },
    { stat = "haste" },
    { stat = "versatility" },
    { stat = "crit" },
  },
  rotation = {
    { title = "Opener", steps = {
        { text = "Open from Stealth with Instant Poison and Atrophic Poison already applied" },
        { spellID = 185313, text = "Shadow Dance immediately, ideally with enough charges banked to chain a second Dance shortly after" },
        { spellID = 185438, text = "Shadowstrike to open, then keep building combo points inside the Dance" },
        { text = "Eviscerate (or Black Powder on an AoE pull) to spend your first full bar of combo points" },
        { spellID = 121471, text = "Shadow Blades lined up with this first Dance — try to land two Shadow Dance windows inside the same Shadow Blades for the biggest burst" },
    }},
    { title = "Single Target", steps = {
        { spellID = 185313, text = "Shadow Dance with 30+ Energy and Slice and Dice up, timed so Secret Technique is ready inside it (Deathstalker: enter at 2 or fewer combo points)" },
        { spellID = 426591, text = "Goremaw's Bite inside Shadow Dance" },
        { text = "Keep Slice and Dice up — Eviscerate extends it through Cut to the Chase, so just Eviscerate whenever it has dropped" },
        { spellID = 196819, text = "Eviscerate with Darkest Night up, as Deathstalker", condition = "Deathstalker hero talent only" },
        { spellID = 280719, text = "Secret Technique — your main finisher inside Shadow Dance" },
        { text = "Coup de Grace whenever Unseen Blade readies it and Secret Technique isn't about to come back", condition = "Trickster hero talent only" },
        { spellID = 196819, text = "Eviscerate as the finisher otherwise, at maximum combo points (one short is fine with Darkest Night) — never sit on a full bar" },
        { spellID = 185438, text = "Shadowstrike as your combo point builder inside Shadow Dance and Stealth" },
        { spellID = 53, text = "Backstab (or Gloomblade, which replaces it) to build combo points outside of Dance windows" },
        { text = "Watch Shadow Techniques with Ancient Arts — at 5+ stored stacks and Secret Technique ready, spend an extra builder before finishing so the stacks become Shadow Clones" },
    }},
    { title = "AoE", steps = {
        { spellID = 197835, text = "Shuriken Storm as the primary AoE combo point builder once 2+ targets are up" },
        { spellID = 280719, text = "Secret Technique on cooldown — its shadow clones hit everything near your target" },
        { spellID = 319175, text = "Black Powder as the AoE spender (Deathstalker from 2 targets, Trickster from 3)" },
        { spellID = 185313, text = "Shadow Dance on cooldown for extra Shadowstrike/Black Powder access" },
        { text = "Prioritize Black Powder over Eviscerate once enough targets are engaged" },
    }},
    { title = "Opener Notes", steps = {
        { text = "Open from Stealth with Shadowstrike, then chain into Shadow Dance" },
        { text = "Save a second Shadow Dance charge if possible to extend your opening burst window" },
        { text = "Shadow Blades lines up with Shadow Dance roughly every 90 seconds — aim to fit two Shadow Dance windows inside each Shadow Blades rather than using them independently" },
        { text = "Your hero talent choice colors the finisher priority — Deathstalker weaves its mark debuff into the builder/finisher cycle, while Trickster stacks its own resource on top of combo points — but the core Shadow Dance cadence stays the same either way" },
    }},
  },
  cooldowns = {
    { spellID = 121471, text = "Shadow Blades — burst cooldown on roughly a 90-second timer; try to land two Shadow Dance windows inside it rather than spending it independently" },
    { spellID = 185313, text = "Shadow Dance — core repeatable burst window, use on cooldown" },
    { spellID = 280719, text = "Secret Technique — 25-second finisher cooldown; aim to have it ready inside every Shadow Dance" },
    { spellID = 426591, text = "Goremaw's Bite (talent) — 45-second cooldown, press it inside Shadow Dance" },
    { spellID = 31224, text = "Cloak of Shadows — major magic defensive, clears many magic effects" },
    { spellID = 5277, text = "Evasion — physical defensive cooldown" },
    { spellID = 1856, text = "Vanish — reopen Shadowstrike from stealth or reposition" },
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
    { slot = "Head", text = "Tier set piece — the set bonus usually matters more than a small item-level gap. Season 2's four-piece specifically extends Shadow Blades and boosts its Shadow damage." },
    { slot = "Neck", text = "Favor Haste for faster combo point generation and better Shadow Dance uptime" },
    { slot = "Back", text = "Secondary stats matching Haste and Crit outweigh a pure item-level chase" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece leaning Haste and Crit" },
    { slot = "Ring", text = "Haste or Crit rings depending on your current stat weights" },
    { slot = "Trinket", text = "One on-use Agility or damage trinket lined up with Shadow Dance or Shadow Blades windows" },
    { slot = "Trinket", text = "A passive stat-stick trinket for consistent damage between burst windows" },
    { slot = "Weapon", text = "Two matched, high item level daggers, since Subtlety's damage scales off both weapons" },
  },
  mplusLoadout = {
    string = "CUQAAAAAAAAAAAAAAAAAAAAAAAgx2MAAAAAwsMGLTMbbjxMDDzMzMzw8AbzYGbbzMzMzMjBjZ2GAAAAGMmFzyADYBsMMhMLYGmZAmxA",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CUQA5HmDzx68KWyrW/8Y781L7Dgx2MAAAAAwsMGLTMbbjxMDjZmZmZGGbzYGbbzMzMzMjBjZ2GAAAAGMmFzyADYBsMMhMLYGmZAmxA",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Subtlety Rogues by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (8/50, 16%); 35/50 (70%) ran Deathstalker overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Keep Shadow Dance on cooldown whenever possible for the strongest burst windows.",
    "Don't waste Shadow Dance charges outside of a real damage window if you can help it.",
    "Black Powder overtakes Eviscerate quickly once a second target is in range.",
    "Vanish can be used offensively to re-enter stealth for another Shadowstrike, not just defensively.",
    "Never sit at 7 combo points without spending — Eviscerate or Black Powder before you cap.",
    "Cash in the Ancient Arts buff with an extra builder when it's about to go to waste rather than losing it entirely.",
  },
})

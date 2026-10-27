local ADDON, ns = ...

-- SpecSage guide data: Mage
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
-- tuning this pass — EXCEPT Arcane (62), Fire (63), and Frost (64),
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
-- Frost's overview/rotation were also corrected this pass: they described
-- Brain Freeze's Flurry applying "Winter's Chill" for an immediate shatter.
-- SimC's current `midnight` branch profile shows no `winters_chill`
-- reference at all - Frostbolt, Flurry and Glacial Spike now build a
-- stacking `Freezing` debuff (debuff.freezing.stack, which Ice Lance spends
-- from about 6 stacks under Spellslinger and 12 under Frostfire per the
-- 12.1.5 APL), a genuinely different shape (accumulate-then-spend, not a
-- single proc).
-- Arcane and Fire were also corrected this pass, confirmed against SimC's
-- current `midnight` branch profiles: Nether Tempest has zero references
-- in either Arcane profile (removed from the tree) so Arcane's AoE step
-- now names Arcane Orb alone; Phoenix Flames has zero references in either
-- Fire profile (removed from Fire's kit) so every mention was dropped,
-- leaving Fire Blast as the sole instant Heating Up/Hot Streak generator.
-- Later pass (2026-09-01): as of this date guide sites (Wowhead, Icy
-- Veins, Maxroll, Method, Boostmatch) are a permitted source for rotation
-- logic, hero-talent recommendations, and stat priorities. Arcane and
-- Fire's overview/rotation/cooldowns/tips were rewritten this pass with
-- real opener sequences, single-target/AoE priority splits, and
-- hero-talent-caused differences pulled from those sites, cross-checked
-- against current spell data for the spell IDs added. Both specs'
-- corrected mechanics from the prior pass (no Nether Tempest, no Phoenix
-- Flames) were independently confirmed by the same sites and were not
-- reintroduced. Frost was left untouched this pass beyond what the prior
-- pass already fixed. statPriority fields were left untouched throughout,
-- since the sources didn't give a confident order beyond what was
-- already there.
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

-- Arcane -----------------------------------------------------------------
ns.GuideStore:RegisterSpec("MAGE", 62, {
  specName = "Arcane",
  role = "DAMAGER",
  overview = {
    "Arcane Mage is a burst-window spec built around managing the Arcane Charges resource and the mana tied to it. You alternate between a mana-conserving 'Arcane Blast/Barrage' setup phase and short, extremely high-damage burn windows fueled by Arcane Surge and trinkets/cooldowns.",
    "The core mechanic is Arcane Charges (0-4, built by Arcane Blast, Arcane Orb, Arcane Pulse and Touch of the Magi): each charge increases Arcane Blast's damage and mana cost, and Arcane Barrage consumes them all for 90% extra damage per charge. Clearcasting procs (Arcane Surge always grants one) make Arcane Missiles free, and every wave of Missiles adds a stack of Arcane Salvo, which raises your next Arcane Barrage's damage. Arcane Charges reset to 0 whenever you dump them with Arcane Barrage, and also on entering combat, so there's nothing to gain from building charges before a pull.",
    "Arcane's two hero trees, Sunfury and Spellslinger, both run the same Blast/Missiles/Barrage loop and both bank Arcane Salvo for Barrage, but they spend it differently: Sunfury opens with Arcane Surge on the pull and fires Barrage freely while Arcane Soul is up, while Spellslinger holds Barrage for around 20 Salvo stacks and leans harder on Arcane Orb charges in AoE. Talented Prismatic Bolt occasionally replaces an Arcane Blast after a Barrage; cast it as soon as it appears.",
    "Bring Arcane when you want strong burst damage aligned to boss windows (bloodlust, execute phases, add spawns) and are comfortable with a rotation that rewards careful cooldown and mana planning over simple button-pressing.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "haste" },
    { stat = "mastery" },
    { stat = "crit" },
    { stat = "versatility" },
  },
  rotation = {
    { title = "Opener", steps = {
        { spellID = 55342, text = "Mirror Image a few seconds before the pull" },
        { spellID = 365350, text = "Arcane Surge pre-cast so it lands as the pull starts, with your potion",
          condition = "Sunfury hero talent; Spellslinger casts Arcane Surge in the first few globals instead" },
        { spellID = 30451, text = "Otherwise pre-cast Arcane Blast to land on the pull" },
        { spellID = 153626, text = "Arcane Orb once at the very start to fill Arcane Charges",
          condition = "Spellslinger hero talent" },
        { spellID = 5143, text = "Arcane Missiles on the Clearcasting proc Arcane Surge gives you" },
        { spellID = 44425, text = "Arcane Barrage to dump your charges and Arcane Salvo" },
        { spellID = 321507, text = "Touch of the Magi immediately after that Barrage — it refills all 4 Arcane Charges; stack trinkets and racials inside Arcane Surge plus Touch" },
        { text = "Opener Notes: your rotation splits along the Sunfury and Spellslinger hero trees — both still center on the Blast/Missiles/Barrage loop, just with different Barrage thresholds; re-use Touch of the Magi on its 45-second cooldown (exactly half of Arcane Surge's), each time straight after a Barrage, and don't let that timing drift" },
    }},
    { title = "Single Target", steps = {
        { spellID = 5143, text = "Arcane Missiles on Clearcasting procs while Arcane Salvo is below 12 stacks — use them before they expire",
          condition = "Spellslinger hero talent: below 15 Salvo stacks, or any time you're sitting on 3 Clearcasting procs" },
        { spellID = 1295923, text = "Prismatic Bolt whenever it replaces your Arcane Blast" },
        { spellID = 44425, text = "Arcane Barrage at 4 Arcane Charges with 12+ Arcane Salvo and a Clearcasting proc, at 25 Salvo, or any time Arcane Soul is up",
          condition = "Sunfury hero talent; Spellslinger instead fires it at about 20 Salvo stacks" },
        { spellID = 153626, text = "Arcane Orb when you're below 3 Arcane Charges" },
        { spellID = 1241462, text = "Arcane Pulse at 0 Arcane Charges",
          condition = "Spellslinger hero talent: below 3 charges, outside Arcane Surge" },
        { spellID = 205025, text = "Presence of Mind right after a Barrage at 0 charges when Orb, Pulse and Touch of the Magi are all on cooldown — your next two Arcane Blasts are instant" },
        { spellID = 12051, text = "Evocation below 10% mana, outside Arcane Surge and Touch of the Magi" },
        { spellID = 30451, text = "Arcane Blast as your filler and Arcane Charge builder" },
    }},
    { title = "AoE", steps = {
        { text = "The AoE priority still revolves around Arcane Barrage, much like single target — dump at 4 Arcane Charges" },
        { spellID = 1241462, text = "Arcane Pulse whenever it's up — it generates one Arcane Charge per enemy hit" },
        { spellID = 153626, text = "Arcane Orb whenever it's available — Nether Tempest is gone from the talent tree, so Orb and Pulse are your AoE charge generators",
          condition = "Spellslinger with Orb Mastery: spend Orb charges freely on 2+ targets" },
        { spellID = 1295923, text = "Prismatic Bolt procs hit every nearby enemy — never let one sit" },
        { spellID = 5143, text = "Arcane Missiles on Clearcasting between Barrages" },
        { text = "Line up Arcane Surge and Touch of the Magi with add waves for maximum value" },
    }},
  },
  cooldowns = {
    { spellID = 365350, text = "Arcane Surge — spends all your mana for a big hit, then 15 seconds of +35% spell damage and fast mana regen on a 90-second cooldown; pair it with Touch of the Magi for your 'big burn'" },
    { spellID = 321507, text = "Touch of the Magi (talent) — cast straight after an Arcane Barrage (it grants 4 Arcane Charges), inside Arcane Surge or whenever Surge is more than 30 seconds away; on a 45-second cooldown, exactly half of Arcane Surge's — don't let that timing drift" },
    { spellID = 12051, text = "Evocation — 45-second mana channel; only when you're nearly empty and not inside a burn window" },
    { spellID = 80353, text = "Time Warp — use on pull or per your raid's Bloodlust assignment" },
    { spellID = 45438, text = "Ice Block — defensive, use to survive unavoidable burst damage" },
    { spellID = 55342, text = "Mirror Image — minor defensive/utility cooldown; SimC also casts it before every pull" },
  },
  consumables = {
    { slot = "Flask", items = { 241324, 241322 }, text = "Flask of the Blood Knights for Haste, this spec's top secondary; Flask of the Magisters if your gear already leans hard into Haste and Mastery is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 271887, 241308, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Haste for this spec. If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting)." },
    { slot = "Weapon Enchant", items = { 244029, 243973, 273072 }, text = "Acuity of the Ren'dorei procs +67 primary stat for 15s; Berserker's Rage procs +124 Haste instead and wins if your stat weights put Haste well clear of the rest. Rite of the Hash'ey (12.1: +139 of a random secondary, favouring your highest above 80% health) is the third option." },
    { slot = "Ring Enchants", items = { 243957, 244015 }, text = "Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; Silvermoon's Alacrity (+29 Haste) if your sim says otherwise - the difference is tiny." },
    { slot = "Chest Enchant", items = { 243977 }, text = "Mark of the Worldsoul (+50 primary stat)." },
    { slot = "Leg Enchant", items = { 240133 }, text = "Sunfire Silk Spellthread (+41 Intellect, +115 Stamina)." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240888, 240892, 240967 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Quick Peridot (+17 Haste) in every other socket, or Flawless Masterful Peridot (+16 Haste, +7 Mastery) if you're balancing the two. With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "One of your tier-set slots — the four-piece bonus adds enough burn-window damage that it usually beats a higher item-level non-set piece. Season 2's two-piece specifically fires an extra, harder-hitting Arcane Missile." },
    { slot = "Chest", text = "A big stat budget slot and often your other tier piece — lean into Critical Strike and Mastery here, your top two secondaries" },
    { slot = "Neck", text = "Usually carries a socket — fill it and favor Critical Strike/Mastery rolls over Haste once you're past a comfortable cast-speed breakpoint" },
    { slot = "Ring", text = "Pure secondary-stat real estate with no set bonus attached — take whichever ring pushes Critical Strike and Mastery hardest" },
    { slot = "Trinket", text = "One on-use Intellect or damage trinket you can pop alongside Arcane Surge so its burst lands inside your burn window" },
    { slot = "Trinket", text = "A second, passive trinket that simply adds secondary stats so you're not dead weight between burn windows" },
    { slot = "Weapon", text = "A one-hand weapon and off-hand or a two-hand staff both work — take whichever has the higher weapon damage" },
    { slot = "Off-hand", text = "If you're wielding a one-hander, match its off-hand's secondary stats to the same Critical Strike/Mastery lean" },
  },
  mplusLoadout = {
    string = "C4DAAAAAAAAAAAAAAAAAAAAAAYGGLzMzswMDamZGAAAGAAEwMzMLLzMxCAAwMzMjNLzMzsMjxYmZwCzYmZGAgBAAYmZBAMDAGmZG",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "C4DAche08tHz49KSVf7iKFnyuNzwMLzMzsgZQzMGAAAGAwMz0sssMDAEbAAsBzMDbWmxMLzYMzMzMswMzMzMAADAAwAMzAMAYYmZA",
    source = "Blizzard Battle.net API, US region, 2026-10-27: top 50 current-season Mythic+ Arcane Mages by best keystone level in the second week of patch 12.1.5 (period 1086), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (5/50, 10%); 50/50 (100%) ran Sunfury overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Track your mana closely — running out mid-burn wastes the window; running out too early forces a weak conserve phase.",
    "Arcane Charges cap at 4 and reset to 0 the moment you enter combat (and again whenever Arcane Barrage fires) — there's no benefit to hard-casting Arcane Blast before the pull, since it won't carry a charge into combat.",
    "Never let a Clearcasting proc expire unused — it's free damage.",
    "Keep Touch of the Magi on its own ~45-second rhythm (half of Arcane Surge's cooldown) even between burn windows — delaying it desyncs your whole cooldown plan.",
    "Plan burn windows around raid cooldowns and boss vulnerability phases rather than using them purely on cooldown.",
  },
})

-- Fire ---------------------------------------------------------------------
ns.GuideStore:RegisterSpec("MAGE", 63, {
  specName = "Fire",
  role = "DAMAGER",
  overview = {
    "Fire Mage is a crit-and-execute spec centered on stacking Heating Up and Hot Streak procs to fire off instant, guaranteed-crit Pyroblasts. Damage is spiky, with big cooldown-aligned burst windows via Combustion — roughly a 2-minute cooldown that becomes your entire burst plan, stacked with trinkets, potions, and racials rather than spread out.",
    "The core loop is: Fire Blast and Fireball/Scorch build Heating Up, two crits in a row (or a Fire Blast consuming Heating Up) grant Hot Streak, and Hot Streak is spent on a free, instant Pyroblast. Fire Blast is a guaranteed crit, which makes it your most reliable way to force that conversion when RNG isn't cooperating. Ignite (a damage-over-time spread from crits) rewards keeping crit up and hitting multiple targets.",
    "Fire's two hero trees change less about the core loop than Devastation's or Augmentation's do for their classes: Frostfire simply swaps your filler spell to Frostfire Bolt in place of Fireball, while Sunfury builds Spellfire Spheres and Arcane Phoenix stacks for extra haste and Fire Blast charges — the Heating Up/Hot Streak/Combustion loop above is identical either way.",
    "Bring Fire when you want a spec that shines in short, well-timed burst windows and cleave/AoE fights, and you're willing to manage Fire Blast charges tightly around Combustion.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "haste" },
    { stat = "mastery" },
    { stat = "versatility" },
    { stat = "crit" },
  },
  rotation = {
    { title = "Opener", steps = {
        { spellID = 55342, text = "Mirror Image a few seconds before the pull" },
        { spellID = 11366, text = "Hardcast Pyroblast so it lands as the pull starts" },
        { spellID = 153561, text = "Meteor right before Combustion so it lands inside the window",
          condition = "Sunfury with Sunfury Execution; Frostfire with Burnout casts Meteor in the last few seconds of Combustion instead" },
        { spellID = 190319, text = "Combustion at the very end of a Fireball, Scorch or Pyroblast cast — it's off the global cooldown and castable while casting. Potion, trinkets and racials go with it",
          condition = "Firestarter talent: hold Combustion until the boss drops below 90% health (SimC models about 18 seconds)" },
        { spellID = 108853, text = "Fire Blast into Pyroblast, repeated through the rest of the Combustion window" },
        { text = "Opener Notes: Fire splits along the Frostfire and Sunfury hero trees — Frostfire swaps your filler to Frostfire Bolt in place of Fireball and otherwise plays the same, while Sunfury builds Spellfire Spheres and Arcane Phoenix stacks for extra haste and Fire Blast charges; the Heating Up/Hot Streak loop below holds either way" },
    }},
    { title = "Single Target", steps = {
        { spellID = 153561, text = "Meteor on cooldown",
          condition = "Frostfire, or Sunfury with Blast Zone; otherwise save it for Combustion" },
        { spellID = 11366, text = "Pyroblast whenever Hot Streak is active",
          condition = "Frostfire hero talent: hold it if Combustion is less than 5 seconds away" },
        { spellID = 11366, text = "Hardcast Pyroblast on a Pyroclasm proc, even outside Hot Streak — at 2 stacks right away, otherwise hold one for Combustion if it's within 12 seconds" },
        { spellID = 2948, text = "Scorch on a Heat Shimmer proc, in execute below 30% health (with Scald), or whenever you're moving" },
        { spellID = 133, text = "Fireball (or Frostfire Bolt, if you're playing the Frostfire hero talent) as your default filler to build Heating Up" },
        { spellID = 108853, text = "Fire Blast while casting Fireball or Pyroblast to turn Heating Up into Hot Streak — and spend one before you reach full charges. Phoenix Flames was removed from Fire's kit in Midnight, so Fire Blast alone now carries this load" },
    }},
    { title = "AoE", steps = {
        { text = "Under 3 targets, just run the single-target priority above" },
        { spellID = 2120, text = "At 3+ targets, spend Hot Streak and Pyroclasm procs on Flamestrike instead of Pyroblast",
          condition = "Needs the Fuel the Fire talent; without it, stay on Pyroblast" },
        { spellID = 108853, text = "Fire Blast to generate Hot Streak procs quickly" },
        { text = "Let Ignite spread damage across the pack rather than single-target dumping" },
        { text = "Time Combustion and Meteor for when the full pack is engaged" },
        { spellID = 31661, text = "Dragon's Breath is a short-range cone disorient — utility for dangerous casters, not part of the damage priority" },
    }},
  },
  cooldowns = {
    { spellID = 190319, text = "Combustion — 10 seconds of +100% spell crit on a 2-minute cooldown, castable mid-cast; stack every trinket, potion, and racial you have into it rather than spreading them out" },
    { spellID = 153561, text = "Meteor — 45-second cooldown; time it to land inside Combustion" },
    { spellID = 108853, text = "Fire Blast — instant proc conversion, weave throughout and especially during Combustion" },
    { spellID = 45438, text = "Ice Block — defensive, negates incoming damage entirely" },
    { spellID = 80353, text = "Time Warp/Bloodlust — raid utility cooldown, coordinate with your raid's lust plan" },
  },
  consumables = {
    { slot = "Flask", items = { 241324, 241322 }, text = "Flask of the Blood Knights for Haste, this spec's top secondary; Flask of the Magisters if your gear already leans hard into Haste and Mastery is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 271887, 241308, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Haste for this spec. If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting)." },
    { slot = "Weapon Enchant", items = { 244029, 243973, 273072 }, text = "Acuity of the Ren'dorei procs +67 primary stat for 15s; Berserker's Rage procs +124 Haste instead and wins if your stat weights put Haste well clear of the rest. Rite of the Hash'ey (12.1: +139 of a random secondary, favouring your highest above 80% health) is the third option." },
    { slot = "Ring Enchants", items = { 243957, 244015 }, text = "Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; Silvermoon's Alacrity (+29 Haste) if your sim says otherwise - the difference is tiny." },
    { slot = "Chest Enchant", items = { 243977 }, text = "Mark of the Worldsoul (+50 primary stat)." },
    { slot = "Leg Enchant", items = { 240133 }, text = "Sunfire Silk Spellthread (+41 Intellect, +115 Stamina)." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240888, 240892, 240967 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Quick Peridot (+17 Haste) in every other socket, or Flawless Masterful Peridot (+16 Haste, +7 Mastery) if you're balancing the two. With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "One of your tier-set slots — the four-piece bonus meaningfully boosts your Hot Streak/Combustion damage, so favor the set piece over a small item-level edge elsewhere. Season 2's set bonus is centered on Pyroclasm." },
    { slot = "Chest", text = "A large stat budget and often your second tier piece — push Critical Strike here first since crits are the entire engine of this spec" },
    { slot = "Neck", text = "Usually has a socket — prioritize Critical Strike, with Mastery as your next fill for Ignite scaling" },
    { slot = "Ring", text = "No set bonus tying you down, so chase Critical Strike hard on both rings before rounding out Mastery" },
    { slot = "Trinket", text = "One on-use trinket timed to pop with Combustion for maximum burst overlap" },
    { slot = "Trinket", text = "A second trinket with a strong passive Intellect or Critical Strike stat stick to carry outside cooldown windows" },
    { slot = "Weapon", text = "Staff or one-hand-plus-off-hand both work fine — weapon damage and item level matter far more than the weapon type" },
    { slot = "Off-hand", text = "Match a one-hander's off-hand to your Critical Strike lean rather than treating it as an afterthought slot" },
  },
  mplusLoadout = {
    string = "C8DAAAAAAAAAAAAAAAAAAAAAAYGGLzMzswMzIzMGAAAGAwMz0sstMDAwmZmx2MzMzYBAAAAALmZmZAAgZMmZmZMzsMAMzQGjBMDjB",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "C8DAche08tHz49KSVf7iKFnyuNzwMLzMmFMzgZmZGAAADAYmZMLbLzAAsZmZsNzMzM2AAAAAwiZmZGAAYGjZmZGzMbDAzMAzMgZYMA",
    source = "Blizzard Battle.net API, US region, 2026-10-27: top 41 current-season Mythic+ Fire Mages by best keystone level in the second week of patch 12.1.5 (period 1086), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick, tied with 1 other build (2/41, 5% each); 38/41 (93%) ran Sunfury overall.",
    patch = "12.1.5",
    sampleSize = 41,
  },
  tips = {
    "Spend any Hot Streak before your Combustion pre-cast, then press Combustion as that cast finishes so the first Hot Streak of the window comes from Combustion's guaranteed crits.",
    "Never overcap Fire Blast charges — that's wasted proc generation.",
    "Use Scorch while moving to keep building toward Heating Up instead of standing still doing nothing.",
    "Watch Ignite uptime on multi-target fights; spreading it well is a large chunk of your AoE damage.",
    "Fire Blast is a guaranteed crit, so lean on it to force Heating Up into Hot Streak when you need the conversion and crit RNG isn't cooperating.",
  },
})

-- Frost ----------------------------------------------------------------
ns.GuideStore:RegisterSpec("MAGE", 64, {
  specName = "Frost",
  role = "DAMAGER",
  overview = {
    "Frost Mage builds a stacking Freezing debuff on its target and then shatters it. Frostbolt, Flurry, Glacial Spike and Ray of Frost all apply Freezing (up to 20 stacks); each Ice Lance shatters 4 of those stacks for bonus Frost damage. Icy Veins is no longer part of Frost's kit in Midnight: your burst comes from Frozen Orb, Ray of Frost (which turns into Comet Storm once talented) and your Water Elemental.",
    "Two procs drive the loop. Fingers of Frost (from Frostbolt, up to 2 charges) makes your next Ice Lance deal 4 stacks' worth of Shatter damage without spending any Freezing. Brain Freeze resets Flurry's cooldown and empowers it, and with Thermal Void your next Ice Lance shatters 4 extra stacks. Frostbolt also banks Icicles; at 5, Glacial Spike is ready.",
    "Frost's hero trees are Spellslinger and Frostfire. Frostfire swaps Frostbolt for Frostfire Bolt and lets Freezing build higher (about 12 stacks) before a plain Ice Lance; Spellslinger spends from about 6 stacks.",
    "Bring Frost when you want a spec with strong burst windows, good cleave via Frozen Orb, Comet Storm and Blizzard, and reliable ranged utility (roots/slows) for mechanics-heavy fights.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "mastery" },
    { stat = "crit" },
    { stat = "haste" },
    { stat = "versatility" },
  },
  rotation = {
    { title = "Opener", steps = {
        { spellID = 31687, text = "Summon Water Elemental before the pull (re-summon it whenever it dies)" },
        { spellID = 116, text = "Pre-cast Frostbolt (Frostfire Bolt under Frostfire) so it lands as the pull starts" },
        { spellID = 44614, text = "Flurry straight away to start Freezing stacking",
          condition = "Wintertide talent only" },
        { spellID = 84714, text = "Frozen Orb, with potion, trinkets and racials right behind it" },
        { spellID = 205021, text = "Ray of Frost to pile on 8 Freezing stacks",
          condition = "Frostfire hero talent: open with Ray of Frost first, before Flurry and Frozen Orb" },
        { text = "Opener Notes: Frost splits along the Frostfire and Spellslinger hero trees — Frostfire replaces Frostbolt with Frostfire Bolt and spends Freezing at higher stacks, Spellslinger keeps the loop closer to the description above. Icy Veins no longer exists for Frost, so Frozen Orb and Ray of Frost are what you line your trinkets up with" },
    }},
    { title = "Single Target", steps = {
        { spellID = 1247777, text = "Comet Storm whenever Ray of Frost has turned into it",
          condition = "Frostfire hero talent: on 1-2 targets, or right after a Glacial Spike" },
        { spellID = 44614, text = "Flurry on a Brain Freeze proc (unless Thermal Void is already waiting on your next Ice Lance)" },
        { spellID = 30455, text = "Ice Lance at 2 Fingers of Frost charges, so the next proc isn't wasted" },
        { spellID = 84714, text = "Frozen Orb on cooldown" },
        { spellID = 199786, text = "Glacial Spike as soon as 5 Icicles make it ready",
          condition = "Frostfire hero talent: this moves to the top of the list" },
        { spellID = 30455, text = "Ice Lance on any Fingers of Frost charge, or once the target has 6+ Freezing stacks",
          condition = "Frostfire hero talent: wait for 12+ Freezing stacks instead (Fingers of Frost lances only with Thermal Void up)" },
        { spellID = 205021, text = "Ray of Frost when you're at 3 or fewer Icicles" },
        { spellID = 44614, text = "Flurry whenever a charge is available, even without Brain Freeze" },
        { spellID = 116, text = "Frostbolt (Frostfire Bolt under Frostfire) as your filler, Icicle builder and Freezing source" },
    }},
    { title = "AoE", steps = {
        { spellID = 84714, text = "Frozen Orb to generate procs and cleave damage" },
        { spellID = 1247777, text = "Comet Storm on cooldown — every comet shatters a Freezing stack" },
        { spellID = 190356, text = "Blizzard at 5+ targets while Freezing Rain is up, otherwise at about 7+ (fewer with Freezing Winds/Freezing Rain talented)" },
        { spellID = 157997, text = "Ice Nova and Cone of Cold at 4+ targets with the Cone of Frost talent (5+ under Frostfire)" },
        { spellID = 30455, text = "Ice Lance to shatter Freezing and spend Fingers of Frost across the pack" },
        { spellID = 205021, text = "Ray of Frost at 3+ targets" },
    }},
  },
  cooldowns = {
    { spellID = 84714, text = "Frozen Orb — 1-minute proc generation and cleave; your trinkets, potion and racials go right after it" },
    { spellID = 205021, text = "Ray of Frost (talent) — 1-minute channel that applies 8 Freezing stacks; with Comet Storm talented, casting it turns your next Ray of Frost into Comet Storm" },
    { spellID = 31687, text = "Summon Water Elemental (talent) — your pet; keep it out, re-summon after a death" },
    { spellID = 45438, text = "Ice Block — defensive, negates incoming damage entirely" },
    { spellID = 80353, text = "Time Warp/Bloodlust — raid utility cooldown, coordinate with your raid's lust plan" },
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
    { slot = "Head", text = "One of your tier-set slots — the four-piece bonus is worth prioritizing since it strengthens your Fingers of Frost/Brain Freeze proc engine. Season 2's set bonus specifically: Shattering a Freezing stack has a chance to generate a bonus Icicle and boosts Glacial Spike, with the four-piece letting Glacial Spike rapidly refill your Icicle stack." },
    { slot = "Chest", text = "A big stat budget and often your other tier piece — split it between Critical Strike (for shatter payoff) and Mastery (for Icicle damage)" },
    { slot = "Neck", text = "Usually carries a socket — fill it and lean Critical Strike/Mastery over Haste past your casting comfort point" },
    { slot = "Ring", text = "No set bonus attached, so use rings to fill whichever of Critical Strike or Mastery your gear is currently light on" },
    { slot = "Trinket", text = "One on-use trinket timed to pop right after Frozen Orb for a stacked burst window" },
    { slot = "Trinket", text = "A passive secondary-stat trinket to keep your damage strong between Frozen Orb and Ray of Frost windows" },
    { slot = "Weapon", text = "Staff or one-hand-plus-off-hand both work — prioritize the higher weapon damage/item level over the type" },
    { slot = "Off-hand", text = "If dual-wielding a caster off-hand, favor one that reinforces your Critical Strike/Mastery split" },
  },
  mplusLoadout = {
    string = "CAEAAAAAAAAAAAAAAAAAAAAAAYGGLzMzsMmZmYmZGjZMziZmZmZMDEAAYmZmllZm2AAAAAAgNA2WGzMzAbzYmZYBAAgZ2AmBGwADD",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CAEAche08tHz49KSVf7iKFnyuNzwYZmZmFMzEzMmZmZmZWMzMzMzMzsMTzMbzCAAAaBAAWAAAAAYbZMzMDmtZMzM2WAAAAzMYGGDYAMA",
    source = "Blizzard Battle.net API, US region, 2026-10-27: top 50 current-season Mythic+ Frost Mages by best keystone level in the second week of patch 12.1.5 (period 1086), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick, tied with 1 other build (2/50, 4% each); 25/50 (50%) each ran Spellslinger and Frostfire.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Shatter is now about the Freezing debuff, not roots: build stacks with Frostbolt and Flurry, then let Ice Lance shatter them 4 at a time.",
    "Don't sit on Glacial Spike once 5 Icicles have readied it — further Icicles are wasted generation.",
    "Never hold 2 Fingers of Frost charges — a third proc is lost, so Ice Lance as soon as you're capped.",
    "Use your root/slow kit (Frost Nova, Ice Nova, Cone of Cold) proactively for movement-heavy mechanics, not just for damage.",
  },
})

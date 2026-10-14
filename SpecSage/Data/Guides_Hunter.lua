local ADDON, ns = ...

-- SpecSage guide data: Hunter (Beast Mastery 253, Marksmanship 254, Survival 255)
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
-- tuning this pass — EXCEPT Beast Mastery (253), Marksmanship (254), and Survival (255),
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
-- Survival's overview/rotation/tips were also corrected this pass: they
-- described the old Mongoose Bite stacking mechanic and a separate
-- Coordinated Assault cooldown, both gone (Mongoose Fury survives only as a
-- passive talent that ramps Raptor Strike, per the 12.1.5 talent data). SimC's current
-- `midnight` branch profile has zero references to either (mongoose_bite,
-- coordinated_assault) and is instead built entirely around Tip of the
-- Spear stacks spent on a new Takedown finisher; a Blizzard developer post
-- on the official forums states Takedown "combines aspects of both
-- Coordinated Assault and Flanking Strike."
-- Later pass (2026-09-01): as of this date guide sites (Wowhead, Icy
-- Veins, Maxroll, Method, Boostmatch) are a permitted source for rotation
-- logic, hero-talent recommendations, and stat priorities. All three
-- specs' overview/rotation/cooldowns/tips were rewritten this pass with
-- real opener sequences, single-target/AoE priority splits, and
-- hero-talent-caused differences pulled from those sites, cross-checked
-- against current spell data for the spell IDs added. Survival's AoE
-- section also got a real fix here: it still named Butchery as the AoE
-- tool, but Butchery was removed in Midnight and replaced by Raptor
-- Swipe (every second Raptor Strike auto-converts to hit multiple
-- enemies) - confirmed via direct lookup, not just the compendium.
-- statPriority fields were left untouched throughout, since the sources
-- didn't give a confident order beyond what was already there.
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

ns.GuideStore:RegisterSpec("HUNTER", 253, {
  specName = "Beast Mastery",
  role = "DAMAGER",
  overview = {
    "Beast Mastery Hunter is a pet-focused ranged spec where a large share of the damage comes from your permanent pet, buffed heavily by Bestial Wrath and Kill Command. It plays as a mobile, simple-to-execute spec that stays fully effective while moving, since most casts are instant.",
    "The core resource is Focus, regenerated passively and by Barbed Shot's bleed, and spent on Kill Command, Cobra Shot and Wild Thrash. Barbed Shot is a two-charge bleed that also refunds Focus, and Cobra Shot shortens Kill Command's cooldown, so the two keep Kill Command cycling. The defining mechanic is Nature's Ally: Barbed Shot, Cobra Shot and Black Arrow each empower your next Kill Command, so the rotation is built around weaving one of them between Kill Commands rather than ever casting two in a row. (Frenzy is now a flat pet attack-speed talent; Barbed Shot no longer builds stacks you have to maintain.)",
    "Beast Mastery's two hero trees are Pack Leader and Dark Ranger. Pack Leader turns your next Kill Command every 30 seconds into a beast summon via Howl of the Pack Leader; Dark Ranger adds Black Arrow, empowered by the Withering Fire window Bestial Wrath opens, and (with Wailing Dead) turns Bestial Wrath into Wailing Arrow for 15 seconds after you press it. Both still run the same Kill Command/Barbed Shot/Cobra Shot core described above.",
    "Beast Mastery is a strong pick for fights requiring constant movement, cleave-light single target, and simple resource management, making it a common choice for Mythic+ and progression pulls with heavy mechanics.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "mastery" },
    { stat = "crit" },
    { stat = "haste" },
    { stat = "versatility" },
  },
  rotation = {
    { title = "Single Target", steps = {
        { spellID = 217200, text = "Barbed Shot when Bestial Wrath is about to come off cooldown, or when you're about to cap 2 charges — Scent of Blood hands you a fresh charge when Bestial Wrath goes out" },
        { spellID = 19574, text = "Bestial Wrath on cooldown" },
        { spellID = 466930, text = "Black Arrow while Withering Fire is up", condition = "Dark Ranger hero talent only" },
        { spellID = 34026, text = "Kill Command with Nature's Ally active, or straight away when Howl of the Pack Leader's beast is ready to summon" },
        { spellID = 392060, text = "Wailing Arrow (Bestial Wrath turns into it for 15 seconds) before Withering Fire runs out", condition = "Dark Ranger hero talent only" },
        { spellID = 193455, text = "Cobra Shot once Cobra Fang is at full stacks (Season 2 four-piece)" },
        { spellID = 217200, text = "Barbed Shot once you're below 75 Focus or about to cap charges" },
        { spellID = 193455, text = "Cobra Shot as filler — each one also takes a second off Kill Command" },
        { text = "Never fire two Kill Commands back-to-back on a single target — always weave a Barbed Shot, Cobra Shot or Black Arrow between them so Nature's Ally is up for the next one" },
    }},
    { title = "AoE", steps = {
        { spellID = 1264359, text = "Wild Thrash right after Bestial Wrath, or whenever Beast Cleave has dropped, once 2+ targets are up — it switches on Beast Cleave for 10 seconds" },
        { spellID = 19574, text = "Bestial Wrath while Beast Cleave is up and Wild Thrash is about to come back" },
        { spellID = 217200, text = "Barbed Shot before it caps charges, spread across targets" },
        { spellID = 34026, text = "Kill Command with Nature's Ally active while Beast Cleave is running" },
        { spellID = 466930, text = "Black Arrow during Withering Fire, then on cooldown", condition = "Dark Ranger hero talent only" },
        { spellID = 193455, text = "Cobra Shot as the Focus dump when everything else is down" },
        { text = "Keep pet uptime on the highest-priority target while cleaving" },
    }},
    { title = "Opener Notes", steps = {
        { spellID = 257284, text = "Hunter's Mark and Misdirection pre-pull, then dump any banked Barbed Shot charges before combat starts" },
        { text = "Trinkets, racials, and your potion together, then Bestial Wrath to open the burst window" },
        { spellID = 34026, text = "Kill Command, then Cobra Shot to round out the opener" },
        { text = "Pack Leader and Dark Ranger add different flavor here — Pack Leader fires Kill Command straight away whenever Howl of the Pack Leader's beast is ready, Dark Ranger works Black Arrow and Wailing Arrow into Withering Fire — but the Barbed Shot/Bestial Wrath/Kill Command opener above holds for both" },
    }},
  },
  cooldowns = {
    { spellID = 19574, text = "Bestial Wrath — core offensive cooldown (20% damage for you and your pet for 15 seconds); dump your Barbed Shot charges right before pressing it rather than banking them through the window, and line up trinkets, racials and Power Infusion with it" },
    { spellID = 186265, text = "Aspect of the Turtle — major defensive, absorbs most damage briefly" },
    { spellID = 109304, text = "Exhilaration — self-healing cooldown for sustain checks" },
    { spellID = 5384, text = "Feign Death — drop threat/aggro or avoid certain mechanics" },
  },
  consumables = {
    { slot = "Flask", items = { 241322, 241326 }, text = "Flask of the Magisters for Mastery, this spec's top secondary; Flask of the Shattered Sun if your gear already leans hard into Mastery and Critical Strike is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 271887, 241308, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Mastery for this spec. If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 237371, 237369 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from Blacksmithing, if the oil is scarce." },
    { slot = "Weapon Enchant", items = { 273072, 244029, 244031 }, text = "Rite of the Hash'ey (12.1) procs +139 of a random secondary for 15s, and favours your highest one while you're above 80% health - the guides' pick for most physical specs, on both weapons if you dual-wield. Acuity of the Ren'dorei (+67 primary stat) is close behind; Arcane Mastery (+124 Mastery) if your sim puts Mastery well clear." },
    { slot = "Ring Enchants", items = { 243957, 243959 }, text = "Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; Zul'jin's Mastery (+29 Mastery) if your sim says otherwise - the difference is tiny." },
    { slot = "Chest Enchant", items = { 243977, 243975 }, text = "Mark of the Worldsoul (+50 primary stat); Mark of the Rootwarden (+40 Agility, +15 Speed) trades a little stat for movement." },
    { slot = "Leg Enchant", items = { 244641, 244643 }, text = "Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides split between them." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240896, 240898, 240967 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Masterful Amethyst (+17 Mastery) in every other socket, or Flawless Deadly Amethyst (+16 Mastery, +7 Critical Strike) if you're balancing the two. With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "Tier set piece — the set bonus usually matters more than a small item-level gap. Season 2's set bonus specifically: Barbed Shot makes your pet Stomp an extra time, and the four-piece has that Stomp empower your next Cobra Shot — a bigger boost in AoE, a smaller but still real one on single target." },
    { slot = "Neck", text = "Favor Crit and Mastery, since Mastery boosts pet damage directly for Beast Mastery" },
    { slot = "Back", text = "Secondary stats matching Crit and Mastery outweigh a pure item-level trade" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece leaning Crit and Mastery" },
    { slot = "Ring", text = "Crit or Mastery rings depending on your current stat weights" },
    { slot = "Trinket", text = "One on-use Agility or damage trinket lined up with Bestial Wrath" },
    { slot = "Trinket", text = "A passive stat-stick trinket for consistent pet and Focus-spender damage" },
    { slot = "Weapon", text = "Mostly a stat stick for Hunters — take the highest item level option since it doesn't gate ability damage directly" },
  },
  mplusLoadout = {
    string = "C0PAAAAAAAAAAAAAAAAAAAAAAAMmxwCsAzwwMsBAgZYMzyMDzYmxMMzYMzwMjZMziZmxMmBjpZAAAAAzAAAwYmZAmZjxGMLgtBgBA",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "C0PAD57yiELKEty14ekTDtZEqAMmxwCsAzwQDbAAYGzMzsMzwMzMjZGMzYmhZGzMzYbmZMjZYZoZAAAAAAAAgZMGwMbEwsA2GAA",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Beast Mastery Hunters by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick, tied with 1 other build (4/50, 8% each); 50/50 (100%) ran Pack Leader overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Barbed Shot no longer builds Frenzy stacks on your pet — just don't let its two charges cap, and dump them right before Bestial Wrath.",
    "Line up Bestial Wrath with trinkets and racials for maximum burst.",
    "Feign Death is useful defensively as well as for threat — it can dodge some mechanics entirely.",
    "Avoid capping Focus; Cobra Shot exists specifically to prevent Focus overflow.",
    "Never let Kill Command or Barbed Shot sit at capped charges — both are core damage, not just maintenance.",
    "Keep a Nature's Ally proc up for every Kill Command by weaving a Barbed Shot or Cobra Shot beforehand — don't cast two Kill Commands back to back.",
  },
})

ns.GuideStore:RegisterSpec("HUNTER", 254, {
  specName = "Marksmanship",
  role = "DAMAGER",
  overview = {
    "Marksmanship Hunter is a precision ranged spec built around hard-hitting cast-time shots, most notably Aimed Shot, amplified by Trueshot and Precise Shots procs. It plays with more positioning and casting discipline than the other Hunter specs — Streamline was removed, so Aimed Shot now has a longer, more deliberate cast time and hits harder for it, rewarding careful use of instant-cast windows while moving.",
    "The core resource is Focus, generated from Steady Shot, Rapid Fire and passive regeneration, and spent primarily on Aimed Shot, Arcane Shot and Multi-Shot. The defining mechanic is the Precise Shots buff: every Aimed Shot makes your next Arcane Shot or Multi-Shot hit 50% harder for 60% less Focus (and it boosts Kill Shot too) — spending it before the next Aimed Shot is central to the rotation, and Precise Shots hits can call down Spotter's Mark to empower a later Aimed Shot. Deathblow adds a second layer on top: an Aimed Shot can flag your next Aimed Shot to reset Kill Shot and make it usable at any health, so that cast shouldn't get delayed once the proc is up.",
    "Explosive Shot and Volley are spec talents both hero trees press on cooldown. Sentinel (by far the most played tree) turns Trueshot into Moonlight Chakram for 15 seconds and replaces your Spotting Eagle with a Sentinel Owl; Dark Ranger replaces Kill Shot with Black Arrow, spends Precise Shots on it, and adds Wailing Arrow.",
    "Marksmanship brings strong burst windows under Trueshot, good execute-phase damage, and solid ranged utility (traps, Concussive Shot), making it a good pick for fights that reward burst windows and have some downtime to cast in.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "crit" },
    { stat = "mastery" },
    { stat = "versatility" },
    { stat = "haste" },
  },
  rotation = {
    { title = "Single Target", steps = {
        { spellID = 466932, text = "Black Arrow while Precise Shots is up", condition = "Dark Ranger hero talent only" },
        { spellID = 212431, text = "Explosive Shot on cooldown — hold it while a Lock and Load Aimed Shot is waiting if you run Tactical Reload" },
        { spellID = 260243, text = "Volley on cooldown" },
        { spellID = 288613, text = "Trueshot on cooldown, lined up with trinkets and racials" },
        { spellID = 1264902, text = "Moonlight Chakram (Trueshot turns into it for 15 seconds) — keep its buff rolling", condition = "Sentinel hero talent only" },
        { spellID = 19434, text = "Aimed Shot inside Trueshot when Precise Shots is not up, or whenever it's about to cap charges" },
        { spellID = 257044, text = "Rapid Fire on cooldown" },
        { spellID = 53351, text = "Kill Shot while Precise Shots is up (usable on any target after Deathblow)", condition = "Sentinel hero talent only" },
        { spellID = 392060, text = "Wailing Arrow on cooldown", condition = "Dark Ranger hero talent only" },
        { spellID = 185358, text = "Arcane Shot to spend Precise Shots — never cast two Aimed Shots with a Precise Shots buff still waiting" },
        { spellID = 19434, text = "Aimed Shot — a 2.5-second cast, so treat it as a deliberate cast rather than something to squeeze in while moving" },
        { spellID = 56641, text = "Steady Shot to refill Focus when nothing else is ready" },
    }},
    { title = "AoE", steps = {
        { spellID = 212431, text = "Explosive Shot and Volley on cooldown — Volley also grants Trick Shots while it rains" },
        { spellID = 257620, text = "Multi-Shot to turn on Trick Shots whenever it's down, and to spend Precise Shots" },
        { spellID = 288613, text = "Trueshot on cooldown" },
        { spellID = 19434, text = "Aimed Shot and Rapid Fire while Trick Shots is up, so they cleave" },
        { text = "Moonlight Chakram as Sentinel, or Black Arrow and Wailing Arrow as Dark Ranger, slotted in on cooldown" },
        { spellID = 56641, text = "Steady Shot as Focus filler between cooldowns" },
        { text = "Keep Trick Shots active whenever 3+ targets are engaged" },
    }},
    { title = "Opener Notes", steps = {
        { spellID = 257284, text = "Mark your target with Hunter's Mark before the pull, and pre-cast Aimed Shot" },
        { spellID = 212431, text = "Explosive Shot and Volley, then Trueshot with trinkets and racials" },
        { text = "Sentinel: Moonlight Chakram as soon as Trueshot turns into it, then Aimed Shot/Rapid Fire. Dark Ranger: Black Arrow on Precise Shots, then Rapid Fire and Wailing Arrow" },
    }},
  },
  cooldowns = {
    { spellID = 288613, text = "Trueshot — core offensive cooldown, line it up with trinkets, racials, and every other burst cooldown you have, not just Rapid Fire" },
    { spellID = 257044, text = "Rapid Fire — Focus and damage cooldown, use on cooldown" },
    { spellID = 212431, text = "Explosive Shot — short damage cooldown, use on cooldown in both single target and AoE" },
    { spellID = 260243, text = "Volley — 45-second AoE cooldown that also grants Trick Shots while it lasts" },
    { spellID = 194595, text = "Lock and Load (talent proc) — grants a free instant Aimed Shot, use it immediately rather than banking it" },
    { spellID = 186265, text = "Aspect of the Turtle — major defensive, absorbs most damage briefly" },
    { spellID = 109304, text = "Exhilaration — self-healing cooldown for sustain checks" },
    { spellID = 5384, text = "Feign Death — drop threat/aggro or avoid certain mechanics" },
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
    { slot = "Head", text = "Tier set piece — the set bonus usually outweighs a small item-level gap" },
    { slot = "Neck", text = "Favor Crit and Mastery to match Marksmanship's stat priority" },
    { slot = "Back", text = "Secondary stats matching Crit and Mastery outweigh a pure item-level chase" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece leaning Crit and Mastery" },
    { slot = "Ring", text = "Crit or Haste rings depending on whether burst or cast-time smoothing is your current bottleneck" },
    { slot = "Trinket", text = "One on-use Agility or damage trinket lined up with Trueshot" },
    { slot = "Trinket", text = "A passive stat-stick trinket for consistent Aimed Shot damage" },
    { slot = "Weapon", text = "Mostly a stat stick — take the highest item level option available" },
  },
  mplusLoadout = {
    string = "C4PAAAAAAAAAAAAAAAAAAAAAAwCMwMGzYZAjZwGAAAAAAAAYGzYmFzYmZMDGTzYwYbZmZmZmZmZWYmlBzAAAGzMjBwM22gBYjZ2mxAA",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "C4PAD57yiELKEty14ekTDtZEqwGMwMGNWGQmBbAAAAAAAAgZMzMjtZMzMmhlx0MGMLbbzMzMzMzMzCzsMMDAAgHYMGAmxGYA2YmtZMA",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Marksmanship Hunters by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (10/50, 20%); 48/50 (96%) ran Sentinel overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Don't let Precise Shots procs sit unused — they're a meaningful chunk of your damage.",
    "Line up Trueshot with Rapid Fire and trinkets for the biggest burst windows.",
    "Keep Trick Shots active any time you're facing three or more targets.",
    "Position for uninterrupted casting whenever possible — Aimed Shot is a 2.5-second cast, so a clean cast matters.",
    "Patch 12.1.5 removed Unload; its row now offers Blood Fletching, which makes critical Aimed Shots leave a bleed window on the target.",
    "If you're Focus-starved, Steady Shot exists specifically to refill it — don't stand there with nothing to cast.",
    "Use Lock and Load procs immediately rather than saving them; they don't get better with age.",
  },
})

ns.GuideStore:RegisterSpec("HUNTER", 255, {
  specName = "Survival",
  role = "DAMAGER",
  overview = {
    "Survival Hunter is a melee spec (uniquely among Hunter specs) that combines direct weapon attacks with pet support and DoT-style bleeds. It plays as an aggressive, mobility-heavy melee spec that still keeps a pet as a secondary damage source, blending Kill Command with Raptor Strike and a Takedown-based finisher. You can now dual-wield one-handed weapons instead of a two-hander, and between Aspect of the Eagle and Kill Command/Wildfire Bomb not requiring melee range, a real share of your damage can come from range when a fight demands it — though Raptor Strike and Raptor Swipe still want you in melee.",
    "The core resource is Focus, generated by Kill Command and Takedown, and spent on Raptor Strike, Wildfire Bomb and Boomstick. The defining mechanic is Tip of the Spear: each Kill Command grants a stack (two with Primal Surge), up to 3, and each stack makes your next other ability hit 15% harder. The golden rule of the spec is spending every stack on your highest-priority attack — including Takedown, the leap-in cooldown that replaced Mongoose Bite (and folded in what used to be the separate Coordinated Assault cooldown) in Midnight — rather than letting stacks go to waste. Mongoose Fury survives only as a passive talent that ramps Raptor Strike's damage.",
    "Survival's two hero trees, Sentinel and Pack Leader, each run their own distinct priority list on top of the Tip of the Spear loop above rather than being a pure flavor choice. Sentinel (the more played tree) turns Takedown into Moonlight Chakram for 15 seconds and marks targets for a bigger Wildfire Bomb; Pack Leader times Kill Command around Howl of the Pack Leader's beast summons.",
    "Survival brings strong sustained single-target damage, useful AoE via Wildfire Bomb, and melee utility (Muzzle interrupt, traps), making it a solid pick for fights where melee positioning is viable and you want pet-assisted burst.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "mastery" },
    { stat = "crit" },
    { stat = "haste" },
    { stat = "versatility" },
  },
  rotation = {
    { title = "Single Target", steps = {
        { text = "The core loop is Kill Command, then spend the Tip of the Spear stack it gave you on your best available attack, then repeat — the goal is never letting a stack fall off unused" },
        { spellID = 259489, text = "Kill Command whenever you have no Tip of the Spear stack (Sentinel), or when Howl of the Pack Leader's beast is ready (Pack Leader)" },
        { spellID = 1261193, text = "Boomstick with a Tip of the Spear stack up" },
        { spellID = 259495, text = "Wildfire Bomb with Sentinel's Mark on the target or about to cap; Pack Leader spends it with a Tip of the Spear stack" },
        { spellID = 259489, text = "Kill Command right before Takedown comes off cooldown, so Takedown gets a stack" },
        { spellID = 1250646, text = "Takedown with a Tip of the Spear stack up (with Twin Fangs, press it with none — it grants 3 itself)" },
        { spellID = 1264902, text = "Moonlight Chakram (Takedown turns into it for 15 seconds)", condition = "Sentinel hero talent only" },
        { spellID = 186270, text = "Raptor Strike as the Focus spender once the priorities above are covered" },
        { spellID = 259489, text = "Kill Command again while Takedown is on cooldown, then Wildfire Bomb and Takedown as fillers" },
    }},
    { title = "AoE", steps = {
        { spellID = 259489, text = "Kill Command whenever you're out of Tip of the Spear stacks (or a Pack Leader beast is ready)" },
        { spellID = 1261193, text = "Boomstick with a Tip of the Spear stack — it hits everything in a 20-yard cone" },
        { spellID = 259495, text = "Wildfire Bomb with a Tip of the Spear stack, and before it caps" },
        { spellID = 1250646, text = "Takedown with a stack up, then Moonlight Chakram as Sentinel" },
        { spellID = 186270, text = "Raptor Strike — each one has a 25% chance to upgrade itself into Raptor Swipe, which hits everything in front of you, so just keep pressing it and let it cleave on its own" },
        { text = "Keep Wildfire Bomb's DoT rolling across as many targets as possible" },
    }},
    { title = "Opener Notes", steps = {
        { spellID = 257284, text = "Hunter's Mark before the pull" },
        { spellID = 259495, text = "Wildfire Bomb thrown about a second before combat starts so it lands right as the pull happens" },
        { spellID = 259489, text = "Kill Command to get a Tip of the Spear stack" },
        { spellID = 1250646, text = "Trinkets, racials, and your potion together with Takedown" },
        { text = "Your hero talent choice splits the rotation in two: Pack Leader leans on its pet-summon procs alongside the core builders, while Sentinel runs its own separate priority list — check which one your loadout uses" },
    }},
  },
  cooldowns = {
    { spellID = 1250646, text = "Takedown — core offensive cooldown on a 1:30 baseline (replaced Mongoose Bite and folded in the old Coordinated Assault: you and your pet leap in, gain 20% damage for 8 seconds and 50 Focus), use once a Tip of the Spear stack is up and line up trinkets with it" },
    { spellID = 1261193, text = "Boomstick — 1-minute cooldown that replaced Fury of the Eagle, use it with a Tip of the Spear stack" },
    { spellID = 186289, text = "Aspect of the Eagle — extends your melee abilities' range, useful both for burst windows and for mechanics that push you out of melee" },
    { spellID = 259495, text = "Wildfire Bomb — frequent damage cooldown, weave in on cooldown" },
    { spellID = 186265, text = "Aspect of the Turtle — major defensive, absorbs most damage briefly" },
    { spellID = 109304, text = "Exhilaration — self-healing cooldown for sustain checks" },
    { spellID = 5384, text = "Feign Death — drop threat/aggro or avoid certain mechanics" },
  },
  consumables = {
    { slot = "Flask", items = { 241322, 241326 }, text = "Flask of the Magisters for Mastery, this spec's top secondary; Flask of the Shattered Sun if your gear already leans hard into Mastery and Critical Strike is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 271887, 241308, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Mastery for this spec. If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 237371, 237369 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from Blacksmithing, if the oil is scarce." },
    { slot = "Weapon Enchant", items = { 273072, 244029, 244031 }, text = "Rite of the Hash'ey (12.1) procs +139 of a random secondary for 15s, and favours your highest one while you're above 80% health - the guides' pick for most physical specs, on both weapons if you dual-wield. Acuity of the Ren'dorei (+67 primary stat) is close behind; Arcane Mastery (+124 Mastery) if your sim puts Mastery well clear." },
    { slot = "Ring Enchants", items = { 243957, 243959 }, text = "Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; Zul'jin's Mastery (+29 Mastery) if your sim says otherwise - the difference is tiny." },
    { slot = "Chest Enchant", items = { 243977, 243975 }, text = "Mark of the Worldsoul (+50 primary stat); Mark of the Rootwarden (+40 Agility, +15 Speed) trades a little stat for movement." },
    { slot = "Leg Enchant", items = { 244641, 244643 }, text = "Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides split between them." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240896, 240898, 240967 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Masterful Amethyst (+17 Mastery) in every other socket, or Flawless Deadly Amethyst (+16 Mastery, +7 Critical Strike) if you're balancing the two. With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "Tier set piece — the set bonus usually matters more than a small item-level gap" },
    { slot = "Neck", text = "Favor Haste to speed up Focus generation and Tip of the Spear stacking" },
    { slot = "Back", text = "Secondary stats matching Haste and Crit outweigh a pure item-level chase" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece leaning Haste and Crit" },
    { slot = "Ring", text = "Haste or Crit rings depending on your current stat weights" },
    { slot = "Trinket", text = "One on-use Agility or damage trinket lined up with a Takedown window" },
    { slot = "Trinket", text = "A passive stat-stick trinket for consistent melee and Kill Command damage" },
    { slot = "Weapon", text = "A melee weapon this time, since Survival fights in melee — take the highest item level option with useful secondary stats" },
  },
  mplusLoadout = {
    string = "C8PAAAAAAAAAAAAAAAAAAAAAAMWgBmxoxyAYmgtZMzMGzyAAAAAAwMmxMLmxYGzgx0MAAAADAmxyyMzsYMzMjZmBAzYZDGDjNDAA",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "C8PAD57yiELKEty14ekTDtZEqMWgBmxoxyAYmgtZmZmZGz28AAAAAAAmxMzM2mxYGzwyYaGAAAgBAGLLzMWwMz4BGjBgZsBGjZmNDA",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Survival Hunters by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (4/50, 8%); 44/50 (88%) ran Sentinel overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Have a Tip of the Spear stack up before pressing Takedown — Kill Command right before it if you're out (Twin Fangs builds are the exception, since Takedown grants its own stacks).",
    "Wildfire Bomb has a short cooldown — don't let it sit unused, especially in AoE.",
    "Raptor Swipe procs automatically — each Raptor Strike has a 25% chance to upgrade itself into one — so you don't need a separate AoE button; just keep Raptor Strike in your priority.",
    "Don't let Focus or Wildfire Bomb charges sit capped — both are core damage, not just maintenance.",
    "Muzzle is a strong interrupt — use it proactively on scripted casts rather than saving it indefinitely.",
  },
})

local ADDON, ns = ...

-- SpecSage guide data: Warrior (Arms 71, Fury 72, Protection 73)
-- 12.1.5 pass (2026-10-13): every spec's overview, rotation, cooldowns
-- and tips here were re-checked against SimC's `midnight` branch (client
-- data 12.1.5.70391: action priority lists, talent and spell tables),
-- spell tooltips and the 12.1.5 patch notes, and corrected where they had
-- drifted; every spellID resolves to the ability its step names. Where an
-- older note further down disagrees with a spec block, the block is current.
-- The Arms MID1 note below is historical: every Warrior `mplusLoadout`
-- matches its MID2 profile as of 12.1.5.
-- Content targets Midnight (patch 12.1.5). Specs below with an `mplusLoadout`
-- and/or `raidLoadout` field have that talent string (only) cross-checked
-- against SimulationCraft's public profiles (github.com/simulationcraft/simc,
-- GPLv3, `midnight` branch) as of patch 12.1; specs without one have no such
-- reference.
-- Rotation/overview/tips/gear prose throughout this file is hand-authored
-- and was reviewed for Midnight ability changes, not derived from or
-- checked against SimC's APLs, and was not re-verified against current
-- tuning this pass — EXCEPT Arms, refreshed this pass, and all three specs,
-- which each also gained an `mplusMetaLoadout` this pass:
--   * `mplusLoadout.string` re-pulled from profiles/MID1/MID1_Warrior_Arms.simc's
--     `talents=` line (superseding an earlier, now-stale pull of the same
--     file - SimC's `midnight` branch updates its default profiles via
--     automation), fetched twice to confirm an exact match before use.
--   * The Slayer hero-talent `condition` lines on the Execute rotation step
--     and the Bladestorm cooldown were translated (not pasted) from
--     actions.slayer_execute/actions.slayer_st lines in that same file,
--     same double-fetch confirmation.
--   * NOT added: `raidLoadout`. As of this pass, SimC's `midnight` branch
--     ships exactly one profile per spec here (this same file, referenced
--     by the profiles/MID1_Raid.simc aggregator) - no genuinely separate
--     Mythic+/dungeon-context build to source a second field from. Adding
--     `raidLoadout` anyway, pointed at the same profile under a UI label
--     that implies real raid-vs-M+ differentiation, would misrepresent the
--     data to a player who only sees "Suggested Raid" vs "Suggested
--     Mythic+" in the Tome with no way to see this comment. See
--     DESIGN.md's v1.3 section.
--   * `mplusMetaLoadout` (DESIGN.md's v1.4 section) added for Arms (71),
--     Fury (72), and Protection (73): pulled live from Blizzard's own
--     Battle.net Game Data API (client-credentials OAuth, US region) rather
--     than SimC, on 2026-08-30. Methodology: every current-season Mythic+
--     leaderboard (8-dungeon pool, period 1078; refreshed 2026-10-04 at
-- period 1083, 2026-10-13 at period 1085 (12.1.5's first day) and
-- 2026-10-27 at period 1086, the end of its second week - a
-- field whose `source` carries an older date was kept because the newer
-- sample had no clear most-common build) across all 83 US connected
--     realms was scanned (top 20 groups per realm/dungeon) for each spec's
--     group members; the 50 distinct characters per spec with the highest
--     observed keystone level had their live `specializations` looked up
--     for their active loadout's `talent_loadout_code`. See each field's
--     own `source` comment for the resulting distribution.
-- A later pass (2026-09-01) enriched all three specs' overview/rotation/
-- cooldowns/tips with opener sequences, single-target-vs-AoE priority
-- nuances, cooldown-syncing notes, and hero-talent-caused differences,
-- drawing on guide sites (Wowhead/Icy Veins/Maxroll/Method/Boostmatch),
-- now a permitted source per repo policy (see
-- .claude/skills/specsage-refresh/SKILL.md). All prose was rewritten in
-- SpecSage's own words rather than copied from any source, and every
-- spellID added was verified against Wowhead rather than guessed (Thunder
-- Blast was deliberately left without a spellID - even addon developers
-- have shipped the wrong one for it, per a public Hekili bug report).
-- raidLoadout follow-up (2026-09-02): checked SimC's `midnight` branch
-- fresh - still exactly one profile per spec, no genuinely separate raid
-- build to source a distinct field from (same reasoning as the Arms note
-- above). Enriched Fury's Slayer/Mountain Thane note instead with the
-- source material's raid-vs-M+ framing (informational text, no opaque
-- talent string needed or risked).
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

ns.GuideStore:RegisterSpec("WARRIOR", 71, {
  specName = "Arms",
  role = "DAMAGER",
  overview = {
    "Arms Warrior is a two-handed weapon melee spec built around Mortal Strike as its core rhythm and Colossus Smash (or Sudden Death procs) as its burst windows. It plays as a methodical, cooldown-driven spec: you build and spend rage on a tight priority list, keep Rend rolling, spend Overpower charges, and time your offensive cooldowns to land inside Colossus Smash's damage-amplifying debuff.",
    "The spec's core resource is Rage, generated from auto-attacks and abilities like Overpower, and spent on Mortal Strike, Cleave, and execute-range finishers. Its defining mechanic is the Colossus Smash debuff window — the damage you deal to affected targets is increased by 30% for 10 seconds, so cooldowns and high-value spenders are stacked inside it for burst.",
    "Arms brings strong single-target cleave, self-sufficient defensives (Die by the Sword, Rallying Cry), and solid execute-phase damage, making it a reliable pick for raid progression and Mythic+ alike when you want consistent melee pressure without pet or DoT management.",
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
        { spellID = 100, text = "Charge to open and generate your first Rage" },
        { spellID = 260708, text = "Sweeping Strikes pre-cast if multiple targets are already up" },
        { spellID = 107574, text = "Avatar, then Ravager if talented, right before your first Colossus Smash" },
        { spellID = 167105, text = "Colossus Smash to open your burst window" },
        { spellID = 12294, text = "Mortal Strike inside the Colossus Smash window" },
        { text = "Trinkets, potions, and your other offensive cooldowns alongside this first Colossus Smash" },
    }},
    { title = "Single Target", steps = {
        { spellID = 772, text = "Rend — refresh it when it's about to drop, and top it up before Colossus Smash if it has under 10 seconds left (Cleave applies Rend instead if you have both)" },
        { spellID = 107574, text = "Avatar together with Colossus Smash (or when Colossus Smash is still more than a global away)" },
        { spellID = 228920, text = "Ravager, if talented, just before Colossus Smash so its bleed amplification lands in the window" },
        { spellID = 167105, text = "Colossus Smash on cooldown — open every burst window with it" },
        { spellID = 436358, text = "Demolish inside Colossus Smash while Colossal Might is up",
          condition = "Colossus hero talent only" },
        { spellID = 227847, text = "Bladestorm while Colossus Smash or Avatar is up",
          condition = "Slayer hero talent only" },
        { spellID = 376079, text = "Champion's Spear, if talented, inside your Colossus Smash window" },
        { spellID = 1269383, text = "Heroic Strike whenever a Master of Warfare proc upgrades Slam into it" },
        { spellID = 163201, text = "Execute at 2 Sudden Death stacks; in execute range (below 20% health, 35% with Massacre) it becomes a main spender",
          condition = "Slayer hero talent: in execute range, Execute with Rage above 40 or on a Sudden Death proc" },
        { spellID = 12294, text = "Mortal Strike on cooldown — and early under Colossus while Colossal Might is below 10 stacks" },
        { spellID = 7384, text = "Overpower to spend charges (at 2 Opportunist stacks first under Slayer)" },
        { spellID = 1464, text = "Slam as the Rage-dump filler when everything else is on cooldown" },
    }},
    { title = "AoE", steps = {
        { spellID = 260708, text = "Sweeping Strikes whenever multiple targets are up" },
        { spellID = 845, text = "Cleave first if the pack has no Rend yet — it applies Rend to every target it hits" },
        { spellID = 107574, text = "Avatar, Ravager and Colossus Smash together to open the pull" },
        { spellID = 227847, text = "Bladestorm on cooldown once 3+ targets are up",
          condition = "Slayer hero talent; Colossus uses it as a late filler instead" },
        { spellID = 436358, text = "Demolish once Mortal Strike has built Colossal Might",
          condition = "Colossus hero talent only" },
        { spellID = 845, text = "Cleave as your main Rage dump against multiple targets" },
        { spellID = 7384, text = "Overpower, especially with Dreadnaught, whose shockwave is pure AoE damage" },
        { text = "Fill with Mortal Strike, Execute on Sudden Death procs, and Slam (or Heroic Strike) between cooldowns" },
    }},
    { title = "Opener Notes", steps = {
        { text = "Pool rage before pulling, then open with Colossus Smash into Mortal Strike to front-load burst" },
        { text = "Line up trinkets and offensive cooldowns with the first Colossus Smash window" },
        { text = "Your hero talent choice reshapes the burst window: Colossus leans on Demolish spenders stacked on Colossal Might inside Colossus Smash, while Slayer ties Bladestorm itself to the Colossus Smash/Avatar debuff instead of using it as a separate cleave cooldown" },
    }},
  },
  cooldowns = {
    { spellID = 107574, text = "Avatar — pair with Colossus Smash for maximum burst" },
    { spellID = 167105, text = "Colossus Smash — core damage-amp window, use on cooldown" },
    { spellID = 227847, text = "Bladestorm — strong AoE/cleave cooldown, also usable defensively; under the Slayer hero talent it's pulled into the Colossus Smash burst window instead",
      condition = "Slayer hero talent: use while your Colossus Smash debuff is active" },
    { spellID = 228920, text = "Ravager (talent) — drop it just before Colossus Smash; enemies it hits take 50% more damage from your bleeds" },
    { spellID = 436358, text = "Demolish — Colossus hero talent spender on a 30-second cooldown, cast inside your Colossus Smash window while Colossal Might is up",
      condition = "Colossus hero talent only" },
    { spellID = 118038, text = "Die by the Sword — major defensive, use under heavy melee pressure" },
    { spellID = 97462, text = "Rallying Cry — raid-wide defensive cooldown for group survival checks" },
  },
  consumables = {
    { slot = "Flask", items = { 241326, 241324 }, text = "Flask of the Shattered Sun for Critical Strike, this spec's top secondary; Flask of the Blood Knights if your gear already leans hard into Critical Strike and Haste is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 271887, 241308, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Critical Strike for this spec. If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 237371, 237369 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from Blacksmithing, if the oil is scarce." },
    { slot = "Weapon Enchant", items = { 273072, 244029, 243971 }, text = "Rite of the Hash'ey (12.1) procs +139 of a random secondary for 15s, and favours your highest one while you're above 80% health - the guides' pick for most physical specs, on both weapons if you dual-wield. Acuity of the Ren'dorei (+67 primary stat) is close behind; Jan'alai's Precision (+124 Critical Strike) if your sim puts Critical Strike well clear." },
    { slot = "Ring Enchants", items = { 243957, 243987 }, text = "Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; Nature's Fury (+29 Critical Strike) if your sim says otherwise - the difference is tiny." },
    { slot = "Chest Enchant", items = { 243977 }, text = "Mark of the Worldsoul (+50 primary stat)." },
    { slot = "Leg Enchant", items = { 244641, 244643 }, text = "Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides split between them." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240904, 240906, 240967 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Deadly Garnet (+17 Critical Strike) in every other socket, or Flawless Quick Garnet (+16 Critical Strike, +7 Haste) if you're balancing the two. With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "Tier set piece — the set bonus usually reshapes your Colossus Smash burst more than a small item-level gap does. Season 2's set bonus boosts Mortal Strike/Execute and gives Slam a small cleave, with the four-piece boosting Overpower and having it buff your next Slam, stacking." },
    { slot = "Neck", text = "Favor Crit and Mastery over Haste and Versatility to match Arms' stat priority" },
    { slot = "Back", text = "Treat it like any other armor slot — secondary stat weighting matters more than the base stat total" },
    { slot = "Legs", text = "Another tier slot when available; otherwise the highest item level piece with Crit and Mastery" },
    { slot = "Ring", text = "Crit- or Mastery-heavy rings outweigh ones leaning Haste or Versatility" },
    { slot = "Trinket", text = "One on-use Strength or damage-proc trinket timed to pop alongside Colossus Smash and Avatar" },
    { slot = "Trinket", text = "A second, passive stat-stick trinket for consistent damage between cooldown windows" },
    { slot = "Weapon", text = "The highest item level two-hander available — weapon damage drives a large share of Arms' output" },
  },
  -- Refreshed this pass (see file header): superseded string from an
  -- earlier, now-stale pull of the same file.
  mplusLoadout = {
    string = "CcEAAAAAAAAAAAAAAAAAAAAAAAzMzsMzMmZGAAAghphxYmxyMzMzgxMDAAAAgZWmZAhxyyALgBMDTIzgNwMjtx2ALzsMAzMAYGGA",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CcEASWsDSHNyPDXnbxuIhH3ZdjZmZmFzYmZGAAAghphZGzMbmZmZGmxMDAAAAgxyMDMhxy2ALgBMDTIzgNwMDDDmlZ2GgZGAMDDA",
    source = "Blizzard Battle.net API, US region, 2026-10-27: top 50 current-season Mythic+ Arms Warriors by best keystone level in the second week of patch 12.1.5 (period 1086), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick, tied with 1 other build (6/50, 12% each); 50/50 (100%) ran Slayer overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Never let Rend fall off a target you'll be hitting for more than a few seconds.",
    "Save Overpower charges to spend rather than letting them cap and go to waste.",
    "Line up Colossus Smash, trinkets, and Avatar together whenever possible for maximum burst windows.",
    "Watch your rage bar during downtime — starving Mortal Strike of rage is a common DPS loss; Rage mostly comes from auto-attacks, so avoid melee downtime.",
    "Pre-cast Sweeping Strikes before a pull with multiple targets so it's active the instant you engage.",
  },
})

ns.GuideStore:RegisterSpec("WARRIOR", 72, {
  specName = "Fury",
  role = "DAMAGER",
  overview = {
    "Fury Warrior is a dual-wield melee spec that plays as a fast, rage-flooded brawler. Its core loop is built around Bloodthirst for rage generation and healing, and Raging Blow for spending the Enrage charges it grants, all while Whirlwind and Rampage fill in the gaps of a high-tempo priority rotation.",
    "The core resource is Rage, generated heavily from Bloodthirst and auto-attacks, and spent in large chunks on Rampage — which is both your main Rage sink and your main source of Enrage. The defining mechanic is the Enrage state — several abilities trigger or require it, so keeping yourself enraged as close to permanently as possible is the throughput backbone of the spec.",
    "Fury is a strong pick when you want simple positioning requirements, good sustained AoE from Whirlwind cleave, and consistent single-target damage without needing precise debuff-window timing — a good fit for both raid and Mythic+ content.",
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
        { spellID = 100, text = "Charge to open and generate your first Rage" },
        { spellID = 1719, text = "Recklessness early, so its burst window covers as much of the fight as possible" },
        { spellID = 107574, text = "Avatar alongside Recklessness for your first burst window" },
        { spellID = 23881, text = "Bloodthirst to establish Enrage immediately" },
    }},
    { title = "Single Target", steps = {
        { spellID = 1719, text = "Recklessness and Avatar on cooldown" },
        { spellID = 184367, text = "Rampage whenever Enrage is about to drop or you're at 100+ Rage — refreshing Enrage comes first" },
        { spellID = 227847, text = "Bladestorm during Recklessness",
          condition = "Slayer hero talent" },
        { text = "Thunder Blast at 2 stacks, or before the buff or Avatar runs out",
          condition = "Mountain Thane hero talent" },
        { spellID = 163201, text = "Execute on a Sudden Death proc, and freely during Recklessness" },
        { spellID = 335097, text = "Crushing Blow and Bloodbath — Recklessness turns Raging Blow and Bloodthirst into these (Reckless Abandon); press them while they're up" },
        { spellID = 385059, text = "Odyn's Fury on cooldown, ideally inside Recklessness" },
        { spellID = 85288, text = "Raging Blow to spend charges before they cap (Hack and Slash can refund a charge from Rampage)" },
        { spellID = 23881, text = "Bloodthirst — core Rage and Enrage generator" },
        { spellID = 1680, text = "Whirlwind as the last filler — it generates Rage on its own in 12.1, and Carving Blades boosts it on a single target" },
        { text = "Keep Enrage as close to 100% uptime as possible — it underpins most of Fury's damage" },
    }},
    { title = "AoE", steps = {
        { spellID = 1680, text = "Whirlwind whenever the Improved Whirlwind buff isn't up, so your single-target attacks cleave (Thunder Clap does this job under Mountain Thane)" },
        { spellID = 1719, text = "Recklessness and Avatar on cooldown" },
        { spellID = 184367, text = "Rampage to maintain Enrage while cleaving" },
        { spellID = 227847, text = "Bladestorm during Recklessness",
          condition = "Slayer hero talent" },
        { text = "Thunder Blast and Thunder Clap as your main AoE buttons, especially while Avatar is up",
          condition = "Mountain Thane hero talent" },
        { spellID = 385059, text = "Odyn's Fury on cooldown — it hits everything nearby" },
        { spellID = 163201, text = "Execute on Sudden Death procs" },
        { spellID = 335097, text = "Crushing Blow / Bloodbath during Recklessness, then Raging Blow and Bloodthirst outside it" },
    }},
    { title = "Opener Notes", steps = {
        { text = "Open with Bloodthirst to establish Enrage immediately, then weave Rampage as rage allows" },
        { text = "Save Recklessness for a moment you can chain several Enrage-consuming abilities back to back" },
        { text = "Your hero talent choice matters for burst sequencing: Slayer strings Recklessness into Rampage, Bladestorm, and Execute together, while Mountain Thane instead weaves Bloodthirst and Raging Blow through its own lightning-infused cooldown windows and leans on Thunder Blast for extra AoE. As a starting point, Slayer suits single-target raid bosses better and Mountain Thane suits Mythic+/add-heavy fights better — but check which one your loadout uses before assuming a fixed order, and re-sim if you're unsure" },
    }},
  },
  cooldowns = {
    { spellID = 1719, text = "Recklessness — pop for a burst window, ideally with trinkets" },
    { spellID = 107574, text = "Avatar — pair with Recklessness for the same burst window" },
    { spellID = 227847, text = "Bladestorm — strong cleave/AoE cooldown, also a brief defensive tool; under Slayer it's folded into the main Recklessness burst sequence" },
    { spellID = 385059, text = "Odyn's Fury — hard-hitting burst cooldown, weave into the same window as Recklessness" },
    { spellID = 184364, text = "Enraged Regeneration — self-healing cooldown for sustain checks" },
    { spellID = 23920, text = "Spell Reflection — reflects the next incoming spell, use against dangerous casts" },
    { spellID = 97462, text = "Rallying Cry — raid-wide defensive utility cooldown" },
  },
  consumables = {
    { slot = "Flask", items = { 241324, 241322 }, text = "Flask of the Blood Knights for Haste, this spec's top secondary; Flask of the Magisters if your gear already leans hard into Haste and Mastery is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 271887, 241308, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Haste for this spec. If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 237371, 237369 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from Blacksmithing, if the oil is scarce." },
    { slot = "Weapon Enchant", items = { 273072, 244029, 243973 }, text = "Rite of the Hash'ey (12.1) procs +139 of a random secondary for 15s, and favours your highest one while you're above 80% health - the guides' pick for most physical specs, on both weapons if you dual-wield. Acuity of the Ren'dorei (+67 primary stat) is close behind; Berserker's Rage (+124 Haste) if your sim puts Haste well clear." },
    { slot = "Ring Enchants", items = { 243957, 244015 }, text = "Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; Silvermoon's Alacrity (+29 Haste) if your sim says otherwise - the difference is tiny." },
    { slot = "Chest Enchant", items = { 243977 }, text = "Mark of the Worldsoul (+50 primary stat)." },
    { slot = "Leg Enchant", items = { 244641, 244643 }, text = "Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides split between them." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240888, 240892, 240967 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Quick Peridot (+17 Haste) in every other socket, or Flawless Masterful Peridot (+16 Haste, +7 Mastery) if you're balancing the two. With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "Tier set piece — the set bonus is usually worth more than a small item-level upgrade. Season 2's set bonus boosts Raging Blow and lets it extend Recklessness, with the four-piece boosting Bloodthirst and its crit bonus during Recklessness — check your tooltip for the exact current numbers, they vary by source." },
    { slot = "Neck", text = "Favor Haste to keep the global cooldown fast and Enrage uptime near-permanent" },
    { slot = "Back", text = "Pick up secondary stats matching Haste and Mastery over a raw item-level chase" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece with Haste and Mastery" },
    { slot = "Ring", text = "Haste-leaning rings support Enrage uptime and faster ability weaving" },
    { slot = "Trinket", text = "One on-use Strength or damage trinket lined up with Recklessness" },
    { slot = "Trinket", text = "A passive stat-stick trinket for sustained damage between cooldowns" },
    { slot = "Weapon", text = "Two matched, high item level one-handers — both weapons contribute equally to Fury's damage" },
  },
  mplusLoadout = {
    string = "CgEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgGDzMmZ2MzMzMDjZmZGzMzsMzMmZmZzYmBAAixy2ALgJYGmAzwGwMDjNAAYmhxYYMYM",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CgEASWsDSHNyPDXnbxuIhH3ZdDAAAAAAgGDjxMzmZmZmZmZMzMzMzMzDsMjxMjZzMzMAAQMW2GYBMBzwEYG2AmZYAAAmZYMLDjBjB",
    source = "Blizzard Battle.net API, US region, 2026-10-27: top 50 current-season Mythic+ Fury Warriors by best keystone level in the second week of patch 12.1.5 (period 1086), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (7/50, 14%); 31/50 (62%) ran Slayer overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Try to stay Enraged as close to 100% of the time as possible — it underpins most of Fury's damage.",
    "Don't let Raging Blow charges cap; spend them before they overflow.",
    "Whirlwind generates Rage on its own since 12.1 and, with Carving Blades, hits harder on a single target — it's a real single-target filler again, not just a cleave enabler.",
    "Save Recklessness for windows where you can string several abilities together rather than opening cold.",
    "Rampage is both your best Rage sink and your main Enrage source — spend big chunks of Rage on it rather than trickling Rage away elsewhere.",
    "Open every pull with Charge into an early Recklessness/Avatar so the burst window covers as much of the fight as possible.",
  },
})

ns.GuideStore:RegisterSpec("WARRIOR", 73, {
  specName = "Protection",
  role = "TANK",
  overview = {
    "Protection Warrior is a shield-and-board tank that plays around Shield Block for physical mitigation and Ignore Pain as a damage-smoothing absorb shield. Its offense and defense are tightly linked: Shield Slam (and, under Mountain Thane, Thunder Blast) generates the Rage that is spent both on Revenge and Execute for threat and on Ignore Pain to soak incoming hits.",
    "The core resource is Rage, generated from taking damage and auto-attacking, and the defining mechanic is the interplay between Shield Block (mitigation window) and Ignore Pain (absorb shield) — both compete for the same rage pool, so pacing rage spend between offense, block uptime, and pain absorption is the spec's central skill.",
    "Protection brings strong sustained mitigation, good AoE threat via Thunder Clap and Revenge, and reliable cooldowns for both magic and physical damage spikes, making it a dependable tank for both raid bosses and Mythic+ trash-heavy pulls.",
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
        { spellID = 100, text = "Charge to open and establish threat" },
        { spellID = 23922, text = "Shield Slam as your first Rage-generating attack" },
        { spellID = 6343, text = "Thunder Clap to apply its debuff" },
        { spellID = 6572, text = "Revenge if it's free or already available" },
        { spellID = 2565, text = "Shield Block established as soon as you have the Rage for it" },
    }},
    { title = "Single Target", steps = {
        { spellID = 107574, text = "Avatar, Ravager, Champion's Spear and Shield Charge on cooldown when talented — they're Rage and damage, not just burst" },
        { text = "Thunder Blast whenever it's available",
          condition = "Mountain Thane hero talent" },
        { spellID = 436358, text = "Demolish at 5+ Colossal Might stacks",
          condition = "Colossus hero talent only" },
        { spellID = 23922, text = "Shield Slam on cooldown — top Rage priority, strong threat, and your main Rage generator" },
        { spellID = 6343, text = "Thunder Clap — right after Shield Slam under Colossus whenever Phalanx has dropped, otherwise after a free Revenge" },
        { spellID = 163201, text = "Execute in range — its damage went up 30% in 12.1.5, and Colossus's Practiced Strikes makes it (and Revenge) 10 Rage cheaper" },
        { spellID = 6572, text = "Revenge whenever a proc makes it free, then as your Rage spender" },
        { spellID = 1160, text = "Demoralizing Shout on cooldown with Booming Voice for the extra Rage, otherwise as mitigation" },
        { spellID = 20243, text = "Devastate as a filler when nothing else is ready" },
    }},
    { title = "AoE", steps = {
        { text = "Thunder Blast first at 3+ targets",
          condition = "Mountain Thane hero talent" },
        { spellID = 6343, text = "Thunder Clap as the primary AoE threat generator — with Blood and Thunder talented it also applies Rend to everything it hits" },
        { spellID = 6572, text = "Revenge cleaves nearby targets — use free procs immediately and spend Rage on it at 3+ targets" },
        { spellID = 23922, text = "Shield Slam still on cooldown for Rage" },
        { spellID = 228920, text = "Ravager on cooldown — enemies it hits take more damage from your bleeds" },
        { spellID = 46968, text = "Shockwave to stun and control add clusters" },
        { spellID = 190456, text = "Ignore Pain to absorb burst damage from multiple attackers" },
        { text = "Rotate cooldowns proactively when pulling large packs" },
    }},
    { title = "Mitigation", steps = {
        { spellID = 2565, text = "Shield Block before predictable physical damage windows — your primary active mitigation; keep it rolling with plenty of time left" },
        { spellID = 190456, text = "Ignore Pain off the global cooldown to bank spare Rage before it caps, especially right before Shield Slam" },
        { spellID = 871, text = "Shield Wall as the strongest cooldown for the heaviest damage spikes — with the Last Stand talent it also raises your maximum health by 30% and heals you for that amount" },
        { text = "Rotate Shield Wall, Demoralizing Shout and Spell Reflection across a fight's danger points rather than stacking them all on one pull" },
        { text = "Alternate Shield Block and Ignore Pain uptime so rage isn't wasted overcapping either" },
    }},
    { title = "Opener Notes", steps = {
        { text = "Your hero talent choice changes the opener: Mountain Thane leads with Thunder Blast ahead of Shield Slam to seed its own buffs, while Colossus keeps Shield Slam first and folds Thunder Clap in as a phalanx-refresh rather than a pure filler" },
    }},
  },
  cooldowns = {
    { spellID = 871, text = "Shield Wall — biggest defensive cooldown, save for the most dangerous hits; with the Last Stand talent it also grants 30% maximum health" },
    { spellID = 2565, text = "Shield Block — core physical mitigation, keep uptime high" },
    { spellID = 1160, text = "Demoralizing Shout — raid-wide damage reduction utility" },
    { spellID = 23920, text = "Spell Reflection — reflects the next incoming spell, use against dangerous casts" },
    { spellID = 97462, text = "Rallying Cry — group-wide defensive cooldown for raid damage checks" },
  },
  consumables = {
    { slot = "Flask", items = { 241324, 241326, 241320 }, text = "Flask of the Blood Knights for Haste, this spec's top secondary; Flask of the Shattered Sun if your gear already leans hard into Haste and Critical Strike is the stat you're short on. Flask of Thalassian Resistance (Versatility) is the survivability pick for progression." },
    { slot = "Food", items = { 255846, 275265, 242275, 275259 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina), or the 12.1 Loa's Gathering, Feast of Knowledge or Amani Cornucopia (about +72 of your highest secondary, +108 Stamina) - for a tank the two families come out about even, so eat whichever is down. Personal: Royal Roast (+50 primary) or Hearty Venom-Spiced Cutlets / Hearty Puffer Plate (+65 highest secondary); only feasts give Stamina, and Hearty food persists through death." },
    { slot = "Potion", items = { 241288, 241308, 241286, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Haste for this spec. Light's Potential (+695 primary stat) is a hair behind and never picks the wrong stat. Light's Preservation (a 121k absorb for 30s) for the pull that actually threatens you. Skip Draught of Rampant Abandon - its void zone silences you where you stand, the last thing a tank positioning a pack needs. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 237371, 237369 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from Blacksmithing, if the oil is scarce." },
    { slot = "Weapon Enchant", items = { 273072, 244029, 243973, 243999 }, text = "Rite of the Hash'ey (12.1) procs +139 of a random secondary for 15s, and favours your highest one while you're above 80% health - the guides' pick for most physical specs, on both weapons if you dual-wield. Acuity of the Ren'dorei (+67 primary stat) is close behind; Berserker's Rage (+124 Haste) if your sim puts Haste well clear. Worldsoul Aegis (a 14k barrier that erupts when it breaks) is the defensive alternative." },
    { slot = "Ring Enchants", items = { 244015, 243987 }, text = "Silvermoon's Alacrity (+29 Haste) on both rings; Nature's Fury (+29 Critical Strike) if you're topping up your second stat instead. Use the greater tier - the lesser one is +24." },
    { slot = "Chest Enchant", items = { 243977, 243947 }, text = "Mark of the Worldsoul (+50 primary stat); Mark of Nalorakk (+40 Strength, +116 Stamina) when you want the health instead." },
    { slot = "Leg Enchant", items = { 244641, 244643 }, text = "Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides split between them." },
    { slot = "Helm, Shoulders and Boots", items = { 244007, 244021, 243983, 243951, 243991, 243953 }, text = "Helm: Empowered Rune of Avoidance (+37) or Empowered Hex of Leeching (+55). Shoulders: Silvermoon's Mending (+166 Leech) or Amirdrassil's Grace (+111 Avoidance). Boots: Shaladrassil's Roots (+28 Leech, +232 Stamina) or Lynx's Dexterity (+19 Avoidance, +232 Stamina). Leech is the stronger sustain pick for a tank; Avoidance for dungeons heavy on unavoidable AoE. Speed (Empowered Blessing of Speed, Akil'zon's Swiftness, Farstrider's Hunt) is just as valid if you'd rather move faster." },
    { slot = "Gems", items = { 240983, 240888, 240890 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Quick Peridot (+17 Haste) in every other socket, or Flawless Deadly Peridot (+16 Haste, +7 Critical Strike) if you're balancing the two." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "Tier set piece — mitigation- and threat-relevant set bonuses often outweigh raw item level for a tank. Season 2's set bonus boosts free Revenge procs and buffs your next Shield Slam, with the four-piece adding a bleed to Ravager and free Revenges and cutting Ravager's cooldown." },
    { slot = "Neck", text = "Balance Stamina for a survivability buffer against Mastery for block value" },
    { slot = "Back", text = "Prioritize Stamina and secondary stats over a pure item-level trade" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece with Stamina and Mastery" },
    { slot = "Ring", text = "Mastery or Haste rings depending on whether you need more block chance or faster Ignore Pain cycling" },
    { slot = "Trinket", text = "One defensive on-use trinket saved for the fight's heaviest predicted damage window" },
    { slot = "Trinket", text = "One passive Stamina or avoidance trinket for a steady survivability floor" },
    { slot = "Weapon", text = "A solid one-hander — Protection's damage comes mostly from abilities, so mitigation stats outweigh weapon dps" },
    { slot = "Off-hand", text = "The highest-armor shield you can equip, since shield block value scales your core mitigation ability" },
  },
  mplusLoadout = {
    string = "CkEAAAAAAAAAAAAAAAAAAAAAA02AAAzMDzMzMzMzmxsMjxYmGGDLzMzMDGzMAAAAYZAYGDAsYGDbwAzwCNmZBmxMDmNAAzMAgZgxA",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CkEASWsDSHNyPDXnbxuIhH3Zd3yAAAjZmxMzMDziZmlZMGjGzYYxMzMjZYmBAAAALzMAGDwgtlZMbLbjmZGmhlZpxMbwYmZYsBAzMzMAgZgxA",
    source = "Blizzard Battle.net API, US region, 2026-10-27: top 49 current-season Mythic+ Protection Warriors by best keystone level in the second week of patch 12.1.5 (period 1086), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (3/49, 6%); 49/49 (100%) ran Mountain Thane overall.",
    patch = "12.1.5",
    sampleSize = 49,
  },
  tips = {
    "Keep Shield Block active before big physical hits rather than reacting after the fact.",
    "Don't dump all your rage into Ignore Pain at once — spread it to smooth damage over time.",
    "Thunder Clap stays in the single-target rotation too — it's cheap damage and threat between Shield Slams, and under Colossus it keeps Phalanx up.",
    "Save your strongest defensive cooldown for known burst phases rather than reacting late.",
    "Rotate your secondary defensives (Shield Wall, Demoralizing Shout, Spell Reflection) across a fight's danger points instead of stacking them all on one pull.",
  },
})

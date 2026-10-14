local ADDON, ns = ...

-- SpecSage guide data: Monk
-- 12.1.5 pass (2026-10-13): every spec's overview, rotation, cooldowns
-- and tips here were re-checked against SimC's `midnight` branch (client
-- data 12.1.5.70391: action priority lists, talent and spell tables),
-- spell tooltips and the 12.1.5 patch notes, and corrected where they had
-- drifted; every spellID resolves to the ability its step names. Where an
-- older note further down disagrees with a spec block, the block is current.
-- Mistweaver has no SimC action list, so it rests on tooltips and patch
-- notes.
-- Content targets Midnight (patch 12.1.5). Specs below with an `mplusLoadout`
-- field have that talent string (only) cross-checked against
-- SimulationCraft's public profiles (github.com/simulationcraft/simc,
-- GPLv3) as of patch 12.1; specs without one have no such reference.
-- Rotation/overview/tips/gear prose throughout this file is hand-authored
-- and was reviewed for Midnight ability changes, not derived from or
-- checked against SimC's APLs, and was not re-verified against current
-- tuning this pass — EXCEPT Brewmaster (268), Mistweaver (270), and Windwalker (269),
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
-- This pass also added an "Opener Notes" rotation entry naming each spec's
-- two hero talent trees, for the two specs that didn't already have one
-- inline (Mistweaver, Windwalker - Brewmaster already carried a hero-tree
-- note and was left as-is). Unlike the hand-authored prose above, these new
-- notes ARE cross-checked against SimC's current `midnight` branch profiles
-- (github.com/simulationcraft/simc) where a real action-list branch exists
-- per hero tree; where SimC's profile set has no branch (an identical
-- actions= list either way, or no profile for the spec at all), the note
-- says so honestly instead of inventing a rotation change.
-- Windwalker's overview/rotation were also corrected this pass, confirmed
-- against SimC's current `midnight` branch profile: Storm, Earth, and Fire
-- has zero references (replaced by Zenith, a baseline burst-window
-- cooldown called unconditionally in the action list, not gated behind a
-- hero talent) and Mark of the Crane has zero references either (the
-- combo-strike/Combo Breaker mastery loop the guide already described
-- separately is what actually drives the "don't repeat an ability" reward
-- now).
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

-- Brewmaster -----------------------------------------------------------
ns.GuideStore:RegisterSpec("MONK", 268, {
  specName = "Brewmaster",
  role = "TANK",
  overview = {
    "Brewmaster Monk tanks by staggering a portion of incoming physical damage into a damage-over-time effect, then clearing that staggered damage with Purifying Brew. Active mitigation is a constant rhythm rather than a single defensive-cooldown press.",
    "The core mechanic is Stagger: a percentage of hits you take is converted into a rolling damage-over-time tick instead of hitting you all at once. Purifying Brew removes a portion of the staggered pool, and Brew charges are also consumed indirectly by abilities that reduce Brew cooldown, so brew management is central to survival. Black Ox Brew instantly refills Energy and your Purifying Brew charges and grants a charge of Celestial Brew or Celestial Infusion — press it when that refund will actually get used, not just because it's off the global cooldown.",
    "Bring Brewmaster when you want a tank that smooths out burst damage into manageable ticks, has strong self-healing through Expel Harm and Celestial Brew, and provides solid AoE threat through Breath of Fire and Keg Smash.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "armor" },
    { stat = "stamina" },
    { stat = "versatility" },
    { stat = "crit" },
    { stat = "mastery" },
    { stat = "haste" },
  },
  rotation = {
    { title = "Opener", steps = {
        { text = "Get Shuffle rolling immediately — it's the mitigation buff Keg Smash (and your other builders) grant, so establishing it comes before anything else" },
        { spellID = 121253, text = "Keg Smash to start the Shuffle/threat loop" },
        { spellID = 205523, text = "Blackout Kick (it grants Shuffle too, and with Blackout Combo empowers your next Tiger Palm or Keg Smash)" },
        { spellID = 115181, text = "Breath of Fire" },
        { spellID = 325153, text = "Exploding Keg — it also resets Keg Smash's cooldown" },
        { spellID = 123986, text = "Chi Burst (if talented) to round things out" },
        { spellID = 132578, text = "Invoke Niuzao only if the pull is expected to last 25 seconds or more — it's not worth the cooldown on a short fight" },
    }},
    { title = "Single Target", steps = {
        { spellID = 115399, text = "Black Ox Brew when Celestial Brew is out of charges, so its refund (Energy, Purifying Brew and a Celestial Brew charge) actually gets used" },
        { spellID = 205523, text = "Blackout Kick whenever Blackout Combo isn't already up" },
        { spellID = 123986, text = "Chi Burst on cooldown" },
        { spellID = 132578, text = "Invoke Niuzao on cooldown on pulls that will last 25+ seconds" },
        { spellID = 100780, text = "Tiger Palm to spend Blackout Combo (or Breath of Fire if Blackout Kick isn't coming back for a while)" },
        { spellID = 325153, text = "Exploding Keg once Keg Smash is on cooldown — it resets Keg Smash; with Empty the Cellar, reactivate it to throw 5 more kegs" },
        { spellID = 115181, text = "Breath of Fire on cooldown, on targets you've already Keg Smashed" },
        { spellID = 121253, text = "Keg Smash on cooldown to build threat and reduce your Brew cooldowns" },
        { spellID = 116847, text = "Rushing Jade Wind (if talented)" },
        { spellID = 205523, text = "Blackout Kick on cooldown" },
        { spellID = 100780, text = "Tiger Palm to spend Energy before it caps" },
        { spellID = 322101, text = "Expel Harm as the last filler or when you need the healing" },
        { text = "Touch of Death whenever it's up and the target is low enough" },
        { text = "Hero trees: about nine in ten top Mythic+ Brewmasters run Master of Harmony, which spends Celestial Brew around Aspect of Harmony's stored vitality; Shado-Pan crams Breath of Fire, Keg Smash, Purifying Brew, Celestial Brew, Exploding Keg and Fortifying Brew into Invoke Niuzao's window. Both keep this same Blackout Kick/Breath of Fire/Keg Smash core" },
    }},
    { title = "AoE", steps = {
        { spellID = 121253, text = "Keg Smash on cooldown, it's your main AoE threat generator" },
        { spellID = 115181, text = "Breath of Fire to damage and weaken nearby enemies — its value goes up with every extra target" },
        { spellID = 383994, text = "Dragonfire Brew (if talented) makes Breath of Fire breathe two extra times" },
        { spellID = 325153, text = "Exploding Keg, then Empty the Cellar's extra kegs if talented" },
        { spellID = 116847, text = "Rushing Jade Wind / Charred Passions (talent-dependent) for sustained cleave" },
        { text = "The single-target priority otherwise carries over largely unchanged" },
    }},
    { title = "Mitigation", steps = {
        { text = "Shuffle uptime is your #1 defensive stat — everything below is secondary to keeping it rolling" },
        { spellID = 119582, text = "Purifying Brew to clear staggered damage when the pool is getting high — hold a charge back if you know a spike is coming rather than dumping both at once" },
        { spellID = 322507, text = "Celestial Brew (or Celestial Infusion, a talent choice) to shield against an upcoming damage spike" },
        { spellID = 115203, text = "Fortifying Brew ahead of a sustained heavy-damage phase, not after you're already deep into it" },
        { spellID = 1243287, text = "Diffuse Magic is now a passive talent: Fortifying Brew reflects the harmful magic effects on you, so time Fortifying Brew for magic-heavy mechanics too" },
        { text = "Don't purify a near-empty stagger pool — save charges for when the pool is meaningfully full" },
    }},
  },
  cooldowns = {
    { spellID = 322507, text = "Celestial Brew — proactive shield, use before a known damage spike" },
    { spellID = 115203, text = "Fortifying Brew — major defensive, use preemptively for sustained heavy-damage phases" },
    { spellID = 119582, text = "Purifying Brew — core mitigation tool, use to prevent stagger overflow; bank a charge for an expected spike rather than spending both on cooldown" },
    { spellID = 115399, text = "Black Ox Brew — refills Energy and Purifying Brew charges and grants a Celestial Brew/Celestial Infusion charge; press it when Celestial Brew is out of charges" },
    { spellID = 132578, text = "Invoke Niuzao (talent) — major cooldown for extended (25s+) high-threat or high-damage windows" },
  },
  consumables = {
    { slot = "Flask", items = { 241320, 241326 }, text = "Flask of Thalassian Resistance for Versatility, this spec's top secondary; Flask of the Shattered Sun if your gear already leans hard into Versatility and Critical Strike is the stat you're short on." },
    { slot = "Food", items = { 255846, 275265, 242275, 275259 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina), or the 12.1 Loa's Gathering, Feast of Knowledge or Amani Cornucopia (about +72 of your highest secondary, +108 Stamina) - for a tank the two families come out about even, so eat whichever is down. Personal: Royal Roast (+50 primary) or Hearty Venom-Spiced Cutlets / Hearty Puffer Plate (+65 highest secondary); only feasts give Stamina, and Hearty food persists through death." },
    { slot = "Potion", items = { 241288, 241308, 241286, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Versatility for this spec. Light's Potential (+695 primary stat) is a hair behind and never picks the wrong stat. Light's Preservation (a 121k absorb for 30s) for the pull that actually threatens you. Skip Draught of Rampant Abandon - its void zone silences you where you stand, the last thing a tank positioning a pack needs. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 237371, 237369 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from Blacksmithing, if the oil is scarce." },
    { slot = "Weapon Enchant", items = { 273072, 244029, 244001, 243999 }, text = "Rite of the Hash'ey (12.1) procs +139 of a random secondary for 15s, and favours your highest one while you're above 80% health - the guides' pick for most physical specs, on both weapons if you dual-wield. Acuity of the Ren'dorei (+67 primary stat) is close behind; Worldsoul Tenacity (+124 Versatility) if your sim puts Versatility well clear. Worldsoul Aegis (a 14k barrier that erupts when it breaks) is the defensive alternative." },
    { slot = "Ring Enchants", items = { 244017, 243987 }, text = "Silvermoon's Tenacity (+29 Versatility) on both rings; Nature's Fury (+29 Critical Strike) if you're topping up your second stat instead. Use the greater tier - the lesser one is +24." },
    { slot = "Chest Enchant", items = { 243977, 243975 }, text = "Mark of the Worldsoul (+50 primary stat); Mark of the Rootwarden (+40 Agility, +15 Speed) trades a little stat for movement." },
    { slot = "Leg Enchant", items = { 244641, 244643 }, text = "Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides split between them." },
    { slot = "Helm, Shoulders and Boots", items = { 244007, 244021, 243983, 243951, 243991, 243953 }, text = "Helm: Empowered Rune of Avoidance (+37) or Empowered Hex of Leeching (+55). Shoulders: Silvermoon's Mending (+166 Leech) or Amirdrassil's Grace (+111 Avoidance). Boots: Shaladrassil's Roots (+28 Leech, +232 Stamina) or Lynx's Dexterity (+19 Avoidance, +232 Stamina). Leech is the stronger sustain pick for a tank; Avoidance for dungeons heavy on unavoidable AoE. Speed (Empowered Blessing of Speed, Akil'zon's Swiftness, Farstrider's Hunt) is just as valid if you'd rather move faster." },
    { slot = "Gems", items = { 240983, 240912, 240914 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Versatile Lapis (+17 Versatility) in every other socket, or Flawless Deadly Lapis (+16 Versatility, +7 Critical Strike) if you're balancing the two." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "One of your tier-set slots — the four-piece bonus strengthens your Stagger/Purifying Brew loop, worth prioritizing over a raw item-level gap" },
    { slot = "Chest", text = "A large stat budget and often your other tier piece — balance Stamina for your health pool against Versatility for flat damage reduction" },
    { slot = "Neck", text = "Usually carries a socket — lean Versatility first for survivability, with Mastery next for Stagger scaling" },
    { slot = "Ring", text = "No set bonus attached — use rings to fill in Versatility and Mastery wherever your gear is light" },
    { slot = "Trinket", text = "One trinket built around avoidance, armor, or a defensive proc rather than pure Agility, to smooth out incoming damage spikes" },
    { slot = "Trinket", text = "A second trinket that adds Stamina or a passive mitigation effect so you're not trading all your survivability for threat" },
    { slot = "Weapon", text = "Monks can dual-wield one-handers or wield a single two-hander — form and Stagger math don't care which, so take the highest weapon damage option" },
    { slot = "Waist", text = "An easy slot to slot in an extra gem for whichever secondary — Versatility or Mastery — your build is currently short on" },
  },
  mplusLoadout = {
    string = "CwQAAAAAAAAAAAAAAAAAAAAAAAAAAgZbzYGzMWmxGmZMAAAAAAALLYmwMwMM2MDmZmZY2GzMmZBLb22GzYWAAglZZaZ2mZZAAgAMDbgZGw0YADAYA",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CwQAQnG51S19isUJoJoTeJ/IKDAAAgZbzYGGzyMzGzMjBAAAAAAYZBzEzMwMM2gxMzMDzGzMGLDLbPw22shZBAAWmlplZbmlBAACghNGmZATjBAAMA",
    source = "Blizzard Battle.net API, US region, 2026-10-04: top 50 current-season Mythic+ Brewmaster Monks by best keystone level, sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (3/50, 6%); 45/50 (90%) ran Master of Harmony overall.",
    patch = "12.1",
    sampleSize = 50,
  },
  tips = {
    "Purify when the stagger pool is meaningfully full, not reflexively on cooldown — timing it right smooths damage better.",
    "Keep Keg Smash on cooldown as much as possible; it's both your best threat tool and part of your mitigation kit.",
    "Use Celestial Brew proactively before a telegraphed damage spike rather than reactively after taking the hit.",
    "Watch your Brew charge count so you're never sitting capped and wasting potential mitigation.",
    "Save Black Ox Brew for a moment when its Energy/Brew refund actually gets used, not as a reflexive off-GCD press.",
    "Invoke Niuzao is only worth casting on pulls expected to run 25 seconds or longer.",
  },
})

-- Mistweaver -------------------------------------------------------------
-- Revised for 12.1 (Curse of Ula'tek) from Blizzard patch-note content
-- reached via search summaries; the official article could not be fetched
-- directly from this environment, so the specific numbers below are
-- UNVERIFIED against the source page and should be treated as provisional
-- pending direct confirmation. No SimC profile exists for this spec, so it
-- is NOT SimC-cross-checked — see the mplusLoadout note in the header above.
-- 12.1 shifts throughput out of Spinning Crane Kick (-7%) and into Mastery:
-- Gust of Mist (+50%) and the Ancient Teachings/Way of the Crane transfer,
-- explicitly to make Mastery a more viable secondary stat; it also adds a
-- new Vital Expenditure talent (Soothing Mist healing +300%, mana cost
-- +200%, a choice node against Dancing Mists). NOTE: the statPriority order
-- below has deliberately been left as Haste-before-Mastery rather than
-- reordered to match the buff — a stat-priority reorder is a derived
-- analytical conclusion (it requires modelling the spec's full scaling),
-- not a fact relayed from a patch note, and the buff alone does not
-- establish the new ranking. See the Mastery stat note below for the bare
-- fact instead.
ns.GuideStore:RegisterSpec("MONK", 270, {
  specName = "Mistweaver",
  role = "HEALER",
  overview = {
    "Mistweaver Monk heals through a mix of direct healing spells, the Renewing Mist heal-over-time that bounces between injured allies, and periodic burst-healing windows via Revival and Thunder Focus Tea. Many builds can flex between a melee 'Fistweaving' playstyle and a pure caster playstyle. Like most healers, Mistweaver doesn't run a fixed cast order — it's a reactive throughput loop where you keep your triggers (Renewing Mist uptime, Rising Sun Kick availability) rolling and press whichever spell is ready for whoever needs it most.",
    "The core mechanic is Soothing Mist and Renewing Mist uptime: keeping Renewing Mist spread across the raid provides steady passive healing, while Enveloping Mist and Vivify handle spot healing, and Thunder Focus Tea empowers your next cast for extra value. (Essence Font is no longer a Mistweaver healing spell in Midnight.)",
    "Patch 12.1 leans the spec harder into Mastery: Gust of Mist (buffed 50%) and the Ancient Teachings/Way of the Crane damage-to-healing transfer, while trimming Spinning Crane Kick's own damage — a deliberate push to make Mastery a real secondary stat instead of an afterthought. A new Vital Expenditure talent offers a channel-heavy alternative to Dancing Mists: hugely amplified Soothing Mist healing at triple the mana cost.",
    "Bring Mistweaver when you want a mobile healer with strong raid-wide throughput via Revival and Thunder Focus Tea, plus meaningful damage contribution when played in a Fistweaving style.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "haste" },
    { stat = "crit" },
    { stat = "versatility" },
    { stat = "mastery" },
  },
  rotation = {
    { title = "Priorities", steps = {
        { text = "This is a reactive throughput loop rather than a strict cast order — keep the triggers below up and press whichever's ready for the ally who needs it" },
        { spellID = 115151, text = "Renewing Mist to keep it rolling on injured or about-to-be-injured allies — don't let charges cap, but don't dump them on full-health targets either" },
        { spellID = 107428, text = "Rising Sun Kick (or Rushing Wind Kick, which replaces it if talented and heals allies with your heal-over-time effects) as often as it comes off cooldown — it's core throughput, not just a Fistweaving bonus" },
        { spellID = 116670, text = "Vivify as an efficient direct heal — with Invigorating Mists it also heals every ally carrying your Renewing Mist" },
        { spellID = 124682, text = "Enveloping Mist for strong single-target/spot healing on focus-fire targets — a Spiritfont proc halves its cast time" },
        { spellID = 115869, text = "Mana Tea: channel your stored stacks during a lull to refill mana" },
    }},
    { title = "AoE", steps = {
        { text = "Spinning Crane Kick becomes real group-healing throughput via the Way of the Crane transfer — lean on it during Mythic+ trash packs when everyone's taking damage" },
        { spellID = 115151, text = "Renewing Mist spread wide before the pack, so Vivify's Invigorating Mists cleave hits everyone" },
        { spellID = 399491, text = "Sheilun's Gift for a quick top-up on whoever's lowest right after a damage spike" },
        { text = "Spinning Crane Kick's own direct damage was trimmed in 12.1 in favor of this Mastery-driven transfer healing — expect it to heal well, not to hit like it used to" },
    }},
    { title = "Cooldown usage", steps = {
        { spellID = 115310, text = "Revival when damage is stacked and heavy — it's your rawest burst AoE heal" },
        { spellID = 388615, text = "Restoral (talent-exclusive with Revival) heals the same but drops the Magic dispel and can be cast while stunned — take it when stuns are the threat" },
        { spellID = 116680, text = "Thunder Focus Tea to empower your next Enveloping Mist (instant, with an immediate heal), Renewing Mist (+10s) or Rising Sun Kick (-9s cooldown)" },
        { spellID = 116849, text = "Life Cocoon on the target about to take heavy predictable damage" },
        { text = "Invoke Yu'lon / Chi-Ji (talent-dependent major cooldown) for sustained raid-damage phases rather than single spike moments" },
        { spellID = 1299572, text = "If talented into Vital Expenditure, lean into longer Soothing Mist channels during low-movement phases for its heavily amplified (but mana-hungry) healing" },
        { text = "Thunder Focus Tea is on a 30-second cooldown — use it on a high-value cast, but don't sit on it so long that you lose casts" },
    }},
    { title = "Opener Notes", steps = {
        { text = "Mistweaver's two hero talent trees are Conduit of the Celestials (also Windwalker's) and Master of Harmony (also Brewmaster's) — check which one your loadout uses; SimC does not yet publish a Mistweaver profile to source specific rotation branching from, so this note names the trees without claiming a specific rotation change for either" },
    }},
  },
  cooldowns = {
    { spellID = 115310, text = "Revival — raid-wide heal + cleanse, use for a big incoming damage wave" },
    { spellID = 388615, text = "Restoral — talent-exclusive alternative to Revival: same heal and Poison/Disease cleanse, no Magic dispel, castable while stunned" },
    { spellID = 116849, text = "Life Cocoon — single-target damage absorb, save for a tank swap or known burst target" },
    { spellID = 116680, text = "Thunder Focus Tea — empowers the next Enveloping Mist, Renewing Mist or Rising Sun Kick; 30-second cooldown" },
    { spellID = 115869, text = "Mana Tea — channel stored stacks to restore mana when you have a quiet moment" },
    { text = "Invoke Yu'lon / Chi-Ji (talent) — major raid-cooldown, line up with sustained damage phases" },
    { spellID = 115203, text = "Fortifying Brew — personal defensive; with the Diffuse Magic talent it also reflects harmful magic effects on you" },
  },
  consumables = {
    { slot = "Flask", items = { 241324, 241326 }, text = "Flask of the Blood Knights for Haste, this spec's top secondary; Flask of the Shattered Sun if your gear already leans hard into Haste and Critical Strike is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 241300, 241294, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Haste for this spec, so use it with your healing cooldowns. Mana potions are weak this season: Lightfused Mana Potion (26,200 mana) is the safe one, Potion of Devoured Dreams gives more over 10s but leaves you defenceless while it channels. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 243736 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Oil of Dawn instead if you'd rather your heals proc a small absorb on their target." },
    { slot = "Weapon Enchant", items = { 244029, 243973, 273072, 243997 }, text = "Acuity of the Ren'dorei procs +67 primary stat for 15s; Berserker's Rage procs +124 Haste instead and wins if your stat weights put Haste well clear of the rest. Rite of the Hash'ey (12.1: +139 of a random secondary, favouring your highest above 80% health) is the third option. Worldsoul Cradle (heals proc a 12.5k barrier on the target) is the healer-flavoured alternative." },
    { slot = "Ring Enchants", items = { 244015, 243987 }, text = "Silvermoon's Alacrity (+29 Haste) on both rings; Nature's Fury (+29 Critical Strike) if you're topping up your second stat instead. Use the greater tier - the lesser one is +24." },
    { slot = "Chest Enchant", items = { 243977, 244003 }, text = "Mark of the Worldsoul (+50 primary stat); Mark of the Magister (+40 Intellect, +5% mana) if mana is what runs out." },
    { slot = "Leg Enchant", items = { 240133, 240155 }, text = "Sunfire Silk Spellthread (+41 Intellect, +115 Stamina); Arcanoweave Spellthread (+41 Intellect, +4% mana) if you'd rather have the mana than the health." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240888, 240890 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Quick Peridot (+17 Haste) in every other socket, or Flawless Deadly Peridot (+16 Haste, +7 Critical Strike) if you're balancing the two." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "One of your tier-set slots — the four-piece bonus adds real throughput to your Renewing Mist/Vivify loop, worth prioritizing" },
    { slot = "Chest", text = "A large stat budget and often your other tier piece — favor Haste, then Mastery" },
    { slot = "Neck", text = "Usually carries a socket — favor Haste or Mastery, then whichever of the two your gear is lighter on" },
    { slot = "Ring", text = "No set bonus attached — use rings to round out Haste and Mastery" },
    { slot = "Trinket", text = "One mana-efficiency or passive-throughput trinket to stretch your healing across a long fight" },
    { slot = "Trinket", text = "A second trinket built around a burst-healing proc or on-use effect you can align with Revival/Thunder Focus Tea" },
    { slot = "Weapon", text = "Monks can dual-wield one-handers or wield a two-hander — take the highest weapon damage option since it feeds both Fistweaving damage and healing" },
    { slot = "Off-hand", text = "If dual-wielding, an off-hand that leans Haste or Mastery keeps your cast-heavy healing loop smooth" },
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "C4QAQnG51S19isUJoJoTeJ/IKDAAAAAAAgBWmZZML2mxMz2mBmhZzMbLLzMWYMNjZADGwYmZmhZDzwsMTAAAAAEgFbzsNbzMgAAYMAzAGDsIjZA",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Mistweaver Monks by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (6/50, 12%); 47/50 (94%) ran Conduit of the Celestials overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Keep Renewing Mist bouncing across as many raid members as reasonable — it's efficient passive throughput.",
    "Don't let Renewing Mist charges or Rising Sun Kick sit unused — this is a reactive loop, so hoarding charges is worse than casting on cooldown.",
    "Spend Thunder Focus Tea on a high-value Enveloping Mist or Renewing Mist, but don't hold its 30-second cooldown for long.",
    "If Fistweaving, don't neglect direct healing when damage spikes — melee damage is a bonus, not a replacement for healing; Spinning Crane Kick's own damage was trimmed in 12.1, but it now heals well through Way of the Crane.",
    "Pre-position Life Cocoon or Revival ahead of known scripted damage rather than reacting after the fact.",
  },
})

-- Windwalker ---------------------------------------------------------------
ns.GuideStore:RegisterSpec("MONK", 269, {
  specName = "Windwalker",
  role = "DAMAGER",
  overview = {
    "Windwalker Monk is a fast-paced melee spec built around generating and spending Chi through Rising Sun Kick, Fists of Fury and Whirling Dragon Punch, with Zenith (which replaced Storm, Earth, and Fire) as the baseline burst window. Conduit of the Celestials players add Invoke Xuen, the White Tiger and Celestial Conduit on top.",
    "The core resource loop is Energy generating Chi via Tiger Palm, spent on Chi abilities like Rising Sun Kick and Fists of Fury, with combo strikes (never repeating the same ability twice) fuelling your mastery and Combo Breaker procs that make Blackout Kick free. Zenith (two charges) cuts Chi costs by 1, makes Blackout Kick shave extra cooldown off your big abilities, resets Rising Sun Kick, and with Zenith Stomp releases a damaging stomp that generates Chi.",
    "Bring Windwalker when you want a highly mobile, cooldown-driven melee spec with strong burst windows and good cleave through Fists of Fury, Spinning Crane Kick, Whirling Dragon Punch and Zenith Stomp.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "haste" },
    { stat = "crit" },
    { stat = "mastery" },
    { stat = "versatility" },
  },
  rotation = {
    { title = "Opener", steps = {
        { spellID = 100780, text = "Tiger Palm to bank Chi on the pull" },
        { spellID = 123904, text = "Invoke Xuen on the pull if the target will live 25+ seconds", condition = "Conduit of the Celestials hero talent only" },
        { spellID = 1249625, text = "Zenith once Xuen is out (Shado-Pan: on the pull), lined up with trinkets and Power Infusion" },
        { spellID = 1248989, text = "Celestial Conduit inside Zenith once Heart of the Jade Serpent has dropped", condition = "Conduit of the Celestials hero talent only" },
        { text = "Then Rising Sun Kick, Fists of Fury, Strike of the Windlord and Whirling Dragon Punch as they come up, keeping combo strikes going" },
    }},
    { title = "Single Target", steps = {
        { spellID = 152175, text = "Whirling Dragon Punch when it's usable (only while Rising Sun Kick and Fists of Fury are both on cooldown) — Conduit players hold it if Invoke Xuen is less than ~9 seconds away" },
        { spellID = 1248989, text = "Celestial Conduit when Heart of the Jade Serpent isn't up", condition = "Conduit of the Celestials hero talent only" },
        { spellID = 113656, text = "Fists of Fury right before Heart of the Jade Serpent expires, and otherwise on cooldown" },
        { spellID = 100780, text = "Tiger Palm when Energy is about to cap outside Zenith" },
        { spellID = 392983, text = "Strike of the Windlord on cooldown (Conduit players: unless Invoke Xuen is less than ~9 seconds away)" },
        { text = "Touch of Death whenever it's up" },
        { text = "Rushing Wind Kick (if talented) on cooldown" },
        { spellID = 107428, text = "Rising Sun Kick on cooldown" },
        { spellID = 100784, text = "Blackout Kick with Combo Breaker, or inside Zenith when Rising Sun Kick and Fists of Fury are on cooldown — every cast shaves time off them" },
        { spellID = 101546, text = "Spinning Crane Kick with Dance of Chi-Ji, even against a single target" },
        { spellID = 100780, text = "Tiger Palm to generate Chi whenever nothing higher on this list is ready" },
        { text = "Maintain 'combo strikes' by never repeating the same ability back-to-back — it's core to Windwalker's damage" },
    }},
    { title = "AoE", steps = {
        { spellID = 113656, text = "Fists of Fury on cooldown — a large share of your AoE damage rides on it" },
        { spellID = 152175, text = "Whirling Dragon Punch whenever it's usable" },
        { spellID = 392983, text = "Strike of the Windlord inside Zenith, or when Zenith is far off" },
        { spellID = 107428, text = "Rising Sun Kick (or Rushing Wind Kick) while Fists of Fury is on cooldown" },
        { spellID = 101546, text = "Spinning Crane Kick as the main Chi spender while Fists of Fury is on cooldown, and always with Dance of Chi-Ji" },
        { spellID = 1217413, text = "Slicing Winds (talent) on cooldown" },
        { spellID = 100784, text = "Blackout Kick with Combo Breaker" },
        { text = "Keep combo strikes going while prioritizing AoE-focused abilities" },
    }},
    { title = "Opener Notes", steps = {
        { text = "Windwalker's two hero talent trees are Conduit of the Celestials (almost every top Mythic+ Windwalker) and Shado-Pan. In SimC's current action list, Conduit plays around Invoke Xuen: Xuen first, Zenith while Xuen has more than 10 seconds left, Celestial Conduit whenever Heart of the Jade Serpent is down, and Strike of the Windlord/Whirling Dragon Punch held if Xuen is about to come back. Shado-Pan has no Xuen; it uses Zenith on cooldown and spends Zenith Stomp more aggressively through Flurry Strikes" },
    }},
  },
  cooldowns = {
    { spellID = 123904, text = "Invoke Xuen, the White Tiger — 2-minute burst cooldown on long-lived targets; it unlocks Celestial Conduit for a minute", condition = "Conduit of the Celestials hero talent only" },
    { spellID = 1249625, text = "Zenith — two charges on a 1:30 recharge (replaced Storm, Earth, and Fire); use it while Xuen still has 10+ seconds left, and don't let both charges sit full" },
    { spellID = 392983, text = "Strike of the Windlord — 35-second cooldown, press it with your burst rather than right before Xuen comes back" },
    { text = "Blackout Kick shaves time off Rising Sun Kick and Fists of Fury each cast (an extra second during Zenith) — another reason not to skip it when it's available" },
    { spellID = 122470, text = "Touch of Karma — absorbs damage and redirects part of it to your target" },
    { spellID = 115203, text = "Fortifying Brew — personal defensive; with the Diffuse Magic talent it also reflects harmful magic effects on you" },
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
    { slot = "Head", text = "One of your tier-set slots — the four-piece bonus is built around your Chi/combo-strike burst windows, worth prioritizing over raw item level" },
    { slot = "Chest", text = "A large stat budget and often your other tier piece — push Critical Strike first for your Rising Sun Kick/Fists of Fury payoff" },
    { slot = "Neck", text = "Usually carries a socket — favor Critical Strike, then Mastery" },
    { slot = "Ring", text = "No set bonus attached — use rings to fill out Critical Strike and Mastery" },
    { slot = "Trinket", text = "One on-use trinket timed to pop with Invoke Xuen and Zenith for a stacked burst window" },
    { slot = "Trinket", text = "A passive Agility or Critical Strike stat-stick trinket to keep pressure up between cooldowns" },
    { slot = "Weapon", text = "Fast one-handers (fist weapons or similar) are the natural fit for Windwalker's attack-speed-driven combo strikes" },
    { slot = "Off-hand", text = "Match your off-hand's secondary stats to your main-hand's Critical Strike lean rather than treating it as filler" },
  },
  mplusLoadout = {
    string = "C0QAAAAAAAAAAAAAAAAAAAAAAMzYw2MmhlZGbzAAAAAAAAAAAAsMMaGzAGwMGmZmZY2GmhZZmAAWMz2MDzMzMAA2AQzys0MzMLAYgZGAGLDgB8B",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "C0QAQnG51S19isUJoJoTeJ/IKPzYAMGbzMz2MAAAAAAAAAAAALDzEmhhBMjhZmZGmNMDzyMBAsYmtZmxMzMDEAbAoZZWamZmFAmBmZAglxAGwA",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Windwalker Monks by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (4/50, 8%); 34/50 (68%) ran Conduit of the Celestials overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Never repeat the same ability twice in a row when possible — combo strikes are core to Windwalker's damage and mastery.",
    "As Conduit of the Celestials, line up Invoke Xuen, Zenith, Celestial Conduit and Strike of the Windlord together, and with boss burst phases, rather than spreading them out.",
    "Try to channel Fists of Fury while stationary or use its mobility talent — movement during the channel loses ticks.",
    "Use Touch of Karma both as a defensive cooldown and as extra damage — it redirects part of what it absorbs to your target.",
    "Don't let Energy or Chi sit capped — convert Energy into Chi with Tiger Palm as soon as you can afford the global cooldown.",
    "Use Blackout Kick to avoid overcapping Teachings of the Monastery stacks, not only as a Chi-strapped filler.",
  },
})

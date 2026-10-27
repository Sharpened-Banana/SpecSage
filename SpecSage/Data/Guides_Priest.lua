local ADDON, ns = ...

-- SpecSage guide data: Priest (Discipline 256, Holy 257, Shadow 258)
-- 12.1.5 pass (2026-10-13): every spec's overview, rotation, cooldowns
-- and tips here were re-checked against SimC's `midnight` branch (client
-- data 12.1.5.70391: action priority lists, talent and spell tables),
-- spell tooltips and the 12.1.5 patch notes, and corrected where they had
-- drifted; every spellID resolves to the ability its step names. Where an
-- older note further down disagrees with a spec block, the block is current.
-- Discipline and Holy have no SimC action list; they were checked against
-- the guide site's 12.1/12.1.5 pages, tooltips and patch notes.
-- Content targets Midnight (patch 12.1.5). Specs below with an `mplusLoadout`
-- field have that talent string (only) cross-checked against
-- SimulationCraft's public profiles (github.com/simulationcraft/simc,
-- GPLv3) as of patch 12.1; specs without one have no such reference.
-- Rotation/overview/tips/gear prose throughout this file is hand-authored
-- and was reviewed for Midnight ability changes, not derived from or
-- checked against SimC's APLs, and was not re-verified against current
-- tuning this pass — EXCEPT Discipline (256), Holy (257), and Shadow (258),
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
-- Shadow's overview/rotation/tips were also corrected this pass, confirmed
-- against SimC's current `midnight` branch profile: Shadow Crash has zero
-- references (replaced by Tentacle Slam, confirmed via a Blizzard forum
-- thread titled "Replacing One of the Worst Spells Ever Designed (Shadow
-- Crash) With Something Worse (Tentacle Slam)"), and Void Bolt/Void
-- Eruption both have zero references (Voidform is now a directly-cast
-- burst-window cooldown that grants charges of Void Volley, per Blizzard's
-- Curse of Ula'tek Content Update Notes; as of 12.1.5 Shadow Word: Madness
-- is the only Insanity spender).
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

-- Discipline (256): revised for 12.1 from Blizzard patch-note content reached
-- via search summaries, not from a directly-fetched patch-notes page, and not
-- SimC-cross-checked (no SimC profile exists for this spec — SimC does not
-- publish healer profiles). The specific numbers/mechanics below are
-- UNVERIFIED against a primary source and should be treated as provisional
-- pending direct confirmation. No mplusLoadout is shipped for this spec for
-- the same reason; see the file header and DESIGN.md's "BiS / Gear" section.
-- 12.1.5 pass (2026-10-13): overview, rotation, cooldowns and tips rechecked
-- against Icy Veins' Discipline rotation page (updated 2026-08-17) and SimC
-- 12.1.5.70391 talent data; Rapture, Schism and Power Word: Life were gone
-- from the tree, and Shadow Mend is now a talent with a new spell ID.
ns.GuideStore:RegisterSpec("PRIEST", 256, {
  specName = "Discipline",
  role = "HEALER",
  overview = {
    "Discipline Priest is a hybrid healer that converts damage into healing through Atonement — a buff applied to allies that turns your damage spells into heals on them. It plays less like a traditional reactive healer and more like a proactive damage-dealer whose output is redirected into the raid's health bars.",
    "The core resource is Mana, spent on both direct heals and the damage spells that trigger Atonement healing, most notably Penance and Smite. The defining mechanic is Atonement uptime — keeping the buff active on as many allies as possible before damage happens, so your damage output translates directly into pre-emptive healing. Patch 12.1 rebalanced this conversion: Discipline's damage output was brought down while the Atonement conversion rate itself was raised, so the spec still turns damage into meaningful healing, just via a smaller amount of harder-hitting damage rather than raw damage volume.",
    "Void Shield is the engine of the current kit for both hero trees: Penance and Mind Blast proc it (Penance on a four-card deck, so at least one proc every four casts), and it shields three allies at once, applying Atonement as it goes. Oracle and Voidweaver are the two hero talent paths: Oracle leans on Void Shield and Penance (Twinsight lets Penance heal an ally without losing much), while Voidweaver adds Entropic Rift, opened by Mind Blast, and Void Blast, a hard-hitting filler that takes Mind Blast's place while the rift is up. Since Atonement's value tails off past about five targets, Discipline now prefers staying at modest Atonement counts and pressing its buttons on cooldown over ramping to 20 for every pull; bigger ramps are for coverage, not raw throughput.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "haste" },
    { stat = "mastery" },
    { stat = "crit" },
    { stat = "versatility" },
  },
  rotation = {
    { title = "Mythic+ Priorities", steps = {
        { text = "This is a reactive loop, not a fixed cast order: keep Penance and Mind Blast rolling for Void Shield procs and plan around the damage you can see coming" },
        { spellID = 589, text = "Shadow Word: Pain on your active target if it isn't there" },
        { spellID = 8092, text = "Mind Blast on cooldown — it forces a Void Shield proc, and for Voidweaver it also opens Entropic Rift" },
        { spellID = 47540, text = "Penance on cooldown, at the enemy by default; with Twinsight you can point it at an ally who needs it, at the cost of spreading Shadow Word: Pain" },
        { spellID = 1253593, text = "Void Shield whenever it's available — it shields three allies and applies Atonement to each" },
        { spellID = 32379, text = "Shadow Word: Death" },
        { spellID = 450405, text = "Void Blast as filler until one of the spells above is back", condition = "Voidweaver: only while Entropic Rift is up" },
        { spellID = 1252217, text = "Shadow Mend when one player needs direct healing that Atonement isn't covering" },
        { spellID = 585, text = "Smite when nothing else is available and nobody is in danger" },
        { spellID = 194509, text = "Power Word: Radiance on a real incoming group-damage event, not on reflex — Atonement past about five targets adds coverage rather than much healing" },
    }},
    { title = "Raid Evangelism Ramp", steps = {
        { text = "Treat every Power Word: Shield below as a Void Shield when a proc is available, and refresh Shadow Word: Pain first if it would fall off during the ramp" },
        { spellID = 17, text = "Power Word: Shield" },
        { spellID = 2061, text = "One Flash Heal — Binding Heals applies Atonement to your target and yourself in one cast" },
        { spellID = 472433, text = "Evangelism, then Power Word: Radiance once or twice depending on how much coverage you need" },
        { spellID = 32379, text = "Shadow Word: Death" },
        { spellID = 8092, text = "Mind Blast" },
        { spellID = 47540, text = "Penance, then Void Shield, then Penance again and another Shadow Word: Death" },
        { spellID = 585, text = "Smite until Penance or Power Word: Shield is back", condition = "Voidweaver: Void Blast instead while Entropic Rift is up" },
    }},
    { title = "Cooldown Usage", steps = {
        { spellID = 472433, text = "Evangelism heals the group on cast and makes your next two Power Word: Radiance casts instant (the charge waits until you use it); it also triggers Archangel or Mindbender, whichever you talented. In keys it's a 90-second button — press it often rather than sitting on it" },
        { spellID = 421453, text = "Ultimate Penitence at an enemy while Atonement is out on the group — you can fit an instant (usually a Power Word: Shield) during the lift-off before the channel starts, and it doubles as a big personal shield", condition = "Voidweaver: cast Mind Blast to open Entropic Rift first, since Void Infusion's Penance bonus also applies to it" },
        { spellID = 33206, text = "Pain Suppression on the tank or whoever is about to take a lethal-range hit — with Protector of the Frail you have plenty of charges in a dungeon, so use them freely, yourself included" },
        { spellID = 62618, text = "Power Word: Barrier for a raid-wide damage reduction zone on a planned damage event" },
        { text = "Pre-shield and refresh Atonement right before a known burst damage phase rather than reacting after it lands" },
    }},
  },
  cooldowns = {
    { spellID = 472433, text = "Evangelism — instant group heal, two instant Power Word: Radiance casts, and Archangel or Mindbender; a 90-second cooldown, press it often" },
    { spellID = 421453, text = "Ultimate Penitence — 4-minute cooldown; fire it at an enemy with Atonement out for a big healing burst and a large personal shield" },
    { spellID = 62618, text = "Power Word: Barrier — raid-wide damage reduction, use for known heavy damage windows" },
    { spellID = 33206, text = "Pain Suppression — strong single-target defensive; plenty of charges with Protector of the Frail" },
    { spellID = 10060, text = "Power Infusion — give it to a DPS ally's burst window; with Twins of the Sun Priestess you get a copy too, so don't cast it on yourself" },
    { spellID = 19236, text = "Desperate Prayer — your main personal defensive; Fade with Translucent Image is a small, short-cooldown damage reduction on top" },
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
    { slot = "Head", text = "Tier set piece — the set bonus usually matters more than a small item-level gap" },
    { slot = "Neck", text = "Favor Crit and Haste to strengthen Penance and Smite's Atonement healing" },
    { slot = "Back", text = "Pick up Intellect and secondary stats over a pure item-level upgrade" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece leaning Crit and Mastery" },
    { slot = "Ring", text = "Crit or Mastery rings depending on whether burst healing or Atonement scaling needs more support" },
    { slot = "Trinket", text = "One mana-efficiency trinket for extended fights" },
    { slot = "Trinket", text = "One throughput trinket timed with Power Word: Barrier or Evangelism windows" },
    { slot = "Weapon", text = "A one-hander with strong Intellect and secondary stats rather than a pure item-level chase" },
    { slot = "Off-hand", text = "An off-hand caster stat stick for extra Intellect and secondary stats" },
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CAQAR03Gt7xPmcDNOjs2Zlb3yCDsMDWmZMmBmZbmtZmZmxMDAAAAAAAAAghZZGMzMDzYmBMNTMAzsghwYWGgxgFAAYMzMjBzAMzMTwM",
    source = "Blizzard Battle.net API, US region, 2026-10-27: top 50 current-season Mythic+ Discipline Priests by best keystone level in the second week of patch 12.1.5 (period 1086), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (2/50, 4%); 44/50 (88%) ran Oracle overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Void Shield procs from Penance and Mind Blast are most of your output — press both as close to on cooldown as you can and spend every proc.",
    "Atonement's value drops off past about five targets, so extra Plea or Flash Heal casts just to add Atonements are usually poor mana for little healing; apply more only when you need the coverage.",
    "Save Power Word: Barrier for the fight's known heaviest raid-damage window; Pain Suppression is plentiful in keys, so use it whenever someone is taking a big hit.",
    "Point Penance at an enemy by default; only aim it at an ally when you need a direct single-target heal right now.",
    "Surge of Light only halves Flash Heal's cost — skip the proc if the heal and its Atonement would mostly overheal.",
    "On Oracle, self-cast Void Shield when you don't already have one: the bigger shield on yourself also feeds more Atonement healing.",
    "On Voidweaver, clipping Penance to get back to Void Blast sooner is a small gain, except when Harsh Discipline and Power of the Dark Side are both up.",
  },
})

-- Holy (257): revised for 12.1 from Blizzard patch-note content reached via
-- search summaries, not from a directly-fetched patch-notes page, and not
-- SimC-cross-checked (no SimC profile exists for this spec — SimC does not
-- publish healer profiles). The specific numbers/mechanics below are
-- UNVERIFIED against a primary source and should be treated as provisional
-- pending direct confirmation. No mplusLoadout is shipped for this spec for
-- the same reason; see the file header and DESIGN.md's "BiS / Gear" section.
-- 12.1.5 pass (2026-10-13): overview, rotation, cooldowns and tips rechecked
-- against Icy Veins' Holy rotation page (updated 2026-08-25) and SimC
-- 12.1.5.70391 talent data; Circle of Healing, Heal, Renew (as a cast) and
-- Holy Word: Salvation were gone from the tree.
ns.GuideStore:RegisterSpec("PRIEST", 257, {
  specName = "Holy",
  role = "HEALER",
  overview = {
    "Holy Priest is a reactive healer built around its Holy Words: Holy Word: Serenity for single-target healing, Holy Word: Sanctify for group healing and Holy Word: Chastise on enemies, backed by Prayer of Mending, Prayer of Healing and Flash Heal.",
    "The core resource is Mana. The defining mechanic is Serendipity: Flash Heal takes time off Serenity, Prayer of Healing off Sanctify, and Smite and Holy Nova off Chastise (Voice of Harmony adds Prayer of Mending, Halo and Holy Fire to those). Treat the Holy Words and Prayer of Mending as rotational spells and cast them almost as soon as they're ready. Benediction, the Apex talent, turns Flash Heal into a stronger Benediction after Holy Word: Serenity and from Prayer of Mending bounces, and Lightweaver rewards alternating Flash Heal (or Benediction) into a buffed Prayer of Healing.",
    "Oracle and Archon are the two hero talent paths. Oracle (the current pick) wants Prayer of Mending on injured allies for Prompt Prognosis and boosts the Holy Words through Words of the Wise. Archon builds around Halo, which should be paired with Apotheosis or Divine Hymn, and Spiritwell, which wants Surge of Light procs spent on Prayer of Healing. Holy Priest brings strong raid healing, big cooldowns (Apotheosis, Divine Hymn, Guardian Spirit) and useful utility (Mass Dispel, Leap of Faith).",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "crit" },
    { stat = "versatility" },
    { stat = "mastery" },
    { stat = "haste" },
  },
  rotation = {
    { title = "Raid Priorities", steps = {
        { text = "There's no fixed rotation — work down this list and skip anything that would mostly overheal" },
        { spellID = 34861, text = "Holy Word: Sanctify when a cluster of the raid is injured" },
        { spellID = 2050, text = "Holy Word: Serenity on an injured ally" },
        { spellID = 88625, text = "Holy Word: Chastise to trigger Divine Image" },
        { spellID = 33076, text = "Prayer of Mending on cooldown, on an injured ally where possible (usually the melee)" },
        { spellID = 596, text = "Prayer of Healing with a Surge of Light proc" },
        { spellID = 1262755, text = "Benediction on an injured ally whenever Flash Heal has turned into it" },
        { spellID = 596, text = "Prayer of Healing with Lightweaver stacks — don't cast it with neither Lightweaver nor Surge of Light; Flash Heal or Benediction first to build Lightweaver" },
        { spellID = 2061, text = "Flash Heal with Surge of Light, or on an ally in real danger" },
        { spellID = 132157, text = "Holy Nova while moving or when little healing is needed" },
        { spellID = 585, text = "Smite when nobody needs healing — it lowers Chastise's cooldown and can proc Surge of Light" },
    }},
    { title = "Mythic+ Priorities", steps = {
        { spellID = 64843, text = "Divine Hymn for heavy group-wide damage, timed so its last seconds overlap the hit" },
        { spellID = 200183, text = "Apotheosis when you're down to 0 or 1 charge of each Holy Word" },
        { spellID = 34861, text = "Holy Word: Sanctify on a cluster of injured allies" },
        { spellID = 2050, text = "Holy Word: Serenity on an injured ally" },
        { spellID = 120517, text = "Halo when most of the group is injured", condition = "Archon only" },
        { spellID = 88625, text = "Holy Word: Chastise to trigger Divine Image" },
        { spellID = 1262755, text = "Benediction on an injured ally" },
        { spellID = 33076, text = "Prayer of Mending on cooldown, preferably on an injured ally" },
        { spellID = 2061, text = "Flash Heal or Prayer of Healing with Surge of Light, then Prayer of Healing and Flash Heal for general healing" },
        { spellID = 14914, text = "Holy Fire when nobody needs healing (after Holy Word: Chastise), then Holy Nova on 4+ enemies or Smite" },
    }},
    { title = "Cooldown Usage", steps = {
        { spellID = 200183, text = "Apotheosis triples Holy Word cooldown reduction while it lasts — use the charges you have first, then press it to get one of each back" },
        { spellID = 120517, text = "Halo just before Apotheosis or Divine Hymn, but don't hold it more than about 30 seconds", condition = "Archon only" },
        { spellID = 64843, text = "Divine Hymn during a sustained heavy damage phase; you stand still while it channels but gain Guardian Spirit for the duration" },
        { spellID = 47788, text = "Guardian Spirit as an emergency save — best on a tank about to take a big hit" },
        { spellID = 10060, text = "Power Infusion inside Apotheosis if it isn't promised to a DPS player's burst" },
    }},
  },
  cooldowns = {
    { spellID = 200183, text = "Apotheosis — triples Holy Word cooldown reduction; press it often" },
    { spellID = 64843, text = "Divine Hymn — channelled group healing; you gain Guardian Spirit while channelling" },
    { spellID = 47788, text = "Guardian Spirit — +60% healing taken and a cheat-death on the target for 10 seconds" },
    { spellID = 120517, text = "Halo (Archon) — pair with Apotheosis or Divine Hymn" },
    { spellID = 33076, text = "Prayer of Mending — a rotational cooldown; cast it as often as possible for Benediction procs" },
    { spellID = 73325, text = "Leap of Faith — utility cooldown to pull an ally out of danger" },
  },
  consumables = {
    { slot = "Flask", items = { 241326, 241320 }, text = "Flask of the Shattered Sun for Critical Strike, this spec's top secondary; Flask of Thalassian Resistance if your gear already leans hard into Critical Strike and Versatility is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 241300, 241294, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Critical Strike for this spec, so use it with your healing cooldowns. Mana potions are weak this season: Lightfused Mana Potion (26,200 mana) is the safe one, Potion of Devoured Dreams gives more over 10s but leaves you defenceless while it channels. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 243736 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Oil of Dawn instead if you'd rather your heals proc a small absorb on their target." },
    { slot = "Weapon Enchant", items = { 244029, 243971, 273072, 243997 }, text = "Acuity of the Ren'dorei procs +67 primary stat for 15s; Jan'alai's Precision procs +124 Critical Strike instead and wins if your stat weights put Critical Strike well clear of the rest. Rite of the Hash'ey (12.1: +139 of a random secondary, favouring your highest above 80% health) is the third option. Worldsoul Cradle (heals proc a 12.5k barrier on the target) is the healer-flavoured alternative." },
    { slot = "Ring Enchants", items = { 243987, 244017 }, text = "Nature's Fury (+29 Critical Strike) on both rings; Silvermoon's Tenacity (+29 Versatility) if you're topping up your second stat instead. Use the greater tier - the lesser one is +24." },
    { slot = "Chest Enchant", items = { 243977, 244003 }, text = "Mark of the Worldsoul (+50 primary stat); Mark of the Magister (+40 Intellect, +5% mana) if mana is what runs out." },
    { slot = "Leg Enchant", items = { 240133, 240155 }, text = "Sunfire Silk Spellthread (+41 Intellect, +115 Stamina); Arcanoweave Spellthread (+41 Intellect, +4% mana) if you'd rather have the mana than the health." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240904, 240910 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Deadly Garnet (+17 Critical Strike) in every other socket, or Flawless Versatile Garnet (+16 Critical Strike, +7 Versatility) if you're balancing the two." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "Tier set piece — the set bonus usually matters more than a small item-level gap. Season 2's set bonus specifically: each Renew target grants you a stacking crit bonus, with the four-piece boosting Renew's healing and having Light's Resurgence leave a Renew on your first Prayer of Mending target." },
    { slot = "Neck", text = "Favor Crit and Haste to speed up Holy Word cooldown reduction" },
    { slot = "Back", text = "Pick up Intellect and secondary stats over a pure item-level upgrade" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece leaning Crit and Mastery" },
    { slot = "Ring", text = "Crit or Mastery rings depending on whether burst or sustained healing needs more support" },
    { slot = "Trinket", text = "One mana-efficiency trinket for long fights" },
    { slot = "Trinket", text = "One throughput trinket timed with Apotheosis or Divine Hymn windows" },
    { slot = "Weapon", text = "A one-hander with strong Intellect and secondary stats rather than a pure item-level chase" },
    { slot = "Off-hand", text = "An off-hand caster stat stick for extra Intellect and secondary stats" },
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CEQAR03Gt7xPmcDNOjs2Zlb3yCDAAAAAAgZmxsMmZMzYYGYZmZmBAAAwYmlZwMzM2mxMDgZKAmZDDhxsMAjBWMzMLAaGzMGDmBYmZAD",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Holy Priests by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (4/50, 8%); 50/50 (100%) ran Oracle overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Smite or Holy Nova when nobody needs healing — they're cheap, lower Holy Word: Chastise's cooldown and can proc Surge of Light.",
    "Casting Flash Heal when Holy Word: Serenity is ready, or Prayer of Healing when Holy Word: Sanctify is, wastes mana — the Holy Words come first.",
    "Don't hoard Prayer of Mending or your Holy Words waiting for a bigger moment — casting them regularly is both more healing and more mana-efficient, and Prayer of Mending bounces are what proc Benediction.",
    "With Miracle Worker, avoid sitting on two charges of a Holy Word unless big damage is seconds away.",
    "Short on mana: spend Surge of Light on Prayer of Healing, save unbuffed Flash Heal for emergencies, and fill quiet moments with Smite and Holy Nova.",
    "Empyreal Blaze trades healing for damage (Holy Fire can't proc Surge of Light) — stick to Smite when healing is the priority.",
  },
})

-- 12.1.5 pass (2026-10-13): overview, rotation, cooldowns and tips rechecked
-- against SimC's midnight-branch priest_shadow APL and Icy Veins' Shadow
-- rotation page (updated for 12.1.5, 2026-10-09).
ns.GuideStore:RegisterSpec("PRIEST", 258, {
  specName = "Shadow",
  role = "DAMAGER",
  overview = {
    "Shadow Priest is a DoT-focused caster: keep Vampiric Touch and Shadow Word: Pain on everything worth dotting, generate Insanity with Mind Blast and your other short-cooldown spells, and spend it on Shadow Word: Madness, a DoT that rolls its remaining damage into the new cast when you refresh it.",
    "The core resource is Insanity. Shadow Word: Madness is the only spender, so refreshing it near the end of its duration, or early when you're about to cap Insanity, costs nothing. Voidform is a 2-minute cooldown cast on its own, synced with Power Infusion, that gives you charges of Void Volley and fully stacked Mastery: Shadow Weaving for its duration.",
    "Archon (Halo, Perfected Form) is the usual pick for single target and Voidweaver (Void Torrent, Entropic Rift, Void Blast in place of Mind Blast) for AoE. Shadow brings strong priority-target damage in AoE, wide DoT cleave through Tentacle Slam and Psychic Link, and utility like Power Infusion, Mass Dispel and Vampiric Embrace.",
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
        { text = "Shadowform and Power Word: Fortitude up before the pull" },
        { spellID = 34914, text = "Pre-cast Vampiric Touch, then Mind Blast" },
        { spellID = 1227280, text = "Tentacle Slam to land Vampiric Touch as the pull starts", condition = "With the Season 2 4-piece, open with Mind Blast instead and Slam after the pull, since its Crushing Void buff resets on combat start" },
        { spellID = 589, text = "Shadow Word: Pain, then Halo (Archon) and Void Volley" },
        { spellID = 228260, text = "Voidform with trinkets, potion and Power Infusion (give Power Infusion to an ally if you take Twins of the Sun Priestess)" },
        { spellID = 1242173, text = "Void Volley, then Shadow Word: Madness, then Void Torrent (Voidweaver), and on into the priority list" },
    }},
    { title = "Single Target", steps = {
        { spellID = 34914, text = "Keep Vampiric Touch and Shadow Word: Pain up, refreshing in the pandemic window (last 30%)" },
        { spellID = 1227280, text = "Tentacle Slam to apply or refresh Vampiric Touch, and before it caps on charges" },
        { spellID = 228260, text = "Voidform with Power Infusion and trinkets once both DoTs are up; Halo on cooldown on Archon" },
        { spellID = 32379, text = "Shadow Word: Death first if the target has an absorb shield", condition = "Devour Matter talent" },
        { spellID = 335467, text = "Shadow Word: Madness, your Insanity spender: recast it with under a GCD left, when you're within ~35 Insanity of cap, or any time in Voidform; pool Insanity if Voidform is under 25 seconds away" },
        { spellID = 450405, text = "Void Blast while Shadow Word: Madness is up or Entropic Rift is about to expire", condition = "Voidweaver only" },
        { spellID = 263165, text = "Void Torrent with Shadow Word: Madness already ticking — it opens Entropic Rift", condition = "Voidweaver only" },
        { spellID = 8092, text = "Mind Blast — don't let charges sit capped; Shadowy Insight procs are just a free extra charge" },
        { spellID = 391401, text = "Mind Flay: Insanity while Shadow Word: Madness is up" },
        { spellID = 32379, text = "Shadow Word: Death below 20% health (35% with Deathspeaker), or while a Shadowfiend/Mindbender is out with Inescapable Torment" },
        { spellID = 1242173, text = "Void Volley — spend every charge before Voidform ends; with the 4-piece weave it in outside Voidform too" },
        { spellID = 15407, text = "Mind Flay as filler, clipped as soon as anything above is ready" },
    }},
    { title = "AoE", steps = {
        { text = "Fade-pull with the tank and start dotting while the pack is gathered; keep Vampiric Touch and Shadow Word: Pain on up to about 12 targets that will live at least 18 seconds" },
        { spellID = 1227280, text = "Tentacle Slam once the pack is stacked — it applies Vampiric Touch to up to 6 enemies; use both charges on a big pack" },
        { spellID = 335467, text = "Shadow Word: Madness funnelled into the highest-health priority target, or spread to a new target each cast for more total AoE (Distorted Reality favors spreading)" },
        { spellID = 199484, text = "Psychic Link carries your direct damage to every Vampiric Touch target, so cast onto the target with Shadow Word: Madness on it" },
        { spellID = 589, text = "Shadow Word: Pain on any target missing it that will live 12+ seconds", condition = "Invoked Nightmare builds (no Misery)" },
        { text = "The rest follows the single-target list: Void Blast, Void Torrent, Mind Blast, Mind Flay: Insanity, Void Volley, Mind Flay" },
    }},
  },
  cooldowns = {
    { spellID = 228260, text = "Voidform — 2-minute burst window with charges of Void Volley; line it up with Power Infusion, trinkets and potion, and Ancient Madness extends it for each Shadow Word: Madness cast inside" },
    { spellID = 10060, text = "Power Infusion — sync with Voidform; with Twins of the Sun Priestess give it to an ally and get a copy yourself" },
    { spellID = 120644, text = "Halo — Archon only, on cooldown (it will drift slightly into Voidform over a long fight)" },
    { spellID = 263165, text = "Void Torrent — Voidweaver only; opens Entropic Rift, cast with Shadow Word: Madness active, can be held up to ~10 seconds for an incoming pack" },
    { spellID = 1227280, text = "Tentacle Slam — charge-based DoT spreader; never let it cap, especially inside cooldowns (Void Apparitions)" },
    { spellID = 47585, text = "Dispersion — damage reduction and Insanity recovery cooldown" },
    { spellID = 586, text = "Fade — threat drop for pulling with the tank, and a mechanic dodge" },
    { spellID = 15487, text = "Silence — interrupt/utility cooldown, use on dangerous casts" },
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
    { slot = "Head", text = "Tier set piece — the set bonus usually matters more than a small item-level gap. Season 2's set bonus specifically: Tentacle Slam's cooldown drops and its damage rises, with the four-piece giving it a guaranteed free, full-power Void Volley." },
    { slot = "Neck", text = "Favor Haste to speed up DoT ticks and Insanity generation" },
    { slot = "Back", text = "Secondary stats matching Haste and Mastery outweigh a pure item-level chase" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece leaning Haste and Mastery" },
    { slot = "Ring", text = "Haste or Mastery rings depending on your current stat weights" },
    { slot = "Trinket", text = "One on-use Intellect or damage trinket lined up with your Insanity burst window" },
    { slot = "Trinket", text = "A passive stat-stick trinket for consistent DoT damage" },
    { slot = "Weapon", text = "A one-hander or staff with strong Intellect and secondary stats" },
    { slot = "Off-hand", text = "An off-hand caster stat stick for extra Intellect and secondary stats" },
  },
  mplusLoadout = {
    string = "CIQAAAAAAAAAAAAAAAAAAAAAAMMjZGAAAAAAAAAAAAMLmxMbzMMz2MzYG2mZGzMzYDZGLmpBYmZGAIAz2stEMbMAwgxMzMmtxMYmBzgB",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CIQAR03Gt7xPmcDNOjs2Zlb3yOMDDAAAAAAAAAAAAmZxMmZbmxMzyMGzw2MzYmZGbIzYxMNAzAMzmZ0sZAIjxCAmZAjZmZMbMz2yAMDGA",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Shadow Priests by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (7/50, 14%); 44/50 (88%) ran Archon overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Never let Shadow Word: Pain or Vampiric Touch fall off a target you'll keep attacking; refresh them in the last 30% of their duration.",
    "Shadow Word: Madness rolls its leftover damage into the new cast, so refreshing early to avoid capping Insanity loses nothing — but for Mastery uptime, refresh it with under a GCD left when you aren't near cap.",
    "Tentacle Slam is your main DoT-spreading tool; don't let it sit on full charges, and with the Season 2 2-piece its shorter cooldown makes that easier to do.",
    "Don't feel obliged to finish Mind Flay — start thinking about the next cast about halfway through the channel.",
    "While moving, use Void Volley, Shadow Word: Death, Shadow Word: Madness and Shadowy Insight procs, and fall back to Shadow Word: Pain if nothing else is instant.",
    "Pull with the tank behind a Fade so your DoTs are rolling before the pack is gathered.",
  },
})

local ADDON, ns = ...

-- SpecSage guide data: Paladin (Holy 65, Protection 66, Retribution 70)
-- 12.1.5 pass (2026-10-13): every spec's overview, rotation, cooldowns
-- and tips here were re-checked against SimC's `midnight` branch (client
-- data 12.1.5.70391: action priority lists, talent and spell tables),
-- spell tooltips and the 12.1.5 patch notes, and corrected where they had
-- drifted; every spellID resolves to the ability its step names. Where an
-- older note further down disagrees with a spec block, the block is current.
-- Protection's `mplusLoadout` moved to the MID2 profile (patch 12.1.5); Holy has
-- no SimC action list, so it rests on tooltips and patch notes.
-- Content targets Midnight (patch 12.1.5). Specs below with an `mplusLoadout`
-- field have that talent string (only) cross-checked against
-- SimulationCraft's public profiles (github.com/simulationcraft/simc,
-- GPLv3) as of patch 12.1; specs without one have no such reference.
-- Rotation/overview/tips/gear prose throughout this file is hand-authored
-- and was reviewed for Midnight ability changes, not derived from or
-- checked against SimC's APLs, and was not re-verified against current
-- tuning this pass — EXCEPT Holy (65), Protection (66), and Retribution (70),
-- which each gained an `mplusMetaLoadout` (DESIGN.md's v1.4 section): pulled
-- live from Blizzard's own Battle.net Game Data API (client-credentials
-- OAuth, US region) rather than SimC (Protection first, on 2026-08-30; Holy
-- and Retribution followed the same day in a second pass). Methodology:
-- every current-season Mythic+ leaderboard (8-dungeon pool, period 1078; refreshed 2026-10-04 at
-- period 1083, 2026-10-13 at period 1085 (12.1.5's first day) and
-- 2026-10-27 at period 1086, the end of its second week - a
-- field whose `source` carries an older date was kept because the newer
-- sample had no clear most-common build)
-- across all 83 US connected realms was scanned (top 20 groups per
-- realm/dungeon) for each spec's group members; the 50 distinct characters
-- per spec with the highest observed keystone level had their live
-- `specializations` looked up for their active loadout's
-- `talent_loadout_code` (confirmed to be Blizzard's real export-string
-- format, not structured data needing a custom encoder). See each field's
-- own `source` comment for the resulting distribution.
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

-- Holy (65): revised for 12.1 from Blizzard patch-note content reached via
-- search summaries, not from a directly-fetched patch-notes page, and not
-- SimC-cross-checked (no SimC profile exists for this spec — SimC does not
-- publish healer profiles). The specific numbers/mechanics below are
-- UNVERIFIED against a primary source and should be treated as provisional
-- pending direct confirmation. No mplusLoadout is shipped for this spec for
-- the same reason; see the file header and DESIGN.md's "BiS / Gear" section.
ns.GuideStore:RegisterSpec("PALADIN", 65, {
  specName = "Holy",
  role = "HEALER",
  overview = {
    "Holy Paladin is a hybrid healer that blends direct single-target healing (Holy Shock, Holy Light) with strong smart-heal utility from Beacon of Light/Faith spreading a portion of your healing to bonded targets. It rewards good beacon placement and Holy Power management as much as raw cast timing.",
    "The core resource is Holy Power, generated from Holy Shock and Crusader Strike and spent on Word of Glory / Eternal Flame / Light of Dawn, alongside mana as the overarching limiting resource across a fight. The defining mechanic is the Beacon system — healing the beacon target's bonded ally also heals them, so positioning beacons on tanks or high-damage targets multiplies your throughput. Patch 12.1 increased Holy Power spender healing.",
    "Herald of the Sun and Lightsmith are the two hero talent paths. Herald of the Sun turns Holy Prism and Divine Toll into Dawnlight casts, empowering your next two Holy Power spenders with a heal over time; Lightsmith adds Holy Armaments (alternating Holy Bulwark and Sacred Weapon, and generating Holy Power) plus Hammer and Anvil healing from Judgment critical strikes. Holy Paladin brings strong raid cooldowns (Avenging Wrath, Aura Mastery), solid AoE healing through Light of Dawn and Holy Prism-style tools, and reliable tank healing via beacon uptime.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "mastery" },
    { stat = "haste" },
    { stat = "crit" },
    { stat = "versatility" },
  },
  rotation = {
    { title = "Priorities", steps = {
        { spellID = 20473, text = "Holy Shock as often as its cooldown allows — it's the core of the whole loop, both a strong heal and your main Holy Power generator" },
        { spellID = 53563, text = "Beacon of Light kept active on the tank or primary damage-taker at all times" },
        { spellID = 19750, text = "Flash of Light on an Infusion of Light proc — it becomes instant with 200% more healing (a proc can empower Judgment instead)" },
        { spellID = 82326, text = "Holy Light as your big, efficient-per-cast single-target heal when you have time to hard-cast (it also generates Holy Power with Tower of Radiance)" },
        { spellID = 85222, text = "Light of Dawn or Word of Glory to spend Holy Power — you don't have to dump every point the instant you have one; banking a charge or two is fine when you're unsure whether a bigger heal is about to be needed" },
        { text = "Word of Glory and Eternal Flame both had their healing increased in 12.1" },
        { text = "Weave Judgment/Crusader Strike when healing demand is low to keep Holy Power flowing" },
        { text = "Holy Armaments on cooldown — it alternates between Holy Bulwark and Sacred Weapon and generates Holy Power, so don't let charges sit",
          condition = "Lightsmith hero talent" },
    }},
    { title = "Cooldown Usage", steps = {
        { spellID = 31884, text = "Avenging Wrath (or Avenging Crusader) during heavy incoming damage windows" },
        { spellID = 375576, text = "Divine Toll — it casts Holy Shock on up to five targets at once on a 1-minute cooldown, so use it generously rather than saving it for emergencies (under Herald of the Sun it also sets up Dawnlight)" },
        { spellID = 200025, text = "Beacon of Virtue right before a scripted AoE damage spike, to get every beacon target topped off at once" },
        { spellID = 31821, text = "Aura Mastery to blanket the raid with your active Aura's benefit during a damage spike" },
        { spellID = 633, text = "Lay on Hands as a full-health emergency heal on whoever's about to die" },
        { text = "Pre-position beacons before a pull so tank healing is covered from the first hit" },
        { text = "Stack cooldowns together for predictable heavy-damage phases rather than spreading them thin" },
    }},
  },
  cooldowns = {
    { spellID = 31884, text = "Avenging Wrath — general healing/damage cooldown, use on cooldown during progression" },
    { spellID = 375576, text = "Divine Toll — Holy Shock on up to 5 targets at once on a 1-minute cooldown; use it often rather than hoarding it" },
    { spellID = 31821, text = "Aura Mastery — raid-wide cooldown, save for known heavy damage windows" },
    { spellID = 633, text = "Lay on Hands — full-health emergency heal, remember it applies Forbearance to the target" },
    { spellID = 1022, text = "Blessing of Protection — physical damage immunity for a single ally in danger" },
    { spellID = 6940, text = "Blessing of Sacrifice — redirect damage from an ally to yourself" },
  },
  consumables = {
    { slot = "Flask", items = { 241322, 241324 }, text = "Flask of the Magisters for Mastery, this spec's top secondary; Flask of the Blood Knights if your gear already leans hard into Mastery and Haste is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 241300, 241294, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Mastery for this spec, so use it with your healing cooldowns. Mana potions are weak this season: Lightfused Mana Potion (26,200 mana) is the safe one, Potion of Devoured Dreams gives more over 10s but leaves you defenceless while it channels. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 243736, 237371, 237369 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Oil of Dawn instead if you'd rather your heals proc a small absorb on their target; Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from Blacksmithing, if the oil is scarce." },
    { slot = "Weapon Enchant", items = { 273072, 244029, 244031, 243997 }, text = "Rite of the Hash'ey (12.1) procs +139 of a random secondary for 15s, and favours your highest one while you're above 80% health - the guides' pick for most physical specs, on both weapons if you dual-wield. Acuity of the Ren'dorei (+67 primary stat) is close behind; Arcane Mastery (+124 Mastery) if your sim puts Mastery well clear. Worldsoul Cradle (heals proc a 12.5k barrier on the target) is the healer-flavoured alternative." },
    { slot = "Ring Enchants", items = { 243959, 244015 }, text = "Zul'jin's Mastery (+29 Mastery) on both rings; Silvermoon's Alacrity (+29 Haste) if you're topping up your second stat instead. Use the greater tier - the lesser one is +24." },
    { slot = "Chest Enchant", items = { 243977, 244003 }, text = "Mark of the Worldsoul (+50 primary stat); Mark of the Magister (+40 Intellect, +5% mana) if mana is what runs out." },
    { slot = "Leg Enchant", items = { 244641, 244643 }, text = "Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides split between them." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240896, 240900 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Masterful Amethyst (+17 Mastery) in every other socket, or Flawless Quick Amethyst (+16 Mastery, +7 Haste) if you're balancing the two." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "Tier set piece — the set bonus usually shapes your Holy Shock/Holy Power cycle more than raw item level. Season 2's set bonus specifically: Infusion of Light adds a large Flash of Light healing boost and a Greater Judgment absorb, with the four-piece adding a chance for Judgment to grant Infusion of Light and a guaranteed (pricier) proc from Holy Light." },
    { slot = "Neck", text = "Favor Crit and Haste to keep Holy Shock cycling and heals landing faster" },
    { slot = "Back", text = "Pick up Intellect and secondary stats over a pure item-level upgrade" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece leaning Crit and Haste" },
    { slot = "Ring", text = "Crit or Haste rings depending on whether burst healing or cast speed is your current bottleneck" },
    { slot = "Trinket", text = "One mana-efficiency or regen trinket to extend your healing over long fights" },
    { slot = "Trinket", text = "One throughput trinket, on-use or proc, timed with Avenging Wrath or Divine Toll" },
    { slot = "Weapon", text = "A one-hander with strong Intellect and secondary stats rather than a pure item-level chase" },
    { slot = "Off-hand", text = "An off-hand caster stat stick for extra Intellect and secondary stats" },
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CEEAzbn3egSOtoSwvPw1U1vTLAAAALAwMAAD2GzMzMjZmZBmZYZsZmFjmYYMzMMmtMAMAsB2YZmZmlZbmZ2aAAAAWAGsZgZMDzAAYmhZMGNA",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Holy Paladins by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (3/50, 6%); 31/50 (62%) ran Lightsmith overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Keep Beacon of Light on the tank at all times unless you're intentionally repositioning it.",
    "Don't let Holy Power sit at the cap, but banking a point or two while you wait to see if a bigger heal is coming is completely fine — Holy doesn't have to dump on cooldown the way a DPS spec does.",
    "Save your strongest cooldowns for known heavy-damage phases rather than reacting after the raid is already low.",
    "Holy Shock's cooldown is short — using it on cooldown even for small top-ups is rarely wrong.",
    "Divine Toll is short enough on cooldown that you should be casting it often, not hoarding it for emergencies.",
    "Patch 12.1 buffed talents that support Beacon of Virtue.",
  },
})

ns.GuideStore:RegisterSpec("PALADIN", 66, {
  specName = "Protection",
  role = "TANK",
  overview = {
    "Protection Paladin is a shield tank that plays around high, consistent block chance and Word of Glory self-healing fueled by Holy Power. Its rotation blends Judgment/Hammer of the Righteous builders with Shield of the Righteous spenders that both mitigate damage and generate threat.",
    "The core resource is Holy Power, generated from Judgment, Hammer of the Righteous, and Blessed Hammer-style attacks, and spent primarily on Shield of the Righteous, which is the spec's core mitigation cooldown as much as it is a rotational ability. Consecration provides a persistent AoE threat and damage floor under your feet.",
    "Protection Paladin brings smooth, consistent physical mitigation, strong self-healing from Holy Power spenders, and solid AoE threat, making it a reliable tank choice for both sustained raid tanking and Mythic+ pulls where consistent uptime on Shield of the Righteous matters.",
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
        { spellID = 31935, text = "Avenger's Shield to pull" },
        { spellID = 20271, text = "Judgment" },
        { text = "Blessed Hammer or Hammer of the Righteous, whichever your build runs" },
        { spellID = 26573, text = "Get Consecration down and keep it there" },
        { spellID = 53600, text = "Shield of the Righteous once you've got Holy Power to spend" },
    }},
    { title = "Single Target", steps = {
        { spellID = 31884, text = "Avenging Wrath (or Sentinel) on cooldown — Judgment becomes Hammer of Wrath while it's active" },
        { text = "Holy Armaments just before Avenging Wrath, or whenever it's at 2 charges",
          condition = "Lightsmith hero talent" },
        { spellID = 375576, text = "Divine Toll — inside Avenging Wrath when the two line up, otherwise on cooldown" },
        { text = "Hammer of Light while Divine Toll has made it available, with Judgment's debuff on the target — don't let the 20-second window lapse",
          condition = "Templar hero talent" },
        { spellID = 53600, text = "Shield of the Righteous to keep its mitigation buff at (or close to) 100% uptime — it's off the global cooldown, so this should rarely cost you a generator" },
        { spellID = 20271, text = "Judgment (Hammer of Wrath during Avenging Wrath) before its charges cap" },
        { spellID = 31935, text = "Avenger's Shield on cooldown — ranged pull tool, interrupt, absorb shield and real damage, not just an opener button" },
        { spellID = 26573, text = "Consecration whenever it isn't down under you (and under Lightsmith, at 5 Divine Guidance stacks)" },
        { spellID = 204019, text = "Blessed Hammer (or Hammer of the Righteous, choice-node dependent) as the filler builder" },
        { spellID = 85673, text = "Word of Glory on a free Shining Light proc, or whenever you need the heal" },
    }},
    { title = "AoE", steps = {
        { spellID = 26573, text = "Consecration kept active — between it and Avenger's Shield's multi-target hit, these two carry most of your AoE" },
        { spellID = 31935, text = "Avenger's Shield on cooldown — it hits three targets and is a big share of your AoE threat and damage" },
        { spellID = 204019, text = "Blessed Hammer (or Hammer of the Righteous) as the primary AoE builder" },
        { spellID = 53600, text = "Shield of the Righteous still prioritized for mitigation uptime" },
        { spellID = 20271, text = "Judgment on cooldown across multiple targets when available" },
        { text = "Otherwise the single-target priority carries over — keep Consecration down and your generators on cooldown rather than switching to a separate AoE-only rotation" },
    }},
    { title = "Mitigation", steps = {
        { spellID = 53600, text = "Shield of the Righteous — off the global cooldown, so keeping its buff up basically never costs you a GCD; never let it fall off during a pull" },
        { spellID = 85673, text = "Word of Glory when you'd rather spend Holy Power on healing than mitigation — it's the one Holy Power spender here that does cost a GCD" },
        { spellID = 86659, text = "Guardian of Ancient Kings for a major defensive cooldown window — 50% damage reduction for 8 seconds on a 3-minute cooldown, so plan it for a known spike rather than hoarding it" },
        { spellID = 31850, text = "Ardent Defender for the heaviest incoming damage spikes" },
        { spellID = 642, text = "Divine Shield as a full damage-immunity panic button when nothing else will save you" },
        { spellID = 1022, text = "Blessing of Protection on yourself or an ally for a physical-damage emergency" },
        { text = "Bank Holy Power slightly before a known burst window so Shield of the Righteous never lapses" },
    }},
    { title = "Opener Notes", steps = {
        { text = "Templar's capstone finisher, Hammer of Light, replaces Divine Toll for 20 seconds after you cast it (and Light's Deliverance grants extra free casts) — spend it promptly rather than continuing to bank Holy Power for Shield of the Righteous" },
        { text = "Templar and Lightsmith are Protection's two hero trees: Templar trades a little consistency for Hammer of Light's periodic burst, while Lightsmith is simpler and layers group-wide absorbs on top of your normal kit. The current Mythic+ meta leans heavily toward Lightsmith (96% of the top-keystone Protection Paladins in this guide's own live-meta sample), for whatever that's worth beyond raw power level" },
    }},
  },
  cooldowns = {
    { spellID = 86659, text = "Guardian of Ancient Kings — strong all-purpose defensive cooldown, 50% damage reduction for 8 seconds on a 3-minute cooldown" },
    { spellID = 31850, text = "Ardent Defender — save for the most dangerous predicted damage spike" },
    { spellID = 642, text = "Divine Shield — full damage immunity, use when nothing else will keep you standing" },
    { spellID = 1022, text = "Blessing of Protection — physical immunity, use on cooldown for mechanics" },
    { spellID = 6940, text = "Blessing of Sacrifice — soak burst damage meant for an ally" },
    { spellID = 31884, text = "Avenging Wrath — damage and self-healing cooldown, weave in during sustained damage" },
  },
  consumables = {
    { slot = "Flask", items = { 241324, 241322, 241320 }, text = "Flask of the Blood Knights for Haste, this spec's top secondary; Flask of the Magisters if your gear already leans hard into Haste and Mastery is the stat you're short on. Flask of Thalassian Resistance (Versatility) is the survivability pick for progression." },
    { slot = "Food", items = { 255846, 275265, 242275, 275259 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina), or the 12.1 Loa's Gathering, Feast of Knowledge or Amani Cornucopia (about +72 of your highest secondary, +108 Stamina) - for a tank the two families come out about even, so eat whichever is down. Personal: Royal Roast (+50 primary) or Hearty Venom-Spiced Cutlets / Hearty Puffer Plate (+65 highest secondary); only feasts give Stamina, and Hearty food persists through death." },
    { slot = "Potion", items = { 241288, 241308, 241286, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Haste for this spec. Light's Potential (+695 primary stat) is a hair behind and never picks the wrong stat. Light's Preservation (a 121k absorb for 30s) for the pull that actually threatens you. Skip Draught of Rampant Abandon - its void zone silences you where you stand, the last thing a tank positioning a pack needs. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 237371, 237369 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from Blacksmithing, if the oil is scarce." },
    { slot = "Weapon Enchant", items = { 273072, 244029, 243973, 243999 }, text = "Rite of the Hash'ey (12.1) procs +139 of a random secondary for 15s, and favours your highest one while you're above 80% health - the guides' pick for most physical specs, on both weapons if you dual-wield. Acuity of the Ren'dorei (+67 primary stat) is close behind; Berserker's Rage (+124 Haste) if your sim puts Haste well clear. Worldsoul Aegis (a 14k barrier that erupts when it breaks) is the defensive alternative." },
    { slot = "Ring Enchants", items = { 244015, 243959 }, text = "Silvermoon's Alacrity (+29 Haste) on both rings; Zul'jin's Mastery (+29 Mastery) if you're topping up your second stat instead. Use the greater tier - the lesser one is +24." },
    { slot = "Chest Enchant", items = { 243977, 243947 }, text = "Mark of the Worldsoul (+50 primary stat); Mark of Nalorakk (+40 Strength, +116 Stamina) when you want the health instead." },
    { slot = "Leg Enchant", items = { 244641, 244643 }, text = "Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides split between them." },
    { slot = "Helm, Shoulders and Boots", items = { 244007, 244021, 243983, 243951, 243991, 243953 }, text = "Helm: Empowered Rune of Avoidance (+37) or Empowered Hex of Leeching (+55). Shoulders: Silvermoon's Mending (+166 Leech) or Amirdrassil's Grace (+111 Avoidance). Boots: Shaladrassil's Roots (+28 Leech, +232 Stamina) or Lynx's Dexterity (+19 Avoidance, +232 Stamina). Leech is the stronger sustain pick for a tank; Avoidance for dungeons heavy on unavoidable AoE. Speed (Empowered Blessing of Speed, Akil'zon's Swiftness, Farstrider's Hunt) is just as valid if you'd rather move faster." },
    { slot = "Gems", items = { 240983, 240888, 240892 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Quick Peridot (+17 Haste) in every other socket, or Flawless Masterful Peridot (+16 Haste, +7 Mastery) if you're balancing the two." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "Tier set piece — Shield of the Righteous uptime and Holy Power flow usually benefit more than a small item-level gap. Season 2's set bonus specifically: Consecration grows and grants bonus crit chance against enemies standing in it, with the four-piece adding bonus Holy damage to Judgment/Blessed Hammer that doubles on a crit." },
    { slot = "Neck", text = "Balance Stamina for survivability with Haste for faster Holy Power generation" },
    { slot = "Back", text = "Prioritize Stamina and secondary stats over a pure item-level trade" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece leaning Haste and Mastery" },
    { slot = "Ring", text = "Haste or Mastery rings depending on whether Shield of the Righteous uptime or block chance needs more support" },
    { slot = "Trinket", text = "One defensive on-use trinket saved for the fight's heaviest predicted damage window" },
    { slot = "Trinket", text = "One passive Stamina or avoidance trinket for a steady mitigation floor" },
    { slot = "Weapon", text = "A solid one-hander — abilities carry the damage, so mitigation and Holy Power stats matter more than weapon dps" },
    { slot = "Off-hand", text = "The highest-armor shield available, since it directly backs Shield of the Righteous's mitigation value" },
  },
  mplusLoadout = {
    string = "CIEAAAAAAAAAAAAAAAAAAAAAAsNzYWmZMzYmxyyALzCDDAwAAAAAAg0MDzYmZMzs1GAGYGYGsNAAACwMzyySLzMWsthBghZYMAYmBAzAM2A",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1.5",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CIEAzbn3egSOtoSwvPw1U1vTLsZYWGzYmZmZW2GjZZWmlZMAADAAAAAAaamZZmxMDDbtBgBGwMYDAAgAMzsst0yMjFLLMDgBzshBAzMAYmBMWA",
    source = "Blizzard Battle.net API, US region, 2026-10-27: top 50 current-season Mythic+ Protection Paladins by best keystone level in the second week of patch 12.1.5 (period 1086), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (2/50, 4%); 50/50 (100%) ran Lightsmith overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Never let Shield of the Righteous's mitigation buff lapse — it's the spec's core defensive tool.",
    "Keep Consecration active under yourself for free AoE threat and damage.",
    "Default to spending Holy Power on Shield of the Righteous — only divert it to Word of Glory when you actually need the heal, since SotR is free on the GCD and WoG isn't.",
    "Bank a small Holy Power buffer before predictable burst damage so you can reapply Shield of the Righteous instantly.",
    "Guardian of Ancient Kings is on a 3-minute cooldown — map it to a fight's biggest hit rather than holding it for a panic that never comes.",
    "Use Blessing of Protection proactively on known mechanics rather than only as a panic button.",
  },
})

ns.GuideStore:RegisterSpec("PALADIN", 70, {
  specName = "Retribution",
  role = "DAMAGER",
  overview = {
    "Retribution Paladin is a two-handed melee spec that plays around building Holy Power with Blade of Justice and Crusader Strike, then spending it on Templar's Verdict/Final Verdict for burst windows amplified by Wake of Ashes and Crusade/Avenging Wrath-style cooldowns.",
    "The core resource is Holy Power, generated from Blade of Justice, Crusader Strike, and Judgment, and spent on Templar's Verdict and Divine Storm. The defining mechanic is stacking Holy Power generation and burst cooldowns together so several high-value spenders land inside the same damage-amplified window.",
    "Retribution brings strong burst windows, useful raid utility (Blessing of Protection/Sacrifice, Lay on Hands), and solid cleave through Divine Storm, making it a good pick when you want a melee spec with reliable defensive and offensive utility on top of its damage.",
  },
  statPriority = {
    { stat = "primary" },
    { stat = "mastery" },
    { stat = "haste" },
    { stat = "crit" },
    { stat = "versatility" },
  },
  rotation = {
    { title = "Single Target", steps = {
        { spellID = 31884, text = "Avenging Wrath on cooldown — your core burst window (with Radiant Glory, Wake of Ashes triggers a short Avenging Wrath instead)" },
        { spellID = 343527, text = "Execution Sentence right before Wake of Ashes, so its delayed hammer collects the damage of your burst" },
        { text = "Spend Holy Power first whenever you're sitting at 5 and Wake of Ashes isn't ready" },
        { spellID = 255937, text = "Wake of Ashes on cooldown (30s) for 3 Holy Power, held only while Avenging Wrath is a few seconds away" },
        { spellID = 375576, text = "Divine Toll on cooldown, unless Avenging Wrath is coming back within about 15 seconds" },
        { spellID = 184575, text = "Blade of Justice right away at 2 stacks of Art of War or Righteous Cause, so the procs don't overflow" },
        { text = "Hammer of Light the moment Wake of Ashes turns into it, and again on a free Light's Deliverance cast — it costs 3 Holy Power",
          condition = "Templar hero talent" },
        { spellID = 53385, text = "Divine Storm over Final Verdict whenever a Divine Arbiter proc is up, even against a single target" },
        { spellID = 383328, text = "Final Verdict as your Holy Power spender (3 Holy Power) whenever the above aren't up — spenders come before most builders" },
        { spellID = 184575, text = "Blade of Justice, Hammer of Wrath (Judgment becomes it during Avenging Wrath) and Judgment to rebuild Holy Power" },
        { spellID = 35395, text = "Crusader Strike or Templar Strike / Templar Slash as the last filler builder" },
    }},
    { title = "AoE", steps = {
        { spellID = 255937, text = "Wake of Ashes to generate Holy Power and hit everything in front of you" },
        { spellID = 375576, text = "Divine Toll on cooldown — it hits multiple targets and refills Holy Power for your next Divine Storm" },
        { spellID = 53385, text = "Divine Storm as the primary AoE Holy Power spender at 2+ targets" },
        { text = "Hammer of Light whenever it's available — it hits up to 7 nearby enemies",
          condition = "Templar hero talent" },
        { spellID = 184575, text = "Blade of Justice on cooldown across the pull" },
        { spellID = 20271, text = "Judgment on cooldown for generation" },
        { spellID = 35395, text = "Crusader Strike as filler when builders are down" },
    }},
    { title = "Opener Notes", steps = {
        { text = "Open with Blade of Justice into Avenging Wrath, popping your potion and on-use trinkets alongside it, and keep building Holy Power rather than dumping it immediately — the goal is landing your first big spender dump fully inside the Avenging Wrath window" },
        { text = "Talent picks like Radiant Glory and Execution Sentence meaningfully reshape when your burst cooldowns line up — don't assume a fixed cadence without checking your own build" },
        { text = "Templar and Herald of the Sun are Retribution's two hero trees. Templar turns Wake of Ashes into the Hammer of Light finisher for 20 seconds after each cast; Herald of the Sun instead makes Wake of Ashes empower your next two spenders with Dawnlight. Separately, Templar Strikes and Crusading Strikes are a spec-tree choice: Templar Strikes makes Crusader Strike a two-press combo, while Crusading Strikes replaces your auto-attacks with Crusader Strikes — check which ones your loadout uses" },
    }},
  },
  cooldowns = {
    { spellID = 31884, text = "Avenging Wrath — core offensive cooldown, the whole rotation is sequenced around this window" },
    { spellID = 375576, text = "Divine Toll — extra Holy Power and multi-target damage, use it often rather than saving it" },
    { spellID = 343527, text = "Execution Sentence — an opening blast plus a hammer that lands 10 seconds later for a share of the damage you dealt meanwhile; cast it right before Wake of Ashes in your cooldown window" },
    { spellID = 255937, text = "Wake of Ashes — Holy Power reset and burst tool, weave into cooldown windows" },
    { text = "Hammer of Light — a Templar capstone finisher (3 Holy Power) that replaces Wake of Ashes for 20 seconds after you cast it, plus free casts from Light's Deliverance; spend it as soon as it's up",
      condition = "Templar hero talent only" },
    { spellID = 642, text = "Divine Shield — emergency defensive, breaks most damage" },
    { spellID = 1022, text = "Blessing of Protection — utility defensive cooldown for yourself or an ally" },
  },
  consumables = {
    { slot = "Flask", items = { 241322, 241324 }, text = "Flask of the Magisters for Mastery, this spec's top secondary; Flask of the Blood Knights if your gear already leans hard into Mastery and Haste is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 271887, 241308, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Mastery for this spec. If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 237371, 237369 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from Blacksmithing, if the oil is scarce." },
    { slot = "Weapon Enchant", items = { 273072, 244029, 244031 }, text = "Rite of the Hash'ey (12.1) procs +139 of a random secondary for 15s, and favours your highest one while you're above 80% health - the guides' pick for most physical specs, on both weapons if you dual-wield. Acuity of the Ren'dorei (+67 primary stat) is close behind; Arcane Mastery (+124 Mastery) if your sim puts Mastery well clear." },
    { slot = "Ring Enchants", items = { 243957, 243959 }, text = "Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; Zul'jin's Mastery (+29 Mastery) if your sim says otherwise - the difference is tiny." },
    { slot = "Chest Enchant", items = { 243977 }, text = "Mark of the Worldsoul (+50 primary stat)." },
    { slot = "Leg Enchant", items = { 244641, 244643 }, text = "Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides split between them." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240896, 240900, 240967 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Masterful Amethyst (+17 Mastery) in every other socket, or Flawless Quick Amethyst (+16 Mastery, +7 Haste) if you're balancing the two. With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "Tier set piece — the set bonus usually reshapes Holy Power flow more than a small item-level gap. Season 2's set bonus increases your Divine Purpose proc rate and boosts whichever Holy Power spender follows a proc — weave Divine Storm on single target or Final Verdict in AoE right after one." },
    { slot = "Neck", text = "Favor Haste to keep Holy Power generators and Templar's Verdict casts flowing" },
    { slot = "Back", text = "Secondary stats matching Haste and Crit outweigh a pure item-level chase" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece leaning Haste and Crit" },
    { slot = "Ring", text = "Haste or Crit rings depending on your current stat weights" },
    { slot = "Trinket", text = "One on-use Strength or damage trinket lined up with Avenging Wrath or Wake of Ashes" },
    { slot = "Trinket", text = "A passive stat-stick trinket for consistent damage between cooldowns" },
    { slot = "Weapon", text = "The highest item level two-hander available — weapon damage is a large share of Retribution's output" },
  },
  -- Matches SimC's MID2 default profile (profiles/MID2/MID2_Paladin_Retribution.simc,
  -- `midnight` branch) as checked on 2026-10-13 against 12.1.5 data.
  mplusLoadout = {
    string = "CYEAAAAAAAAAAAAAAAAAAAAAAAAAAAANbbzMzywMDAAAAAAjyYGmZsNmthZ2mxYMGmxCbDDYWmtZmZrBBAAsAYAwYGmBzYmZDYmZYMjBD",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CYEAzbn3egSOtoSwvPw1U1vTLAAAAAwoZbbmZWGzYGAAAAAAzUmlZYmx2Y2GmZbGjxYYGLsBgZZ2mZmtmZm2mZ2mBAsAYAwYmNgZMzshlZmZGGzYwA",
    source = "Blizzard Battle.net API, US region, 2026-10-27: top 50 current-season Mythic+ Retribution Paladins by best keystone level in the second week of patch 12.1.5 (period 1086), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick, tied with 1 other build (5/50, 10% each); 50/50 (100%) ran Herald of the Sun overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Don't let Holy Power sit at cap — spend it before you overflow and waste generation.",
    "Save Wake of Ashes to line up with your other offensive cooldowns when possible.",
    "Divine Storm outperforms Final Verdict once two or more targets are in melee range.",
    "Divine Toll is worth using on cooldown rather than hoarding — it both refills Holy Power and hits multiple targets.",
    "Keep Blessing of Protection and Lay on Hands available as raid utility, not just self-preservation.",
  },
})

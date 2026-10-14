local ADDON, ns = ...

-- SpecSage guide data: Death Knight (Blood 250, Frost 251, Unholy 252)
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
-- tuning this pass — EXCEPT Blood (250), Frost (251), and Unholy (252),
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
-- Unholy's overview/rotation/tips were also corrected this pass: they
-- described the old Festering Wound stacking debuff, which SimC's current
-- `midnight` branch profile and Blizzard's own Midnight Pre-Expansion
-- Content Update Notes both confirm is gone - Festering Strike now sets up
-- a player-side buff that makes the next 2-3 Scourge Strikes each summon a
-- Lesser Ghoul instead (SimC: buff.lesser_ghoul_ready gating Scourge
-- Strike; patch notes: "Festering Strike has been redesigned").
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

ns.GuideStore:RegisterSpec("DEATHKNIGHT", 250, {
  specName = "Blood",
  role = "TANK",
  overview = {
    "Blood Death Knight is a self-healing tank that plays around Death Strike, converting Runic Power and recent damage taken into a large heal, while Bone Shield charges provide flat physical damage reduction. It rewards proactive Death Strike timing over purely reactive healing.",
    "The core resources are Runes and Runic Power — Runes are spent on Marrowrend and Death's Caress (Bone Shield) and Heart Strike, Blood Boil runs on its own charges, and Runic Power builds toward Death Strike's healing component. Every enemy Blood Boil hits adds a stack of Hemostasis, a Death Strike damage/healing buff, and the Blood Plague it spreads lets your auto-attacks proc Crimson Scourge for a free Death and Decay, so Blood Boil and Death Strike timing matter just as much as topping up Bone Shield via Marrowrend.",
    "Blood brings excellent self-sustain, strong AoE threat through Death and Decay, and solid group utility (Anti-Magic Zone, grip), making it a reliable tank for both progression raiding and Mythic+ where consistent self-healing reduces external healer load. Its hero talents diverge more than most tank specs: Deathbringer layers Reaper's Mark's execute-style damage onto the core loop, while San'layn needs Bone Shield charges and its own resource banked before its Vampiric burst window opens.",
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
        { text = "Pre-pull: drop Death and Decay where you'll tank the pack and precast Raise Dead" },
        { spellID = 49576, text = "Death Grip to pull the pack in" },
        { spellID = 195182, text = "Marrowrend to establish roughly 5-6 Bone Shield stacks" },
        { spellID = 50842, text = "Blood Boil to apply Blood Plague and start building Hemostasis" },
        { spellID = 49028, text = "Dancing Rune Weapon, followed by Reaper's Mark on Deathbringer, for your first burst window" },
        { spellID = 49998, text = "Death Strike to kick off the survival loop" },
    }},
    { title = "Single Target", steps = {
        { spellID = 55233, text = "Vampiric Blood whenever it isn't already active — it's a rotational cooldown in current builds, not just an emergency button" },
        { spellID = 49998, text = "Death Strike before Runic Power caps, and sooner any time you need the heal or mitigation now" },
        { spellID = 43265, text = "Death and Decay kept under you, and immediately on a free Crimson Scourge proc" },
        { spellID = 439843, text = "Reaper's Mark on cooldown, after Dancing Rune Weapon",
          condition = "Deathbringer hero talent only" },
        { spellID = 195182, text = "Marrowrend (or Death's Caress when you're short on Runes) to keep Bone Shield at about 6 stacks and stop it expiring" },
        { spellID = 50842, text = "Blood Boil to keep Blood Plague up and build Hemostasis — don't let both charges sit full" },
        { spellID = 1263824, text = "Consumption (first empower rank) on cooldown, outside Dancing Rune Weapon on Deathbringer" },
        { spellID = 206930, text = "Heart Strike as your default Rune spender and Runic Power generator — under San'layn, press it immediately when it becomes Vampiric Strike" },
    }},
    { title = "AoE", steps = {
        { spellID = 50842, text = "Blood Boil moves up in priority — spreading Blood Plague and stacking Hemostasis across the pull outweighs its single-target value" },
        { spellID = 43265, text = "Death and Decay is worth dropping proactively in AoE, not just off a Crimson Scourge proc" },
        { spellID = 195182, text = "Marrowrend to maintain Bone Shield while multiple targets attack you" },
        { spellID = 206930, text = "Heart Strike hits a second nearby target — still your rune-spending filler between Blood Boil and Death and Decay" },
        { spellID = 1263824, text = "Consumption into the pack — it damages everything in front of you and its empower reduces your damage taken" },
        { spellID = 49998, text = "Death Strike on cooldown for healing during heavy incoming damage" },
        { text = "Prioritize Bone Shield uptime over pure damage during large trash pulls" },
    }},
    { title = "Mitigation", steps = {
        { spellID = 195181, text = "Bone Shield — never let this fall to zero charges" },
        { spellID = 49998, text = "Death Strike — time it for both healing and mitigation value" },
        { spellID = 48792, text = "Icebound Fortitude for the heaviest predicted damage spikes" },
        { spellID = 55233, text = "Vampiric Blood to amplify healing and effective health during a burst window" },
        { text = "Pool Runic Power slightly before a known damage spike so Death Strike lands at its strongest" },
        { text = "Minimize how many Runes go toward Bone Shield upkeep alone — that's the real Blood efficiency question, not maximizing Marrowrend casts" },
        { text = "Keep at least 3 Runes recharging when you can, and don't let Runic Power sit capped — Death Strike is your primary dump" },
    }},
    { title = "Opener Notes", steps = {
        { text = "Your hero talent choice changes what backs up Death Strike, and your opener: Deathbringer opens Dancing Rune Weapon together with Reaper's Mark for execute-style damage layered onto the core loop, while San'layn needs Bone Shield charges (and its own resource) banked before its Vampiric burst window opens — its opener and soul-spending loop diverge from Deathbringer's Reaper's Mark focus, so check your build rather than assuming a fixed extra step" },
    }},
  },
  cooldowns = {
    { spellID = 49028, text = "Dancing Rune Weapon — your core offensive cooldown and a 30% parry buff; on Deathbringer, cast it first and follow with Reaper's Mark rather than the other way round" },
    { spellID = 55233, text = "Vampiric Blood — 30% more maximum health and healing/absorbs received for 10 seconds; current builds use it close to on cooldown" },
    { spellID = 48792, text = "Icebound Fortitude — strong defensive cooldown for burst damage spikes" },
    { spellID = 1263824, text = "Consumption — empowered frontal hit on a 45-second cooldown that also reduces your damage taken while and after you empower it" },
    { spellID = 51052, text = "Anti-Magic Zone — raid-wide magic damage reduction utility" },
    { spellID = 61999, text = "Raise Ally — battle-resurrection utility on a personal cooldown" },
  },
  consumables = {
    { slot = "Flask", items = { 241324, 241322, 241320 }, text = "Flask of the Blood Knights for Haste, this spec's top secondary; Flask of the Magisters if your gear already leans hard into Haste and Mastery is the stat you're short on. Flask of Thalassian Resistance (Versatility) is the survivability pick for progression." },
    { slot = "Food", items = { 255846, 275265, 242275, 275259 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina), or the 12.1 Loa's Gathering, Feast of Knowledge or Amani Cornucopia (about +72 of your highest secondary, +108 Stamina) - for a tank the two families come out about even, so eat whichever is down. Personal: Royal Roast (+50 primary) or Hearty Venom-Spiced Cutlets / Hearty Puffer Plate (+65 highest secondary); only feasts give Stamina, and Hearty food persists through death." },
    { slot = "Potion", items = { 241288, 241308, 241286, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Haste for this spec. Light's Potential (+695 primary stat) is a hair behind and never picks the wrong stat. Light's Preservation (a 121k absorb for 30s) for the pull that actually threatens you. Skip Draught of Rampant Abandon - its void zone silences you where you stand, the last thing a tank positioning a pack needs. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 237371, 237369 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from Blacksmithing, if the oil is scarce. Runeforge rather than a weapon enchant: Rune of Sanguination for San'layn and for Deathbringer below about +10 keys, Rune of the Fallen Crusader for Deathbringer above that." },
    { slot = "Ring Enchants", items = { 244015, 243959 }, text = "Silvermoon's Alacrity (+29 Haste) on both rings; Zul'jin's Mastery (+29 Mastery) if you're topping up your second stat instead. Use the greater tier - the lesser one is +24." },
    { slot = "Chest Enchant", items = { 243977, 243947 }, text = "Mark of the Worldsoul (+50 primary stat); Mark of Nalorakk (+40 Strength, +116 Stamina) when you want the health instead." },
    { slot = "Leg Enchant", items = { 244641, 244643 }, text = "Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides split between them." },
    { slot = "Helm, Shoulders and Boots", items = { 244007, 244021, 243983, 243951, 243991, 243953 }, text = "Helm: Empowered Rune of Avoidance (+37) or Empowered Hex of Leeching (+55). Shoulders: Silvermoon's Mending (+166 Leech) or Amirdrassil's Grace (+111 Avoidance). Boots: Shaladrassil's Roots (+28 Leech, +232 Stamina) or Lynx's Dexterity (+19 Avoidance, +232 Stamina). Leech is the stronger sustain pick for a tank; Avoidance for dungeons heavy on unavoidable AoE. Speed (Empowered Blessing of Speed, Akil'zon's Swiftness, Farstrider's Hunt) is just as valid if you'd rather move faster." },
    { slot = "Gems", items = { 240983, 240888, 240892 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Quick Peridot (+17 Haste) in every other socket, or Flawless Masterful Peridot (+16 Haste, +7 Mastery) if you're balancing the two." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "Tier set piece — the set bonus usually matters more than a small item-level gap for a tank. Season 2's set bonus specifically: Death Strike builds a stacking Strength buff that empowers your next Marrowrend once it's stacked up, and the four-piece extends that same theme further." },
    { slot = "Neck", text = "Balance Stamina for a survivability buffer against Haste for Rune and Runic Power flow" },
    { slot = "Back", text = "Prioritize Stamina and secondary stats over a pure item-level trade" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece leaning Stamina and Haste" },
    { slot = "Ring", text = "Haste or Mastery rings depending on whether resource flow or Death Strike healing needs more support" },
    { slot = "Trinket", text = "One defensive on-use trinket saved for the fight's heaviest predicted damage window" },
    { slot = "Trinket", text = "One passive Stamina or avoidance trinket for a steady survivability floor" },
    { slot = "Weapon", text = "High item level weapons still carry meaningful damage for Blood — don't sacrifice too much Stamina chasing pure dps stats" },
  },
  mplusLoadout = {
    string = "CoPAAAAAAAAAAAAAAAAAAAAAAwYWmZmxMmZmhZZmZmmZxMjxMAAAAAmZmZGmZGzMjZAgZmZGAAADMwMW0YZDklBsBYGzAAAmZwgB",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CoPAkXBWxkyfx9CbGaHonEAhLxMzyMzwMmZmhZbmZmmZxMjZmxAAAAAmhZmZmZMzYAAzMzMzAAAYgBmxiGLbgsNgNAzYAAAmZAMA",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Blood Death Knights by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (4/50, 8%); 45/50 (90%) ran San'layn overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Keep Bone Shield charges above zero at all times — a lapsed Bone Shield is a big mitigation loss.",
    "Time Death Strike for when you actually need the heal, not purely on cooldown, when Runic Power allows pooling.",
    "Death and Decay is both a damage and threat tool — keep it under the pack during AoE pulls.",
    "Save Icebound Fortitude for known heavy-damage phases rather than reacting after the fact; Vampiric Blood is cheap enough to use near cooldown.",
    "Don't spend more Runes on Bone Shield upkeep than you need to — minimizing that spend, not maximizing Marrowrend casts, is the actual Blood optimization.",
    "Cast Death Strike before Hemostasis climbs past 5 stacks so you're not leaving free healing and damage on the table.",
    "On Deathbringer, open each window with Dancing Rune Weapon and follow with Reaper's Mark; on San'layn, keep Essence of the Blood Queen rolling with Vampiric Strike.",
  },
})

ns.GuideStore:RegisterSpec("DEATHKNIGHT", 251, {
  specName = "Frost",
  role = "DAMAGER",
  overview = {
    "Frost Death Knight is a dual-wield or two-handed melee spec built around Obliterate and Frost Strike, spending Runes and Runic Power while chasing Killing Machine procs that make your next Obliterate (or Frostscythe) a guaranteed critical strike. It plays as a burst-oriented spec with strong cooldown-driven damage windows.",
    "The core resources are Runes, spent on Obliterate below 3 targets and Frostscythe at 3+, and Runic Power, spent on Frost Strike (Glacial Advance instead in AoE). The defining mechanic is Killing Machine, a proc from your auto-attack crits that turns your next Obliterate into a guaranteed Frost-damage critical strike (or makes Frostscythe crit for four times normal damage), alongside Rime procs from Frost Strike and Glacial Advance that make your next Howling Blast cost no Runes and deal far more damage — spending both promptly, rather than banking them, is central to maximizing damage.",
    "Frost brings strong burst through Pillar of Frost — paired with Reaper's Mark on the Deathbringer hero talent — and, on some builds, Breath of Sindragosa, an 8-second breath that lasts longer the more Killing Machine and Rime procs you spend during it, making it a strong pick for both progression raiding, where Rider of the Apocalypse's straightforward single-target focus shines, and burst-heavy Mythic+, where Deathbringer's AoE tools take over.",
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
        { text = "Close the gap with your pre-cast, then open Pillar of Frost as you engage" },
        { spellID = 439843, text = "Macro Reaper's Mark into Pillar of Frost on the Deathbringer hero talent" },
        { text = "Frostwyrm's Fury inside that first Pillar of Frost window" },
        { spellID = 49020, text = "Obliterate, Frost Strike, Empower Rune Weapon, Obliterate — the standard double-Obliterate opener sequence" },
        { text = "On a Breath of Sindragosa build, cast Breath (60 Runic Power) once Pillar of Frost is up" },
    }},
    { title = "Single Target", steps = {
        { spellID = 51271, text = "Pillar of Frost on cooldown for a burst window, paired with Reaper's Mark on Deathbringer" },
        { spellID = 49020, text = "Obliterate at 2 Killing Machine stacks, or with 1 stack and 3+ Runes" },
        { spellID = 49184, text = "Howling Blast on a Rime proc — free and heavily empowered" },
        { spellID = 49143, text = "Frost Strike at 5 Razorice stacks with Shattering Blade, or when Runic Power is close to capping" },
        { spellID = 49020, text = "Obliterate with Killing Machine" },
        { spellID = 49143, text = "Frost Strike to spend Runic Power" },
        { spellID = 49020, text = "Obliterate as the Rune spender otherwise (on Deathbringer, pool a few Runes when Reaper's Mark is about to come up)" },
        { spellID = 47568, text = "Empower Rune Weapon (2 charges) when you're short on Runes or Killing Machine and below about 35 Runic Power — it grants Killing Machine and 40 Runic Power" },
        { text = "With Obliteration, Frost Strike and Howling Blast always grant Killing Machine during Pillar of Frost — fill with them instead of Rune-only Obliterates there" },
    }},
    { title = "AoE", steps = {
        { spellID = 49184, text = "Howling Blast to spread Frost Fever to the whole pack, and on every Rime proc" },
        { spellID = 207230, text = "Frostscythe instead of Obliterate at 3+ targets, especially with Killing Machine (4x crit damage)" },
        { spellID = 194913, text = "Glacial Advance as your Runic Power spender at 3+ targets (4+ with Deathly Blows); Frost Strike below that" },
        { spellID = 196770, text = "Remorseless Winter during your cooldowns once 2+ targets are up (Frozen Dominion also summons one when you cast Pillar of Frost)" },
        { spellID = 51271, text = "Pillar of Frost on cooldown during add waves" },
        { spellID = 47568, text = "Empower Rune Weapon to sustain resources through a long pull" },
        { text = "Reapply Frost Fever to new adds as they join the pull" },
    }},
    { title = "Opener Notes", steps = {
        { text = "Apply Frost Fever first, then pool for a Pillar of Frost burst window" },
        { text = "Keep an Empower Rune Weapon charge available going into Pillar of Frost, but don't let both charges sit capped while you wait" },
        { text = "Your hero talent changes which build you lean into: Rider of the Apocalypse is the more straightforward single-target/raid pick, while Deathbringer — with Reaper's Mark macroed into Pillar of Frost — is the stronger Mythic+/AoE pick, so check which one your loadout uses" },
    }},
  },
  cooldowns = {
    { spellID = 51271, text = "Pillar of Frost — core offensive cooldown, use on cooldown; Deathbringer players macro Reaper's Mark into it for the biggest combined window" },
    { spellID = 47568, text = "Empower Rune Weapon — 2 charges on a 30-second recharge, each granting Killing Machine and 40 Runic Power; don't let both charges sit" },
    { spellID = 279302, text = "Frostwyrm's Fury — 90-second burst cooldown; use it inside Pillar of Frost (late in the window on single target)" },
    { spellID = 1249658, text = "Breath of Sindragosa (talent) — 60 Runic Power, 8 seconds, 90-second cooldown, so it lines up with every second Pillar of Frost; spending Killing Machine/Rime while it's active extends the duration, so the standard priority holds throughout" },
    { spellID = 48792, text = "Icebound Fortitude — major defensive cooldown for burst damage spikes" },
    { spellID = 49039, text = "Lichborne — self-healing/CC-immunity utility cooldown" },
    { spellID = 61999, text = "Raise Ally — battle-resurrection utility on a personal cooldown" },
  },
  consumables = {
    { slot = "Flask", items = { 241326, 241322 }, text = "Flask of the Shattered Sun for Critical Strike, this spec's top secondary; Flask of the Magisters if your gear already leans hard into Critical Strike and Mastery is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 271887, 241308, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Critical Strike for this spec. If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 237371, 237369 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from Blacksmithing, if the oil is scarce. Runeforge rather than a weapon enchant: Rune of the Fallen Crusader on a two-hander (Rune of Razorice for two-handed Breath builds); dual-wield runs Rune of Razorice on the main hand and Fallen Crusader on the off hand." },
    { slot = "Ring Enchants", items = { 243957, 243987 }, text = "Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; Nature's Fury (+29 Critical Strike) if your sim says otherwise - the difference is tiny." },
    { slot = "Chest Enchant", items = { 243977 }, text = "Mark of the Worldsoul (+50 primary stat)." },
    { slot = "Leg Enchant", items = { 244641, 244643 }, text = "Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides split between them." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240904, 240908, 240967 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Deadly Garnet (+17 Critical Strike) in every other socket, or Flawless Masterful Garnet (+16 Critical Strike, +7 Mastery) if you're balancing the two. With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "Tier set piece — the set bonus usually matters more than a small item-level gap. Season 2's set bonus specifically boosts your Shadowfrost/Exterminate damage." },
    { slot = "Neck", text = "Favor Crit and Haste to feed Killing Machine procs" },
    { slot = "Back", text = "Secondary stats matching Crit and Haste outweigh a pure item-level chase" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece leaning Crit and Haste" },
    { slot = "Ring", text = "Crit or Haste rings depending on your current stat weights" },
    { slot = "Trinket", text = "One on-use Strength or damage trinket lined up with Pillar of Frost" },
    { slot = "Trinket", text = "A passive stat-stick trinket for consistent damage between cooldowns" },
    { slot = "Weapon", text = "Two matched one-handers for dual-wield, or the highest item level two-hander if running that build — check your talents before gearing" },
  },
  mplusLoadout = {
    string = "CsPAAAAAAAAAAAAAAAAAAAAAAMAGAADYYYMiBjhZGDmZmZmZmZmBAAAAAAAAgxYgBAsMMhMWwMjhBGAGmBAwA",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CsPAkXBWxkyfx9CbGaHonEAhLNAzMMjxYY2mZmZmZbmZ0MjxYYmxgZmZmZmZmZAAAAAAAAAYMbDMgFwywEyYBzMmZGYAYYmBgBD",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Frost Death Knights by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (5/50, 10%); 50/50 (100%) ran Deathbringer overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Spend Killing Machine procs promptly rather than banking multiple and risking an overwrite.",
    "Rime procs make your next Howling Blast free and instant — don't let a Rime proc sit unused.",
    "Keep Frost Fever active on any target you'll be attacking for more than a few seconds.",
    "Empower Rune Weapon has 2 charges — spend one whenever you're short on Runes or Killing Machine instead of holding both for Pillar of Frost.",
    "Howling Blast is a strong AoE opener even on cooldown-limited pulls — don't save it exclusively for big packs.",
    "Switch from Obliterate to Frostscythe once you've got 3+ targets — the AoE swap point moved up from the old two-target rule.",
    "On a Breath of Sindragosa build, keep spending Killing Machine and Rime as normal while it's active — that's what extends the Breath, not banking procs.",
    "Deathbringer players get more value macroing Reaper's Mark into Pillar of Frost than casting it on its own.",
  },
})

ns.GuideStore:RegisterSpec("DEATHKNIGHT", 252, {
  specName = "Unholy",
  role = "DAMAGER",
  overview = {
    "Unholy Death Knight is a plague- and minion-focused melee spec. Outbreak applies Dread Plague and Virulent Plague, Festering Strike corrupts your weapon so your next 2-3 Scourge Strikes each summon a Lesser Ghoul, and Putrefy, Army of the Dead and Dark Transformation turn those ghouls and your permanent pet into burst windows.",
    "The core resources are Runes, spent on Festering Strike, Scourge Strike, Putrefy and Soul Reaper, and Runic Power, spent on Death Coil (cheaper and stronger on a Sudden Doom proc) or Epidemic once three or more targets are up. Every Death Coil and Epidemic also extends your plagues and Dark Transformation. Festering Strike's Lesser Ghoul setup replaced the older stacking Festering Wound mechanic — this is a set-up-then-spend loop on your own buff rather than a debuff you build on the target — and with the Festering Scythe talent it follows up with a free frontal sweep that makes your plagues tick 35% faster for 25 seconds.",
    "Unholy brings strong burst through its cooldown windows, excellent sustained AoE via plagues, Putrefy and Epidemic, and useful pet-based utility, making it a strong pick for fights with add phases or sustained multi-target damage. San'layn turns some Scourge Strikes into Vampiric Strike, whose Essence of the Blood Queen haste buff is worth refreshing before it drops; Rider of the Apocalypse adds its horsemen on top of the core loop with no extra upkeep, making it the simpler of the two hero trees to pick up.",
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
        { spellID = 77575, text = "Outbreak to apply Dread Plague and Virulent Plague before you engage" },
        { spellID = 85948, text = "Festering Strike to bank Lesser Ghoul stacks (and start Festering Scythe's faster plagues)" },
        { spellID = 42650, text = "Army of the Dead, with trinkets, racial and potion" },
        { spellID = 1233448, text = "Dark Transformation while the army is out" },
        { spellID = 343294, text = "Soul Reaper early in Dark Transformation (Reaping lets you use it on any target then)" },
        { spellID = 1247378, text = "Putrefy during Dark Transformation" },
        { spellID = 47541, text = "Death Coil to spend Runic Power — each one also extends Dark Transformation" },
        { spellID = 1271974, text = "Blightfall just before your Soul Reaper debuff expires so its bonus isn't wasted" },
    }},
    { title = "Single Target", steps = {
        { spellID = 77575, text = "Outbreak whenever Dread Plague isn't ticking on anything" },
        { spellID = 85948, text = "Festering Strike to refresh Festering Scythe before its plague-haste runs out",
          condition = "Festering Scythe talent" },
        { spellID = 343294, text = "Soul Reaper early in Dark Transformation, or on a target below 35% health" },
        { spellID = 1247378, text = "Putrefy during Dark Transformation" },
        { spellID = 47541, text = "Death Coil on a Sudden Doom proc or when Runic Power is about to cap" },
        { spellID = 47541, text = "Death Coil during Dark Transformation or Forbidden Knowledge, otherwise whenever Army of the Dead isn't about to come back" },
        { spellID = 55090, text = "Scourge Strike whenever you're holding at least 1 Lesser Ghoul stack" },
        { spellID = 85948, text = "Festering Strike when you have no Lesser Ghoul stacks left" },
        { text = "Don't let a Sudden Doom proc go unused — Death Coil it away before it's overwritten" },
    }},
    { title = "AoE", steps = {
        { spellID = 85948, text = "Festering Strike to keep Festering Scythe's plague-haste up across the pack",
          condition = "Festering Scythe talent" },
        { spellID = 1247378, text = "Putrefy during Dark Transformation, or whenever it's at full charges — its ghoul explodes on nearby enemies" },
        { spellID = 343294, text = "Soul Reaper on the boss or priority target during Dark Transformation" },
        { spellID = 207317, text = "Epidemic instead of Death Coil at 3+ targets (4+ while Forbidden Knowledge is active)" },
        { spellID = 85948, text = "Festering Strike while you're under 3 Lesser Ghoul stacks" },
        { spellID = 55090, text = "Scourge Strike to spend stacks — it also spreads Virulent Plague to a nearby enemy" },
        { spellID = 43265, text = "Death and Decay at 3+ targets with Cycle of Death, to speed up Putrefy" },
        { text = "During Forbidden Knowledge (from Army of the Dead), Death Coil and Epidemic become Necrotic Coil (up to 3 foes) and Graveyard (every enemy with Virulent Plague)" },
    }},
    { title = "Opener Notes", steps = {
        { text = "Apply your plagues immediately, then Festering Strike to bank Lesser Ghoul stacks before your first burst window" },
        { text = "Time Army of the Dead with trinkets, then Dark Transformation once the army is out (or once Army is more than 30 seconds away)" },
        { text = "San'layn adds Vampiric Strike procs and the Essence of the Blood Queen haste buff — refresh it before it falls off — while Rider of the Apocalypse needs no extra setup and plays the core loop straight, making it the simpler hero tree to pick up" },
    }},
  },
  cooldowns = {
    { spellID = 1233448, text = "Dark Transformation — empowers your pet for 15 seconds, extended by each Death Coil and Epidemic; try to line its 45-second cooldown up with Army of the Dead's 90-second one so they periodically overlap" },
    { spellID = 42650, text = "Army of the Dead — raises an army of 8 Lesser Ghouls for 30 seconds that your Scourge Strikes command; align with burst windows" },
    { spellID = 343294, text = "Soul Reaper — execute below 35% health (any target during Dark Transformation with Reaping); your plagues and minions deal 20% more damage to the target for 8 seconds" },
    { spellID = 48792, text = "Icebound Fortitude — major defensive cooldown for burst damage spikes" },
    { spellID = 49039, text = "Lichborne — self-healing/CC-immunity utility cooldown" },
    { spellID = 61999, text = "Raise Ally — battle-resurrection utility on a personal cooldown" },
  },
  consumables = {
    { slot = "Flask", items = { 241326, 241322 }, text = "Flask of the Shattered Sun for Critical Strike, this spec's top secondary; Flask of the Magisters if your gear already leans hard into Critical Strike and Mastery is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 271887, 241308, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Critical Strike for this spec. If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734, 237371, 237369 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting); Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from Blacksmithing, if the oil is scarce. Runeforge rather than a weapon enchant: Rune of the Apocalypse." },
    { slot = "Ring Enchants", items = { 243957, 243987 }, text = "Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; Nature's Fury (+29 Critical Strike) if your sim says otherwise - the difference is tiny." },
    { slot = "Chest Enchant", items = { 243977 }, text = "Mark of the Worldsoul (+50 primary stat)." },
    { slot = "Leg Enchant", items = { 244641, 244643 }, text = "Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides split between them." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240904, 240908, 240967 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Deadly Garnet (+17 Critical Strike) in every other socket, or Flawless Masterful Garnet (+16 Critical Strike, +7 Mastery) if you're balancing the two. With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "Tier set piece — the set bonus usually matters more than a small item-level gap" },
    { slot = "Neck", text = "Favor Haste to speed up Rune regeneration and Runic Power flow" },
    { slot = "Back", text = "Secondary stats matching Haste and Mastery outweigh a pure item-level chase" },
    { slot = "Legs", text = "Another tier slot when possible; otherwise the highest item level piece leaning Haste and Mastery" },
    { slot = "Ring", text = "Haste or Mastery rings depending on your current stat weights" },
    { slot = "Trinket", text = "One on-use Strength or damage trinket lined up with Army of the Dead and Dark Transformation" },
    { slot = "Trinket", text = "A passive stat-stick trinket, ideally one that also benefits pet damage" },
    { slot = "Weapon", text = "The highest item level two-hander available — weapon damage still matters for Scourge Strike swings" },
  },
  mplusLoadout = {
    string = "CwPAAAAAAAAAAAAAAAAAAAAAAAwMjZMDDz2MzMTzmZmZMjBAAAAAAAgZGmZAwyMmZ2mZGjZAbmFDDZgZjhGLAYGAGzMjZAmZmxYA",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CwPAkXBWxkyfx9CbGaHonEAhLBYmhZMGDz2YmZa2mZGzMjBAAAAAAAg5BGDDAWmBzmZGzMjBGYGbassAYbiNMgZAMzMzMmBzMYMjB",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Unholy Death Knights by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (2/50, 4%); 46/50 (92%) ran San'layn overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Never let Virulent Plague fall off a target you'll keep attacking.",
    "Soul Reaper is an execute: below 35% health it's always available, and with Reaping Dark Transformation resets it and lets you use it on any target.",
    "Spend Lesser Ghoul stacks from Festering Strike with Scourge Strike promptly rather than sitting on them.",
    "Dark Transformation is worth using on cooldown in most fights — just let it wait for Army of the Dead when Army is about to come back.",
    "Line up your big summon-based cooldown with a known burst or add phase for maximum value.",
    "Spending Runic Power on Death Coil/Epidemic can proc Runic Corruption, which speeds up Rune regeneration, and extends your plagues — don't hoard Runic Power waiting for a 'better' moment.",
    "Don't let Putrefy sit at full charges outside Dark Transformation.",
    "Bank Lesser Ghoul stacks before Army of the Dead and Dark Transformation so the window has something to spend.",
  },
})

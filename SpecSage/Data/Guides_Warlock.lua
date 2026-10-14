local ADDON, ns = ...

-- SpecSage guide data: Warlock
-- 12.1.5 pass (2026-10-13): every spec's overview, rotation, cooldowns
-- and tips here were re-checked against SimC's `midnight` branch (client
-- data 12.1.5.70391: action priority lists, talent and spell tables),
-- spell tooltips and the 12.1.5 patch notes, and corrected where they had
-- drifted; every spellID resolves to the ability its step names. Where an
-- older note further down disagrees with a spec block, the block is current.
-- Affliction's and Demonology's `mplusLoadout` moved to the MID2 profiles
-- (patch 12.1.5). This supersedes the Malefic Grasp/Vilefiend notes below:
-- Drain Soul is Affliction's filler (Malefic Grasp only replaces Shadow Bolt
-- while Darkglare is out) and Summon Vilefiend is its own talent again.
-- Content targets Midnight (patch 12.1.5). Specs below with an `mplusLoadout`
-- field have that talent string (only) cross-checked against
-- SimulationCraft's public profiles (github.com/simulationcraft/simc,
-- GPLv3) as of patch 12.1; specs without one have no such reference.
-- Rotation/overview/tips/gear prose throughout this file is hand-authored
-- and was reviewed for Midnight ability changes, not derived from or
-- checked against SimC's APLs, and was not re-verified against current
-- tuning this pass — EXCEPT Affliction (265), Demonology (266), and Destruction (267),
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
-- two hero talent trees, for the one spec that didn't already have one
-- inline (Destruction). Affliction already carried a correct hero-tree
-- note and was left as-is. Demonology's note went through two rounds this
-- session: it originally read Diabolist/Soul Harvester (correct - it was
-- flagged as wrong on the assumption that Hellcaller must fill Demonology's
-- second slot by elimination from Affliction/Destruction's confirmed
-- pairs, and "corrected" to Diabolist/Hellcaller), then a later, more
-- careful audit found Demonology's own SimC profile dispatches to two
-- separate action lists - `diabolist` (talent.diabolic_ritual) and
-- `soulharvest` (talent.demonic_soul) - with zero Hellcaller references
-- anywhere in the file, confirming the original text was right and
-- restoring it. Lesson: check a spec's own file for its real branch names
-- before inferring a pairing from other specs' files.
-- Overview/rotation/tips for Affliction and Demonology were also corrected
-- this pass: Affliction's Malefic Rapture has zero references in SimC's
-- current profile (replaced by Unstable Affliction + the new Dark Harvest
-- as shard spenders, Malefic Grasp as filler); Demonology's Summon
-- Vilefiend is gone as a separate cast (folded into Call Dreadstalkers
-- itself - "Vilefiend added to dog cast" per a Blizzard forum post) and
-- Grimoire: Felguard was replaced by Grimoire: Imp Lord / Grimoire: Fel
-- Ravager.
-- A later pass (2026-09-01) enriched all three specs' overview/rotation/
-- cooldowns/tips with opener sequences, single-target-vs-AoE priority
-- nuances, cooldown-syncing notes, and hero-talent-caused differences,
-- drawing on guide sites (Wowhead/Icy Veins/Maxroll/Method/Boostmatch),
-- now a permitted source per repo policy (see
-- .claude/skills/specsage-refresh/SKILL.md). All prose was rewritten in
-- SpecSage's own words rather than copied from any source, and every
-- spellID added was verified against Wowhead rather than guessed (one
-- casualty of that verification: Vile Taint, which the compendium this
-- pass drew from still listed for Affliction AoE, was confirmed removed
-- in patch 12.0.0 and was NOT added back). This pass built on top of the
-- already-corrected Dark Harvest/Vilefiend/Grimoire mechanics above and
-- did not touch Demonology's verified Diabolist/Soul Harvester pairing.
-- raidLoadout follow-up (2026-09-02): checked SimC's `midnight` branch
-- fresh - still exactly one profile per spec for Demonology and
-- Destruction, no genuinely separate raid build to source a distinct field
-- from. Enriched both specs' hero-talent notes instead with the source
-- material's raid-vs-M+ framing (informational text, no opaque talent
-- string needed or risked).
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

-- Affliction ---------------------------------------------------------------
ns.GuideStore:RegisterSpec("WARLOCK", 265, {
  specName = "Affliction",
  role = "DAMAGER",
  overview = {
    "Affliction Warlock is a damage-over-time spec that ramps up over the course of a fight, layering Agony, Corruption (Wither under Hellcaller) and Unstable Affliction into a strong sustained-damage profile, with Haunt, Dark Harvest and Summon Darkglare for periodic burst.",
    "The core resource is Soul Shards, generated by Agony ticks and spent on Unstable Affliction (several can overlap on one target) or Seed of Corruption in AoE — Malefic Rapture no longer exists. Dark Harvest is a 1-minute channel that drains every target carrying your damage-over-time effects. Drain Soul (talent) replaces Shadow Bolt as your filler, and while Darkglare is out your Shadow Bolt becomes Malefic Grasp, which makes your other dots tick extra damage. Agony's damage starts low and climbs over its duration, and refreshing it keeps the current level, so keep it rolling.",
    "Bring Affliction when a fight rewards consistent damage over time, has multiple targets to dot up, or has a long fight length that lets your damage ramp — it's less ideal for very short burst-only encounters.",
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
        { spellID = 48181, text = "Pre-cast Haunt so it lands as the pull starts (Seed of Corruption instead if several enemies are coming)" },
        { spellID = 980, text = "Agony to start it ramping as early as possible" },
        { spellID = 172, text = "Corruption (Wither under Hellcaller) to add a second dot" },
        { spellID = 1257052, text = "Dark Harvest once both dots are rolling" },
        { spellID = 430014, text = "Malevolence to open the burst",
          condition = "Hellcaller hero talent only" },
        { spellID = 205180, text = "Summon Darkglare with potions/trinkets/racials for an early burst window" },
        { spellID = 1261149, text = "Malefic Grasp (your Shadow Bolt while Darkglare is out) and Unstable Affliction through the Darkglare window" },
        { text = "Opener Notes: Affliction splits along the Soul Harvester and Hellcaller hero trees — both keep the dot-then-spend loop above; Hellcaller swaps Corruption for Wither, adds Malevolence and holds Unstable Affliction for its burst windows" },
    }},
    { title = "Single Target", steps = {
        { spellID = 48181, text = "Haunt on cooldown" },
        { spellID = 980, text = "Keep Agony active at all times — refresh it with under 3 seconds left" },
        { spellID = 172, text = "Keep Corruption (or Wither under Hellcaller) active at all times — refresh with under 3 seconds left" },
        { spellID = 1257052, text = "Dark Harvest on cooldown, as long as Agony and Corruption will outlast the channel",
          condition = "Soul Harvester hero talent: cast it below 3 Soul Shards" },
        { spellID = 430014, text = "Malevolence on cooldown",
          condition = "Hellcaller hero talent only" },
        { spellID = 205180, text = "Summon Darkglare on cooldown",
          condition = "Soul Harvester hero talent: once Dark Harvest is on cooldown" },
        { spellID = 1261149, text = "Malefic Grasp while Darkglare is out; outside it, Drain Soul (or Shadow Bolt) at 2 Nightfall stacks" },
        { spellID = 1259790, text = "Unstable Affliction to spend Soul Shards whenever you have one",
          condition = "Hellcaller hero talent: hold shards for Darkglare or Malevolence, unless you're at 5" },
        { spellID = 198590, text = "Drain Soul as your filler (Shadow Bolt if you didn't talent it)" },
    }},
    { title = "AoE", steps = {
        { spellID = 48181, text = "Haunt on cooldown" },
        { spellID = 27243, text = "Seed of Corruption to spread Corruption (or Wither) across the pack" },
        { spellID = 1257052, text = "Dark Harvest — it hits every target carrying your dots, so cast it once the pack is dotted" },
        { spellID = 980, text = "Agony on each target, lowest duration first, prioritizing ones that will live longest" },
        { spellID = 205180, text = "Summon Darkglare (after Malevolence under Hellcaller)" },
        { spellID = 27243, text = "Seed of Corruption as your shard spender with Sow the Seeds or 6+ targets; otherwise Unstable Affliction" },
        { text = "In Mythic+, 'shard snipe' a target that's about to die with Drain Soul — it gives a Soul Shard if the target dies during the channel" },
        { text = "Keep re-dotting targets as they come into range rather than tunneling one target" },
    }},
  },
  cooldowns = {
    { spellID = 205180, text = "Summon Darkglare — 2-minute cooldown; boosts Agony, Corruption and Unstable Affliction by 20% for 20 seconds and turns Shadow Bolt into Malefic Grasp" },
    { spellID = 48181, text = "Haunt — 15-second cooldown that raises your damage on the target by 16%; it resets if the target dies, so weave it in frequently rather than saving it" },
    { spellID = 1257052, text = "Dark Harvest — 1-minute channel that drains every dotted target; with Cull the Weak, each Unstable Affliction or Seed of Corruption shortens its cooldown" },
    { spellID = 430014, text = "Malevolence (Hellcaller hero talent) — burst cooldown, line up with Darkglare",
      condition = "Hellcaller hero talent only" },
    { spellID = 108416, text = "Dark Pact — defensive cooldown, absorbs damage using health as a resource" },
    { spellID = 104773, text = "Unending Resolve — major defensive, use against heavy incoming damage" },
    { text = "Mortal Coil / Howl of Terror — utility CC, situational" },
  },
  consumables = {
    { slot = "Flask", items = { 241324, 241326 }, text = "Flask of the Blood Knights for Haste, this spec's top secondary; Flask of the Shattered Sun if your gear already leans hard into Haste and Critical Strike is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 271887, 241308, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Haste for this spec. If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting)." },
    { slot = "Weapon Enchant", items = { 244029, 243973, 273072 }, text = "Acuity of the Ren'dorei procs +67 primary stat for 15s; Berserker's Rage procs +124 Haste instead and wins if your stat weights put Haste well clear of the rest. Rite of the Hash'ey (12.1: +139 of a random secondary, favouring your highest above 80% health) is the third option." },
    { slot = "Ring Enchants", items = { 243957, 244015 }, text = "Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; Silvermoon's Alacrity (+29 Haste) if your sim says otherwise - the difference is tiny." },
    { slot = "Chest Enchant", items = { 243977 }, text = "Mark of the Worldsoul (+50 primary stat)." },
    { slot = "Leg Enchant", items = { 240133 }, text = "Sunfire Silk Spellthread (+41 Intellect, +115 Stamina)." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240888, 240890, 240967 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Quick Peridot (+17 Haste) in every other socket, or Flawless Deadly Peridot (+16 Haste, +7 Critical Strike) if you're balancing the two. With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "One of your tier-set slots — the four-piece bonus is worth chasing since it reinforces your dot-and-shard-spender damage engine. Season 2's set bonus boosts Corruption and Agony, and rewards a heavier Unstable Affliction build (each active UA adds a stacking damage bonus, and Seed of Corruption now applies a partial UA too) at four pieces." },
    { slot = "Chest", text = "A large stat budget and often your other tier piece — lean into Haste first to smooth dot ticks and shard generation" },
    { slot = "Neck", text = "Usually has a socket — fill it and prioritize Haste, then Mastery, over Critical Strike" },
    { slot = "Ring", text = "No set bonus tying you down — use rings to round out Haste and Mastery wherever your gear is thin" },
    { slot = "Trinket", text = "One on-use trinket timed with Summon Darkglare so its burst lands while your dots are fully stacked" },
    { slot = "Trinket", text = "A passive Intellect or secondary-stat trinket to keep sustained dot damage strong the rest of the fight" },
    { slot = "Weapon", text = "Take the highest weapon damage one-hand-plus-off-hand or staff available — type matters far less than item level for a dot-based caster" },
    { slot = "Off-hand", text = "A caster off-hand that adds Haste or Mastery keeps your dot ramp and shard generation smooth" },
  },
  mplusLoadout = {
    string = "CkQAAAAAAAAAAAAAAAAAAAAAAwMzMzoZhhZmZmlBAAYmZZWmZml5BGAwCMwsY0YGQmNwyAAAwMAAwMDYmZMYGmZMzMGMzMzAAmBG",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1.5",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CkQAMrNP5kak+EBqLfUa3dMm+yMjZGNbmx2MzYWGAAwMzsMLmZ2GDAM2WGYATwMsFYYbAAAYGAAAzMjZMzsNGzYMzMzYYmZGAgBMA",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Affliction Warlocks by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (6/50, 12%); 43/50 (86%) ran Soul Harvester overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Never let Agony or Corruption fall off early — dropped dots and re-ramping cost significant damage.",
    "Make sure Agony and Corruption will outlast Dark Harvest's 3-second channel before casting it — it only hits targets carrying your dots.",
    "Pre-dot targets that are about to become active (adds spawning soon) if you can safely reach them.",
    "Plan Darkglare around when your dots will be at strong uptime across the most targets — Soul Rot and Phantom Singularity are no longer in Affliction's tree.",
    "Spend shards on Unstable Affliction rather than hoarding them — with Cull the Weak it also shortens Dark Harvest's cooldown, so it pays for itself twice.",
    "In Mythic+, snipe a dying add with Drain Soul to bank a shard before it's lost for good.",
  },
})

-- Demonology -----------------------------------------------------------
ns.GuideStore:RegisterSpec("WARLOCK", 266, {
  specName = "Demonology",
  role = "DAMAGER",
  overview = {
    "Demonology Warlock is a pet-and-cooldown spec built around summoning waves of demons and popping Demonic Tyrant on top of them for a big burst window, repeated on its 1-minute cooldown throughout the fight.",
    "The core loop is generating Soul Shards from Demonbolt/Shadow Bolt and spending them on Hand of Gul'dan (Wild Imps) and Call Dreadstalkers (which also brings a Vilefiend if you take the Summon Vilefiend talent) to build up a pack of demons, then adding Grimoire: Imp Lord or Grimoire: Fel Ravager and Summon Doomguard before Summon Demonic Tyrant. Tyrant's damage grows by 10% for every Wild Imp and Dreadstalker you have out, and it empowers your active demons.",
    "Bring Demonology when you want a highly cooldown-driven, pet-management playstyle with big periodic burst windows and strong pad-the-numbers cleave from empowered demons.",
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
        { spellID = 264130, text = "Power Siphon a few seconds before pulling, if talented" },
        { spellID = 686, text = "Pre-cast Shadow Bolt (or Demonbolt if you skipped Power Siphon) timed to land right as combat starts" },
        { spellID = 1276452, text = "Grimoire: Imp Lord or Grimoire: Fel Ravager (talent-dependent) to add another pet before Tyrant" },
        { spellID = 1276672, text = "Summon Doomguard" },
        { spellID = 104316, text = "Call Dreadstalkers to build your demon pack" },
        { spellID = 265187, text = "Summon Demonic Tyrant once your demons are out, with potion and racials" },
        { text = "Opener Notes: Demonology splits along the Diabolist and Soul Harvester hero trees (not Hellcaller, which pairs with Affliction and Destruction instead) — check which one your loadout uses. The simulated priority keeps one list for Diabolist and one for Soul Harvester; the order is nearly the same, but Diabolist waits for 5 Soul Shards before Tyrant and spends Ruination and Infernal Bolt procs, while Soul Harvester presses Tyrant on cooldown. Diabolist is the simulation default and what nearly every top Mythic+ Demonology player runs — re-sim if you're unsure" },
    }},
    { title = "Single Target", steps = {
        { spellID = 264130, text = "Power Siphon when you have 1 or fewer Demonic Core stacks" },
        { spellID = 1276452, text = "Grimoire: Imp Lord / Grimoire: Fel Ravager on cooldown" },
        { spellID = 1276672, text = "Summon Doomguard on cooldown — consuming Demonic Core shortens its cooldown" },
        { spellID = 104316, text = "Call Dreadstalkers on cooldown",
          condition = "Reign of Tyranny talent: hold it so it's up for Tyrant — skip it when Tyrant is 12 to 20 seconds away" },
        { spellID = 265187, text = "Summon Demonic Tyrant at 5 Soul Shards",
          condition = "Soul Harvester hero talent: on cooldown, no shard requirement" },
        { spellID = 196277, text = "Implosion at 6+ Wild Imps if you have To Hell and Back" },
        { spellID = 428522, text = "Ruination whenever a Pit Lord grants it",
          condition = "Diabolist hero talent only" },
        { spellID = 105174, text = "Hand of Gul'dan at 3+ Soul Shards when Tyrant is more than 5 seconds away, or at 5 shards" },
        { spellID = 434506, text = "Infernal Bolt below 3 Soul Shards when it replaces Shadow Bolt",
          condition = "Diabolist hero talent only" },
        { spellID = 264178, text = "Demonbolt on Demonic Core below 4 shards — onto a target without Doom first if you play Doom" },
        { spellID = 686, text = "Shadow Bolt as filler when nothing else applies" },
    }},
    { title = "AoE", steps = {
        { spellID = 105174, text = "Hand of Gul'dan to flood the pack with Wild Imps and Shadowflame damage" },
        { spellID = 104316, text = "Call Dreadstalkers as normal — your demons cleave naturally" },
        { spellID = 196277, text = "Implosion at 6+ Wild Imps on 3+ targets to detonate the pack for burst AoE" },
        { text = "Keep pets attacking the highest-priority target so cleave lands on real threats" },
        { spellID = 265187, text = "Time Demonic Tyrant for when the full pack is engaged on the pull" },
    }},
  },
  cooldowns = {
    { spellID = 265187, text = "Summon Demonic Tyrant — main burst window (1-minute cooldown), use once your demon pack is built and pool shards for it, always with Dreadstalkers already active" },
    { spellID = 1276452, text = "Grimoire: Imp Lord or Grimoire: Fel Ravager — 2-minute extra pet, use on cooldown ahead of a Tyrant window" },
    { spellID = 1276672, text = "Summon Doomguard — 2-minute pet cooldown, use on cooldown alongside your other pet summons" },
    { spellID = 108416, text = "Dark Pact — defensive cooldown, absorbs damage using health as a resource" },
    { spellID = 104773, text = "Unending Resolve — major defensive, use against heavy incoming damage" },
  },
  consumables = {
    { slot = "Flask", items = { 241324, 241326 }, text = "Flask of the Blood Knights for Haste, this spec's top secondary; Flask of the Shattered Sun if your gear already leans hard into Haste and Critical Strike is the stat you're short on." },
    { slot = "Food", items = { 255846, 242275, 242747, 275265 }, text = "Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists through death, which is what you want in Mythic+." },
    { slot = "Potion", items = { 241288, 271887, 241308, 271884 }, text = "Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is the default - it only works if your highest secondary is the one you want, Haste for this spec. If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade." },
    { slot = "Weapon Oil", items = { 243734 }, text = "Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 Critical Strike and Haste for 2 hours, from Enchanting)." },
    { slot = "Weapon Enchant", items = { 244029, 243973, 273072 }, text = "Acuity of the Ren'dorei procs +67 primary stat for 15s; Berserker's Rage procs +124 Haste instead and wins if your stat weights put Haste well clear of the rest. Rite of the Hash'ey (12.1: +139 of a random secondary, favouring your highest above 80% health) is the third option." },
    { slot = "Ring Enchants", items = { 243957, 244015 }, text = "Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; Silvermoon's Alacrity (+29 Haste) if your sim says otherwise - the difference is tiny." },
    { slot = "Chest Enchant", items = { 243977 }, text = "Mark of the Worldsoul (+50 primary stat)." },
    { slot = "Leg Enchant", items = { 240133 }, text = "Sunfire Silk Spellthread (+41 Intellect, +115 Stamina)." },
    { slot = "Helm, Shoulders and Boots", items = { 243981, 243963, 244009, 244007, 243991, 243953 }, text = "None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed (+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight you keep dying on." },
    { slot = "Gems", items = { 240983, 240888, 240890, 240967 }, text = "One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds only give +23. Then Flawless Quick Peridot (+17 Haste) in every other socket, or Flawless Deadly Peridot (+16 Haste, +7 Critical Strike) if you're balancing the two. With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour." },
    { slot = "Augment Rune", items = { 259085, 243191 }, text = "Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from the K'aresh Trust at renown 18) is the free stopgap the rest of the time." },
  },
  gear = {
    { slot = "Head", text = "One of your tier-set slots — the four-piece bonus is built around your demon-summon burst, so it's usually worth prioritizing over raw item level. Season 2's set bonus boosts Wild Imp damage and Implosion, with the four-piece giving depleted Wild Imps a chance to Implode on their own — exact numbers have moved in hotfixes, check your current tooltip." },
    { slot = "Chest", text = "A big stat budget and likely your other tier piece — lean Haste first to shorten the ramp into each Demonic Tyrant window" },
    { slot = "Neck", text = "Usually carries a socket — fill it and favor Haste, then Mastery" },
    { slot = "Ring", text = "No set bonus attached — use rings to top up Haste and Mastery wherever you're light" },
    { slot = "Trinket", text = "One on-use trinket timed to pop with Summon Demonic Tyrant for maximum overlap with your empowered demons" },
    { slot = "Trinket", text = "A passive secondary-stat trinket to hold your damage floor between Tyrant windows" },
    { slot = "Weapon", text = "Take the highest weapon damage staff or one-hand-plus-off-hand you can equip — pet damage scales off your stats, not weapon type" },
    { slot = "Off-hand", text = "A caster off-hand that reinforces Haste helps you rebuild your demon pack faster between cooldowns" },
  },
  mplusLoadout = {
    string = "CoQAAAAAAAAAAAAAAAAAAAAAAYmxMzoZjZ2mZGzyAAAAAAAAGzYYBGYb0CNsYMGLzyMzMmBAmZMzMzMDgZGzAAAYMzMjhhlZMgB",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1.5",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CoQAMrNP5kak+EBqLfUa3dMm+yMMzoZzMz2MzMzyAAAAAAAAGzYYBGYb0CNsYMzYZ2mZmxMAwMjZmxMDwYGzYDAAMmZmxwwyMGwA",
    source = "Blizzard Battle.net API, US region, 2026-10-13: top 50 current-season Mythic+ Demonology Warlocks by best keystone level in the first week of patch 12.1.5 (period 1085), sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick (5/50, 10%); 50/50 (100%) ran Diabolist overall.",
    patch = "12.1.5",
    sampleSize = 50,
  },
  tips = {
    "Pool Soul Shards and demon summons before Demonic Tyrant so the empower window has as many demons as possible.",
    "Don't let Wild Imps sit unused if running Implosion — detonate them at 6 on multiple targets rather than banking indefinitely.",
    "Keep track of Call Dreadstalkers' cooldown so it's ready to refill your pack (Dreadstalkers, plus Vilefiend if talented) before each Tyrant.",
    "Reposition pets onto priority adds quickly — cleave damage is wasted on a dead or low-value target.",
    "Soul Shards cap at 5 — spend on Hand of Gul'dan (or Ruination) before you're forced to waste shard generation by sitting at the cap.",
  },
})

-- Destruction ----------------------------------------------------------
ns.GuideStore:RegisterSpec("WARLOCK", 267, {
  specName = "Destruction",
  role = "DAMAGER",
  overview = {
    "Destruction Warlock is a Soul Shard spender spec that alternates between building shards with Incinerate, Conflagrate and Soul Fire and unloading them on Chaos Bolt for large single hits, with Immolate (Wither under Hellcaller) providing a steady damage-over-time backbone.",
    "The core resource is Soul Shards (0-5): Incinerate, Conflagrate, Soul Fire and your Immolate ticks generate them, while Chaos Bolt (2 shards) and Rain of Fire (3 shards) spend them. Conflagrate also grants Backdraft, which speeds up your next Incinerate or Chaos Bolt. Havoc marks a second target for 15 seconds so your single-target spells hit it too, and Shadowburn is your execute below 20% health.",
    "Bring Destruction when you want a spec with strong scheduled burst via Chaos Bolt during cooldown windows, solid cleave via Havoc/Rain of Fire, and a relatively straightforward shard-management rotation.",
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
        { spellID = 6353, text = "Pre-cast Soul Fire so it lands as the pull starts (Cataclysm first if 2+ enemies are coming)" },
        { spellID = 152108, text = "Cataclysm to apply Immolate" },
        { spellID = 17962, text = "Conflagrate to trigger Backdraft and generate shards" },
        { spellID = 1122, text = "Summon Infernal alongside potion, trinkets and racials to open your first burst window" },
        { spellID = 430014, text = "Malevolence right after Infernal",
          condition = "Hellcaller hero talent only" },
        { spellID = 116858, text = "Chaos Bolt with your banked shards inside the Infernal window" },
    }},
    { title = "Single Target", steps = {
        { spellID = 6353, text = "Soul Fire on cooldown while you're at 4 or fewer shards — it also applies Immolate" },
        { spellID = 17962, text = "Conflagrate at 2 charges" },
        { spellID = 116858, text = "Chaos Bolt whenever Demonic Art is active, or just before your Diabolic Ritual runs out, while the target is above 20% health",
          condition = "Diabolist hero talent only" },
        { spellID = 17962, text = "Conflagrate when you have no Backdraft and aren't about to overcap shards" },
        { spellID = 1122, text = "Summon Infernal on cooldown" },
        { spellID = 430014, text = "Malevolence on cooldown",
          condition = "Hellcaller hero talent only" },
        { spellID = 17877, text = "Shadowburn below 20% health (earlier with Fiendish Cruelty or Conflagration of Chaos)" },
        { spellID = 348, text = "Refresh Immolate in its last 30% unless Soul Fire or Cataclysm will refresh it first (Hellcaller's Wither replaces it as the maintained dot on that hero tree)" },
        { spellID = 428522, text = "Ruination whenever a Pit Lord grants it",
          condition = "Diabolist hero talent only" },
        { spellID = 152108, text = "Cataclysm on cooldown if you have Lake of Fire" },
        { spellID = 116858, text = "Chaos Bolt at 4+ shards, or any time Malevolence or your Infernal is up",
          condition = "Hellcaller hero talent; Diabolist spends it while a Diabolic Ritual has more than 4 seconds left" },
        { spellID = 434506, text = "Infernal Bolt at 3 or fewer shards when it replaces Incinerate",
          condition = "Diabolist hero talent only" },
        { spellID = 29722, text = "Incinerate as your lowest-priority filler, used only when nothing better is available" },
    }},
    { title = "AoE", steps = {
        { spellID = 1122, text = "Summon Infernal (then Malevolence under Hellcaller) as the pack is engaged" },
        { spellID = 5740, text = "Rain of Fire as your main spender at 3+ targets (4+ under Hellcaller), as soon as you have the shards" },
        { spellID = 116858, text = "Chaos Bolt instead of Rain of Fire on 2 targets (up to 3 under Hellcaller)" },
        { spellID = 80240, text = "Havoc on a second target whenever Summon Infernal isn't ready, to duplicate your single-target damage onto it" },
        { spellID = 152108, text = "Cataclysm to apply Immolate across the pull" },
        { spellID = 17962, text = "Conflagrate on a target whose Immolate is still healthy — with Roaring Blaze it spreads that Immolate to up to 3 nearby enemies" },
        { spellID = 17877, text = "Shadowburn on the lowest-health target with Fiendish Cruelty or Conflagration of Chaos" },
        { spellID = 6353, text = "Soul Fire below 4 shards" },
        { spellID = 29722, text = "Incinerate to fill" },
    }},
    { title = "Opener Notes", steps = {
        { text = "Destruction's two hero talent trees are Diabolist (also Demonology's) and Hellcaller (the simulation default; also Affliction's) — check which one your loadout uses. SimC runs one shared single-target list with a handful of hero-specific lines (Diabolist spends Chaos Bolt around Demonic Art and its rituals and adds Ruination and Infernal Bolt; Hellcaller swaps Immolate for Wither and pools shards for Malevolence and Infernal), plus a separate AoE list per tree. As a starting point, Hellcaller suits raid single-target/2-target/spread fights, while Diabolist's demon-and-cleave kit suits Mythic+ better — re-sim if you're unsure" },
    }},
  },
  cooldowns = {
    { spellID = 1122, text = "Summon Infernal — 2-minute major burst cooldown; potion, trinkets and racials go with it" },
    { spellID = 430014, text = "Malevolence (Hellcaller hero talent) — burst cooldown, pool shards for it",
      condition = "Hellcaller hero talent only" },
    { spellID = 6353, text = "Soul Fire (talent) — 45-second hard-hitting shard generator that also applies Immolate" },
    { spellID = 80240, text = "Havoc — 30-second cooldown that duplicates your damage onto a second target; use it proactively rather than saving it for pure single-target fights" },
    { spellID = 116858, text = "Chaos Bolt — spend banked shards during cooldown windows for maximum burst value" },
    { spellID = 108416, text = "Dark Pact — defensive cooldown, absorbs damage using health as a resource" },
    { spellID = 104773, text = "Unending Resolve — major defensive, use against heavy incoming damage" },
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
    { slot = "Head", text = "One of your tier-set slots — the four-piece bonus meaningfully strengthens your Chaos Bolt burst windows, so it's usually worth the set piece. Season 2's set bonus boosts Incinerate and gives it a chance to evoke Echo of Sargeras, with the four-piece making Echo of Sargeras targets take extra damage from your other spells briefly." },
    { slot = "Chest", text = "A large stat budget and often your other tier piece — push Critical Strike first since it directly scales your biggest hits" },
    { slot = "Neck", text = "Usually has a socket — prioritize Critical Strike, then Haste for more shard generation" },
    { slot = "Ring", text = "No set bonus tying you down — use rings to round out Critical Strike and Haste" },
    { slot = "Trinket", text = "One on-use trinket timed with Summon Infernal so its burst overlaps your Chaos Bolt spam" },
    { slot = "Trinket", text = "A passive stat-stick trinket to keep Incinerate/Immolate damage solid between cooldown windows" },
    { slot = "Weapon", text = "Take the highest weapon damage staff or one-hand-plus-off-hand — item level matters far more than weapon type here" },
    { slot = "Off-hand", text = "A caster off-hand leaning Critical Strike keeps your burst windows hitting as hard as possible" },
  },
  mplusLoadout = {
    string = "CsQAAAAAAAAAAAAAAAAAAAAAAwMmZGNLMzmZmZWmFzMzsYMWMDAAmZGzMziNYgZxoxMAmtYjBAAGDM2AAmZwYGzYDAAwMzMAAMGG",
    source = "SimulationCraft default profile (credit, not endorsement of 'best')",
    patch = "12.1",
  },
  -- Live top-players pull (DESIGN.md's v1.4 section), NOT SimC - see this
  -- file's header for the methodology. The `source` line below carries the
  -- pull's date, sample size, the plurality share and the hero-talent
  -- split; one exact code rarely commands a majority, since flex-point
  -- choices vary, so the share is reported as it is.
  mplusMetaLoadout = {
    string = "CsQAMrNP5kak+EBqLfUa3dMm+yMMzoZzMz2MzYWmNzMzsYmZZZMAAYGjZmZDMmxwCZgthFaswAAAjBDAwMDwYGzMbAAAmZmBAAzwA",
    source = "Blizzard Battle.net API, US region, 2026-10-04: top 50 current-season Mythic+ Destruction Warlocks by best keystone level, sampled across all 83 US connected realms' leaderboards. This exact build was the plurality pick, tied with 1 other build (3/50, 6% each); 45/50 (90%) ran Diabolist overall.",
    patch = "12.1",
    sampleSize = 50,
  },
  tips = {
    "Never let Immolate fall off the target — its ticks are a steady source of Soul Shards.",
    "Don't cap Soul Shards; if you're at 5 shards and generating more, spend one before it's wasted.",
    "Save a Backdraft-fueled Conflagrate burst for right before Chaos Bolt spam during a cooldown window.",
    "Use Havoc proactively on cleave/2-target windows rather than only on pure single-target fights.",
    "Don't let Conflagrate sit at 2 charges — spend one before a third generates and overflows.",
    "On a big pull, use Cataclysm to apply Immolate everywhere at once (and let Roaring Blaze's Conflagrate spread it further, if talented) rather than casting it target by target.",
  },
})

#!/usr/bin/env python3
"""Regenerates every spec's `consumables` block in SpecSage/Data/Guides_*.lua.

Each spec's block is derived from three things the guide already states -
its role, its stat priority, and its class (which fixes the primary stat) -
against a catalogue of the current expansion's consumables, enchants and
gems. Every item in the catalogue was looked up on Wowhead's tooltip
endpoint (name, item ID, tooltip effect) on the date in CATALOGUE_CHECKED;
the tooltips are what the stat mappings below are built from. Crafted items
are the rank-2 (top quality, item level 295 / enchant scrolls 85) ID - the
rank-1 ID is always one lower and has smaller numbers, so check the item
level when adding one. Gems are the Flawless tier. The role picks (diamond,
weapon and ring enchant, potion, food) follow the Icy Veins 12.1 / 12.1.5
spec pages, read on CATALOGUE_CHECKED.

Run from the repo root:  python3 tools/gen_consumables.py
Then:                    lua tests/run.lua

Entry shape written into the guides:
    { slot = "Flask", items = { 241324, 241322 }, text = "..." }
`items` are the item IDs the Tome draws as hoverable chips under the line
(UI/Tome.lua RenderConsumables), in the order given; `text` is the prose.
"""

import re
import sys
from pathlib import Path

CATALOGUE_CHECKED = "2026-10-13"   # live patch 12.1.5 (Midnight Season 2)
ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "SpecSage" / "Data"

# ---------------------------------------------------------------------------
# Catalogue: name -> item ID. Wowhead tooltip endpoint, CATALOGUE_CHECKED.
# ---------------------------------------------------------------------------
ITEMS = {
    # Flasks (Alchemy, rank 2: +165 of one secondary for 1h, persists through death)
    "Flask of the Blood Knights": 241324,          # Haste
    "Flask of the Magisters": 241322,              # Mastery
    "Flask of the Shattered Sun": 241326,          # Critical Strike
    "Flask of Thalassian Resistance": 241320,      # Versatility
    # Combat potions (rank 2)
    "Potion of Recklessness": 241288,              # +1725 highest secondary, -232 lowest, 30s
    "Light's Potential": 241308,                   # +695 primary stat, 30s
    "Draught of Rampant Abandon": 241292,          # +774 primary, 30s, but may drop a void zone at your feet
    "Liquid Luster": 271887,                       # 12.1: +420 Versatility every 6s for 30s, stacks to 5
    "Alluring Nostrum": 271890,                    # 12.1: Shadow damage procs to 5 targets, stacking 15% slow
    "Light's Preservation": 241286,                # 121,433 absorb shield, 30s
    "Lightfused Mana Potion": 241300,              # 26,200 mana
    "Potion of Devoured Dreams": 241294,           # 39,300 mana over 10s, defenceless while channelling
    "Concentrated Silvermoon Health Potion": 271884,  # 12.1: 421,200 health
    # Food
    "Harandar Celebration": 255846,                # feast: 98 Stamina + 50 primary
    "Silvermoon Parade": 255845,                   # feast: 98 Stamina + 50 primary
    "Hearty Harandar Celebration": 266996,         # same, persists through death
    "Loa's Gathering": 275265,                     # 12.1 feast: 108 Stamina + 72 highest secondary
    "Feast of Knowledge": 275266,                  # 12.1 feast: same
    "Amani Cornucopia": 275264,                    # 12.1 feast: same
    "Hearty Loa's Gathering": 275268,              # 12.1 feast: same, persists through death
    "Royal Roast": 242275,                         # 50 primary
    "Impossibly Royal Roast": 255847,              # 50 primary (vegetarian)
    "Hearty Royal Roast": 242747,                  # 50 primary, persists through death
    "Hearty Venom-Spiced Cutlets": 275259,         # 12.1: 65 highest secondary, persists through death
    "Hearty Puffer Plate": 275262,                 # 12.1: 65 highest secondary, persists through death
    "Hearty Null and Void Plate": 242754,          # 58 Haste, persists through death
    "Hearty Sun-Seared Lumifin": 242755,           # 58 Critical Strike, persists through death
    "Hearty Warped Wise Wings": 242757,            # 58 Mastery, persists through death
    "Hearty Void-Kissed Fish Rolls": 242756,       # 58 Versatility, persists through death
    # Weapon oils (Enchanting) and stones (Blacksmithing), 2h
    "Thalassian Phoenix Oil": 243734,              # +16 Critical Strike and Haste
    "Oil of Dawn": 243736,                         # healing procs a 1,879 absorb
    "Smuggler's Enchanted Edge": 243738,           # damage procs 1,253 Arcane
    "Refulgent Whetstone": 237371,                 # +15 Attack Power, bladed
    "Refulgent Weightstone": 237369,               # +15 Attack Power, blunt
    # Augment runes (one augment-rune buff at a time)
    "Void-Touched Augment Rune": 259085,           # +25 primary, 1h, does not persist through death
    "Ethereal Augment Rune": 243191,               # +6 primary, reusable (1 min cd), K'aresh Trust renown 18
    # Weapon enchants (proc, 15s)
    "Enchant Weapon - Rite of the Hash'ey": 273072,       # 12.1: +139 random secondary, favours highest above 80% health
    "Enchant Weapon - Acuity of the Ren'dorei": 244029,   # +67 primary stat
    "Enchant Weapon - Berserker's Rage": 243973,          # +124 Haste
    "Enchant Weapon - Arcane Mastery": 244031,            # +124 Mastery
    "Enchant Weapon - Jan'alai's Precision": 243971,      # +124 Critical Strike
    "Enchant Weapon - Worldsoul Tenacity": 244001,        # +124 Versatility
    "Enchant Weapon - Worldsoul Aegis": 243999,           # 14,039 barrier when damaged, erupts
    "Enchant Weapon - Worldsoul Cradle": 243997,          # healing procs a 12,525 barrier on the target
    # Ring enchants (greater tier, +29)
    "Enchant Ring - Eyes of the Eagle": 243957,           # +2% critical strike effectiveness
    "Enchant Ring - Silvermoon's Alacrity": 244015,       # Haste
    "Enchant Ring - Zul'jin's Mastery": 243959,           # Mastery
    "Enchant Ring - Nature's Fury": 243987,               # Critical Strike
    "Enchant Ring - Silvermoon's Tenacity": 244017,       # Versatility
    # Chest
    "Enchant Chest - Mark of the Worldsoul": 243977,      # +50 primary
    "Enchant Chest - Mark of Nalorakk": 243947,           # +40 Strength, +116 Stamina
    "Enchant Chest - Mark of the Rootwarden": 243975,     # +40 Agility, +15 Speed
    "Enchant Chest - Mark of the Magister": 244003,       # +40 Intellect, +5% mana
    # Legs
    "Sunfire Silk Spellthread": 240133,                   # +41 Intellect, +115 Stamina
    "Arcanoweave Spellthread": 240155,                    # +41 Intellect, +4% mana
    "Forest Hunter's Armor Kit": 244641,                  # +41 Agility/Strength, +115 Stamina
    "Blood Knight's Armor Kit": 244643,                   # +41 Agility/Strength, +27 armor
    # Helm (the Empowered tier; the plain one is about two thirds of it) / shoulders / boots
    "Enchant Helm - Empowered Blessing of Speed": 243981,   # +22 Speed
    "Enchant Helm - Empowered Rune of Avoidance": 244007,   # +37 Avoidance
    "Enchant Helm - Empowered Hex of Leeching": 243951,     # +55 Leech
    "Enchant Shoulders - Akil'zon's Swiftness": 243963,   # +65 Speed
    "Enchant Shoulders - Silvermoon's Mending": 244021,   # +166 Leech
    "Enchant Shoulders - Amirdrassil's Grace": 243991,    # +111 Avoidance
    "Enchant Boots - Farstrider's Hunt": 244009,          # +11 Speed, +232 Stamina
    "Enchant Boots - Shaladrassil's Roots": 243983,       # +28 Leech, +232 Stamina
    "Enchant Boots - Lynx's Dexterity": 243953,           # +19 Avoidance, +232 Stamina
    # Gems
    "Indecipherable Eversong Diamond": 240983,  # +32 primary, no other effect
    "Powerful Eversong Diamond": 240967,   # +23 primary, +0.15% crit effectiveness per unique gem colour
    "Stoic Eversong Diamond": 240971,      # +23 primary, +13 armor
    "Telluric Eversong Diamond": 240969,   # +23 primary, +1% mana per unique gem colour
    "Flawless Quick Peridot": 240888,      # +17 Haste
    "Flawless Deadly Garnet": 240904,      # +17 Critical Strike
    "Flawless Masterful Amethyst": 240896, # +17 Mastery
    "Flawless Versatile Lapis": 240912,    # +17 Versatility
    "Flawless Deadly Peridot": 240890,     # +16 Haste, +7 Crit
    "Flawless Masterful Peridot": 240892,  # +16 Haste, +7 Mastery
    "Flawless Versatile Peridot": 240894,  # +16 Haste, +7 Vers
    "Flawless Quick Garnet": 240906,       # +16 Crit, +7 Haste
    "Flawless Masterful Garnet": 240908,   # +16 Crit, +7 Mastery
    "Flawless Versatile Garnet": 240910,   # +16 Crit, +7 Vers
    "Flawless Quick Amethyst": 240900,     # +16 Mastery, +7 Haste
    "Flawless Deadly Amethyst": 240898,    # +16 Mastery, +7 Crit
    "Flawless Versatile Amethyst": 240902, # +16 Mastery, +7 Vers
    "Flawless Quick Lapis": 240916,        # +16 Vers, +7 Haste
    "Flawless Deadly Lapis": 240914,       # +16 Vers, +7 Crit
    "Flawless Masterful Lapis": 240918,    # +16 Vers, +7 Mastery
}

STAT_LABEL = {"haste": "Haste", "crit": "Critical Strike", "mastery": "Mastery", "versatility": "Versatility"}
FLASK = {"haste": "Flask of the Blood Knights", "mastery": "Flask of the Magisters",
         "crit": "Flask of the Shattered Sun", "versatility": "Flask of Thalassian Resistance"}
WEAPON_ENCHANT = {"haste": "Enchant Weapon - Berserker's Rage", "mastery": "Enchant Weapon - Arcane Mastery",
                  "crit": "Enchant Weapon - Jan'alai's Precision", "versatility": "Enchant Weapon - Worldsoul Tenacity"}
RING_ENCHANT = {"haste": "Enchant Ring - Silvermoon's Alacrity", "mastery": "Enchant Ring - Zul'jin's Mastery",
                "crit": "Enchant Ring - Nature's Fury", "versatility": "Enchant Ring - Silvermoon's Tenacity"}
GEM_BASE = {"haste": "Peridot", "crit": "Garnet", "mastery": "Amethyst", "versatility": "Lapis"}
GEM_ADJ = {"haste": "Quick", "crit": "Deadly", "mastery": "Masterful", "versatility": "Versatile"}

# Which primary stat a class (or, where it splits, a spec) uses.
PRIMARY_BY_CLASS = {
    "WARRIOR": "STR", "PALADIN": "STR", "DEATHKNIGHT": "STR",
    "HUNTER": "AGI", "ROGUE": "AGI", "DEMONHUNTER": "AGI",
    "MAGE": "INT", "PRIEST": "INT", "WARLOCK": "INT", "EVOKER": "INT",
}
PRIMARY_BY_SPEC = {
    # Druid
    102: "INT", 103: "AGI", 104: "AGI", 105: "INT",
    # Monk
    268: "AGI", 269: "AGI", 270: "INT",
    # Shaman
    262: "INT", 263: "AGI", 264: "INT",
}


# Death Knights runeforge their weapon instead of using an enchanting scroll
# (Icy Veins 12.1 Blood / Frost / Unholy pages). Runeforges are spells, not
# items, so this is prose on the Weapon Oil kind rather than chips.
RUNEFORGE = {
    250: ("Runeforge rather than a weapon enchant: Rune of Sanguination for San'layn and for Deathbringer below "
          "about +10 keys, Rune of the Fallen Crusader for Deathbringer above that."),
    251: ("Runeforge rather than a weapon enchant: Rune of the Fallen Crusader on a two-hander (Rune of Razorice "
          "for two-handed Breath builds); dual-wield runs Rune of Razorice on the main hand and Fallen Crusader on "
          "the off hand."),
    252: "Runeforge rather than a weapon enchant: Rune of the Apocalypse.",
}

def secondaries(stats):
    return [s for s in stats if s in STAT_LABEL]


def lua_str(text):
    return '"' + text.replace('\\', '\\\\').replace('"', '\\"') + '"'


def entry(slot, names, text):
    ids = ", ".join(str(ITEMS[n]) for n in names)
    return f'    {{ slot = {lua_str(slot)}, items = {{ {ids} }}, text = {lua_str(text)} }},'


def build(cls, spec_id, role, stats):
    primary = PRIMARY_BY_SPEC.get(spec_id) or PRIMARY_BY_CLASS[cls]
    sec = secondaries(stats)
    top, second = sec[0], sec[1]
    top_l, second_l = STAT_LABEL[top], STAT_LABEL[second]
    tank, healer = role == "TANK", role == "HEALER"
    physical = primary in ("STR", "AGI")
    lines = []

    # Flask
    flasks = [FLASK[top], FLASK[second]]
    text = (f"{FLASK[top]} for {top_l}, this spec's top secondary; {FLASK[second]} if your gear already "
            f"leans hard into {top_l} and {second_l} is the stat you're short on.")
    if tank and top != "versatility":
        flasks.append(FLASK["versatility"])
        text += " Flask of Thalassian Resistance (Versatility) is the survivability pick for progression."
    lines.append(entry("Flask", flasks, text))

    # Food. Icy Veins' 12.1 pages put the primary-stat feasts and Royal
    # Roast first for damage and healing specs (Resto Druid: "the secondary
    # stat food options are not viable"); the tank pages call the two
    # families even, so tanks get both.
    if tank:
        foods = ["Harandar Celebration", "Loa's Gathering", "Royal Roast", "Hearty Venom-Spiced Cutlets"]
        text = ("Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina), or the 12.1 "
                "Loa's Gathering, Feast of Knowledge or Amani Cornucopia (about +72 of your highest secondary, +108 "
                "Stamina) - for a tank the two families come out about even, so eat whichever is down. Personal: Royal "
                "Roast (+50 primary) or Hearty Venom-Spiced Cutlets / Hearty Puffer Plate (+65 highest secondary); "
                "only feasts give Stamina, and Hearty food persists through death.")
    else:
        foods = ["Harandar Celebration", "Royal Roast", "Hearty Royal Roast", "Loa's Gathering"]
        text = ("Raid feasts: Harandar Celebration or Silvermoon Parade (+50 primary stat, +98 Stamina) - primary stat "
                "is the stronger food buff this season. Loa's Gathering, Feast of Knowledge or Amani Cornucopia (12.1: "
                "about +72 of your highest secondary, +108 Stamina) are the fallback if that's what's down. Personal: "
                "Royal Roast or Impossibly Royal Roast (+50 primary); Hearty Royal Roast is the same buff but persists "
                "through death, which is what you want in Mythic+.")
    lines.append(entry("Food", foods, text))

    # Potion. Recklessness is the default on every Icy Veins 12.1 page read
    # (DPS, both tanks, Resto Druid: "mana potions are very weak currently").
    reck = (f"Potion of Recklessness (+1725 of your highest secondary for 30s, at the cost of 232 of your lowest) is "
            f"the default - it only works if your highest secondary is the one you want, {top_l} for this spec")
    if healer:
        pots = ["Potion of Recklessness", "Lightfused Mana Potion", "Potion of Devoured Dreams", "Concentrated Silvermoon Health Potion"]
        text = (reck + ", so use it with your healing cooldowns. Mana potions are weak this season: Lightfused Mana "
                "Potion (26,200 mana) is the safe one, Potion of Devoured Dreams gives more over 10s but leaves you "
                "defenceless while it channels. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade.")
    elif tank:
        pots = ["Potion of Recklessness", "Light's Potential", "Light's Preservation", "Concentrated Silvermoon Health Potion"]
        text = (reck + ". Light's Potential (+695 primary stat) is a hair behind and never picks the wrong stat. Light's "
                "Preservation (a 121k absorb for 30s) for the pull that actually threatens you. Skip Draught of "
                "Rampant Abandon - its void zone silences you where you stand, the last thing a tank positioning a "
                "pack needs. Always carry Concentrated Silvermoon Health Potions - 421k, the 12.1 upgrade.")
    else:
        pots = ["Potion of Recklessness", "Liquid Luster", "Light's Potential", "Concentrated Silvermoon Health Potion"]
        text = (reck + ". If your gear makes it pick another stat, Liquid Luster (12.1: +420 Versatility every 6s, "
                "stacking to 5 over 30s) has no downside and suits a long burst window; Light's Potential (+695 "
                "primary) is the simple alternative. Draught of Rampant Abandon (+774 primary) is stronger on paper, "
                "but its void zone pacifies you and a GCD or two inside it erases the gain. Always carry Concentrated "
                "Silvermoon Health Potions - 421k, the 12.1 upgrade.")
    lines.append(entry("Potion", pots, text))

    # Weapon oil / stone (and, for Death Knights, the runeforge, which takes
    # the place of an enchanting scroll - so they get no Weapon Enchant kind)
    oils = ["Thalassian Phoenix Oil"]
    text = ("Thalassian Phoenix Oil - the current tier's weapon oil and the guides' default for all content (+16 "
            "Critical Strike and Haste for 2 hours, from Enchanting)")
    if healer:
        oils.append("Oil of Dawn")
        text += "; Oil of Dawn instead if you'd rather your heals proc a small absorb on their target"
    if physical:
        oils += ["Refulgent Whetstone", "Refulgent Weightstone"]
        text += ("; Refulgent Whetstone (bladed) or Refulgent Weightstone (blunt) gives +15 Attack Power instead, from "
                 "Blacksmithing, if the oil is scarce")
    text += "."
    if cls == "DEATHKNIGHT":
        text += " " + RUNEFORGE[spec_id]
    lines.append(entry("Weapon Oil", oils, text))

    # Weapon enchant
    if cls != "DEATHKNIGHT":
        if physical:
            wep = ["Enchant Weapon - Rite of the Hash'ey", "Enchant Weapon - Acuity of the Ren'dorei", WEAPON_ENCHANT[top]]
            text = ("Rite of the Hash'ey (12.1) procs +139 of a random secondary for 15s, and favours your highest one "
                    "while you're above 80% health - the guides' pick for most physical specs, on both weapons if you "
                    "dual-wield. Acuity of the Ren'dorei (+67 primary stat) is close behind; "
                    f"{WEAPON_ENCHANT[top].split(' - ')[1]} (+124 {top_l}) if your sim puts {top_l} well clear.")
        else:
            wep = ["Enchant Weapon - Acuity of the Ren'dorei", WEAPON_ENCHANT[top], "Enchant Weapon - Rite of the Hash'ey"]
            text = (f"Acuity of the Ren'dorei procs +67 primary stat for 15s; {WEAPON_ENCHANT[top].split(' - ')[1]} procs "
                    f"+124 {top_l} instead and wins if your stat weights put {top_l} well clear of the rest. Rite of "
                    "the Hash'ey (12.1: +139 of a random secondary, favouring your highest above 80% health) is the "
                    "third option.")
        if tank:
            wep.append("Enchant Weapon - Worldsoul Aegis")
            text += " Worldsoul Aegis (a 14k barrier that erupts when it breaks) is the defensive alternative."
        if healer:
            wep.append("Enchant Weapon - Worldsoul Cradle")
            text += " Worldsoul Cradle (heals proc a 12.5k barrier on the target) is the healer-flavoured alternative."
        lines.append(entry("Weapon Enchant", wep, text))

    # Rings. Icy Veins' damage pages take Eyes of the Eagle; tanks and
    # healers take their stat.
    if tank or healer:
        rings = [RING_ENCHANT[top], RING_ENCHANT[second]]
        text = (f"{RING_ENCHANT[top].split(' - ')[1]} (+29 {top_l}) on both rings; {RING_ENCHANT[second].split(' - ')[1]} "
                f"(+29 {second_l}) if you're topping up your second stat instead. Use the greater tier - the lesser one is +24.")
    else:
        rings = ["Enchant Ring - Eyes of the Eagle", RING_ENCHANT[top]]
        text = (f"Eyes of the Eagle (+2% critical strike effectiveness) on both rings is the guides' damage pick; "
                f"{RING_ENCHANT[top].split(' - ')[1]} (+29 {top_l}) if your sim says otherwise - the difference is tiny.")
    lines.append(entry("Ring Enchants", rings, text))

    # Chest
    chest = ["Enchant Chest - Mark of the Worldsoul"]
    text = "Mark of the Worldsoul (+50 primary stat)"
    if tank and primary == "STR":
        chest.append("Enchant Chest - Mark of Nalorakk")
        text += "; Mark of Nalorakk (+40 Strength, +116 Stamina) when you want the health instead"
    elif primary == "AGI":
        chest.append("Enchant Chest - Mark of the Rootwarden")
        text += "; Mark of the Rootwarden (+40 Agility, +15 Speed) trades a little stat for movement"
    elif healer:
        chest.append("Enchant Chest - Mark of the Magister")
        text += "; Mark of the Magister (+40 Intellect, +5% mana) if mana is what runs out"
    text += "."
    lines.append(entry("Chest Enchant", chest, text))

    # Legs
    if primary == "INT":
        legs = ["Sunfire Silk Spellthread"]
        text = "Sunfire Silk Spellthread (+41 Intellect, +115 Stamina)"
        if healer:
            legs.append("Arcanoweave Spellthread")
            text += "; Arcanoweave Spellthread (+41 Intellect, +4% mana) if you'd rather have the mana than the health"
    else:
        legs = ["Forest Hunter's Armor Kit", "Blood Knight's Armor Kit"]
        text = ("Forest Hunter's Armor Kit (+41 primary stat, +115 Stamina) or Blood Knight's Armor Kit (+41 primary "
                "stat, +27 armor) - the same offensive stat either way, so it's health or armour; the 12.1 guides "
                "split between them")
    text += "."
    lines.append(entry("Leg Enchant", legs, text))

    # Helm / shoulders / boots. The Empowered helm enchants (12.0 recipes)
    # are what the 12.1 guides list; their outdoor riders don't matter in
    # instances, the bigger stat does.
    if tank:
        misc = ["Enchant Helm - Empowered Rune of Avoidance", "Enchant Shoulders - Silvermoon's Mending", "Enchant Boots - Shaladrassil's Roots",
                "Enchant Helm - Empowered Hex of Leeching", "Enchant Shoulders - Amirdrassil's Grace", "Enchant Boots - Lynx's Dexterity"]
        text = ("Helm: Empowered Rune of Avoidance (+37) or Empowered Hex of Leeching (+55). Shoulders: Silvermoon's "
                "Mending (+166 Leech) or Amirdrassil's Grace (+111 Avoidance). Boots: Shaladrassil's Roots (+28 Leech, "
                "+232 Stamina) or Lynx's Dexterity (+19 Avoidance, +232 Stamina). Leech is the stronger sustain pick "
                "for a tank; Avoidance for dungeons heavy on unavoidable AoE. Speed (Empowered Blessing of Speed, "
                "Akil'zon's Swiftness, Farstrider's Hunt) is just as valid if you'd rather move faster.")
    else:
        misc = ["Enchant Helm - Empowered Blessing of Speed", "Enchant Shoulders - Akil'zon's Swiftness", "Enchant Boots - Farstrider's Hunt",
                "Enchant Helm - Empowered Rune of Avoidance", "Enchant Shoulders - Amirdrassil's Grace", "Enchant Boots - Lynx's Dexterity"]
        text = ("None of these touch your throughput, so it's personal preference. Speed: Empowered Blessing of Speed "
                "(+22), Akil'zon's Swiftness (+65), Farstrider's Hunt (+11, +232 Stamina). Avoidance, to survive the "
                "bigger hits: Empowered Rune of Avoidance (+37), Amirdrassil's Grace (+111), Lynx's Dexterity (+19, +232 "
                "Stamina). Leech (Empowered Hex of Leeching, Silvermoon's Mending, Shaladrassil's Roots) for a fight "
                "you keep dying on.")
    lines.append(entry("Helm, Shoulders and Boots", misc, text))

    # Gems. Indecipherable (+32 primary, nothing else) is the default on
    # every Icy Veins 12.1 page read; Powerful only pays with enough sockets
    # to run all four colours.
    single = f"Flawless {GEM_ADJ[top]} {GEM_BASE[top]}"
    hybrid = f"Flawless {GEM_ADJ[second]} {GEM_BASE[top]}"
    text = (f"One Indecipherable Eversong Diamond (+32 primary stat) - it's unique-equipped and the other diamonds "
            f"only give +23. Then {single} (+17 {top_l}) in every other socket, or {hybrid} (+16 {top_l}, +7 "
            f"{second_l}) if you're balancing the two.")
    gems = ["Indecipherable Eversong Diamond", single, hybrid]
    if not tank and not healer:
        gems.append("Powerful Eversong Diamond")
        text += (" With five or more sockets, Powerful Eversong Diamond (+23 primary stat, +0.15% critical strike "
                 "effectiveness per unique gem colour) can edge ahead if you socket one gem of each colour.")
    lines.append(entry("Gems", gems, text))

    # Augment rune. The War Within's Crystallized (+6, from 733 before the
    # 12.0 squish) and Soulgorged runes still work at 90 but share the one
    # augment-rune buff and are a quarter of Void-Touched, so they're out.
    runes = ["Void-Touched Augment Rune", "Ethereal Augment Rune"]
    text = ("Void-Touched Augment Rune (+25 primary stat for 1 hour; it does not persist through death) is the only "
            "Midnight rune - use it for progression pulls and high keys. Ethereal Augment Rune (+6, reusable, from "
            "the K'aresh Trust at renown 18) is the free stopgap the rest of the time.")
    lines.append(entry("Augment Rune", runes, text))

    return "  consumables = {\n" + "\n".join(lines) + "\n  },"


SPEC_RE = re.compile(r'RegisterSpec\("([A-Z]+)", (\d+), \{')
BLOCK_RE = re.compile(r'\n  consumables = \{\n.*?\n  \},', re.S)


def process(path):
    src = path.read_text()
    out, pos, count = [], 0, 0
    specs = list(SPEC_RE.finditer(src))
    for i, m in enumerate(specs):
        end = specs[i + 1].start() if i + 1 < len(specs) else len(src)
        chunk = src[m.start():end]
        cls, spec_id = m.group(1), int(m.group(2))
        role = re.search(r'\n  role = "([A-Z]+)"', chunk).group(1)
        stats = re.findall(r'\{ stat = "(\w+)"', chunk.split("rotation = {")[0])
        block = build(cls, spec_id, role, stats)
        new_chunk, n = BLOCK_RE.subn("\n" + block, chunk, count=1)
        if n != 1:
            sys.exit(f"{path.name}: spec {spec_id} has no consumables block to replace")
        out.append(src[pos:m.start()])
        out.append(new_chunk)
        pos = end
        count += 1
    out.append(src[pos:])
    path.write_text("".join(out))
    return count


def main():
    total = 0
    for path in sorted(DATA.glob("Guides_*.lua")):
        total += process(path)
    print(f"rewrote consumables for {total} specs")
    # The Tome's Data/Consumables.lua item table, so chip fallbacks and the
    # prose scanner know every name the guides now use.
    lines = [f'    ["{n}"] = {i},' for n, i in sorted(ITEMS.items(), key=lambda kv: kv[0].lower())]
    table = "ns.ConsumableItems = {\n" + "\n".join(lines) + "\n}"
    cons = (DATA / "Consumables.lua")
    src = cons.read_text()
    new_src, n = re.subn(r"ns\.ConsumableItems = \{\n.*?\n\}", lambda _: table, src, count=1, flags=re.S)
    if n != 1:
        sys.exit("Data/Consumables.lua: could not find ns.ConsumableItems to rewrite")
    cons.write_text(new_src)
    print(f"wrote {len(ITEMS)} items to Data/Consumables.lua")


if __name__ == "__main__":
    main()

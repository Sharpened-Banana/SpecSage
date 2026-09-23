"""Wowhead guide data for the generators, read from tools/wowhead_dump.json.

The dump is produced in a browser by tools/wowhead_harvest.js (Wowhead's guide
pages are client-rendered and refuse non-browser clients, so no Python fetch
can replace that step); this module turns the raw per-spec records into the
same shapes the Icy Veins parsers produce, resolving item names and equip
slots through tools/wowhead_items.py where the harvested tables omit them.
"""
import html
import json
import os
import re

from wowhead_items import lookup

DUMP = os.path.join(os.path.dirname(__file__), "wowhead_dump.json")

# Wowhead's own slot column labels -> Data/API.lua's 14-slot vocabulary.
# Anything not listed falls back to the item's tooltip slot.
SLOT_LABELS = {
    "head": "Head", "helm": "Head", "neck": "Neck", "shoulder": "Shoulder", "shoulders": "Shoulder",
    "back": "Back", "cape": "Back", "cloak": "Back", "chest": "Chest", "wrist": "Wrist", "bracers": "Wrist",
    "hands": "Hands", "gloves": "Hands", "waist": "Waist", "belt": "Waist", "legs": "Legs", "feet": "Feet",
    "boots": "Feet", "ring": "Ring", "trinket": "Trinket", "trinkets": "Trinket", "weapon": "Weapon",
    "weapons": "Weapon", "main hand": "Weapon", "main-hand": "Weapon", "mainhand": "Weapon",
    "1h weapon": "Weapon", "2h weapon": "Weapon", "off hand": "Off-hand", "off-hand": "Off-hand",
    "offhand": "Off-hand", "shield": "Off-hand",
}

TRINKET_SOURCES = {"raid": "Raid", "dungeon": "Dungeon", "delves": "Delves", "crafting": "Profession"}


def load():
    """The harvested dump. A missing or unreadable dump is an error, not an
    empty result: an empty dump makes every generator emit guide-less data,
    which strip_sites.py then empties out completely."""
    return {int(k): v for k, v in json.load(open(DUMP)).items()}


def _all_item_ids(dump):
    ids = set()
    for rec in dump.values():
        for table in rec.get("bis", []):
            for row in table["rows"]:
                ids.add(row[1])
        for tier in rec.get("tiers", []):
            for item_id, _ in tier["items"]:
                ids.add(item_id)
    return sorted(ids)


_items = None


def items(dump):
    """{ itemID: { name, slot, quality } } for every item the dump mentions (cached)."""
    global _items
    if _items is None:
        _items = lookup(_all_item_ids(dump))
    return _items


def _slot(label, info):
    """(slot, qualifier) for a table's slot label. The qualifier is the text a
    guide puts in brackets to tell alternatives apart - "Trinket (Raid)" /
    "Trinket (M+)", "Weapon (2h)" / "Weapons (1h)" - and must survive, or two
    alternatives for one slot read as an impossible third trinket."""
    label = label or ""
    m = re.search(r"\(([^)]*)\)\s*$", label)
    qualifier = m.group(1).strip() if m else ""
    key = re.sub(r"\s*\(.*\)$", "", label).strip().lower()          # "Trinket (Raid)" -> "trinket"
    key = re.sub(r"\s+\d$", "", key)                                 # "Ring 1" -> "ring"
    return SLOT_LABELS.get(key) or (info or {}).get("slot"), qualifier


def _clean_from(text):
    """A row's drop-source text, safe to show in a WoW FontString: HTML
    entities decoded, `|` (the client's escape character - "|T" starts a
    texture) turned into a separator, stray markup brackets dropped."""
    text = html.unescape(text or "")
    text = re.sub(r"\s*\|\s*", " / ", text)
    text = text.replace("[", "").replace("]", "")
    return re.sub(r"\s+", " ", text).strip(" /-")


# Words every BiS table heading shares, dropped when titling a guide's lists.
_TITLE_FILLER = {"best", "in", "slot", "gear", "for", "bis", "the", "of"}


def _title_words(title, spec_words):
    spec = {w.lower() for w in spec_words}
    words = re.findall(r"[\w'+-]+", title or "")
    return " ".join(w for w in words if w.lower() not in _TITLE_FILLER and w.lower() not in spec)


def bis_lists(dump, spec_id, spec_words):
    """[(title, rows)] for the spec, rows as {slot, itemID, name, from}. Only tables
    that look like a full BiS set (8+ rows) count; a guide's side tables
    ("Gearing Strategy", "Bonus Rolling") are skipped. When a guide carries
    more than one full set (one per hero tree), the title keeps the words
    that distinguish them."""
    rec = dump.get(spec_id)
    if not rec:
        return []
    info = items(dump)
    tables = [t for t in rec.get("bis", []) if len(t["rows"]) >= 8]
    out = []
    for table in tables:
        rows = []
        for label, item_id, _, source in table["rows"]:
            meta = info.get(item_id) or {}
            slot, qualifier = _slot(label, meta)
            name = meta.get("name") or ""
            if not slot or not name:
                continue
            source = _clean_from(source)
            if qualifier:
                source = "%s · %s" % (qualifier, source) if source else qualifier
            rows.append({"slot": slot, "itemID": item_id, "name": name, "from": source})
        if not rows:
            continue
        # Titled by what tells the guide's tables apart ("Deathbringer",
        # "Mythic+-Only", "Raid"), wherever in the heading it sits. The old
        # rule read only the words after "for", so Restoration Druid's
        # "Best in Slot Mythic+-Only Gear for ..." titled the same as its
        # overall table and was silently dropped as a duplicate.
        title = "Wowhead"
        if len(tables) > 1:
            words = _title_words(table["title"], spec_words)
            if words:
                title = "Wowhead (%s)" % words
        base, n = title, 1
        while any(t == title for t, _ in out):
            n += 1
            title = "%s (%d)" % (base, n)
        out.append((title, rows))
    return out


def trinket_tiers(dump, spec_id):
    """[{tier, items: [{itemID, name, source}]}] in the site's order, or []."""
    rec = dump.get(spec_id)
    if not rec:
        return []
    info = items(dump)
    tiers = []
    for tier in rec.get("tiers", []):
        rows, seen = [], set()
        for item_id, source in tier["items"]:
            if item_id in seen:
                continue
            seen.add(item_id)
            name = (info.get(item_id) or {}).get("name") or ""
            if not name:
                continue
            rows.append({"itemID": item_id, "name": name,
                         "source": TRINKET_SOURCES.get(source.split(",")[0], "")})
        if rows:
            tiers.append({"tier": tier["tier"], "items": rows})
    return tiers


def builds(dump, spec_id):
    """[{label, string}] with the hero-tree group folded into the label."""
    rec = dump.get(spec_id)
    if not rec:
        return []
    out, labels = [], {}
    for group, label, code in rec.get("builds", []):
        text = ("%s: %s" % (group, label)) if group else label
        n = labels.get(text, 0) + 1
        labels[text] = n
        if n > 1:
            text = "%s (%d)" % (text, n)
        out.append({"label": text, "string": code})
    return out


def updated(dump, spec_id, key="updated"):
    return (dump.get(spec_id) or {}).get(key)

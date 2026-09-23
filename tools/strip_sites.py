#!/usr/bin/env python3
"""Drops the Icy Veins data and the site names from SpecSage's generated data.

Owner's call (2026-09-08): the addon ships one guide's BiS lists, talent
builds and trinket rankings (the ones fetch_bis.py / fetch_talents.py /
fetch_trinkets.py label "Wowhead") and does not name the site in the UI or
the data. The generators still emit both sites with their names, so this
runs AFTER them and is idempotent - re-run it whenever the data is
regenerated:

    python3 tools/fetch_bis.py && python3 tools/strip_sites.py

Full order (DESIGN.md "Regenerating the data: script order"): fetch_bis.py
first (it writes tools/item_bonus.json, which fetch_trinkets.py reads), then
fetch_trinkets.py, fetch_talents.py and fetch_stats.py, then this script.
It exits non-zero if a site name survives or a registration is emptied.

What it does, per file under SpecSage/Data/:
  BiS.lua          - removes every "Icy Veins ..." list, retitles the
                     remaining list "Guide", neutralises `source`.
  Trinkets.lua     - removes the "Icy Veins" list, retitles "Wowhead" to
                     "Guide" (fightStyle "guide"), drops each sim row's
                     `siteTier` (the Icy Veins tier; `whTier` stays),
                     neutralises `source` and the "only list here" notes.
  SiteLoadouts.lua - removes builds with site = "Icy Veins", drops the
                     `site` field from the rest, neutralises `source`.
  StatPriority.lua - neutralises `source`.
"""

import re
from pathlib import Path

DATA = Path(__file__).resolve().parent.parent / "SpecSage" / "Data"


def neutral_source(text, kind):
    """'Icy Veins X gear guide, updated A; Wowhead X gear guide, updated B'
    -> 'Gear guide, updated B' (keeps any leading non-site part, e.g. the
    bloodmallet sims, and the Wowhead date since that is the data kept)."""
    def fix(m):
        src = m.group(1)
        parts = [p.strip() for p in src.split(";")]
        kept = []
        for part in parts:
            if part.startswith("Icy Veins"):
                continue
            wh = re.match(r"Wowhead .*? (gear|talent|stat priority) guide, updated (.*)$", part)
            if wh:
                kept.append(f"{wh.group(1).capitalize()} guide, updated {wh.group(2)}")
                continue
            kept.append(part)
        return 'source = "' + "; ".join(kept) + '"'
    return re.sub(r'source = "([^"]*)"', fix, text)


def strip_bis(src):
    src = re.sub(r'    \{ title = "Icy Veins[^"]*", list = \{\n.*?\n    \}\},\n', "", src, flags=re.S)
    src = src.replace('title = "Wowhead', 'title = "Guide')
    return neutral_source(src, "gear")


def strip_trinkets(src):
    src = re.sub(r'    \{ title = "Icy Veins", fightStyle = "icyveins", list = \{\n.*?\n    \}\},\n', "", src, flags=re.S)
    src = src.replace('{ title = "Wowhead", fightStyle = "wowhead", list = {', '{ title = "Guide", fightStyle = "guide", list = {')
    src = re.sub(r' siteTier = "[^"]*",', "", src)
    src = src.replace("The Icy Veins ranking is the only list here", "The guide ranking is the only list here")
    return neutral_notes(neutral_source(src, "gear"))


def strip_site_loadouts(src):
    src = re.sub(r'    \{ site = "Icy Veins",[^\n]*\n', "", src)
    src = src.replace('{ site = "Wowhead", label', "{ label")
    return neutral_source(src, "talent")


def neutral_notes(src):
    """'note = "Wowhead ranks ..."' -> 'note = "The guide ranks ...".

    A sentence about the Icy Veins ranking describes a list this pass
    removes, so it is dropped rather than renamed; any other mention of
    either site becomes "the guide". `unavailable` text gets the same."""
    def fix_text(text):
        text = re.sub(r"Icy Veins also rates [^.]*\.\s*", "", text)
        text = (text.replace("Wowhead's", "the guide's").replace("Wowhead", "the guide")
                    .replace("Icy Veins'", "the guide's").replace("Icy Veins", "the guide")).strip()
        return text[:1].upper() + text[1:] if text else text

    def fix(m):
        note = fix_text(m.group(2))
        if not note:
            return ""
        return '%s = "%s"' % (m.group(1), note)
    src = re.sub(r'(note|unavailable) = "([^"]*)"', fix, src)
    return re.sub(r"\n  ,\n", "\n", src)   # a dropped note line leaves an empty field behind


def neutral_comments(src):
    """The generators' header comments name the sites; say 'the guide site'."""
    out = []
    for line in src.split("\n"):
        if line.startswith("--"):
            line = (line.replace("Icy Veins' and Wowhead's", "the guide site's")
                        .replace("Wowhead's own", "the guide site's").replace("Wowhead's", "the guide site's")
                        .replace("Icy Veins", "the guide site").replace("Wowhead", "the guide site"))
        out.append(line)
    return "\n".join(out)


def strip_stat_priority(src):
    return neutral_notes(neutral_source(src, "stat priority"))


# A registration whose lists or builds this pass emptied: the spec had only
# Icy Veins data (a failed harvest, or a guide page that moved). Shipping
# `lists = {}` would be rejected at load with a chat warning every login.
EMPTIED = re.compile(r"(lists|builds) = \{\s*\}")


def main():
    problems = []
    for name, fn in (("BiS.lua", strip_bis), ("Trinkets.lua", strip_trinkets),
                     ("SiteLoadouts.lua", strip_site_loadouts), ("StatPriority.lua", strip_stat_priority)):
        path = DATA / name
        before = path.read_text()
        after = neutral_comments(fn(before))
        path.write_text(after)
        print(f"{name}: {len(before)} -> {len(after)} bytes; icy={after.count('Icy Veins')} wowhead={after.count('Wowhead')}")
        if after.count("Icy Veins") or after.count("Wowhead"):
            problems.append(f"{name} still names a site")
        if EMPTIED.search(after):
            problems.append(f"{name} has a registration with no guide data left - re-run the harvest")
    if problems:
        raise SystemExit("strip_sites: " + "; ".join(problems))


if __name__ == "__main__":
    main()

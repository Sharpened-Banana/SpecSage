# Changelog

## 1.3.2 (2026-09-08)

**New**
- **Old trinkets, current copies.** Returning dungeons put years-old trinkets (Merektha's Fang, Ruby Whelp Shell, Algeth'ar Puzzle Box) in this season's tier lists. Trinket rows on the Codex's BiS tab now carry the current copy's bonus IDs wherever a BiS guide links them (25 trinkets), so hovering the row shows this season's item level and numbers, not the base item from its original expansion.
- **Hover Codex trinkets at their simmed item level** (option, default on). For a trinket no guide links, the row projects the base item to the level the sims ranked it at, only when the client confirms the level, and the tooltip says it is a projection, not a drop.
- **Label the gearing panel's tabs** option. The character sheet panel's side tabs carry their section names beside the icons; the option turns the names off.

**Improved**
- A levelling-era copy of a ranked trinket (an item level 19 Merektha's Fang from Chromie Time) no longer shows the current-season tiers on its tooltip. A grey note names both item levels and points at the Codex row for the ranked copy.
- One guide's data: the second site's BiS lists, trinket rankings and talent builds are gone, and the remaining guide is not named anywhere. Lists are titled "Guide"; attribution lines keep the date the guide was read.
- The Stats tab and the character sheet panel's Gear section are laid out as headed blocks: Stat Priority with your hero tree under it, Other Hero Trees (each tree named over its order), Best in Slot.
- The BiS header names the site of the list you are looking at.

**Fixed**
- When the game hides auras in combat, proc and buff tracking waits for the fight to end instead of retrying every 5 seconds and logging a warning each time.

## 1.3.1 (2026-09-05)

**New**
- **Talent window button.** A SpecSage button on the Talents tab lists every build for your spec (SimC Mythic+ and Raid, live top-players', guide sites, your vault) and lays the one you pick onto the tree, unsaved.
- **Minimap button.** The wax seal on the minimap ring: left-click the Codex, right-click the stat overlay, drag to move.
- **Consumables tab rebuilt on Midnight data.** The old entries were War Within items. Every spec now gets eleven kinds (flask, food, potion, weapon oil, each enchant slot, gems, augment rune), stat-matched to its priority and role, every item a hoverable, clickable chip. Item IDs checked against Wowhead. Also on the character sheet panel.
- **Overlay themes.** Minimal, Bordered, and Class-coloured, from the Options tab or Settings panel.
- **Buffs section** on the overlay: missing raid buffs and, optionally, a missing flask or food. Silent when nothing is missing.
- **Show stat overlay** option, plus **Toggle stat overlay** and **Toggle the Codex** key bindings.
- **Stagger** stat row (off by default).

**Improved**
- Buttons read as buttons: ink plates with a shadow and lit edge, wax red on hover, they sink when pressed, and they size to their labels.
- Armor tooltip shows reduction against your current target and falls back to a self-checking estimate when the live figure is unavailable.
- Mastery tooltip quotes your spec's own mastery text and shows mastery points.
- Combat report shows "?" for one protected number instead of blanking the whole line.
- Colour-blind-safe status colours across combat, proc, and buff rows.
- Feedback link now points at github.com/Sharpened-Banana/SpecSage, in a dialog that fits its text.

**Fixed**
- "Save current" and "Add from string" no longer overflow their buttons.
- One watched proc failing to build no longer hides the others.

## 1.3.0

- The Tome: leather-bound Codex with parchment pages, Playfair and Libre Baskerville type, class-coloured names on ink plates, chapter tabs sized to their words, and the hero-tree wax seal.
- View button on every loadout row opens a build in the talent window without saving it. The addon never opens the window itself.
- Hero talent tree read from your talents; the Stats tab shows that tree's priority.
- Docked character sheet panel gained a resize grip; item rows hit only the item name.

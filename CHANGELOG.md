# Changelog

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
- The Stats tab and the character sheet panel's Gear section are laid out as headed blocks: Stat Priority with your hero tree under it, Other Hero Trees (each tree named over its order), Best in Slot.
- Buttons read as buttons: ink plates with a shadow and lit edge, wax red on hover, they sink when pressed, and they size to their labels.
- Armor tooltip shows reduction against your current target and falls back to a self-checking estimate when the live figure is unavailable.
- Mastery tooltip quotes your spec's own mastery text and shows mastery points.
- Combat report shows "?" for one protected number instead of blanking the whole line.
- Colour-blind-safe status colours across combat, proc, and buff rows.
- Feedback link now points at github.com/Sharpened-Banana/SpecSage, in a dialog that fits its text.

**Fixed**
- When the game hides auras in combat, proc and buff tracking now waits for the fight to end instead of retrying every 5 seconds and logging a warning each time.
- The BiS header names the site of the list you are looking at instead of always saying Icy Veins.
- "Save current" and "Add from string" no longer overflow their buttons.
- One watched proc failing to build no longer hides the others.

## 1.3.0

- The Tome: leather-bound Codex with parchment pages, Playfair and Libre Baskerville type, class-coloured names on ink plates, chapter tabs sized to their words, and the hero-tree wax seal.
- View button on every loadout row opens a build in the talent window without saving it. The addon never opens the window itself.
- Hero talent tree read from your talents; the Stats tab shows that tree's priority.
- Docked character sheet panel gained a resize grip; item rows hit only the item name.

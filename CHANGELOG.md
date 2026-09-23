# Changelog

## Unreleased

**Improved**
- Guide data refreshed from the guide site on 2026-09-23: new talent builds for 11 specs, BiS changes for 7, trinket tier changes for 3, and fresh trinket sims for every spec. Retribution Paladin and Feral Druid now have sim-ranked trinket lists.
- Holy Priest's stat priority now follows the guide's separate Raid and Mythic+ orders for each hero tree. Windwalker's now ranks Haste, Crit and Mastery equal for both hero trees.
- BiS alternatives keep their label, so "Trinket (Raid)" and "Trinket (M+)" read as two options rather than a third and fourth trinket. Brewmaster's one-hand and two-hand weapons are labelled the same way.
- The stat, proc, combat and buff trackers do no work while the overlay is turned off.
- One addon error no longer stops the rest of SpecSage's event handling.
- The Tome stays on screen, shrinks to fit narrow screens, closes an open dialog on ESC before closing itself, and keeps a position you dragged it to right before closing. `/sage reset tome` brings it back to the centre.
- The Tome's Stats tab updates its live values when you change gear.
- `/sage overlay` says so when the overlay is on but hidden until combat, and opening options in combat explains why it can't.
- Pinned tooltips no longer rebuild twice a second when nothing changed.
- Releases now run the full test suite on WoW's Lua version before anything is published.

**Fixed**
- The talent window **View** button works again. It had been calling Blizzard's view function the way it worked before Midnight and failing every time.
- **Reset session** now also clears Blizzard's own damage meter, so Session DPS and Session Dmg start from zero.
- The Mastery tooltip keeps its rating lines and shows your spec's mastery text again.
- The docked gearing panel, trinket tooltips and hero-tree stat priorities no longer depend on functions Blizzard is removing next expansion.
- Notes edited in the gearing panel are no longer overwritten by the Tome, and typing in the panel's notes is no longer wiped by background redraws.
- The gearing panel's Copy, Add from string and Save current open their own dialogs instead of the Tome's, which could be hidden or bound to another spec.
- Deleting a loadout always deletes the one you clicked, even after the list changed in the other window.
- In restricted content, a watched spell on cooldown now reads "cooldown" instead of "ready", and stat rows no longer vanish.
- Raid buffs only show as missing when someone in your group can cast them.
- Watched spells are now per spec, so another spec's watches no longer sit in the overlay as "ready".
- A drag of the gearing panel can no longer get stuck to the cursor after the character sheet closes mid-drag, and it follows the cursor at any UI scale.
- Restoration Druid's Mythic+ BiS list was missing; it ships again alongside the overall list.
- Ten guide talent builds that the site shared with another source were silently dropped; all harvested builds now ship.
- Some BiS source text carried characters the game reads as formatting codes (a stray "|" or "]"), which could garble the row.
- Trinket lists no longer show the same trinket twice when the sims rank two stat variants of it.
- Windwalker's cooldown notes no longer list Serenity or Invoke Yu'lon, neither of which is a Windwalker button in Midnight.

## 1.3.3 (2026-09-14)

**New**
- **Hide the Tome while the character sheet is open** (option, default on). Opening the sheet hides an open Tome and closing it brings the Tome back. A Tome you reopen and close yourself while the sheet is up stays closed.
- **The gearing panel moves anywhere.** Drag its title, or the grip in its top-left corner, to put it wherever you like; it used to allow only right or down from the sheet. Right-click the grip to dock it back.

**Fixed**
- ESC closes the Tome without going through the game's own ESC list. Registering there tainted every ESC press, and Edit Mode, the raid frames, the cooldown viewer and encounter warnings then threw errors blamed on SpecSage. In combat, ESC opens the game menu over the Tome instead.
- The aura refusal warning no longer repeats every 5 seconds between pulls: the wait doubles on each refusal up to a minute, and resets when combat ends or the zone changes.

## 1.3.2 (2026-09-08)

**New**
- **The Tome.** The guide window goes by its own name everywhere now: the window, its title, the slash-command help, the options, the key binding and the source file. Rebind **Toggle the Tome** if you had the old binding set; the window's saved position resets to centre once.
- **Old trinkets, current copies.** Returning dungeons put years-old trinkets (Merektha's Fang, Ruby Whelp Shell, Algeth'ar Puzzle Box) in this season's tier lists. Trinket rows on the Tome's BiS tab now carry the current copy's bonus IDs wherever a BiS guide links them (25 trinkets), so hovering the row shows this season's item level and numbers, not the base item from its original expansion.
- **Hover Tome trinkets at their simmed item level** (option, default on). For a trinket no guide links, the row projects the base item to the level the sims ranked it at, only when the client confirms the level, and the tooltip says it is a projection, not a drop.
- **Label the gearing panel's tabs** option. The character sheet panel's side tabs carry their section names beside the icons; the option turns the names off.

**Improved**
- A levelling-era copy of a ranked trinket (an item level 19 Merektha's Fang from Chromie Time) no longer shows the current-season tiers on its tooltip. A grey note names both item levels and points at the Tome's row for the ranked copy.
- One guide's data: the second site's BiS lists, trinket rankings and talent builds are gone, and the remaining guide is not named anywhere. Lists are titled "Guide"; attribution lines keep the date the guide was read.
- The Stats tab and the character sheet panel's Gear section are laid out as headed blocks: Stat Priority with your hero tree under it, Other Hero Trees (each tree named over its order), Best in Slot.
- The BiS header names the site of the list you are looking at.

**Fixed**
- When the game hides auras in combat, proc and buff tracking waits for the fight to end instead of retrying every 5 seconds and logging a warning each time.

## 1.3.1 (2026-09-05)

**New**
- **Talent window button.** A SpecSage button on the Talents tab lists every build for your spec (SimC Mythic+ and Raid, live top-players', guide sites, your vault) and lays the one you pick onto the tree, unsaved.
- **Minimap button.** The wax seal on the minimap ring: left-click the Tome, right-click the stat overlay, drag to move.
- **Consumables tab rebuilt on Midnight data.** The old entries were War Within items. Every spec now gets eleven kinds (flask, food, potion, weapon oil, each enchant slot, gems, augment rune), stat-matched to its priority and role, every item a hoverable, clickable chip. Item IDs checked against Wowhead. Also on the character sheet panel.
- **Overlay themes.** Minimal, Bordered, and Class-coloured, from the Options tab or Settings panel.
- **Buffs section** on the overlay: missing raid buffs and, optionally, a missing flask or food. Silent when nothing is missing.
- **Show stat overlay** option, plus **Toggle stat overlay** and **Toggle the Tome** key bindings.
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

- The Tome look: a leather-bound book with parchment pages, Playfair and Libre Baskerville type, class-coloured names on ink plates, chapter tabs sized to their words, and the hero-tree wax seal.
- View button on every loadout row opens a build in the talent window without saving it. The addon never opens the window itself.
- Hero talent tree read from your talents; the Stats tab shows that tree's priority.
- Docked character sheet panel gained a resize grip; item rows hit only the item name.

# FABconfig

FABconfig is a Windows GUI tool, written in AutoHotkey v2, that registers an Autodesk Fabrication database as a named Fabrication configuration. It creates a configuration folder, writes a `map.ini` pointing back to the shared database, copies `config.png`, and writes `HKCU\Software\Autodesk\Fabrication <year>\Configuration\<name>` → `Path` for years A_YYYY-4 to A_YYYY+2. See README.md for user-facing behavior.

Owner and developer: Scott Hendricks, Virtual Building Supply, LLC (VBS). License: GPL-3.0-or-later with section 7 additional terms (keep author attribution; no rights to VBS name/logo).

## Files

- `FABconfig.ahk` — the whole program (single file). The file name never changes between versions.
- `CHANGELOG.md` — notes per version; new changes go under **Unreleased**.
- `Resources/VBS_Logo.ico` — window/tray/.exe icon. `Resources/VBS_Logo_Badge.png` — sidebar logo (logo on white, rounded via a window region). Both optional at runtime; the script falls back to a shell32 icon / MDL2 glyph. The compiled .exe has both built in (`SetMainIcon`, and `AddResource` as RCDATA `VBS_LOGO_BADGE`, loaded by `LoadPngResource()` through GDI+), so it doesn't need the folder. Don't paste the logos into the .ahk itself: GPL section 7(e) keeps them separate from the GPL'd source.
- `README.md`, `LICENSE` (verbatim GPL v3, do not edit).

## Running and checking

- Requires AutoHotkey v2 on Windows 10/11. Run: `AutoHotkey64.exe FABconfig.ahk`.
- Load/syntax errors: `AutoHotkey64.exe /ErrorStdOut FABconfig.ahk` prints errors to stdout instead of a dialog.
- Compile: Ahk2Exe with a v2 base; metadata comes from the `;@Ahk2Exe-` lines (escape commas as `` `, ``). The output is `FABconfig_v<version>.exe` next to the script.
- There are no automated tests. Test FABconfig with a throwaway configuration name and clean up afterwards (delete the registry keys and the folder).

## Code conventions

- Keep the GPL header block at the top of the file intact, including copyright, author and the section 7 terms.
- Version format is `vYY.MM.DD` (for example `v26.10.24`); a second release the same day is `vYY.MM.DD.N`. `APP_VERSION` is the only place it's written: the `;@Ahk2Exe-Let`/`SetVersion`/`ExeName` lines directly after it read it through `A_PriorLine`, so nothing may be inserted between them. Don't put the version in file names, the header comment or the README. Releases are git tags (`v26.10.24`) with GitHub Releases.
- Record user-visible changes in CHANGELOG.md under **Unreleased** as you make them.
- Colors are defined once in the `CLR_*` constants (VBS palette from the logo: green A6B727, dark green 6B7619, gray 818183/6C6C6E). Use the dark shades for text on white; keep text at WCAG AA contrast.
- Fonts: Segoe UI / Segoe UI Semibold for text, Segoe MDL2 Assets for icons (`Chr(0xE...)`).
- Plain-language UI text, sentence case, no jargon in messages to users.

## AutoHotkey v2 lessons learned (these caused real bugs)

- **Never name an object property `Base`** — it's the built-in prototype property ("Invalid base" error). Group colors use `Normal`/`Hover`.
- **Z-order:** Windows stacks each new control *underneath* earlier ones. Every control must be created through `AddCtl()` (records creation order and adds `WS_CLIPSIBLINGS` 0x4000000), and `StackControls()` re-stacks them before `Show` so later controls sit on top of the cards behind them. Do not call `g.Add` directly.
- **Do not use `WS_EX_COMPOSITED` (+E0x02000000)** on the Gui: it painted the backgrounds over everything and broke rounded corners. The Gui uses `WS_CLIPCHILDREN` (+0x2000000) instead.
- **DPI:** the Gui uses `-DPIScale`; all layout is written in 100%-scale units and converted with `S(n)`. `M(ctrl, x, y, w, h, r)` moves a control in those units and rounds corners with `SetWindowRgn` when `r` is given. `Layout()` works in `W := w / SCALE` units.
- Repaint controls with `RedrawCtl()` (RedrawWindow), not `GuiCtrl.Redraw()`.
- Avoid multi-line ternaries (lines starting with `?` / `:`); use if/else.
- When editing with scripted find/replace, make sure a replacement doesn't split a comment line onto code (an earlier edit left the tail of a comment after a statement and broke the script).

## Databases vs. configuration folders

- VBS databases' own map.ini files also start with `# Created by Virtual Building Supply`, so that marker does **not** tell a configuration folder from a database (relying on it made FABconfig reject its own database folder). `IsConfigFolder()` instead checks whether `[PROGRAM PATHS] Main` resolves to a different folder; a database's map.ini has `Main=.`. Use the marker (`HasMarker()`) only on folders already known to be configurations.

## UI structure

- Dark sidebar (badge, app name, version, nav: New configuration / What's this? / Exit) and a light page with white rounded cards.
- Main view: "Configuration details" card (name, location + Browse, database folder + Browse, Create Configuration button at bottom right) and a "Registers with" card of version chips on the right.
- About view ("What's this?"): four step tiles and a text card ending with the GPL copyright/no-warranty notice.
- Clickable items are "groups" (`NewGroup`/`AddPart`) with hover colors, a hand cursor and a polling timer to clear hover.
- If FABconfig isn't run from a folder with a `map.ini`, it asks for the database folder at start-up ("Select a folder that contains a Fabrication database"). A valid database folder has a `map.ini` or a `DATABASE` folder.

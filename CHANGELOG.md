# Changelog

All notable changes to this resource are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/).

## [1.2.3] - 2026-11-18

### Fixed
- The blur could remain fully applied after opening. `IS_SCREENBLUR_FADE_RUNNING`
  turns false as soon as WHIP's 200 ms fade-in finishes -- at which point the blur
  is already on screen -- and `TRIGGER_SCREENBLUR_FADE_OUT` can be refused while
  that fade-in is animating. The resource now keeps a 450 ms suppression window
  and retries `TriggerScreenblurFadeOut(0)` every frame, so a call always lands
  after the fade-in. A backstop on `whip_core:ui:stateChanged` catches opens the
  fade check misses, without touching the pause menu's own blur.

## [1.2.2] - 2026-11-18

### Changed
- Replaced the every-frame `IsInventoryOpen()` export poll with a cheap native
  fade-state check. The cross-resource export is now called only while a screen
  blur fade is actually running, so the idle cost of the resource is near zero.
  The watcher still covers local opens (F2, pad, radial, prompts/stashes) and
  leaves the pause menu's own blur untouched.

## [1.2.1] - 2026-11-18

### Fixed
- Removed the last one-frame blur flash on open. The normal F2 open is handled
  locally inside `whip_core` and never fires a net event; the blur killer was
  therefore waiting up to 40 ms before noticing the inventory was open. It now
  polls `IsInventoryOpen()` every frame, so `TriggerScreenblurFadeOut(1)` lands
  in the same frame as WHIP's `TriggerScreenblurFadeIn(200)`.

## [1.2.0] - 2026-11-18

### Changed
- Renamed the resource from `whip_inventory_skin` to **`whip_inventory_compact`**.
  `server.cfg` and `whip_core/config.lua` were updated to match.
- `README.md` is now the full English documentation; the Italian version moved to
  `README.it.md` and the redundant `README.en.md` was removed. Its structure follows
  the `whip_clothingwheel` README (Installation, Languages, How to use, Files, Events,
  Configuration), adapted to a CSS-only skin.
- Installation docs no longer assume the `[custom]` folder: the resource can live
  in any directory under `resources/`.

### Added
- `config.lua` with `Config.Locale` and the five language blocks `it`, `en`,
  `es`, `fr`, `de` — the same one-line switch used by `whip_clothingwheel`.
- `shared/locale.lua`: dot-path lookup, `en` → `it` fallback and `string.format`
  placeholders, mirroring the clothingwheel loader.
- `server.lua` now compiles the active accessory labels into
  `locales/active.css`; `theme.css` imports that generated file.
- GitHub metadata: MIT `LICENSE`, `.gitignore`, `CHANGELOG.md`, screenshot folder.

## [1.1.0] - 2026-11-18

### Added
- Localization for in-game accessory labels and documentation: `it`, `en`, `es`,
  `fr`, `de`. Change one line in `theme.css` (the `@import` at the top) to switch
  language; the default is Italian.
- `README.en.md`, `README.es.md`, `README.fr.md`, `README.de.md` alongside the
  Italian `README.md`.
- GitHub package files: `LICENSE` (MIT), `.gitignore`, `CHANGELOG.md` and two
  screenshots under `docs/screenshots/`.

### Fixed
- Item names were clipped to their first letter: WHIP reserved 82px of a 96px
  slot for the stack count, leaving 14px for the name. The skin now gives the
  name the space up to the count and ellipsises long names.
- Accessory labels (`Telefono`, `Contanti`, `Chiave 1-3`) were too small; they
  are now 15px internal, full colour with a dark rim.
- Key hints at the bottom of the card were too small; text is 15px and keycaps
  14px internal.
- Object tooltips could leave the screen near an edge: the `-50%/-100%`
  positioning transform was applied *after* WHIP's clamps. The transform is
  gone, so the native clamps work on all four sides.
- The Tab hotbar used a different visual language and disappeared immediately
  on key release. It now matches the inventory (dark surface, quiet white
  lines, no blue, no shadows) and stays fully visible for 2 seconds (plus a
  0.2s fade).

## [1.0.0] - 2026-11-18

### Added
- Initial release: two equal 420px columns, native WHIP renderer kept intact,
  no screen dimming/blur, animated open/close, stacked right-hand panels,
  hover tooltip with delay and restyled Tab hotbar.

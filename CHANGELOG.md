# Changelog

All notable changes to this resource are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/).

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

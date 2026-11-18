# whip_inventory_compact

A skin for WHIP's stock inventory. It **does not replace the renderer**: `whip_core` still draws
every slot, handles drag & drop, tooltips, menus, weights and server-side validation. The resource
only applies a `theme.css` at startup through `Whip.register` + `SetActiveTheme`. CSS cannot undo
the native screen blur WHIP applies on open, so the installation also includes a one-line patch to
`whip_core/client/inventory.lua`, with a script to re-apply it after every core update.

No NUI page, no JavaScript and no copy of the renderer are shipped. The layout is CSS only: two
equal columns, the left one continuous (title, accessories, player grid, Nearby, key hints), the
right one stacking the bags, trunk, boot and wallet windows instead of overlapping them. The center
of the screen stays free.

## Installation

Copy the `whip_inventory_compact` folder into any directory under your server's `resources`
directory (`[custom]`, `[core]`, or directly under `resources`), then add this line to `server.cfg`,
**after `whip_core`**:

```cfg
ensure whip_inventory_compact
```

- `dependency 'whip_core'`, `@whip_core/lib/satellite.lua`, `config.lua` and `shared/locale.lua` are
  already in the manifest.
- The one-line blur patch is applied to `whip_core/client/inventory.lua`. See **Blur and dimming**
  below, and re-run `scripts/apply-blur-patch.ps1` after every `whip_core` update.
- `server.lua` writes `locales/active.css` on start: the resource folder needs to be writable. If it
  is not, the committed Italian file is kept and a warning is printed in the F8 console.
- `restart whip_inventory_compact` is required after editing `theme.css`, `config.lua` or the
  locale file. Calling `SetActiveTheme` with the same name does not rebroadcast it.
- `stop whip_inventory_compact` removes the override and restores the stock look. To make the theme
  permanent, stop it and select it in `/whip` → Settings → Theme.

Repository: https://github.com/OkanFeNwa/whip_inventory_compact

```bash
cd resources
git clone https://github.com/OkanFeNwa/whip_inventory_compact.git
```

## Languages

All text owned by this resource is translated. In `config.lua` change a single line:

```lua
Config.Locale = 'it' -- it, en, es, fr, de
```

Complete `it`, `en`, `es`, `fr`, `de` blocks are included in `Config.Locales`. Copy a block to add
another language. Italian, English, Spanish, French and German cover:

- the five accessory slot labels (Phone, Cash, Key 1/2/3);
- the console messages printed by this resource.

Fallback is `en`, then `it`, then the key name: a missing label never produces an empty string.
`server.lua` compiles the active labels into `locales/active.css`, which `theme.css` imports as its
first rule; this is the bridge between the Lua config and CSS, because the client never reads Lua.
Restart the resource after changing `Config.Locale`.

The other inventory strings (Nearby, key hints, item names) are drawn by `whip_core` and stay in
their own language: a CSS theme cannot translate them without rewriting the renderer.

## How to use

Open the inventory with F2, the radial menu, the quick wheel or a container. The theme is active for
everyone as soon as the resource starts:

1. The left column is a single card. The title and weight capacity are attached to the five
   accessory slots; a short centered divider separates them from the player grid, and another one
   separates the grid from the two-row **Nearby / Ground** area and the key hints at the bottom.
2. Every grid uses 5 columns per row with 72px on-screen slots. Quick slots 1–5 are highlighted.
   The left card has no side borders and no drop shadow, only thin flat dividers.
3. Bags, trunks, boots and wallets opened by WHIP appear in the right column, stacked vertically
   and centered as a group. The window opened first stays on top (it is the first child in WHIP's
   DOM). They grow with their content and never overlap.
4. Hover an item: the tooltip appears after 0.32s instead of immediately, so passing the mouse over
   slots does not flash text. It is larger (285×96px on screen) and stays inside the screen on all
   four edges.
5. Press Tab: the hotbar uses the same dark surface and quiet white lines as the inventory. It
   remains fully visible for 2 seconds after release, then fades over 0.2s. Counts and the active
   slot are still handled by WHIP.
6. Close the inventory: the shell animates out over 0.24s. No background blur and no dark wash are
   applied while it is open.

### Layout

- At 1920×1080 the wrapper leaves 24px on each side and 89px at the top and bottom; both columns
  are 420px on screen (560px internal × WHIP's 0.75 zoom).
- Item names use the space up to the stack counter and fall back to ellipsis: WHIP originally
  reserved 82px of a 96px slot for the counter, leaving 14px for the name.
- Accessory labels are 15px internal instead of 10px; key hints are 15px with 14px keycaps instead
  of 11px.
- Resize the columns in `theme.css` at `.inv-wrapper` → `grid-template-columns`. Card width is
  `--skin-card-w`, slot size is `--skin-slot`, zoom is `--ui-zoom-inventory`.

### Animations

- Opening: the window rises 10px and settles in 0.26s. Closing is animated with `ease-in` over
  0.24s (WHIP keeps `.open` for 250ms).
- Everything enters together: the native 0.07s delay on the accessory bar is cancelled, so
  phone/cash/keys do not lag behind.
- No flicker: the overlay snaps to opacity 1 instead of fading with the shell; `scale()` was removed
  because at `zoom:0.75` it redrew slots and text at fractional pixels; the easing is
  `--skin-ease` (`cubic-bezier(.25,.8,.25,1)`) instead of WHIP's `--ui-ease`, which did 60% of the
  movement in the first frame.
- Panels opened while the inventory is already visible enter with `skinPanelIn` (0.26s, 8px rise,
  no `scale`).
- The tooltip animation lives on the inner `.inv-pop`: WHIP's inline `left/top` written by
  `positionTooltip()` are not touched, and the extra `-50%/-100%` transform that pushed tooltips off
  screen is gone.

### Blur and dimming

WHIP calls `TriggerScreenblurFadeIn(200)` on open. That native blurs the **game frame** behind the
NUI page, so no CSS rule can remove it. Chasing it from this resource also fails: a client-side
`FadeOut` either arrives one frame late (visible flash) or was refused while the fade-in was still
animating. The reliable fix is to disable the call at its source.

`whip_core/client/inventory.lua` is patched like this (the pause menu's own blur is untouched):

```lua
    -- [whip_inventory_compact blur patch] native inventory blur disabled; pause blur untouched.
    -- Re-apply after a whip_core update with scripts/apply-blur-patch.ps1
    -- TriggerScreenblurFadeIn(200)
```

After a `whip_core` update the original line comes back. Re-apply the patch from PowerShell, in the
resource folder:

```powershell
.\scripts\apply-blur-patch.ps1          # apply (idempotent, makes a one-time backup)
.\scripts\apply-blur-patch.ps1 -Status  # report patched / original
.\scripts\apply-blur-patch.ps1 -Restore # put the original line back
```

The script finds `whip_core` anywhere under the same `resources` tree, or accepts `-CorePath`.
Then `restart whip_core`. No client script ships with this resource, so idle CPU cost is zero.

`#inv-wash` is forced to `background: transparent`, beating the inline color written by
`inventory.js`, so there is no dark wash either. `#inv-ground-panel` is forced to stay visible when
WHIP opens a container.

## Files

| File | Role |
| --- | --- |
| `theme.css` | Full CSS layout, animations and the import of the active locale CSS |
| `locales/active.css` | Generated from `config.lua` by `server.lua`; committed with Italian defaults |
| `config.lua` | Locale selection and the five language blocks |
| `shared/locale.lua` | Dot-path lookup with `en` → `it` fallback and `string.format` placeholders |
| `server.lua` | Writes the locale CSS, then applies the theme for everyone with `Whip.register` |
| `scripts/apply-blur-patch.ps1` | Re-applies the one-line `whip_core` blur patch after core updates |
| `fxmanifest.lua` | `dependency 'whip_core'`, shared scripts and served files |
| `docs/screenshots/` | Preview images used in this README |

![Inventory — pockets](docs/screenshots/pockets.png)

![Inventory — container and wallet](docs/screenshots/stash.png)

## Events

No new net event is registered and no client script ships with this resource. `theme.css` changes
only the presentation of the DOM that `whip_core` already renders; the blur patch is a commented
line in the core itself.

## Configuration

`config.lua` contains `Locale` and `Locales` (5 languages). `theme.css` contains the colors, sizes,
`.inv-wrapper` columns, the animation easings and the import of `locales/active.css`.
`fxmanifest.lua` declares `whip_core` as a dependency and serves both CSS files. The only change
outside this folder is the one-line blur patch in `whip_core/client/inventory.lua`.

Known limitation: WHIP appends static containers after the wallet, so if a wallet is opened first
and a container second, the wallet stays above it in the DOM. Changing that order would require JS
in the renderer, which this skin deliberately does not ship.

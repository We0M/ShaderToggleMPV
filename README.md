# MPV Shader Toggle

Type-aware GLSL shader switcher for [mpv](https://mpv.io/).

Shaders are organized by **type** — the first subdirectory under `~~/shaders/`.
When toggling a single shader, it **replaces** the active shader of the same type instead of stacking.
Multiple shaders can be toggled as a pack.

## Install

Copy `shader-toggle.lua` to `~~/scripts/`.

## Usage

```
script-message toggle-shaders "shaders" ["label"] ["begin"|"end"]
```

Shaders are separated by `;`. All paths must start with `~~/shaders/`.

### Modes

| Shaders | Position | Behavior |
|---------|----------|----------|
| Single  | —        | Toggle on/off; replaces same-type shader if one is active |
| Multi   | —        | **Pack mode**: replaces entire shader list or clears it |
| Multi   | `begin`/`end` | Inserts at position or removes; preserves other shaders |

### input.conf examples

```
# Single shader — toggles or replaces same type
F1 script-message toggle-shaders "~~/shaders/UpscaleLuma/ArtCNN.glsl"

# Pack — replaces all active shaders with this set
F2 script-message toggle-shaders "~~/shaders/Pack/Anime4K/Clamp.glsl;~~/shaders/Pack/Anime4K/Restore.glsl;~~/shaders/Pack/Anime4K/Upscale.glsl" "Anime4K A+A"

# Multi with position — appends to end, keeps other shaders
F3 script-message toggle-shaders "~~/shaders/PreUpscale/Restoration.glsl;~~/shaders/Downscale/SSimDownscaler.glsl" "" "end"
```

### Expected directory structure

```
~~/shaders/
├── UpscaleLuma/
│   ├── ArtCNN.glsl
│   └── FSRCNNX.glsl
├── Downscale/
│   └── SSimDownscaler.glsl
└── Pack/
    └── Anime4K/
        ├── Clamp.glsl
        ├── Restore.glsl
        └── Upscale.glsl
```

## License

[MIT](LICENSE)

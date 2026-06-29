# Kitana Themes

Kitana theme source material lives under this directory. Runtime files are still written to each application's config directory by `kitana-theme`, `kitana-matugen`, and the app-specific `kitana-theme-*` helpers.

## Layout

```text
themes/
  _template.jsonc
  static/
    *.jsonc
  dynamic/
    matugen/
      config.toml.example
      quickshell-current.json.tpl
  integrations/
    cava/
      kitana/
      vendor/
    ghostty/
      vendor/
    zed/
      vendor/
```

## Flow

Static themes in `themes/static/*.jsonc` are loaded by `lib/kitana-theme.lua`. The shared schema uses native source colors under `colors`, semantic Kitana roles under `palette`, icon tone mappings under `icons`, and optional app metadata under integration keys such as `hypr`, `ghostty`, `cava`, `zed`, and `neovim`.

Quickshell and Matugen converge on the same runtime JSON schema at `~/.config/quickshell/kitana/Theme/current.json`. Quickshell consumes that file through `config/quickshell/kitana/Config/Colors.qml`.

Matugen templates live under `themes/dynamic/matugen/templates/`. Kitana's `kitana-matugen` command renders those templates from its normalized Material color table so wallpaper-derived themes keep working even when the external `matugen` command is unavailable and Kitana falls back to ImageMagick or direct hex colors.

Vendored upstream app themes live beside the integration they support. Static theme metadata references those files through repository-relative `source_file` paths, including local Ghostty and Cava sources so application backgrounds do not depend on packaged theme-name lookup behavior.

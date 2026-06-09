# TODO

- Design a Kitana first-run stage, likely triggered once from Hyprland autostart with per-step markers under `~/.local/state/kitana/first-run/`. Candidate first-run tasks:
  - Apply live GNOME/GTK settings (`Adwaita-dark`, `Adwaita`, `prefer-dark`) after first login.
  - Show a welcome/keybinding notification once Quickshell/notifications are actually running.
  - Configure optional hardening like `ufw` explicitly as a first-run/user-visible choice instead of silently enabling it during reinstall.
  - Handle user-session services that need a running session, such as future battery monitoring or OSD services.
  - Keep package installation, config file deployment, SDDM setup, firmware metadata refresh, and hardware package detection in install/reinstall stages rather than first-run.
- Revisit real CAVA integration for the dashboard media visualizer. Current bars are synthetic; a later pass should add a small `cava` service/process parser with graceful fallback.
- Revisit theme-specific blur coordination between Hyprland and Quickshell. Hyprland now has blur profiles, but Quickshell still owns separate alpha/color tokens in `Colors.qml`; later theme generation could set both together.
- Consider optional Plymouth boot splash support for a smoother branded boot after Limine. Keep it opt-in for non-encrypted installs, and provide a migration/helper for existing Kitana installs that installs Plymouth, configures mkinitcpio/kernel args, applies a Kitana theme, regenerates initramfs, and validates rollback safety.
- Consider Bitwarden lock separately after confirming the right command/session behavior.
- Improve Bluetooth audio routing for multiple connected devices. Detect personal earbuds/headsets such as AirPods, Pixel Buds, and similar Bluetooth audio devices, then safely switch the default PipeWire sink to them when they connect and fall back to the preferred speaker sink, such as Audioengine HD3, when they disconnect. Keep Bluetooth connection management separate from audio routing and avoid surprising changes for non-earbud devices.
- Improve launcher search later using DMS/Noctalia provider ideas: app actions, frecency, calculator, session actions, and maybe clipboard search.
- Remove the separate `papers` install once Sushi 51 is released and packaged with Papers support, so Kitana does not request Papers twice.
- Consider adding Kitana Hyprland helper functions for common patterns like window rules, binds, launchers, and notifications.

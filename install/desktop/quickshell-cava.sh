echo "Installing Quickshell Cava plugin..."

PACKAGES=(
  cmake
  fftw
  ninja
  pipewire
  pkgconf
  qt6-base
  qt6-declarative
)

kitana_install_required_packages "desktop/quickshell-cava" "${PACKAGES[@]}" || exit 1

if ! "$KITANA_DIR/bin/kitana-quickshell-build-cava"; then
  exit_code="${KITANA_LAST_EXIT_CODE:-1}"
  kitana_log_failure \
    "desktop/quickshell-cava" \
    "kitana-quickshell-build-cava" \
    "kitana-quickshell-build-cava" \
    "$exit_code" \
    "kitana-quickshell-build-cava" \
    "${KITANA_LAST_COMMAND_LOG:-}"
  exit "$exit_code"
fi

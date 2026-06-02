#!/bin/bash

kitana_state_dir() {
  printf '%s\n' "${KITANA_STATE_DIR:-$HOME/.local/state/kitana}"
}

kitana_init_install_log() {
  local state_dir
  state_dir="$(kitana_state_dir)"
  mkdir -p "$state_dir"

  export KITANA_INSTALL_REPORT="$state_dir/install-report.log"
  export KITANA_INSTALL_FAILURES="$state_dir/install-failures.log"

  if [ "${KITANA_INSTALL_LOG_INITIALIZED:-0}" != "1" ]; then
    : >"$KITANA_INSTALL_REPORT"
    : >"$KITANA_INSTALL_FAILURES"
    export KITANA_INSTALL_LOG_INITIALIZED=1
  fi
}

kitana_timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

kitana_is_unattended() {
  [ "${KITANA_UNATTENDED:-0}" = "1" ]
}

kitana_is_edge() {
  [ "${KITANA_EDGE:-0}" = "1" ]
}

kitana_log_report() {
  kitana_init_install_log
  printf '[%s] %s\n' "$(kitana_timestamp)" "$*" >>"$KITANA_INSTALL_REPORT"
}

kitana_log_failure() {
  local phase="$1"
  local item="$2"
  local command="$3"
  local exit_code="$4"
  local manual="${5:-$command}"

  kitana_init_install_log
  {
    printf '[%s] FAILED\n' "$(kitana_timestamp)"
    printf 'phase=%s\n' "$phase"
    printf 'item=%s\n' "$item"
    printf 'command=%s\n' "$command"
    printf 'exit=%s\n' "$exit_code"
    printf 'manual=%s\n\n' "$manual"
  } >>"$KITANA_INSTALL_FAILURES"
}

kitana_install_required() {
  local phase="$1"
  local pkg="$2"
  local command=(yay -S --noconfirm --needed "$pkg")

  kitana_log_report "Installing required package: $pkg ($phase)"
  if "${command[@]}"; then
    return 0
  fi

  local exit_code=$?
  kitana_log_failure "$phase" "$pkg" "${command[*]}" "$exit_code" "yay -S $pkg"
  return "$exit_code"
}

kitana_install_optional() {
  local phase="$1"
  local pkg="$2"
  local command=(yay -S --noconfirm --needed "$pkg")

  kitana_log_report "Installing optional package: $pkg ($phase)"
  if "${command[@]}"; then
    return 0
  fi

  local exit_code=$?
  kitana_log_failure "$phase" "$pkg" "${command[*]}" "$exit_code" "yay -S $pkg"

  local retry=(yay -S --noconfirm --needed --answerclean All "$pkg")
  echo "$pkg install failed. Retrying with a clean AUR build..."
  if "${retry[@]}"; then
    kitana_log_report "Optional package succeeded after clean retry: $pkg ($phase)"
    return 0
  fi

  exit_code=$?
  kitana_log_failure "$phase" "$pkg" "${retry[*]}" "$exit_code" "yay -S --answerclean All $pkg"
  echo "WARNING: $pkg failed to install and needs manual intervention. Continuing."
  return 0
}

kitana_install_with_fallback() {
  local phase="$1"
  local primary="$2"
  local fallback="$3"
  local command=(yay -S --noconfirm --needed "$primary")

  kitana_log_report "Installing package with fallback: $primary -> $fallback ($phase)"
  if "${command[@]}"; then
    return 0
  fi

  local exit_code=$?
  kitana_log_failure "$phase" "$primary" "${command[*]}" "$exit_code" "yay -S $primary"
  echo "$primary failed. Trying fallback package: $fallback"

  kitana_install_required "$phase" "$fallback"
}

kitana_print_install_summary() {
  kitana_init_install_log

  if [ -s "$KITANA_INSTALL_FAILURES" ]; then
    echo
    echo "Kitana install completed with failures that may need manual review:"
    echo "$KITANA_INSTALL_FAILURES"
    if command -v gum >/dev/null 2>&1; then
      gum style --foreground 3 "Review Kitana install failures: $KITANA_INSTALL_FAILURES" || true
    fi
  else
    echo
    echo "Kitana install completed with no tracked failures."
  fi
}

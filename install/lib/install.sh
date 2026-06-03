#!/bin/bash

kitana_init_paths() {
  export KITANA_DIR="${KITANA_DIR:-$HOME/.local/share/kitana}"
  export KITANA_INSTALL="${KITANA_INSTALL:-$KITANA_DIR/install}"

  case ":$PATH:" in
    *":$KITANA_DIR/bin:"*) ;;
    *) export PATH="$KITANA_DIR/bin:$PATH" ;;
  esac
}

source_script() {
  local script="$1"
  local script_path="$KITANA_INSTALL/$script"

  if [ -f "$script_path" ]; then
    echo "Sourcing $script..."
    source "$script_path"
  else
    echo "$script not found; skipping."
  fi
}

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
  local output_log="${6:-}"

  kitana_init_install_log
  {
    printf '[%s] FAILED\n' "$(kitana_timestamp)"
    printf 'phase=%s\n' "$phase"
    printf 'item=%s\n' "$item"
    printf 'command=%s\n' "$command"
    printf 'exit=%s\n' "$exit_code"
    printf 'manual=%s\n' "$manual"
    if [ -n "$output_log" ]; then
      printf 'output=%s\n' "$output_log"
    fi
    printf '\n'
  } >>"$KITANA_INSTALL_FAILURES"
}

kitana_slug() {
  printf '%s' "$1" | tr -cs 'A-Za-z0-9._-' '_'
}

kitana_package_log_dir() {
  local state_dir
  state_dir="$(kitana_state_dir)"
  printf '%s/package-logs\n' "$state_dir"
}

kitana_run_logged() {
  local phase="$1"
  local item="$2"
  local attempt="$3"
  shift 3

  local log_dir log_file exit_code had_errexit=0
  log_dir="$(kitana_package_log_dir)"
  mkdir -p "$log_dir"
  log_file="$log_dir/$(date '+%Y%m%d-%H%M%S')-$(kitana_slug "$phase")-$(kitana_slug "$item")-$(kitana_slug "$attempt").log"

  export KITANA_LAST_COMMAND_LOG="$log_file"
  kitana_log_report "Output log for $item ($phase/$attempt): $log_file"

  case "$-" in
    *e*)
      had_errexit=1
      set +e
      ;;
  esac

  "$@" > >(tee "$log_file") 2>&1
  exit_code=$?
  export KITANA_LAST_EXIT_CODE="$exit_code"

  if [ "$had_errexit" -eq 1 ]; then
    set -e
  fi

  if grep -qiE 'no AUR package|target not found|package .* was not found|could not find package|failed to create package file' "$log_file"; then
    kitana_log_report "Package warning for $item ($phase/$attempt); inspect $log_file"
  fi

  return "$exit_code"
}

kitana_install_required() {
  local phase="$1"
  local pkg="$2"
  local command=(yay -S --noconfirm --needed "$pkg")

  kitana_log_report "Installing required package: $pkg ($phase)"
  if kitana_run_logged "$phase" "$pkg" "required" "${command[@]}"; then
    return 0
  fi

  local exit_code="${KITANA_LAST_EXIT_CODE:-1}"
  kitana_log_failure "$phase" "$pkg" "${command[*]}" "$exit_code" "yay -S $pkg" "${KITANA_LAST_COMMAND_LOG:-}"
  return "$exit_code"
}

kitana_install_optional() {
  local phase="$1"
  local pkg="$2"
  local command=(yay -S --noconfirm --needed "$pkg")

  kitana_log_report "Installing optional package: $pkg ($phase)"
  if kitana_run_logged "$phase" "$pkg" "optional" "${command[@]}"; then
    return 0
  fi

  local exit_code="${KITANA_LAST_EXIT_CODE:-1}"
  kitana_log_failure "$phase" "$pkg" "${command[*]}" "$exit_code" "yay -S $pkg" "${KITANA_LAST_COMMAND_LOG:-}"

  local retry=(yay -S --noconfirm --needed --answerclean All "$pkg")
  echo "$pkg install failed. Retrying with a clean AUR build..."
  if kitana_run_logged "$phase" "$pkg" "optional-clean-retry" "${retry[@]}"; then
    kitana_log_report "Optional package succeeded after clean retry: $pkg ($phase)"
    return 0
  fi

  exit_code="${KITANA_LAST_EXIT_CODE:-1}"
  kitana_log_failure "$phase" "$pkg" "${retry[*]}" "$exit_code" "yay -S --answerclean All $pkg" "${KITANA_LAST_COMMAND_LOG:-}"
  echo "WARNING: $pkg failed to install and needs manual intervention. Continuing."
  return 0
}

kitana_install_with_fallback() {
  local phase="$1"
  local primary="$2"
  local fallback="$3"
  local command=(yay -S --noconfirm --needed "$primary")

  kitana_log_report "Installing package with fallback: $primary -> $fallback ($phase)"
  if kitana_run_logged "$phase" "$primary" "fallback-primary" "${command[@]}"; then
    return 0
  fi

  local exit_code="${KITANA_LAST_EXIT_CODE:-1}"
  kitana_log_failure "$phase" "$primary" "${command[*]}" "$exit_code" "yay -S $primary" "${KITANA_LAST_COMMAND_LOG:-}"
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

#!/bin/bash

# shellcheck source=install.sh
[ -n "${KITANA_INSTALL_REPORT:-}" ] || source "${KITANA_INSTALL:-${KITANA_DIR:-$HOME/.local/share/kitana}/install}/lib/install.sh"
kitana_init_paths

kitana_has_extra() {
  local extra="$1"
  local value="${KITANA_EXTRAS:-}"
  value="${value//[[:space:]]/}"

  [ -n "$value" ] || return 1

  case ",$value," in
    *,all,*|*,"$extra",*) return 0 ;;
    *) return 1 ;;
  esac
}

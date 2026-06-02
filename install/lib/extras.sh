#!/bin/bash

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

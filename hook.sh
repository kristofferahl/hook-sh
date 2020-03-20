#!/usr/bin/env bash

export HOOK_LOG="${HOOK_LOG:-false}"
export HOOK_PREFIX=${HOOK_PREFIX:-hook_}
export HOOK_GLOBAL_PREFIX=${HOOK_GLOBAL_PREFIX:-global_}
export HOOK_FILE="${HOOK_FILE:-./hooks.sh}"
export HOOK_GLOBAL_FILE="${HOOK_GLOBAL_FILE:-}"
export HOOK_LAST_EXIT_CODE

hook() {
  local -a functions_before_hook
  local -a functions_after_hook

  HOOK_LAST_EXIT_CODE=''

  mapfile -t functions_before_hook < <(declare -F | sed 's/declare -f //g')

  if [[ ${HOOK_GLOBAL_FILE} != "" && -f "${HOOK_GLOBAL_FILE}" ]]; then
    # shellcheck source=/dev/null
    source "${HOOK_GLOBAL_FILE:?}"
  fi

  if [[ -f "${HOOK_FILE:?}" ]]; then
    # shellcheck source=/dev/null
    source "${HOOK_FILE:?}"
  fi

  mapfile -t functions_after_hook < <(declare -F | sed 's/declare -f //g')

  _hook "${HOOK_PREFIX:?}pre" "$@"
  "$@"
  HOOK_LAST_EXIT_CODE=$?
  _hook "${HOOK_PREFIX:?}post" "$@"

  for f in "${functions_after_hook[@]}"; do
    if ! _hook_array_contains "$f" "${functions_before_hook[@]}"; then
      unset -f "$f"
    fi
  done

  return ${HOOK_LAST_EXIT_CODE:?}
}

_hook() {
  local prefix="${1:?'A prefix must be given'}"
  shift

  local index
  local -a args
  local arg
  local rest_args_start
  local rest_args_end
  local -a rest_args
  local hook_func

  args=("$@")
  hook_func="${prefix}"
  _hook_exec "${hook_func:?}" "${args[@]}"

  for ((index = 0; index < ${#args[@]}; index++)); do
    arg="${args[index]}"
    if [[ "${arg}" != '' ]]; then
      rest_args_start=${index+1}
      rest_args_end=${#args[@]}
      rest_args=("${args[@]:${rest_args_start:?}:${rest_args_end:?}}")
      hook_func="${hook_func:?}_${arg:?}"
      _hook_exec "${hook_func:?}" "${rest_args[@]}"
    fi
  done
}

_hook_exec() {
  local hook_func="${1:?'A hook function must be provided!'}"
  shift

  if [[ "$(type -t "${HOOK_GLOBAL_PREFIX:?}${hook_func:?}")" == 'function' ]]; then
    [[ "${HOOK_LOG}" == 'true' ]] && echo "[hook] executing \"${HOOK_GLOBAL_PREFIX:?}${hook_func}\" (${HOOK_GLOBAL_FILE})"
    "${HOOK_GLOBAL_PREFIX:?}${hook_func:?}" "$@"
    [[ "${HOOK_LOG}" == 'true' ]] && echo "[hook] finished executing \"${HOOK_GLOBAL_PREFIX:?}${hook_func}\" (${HOOK_GLOBAL_FILE})"
  fi

  if [[ "$(type -t "${hook_func:?}")" == 'function' ]]; then
    [[ "${HOOK_LOG}" == 'true' ]] && echo "[hook] executing \"${hook_func}\" (${HOOK_FILE:?})"
    "${hook_func:?}" "$@"
    [[ "${HOOK_LOG}" == 'true' ]] && echo "[hook] finished executing \"${hook_func}\" (${HOOK_FILE:?})"
  fi
}

_hook_array_contains() {
  local -r needle="$1"
  shift
  local -ra haystack=("$@")

  local item
  for item in "${haystack[@]}"; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done

  return 1
}

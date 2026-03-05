#!/usr/bin/env bash
# =============================================================================
#  wt.init.sh — Shell integration for wt
#
#  Source this file in your ~/.bashrc or ~/.zshrc.
#  Do NOT execute it directly.
#
#  Why is this needed?
#  A script runs in a subshell. Any `cd` inside it only affects that subshell
#  and is lost when the script exits. To actually change your shell's working
#  directory, the `cd` must happen in the current shell process.
#
#  How it works:
#  1. The `wt` binary emits "__WT_CD__:/some/path" when a directory change
#     is required.
#  2. This wrapper function intercepts that token, strips it from the visible
#     output, and runs `cd /some/path` in your current shell.
# =============================================================================

wt() {
  # ── Locate the wt binary ────────────────────────────────────────────────

  local _wt_bin

  # 1. Default location
  local _this_dir
  _this_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
  if [[ -x "${_this_dir}/../bin/wt" ]]; then
    _wt_bin="${_this_dir}/../bin/wt"
  # 2. Common install locations
  elif command -v _wt_impl &>/dev/null; then
    _wt_bin="_wt_impl"
  elif [[ -x "/usr/local/bin/wt" ]]; then
    _wt_bin="/usr/local/bin/wt"
  elif [[ -x "${HOME}/.local/bin/wt" ]]; then
    _wt_bin="${HOME}/.local/bin/wt"
  else
    echo "wt: binary not found. Check your PATH or reinstall." >&2
    return 1
  fi

  # ── Run the binary, capturing stdout/stderr separately ──────────────────

  local _tmpout _tmperr
  _tmpout="$(mktemp)" || { echo "wt: mktemp failed" >&2; return 1; }
  _tmperr="$(mktemp)" || { rm -f "$_tmpout"; echo "wt: mktemp failed" >&2; return 1; }

  # Forward colour intent: stdout is captured to a file inside this function,
  # so the binary's [ -t 1 ] check always fails. Pass WT_COLOR=1 when our
  # own stdout (the user's terminal) is a tty.
  local _color_env=""
  [ -t 1 ] && _color_env="WT_COLOR=1"

  env ${_color_env} "$_wt_bin" "$@" >"$_tmpout" 2>"$_tmperr"
  local _exit_code=$?

  # ── Extract the cd signal (if any) ──────────────────────────────────────

  local _cd_path
  _cd_path="$(grep "^__WT_CD__:" "$_tmpout" | tail -1 | sed 's/^__WT_CD__://')"

  # ── Print output without the signal line ────────────────────────────────

  grep -v "^__WT_CD__:" "$_tmpout"
  cat "$_tmperr" >&2

  # ── Clean up temp files ──────────────────────────────────────────────────

  rm -f "$_tmpout" "$_tmperr"

  # ── Perform the directory change in the current shell ───────────────────

  if [[ -n "$_cd_path" ]]; then
    if [[ -d "$_cd_path" ]]; then
      cd "$_cd_path" || {
        echo "wt: failed to cd into '${_cd_path}'" >&2
        return 1
      }
    else
      echo "wt: target directory does not exist: '${_cd_path}'" >&2
      return 1
    fi
  fi

  return $_exit_code
}

# Export so it is available in sub-shells (bash only; zsh ignores this for functions)
export -f wt 2>/dev/null || true

#!/usr/bin/env bash
# lib/status.sh — show lock file location, entry count, and rm override status

RMLOCK_FILE="${RMLOCK_FILE:-$HOME/.rm-lock}"

_rmlock_status() {
    echo "Lock file : $RMLOCK_FILE"

    if [[ ! -f "$RMLOCK_FILE" ]]; then
        echo "Status    : no lock file (rm is unprotected)"
        return 0
    fi

    # Count valid entries
    local count=0 line
    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%%#*}"
        line="${line//[[:space:]]/}"
        [[ -n "$line" ]] && count=$((count + 1))
    done < "$RMLOCK_FILE"

    echo "Entries   : $count"

    # Check if the rm override is active
    if declare -f rm &>/dev/null; then
        echo "Override  : active"
    else
        echo "Override  : inactive (source rm-lock in your .bashrc/.zshrc)"
    fi
}

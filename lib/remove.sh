#!/usr/bin/env bash
# lib/edit.sh — open ~/.rm-lock in $EDITOR

RMLOCK_FILE="${RMLOCK_FILE:-$HOME/.rm-lock}"

_rmlock_remove() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: rm-lock remove <path> [path2 ...]" >&2
        return 1
    fi

    [[ ! -f "$RMLOCK_FILE" ]] && {
        echo "[rm-lock] No lock file found at $RMLOCK_FILE" >&2
        return 1
    }

    local MKTEMP_BIN arg path tmp
    MKTEMP_BIN=$(command -p mktemp) || { echo "mktemp not found" >&2; return 1; }

    for arg in "$@"; do
        # Resolve . to current directory
        path=$([[ "$arg" == "." ]] && pwd || echo "$arg")

        if command -p grep -qxF -- "$path" "$RMLOCK_FILE"; then
            tmp=$MKTEMP_BIN
            echo "$(command -p grep -vxF -- "$path" "$RMLOCK_FILE")" > "$tmp"

            command -p mv -- "$tmp" "$RMLOCK_FILE"
            printf '[rm-lock] Removed lock: %s\n' "$path"
        else
            printf '[rm-lock] Not found: %s\n' "$path" >&2
        fi
    done
}

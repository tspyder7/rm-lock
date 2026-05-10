#!/usr/bin/env bash
# lib/add.sh — add paths to ~/.rm-lock

RMLOCK_FILE="${RMLOCK_FILE:-$HOME/.rm-lock}"

_rmlock_add() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: rm-lock add <path> [path2 ...]" >&2
        return 1
    fi

    touch "$RMLOCK_FILE"

    local arg path
    for arg in "$@"; do
        # Resolve to absolute path; reject if it doesn't exist
        path=$(realpath -- "$arg" 2>/dev/null) || {
            printf 'rm-lock add: path not found: %s\n' "$arg" >&2
            continue
        }

        if grep -qxF "$path" "$RMLOCK_FILE" 2>/dev/null; then
            printf 'rm-lock add: already protected: %s\n' "$path"
        else
            printf '%s\n' "$path" >> "$RMLOCK_FILE"
            printf 'rm-lock add: protected: %s\n' "$path"
        fi
    done
}

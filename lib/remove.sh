#!/usr/bin/env bash
# lib/remove.sh — remove paths from ~/.rm-lock

RMLOCK_FILE="${RMLOCK_FILE:-$HOME/.rm-lock}"

_rmlock_remove() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: rm-lock remove <path> [path2 ...]" >&2
        return 1
    fi

    [[ ! -f "$RMLOCK_FILE" ]] && {
        echo "rm-lock remove: no lock file found at $RMLOCK_FILE" >&2
        return 1
    }

    local arg path tmp
    for arg in "$@"; do
        path=$(realpath -- "$arg" 2>/dev/null) || path="$arg"

        if grep -qxF "$path" "$RMLOCK_FILE" 2>/dev/null; then
            tmp=$(grep -vxF "$path" "$RMLOCK_FILE")
            printf '%s\n' "$tmp" > "$RMLOCK_FILE"
            printf 'rm-lock remove: unprotected: %s\n' "$path"
        else
            printf 'rm-lock remove: not found: %s\n' "$path" >&2
        fi
    done
}

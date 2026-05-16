#!/usr/bin/env bash
# lib/add.sh — add paths to ~/.rm-lock

RMLOCK_FILE="${RMLOCK_FILE:-$HOME/.rm-lock}"

_rmlock_add() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: rm-lock add <path> [path2 ...]" >&2
        return 1
    fi

    if ! touch "$RMLOCK_FILE"; then
        echo "[rm-lock] Cannot write to $RMLOCK_FILE" >&2
        return 1
    fi

    local arg path

    for arg in "$@"; do
        # Resolve . to current directory
        path=$([[ "$arg" == "." ]] && pwd || echo "$arg")

        if grep -qxF -- "$path" "$RMLOCK_FILE" 2>/dev/null; then
            printf '[rm-lock] Already protected: %s\n' "$path"
        else
            printf '%s\n' "$path" >> "$RMLOCK_FILE"
            printf '[rm-lock] Added rm protection: %s\n' "$path"
        fi
    done
}

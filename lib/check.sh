#!/usr/bin/env bash
# lib/check.sh — rm override: checks global ~/.rm-lock before deleting

RMLOCK_FILE="${RMLOCK_FILE:-$HOME/.rm-lock}"

rm() {
    # Pass through in non-interactive shells (scripts, CI, etc.)
    [[ $- != *i* ]] && { command rm "$@"; return $?; }

    [[ $# -eq 0 ]] && return 0

    # No global lock file → behave normally
    [[ ! -f "$RMLOCK_FILE" ]] && { command rm "$@"; return $?; }

    local arg target violations=0

    for arg in "$@"; do
        [[ "$arg" == -* ]] && continue

        # Resolve to absolute path
        target=$(realpath -- "$arg" 2>/dev/null) || continue

        while IFS= read -r protected || [[ -n "$protected" ]]; do
            # Skip blank lines and comments
            protected="${protected%%#*}"           # strip inline comments
            protected="${protected//[[:space:]]/}" # strip whitespace
            [[ -z "$protected" ]] && continue

            if [[ "$target" == "$protected" ]]; then
                printf '[rm-lock]: "%s" is protected by %s\n' "$arg" "$RMLOCK_FILE" >&2
                violations=1
                break
            fi
        done < "$RMLOCK_FILE"
    done

    [[ $violations -eq 1 ]] && return 1
    command rm "$@"
}

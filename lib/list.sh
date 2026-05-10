#!/usr/bin/env bash
# lib/list.sh — list all protected paths in ~/.rm-lock

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

RMLOCK_FILE="${RMLOCK_FILE:-$HOME/.rm-lock}"

log_error() {
    printf "${RED}%s\n${NC}" "$1" >&2
}

log_success() {
    printf "${GREEN}%s\n${NC}" "$1"
}

_rmlock_list() {
    if [[ ! -f "$RMLOCK_FILE" ]]; then
        echo "rm-lock: no lock file at $RMLOCK_FILE (nothing protected)"
        return 0
    fi

    local entries=0 line path

    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%%#*}"
        line="${line//[[:space:]]/}"
        [[ -z "$line" ]] && continue

        entries=$((entries + 1))

        # Show whether the path currently exists
        if [[ -e "$line" ]]; then
            log_success "  $line"
        else
            log_error "  $line"
        fi
    done < "$RMLOCK_FILE"

    [[ $entries -eq 0 ]] && echo "rmlock: lock file exists but has no entries"
}

#!/usr/bin/env bash
# lib/list.sh — list all protected paths in ~/.rm-lock

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
NC=$'\033[0m'

RMLOCK_FILE="${RMLOCK_FILE:-$HOME/.rm-lock}"

log_error() {
    printf '%b\n' "${RED}$1${NC}" >&2
}

log_success() {
    printf '%b\n' "${GREEN}$1${NC}"
}

_rmlock_list() {
    if [[ ! -f "$RMLOCK_FILE" ]]; then
        echo "rm-lock: no lock file at $RMLOCK_FILE (nothing protected)"
        return 0
    fi

    local entries=0 line

    while IFS= read -r line || [[ -n "$line" ]]; do

        # skip comments
        [[ "$line" =~ ^[[:space:]]*# ]] && continue

        # trim leading whitespace
        line="${line#"${line%%[![:space:]]*}"}"

        # trim trailing whitespace
        line="${line%"${line##*[![:space:]]}"}"

        [[ -z "$line" ]] && continue

        ((entries++))

        if [[ -e "$line" ]]; then
            log_success "  $line"
        else
            log_error "  $line"
        fi

    done < "$RMLOCK_FILE"

    if [[ $entries -eq 0 ]]; then
        echo "rm-lock: lock file exists but has no entries"
    fi
}

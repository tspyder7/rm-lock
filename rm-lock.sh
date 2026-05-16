#!/usr/bin/env bash
# rm-lock — global rm protection via ~/.rm-lock
#
# Source this file in ~/.bashrc or ~/.zshrc:
#   source /path/to/rm-lock/rm-lock.sh
#
# It does two things:
#   1. Overrides `rm` to check ~/.rm-lock before every deletion
#   2. Registers the `rm-lock` command for managing the lock file

if [ -n "$BASH_SOURCE" ]; then
    RMLOCK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "$ZSH_VERSION" ]; then
    RMLOCK_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
fi
RMLOCK_FILE="${RMLOCK_FILE:-$HOME/.rm-lock}"

# Source all modules
for _mod in check add remove list status edit help; do
    source "$RMLOCK_DIR/lib/$_mod.sh" || {
        echo "rm-lock: failed to load lib/$_mod.sh" >&2
        return 1
    }
done
unset _mod

# Main dispatcher
rmlock() {
    local cmd="$1"
    [[ $# -gt 0 ]] && shift
    cmd="${cmd:-help}"

    case "$cmd" in
        add)     _rmlock_add    "$@" ;;
        remove)  _rmlock_remove "$@" ;;
        list)    _rmlock_list        ;;
        status)  _rmlock_status      ;;
        edit)    _rmlock_edit        ;;
        help|--help|-h) _rmlock_help ;;
        *)
            printf 'rm-lock: unknown command "%s"\n' "$cmd" >&2
            _rmlock_help >&2
            return 1
            ;;
    esac
}

# Public command — use function aliasing
eval 'rm-lock() { rmlock "$@"; }'

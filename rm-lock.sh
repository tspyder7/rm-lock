#!/usr/bin/env bash
# rm-lock — global rm protection via ~/.rm-lock
#
# Source this file in ~/.bashrc or ~/.zshrc:
#   source /path/to/rm-lock/rm-lock.sh
#
# It does two things:
#   1. Overrides `rm` to check ~/.rm-lock before every deletion
#   2. Registers the `rm-lock` command for managing the lock file

RMLOCK_DIR="${RMLOCK_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
RMLOCK_FILE="${RMLOCK_FILE:-$HOME/.rm-lock}"

# Source all modules
for _mod in check add remove list status edit; do
    source "$RMLOCK_DIR/lib/$_mod.sh" || {
        echo "rm-lock: failed to load lib/$_mod.sh" >&2
        return 1
    }
done
unset _mod

# Main dispatcher
rmlock() {
    local cmd="${1:-help}"
    shift || true

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

_rmlock_help() {
    cat <<'EOF'
rm-lock — global rm nuke guard

USAGE
  rm-lock <command> [args]

COMMANDS
  add <path> [...]    Protect one or more absolute paths
  remove <path> [...] Unprotect one or more paths
  list                Show all protected paths
  status              Show lock file location and override status
  edit                Open lock file in $EDITOR
  help                Show this help

LOCK FILE
  Default: ~/.rm-lock
  Override: export RMLOCK_FILE=/custom/path

EXAMPLES
  rm-lock add ~/projects/data ~/projects/models
  rm-lock remove ~/projects/old-data
  rm-lock list
  rm-lock status

NOTES
  • Paths are stored as absolute, resolved paths
  • Only the exact path is protected — subdirectories are NOT blocked
  • Protection applies to interactive shells only
  • Scripts and CI pipelines bypass the override automatically
EOF
}

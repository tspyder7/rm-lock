#!/usr/bin/env bash
# lib/help.sh — utility for help

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

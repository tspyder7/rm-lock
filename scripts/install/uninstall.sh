#!/usr/bin/env bash
# uninstall.sh — remove rm-lock installation
# Keeps ~/.rm-lock file intact

set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/lib/rm-lock}"
PROFILED_FILE="/etc/profile.d/rm-lock.sh"

echo "Uninstalling rm-lock..."
echo

# ── remove profile.d configuration ─────────────────────────────────────────

if [[ -f "$PROFILED_FILE" ]]; then
    sudo rm -f "$PROFILED_FILE"
    echo "✓ Removed $PROFILED_FILE"
else
    echo "  (not found: $PROFILED_FILE)"
fi

# ── unset functions ───────────────────────────────────────────────────────

utils=("add" "check" "edit" "help" "list" "remove" "status")

for util in "${utils[@]}"; do
    unset -f "_rmlock_$util" 2>/dev/null || true
done

unset -f "rm-lock" 2>/dev/null || true

echo "✓ Functions unset"

# ── remove installation directory ──────────────────────────────────────────

if [[ -d "$INSTALL_DIR" ]]; then
    rm -rf "$INSTALL_DIR"
    echo "✓ Removed $INSTALL_DIR"
else
    echo "  (not found: $INSTALL_DIR)"
fi

# ── note about lock file ───────────────────────────────────────────────────

echo
echo "Lock file preserved (if any):"
RMLOCK_FILE="${RMLOCK_FILE:-$HOME/.rm-lock}"
if [[ -f "$RMLOCK_FILE" ]]; then
    echo "  $RMLOCK_FILE"
else
    echo "  (none found)"
fi
echo
echo "Done!"

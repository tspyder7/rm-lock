#!/usr/bin/env bash
# uninstall.sh — remove rm-lock installation
# Keeps ~/.rm-lock file intact

set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/lib/rm-lock}"

echo "Uninstalling rm-lock..."
echo

# ── remove installation directory ──────────────────────────────────────────

if [[ -d "$INSTALL_DIR" ]]; then
    rm -rf "$INSTALL_DIR"
    echo "✓ Removed $INSTALL_DIR"
else
    echo "  (not found: $INSTALL_DIR)"
fi

# ── clean shell configs ────────────────────────────────────────────────────

for rc in ~/.bashrc ~/.zshrc; do
    [[ ! -f "$rc" ]] && continue
    if grep -qF "rm-lock" "$rc" 2>/dev/null; then
        sed -i.bak '/rm-lock/d' "$rc"
        echo "✓ Cleaned $rc (backup: ${rc}.bak)"
    fi
done

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

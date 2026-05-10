#!/usr/bin/env bash
# install.sh — install rm-lock globally

set -euo pipefail

INSTALL_DIR="${1:-$HOME/.local/lib/rm-lock}"
SHELL_CONFIGS=()

# Detect shell config files
[[ -f "$HOME/.bashrc" ]] && SHELL_CONFIGS+=("$HOME/.bashrc")
[[ -f "$HOME/.zshrc"  ]] && SHELL_CONFIGS+=("$HOME/.zshrc")

SOURCE_LINE="source \"$INSTALL_DIR/rm-lock.sh\"  # rm-lock"

# ── install files ──────────────────────────────────────────────────────────

echo "Installing to $INSTALL_DIR ..."
mkdir -p "$INSTALL_DIR/lib"

cp rm-lock.sh        "$INSTALL_DIR/rm-lock.sh"
cp lib/check.sh      "$INSTALL_DIR/lib/check.sh"
cp lib/add.sh        "$INSTALL_DIR/lib/add.sh"
cp lib/remove.sh     "$INSTALL_DIR/lib/remove.sh"
cp lib/list.sh       "$INSTALL_DIR/lib/list.sh"
cp lib/status.sh     "$INSTALL_DIR/lib/status.sh"
cp lib/edit.sh       "$INSTALL_DIR/lib/edit.sh"

echo "  ✓ files copied"

# ── add source line to shell configs ───────────────────────────────────────

for cfg in "${SHELL_CONFIGS[@]}"; do
    if grep -qF "rm-lock" "$cfg" 2>/dev/null; then
        echo "  ✓ $cfg already configured"
    else
        printf '\n%s\n' "$SOURCE_LINE" >> "$cfg"
        echo "  ✓ added source line to $cfg"
    fi
done

# ── done ───────────────────────────────────────────────────────────────────

echo
echo "Done! Reload your shell or run:"
echo "  source $INSTALL_DIR/rm-lock.sh"
echo
echo "Then protect paths with:"
echo "  rm-lock add ~/important/data"

#!/usr/bin/env bash
# install.sh — install rm-lock globally

set -euo pipefail

INSTALL_DIR="${1:-$HOME/.local/lib/rm-lock}"
PROFILED_FILE="/etc/profile.d/rm-lock.sh"

# ── check if already installed ──────────────────────────────────────────────

if [[ -d "$INSTALL_DIR" ]] && [[ -f "$PROFILED_FILE" ]]; then
    echo "rm-lock is already installed at $INSTALL_DIR"
    exit 0
fi

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
cp lib/help.sh       "$INSTALL_DIR/lib/help.sh"

echo "  ✓ files copied"

# ── configure shell integration ────────────────────────────────────────────

echo "Configuring rm-lock shell integration..."

sudo bash -c "cat > \"$PROFILED_FILE\" <<'EOF'
#!/bin/sh

if [ -f \"$INSTALL_DIR/rm-lock.sh\" ]; then
    . \"$INSTALL_DIR/rm-lock.sh\"
fi
EOF"

sudo chmod 755 "$PROFILED_FILE"

echo "  ✓ created $PROFILED_FILE"

# ── done ───────────────────────────────────────────────────────────────────

echo
echo "✓ rm-lock installed successfully"
echo
echo "Open a new shell or run:"
echo "  source /etc/profile"
echo
echo "Then protect paths with:"
echo "  rm-lock add ~/important/data"

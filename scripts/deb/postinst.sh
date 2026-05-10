#!/bin/bash
# DEB post-install script — configure shell environments

set -e

INSTALL_DIR="/usr/local/lib/rm-lock"
SOURCE_LINE="source \"$INSTALL_DIR/rm-lock.sh\"  # rm-lock"

echo "Configuring shell environments..."

# Patch user shell configs
for rc in ~/.bashrc ~/.zshrc; do
    [[ ! -f "$rc" ]] && continue
    if grep -qF "rm-lock" "$rc" 2>/dev/null; then
        echo "  ✓ already configured in $rc"
    else
        printf '\n%s\n' "$SOURCE_LINE" >> "$rc"
        echo "  ✓ patched $rc"
    fi
done

echo
echo "Installation complete! Reload your shell:"
echo "  source ~/.bashrc"
echo
echo "Then protect paths with:"
echo "  rm-lock add ~/important/data"

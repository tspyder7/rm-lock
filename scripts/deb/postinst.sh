#!/bin/bash
# DEB post-install script

set -e

INSTALL_DIR="/usr/local/lib/rm-lock"
PROFILED_FILE="/etc/profile.d/rm-lock.sh"

# ── check if already installed ──────────────────────────────────────────────

if [[ -d "$INSTALL_DIR" ]] && [[ -f "$PROFILED_FILE" ]]; then
    echo "rm-lock is already installed"
    exit 0
fi

echo "Configuring rm-lock shell integration..."

cat > "$PROFILED_FILE" <<EOF
#!/bin/sh

if [ -f "$INSTALL_DIR/rm-lock.sh" ]; then
    . "$INSTALL_DIR/rm-lock.sh"
fi
EOF

chmod 755 "$PROFILED_FILE"

echo
echo "✓ rm-lock installed successfully"
echo
echo "Open a new shell or run:"
echo "  source /etc/profile"
echo
echo "Then protect paths with:"
echo "  rm-lock add ~/important/data"

#!/bin/bash
# DEB pre-remove script — clean up shell configurations
# Keeps ~/.rm-lock file intact

set -e

echo "Cleaning up shell configurations..."

# Remove sourcing lines from shell configs
for rc in ~/.bashrc ~/.zshrc; do
    [[ ! -f "$rc" ]] && continue
    if grep -qF "rm-lock" "$rc" 2>/dev/null; then
        sed -i.bak '/rm-lock/d' "$rc"
        echo "  ✓ cleaned $rc (backup: ${rc}.bak)"
    fi
done

echo "Shell configs cleaned. Lock file preserved at ~/.rm-lock"

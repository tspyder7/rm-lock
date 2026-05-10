#!/usr/bin/env bash
# build.sh — build rm-lock DEB package
#
# Usage:
#   bash scripts/deb/build.sh          # create rm-lock_1.0.0_all.deb in dist/
#   bash scripts/deb/build.sh 2.0.0    # create rm-lock_2.0.0_all.deb in dist/

set -euo pipefail

VERSION="${1:-1.0.0}"
PACKAGE_NAME="rm-lock"
OUTPUT="dist/${PACKAGE_NAME}_${VERSION}_all.deb"

if ! command -v fpm &>/dev/null; then
    echo "Error: fpm not found. Install with: gem install fpm"
    exit 1
fi

echo "Building $OUTPUT ..."
echo

# Create temporary staging directory
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

STAGEDIR="$TMPDIR/stage"
mkdir -p "$STAGEDIR/usr/local/lib/rm-lock/lib"

# Copy files to staging
cp rm-lock.sh "$STAGEDIR/usr/local/lib/rm-lock/"
cp lib/*.sh "$STAGEDIR/usr/local/lib/rm-lock/lib/"

# Make scripts executable
chmod +x "$STAGEDIR/usr/local/lib/rm-lock/rm-lock.sh"
chmod +x "$STAGEDIR/usr/local/lib/rm-lock/lib"/*.sh

# Build DEB
fpm \
  -s dir \
  -t deb \
  -n "$PACKAGE_NAME" \
  -v "$VERSION" \
  -C "$STAGEDIR" \
  --after-install scripts/deb/postinst.sh \
  --before-remove scripts/deb/prerm.sh \
  -m "rm-lock contributors" \
  -d "bash" \
  --description "Global nuke guard for rm" \
  --homepage "https://github.com/tspyder7/rm-lock" \
  --license "MIT" \
  .

echo
echo "✓ Created $OUTPUT"
echo
echo "Install with:"
echo "  sudo dpkg -i $OUTPUT"
echo
echo "Uninstall with:"
echo "  sudo dpkg -r rm-lock"

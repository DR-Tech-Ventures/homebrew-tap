#!/bin/bash
# Points the cask at a new iCloud GUI release.
#
#   ./bump.sh        # whatever is published as the latest release
#   ./bump.sh 1.5    # a specific version
#
# Every release needs this. Homebrew verifies the checksum before it installs anything,
# so a cask still carrying the previous version's sha256 fails every install outright --
# it does not quietly serve the old build. Two edits, one of which is a 64-character
# hash, is exactly the job to stop doing by hand.
set -euo pipefail
cd "$(dirname "$0")"

REPO="DR-Tech-Ventures/icloud-gui"
CASK="Casks/icloud-gui.rb"
ASSET="iCloud-GUI.dmg"

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
    VERSION="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
               | sed -n 's/.*"tag_name"[^"]*"v\{0,1\}\([^"]*\)".*/\1/p' | head -1)"
    [ -n "$VERSION" ] || { echo "Could not read the latest release tag from GitHub." >&2; exit 1; }
    echo "==> Latest release: $VERSION"
fi

CURRENT="$(sed -n 's/^  version "\(.*\)"$/\1/p' "$CASK" | head -1)"
[ -n "$CURRENT" ] || { echo "Could not read the current version out of $CASK." >&2; exit 1; }

if [ "$CURRENT" = "$VERSION" ]; then
    echo "Cask is already at $VERSION. Nothing to do."
    exit 0
fi

URL="https://github.com/$REPO/releases/download/v$VERSION/$ASSET"
echo "==> Hashing $URL"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
# curl -f so a 404 for a version that was never released fails here rather than writing
# the hash of GitHub's error page into the cask.
curl -fsSL -o "$TMP/$ASSET" "$URL"
SHA="$(shasum -a 256 "$TMP/$ASSET" | awk '{print $1}')"
# 64 hex characters or nothing. A truncated read must not reach the cask, where it would
# look exactly like a correct hash until someone tried to install.
if [ "${#SHA}" -ne 64 ] || [ -n "${SHA//[0-9a-f]/}" ]; then
    echo "Refusing to write an implausible checksum: '$SHA'" >&2
    exit 1
fi
echo "    $SHA"

# Anchored to the stanza's own line shape, so nothing inside a comment can match.
sed -i '' -e "s|^  version \".*\"$|  version \"$VERSION\"|" \
          -e "s|^  sha256 \".*\"$|  sha256 \"$SHA\"|" "$CASK"

ruby -c "$CASK" >/dev/null

# Confirm the file really says what we think, rather than trusting sed's exit code.
[ "$(sed -n 's/^  version "\(.*\)"$/\1/p' "$CASK" | head -1)" = "$VERSION" ] \
    || { echo "The version stanza did not take. Check $CASK by hand." >&2; exit 1; }
grep -q "^  sha256 \"$SHA\"$" "$CASK" \
    || { echo "The sha256 stanza did not take. Check $CASK by hand." >&2; exit 1; }

echo "==> $CURRENT -> $VERSION"
git --no-pager diff --stat "$CASK"
echo
echo "This script does NOT touch depends_on. If $VERSION raised the minimum macOS"
echo "version, edit that stanza too -- Homebrew's symbol for a release is its own, not"
echo "Apple's marketing name:"
echo "    brew ruby -e 'require \"macos_version\"; puts MacOSVersion::SYMBOLS'"
echo
echo "Then: git commit -am \"icloud-gui $VERSION\" && git push"

#!/bin/bash
# setup_game.sh — Deploy mystery game files to /opt/comets-mystery/
#
# Safe to re-run; overwrites any existing installation.
# All game files are set read-only so students cannot modify them.
#
# Usage:
#   sudo bash setup/setup_game.sh

set -e

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
GAME_SOURCE="$REPO_ROOT/game"
GAME_DEST="/opt/comets-mystery"

if [ ! -d "$GAME_SOURCE" ]; then
    echo "ERROR: Game source directory not found: $GAME_SOURCE" >&2
    echo "       Run this script from inside the cloned repository." >&2
    exit 1
fi

echo "=== Mason High School Terminal Mystery — Game Setup ==="
echo ""
echo "Source : $GAME_SOURCE"
echo "Dest   : $GAME_DEST"
echo ""

# Remove old installation
if [ -d "$GAME_DEST" ]; then
    echo "Removing previous installation..."
    # Make sure any previously locked dirs are writable before removal
    find "$GAME_DEST" -type d -exec chmod u+w {} \;
    rm -rf "$GAME_DEST"
fi

mkdir -p "$GAME_DEST"

# Use tar pipe to copy everything, including hidden dot-files
echo "Copying game files..."
(cd "$GAME_SOURCE" && tar cf - .) | (cd "$GAME_DEST" && tar xf -)

# Lock down ownership
chown -R root:root "$GAME_DEST"

# Files: read-only for everyone (444 = r--r--r--)
find "$GAME_DEST" -type f -exec chmod 444 {} \;

# Directories: read + execute for everyone, no write (555 = r-xr-xr-x)
find "$GAME_DEST" -type d -exec chmod 555 {} \;

echo ""
echo "Installed file tree:"
find "$GAME_DEST" | sort | sed 's|'"$GAME_DEST"'||' | head -50
echo ""
echo "Setup complete. Game is live at $GAME_DEST"

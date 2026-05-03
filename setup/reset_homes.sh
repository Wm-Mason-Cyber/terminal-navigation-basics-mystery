#!/bin/bash
# reset_homes.sh — Reset student home directories between class periods
#
# For each user in the CSV:
#   - Deletes ~/solution/  (removes their submitted work)
#   - Deletes ~/scratch/   (removes any leftover junk)
#   - Recreates ~/scratch/ with fresh placeholder files
#
# Run this between class periods so each group starts clean.
#
# Usage:
#   sudo bash setup/reset_homes.sh setup/students.csv

set -e

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root." >&2
    exit 1
fi

CSV_FILE="${1:-}"

if [ -z "$CSV_FILE" ] || [ ! -f "$CSV_FILE" ]; then
    echo "Usage: sudo bash $0 <students.csv>" >&2
    exit 1
fi

echo "This will DELETE all student solution/ and scratch/ directories."
echo "This cannot be undone."
read -r -p "Type 'yes' to continue: " confirm
if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

echo ""

reset=0
skipped=0
line_num=0

while IFS=',' read -r username rest; do
    line_num=$((line_num + 1))
    [ "$line_num" -eq 1 ] && [ "$username" = "username" ] && continue
    [ -z "$username" ] && continue

    username=$(echo "$username" | tr -d '[:space:]')

    if ! id "$username" &>/dev/null; then
        echo "  [skip]  $username — user not found"
        skipped=$((skipped + 1))
        continue
    fi

    home_dir="/home/$username"

    rm -rf "$home_dir/solution"
    rm -rf "$home_dir/scratch"

    # Recreate scratch/
    mkdir -p "$home_dir/scratch/old_notes"

    cat > "$home_dir/scratch/test.txt" << 'SCRATCHEOF'
Just a scratch file. Nothing useful here.

When you are ready to clean up, delete this whole folder:
  rm -r scratch
SCRATCHEOF

    cat > "$home_dir/scratch/old_notes/reminder.txt" << 'SCRATCHEOF'
Old notes — safe to delete.
Try:  cd ~  then  rm -r scratch
SCRATCHEOF

    chown -R "$username:$username" "$home_dir/scratch"

    echo "  [reset] $username"
    reset=$((reset + 1))

done < "$CSV_FILE"

echo ""
echo "Done.  Reset: $reset   Skipped (not found): $skipped"

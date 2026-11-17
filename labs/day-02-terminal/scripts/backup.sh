#!/usr/bin/env bash
#
# backup.sh — archive a directory into a timestamped tarball.
#
# Usage:   ./scripts/backup.sh <source-dir> [dest-dir]
# Example: ./scripts/backup.sh ~/projects ~/backups
#
# Run it with: chmod +x scripts/backup.sh && ./scripts/backup.sh ./labs
#
# Requirements to satisfy yourself:
#   - fails loudly on any error (set -euo pipefail)
#   - refuses to run with no arguments, prints usage, exits non-zero
#   - refuses to run if the source directory does not exist
#   - destination defaults to ../backups
#   - output filename includes a timestamp (date +%Y%m%d-%H%M%S)
#   - prints what it created, so you can verify it

set -euo pipefail

usage() {
  echo "usage: $(basename "$0") <source-dir> [dest-dir]" >&2
}

# TODO: validate $# and $1, then create the tarball.
# Hint: mkdir -p, then tar -czf "$dest/backup-$stamp.tar.gz" -C "$(dirname "$src")" "$(basename "$src")"

echo "not implemented yet" >&2
exit 1

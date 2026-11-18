#!/usr/bin/env bash
#
# backup.sh — archive a directory into a timestamped .tar.gz
#
# Usage:   ./scripts/backup.sh <source-dir> [dest-dir]
# Example: ./scripts/backup.sh ~/projects ~/backups
#
# dest-dir defaults to <parent-of-source>/backups
# Exit: 0 success · 1 bad source/destination · 2 bad usage

set -euo pipefail

usage() {
  printf 'usage: %s <source-dir> [dest-dir]\n' "$(basename "$0")" >&2
  printf '  dest-dir defaults to <parent-of-source>/backups\n' >&2
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

# --- arguments -------------------------------------------------------------
[[ $# -ge 1 && $# -le 2 ]] || { usage; exit 2; }

src=${1%/}
[[ -n $src ]] || { usage; exit 2; }
dest=${2:-$(dirname "$src")/backups}

# --- preconditions ---------------------------------------------------------
[[ -d $src ]] || die "source directory not found: $src"
[[ -r $src ]] || die "source directory not readable: $src"

mkdir -p "$dest"
[[ -w $dest ]] || die "destination not writable: $dest"

# --- archive ---------------------------------------------------------------
stamp=$(date +%Y%m%d-%H%M%S)
base=$(basename "$src")
archive="$dest/backup-${stamp}-${base}.tar.gz"

tar -czf "$archive" -C "$(dirname "$src")" "$base"

size=$(du -h "$archive" | cut -f1)
printf 'created %s (%s)\n' "$archive" "$size"

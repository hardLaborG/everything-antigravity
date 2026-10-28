#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./install.sh /path/to/target-repo [--link | --copy]

TARGET_DIR="${1:-}"
MODE="${2:---link}"

if [ -z "$TARGET_DIR" ]; then
  echo "Usage: $0 <path-to-target-repo> [--link | --copy]"
  exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Directory '$TARGET_DIR' does not exist."
  exit 1
fi

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo "==> Source template: $SOURCE_DIR"
echo "==> Target repo:     $TARGET_DIR"
echo "==> Mode:            $MODE"

link_or_copy() {
  local src="$1"
  local dest="$2"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "  [warn] Destination '$dest' already exists. Backing up to '${dest}.bak'..."
    rm -rf "${dest}.bak"
    mv "$dest" "${dest}.bak"
  fi

  if [ "$MODE" = "--link" ]; then
    ln -s "$src" "$dest"
    echo "  [ok] Symlinked: $dest -> $src"
  else
    cp -R "$src" "$dest"
    echo "  [ok] Copied: $src -> $dest"
  fi
}

# 1. Install .agent and .agents
link_or_copy "$SOURCE_DIR/.agent" "$TARGET_DIR/.agent"
link_or_copy "$SOURCE_DIR/.agents" "$TARGET_DIR/.agents"

# 2. Configure Git isolation (optional safety guard)
GIT_DIR="$TARGET_DIR/.git"
if [ -d "$GIT_DIR" ]; then
  EXCLUDE_FILE="$GIT_DIR/info/exclude"
  mkdir -p "$GIT_DIR/info"
  touch "$EXCLUDE_FILE"

  for entry in ".agent" ".agents"; do
    if ! grep -q "^$entry" "$EXCLUDE_FILE"; then
      echo "$entry" >> "$EXCLUDE_FILE"
      echo "  [git] Added '$entry' to .git/info/exclude (local ignore, won't pollute team repo)"
    fi
  done
fi

echo "==> Successfully installed Antigravity rules and skills to $TARGET_DIR!"
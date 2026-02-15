#!/bin/bash
# Fix vendor packages that were extracted with an extra nested folder (e.g. author-package-hash/)
cd "$(dirname "$0")/vendor" || exit 1
for pkg in */*/; do
  [ -d "$pkg" ] || continue
  # Find single subdir matching *-*-* (e.g. ezyang-htmlpurifier-b287d2a)
  sub=$(find "$pkg" -maxdepth 1 -type d -name '*-*-*' 2>/dev/null | head -1)
  [ -z "$sub" ] && continue
  subbase=$(basename "$sub")
  # Copy contents from subdir to pkg root (so library/, src/ etc appear in pkg)
  (cd "$pkg" && for f in "$subbase"/*; do [ -e "$f" ] && cp -R "$f" .; done)
  (cd "$pkg" && for f in "$subbase"/.*; do [ -e "$f" ] && [ "$(basename "$f")" != "." ] && [ "$(basename "$f")" != ".." ] && cp -R "$f" .; done 2>/dev/null; true)
done
echo "Done."

#!/usr/bin/env bash
# Render a resume HTML file to PDF with headless Chrome, then print the page count.
# Usage: render_resume.sh <input.html> <output.pdf>
set -euo pipefail

in="${1:?usage: render_resume.sh <input.html> <output.pdf>}"
out="${2:?usage: render_resume.sh <input.html> <output.pdf>}"
chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

[ -x "$chrome" ] || { echo "Google Chrome not found at $chrome" >&2; exit 1; }
[ -f "$in" ] || { echo "No such file: $in" >&2; exit 1; }

abs_in="$(cd "$(dirname "$in")" && pwd)/$(basename "$in")"
profile="$(mktemp -d)"
trap 'rm -rf "$profile"' EXIT

"$chrome" --headless=new --disable-gpu --no-pdf-header-footer \
  --user-data-dir="$profile" --print-to-pdf="$out" "file://$abs_in" \
  >/dev/null 2>&1

python3 -I -c '
import re, sys
data = open(sys.argv[1], "rb").read()
print("pages:", len(re.findall(rb"/Type\s*/Page[^s]", data)))
' "$out"

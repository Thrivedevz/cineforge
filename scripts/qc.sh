#!/usr/bin/env bash
# qc.sh: quality control gate for a finished episode MP4.
#
# Checks:
#   1. Black frames: blackdetect scan, FAIL only if total black duration
#      exceeds 1.0 second (short blacks are reported, not failed).
#   2. Full decode: ffmpeg -v error decode to null, FAIL on any error output.
#   3. Loudness: integrated loudness via loudnorm dual-pass JSON, WARN if far
#      from -16 LUFS (target of the voice post chain).
#   4. File size: WARN if over 900 MB (do not fail).
#
# Exits nonzero on failure (black over threshold or decode errors).
#
# Usage:
#   qc.sh file.mp4
#
# Env: none. No credentials needed.

set -euo pipefail

PROG="$(basename "$0")"

usage() {
  cat <<EOF
Usage: $PROG file.mp4

Quality control checks for a finished episode MP4:

  1. Black scan:    blackdetect=d=0.5:pic_th=0.98, FAIL if total black
                    duration > 1.0s (shorter blacks are reported only).
  2. Full decode:   decode the whole file to null, FAIL on any error.
  3. Loudness:      loudnorm dual-pass JSON, WARN if integrated loudness is
                    far from -16 LUFS.
  4. File size:     WARN if over 900 MB (does not fail).

Exit status is nonzero on FAIL of check 1 or 2. A PASS/FAIL summary is
printed per check.

Example:
  $PROG episode.mp4
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage; exit 0
fi

[[ $# -eq 1 ]] || { echo "$PROG: need exactly one file.mp4" >&2; usage >&2; exit 2; }

FILE="$1"
[[ -f "$FILE" ]] || { echo "$PROG: file not found: $FILE" >&2; exit 1; }
command -v ffmpeg >/dev/null 2>&1 || { echo "$PROG: ffmpeg not found on PATH" >&2; exit 1; }

FAIL=0

echo "== QC: $FILE =="

# --- Check 1: black frames ---
echo "--- [1/4] black scan (blackdetect=d=0.5:pic_th=0.98) ---"
BLACK_LOG="$(ffmpeg -hide_banner -i "$FILE" \
  -vf "blackdetect=d=0.5:pic_th=0.98" -an -f null - 2>&1 || true)"
echo "$BLACK_LOG" | grep -i "black_start" || echo "(no black segments reported)"
TOTAL_BLACK="$(echo "$BLACK_LOG" | grep -o "black_duration:[0-9.]*" | cut -d: -f2 | \
  python3 -c "import sys; print(sum(float(l.strip()) for l in sys.stdin))" 2>/dev/null || echo 0)"
TOTAL_BLACK="${TOTAL_BLACK:-0}"
echo "total black duration: ${TOTAL_BLACK}s (threshold: 1.0s)"
if python3 -c "import sys; sys.exit(0 if float(sys.argv[1]) > 1.0 else 1)" "$TOTAL_BLACK"; then
  echo "RESULT: FAIL (black over threshold)"
  FAIL=1
else
  echo "RESULT: PASS"
fi

# --- Check 2: full decode ---
echo "--- [2/4] full decode check ---"
DECODE_ERR="$(ffmpeg -v error -i "$FILE" -f null - 2>&1 || true)"
if [[ -n "$DECODE_ERR" ]]; then
  echo "$DECODE_ERR"
  echo "RESULT: FAIL (decode errors)"
  FAIL=1
else
  echo "(decoded cleanly, no error output)"
  echo "RESULT: PASS"
fi

# --- Check 3: loudness ---
echo "--- [3/4] loudness (loudnorm dual-pass) ---"
LJSON="$(ffmpeg -hide_banner -i "$FILE" -map a:0 \
  -af "loudnorm=I=-16:TP=-1.5:LRA=11:print_format=json" -f null - 2>&1 \
  | python3 -c "
import sys, json, re
blob = sys.stdin.read()
m = re.search(r'\{.*\}', blob, re.S)
print(m.group(0) if m else '{}')
" || echo '{}')"
INTEGRATED="$(echo "$LJSON" | python3 -c "import sys,json; print(json.load(sys.stdin).get('input_i','?'))" 2>/dev/null || echo '?')"
TPK="$(echo "$LJSON" | python3 -c "import sys,json; print(json.load(sys.stdin).get('input_tp','?'))" 2>/dev/null || echo '?')"
echo "integrated loudness: ${INTEGRATED} LUFS (target: -16), true peak: ${TPK} dBTP"
if [[ "$INTEGRATED" == "?" ]]; then
  echo "RESULT: WARN (could not measure loudness)"
else
  FAR="$(python3 -c "i=float('$INTEGRATED'); print('yes' if abs(i+16) > 2.0 else 'no')")"
  if [[ "$FAR" == "yes" ]]; then
    echo "RESULT: WARN (far from -16 LUFS)"
  else
    echo "RESULT: PASS"
  fi
fi

# --- Check 4: file size guardrail ---
echo "--- [4/4] file size guardrail (900 MB) ---"
SIZE="$(stat -c%s "$FILE" 2>/dev/null || stat -f%z "$FILE")"
HUMAN="$(numfmt --to=iec "$SIZE" 2>/dev/null || echo "${SIZE} bytes")"
echo "size: $HUMAN ($SIZE bytes)"
if [[ "$SIZE" -gt 943718400 ]]; then
  echo "RESULT: WARN (over 900 MB, may choke some players)"
else
  echo "RESULT: PASS"
fi

echo "== QC summary =="
if [[ "$FAIL" -ne 0 ]]; then
  echo "OVERALL: FAIL"
  exit 1
fi
echo "OVERALL: PASS"

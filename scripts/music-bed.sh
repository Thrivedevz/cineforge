#!/usr/bin/env bash
# music-bed.sh: generate a fully procedural, original dark ambient drone.
#
# 100% synthesized inside ffmpeg (no external files, no samples), so there
# is zero copyright-claim risk. A stack of five sine tones
# (55, 110, 130.81, 164.81, 220 Hz, a dark A-minor voicing) is mixed down,
# then shaped with tremolo, a lowpass at 800 Hz, a multi-tap echo, and a
# 7-second fade out at the end.
#
# Usage:
#   music-bed.sh DURATION_SECONDS out.wav
#
# Env: none. No credentials needed.

set -euo pipefail

PROG="$(basename "$0")"

usage() {
  cat <<EOF
Usage: $PROG DURATION_SECONDS out.wav

Generate an original dark ambient music bed of the given duration (seconds,
positive number, may be fractional, e.g. 372.5).

The bed is fully procedural: a sine stack at 55, 110, 130.81, 164.81 and
220 Hz (dark A-minor voicing), mixed and shaped with tremolo, lowpass at
800 Hz, multi-tap echo, and a fade out over the last 7 seconds.

Example:
  $PROG 372.5 bed.wav
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage; exit 0
fi

[[ $# -eq 2 ]] || { echo "$PROG: need DURATION_SECONDS and out.wav" >&2; usage >&2; exit 2; }

DURATION="$1"
OUT="$2"

# Validate: positive number (integer or decimal).
if ! [[ "$DURATION" =~ ^[0-9]+(\.[0-9]+)?$ ]] || \
   ! python3 -c "import sys; sys.exit(0 if float(sys.argv[1]) > 0 else 1)" "$DURATION" 2>/dev/null; then
  echo "$PROG: duration must be a positive number of seconds, got: $DURATION" >&2
  exit 2
fi

command -v ffmpeg >/dev/null 2>&1 || { echo "$PROG: ffmpeg not found on PATH" >&2; exit 1; }

# Fade start = duration minus 7 seconds (clamped at 0 for very short beds).
FADE_START="$(python3 -c "print(max(0.0, float('$DURATION') - 7.0))")"

# Five sine sources (A-minor voicing), each with its own gentle level so the
# low tones anchor the drone and the higher tones stay subtle.
ffmpeg -y -v error \
  -f lavfi -i "sine=frequency=55:duration=$DURATION" \
  -f lavfi -i "sine=frequency=110:duration=$DURATION" \
  -f lavfi -i "sine=frequency=130.81:duration=$DURATION" \
  -f lavfi -i "sine=frequency=164.81:duration=$DURATION" \
  -f lavfi -i "sine=frequency=220:duration=$DURATION" \
  -filter_complex "
    [0:a]volume=0.35[a0];
    [1:a]volume=0.30[a1];
    [2:a]volume=0.22[a2];
    [3:a]volume=0.18[a3];
    [4:a]volume=0.14[a4];
    [a0][a1][a2][a3][a4]amix=inputs=5:normalize=0[mixed];
    [mixed]tremolo=f=0.8:d=0.35[trem];
    [trem]lowpass=f=800[lp];
    [lp]aecho=0.8:0.7:60|120|250:0.25|0.18|0.12[echo];
    [echo]afade=t=out:st=$FADE_START:d=7[out]
  " \
  -map "[out]" -t "$DURATION" "$OUT"

echo "$PROG: generated $DURATION s original dark ambient bed -> $OUT"

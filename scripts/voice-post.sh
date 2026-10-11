#!/usr/bin/env bash
# voice-post.sh: post-process a TTS voiceover into the house sound.
#
# Applies the locked voice post chain as ONE -af string, in this order:
#   1. acompressor (gentle vocal compression)
#   2. aecho (subtle room feel)
#   3. loudnorm (podcast-style loudness: -16 LUFS integrated)
#
# Usage:
#   voice-post.sh in.wav out.wav
#
# Env: none. No credentials needed.

set -euo pipefail

PROG="$(basename "$0")"

usage() {
  cat <<EOF
Usage: $PROG in.wav out.wav

Apply the locked voice post chain to a TTS voiceover:

  acompressor=threshold=-20dB:ratio=3:attack=15:release=200:makeup=3dB,
  aecho=0.8:0.6:25|40:0.18|0.12,
  loudnorm=I=-16:TP=-1.5:LRA=11

The three filters are applied as one -af string, in that order.

Example:
  $PROG raw-voice.wav final-voice.wav
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage; exit 0
fi

[[ $# -eq 2 ]] || { echo "$PROG: need exactly in.wav and out.wav" >&2; usage >&2; exit 2; }

IN="$1"
OUT="$2"

[[ -f "$IN" ]] || { echo "$PROG: input not found: $IN" >&2; exit 1; }
command -v ffmpeg >/dev/null 2>&1 || { echo "$PROG: ffmpeg not found on PATH" >&2; exit 1; }

AF="acompressor=threshold=-20dB:ratio=3:attack=15:release=200:makeup=3dB,aecho=0.8:0.6:25|40:0.18|0.12,loudnorm=I=-16:TP=-1.5:LRA=11"

ffmpeg -y -v error -i "$IN" -af "$AF" "$OUT"

echo "$PROG: post chain applied (single -af string, in order:)"
echo "  1. acompressor=threshold=-20dB:ratio=3:attack=15:release=200:makeup=3dB"
echo "  2. aecho=0.8:0.6:25|40:0.18|0.12"
echo "  3. loudnorm=I=-16:TP=-1.5:LRA=11"
echo "$PROG: done -> $OUT"

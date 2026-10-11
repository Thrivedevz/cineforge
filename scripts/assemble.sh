#!/usr/bin/env bash
# assemble.sh: final mix and encode for one episode.
#
# Mixes the full voiceover with the music bed kept REALLY low (barely-there
# background presence), optionally burns in subtitles, then encodes a single
# MP4 with libx264 at ~5 Mbps plus 192k AAC.
#
# Usage:
#   assemble.sh --voice voice.wav --bed bed.wav [--subs subs.ass] \
#               --out episode.mp4 [--bed-gain 0.08]
#
# Env: none. No credentials needed.

set -euo pipefail

PROG="$(basename "$0")"

VOICE=""
BED=""
SUBS=""
OUT=""
BED_GAIN="0.08"

usage() {
  cat <<EOF
Usage: $PROG --voice voice.wav --bed bed.wav [--subs subs.ass] --out episode.mp4 [--bed-gain 0.08]

Mix the voiceover (full level) with the music bed at a low gain
(default 0.08, "really low, barely-there"), with the bed looped or trimmed
to the voiceover length. Optionally burn in subtitles, then encode a single
MP4: libx264 ~5 Mbps (-b:v 5M, -maxrate 5.5M, -bufsize 10M), AAC 192k,
yuv420p.

Options:
  --voice FILE    Voiceover wav (required).
  --bed FILE      Music bed wav (required).
  --subs FILE     Subtitles file to burn in (optional, .ass or .srt).
  --out FILE      Output MP4 path (required).
  --bed-gain G   Bed gain, 0.0 to 1.0 (default 0.08).
  --help          Show this help and exit.

Example:
  $PROG --voice final-voice.wav --bed bed.wav --subs ep.ass --out episode.mp4
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --voice) VOICE="${2:-}"; shift 2 ;;
    --bed)   BED="${2:-}";   shift 2 ;;
    --subs)  SUBS="${2:-}";  shift 2 ;;
    --out)   OUT="${2:-}";   shift 2 ;;
    --bed-gain) BED_GAIN="${2:-}"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    --*) echo "$PROG: unknown option: $1" >&2; usage >&2; exit 2 ;;
    *) echo "$PROG: unexpected arg: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -n "$VOICE" ]] || { echo "$PROG: --voice is required" >&2; usage >&2; exit 2; }
[[ -n "$BED"   ]] || { echo "$PROG: --bed is required"   >&2; usage >&2; exit 2; }
[[ -n "$OUT"   ]] || { echo "$PROG: --out is required"   >&2; usage >&2; exit 2; }
[[ -f "$VOICE" ]] || { echo "$PROG: voiceover not found: $VOICE" >&2; exit 1; }
[[ -f "$BED"   ]] || { echo "$PROG: bed not found: $BED"         >&2; exit 1; }
if [[ -n "$SUBS" && ! -f "$SUBS" ]]; then
  echo "$PROG: subtitles not found: $SUBS" >&2; exit 1
fi
if ! [[ "$BED_GAIN" =~ ^(0(\.[0-9]+)?|1(\.0+)?)$ ]]; then
  echo "$PROG: --bed-gain must be between 0 and 1, got: $BED_GAIN" >&2; exit 2
fi
command -v ffmpeg >/dev/null 2>&1 || { echo "$PROG: ffmpeg not found on PATH" >&2; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
MIXED="$WORK/mixed.wav"

# Mix voiceover (full) with bed at low gain. The bed is looped and trimmed
# to the voiceover length, then amix with duration=first (the voiceover
# length rules the episode). Simple, no sidechain.
ffmpeg -y -v error \
  -i "$VOICE" \
  -stream_loop -1 -i "$BED" \
  -filter_complex "
    [1:a]volume=$BED_GAIN,atrim=0:0[bedtrim];
    [bedtrim]asetpts=PTS-STARTPTS[bed];
    [0:a]aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo[vox];
    [bed]aformat=sample_fmts=fltp:sample_rates=48000:channel_layouts=stereo[bedf];
    [vox][bedf]amix=inputs=2:duration=first:dropout_transition=0[mix]
  " \
  -map "[mix]" "$MIXED"

echo "$PROG: mixed voiceover + bed (bed gain $BED_GAIN)"

# Build a blank video canvas the length of the mix for the final MP4.
DUR="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$MIXED")"
[[ -n "$DUR" ]] || { echo "$PROG: could not probe mix duration" >&2; exit 1; }

VF_OPTS=()
if [[ -n "$SUBS" ]]; then
  # Escape for the subtitles filter: quote the path.
  VF_OPTS=(-vf "subtitles='$SUBS'")
  echo "$PROG: burning in subtitles: $SUBS"
fi

ffmpeg -y -v error \
  -f lavfi -i "color=c=black:s=1920x1080:r=30:d=$DUR" \
  -i "$MIXED" \
  "${VF_OPTS[@]}" \
  -c:v libx264 -b:v 5M -maxrate 5.5M -bufsize 10M \
  -pix_fmt yuv420p -preset medium \
  -c:a aac -b:a 192k -ar 48000 \
  -shortest "$OUT"

SIZE="$(stat -c%s "$OUT" 2>/dev/null || stat -f%z "$OUT")"
HUMAN="$(numfmt --to=iec "$SIZE" 2>/dev/null || echo "${SIZE} bytes")"

echo "$PROG: done -> $OUT"
echo "$PROG: output size: $HUMAN ($SIZE bytes)"

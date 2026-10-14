#!/usr/bin/env bash
# enhance.sh: video enhancement stage runner for the CineForge pipeline.
#
# Optional AI tools are detected with command -v and used when present:
#   realesrgan-ncnn-vulkan, anime4kcpp - AI upscalers. When found, the first
#     available one is preferred over the ffmpeg-only fallback, and its name
#     is printed so you can see which tool handled the upscale.
#   rife-ncnn-vulkan                   - true frame interpolation (RIFE).
#
# Hard requirement: ffmpeg (plus its bundled ffprobe) on PATH. Everything
# else is optional. A missing optional tool only triggers a warning on
# stderr and a fallback for that step. The pipeline never fails because an
# enhancement tool is absent; OUTPUT.mp4 is always produced.
#
# Interpolation fallback note: ffmpeg minterpolate is NOT true RIFE. It is a
# motion-compensated interpolator built into ffmpeg, good enough as a
# no-dependency fallback, but it does not match a trained RIFE model.
#
# Usage:
#   enhance.sh [--dry-run] [--no-interp] INPUT.mp4 OUTPUT.mp4
#
# Env: none. No credentials needed.

set -euo pipefail

PROG="$(basename "$0")"

usage() {
  cat <<EOF
Usage: $PROG [--dry-run] [--no-interp] INPUT.mp4 OUTPUT.mp4

Enhance a video: optional AI upscale, optional frame interpolation, then a
light ffmpeg cleanup pass (denoise + sharpen).

Options:
  --dry-run    Print the planned steps and the commands that would run,
               without running anything.
  --no-interp  Skip the interpolation step entirely.

Tool detection (all optional, probed with command -v):
  realesrgan-ncnn-vulkan, anime4kcpp  AI upscalers; preferred when present.
  rife-ncnn-vulkan                    True RIFE frame interpolation.

If no AI upscaler is present, a light ffmpeg-only fallback is applied
(hqdn3d denoise + unsharp sharpening). If rife-ncnn-vulkan is missing,
interpolation falls back to ffmpeg minterpolate (not true RIFE; see the
comment at the top of this script).

Missing optional tools never fail the pipeline: the step is warned about on
stderr and skipped, and OUTPUT.mp4 is always produced.

Example:
  $PROG scene-01.mp4 scene-01-enhanced.mp4
EOF
}

DRY_RUN=0
NO_INTERP=0
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)   DRY_RUN=1; shift ;;
    --no-interp) NO_INTERP=1; shift ;;
    -h|--help)   usage; exit 0 ;;
    --)          shift; while [[ $# -gt 0 ]]; do POSITIONAL+=("$1"); shift; done ;;
    -*)          echo "$PROG: unknown option: $1" >&2; usage >&2; exit 2 ;;
    *)           POSITIONAL+=("$1"); shift ;;
  esac
done

[[ ${#POSITIONAL[@]} -eq 2 ]] || { echo "$PROG: need INPUT.mp4 and OUTPUT.mp4" >&2; usage >&2; exit 2; }

INPUT="${POSITIONAL[0]}"
OUTPUT="${POSITIONAL[1]}"

[[ -f "$INPUT" ]] || { echo "$PROG: input not found: $INPUT" >&2; exit 2; }
[[ "$INPUT" != "$OUTPUT" ]] || { echo "$PROG: input and output must differ" >&2; exit 2; }

command -v ffmpeg >/dev/null 2>&1 || { echo "$PROG: ffmpeg not found on PATH (hard requirement)" >&2; exit 1; }
command -v ffprobe >/dev/null 2>&1 || { echo "$PROG: ffprobe not found on PATH (ships with ffmpeg)" >&2; exit 1; }

# --- Optional tool detection -------------------------------------------------
UPSCALER=""
for tool in realesrgan-ncnn-vulkan anime4kcpp; do
  if command -v "$tool" >/dev/null 2>&1; then UPSCALER="$tool"; break; fi
done

HAVE_RIFE=0
if command -v rife-ncnn-vulkan >/dev/null 2>&1; then HAVE_RIFE=1; fi

# --- Source info -------------------------------------------------------------
RFR="$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of csv=p=0 "$INPUT" | head -n 1)"
FPS_FLOAT="$(awk -F/ '{ if ($2 == 0 || $2 == "") print $1; else print $1/$2 }' <<<"$RFR")"
TARGET_FPS="$(awk -v f="$FPS_FLOAT" 'BEGIN { printf "%d", int(2*f + 0.5) }')"
WXH="$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0:s=x "$INPUT" | head -n 1)"
HAS_AUDIO=0
if ffprobe -v error -select_streams a:0 -show_entries stream=index -of csv=p=0 "$INPUT" 2>/dev/null | grep -q .; then
  HAS_AUDIO=1
fi

# --- Plan --------------------------------------------------------------------
# Interpolation mode: rife (true RIFE), minterp (ffmpeg minterpolate
# fallback), or none (--no-interp).
INTERP="minterp"
if [[ "$NO_INTERP" -eq 1 ]]; then
  INTERP="none"
elif [[ "$HAVE_RIFE" -eq 1 ]]; then
  INTERP="rife"
fi

# Cleanup filter chain (applied in the final ffmpeg pass; cleanup first, so
# interpolation frames are built from already cleaned frames).
CLEANUP_VF="hqdn3d=4:4:6:6,unsharp=5:5:0.8:5:5:0.4"

# --- Dry run: print the plan and exit -----------------------------------------
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "$PROG: dry run, nothing will be executed"
  echo "  input:  $INPUT ($WXH @ ${FPS_FLOAT} fps, audio: $([[ $HAS_AUDIO -eq 1 ]] && echo yes || echo no))"
  echo "  output: $OUTPUT"
  if [[ -n "$UPSCALER" ]]; then
    echo "  upscale: AI pre-pass with $UPSCALER (preferred; AI tools beat the ffmpeg fallback)"
    echo "    would run: $UPSCALER -i <frames_dir> -o <upscaled_dir>"
    echo "    (exact flags follow each tool's -h help; tune for your build)"
  else
    echo "  upscale: none found (realesrgan-ncnn-vulkan, anime4kcpp) -> ffmpeg-only fallback"
    echo "    fallback filters: $CLEANUP_VF"
  fi
  case "$INTERP" in
    rife)
      echo "  interpolation: true RIFE via rife-ncnn-vulkan (-> ${TARGET_FPS} fps)"
      echo "    would run: rife-ncnn-vulkan -i <frames_dir> -o <interp_dir>"
      ;;
    minterp)
      echo "  interpolation: ffmpeg minterpolate fallback (not true RIFE; rife-ncnn-vulkan not found) -> ${TARGET_FPS} fps"
      echo "    filter: minterpolate=fps=${TARGET_FPS}:mi_mode=mci:mc_mode=aobmc:me_mode=bidir:vsbmc=1"
      ;;
    none)
      echo "  interpolation: skipped (--no-interp)"
      ;;
  esac
  echo "  final pass: ffmpeg libx264 (crf 20, preset medium, yuv420p), audio: $([[ $HAS_AUDIO -eq 1 ]] && echo copied || echo none)"
  exit 0
fi

# --- Real run ------------------------------------------------------------------
echo "$PROG: enhancing $INPUT -> $OUTPUT"

if [[ -n "$UPSCALER" ]]; then
  echo "$PROG: using AI upscaler: $UPSCALER"
else
  echo "$PROG: no AI upscaler found (checked: realesrgan-ncnn-vulkan, anime4kcpp); using ffmpeg-only fallback ($CLEANUP_VF)" >&2
fi

case "$INTERP" in
  rife)    echo "$PROG: interpolation via true RIFE (rife-ncnn-vulkan)" ;;
  minterp) echo "$PROG: rife-ncnn-vulkan not found; interpolation via ffmpeg minterpolate (not true RIFE)" >&2 ;;
  none)    echo "$PROG: interpolation skipped (--no-interp)" ;;
esac

TMPD="$(mktemp -d "${TMPDIR:-/tmp}/enhance.XXXXXX")"
cleanup() { rm -rf "$TMPD"; }
trap cleanup EXIT

USE_FRAMES=0        # 1 when an AI frame-level pre-pass produced frames
SRC_FRAMES=""       # directory holding the frames ffmpeg will consume
SRC_FPS="$FPS_FLOAT"

# AI upscale pre-pass: decode to frames, upscale with the preferred binary,
# keep going with the original frames if the tool fails.
if [[ -n "$UPSCALER" ]]; then
  FRAMES_IN="$TMPD/frames"
  UPSCALED="$TMPD/upscaled"
  mkdir -p "$FRAMES_IN" "$UPSCALED"
  ffmpeg -y -v error -i "$INPUT" -qscale:v 2 "$FRAMES_IN/f%06d.png"
  if "$UPSCALER" -i "$FRAMES_IN" -o "$UPSCALED" >/dev/null 2>&1; then
    echo "$PROG: AI upscale pass done ($UPSCALER)"
    SRC_FRAMES="$UPSCALED"
  else
    echo "$PROG: warning: $UPSCALER failed; continuing with original frames" >&2
    SRC_FRAMES="$FRAMES_IN"
  fi
  USE_FRAMES=1
fi

# True RIFE pre-pass (only when interpolation is enabled and the binary
# exists). On failure, warn and fall back to ffmpeg minterpolate so the
# pipeline never breaks.
if [[ "$INTERP" == "rife" ]]; then
  if [[ "$USE_FRAMES" -eq 0 ]]; then
    SRC_FRAMES="$TMPD/frames"
    mkdir -p "$SRC_FRAMES"
    ffmpeg -y -v error -i "$INPUT" -qscale:v 2 "$SRC_FRAMES/f%06d.png"
    USE_FRAMES=1
  fi
  INTERP_DIR="$TMPD/interp"
  mkdir -p "$INTERP_DIR"
  if rife-ncnn-vulkan -i "$SRC_FRAMES" -o "$INTERP_DIR" >/dev/null 2>&1; then
    echo "$PROG: RIFE interpolation pass done (target ${TARGET_FPS} fps)"
    SRC_FRAMES="$INTERP_DIR"
    SRC_FPS="$TARGET_FPS"
    INTERP="done"
  else
    echo "$PROG: warning: rife-ncnn-vulkan failed; falling back to ffmpeg minterpolate" >&2
    INTERP="minterp"
  fi
fi

# Build the final ffmpeg video filter chain.
VF=""
if [[ -z "$UPSCALER" ]]; then
  # No AI upscaler: the light ffmpeg-only fallback carries cleanup.
  VF="$CLEANUP_VF"
fi
if [[ "$INTERP" == "minterp" ]]; then
  [[ -n "$VF" ]] && VF+=","
  VF+="minterpolate=fps=${TARGET_FPS}:mi_mode=mci:mc_mode=aobmc:me_mode=bidir:vsbmc=1"
fi

# Assemble the final ffmpeg command.
FF_ARGS=(-y -v error)
if [[ "$USE_FRAMES" -eq 1 ]]; then
  FF_ARGS+=(-framerate "$SRC_FPS" -i "$SRC_FRAMES/f%06d.png")
  if [[ "$HAS_AUDIO" -eq 1 ]]; then
    FF_ARGS+=(-i "$INPUT" -map 0:v -map 1:a)
  else
    FF_ARGS+=(-map 0:v)
  fi
else
  FF_ARGS+=(-i "$INPUT")
fi
if [[ -n "$VF" ]]; then
  FF_ARGS+=(-vf "$VF")
fi
FF_ARGS+=(-c:v libx264 -crf 20 -preset medium -pix_fmt yuv420p)
if [[ "$HAS_AUDIO" -eq 1 ]]; then
  FF_ARGS+=(-c:a copy)
fi
FF_ARGS+=("$OUTPUT")

ffmpeg "${FF_ARGS[@]}"

echo "$PROG: done -> $OUTPUT"

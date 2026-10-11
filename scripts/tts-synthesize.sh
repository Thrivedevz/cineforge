#!/usr/bin/env bash
# tts-synthesize.sh: full TTS pipeline for narration scripts.
# Steps: (1) strip speaker labels, (2) merge ultra-short chunks,
# (3) split into 4 quarters, (4) synthesize each quarter with the
# `tts` CLI, (5) concat the four wavs into one output file.
#
# Credentials: none needed. The `tts` CLI handles its own auth.
# Secrets belong in env vars, never hardcoded here.
#
# Usage:
#   tts-synthesize.sh [--dry-run] [--voice VOICE] script.txt out.wav
#
# Env:
#   TTS_VOICE   Default voice id (fallback: avocado_v2:MAI_03)

set -euo pipefail

PROG="$(basename "$0")"
DRY_RUN=0
VOICE="${TTS_VOICE:-avocado_v2:MAI_03}"
SCRIPT=""
OUT=""

usage() {
  cat <<EOF
Usage: $PROG [--dry-run] [--voice VOICE] script.txt out.wav

TTS pipeline for narration scripts:

  1. LABEL-STRIP GATE: remove speaker labels ("Narrator:", "NARRATOR:",
     "[Narrator]") so they are never spoken aloud.
  2. Merge ultra-short chunks: paragraphs of 2 words or fewer are joined
     with the following paragraph (the TTS backend chokes on tiny chunks).
  3. Split the cleaned script into 4 roughly equal paragraph-count quarters.
  4. Synthesize each quarter: tts synthesize-script --voice VOICE qN.txt qN.wav
  5. Concat the four wavs into out.wav via the ffmpeg concat demuxer.

Options:
  --dry-run     Show the chunking plan (labels stripped count, tiny chunks
                merged count, paragraph counts per quarter) and exit without
                synthesizing.
  --voice VOICE Voice id for the tts CLI (default: \$TTS_VOICE or
                "avocado_v2:MAI_03").
  --help        Show this help and exit.

Example:
  $PROG --voice avocado_v2:MAI_03 narration.txt episode-voice.wav
EOF
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --voice)
      [[ $# -ge 2 ]] || { echo "$PROG: --voice needs a value" >&2; usage >&2; exit 2; }
      VOICE="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    --*) echo "$PROG: unknown option: $1" >&2; usage >&2; exit 2 ;;
    *)
      if [[ -z "$SCRIPT" ]]; then SCRIPT="$1";
      elif [[ -z "$OUT" ]]; then OUT="$1";
      else echo "$PROG: too many positional args" >&2; usage >&2; exit 2; fi
      shift ;;
  esac
done

[[ -n "$SCRIPT" && -n "$OUT" ]] || { echo "$PROG: need script.txt and out.wav" >&2; usage >&2; exit 2; }
[[ -f "$SCRIPT" ]] || { echo "$PROG: script not found: $SCRIPT" >&2; exit 1; }
command -v ffmpeg >/dev/null 2>&1 || { echo "$PROG: ffmpeg not found on PATH" >&2; exit 1; }
if [[ "$DRY_RUN" -eq 0 ]]; then
  command -v tts >/dev/null 2>&1 || { echo "$PROG: tts CLI not found on PATH" >&2; exit 1; }
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Step 1: LABEL-STRIP GATE.
# Removes lines like "Narrator:", "NARRATOR:", "[Narrator]" (case-insensitive,
# optional brackets, optional trailing whitespace) so the voice never speaks
# the label. Counts how many lines were stripped.
LABEL_COUNT="$(
  awk 'BEGIN{c=0}
       /^[[:space:]]*\[[Nn][Aa][Rr][Rr][Aa][Tt][Oo][Rr]\][[:space:]]*$/ {c++; next}
       /^[[:space:]]*[Nn][Aa][Rr][Rr][Aa][Tt][Oo][Rr][[:space:]]*:[[:space:]]*$/ {c++; next}
       {print}
       END{print c > "/dev/stderr"}' "$SCRIPT" > "$WORK/stripped.txt" 2>"$WORK/labelcount.txt"
  cat "$WORK/labelcount.txt"
)"

# Step 2: merge ultra-short chunks (2 words or fewer) with the next paragraph.
# Paragraphs are separated by blank lines. Prefer python3, fall back to awk.
if command -v python3 >/dev/null 2>&1; then
  MERGE_STATS="$(python3 - "$WORK/stripped.txt" "$WORK/merged.txt" <<'PY'
import re, sys
src, dst = sys.argv[1], sys.argv[2]
text = open(src, encoding="utf-8").read()
paras = [p.strip() for p in re.split(r"\n\s*\n", text) if p.strip()]
merged = []
i = 0
merge_count = 0
while i < len(paras):
    words = paras[i].split()
    if len(words) <= 2 and i + 1 < len(paras):
        merged.append(paras[i] + " " + paras[i + 1])
        merge_count += 1
        i += 2
    else:
        merged.append(paras[i])
        i += 1
with open(dst, "w", encoding="utf-8") as f:
    f.write("\n\n".join(merged) + "\n")
print(f"{merge_count} {len(paras)} {len(merged)}")
PY
)"
  MERGED_COUNT="$(echo "$MERGE_STATS" | cut -d' ' -f1)"
  PARA_TOTAL="$(echo "$MERGE_STATS" | cut -d' ' -f3)"
else
  # awk fallback: joins a short paragraph line-block with the next one.
  MERGE_STATS="$(awk '
    BEGIN{RS=""; ORS="\n\n"; total=0; merged=0; hold=""; have=0}
    {
      total++
      gsub(/\n[ \t]*/, " ")
      n = split($0, w, /[ \t]+/)
      if (have) { print hold " " $0; have=0; merged++ }
      else if (n <= 2) { hold=$0; have=1 }
      else { print $0 }
    }
    END{
      if (have) print hold
      print "STATS " merged " " total > "/dev/stderr"
    }' "$WORK/stripped.txt" > "$WORK/merged.txt" 2>"$WORK/mergestats.txt"
  cat "$WORK/mergestats.txt")"
  MERGED_COUNT="$(echo "$MERGE_STATS" | awk '{print $2}')"
  PARA_TOTAL="$(python3 -c 'import re,sys; print(len([p for p in re.split(r"\n\s*\n", open(sys.argv[1]).read()) if p.strip()]))' "$WORK/merged.txt" 2>/dev/null || echo 0)"
fi

# Step 3: split into 4 roughly equal paragraph-count quarters.
SPLIT_COUNTS="$(python3 - "$WORK/merged.txt" "$WORK" <<'PY'
import re, sys, math
src, work = sys.argv[1], sys.argv[2]
text = open(src, encoding="utf-8").read()
paras = [p.strip() for p in re.split(r"\n\s*\n", text) if p.strip()]
n = len(paras)
counts = []
for q in range(4):
    start = math.floor(q * n / 4)
    end = math.floor((q + 1) * n / 4)
    chunk = paras[start:end]
    with open(f"{work}/quarter{q+1}.txt", "w", encoding="utf-8") as f:
        f.write("\n\n".join(chunk) + ("\n" if chunk else ""))
    counts.append(len(chunk))
print(" ".join(map(str, counts)))
PY
)"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "--- DRY RUN: chunking plan ---"
  echo "Script:        $SCRIPT"
  echo "Voice:         $VOICE"
  echo "Labels stripped: $LABEL_COUNT"
  echo "Tiny chunks merged: $MERGED_COUNT"
  echo "Total paragraphs after merge: $PARA_TOTAL"
  echo "Paragraphs per quarter (Q1 Q2 Q3 Q4): $SPLIT_COUNTS"
  echo "First few cleaned lines (label-strip proof):"
  head -n 5 "$WORK/merged.txt"
  echo "--- (no synthesis performed) ---"
  exit 0
fi

# Step 4: synthesize each quarter separately (isolates failures fast).
for q in 1 2 3 4; do
  if [[ ! -s "$WORK/quarter$q.txt" ]]; then
    echo "$PROG: warning: quarter$q is empty, skipping" >&2
    continue
  fi
  echo "$PROG: synthesizing quarter $q/4..."
  tts synthesize-script --voice "$VOICE" "$WORK/quarter$q.txt" "$WORK/quarter$q.wav"
done

# Step 5: concat the four wavs into the final output.
CONCAT_LIST="$WORK/concat.txt"
: > "$CONCAT_LIST"
for q in 1 2 3 4; do
  [[ -f "$WORK/quarter$q.wav" ]] && echo "file '$WORK/quarter$q.wav'" >> "$CONCAT_LIST"
done
[[ -s "$CONCAT_LIST" ]] || { echo "$PROG: no quarter wavs produced, aborting" >&2; exit 1; }
ffmpeg -y -v error -f concat -safe 0 -i "$CONCAT_LIST" -c copy "$OUT"
echo "$PROG: done -> $OUT (labels stripped: $LABEL_COUNT, tiny chunks merged: $MERGED_COUNT)"

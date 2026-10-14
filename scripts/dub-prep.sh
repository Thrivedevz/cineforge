#!/usr/bin/env bash
# dub-prep.sh: prepare multi-speaker dubbing inputs from a labeled narration script.
#
# Splits the script into per-speaker segment files (one file per speaker turn)
# in an output directory, strips speaker labels from the segment text (labels
# are never synthesized: the label-strip gate), and writes a dubbing manifest
# (TSV) with per-segment word counts and estimated durations.
#
# Label format: UPPERCASE words (letters, digits, spaces, hyphens) followed by
# a colon at the start of a line, e.g. "NARRATOR:", "XIAO YI:", "DEMON-2:".
# Lines without a label continue the current speaker. Blank lines are kept as
# paragraph breaks inside a segment. Label-only lines (no text after the colon)
# set the speaker for following lines; if no text ever follows, the empty
# segment is skipped with a warning. A script with no labels at all becomes a
# single segment spoken by UNKNOWN, with a warning.
#
# Manifest columns (TSV): segment_id, speaker, word_count,
# est_duration_sec, target_lang.
# Segment files are named SEGID_SPEAKER.txt, e.g. seg_0001_NARRATOR.txt.
#
# Usage:
#   dub-prep.sh [--dry-run] [--speakers] [--wpm N] [--lang CODE] [--out DIR] script.txt
#
# Exit codes: 0 on success; 2 on usage errors (including a missing input
# file); 1 if the output directory cannot be created.

set -euo pipefail

PROG="$(basename "$0")"
MODE="split"          # split | dry | list
WPM=150
LANG="en"
OUT="./dub_segments"
SCRIPT=""

usage() {
  cat <<EOF
Usage: $PROG [options] script.txt

Prepare multi-speaker dubbing inputs from a labeled narration script.

The script is split into per-speaker segment files, one file per speaker
turn, with speaker labels stripped (labels are never synthesized). A
dubbing manifest (TSV) is written next to the segment files.

Label format: UPPERCASE words (letters, digits, spaces, hyphens) followed
by a colon at the start of a line, e.g. "NARRATOR:", "XIAO YI:".
Lines without a label continue the current speaker. A script with no
labels is treated as one segment spoken by UNKNOWN (with a warning).

Options:
  --speakers    List detected speakers (first-appearance order) and exit.
  --dry-run     Print the dubbing plan (speakers, segment counts, words,
                estimated durations) without writing any files.
  --wpm N       Words per minute for duration estimates (default: 150).
  --lang CODE   Target language code recorded in the manifest
                (default: en).
  --out DIR     Output directory for segments and manifest
                (default: ./dub_segments).
  --help        Show this help and exit.

Manifest columns (TSV): segment_id, speaker, word_count,
est_duration_sec, target_lang.

Segment files: SEGID_SPEAKER.txt, e.g. seg_0001_NARRATOR.txt.

Example:
  $PROG --wpm 150 --lang en --out ./dub_segments narration.txt
EOF
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --speakers) MODE="list"; shift ;;
    --dry-run) MODE="dry"; shift ;;
    --wpm)
      [[ $# -ge 2 ]] || { echo "$PROG: --wpm needs a value" >&2; usage >&2; exit 2; }
      WPM="$2"; shift 2 ;;
    --lang)
      [[ $# -ge 2 ]] || { echo "$PROG: --lang needs a value" >&2; usage >&2; exit 2; }
      LANG="$2"; shift 2 ;;
    --out)
      [[ $# -ge 2 ]] || { echo "$PROG: --out needs a value" >&2; usage >&2; exit 2; }
      OUT="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    --*) echo "$PROG: unknown option: $1" >&2; usage >&2; exit 2 ;;
    *)
      if [[ -z "$SCRIPT" ]]; then SCRIPT="$1";
      else echo "$PROG: too many positional args" >&2; usage >&2; exit 2; fi
      shift ;;
  esac
done

[[ -n "$SCRIPT" ]] || { echo "$PROG: missing input script file" >&2; usage >&2; exit 2; }
[[ -f "$SCRIPT" ]] || { echo "$PROG: input script not found: $SCRIPT" >&2; usage >&2; exit 2; }
[[ "$WPM" =~ ^[0-9]+$ ]] && (( WPM > 0 )) || { echo "$PROG: --wpm needs a positive integer (got: $WPM)" >&2; usage >&2; exit 2; }
[[ -n "$LANG" ]] || { echo "$PROG: --lang needs a non-empty value" >&2; usage >&2; exit 2; }

if [[ "$MODE" == "split" ]]; then
  mkdir -p "$OUT" || { echo "$PROG: cannot create output dir: $OUT" >&2; exit 1; }
fi

# Main parse: one awk pass over the script. Tracks the current speaker,
# accumulates each speaker turn into a segment buffer, writes segment files
# and the manifest in split mode, or reports in list/dry modes.
awk -v prog="$PROG" -v script="$SCRIPT" -v out="$OUT" \
    -v wpm="$WPM" -v lang="$LANG" -v mode="$MODE" '
function safe_name(s,   t) {
  # Speaker name sanitized for use in a filename.
  t = s
  gsub(/[^A-Za-z0-9]+/, "_", t)
  sub(/^_+/, "", t)
  sub(/_+$/, "", t)
  if (t == "") t = "UNKNOWN"
  return t
}
function count_words(s,   t) {
  # Count whitespace-separated tokens; gsub returns the match count.
  t = s
  return gsub(/[^ \t\n]+/, "&", t)
}
function plural(n, one, many) {
  return (n == 1 ? one : many)
}
function seg_dur(words) {
  return sprintf("%.1f", words * 60 / wpm)
}
function close_segment(   clean, id, words, fname) {
  # Flush the buffered speaker turn. Empty buffers (e.g. from label-only
  # lines with no following text) are skipped with a warning.
  if (!has) {
    if (empty_warn) {
      print prog ": warning: label-only line for " empty_warn_spk \
        " had no text, skipped" > "/dev/stderr"
      skipped++
      empty_warn = 0
    }
    return
  }
  clean = buf
  sub(/\n+$/, "", clean)
  nseg++
  id = sprintf("seg_%04d", nseg)
  words = count_words(clean)
  total_words += words
  if (!(cur in seen)) { seen[cur] = 1; order[++nspeakers] = cur }
  spk_segs[cur]++
  spk_words[cur] += words
  if (mode == "split") {
    fname = out "/" id "_" safe_name(cur) ".txt"
    print clean > fname
    printf "%s\t%s\t%d\t%s\t%s\n", \
      id, cur, words, seg_dur(words), lang >> man
  }
  buf = ""; has = 0; empty_warn = 0
}
BEGIN {
  if (mode == "split") {
    man = out "/manifest.tsv"
    print "segment_id\tspeaker\tword_count\test_duration_sec\ttarget_lang" > man
  }
  cur = "UNKNOWN"
  buf = ""; has = 0
  nseg = 0; nlabels = 0; nspeakers = 0; skipped = 0
  total_words = 0
  empty_warn = 0
}
{
  line = $0
  sub(/\r$/, "", line)   # tolerate Windows line endings
  if (line ~ /^[ \t]*[A-Z][A-Z0-9 -]*:/) {
    # Speaker label at line start: strip it, keep the rest as segment text.
    lab = line
    sub(/^[ \t]*/, "", lab)
    cpos = index(lab, ":")
    spk = substr(lab, 1, cpos - 1)
    sub(/[ \t]+$/, "", spk)
    rest = substr(lab, cpos + 1)
    sub(/^[ \t]+/, "", rest)
    nlabels++
    close_segment()
    cur = spk
    if (rest != "") { buf = rest; has = 1; empty_warn = 0 }
    else { empty_warn = 1; empty_warn_spk = spk }
    next
  }
  if (line ~ /^[ \t]*$/) {
    # Blank line: paragraph break, only meaningful inside a segment.
    if (has) buf = buf "\n"
    next
  }
  # Unlabeled line: continues the current speaker.
  if (has) buf = buf "\n" line
  else { buf = line; has = 1 }
  empty_warn = 0
  next
}
END {
  close_segment()
  if (nseg == 0) {
    print prog ": warning: no segments found in script" > "/dev/stderr"
  } else if (nlabels == 0) {
    print prog ": warning: no speaker labels found, " \
      "entire script assigned to UNKNOWN" > "/dev/stderr"
  }
  if (mode == "list") {
    for (i = 1; i <= nspeakers; i++) print order[i]
  } else if (mode == "dry") {
    print "--- DRY RUN: dubbing plan ---"
    print "Script:       " script
    print "Target lang:  " lang
    print "Words/minute: " wpm
    print "Output dir:   " out " (not created)"
    print "Speakers:     " nspeakers
    for (i = 1; i <= nspeakers; i++) {
      s = order[i]
      printf "  %-10s %d %s, %d words, %s sec est.\n", \
        s ":", spk_segs[s], plural(spk_segs[s], "segment", "segments"), \
        spk_words[s], seg_dur(spk_words[s])
    }
    printf "Total: %d %s, %d words, %s sec est.\n", \
      nseg, plural(nseg, "segment", "segments"), \
      total_words, seg_dur(total_words)
    print "Label-only lines skipped: " skipped
    print "--- (no files written) ---"
  } else if (mode == "split") {
    print prog ": wrote " nseg " " plural(nseg, "segment", "segments") \
      " to " out
    print prog ": manifest: " man
    printf "%s: total %d words, %s sec est. at %d wpm (target lang: %s)\n", \
      prog, total_words, seg_dur(total_words), wpm, lang
    if (skipped > 0)
      print prog ": label-only lines skipped: " skipped
  }
}
' "$SCRIPT"

# TTS Pipeline

End-to-end voiceover synthesis workflow. Follow in order; each step gates the next.

## 1. Prepare the script

Write the script with proper names, performance notation (see voice-direction.md), and all numbers in spoken form. Split narration into scenes or segments, one per line or paragraph, sized for steady synthesis.

## 2. Apply phonetic substitutions

Run the script through the project's substitution table (see phonetics-guide.md) BEFORE any synthesis. The engine must only ever see phonetic spellings of names. Do a text search for each original name afterward to confirm zero remain.

## 3. Label-strip gate (critical, non-negotiable)

Speaker labels such as `Narrator:` must NEVER be spoken aloud. A single missed label means the voice says "narrator" before the line, and the whole take is ruined.

- Strip ALL segment labels from the script, or map each label through the `--speaker` option if your pipeline supports it.
- On ANY new pipeline, verify the stripping path on ONE segment first: synthesize a single segment, listen, confirm no label is spoken. Only then run the full script.

## 4. Merge tiny chunks

The TTS backend chokes on ultra-short chunks. Any line of one or two words (for example a lone "Xiao Ning.") will return truncated or broken audio. Merge every 1-2 word line into a neighboring paragraph before synthesis.

## 5. Split into quarters

For long scripts, split the labeled-and-stripped script into quarters. Synthesize each quarter separately with `tts synthesize-script`. This isolates failures: a bad chunk in quarter three does not cost you quarters one and two.

## 6. Synthesize

Run synthesis per quarter. Keep the same voice id (`avocado_v2:MAI_03`) across all quarters of an episode for a consistent sound.

## 7. Concatenate

Join the quarter audio files in order into one full voiceover track. Verify the join: listen to the boundary between quarters to confirm no dropped words or volume jumps.

## Failure modes and fixes

- **Truncated audio on short chunks:** symptom is a few hundred bytes of output or clipped speech. Fix: merge the tiny line into the neighboring paragraph (step 4) and re-synthesize that segment.
- **Spoken labels:** symptom is the voice saying "narrator" or another label aloud. Fix: re-run the label-strip gate on the segment, verify on one segment first (step 3), then re-synthesize.
- **Mispronounced names:** symptom is a name that sounds wrong in the output. Fix: update the phonetic spelling in the project substitution table, re-run the name-list QA (see phonetics-guide.md), and re-synthesize affected segments.
- **Inconsistent tone across quarters:** symptom is audible shifts between quarter joins. Fix: check that the same voice id and the same script formatting were used throughout; re-synthesize the offending quarter.

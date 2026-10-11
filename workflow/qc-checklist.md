# QC Checklist

Run each section at its stage. A failed item blocks the stage's exit gate.

## Pre-synthesis (Stage 3, before TTS)

- [ ] **Label-strip gate:** all script segment labels stripped or mapped before synthesis. Verify the synthesis path never speaks labels aloud (e.g. "Narrator:" must never be heard in the audio). Test one segment first on any new pipeline.
- [ ] **Phonetics locked:** every name in the script uses a web-checked or locked phonetic spelling. No name is synthesized on a guess.
- [ ] **Chunking:** ultra-short chunks (one or two words) merged into neighboring paragraphs. The TTS backend truncates tiny chunks.
- [ ] **Quarter split plan:** long scripts split into quarters for isolated synthesis, then concatenated.

## Post-voiceover (Stage 3, after synthesis)

- [ ] **Post chain applied:** compressor, subtle room, loudnorm to the project's loudness target.
- [ ] **Loudness verified:** measured integrated loudness matches target; no clipping.
- [ ] **Full listen-through:** no mispronunciations, no spoken labels, no truncated words, no repeated or skipped lines.

## Post-assembly (Stage 9)

- [ ] **Black-frame detection:** run blackdetect over the whole file. Zero unexpected black frames.
- [ ] **Full decode check:** decode the entire file end to end. Fail on any decode error.
- [ ] **Loudness verification:** final mix measured at target loudness; voice clear over the music bed.
- [ ] **File-size guardrail:** file under ~900MB. Warn and re-encode lighter if it approaches the guardrail. Never ship at or above 1GB.
- [ ] **Captions present and animated:** word-by-word highlighting verified on playback, timed to the voiceover. Not plain static subtitles.
- [ ] **Single whole file:** exactly one MP4 for the episode. No split parts.
- [ ] **Fresh filename:** version filename not reused from a previous version.
- [ ] **Codec and bitrate:** h264 + aac, video bitrate at the ~5 to 6 Mbps cap.
- [ ] **Music bed level:** bed is really low under the voiceover, a barely-there presence, never distracting.
- [ ] **Thumbnail matches template:** golden ring badge top-right with the correct two-digit episode number, series full name in gold along the bottom, 1280 x 720, under 2MB.
- [ ] **Length and density:** final runtime 15 to 23 minutes; narration density roughly 45 to 55 words per scene.
- [ ] **No hallucination spot check:** sampled scenes verified against the source: events, names, techniques, outcomes all match.

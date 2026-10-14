# Multi-Language Dubbing and Localization Direction

(credit: Huanshere/VideoLingo, 18.8k stars, Apache 2.0)

This doc covers how CineForge handles dubbed versions of episodes and films for new audiences. The primary use case: take a finished episode or film and produce a version in another language, with subtitles and an AI voice track that follows the same discipline as the original production.

## The pipeline in plain terms

1. Export the finished narration script (post label-strip gate, phonetic substitution already applied).
2. Segment the script into subtitle units.
3. Translate each unit with a locked terminology table.
4. Generate the dubbed voice track with one consistent voice per character.
5. Align dubbed lines to the original timing.
6. Run the dubbing QC checklist below.
7. Ship a language-specific final file, never mixed with the original.

## Subtitle segmentation

- Cut on sentence boundaries. Never split a sentence across two subtitle units unless it is long enough to require it, and then split at a clause boundary (a comma or conjunction), not mid-phrase.
- Target 1 to 2 lines per unit, 42 characters max per line.
- Keep each unit on screen long enough to read: minimum 1 second, maximum 7 seconds.
- A new speaker or a new scene starts a new unit, even if the previous one was short.
- Keep speaker labels ("XIAO YAN:") out of the spoken dub. They may appear in subtitles if the release convention uses them, but they never reach the voice track.

## Translation workflow with terminology consistency

- Maintain a term table per language: every character name, technique name, place name, and title gets exactly one locked translation. This is the same lock discipline as the phonetics substitution table used before TTS.
- The term table is filled before translation begins, not patched afterward. Retroactive find-and-replace across a finished dub is how inconsistencies ship.
- Proper names stay consistent across episodes. If "Xiao Yi" becomes one word in the target language in Episode 11, it stays that word in Episode 12.
- Review the full episode glossary after each new episode before locking, so new names introduced later get tabled once and stay locked.

## Multi-voice AI dubbing direction

- One locked voice per character, across languages and across episodes. The same character in the original and the dub should be recognizable as the same role (matched by casting, see `voiceover/multi-voice.md`), not assigned at random each episode.
- Narrator keeps the same voice as the original where the target language supports it; if a different language needs a different narrator voice, that choice is locked once and documented.
- Direct performance per character, not a flat read. Dialogue scenes get acted delivery; recap narration keeps the cinematic pacing the original was directed with.

## Timing and alignment

- Dubbed lines are matched to the original timing window of each scene: the line must start and end within the same beat as the original.
- If a translated line is too long for its window, shorten the translation, never stretch the video. Shorter is almost always the right answer.
- If a translated line is much shorter than its window, add a natural pause, do not rush or add filler words.
- Lip sync is approximate for animated/recap content. Do not burn production time chasing frame-perfect lip match; beat-level alignment is the standard.

## Dubbing QC checklist

Run this before shipping any dubbed file:

- [ ] No speaker labels spoken aloud in the dub track.
- [ ] Every character name matches the locked term table.
- [ ] Every technique and place name matches the locked term table.
- [ ] No subtitle unit exceeds 42 characters per line.
- [ ] No subtitle unit runs longer than 7 seconds.
- [ ] Each dubbed line lands inside its original scene timing.
- [ ] Voice per character matches the casting lock from previous episodes.
- [ ] Final file is a separate language-specific deliverable, not a patch over the original.

## Honest limitations (from VideoLingo's own cautions, restated)

- Translation quality depends on the source. A sloppy or machine-raw translation ships a sloppy dub. Human review of the translated script is still required before voice generation.
- Dubbing timing is approximate. AI voice generation does not guarantee exact durations, so every line needs a timing pass.
- Mixed-language speech in one track is unreliable. If a scene mixes languages in the source, dub the whole line or subtitle the foreign part, do not expect the voice model to switch cleanly mid-sentence.

## Rule of thumb

Dub for one language at a time, lock the term table once per language, and never ship a dub that has not passed the timing and terminology QC above.

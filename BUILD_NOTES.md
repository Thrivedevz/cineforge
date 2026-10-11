# CineForge v1 — Build Notes

Built: 2026-10-11. Local only. No GitHub repo created, nothing pushed (per instructions; owner pushes after review).

## How it was built

Six parallel writers produced the content packages (root docs, prompts, voiceover docs, video/workflow/thumbnail docs, scripts, worked example), then the coordinator ran verification: file layout check, `bash -n` on all scripts, live execution tests of music-bed.sh and voice-post.sh, a dry-run of tts-synthesize.sh, an assemble.sh + qc.sh round trip, and a repo-wide em-dash grep.

## File list (27 files)

- README.md, GUIDE.md, LICENSE (MIT, Copyright (c) 2026 Muhammad Sabir / Thrivedevz), BUILD_NOTES.md
- prompts/prompt-formula.md
- prompts/directing-briefs/cinematic.md (6 briefs), anime-action.md (5), fantasy-film.md (5), ads-ugc.md (5), documentary.md (5)
- prompts/templates/scene-prompt-template.md, character-lock-template.md, voiceover-block-template.md, film-brief-template.md
- voiceover/voice-direction.md, phonetics-guide.md, tts-pipeline.md, audio-post.md, music-bed.md
- video/generation-workflows.md, character-design-system.md, assembly.md
- scripts/tts-synthesize.sh, voice-post.sh, music-bed.sh, assemble.sh, qc.sh (all executable)
- examples/episode-breakdown/README.md ("The Lantern Keeper of Mirell", 100% original fiction)
- thumbnails/thumbnail-system.md
- workflow/stage-gates.md, qc-checklist.md

Every directing brief is stamped "Last verified: 2026-10" and marked model-agnostic.

## Test results

- `bash -n` on all 5 scripts: OK.
- Repo-wide em-dash grep: zero matches.
- music-bed.sh (10s): generated valid mono 44.1kHz WAV, duration 10.00s, verified with ffprobe.
- voice-post.sh on a 5s 220Hz test tone: full chain applied (acompressor, aecho, loudnorm in order), valid WAV out (5.04s; extra 0.04s is the echo tail, expected).
- tts-synthesize.sh --dry-run on a labeled 3-paragraph script: stripped 3 "Narrator:" labels, merged 1 ultra-short chunk ("Sareth waited."), printed the quartering plan, no synthesis attempted. (The `tts` CLI is not installed in this environment, so live synthesis was not tested; dry-run path verified only.)
- assemble.sh (test tone + 10s bed): mixed at bed gain 0.08, encoded h264 ~5 Mbps + aac, single MP4 out, size printed.
- qc.sh on that MP4: blackdetect correctly FAILED (the test file is a black canvas, so this is correct detection, not a bug); full decode PASS; loudness -16.08 LUFS vs -16 target PASS; size guardrail PASS. Overall FAIL verdict was the right call for a black test file.

## Caveats and open items

- assemble.sh builds a black 1920x1080 canvas as the video track because this pipeline has no visual-generation stage; when video clips exist, swap that input for the real footage.
- tts-synthesize.sh quartering edge case: scripts with fewer than 4 paragraphs produce empty quarters, which are skipped with a warning. Fine for real scripts, slightly awkward for tiny ones.
- qc.sh uses python3 (not jq) to parse loudnorm JSON; if python3 is missing the loudness check degrades to a warning instead of crashing.
- All content is original. Inspirations are credited by name only in README.md (MoneyPrinterTurbo for pipeline architecture, guide-to-best-ai-filmmaking for workflow structure, flaqai prompt packs for the directing-brief formula). No text was copied from any of them.
- Suggested next steps after owner review: `git init` + first commit locally, create the private GitHub repo, push; later decide on the public flip and whether to withhold any section.

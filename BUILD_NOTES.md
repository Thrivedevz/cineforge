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

---

# CineForge v1.1 — Build Notes

Built: 2026-10-14. Local only. Nothing committed, nothing pushed (per instructions; owner reviews and pushes).

## How it was built

Three parallel writers produced the packages (video docs: enhancement.md + generation-backends.md; audio doc + enhance.sh script with tests; GUIDE.md + README.md edits), then the coordinator ran verification: repo-wide em-dash grep, `bash -n` on all six scripts, an independent enhance.sh --dry-run and ffmpeg-fallback run on a 5s testsrc clip, and spot checks of the GUIDE/README edits.

## Files added (4)

- video/enhancement.md: optional Stage 7.5 doc. Anime4K technique (credit: bloc97/Anime4K, 21.5k stars, MIT) for anime upscaling/denoising; video2x pipeline concept (credit: k4yt3x/video2x) for batch episode processing; Real-ESRGAN as the photorealistic alternative; RIFE frame interpolation (rife-ncnn-vulkan) with an explicit skip list; honest compute-cost notes and the keep-the-master rule.
- video/generation-backends.md: ComfyUI (credit: Comfy-Org/ComfyUI, 123k stars) as an alternate generation backend; what stays identical across backends (prompt formula, character locks, Style DNA, directing principles, no-hallucination rule); 6-step porting checklist.
- voiceover/audio-separation.md: vocal/BGM separation technique (credit: Anjok07/ultimatevocalremovergui, 26.4k stars); primary use case is the photorealistic fantasy film channel; recap channel note (clean stems already, separation rarely needed); separate -> clean dialogue -> re-mix -> re-verify loudness workflow.
- scripts/enhance.sh (executable): enhancement stage runner. Probes for realesrgan-ncnn-vulkan, anime4kcpp, rife-ncnn-vulkan; ffmpeg-only fallback (hqdn3d + unsharp) when none present; ffmpeg minterpolate as the no-dependency interpolation fallback (documented as not true RIFE); --dry-run and --no-interp flags; never fails the pipeline when optional tools are missing (warn + skip).

## Files changed (3)

- GUIDE.md: new Stage 7.5 (optional, between generation and assembly) with Purpose/Inputs/Steps/Outputs/Exit gate; new Format matrix section (universal vs per-format swaps: anime recap, photorealistic fantasy film, ads/UGC, documentary); Reference documents updated (new docs listed, "six runnable pipeline scripts").
- README.md: pipeline diagram note for optional Stage 7.5; repo map gains the 3 docs + enhance.sh; Credits extended with v1.1 inspirations by name; new Changelog section with the v1.1 entry.
- BUILD_NOTES.md: this log.

## Test results

- `bash -n` on all 6 scripts: OK.
- Repo-wide em-dash grep (new + edited files): zero matches.
- enhance.sh --dry-run on 5s 1280x720@30 test clip: printed correct plan (input probe, no upscaler -> fallback filters listed, minterpolate -> 60 fps flagged as not true RIFE, final libx264 pass); exit 0, nothing executed.
- enhance.sh fallback run on the same clip: produced valid h264 output, 1280x720, r_frame_rate 60/1, duration 4.95s (~5s); warnings went to stderr as designed; exit 0.
- The AI upscaler and true-RIFE paths are implemented with failure fallbacks but were not exercised live (those binaries are not installed on this VM).

## Caveats and open items

- Enhancement is GPU-heavy by nature; the stage is optional per project by design (default: skip for standard episodes).
- Inspirations are credited by name only (README Credits + in-doc credit lines). No text was copied from any source repo.

---

## v1.2 build log (2026-10-14)

Added: `localization/dubbing.md`, `voiceover/ai-music-sfx.md`, `voiceover/multi-voice.md`, `video/talking-heads.md`, `scripts/dub-prep.sh`. Changed: `GUIDE.md` (new optional Stage 10 Localization, format matrix + reference docs updated, voiceover stage notes), `README.md` (repo map, credits, changelog, pipeline heading).

### Test results
- `bash -n` on all 7 scripts: OK.
- Repo-wide em-dash grep: zero matches.
- dub-prep.sh --dry-run on an 8-line fixture (3 speakers, blank line, unlabeled continuation, label-only line): exit 0; correct plan (5 segments, 47 words, 18.8s est at 150wpm; label-only line skipped with warning; no files written).
- dub-prep.sh --speakers: exit 0; speakers listed in first-appearance order, no files written.
- dub-prep.sh real split: exit 0; 5 segment files + manifest.tsv; independently verified with python3: no label-pattern line in any segment file, manifest word counts correct (11, 7, 11, 6, 12), durations match words*60/wpm (4.4, 2.8, 4.4, 2.4, 4.8s).
- --wpm 120 --lang zh: durations 5.5/3.5/5.5/3.0/6.0s, lang zh; all match wpm math.
- Edge cases: label-free script becomes one UNKNOWN segment with warning; label-only line at EOF skipped with warning; empty script produces header-only manifest; missing input exits 2 with usage; --wpm 0 / --wpm abc exit 2 with usage.

### Caveats and open items
- The awk label regex treats any line starting with an UPPERCASE token ending in a colon as a speaker label (e.g. `SCENE 1:` would become speaker "SCENE 1"); documented in the script usage text.
- AI upscaler/true-RIFE paths (v1.1) remain unexercised live (binaries not installed on this VM).
- Inspirations credited by name only (README Credits + in-doc credit lines). No text copied from any source repo.

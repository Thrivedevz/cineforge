# CineForge

CineForge is a production playbook for building recap-style AI video episodes end to end, from raw idea to a finished, quality-checked MP4. It was developed while producing long-form anime recap episodes (15-23 minutes each, roughly 45-55 narration words per scene) and encodes everything the process taught: a nine-stage pipeline, strict no-hallucination source discipline, voiceover and audio-post chains, character-design consistency rules, directing principles for prompt engineering, assembly conventions, and QC gates. It does not generate video by itself. It directs external video models and automates everything around them: script prep, voiceover synthesis, original music, animated captions, assembly, and packaging.

## The pipeline

```
+-------+   +--------+   +-----------+   +-----------------+
| 1     |   | 2      |   | 3         |   | 4               |
| IDEA  |-->> SCRIPT |-->> VOICEOVER |-->> CHARACTER       |
+-------+   +--------+   +-----------+   | DESIGN          |
                                        +--------+--------+
                                                 |
                                                 v
+-----------+   +----------+   +----------+   +----------+
| 9         |   | 8        |   | 7        |   | 5        |
| QC /      |<<--| ASSEMBLY |<<--| GENERA-  |   | REFE-    |
| PACKAGING |   |          |   | TION     |   | RENCE    |
+-----------+   +----------+   +----------+   | IMAGES   |
                                               +---+------+
                                                   |
                                                   v
                                           +----------+
                                           | 6        |
                                           | PROMPT   |
                                           | ENGR     |
                                           +----------+
```

Optional stage 7.5 (ENHANCE: upscaling/denoising, frame interpolation) sits between generation (7) and assembly (8). It is never a gate: stage 7 output is always assembly-ready without it.

Stage 6 (prompt engineering) draws on the character designs from stage 4 and the reference images from stage 5. Stages 4-6 can overlap with stage 3 once the script is locked.

## Quickstart

1. Read `GUIDE.md` once, end to end. It is the staged playbook with exit gates.
2. Draft your idea, then write the script per stage 2 (3 chapters per episode, 4 for longer episodes, with a short spoken subscribe/like bumper at the start and end).
3. Substitute phonetics and synthesize the voiceover (`scripts/tts-synthesize.sh`), then run `scripts/voice-post.sh` for the audio post chain.
4. Build or reuse the character design library entries (`video/character-design-system.md`), collect reference images, and write scene prompts with `prompts/prompt-formula.md`.
5. Generate the scenes with your video model of choice, then assemble with `scripts/assemble.sh`, add the music bed (`scripts/music-bed.sh`), and render animated word-by-word captions.
6. Run `scripts/qc.sh`. Only ship if every check in `workflow/qc-checklist.md` passes. Deliver one whole-episode MP4.

## Repo map

```
cineforge/
  README.md
  GUIDE.md
  LICENSE
  BUILD_NOTES.md
  prompts/
    prompt-formula.md
    directing-briefs/
      cinematic.md
      anime-action.md
      fantasy-film.md
      ads-ugc.md
      documentary.md
    templates/
      scene-prompt-template.md
      character-lock-template.md
      voiceover-block-template.md
      film-brief-template.md
  voiceover/
    voice-direction.md
    phonetics-guide.md
    tts-pipeline.md
    audio-post.md
    music-bed.md
    audio-separation.md
    ai-music-sfx.md
    multi-voice.md
  video/
    enhancement.md
    generation-backends.md
    generation-workflows.md
    character-design-system.md
    talking-heads.md
    assembly.md
  localization/
    dubbing.md
  scripts/
    tts-synthesize.sh
    voice-post.sh
    music-bed.sh
    assemble.sh
    enhance.sh
    dub-prep.sh
    qc.sh
  examples/
    episode-breakdown/
      README.md
  thumbnails/
    thumbnail-system.md
  workflow/
    stage-gates.md
    qc-checklist.md
```

## Core rules

- **No hallucination.** Every event, name, technique, and outcome stays exactly as the source material. Value-add lives only in presentation: pacing, tension, vivid retelling, cinematic narration.
- **Short spoken subscribe/like bumper** at the start and end of every episode, a few seconds each, spoken only, no text overlay.
- **Original dramatic openings and closings.** Strip any source self-promo. Never replicate the source's episode boundaries.

## What CineForge is not

- It is **not** a self-contained text-to-video app. There is no built-in video model.
- It **directs external video models** and automates everything around them: voiceover synthesis, original music generation, animated captions, assembly, QC, and packaging.
- It is **not** a dataset or a media library. It ships process, templates, and scripts, not footage.
- It is **not** tied to one provider. The pipeline stages work with any video model, TTS backend, or editor that accepts the inputs described in the playbook.

## Credits

Pipeline architecture inspired by MoneyPrinterTurbo; workflow structure inspired by guide-to-best-ai-filmmaking; directing-brief formula inspired by flaqai prompt packs. v1.1 inspirations: Anime4K (bloc97/Anime4K) and video2x (k4yt3x/video2x) for the enhancement stage, RIFE (rife-ncnn-vulkan) for frame interpolation, Ultimate Vocal Remover (Anjok07/ultimatevocalremovergui) for audio separation, ComfyUI (Comfy-Org/ComfyUI) for the alternate generation backend. v1.2 inspirations: VideoLingo (Huanshere/VideoLingo) for dubbing and localization, Meta AudioCraft (facebookresearch/audiocraft) for AI music and SFX, Chatterbox (resemble-ai/chatterbox) for multi-voice cloning, SadTalker (OpenTalker/SadTalker) for talking heads. All content in this repo is original.

## Changelog

### v1.2 (2026-10-14): adds the localization stage (Stage 10: dubbing + subtitles), AI music/SFX premium tier doc, multi-voice direction doc, talking-heads doc, and the dub-prep.sh script.

### v1.1 (2026-10-14): adds the optional enhancement stage (Stage 7.5), audio-separation doc, alternate generation backends doc, enhance.sh script, and the format matrix.

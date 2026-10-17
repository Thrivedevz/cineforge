# CineForge Playbook: the production stages

This guide walks the full pipeline from idea to packaged episode. Each stage lists its purpose, inputs, step-by-step actions, outputs, and the exit gate you must clear before moving on. Do not skip gates. Thin scripts, inconsistent characters, and untested audio chains are the three most common reasons episodes need rebuilding.

Core rule for the entire pipeline: **no hallucination.** Every event, name, technique, and outcome stays exactly as the source material. Value-add lives only in presentation (pacing, tension, vivid retelling, cinematic narration). Strip source self-promo. Use original dramatic openings and closings, never a replica of the source's episode boundaries. If a transcript and the source disagree, flag it. Never invent.

---

## Stage 1: Idea

**Purpose.** Decide what this episode covers and why it deserves to exist, before any writing begins.

**Inputs.** Your series plan, source chapters, audience feedback, channel direction.

**Steps.**
1. Pick the source range for this episode. Standard: 3 chapters per episode, 4 for longer episodes that need the room.
2. Write a one-paragraph arc: what changes by the end, and what the viewer feels.
3. Draft the episode's dramatic opening hook (a few seconds) and closing beat. These must be your own, never a replica of the source's episode boundaries.

**Outputs.** A one-paragraph arc plus hook and closing notes.

**Exit gate.** You can state the episode's arc and source range in two sentences. If not, the idea is not ready.

---

## Stage 2: Script

**Purpose.** Produce the full narration script at the locked length and density: 15-23 minutes, roughly 45-55 narration words per scene.

**Inputs.** Stage 1 arc, source chapters, phonetic conventions.

**Steps.**
1. Write the script scene by scene, following the source exactly. Every event, name, technique, and outcome stays as written.
2. Bake performance direction into the text: ellipses (...) for suspense pauses, short hammer-blow sentences for impact, slow burn before reveals, rising finish. Write numbers and times in spoken form ("twenty three minutes", not "23 min").
3. Open and close with a SHORT spoken subscribe/like bumper (a few seconds each, spoken only, no text overlay).
4. Cut any self-promo insertions from the source (links, website plugs, "full audio on my site"). Keep the story clean.
5. Apply the **label-strip gate**: speaker labels like "Narrator:" must NEVER be spoken in the audio. Strip all segment labels from the script before synthesis. Verify the stripping path on one segment first (synthesize one block, listen, confirm no label is spoken) before running the full script.

**Outputs.** The final narration script, label-free, with phonetic substitutions applied.

**Exit gate.** Word count and scene count hit the density target (thin scripts must be expanded before assembly, never after). A one-segment synthesis test confirms labels are not spoken.

---

## Stage 3: Voiceover

**Purpose.** Turn the locked script into a finished vocal track.

**Inputs.** Final script from stage 2, voice `avocado_v2:MAI_03` ("Smooth", gentle American male).

**Steps.**
1. Substitute phonetic spellings for all proper names before synthesis (e.g. Xiao Yan becomes "Shyaow Yen"). Keep a phonetics table for the series so every episode pronounces names identically.
2. Apply the **TTS chunking rules**: merge 1-2 word lines into the neighboring paragraph (tiny chunks truncate or fail). For long scripts, split into quarters, synthesize each quarter separately, then concatenate. This isolates failures fast.
3. Run synthesis, then check every segment for completeness: no truncation, no missing lines, no label leakage.
4. Apply the audio post chain (ffmpeg): `acompressor=threshold=-20dB:ratio=3:attack=15:release=200:makeup=3dB`, then `aecho=0.8:0.6:25|40:0.18|0.12` (subtle room), then `loudnorm=I=-16:TP=-1.5:LRA=11`.

**Outputs.** A single normalized voice track, plus the original music bed (stage 8) ready to mix underneath. For dialogue-heavy productions, see `voiceover/multi-voice.md` (one locked voice per character) and `voiceover/ai-music-sfx.md` (AI-generated scores as the premium tier above the procedural bed).

**Exit gate.** Full decode of the voice track plays clean, ends to end. Loudness verified against the normalization target.

---

## Stage 4: Character design

**Purpose.** Lock how every appearing character looks, before any video is generated.

**Inputs.** Script character list, official anime designs where they exist.

**Steps.**
1. For every character appearing in this episode, web-check their official anime design before production. Never guess looks.
2. Record each character in the character design library (indexed). The library is the single source of truth for appearance.
3. Characters with no official design get ONE locked original design at their first appearance. That design is reused consistently from then on, never redesigned.
4. Apply the same rule to signature effects and weapons (flames, fire forms, signature weapons). Their designs lock once and stay consistent series-wide.

**Outputs.** Design library entries for every appearing character, effect, and weapon.

**Exit gate.** Every character in the script has a library entry or a confirmed reuse of an existing locked design. No character goes into prompting undesigned.

---

## Stage 5: Reference images

**Purpose.** Assemble the visual anchors the video model will hold on to during generation.

**Inputs.** Stage 4 design entries, official art, prior episode frames.

**Steps.**
1. Collect or generate reference images per locked design: clean front view, plus key alternates (e.g. battle stance, signature weapon in hand).
2. Verify each reference matches the library entry. If it drifts, fix the reference, never the design.
3. Organize references per character and episode so prompt writing can pull them directly.

**Outputs.** A reference image set keyed to the script's cast list.

**Exit gate.** Every character has at least one clean reference, and each matches its library entry.

---

## Stage 6: Prompt engineering

**Purpose.** Write generation prompts that produce consistent, cinematic, real animation for every scene.

**Inputs.** Locked script, character library entries, reference images.

**Directing principles (apply to every prompt).**
- Name the mechanism, never the mood: specify lens, light source, and color grade, not feelings.
- Lock character first, location second: the prompt leads with the locked design, then places it.
- Physical actions only, never interior states: "he raises the blade" is promptable, "he feels conflicted" is not.
- Style DNA written once, pasted byte-identical into every prompt of the series.
- Dialogue and physical action never overlap in a single shot description.

**Steps.**
1. Write one prompt per scene using the scene-prompt template.
2. Attach the character reference images for every character in the shot (this is how consistency is enforced).
3. Every scene must be real animation. No stills, no slow-zoom fallbacks, no exceptions.

**Outputs.** A complete set of scene prompts with references attached.

**Exit gate.** Every script scene has a prompt, and every prompt passes the directing-principles check.

---

## Stage 7: Generation

**Purpose.** Produce the actual video clips from the prompts.

**Inputs.** Stage 6 prompts, your video model of choice.

**Steps.**
1. Generate in small batches so a declined or degraded batch is cheap to redo.
2. If the model declines a violent prompt, produce the scene at outcome level: narrate what happens without invented choreography, matching the source exactly.
3. Keep every generated clip. Log any regenerated or declined scenes with a note on how they were handled.

**Outputs.** A full set of scene clips covering the episode.

**Exit gate.** Every scene has usable animation. Any declined scenes have a documented, source-faithful fallback.

---

## Stage 7.5: Enhancement (optional)

**Purpose.** Optional post-generation polish applied between generation and assembly. It is numbered 7.5 precisely because it is optional and never blocks the pipeline: the stage 7 output is always assembly-ready without it.

**Inputs.** Stage 7 scene clips, project budget and timeline.

**Steps.**
1. Decide per project whether enhancement is worth the compute. Default: skip for standard episodes. Consider it for flagship releases.
2. For anime content, apply anime upscaling/denoising (Anime4K technique). For photorealistic content, use Real-ESRGAN.
3. Optionally interpolate frames for smoother motion (RIFE-style).
4. Always keep the pre-enhancement master untouched, so any pass can be redone or dropped without losing the original clips.

**Outputs.** Enhanced scene clips, with the pre-enhancement master archived.

**Exit gate.** Enhanced clips verified against the pre-enhancement master: no new artifacts, character designs intact. If in doubt, ship the unenhanced clips.

---

## Stage 8: Assembly

**Purpose.** Combine voice, clips, music, and captions into one finished episode file.

**Inputs.** Voice track, scene clips, original music bed, caption timing.

**Steps.**
1. Assemble into ONE whole-episode MP4. Never split parts.
2. Generate the music bed: 100% original dark ambient drone (A-minor sines 55/110/130.81/164.81/220 Hz, tremolo, lowpass 800Hz, multi-tap echo). Mix it REALLY low, a barely-there background presence that never distracts from narration. Fade out the last 7 seconds. Never use stock or unknown-license tracks.
3. Render captions as animated word-by-word (AutoSubs-like) captions, not static subtitles. Keep them low key.
4. Encode with the size cap: ~5-6 Mbps. Files around 1 GB or larger choke consumer players.

**Outputs.** One whole-episode MP4 with voice, music bed, and animated captions.

**Exit gate.** The file exists, plays, and is under the size ceiling.

---

## Stage 9: QC and packaging

**Purpose.** Verify the episode is shippable, then deliver it as one file.

**Inputs.** Assembled MP4.

**Steps.**
1. Run the QC script: black-frame detection, full decode check, loudness verification, file-size guard.
2. Watch the opening and closing bumpers plus two random middle scenes at speed. Check caption sync on each.
3. Deliver ONE complete episode file to the final destination. Never split parts, never attach fragments.
4. Package for upload: run `scripts/package_youtube.py` with the episode metadata and scene timings to produce the title, description (policy-validated chapters), tags, thumbnail, and upload checklist (`packaging/youtube-packaging.md`). Review the package; nothing is published automatically.

**Outputs.** The delivered episode file, plus a QC log.

**Exit gate.** Every QC check passes. If one fails, fix the cause at its stage (thin script, bad prompt, bad encode) rather than patching the output.

---

## Stage 10: Localization (optional)

**Purpose.** Produce dubbed and/or subtitled versions of a finished episode for new audiences, without re-running the production pipeline.

**Inputs.** The delivered episode file, the locked term table (character names, technique names, place names), per-character locked voices.

**Steps.**
1. Segment subtitles sentence-aware with length limits (`localization/dubbing.md`).
2. Translate with the term table locked, so names stay identical across languages (same discipline as the phonetics table).
3. Dub with one consistent voice per character across languages (`voiceover/multi-voice.md`), aligned to original scene timing. Prepare inputs with `scripts/dub-prep.sh`.
4. Run the dubbing QC checklist: sync, levels, no buried dialogue, labels never synthesized.

**Outputs.** Localized subtitle files and/or dubbed episode versions, plus a dubbing QC log.

**Exit gate.** Dubbed lines match original timing, terminology is consistent, and every dubbing QC check passes.

---

## Format matrix

The pipeline is format-agnostic. Universal across formats: the stages, the scripting rules, the full voiceover studio (phonetics, TTS pipeline, audio post, original music bed, AI music premium tier, multi-voice), assembly, animated captions, QC, thumbnails, and localization. What swaps per format is the design system, the enhancement option, the directing-brief pack, and where relevant the audio setup.

| Format | What swaps in |
| --- | --- |
| Anime recap | Anime-accurate character designs, Anime4K enhancement option, `prompts/directing-briefs/anime-action.md` |
| Photorealistic fantasy film | Photorealistic character sheets, Real-ESRGAN enhancement option, `prompts/directing-briefs/fantasy-film.md`, audio-separation for dialogue (`voiceover/audio-separation.md`) |
| Ads / UGC | `prompts/directing-briefs/ads-ugc.md`, lighter QC density as appropriate |
| Documentary | `prompts/directing-briefs/documentary.md`, lighter QC density as appropriate |
| Horror narration | Practical-light design system, `prompts/directing-briefs/horror.md` |

## Thumbnail

Every episode ships with a thumbnail from the locked template: the episode number rendered as "01" inside an ornamented golden ring badge at the top-right, with the series' full name in gold along the bottom. Reuse the template with only the number swapped.

## Reference documents

- `workflow/stage-gates.md`: the stage gates in checklist form.
- `workflow/qc-checklist.md`: the full QC pass.
- `prompts/prompt-formula.md`: the directing-brief formula.
- `localization/dubbing.md`: dubbing and localization direction.
- `voiceover/ai-music-sfx.md`: AI-generated music and SFX (premium tier).
- `voiceover/multi-voice.md`: multi-character voice direction.
- `video/talking-heads.md`: talking-head generation direction.
- `voiceover/`: voice direction, phonetics, TTS pipeline, audio post, music bed, audio-separation.
- `video/`: generation workflows, character design system, assembly, enhancement, generation-backends.
- `scripts/`: the eight runnable pipeline scripts.
- `examples/episode-breakdown/`: a worked example of one episode.

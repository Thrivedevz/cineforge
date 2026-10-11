# Stage Gates

Nine stages. Each stage lists entry criteria (what must be true to start), actions (what happens), outputs (what it produces), and the exit gate (what must pass before the next stage starts). No stage starts until the previous stage's exit gate is green.

## Stage 1: Idea

- **Entry:** a source to adapt (novel chapters, fanfic arc, original concept) and a target episode length.
- **Actions:** pick the chapters or beats the episode covers; define the episode's dramatic arc (opening hook, midpoint turn, closing beat); confirm the episode does not replicate another channel's episode boundaries.
- **Outputs:** a one-paragraph episode brief: chapters covered, arc beats, target length.
- **Exit gate:** the brief is written and the chapter range is final. No script work until the range is locked.

## Stage 2: Script

- **Entry:** locked episode brief from Stage 1.
- **Actions:** write the narration script scene by scene at 45 to 55 words per scene; add short subscribe/like bumpers at start and end (spoken, no overlay); strip any self-promo insertions from source transcripts; dramatize only in presentation (pacing, tension, vivid retelling), never invent events, names, techniques, or outcomes.
- **Outputs:** full narration script with scene breaks.
- **Exit gate:** word count and scene count hit the length target (15 to 23 minutes at planned pacing); script read-through confirms zero hallucination against the source. Thin scripts are expanded here, never later.

## Stage 3: Voiceover

- **Entry:** final script from Stage 2.
- **Actions:** run the pre-synthesis checks (`workflow/qc-checklist.md`): strip speaker labels, substitute locked phonetics, merge ultra-short chunks; synthesize in quarters and concatenate; apply the post chain (compressor, subtle room, loudnorm to target).
- **Outputs:** finished voiceover track with the post chain applied, at target loudness.
- **Exit gate:** full listen-through with no mispronunciations, no spoken labels, no truncation artifacts; loudness verified.

## Stage 4: Character design

- **Entry:** script from Stage 2 (character list known).
- **Actions:** web-check every new character's appearance AND pronunciation; save references into the character design library and register them in INDEX.md; for fanfic-original characters with no official design, create ONE locked original design; lock effect and weapon designs the same way.
- **Outputs:** library entries + updated INDEX.md for every character, effect, and item in the episode.
- **Exit gate:** every character appearing in the episode has a registered, locked design. No generation begins with an unlocked character.

## Stage 5: Reference images

- **Entry:** locked designs from Stage 4.
- **Actions:** prepare keyframes and anchor images for the episode's shots: identity anchors, style anchors, motion anchors, environment plates; each assigned one explicit role.
- **Outputs:** a shot list mapping each shot to its workflow mode (T2V/I2V/reference) and its reference images.
- **Exit gate:** every shot on the list has its mode and references assigned. No shot goes to generation without a plan.

## Stage 6: Prompt engineering

- **Entry:** shot list from Stage 5.
- **Actions:** write the directing brief for each shot following the directing principles: Style DNA byte-identical across blocks, character first then location, physical actions only, mechanism named not mood, dialogue and action never overlapping; for I2V, specify exactly what moves and by how much; for reference mode, use @image-style matching.
- **Outputs:** finished prompt set, one per shot, with the shot list updated.
- **Exit gate:** prompts reviewed against the directing principles; Style DNA verified byte-identical across the block.

## Stage 7: Generation

- **Entry:** finished prompts from Stage 6.
- **Actions:** generate every shot as real animation; on a decline or botched shot, regenerate once softened, then fall back to a planned bridge scene (environment/energy) with outcome-level narration; never invent choreography.
- **Outputs:** finished shot files for every beat in the shot list.
- **Exit gate:** every shot exists, is real animation (no stills, no slow-zoom fallbacks), and character identity holds against the references.

## Stage 8: Assembly

- **Entry:** finished voiceover (Stage 3) and finished shots (Stage 7).
- **Actions:** mix voiceover full with the original music bed really low underneath; burn in animated word-by-word captions from ASS; encode h264 + aac at ~5 to 6 Mbps; output exactly one whole-episode MP4 under a fresh filename.
- **Outputs:** the final episode MP4.
- **Exit gate:** file exists, is a single whole file, filename is fresh (not reused), bitrate at cap.

## Stage 9: QC and packaging

- **Entry:** assembled MP4 from Stage 8.
- **Actions:** run the full post-assembly checklist (`workflow/qc-checklist.md`): black-frame detection, full decode pass, loudness verification, file-size guardrail, caption check, thumbnail template match; generate the thumbnail from the locked template with the episode number swapped.
- **Outputs:** QC-passed episode file + thumbnail, ready for delivery.
- **Exit gate:** every checklist item passes. A failed item goes back to the stage that produced it, not forward.

# The CineForge Prompt Formula

Every scene brief in this repo follows one formula: eight blocks, in this order, every time. The formula exists because video generators fail in predictable ways, and each block closes one failure mode.

## The 8 Blocks

### 1. [Output]
Duration, aspect ratio, and visual medium.

Why: the generator needs to know how long the shot is, what frame to fill, and whether this is live-action-look, anime, photorealistic fantasy, or stylized. A prompt that skips this drifts between styles shot to shot.

Common mistake: leaving the medium vague ("cinematic video"). Name the medium directly: "photorealistic live-action look", "2D anime style, clean linework", "photorealistic dark fantasy".

### 2. [Subject]
Reusable identity anchors plus immutable details.

Why: consistency across scenes comes from anchors, not re-descriptions. Define a character once (in a character lock file), then reference the anchor: "MARA as defined in the character lock".

Common mistake: re-describing the character differently in every scene. Hair color, costume details, and scars drift unless anchored. Lock once, reference forever.

### 3. [World]
Time, place, weather, spatial layers.

Why: the generator places the action inside a space. Time of day sets the light logic, place sets the set dressing, weather sets atmosphere and motion (rain, dust, wind), and spatial layers (foreground, midground, background) give depth.

Common mistake: "a forest". Which forest, at what hour, in what weather? A bare noun gives the generator nothing to hold onto, so every shot looks like a different forest.

### 4. [Action]
Trigger, then continuous motion, then visible result.

Why: most generated shots die because nothing actually happens. The trigger starts the motion (what initiates it), the continuous motion is the physical thing that must keep moving through the whole shot, and the visible result is the payoff the camera must show.

Common mistake: interior states ("he feels afraid") or static poses ("she stands in the rain"). Write physical actions only: what moves, how it moves, and what changes because of it.

### 5. [Camera]
Shot size, angle, one movement path, ending frame.

Why: generators default to a flat wide shot unless told otherwise. One movement path (push in, lateral track, crane up) gives the shot a beginning and an end. Naming the ending frame locks where the shot lands.

Common mistake: two movements in one shot ("dolly in then crane up"), or no movement at all. Pick one path. If the shot needs two movements, it is two shots.

### 6. [Look]
Light, palette, material, motion treatment.

Why: this is the grade. Name the light source (low sun through dust, single practical lamp), the palette (cool blues, warm highlights), the material feel (wet stone, worn leather, polished steel), and how motion should feel (48fps-smooth slow motion, handheld with micro shake, locked tripod).

Common mistake: mood words ("dramatic", "epic", "moody"). Name the mechanism: the lens, the light source, the grade. "Dramatic" means nothing to a generator; "low key side light, crushed blacks, desaturated greens" means something.

### 7. [Sound]
Ambience, action sound, music, dialogue (if supported).

Why: some generators take audio direction. Even when they do not, this block becomes the audio edit sheet for assembly: what bed runs under the shot, what sync sounds the action needs, where dialogue lands.

Common mistake: skipping it because "the generator ignores audio anyway". It becomes the assembly checklist later, so write it now.

### 8. [Constraints]
What must remain, plus most likely failure modes.

Why: this is the guard rail. State what cannot change (the locked flame design, the character anchor, the aspect ratio) and name the ways this specific shot is likely to break (extra fingers, drifting costume, frozen background, morphing weapon), so the reviewer checks those first.

Common mistake: generic constraints ("make it good"). Name the actual failure modes for this shot. You know them; the generator does not.

## Worked Example

**Brief: Rooftop Signal (night chase pickup)**

[Output] 6 seconds, 16:9, photorealistic live-action look.

[Subject] RUNNER as defined in the character lock (lean build, cropped black hair, grey hooded jacket with torn left sleeve, dark cargo pants, headlamp). HEADLAMP on, white LED beam, locked look across all scenes.

[World] 2:00 AM, industrial rooftop, rain just stopped. Wet gravel roof, ventilation ducts foreground, city glow midground, crane silhouette background. Damp air, thin mist at ankle height.

[Action] Trigger: a distant siren wail rises. Continuous motion: the runner sprints across the gravel roof from left frame to right frame, gravel scattering under each stride, headlamp beam sweeping the vents ahead. Visible result: she reaches the roof edge, grabs the antenna mast, and swings down out of frame, the mast shuddering.

[Camera] Medium wide, eye level, single lateral track matching her speed left to right, ending frame: empty roof edge with the mast still swaying, city glow beyond.

[Look] Sodium-vapor city glow from below, cool blue rim from the headlamp beam, crushed blacks, desaturated except the amber windows. Wet gravel with reflective sheen. Slight handheld micro shake, 24fps motion blur on the sprint.

[Sound] Ambience: wet wind, distant siren swelling. Action sound: gravel scatter under boots, mast clanging once when grabbed. Music: none in this shot, tension carries. Dialogue: none.

[Constraints] Must remain: headlamp beam locked white, grey jacket with torn left sleeve, 16:9. Likely failure modes: generator freezes her mid-sprint into a still pose; mast bends instead of swaying; extra fingers on the grab; headlamp beam changes color. Reject any take where she stops moving before the edge.

---

Last verified: 2026-10. Model-agnostic: the formula targets the mechanism of any video generator, not a specific product.

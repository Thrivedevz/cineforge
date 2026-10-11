# Worked Example: "The Lantern Keeper of Mirell"

A 3-scene original fantasy micro-film, run end to end through the CineForge pipeline. Every name, place, and event below is invented for this example. The pipeline is the point, not the story.

---

## 1. Film Brief

**Logline:** A lone lantern keeper in a fog-bound marsh town must relight the last beacon before the evening mist swallows the causeway, and learn who lit it before her.

**Runtime target:** ~2 minutes.

**Scenes:** 3.

**Style DNA** (paste byte-identical into every scene brief):

```
Photorealistic dusk fantasy. 35mm lens language: shallow depth of field, natural skin texture, no stylization. Teal-and-ember palette: fog reads cool teal, lantern light reads warm ember, no pure white highlights. Wet surfaces everywhere: mist, rain-polished stone, still black water. Camera moves are slow and deliberate, one path per shot.
```

**Characters:**

1. **Mirell**: the lantern keeper. A quiet woman in her fifties who walks the causeway every dusk.
2. **Sareth**: a hooded boatman in his thirties. He drifts the marsh channels and sees things others miss.

**Locations:**

1. **The causeway of Veylan**: a low stone footpath crossing black marsh water, lined with iron lantern posts.
2. **The last beacon**: a tall stone lantern at the causeway's end, cold and dark at the start of the film.

**Sound direction:** Sparse. Marsh ambience under everything (water movement, distant frogs, wind through reeds). Lantern mechanics give tactile action sounds (glass doors, chain links, match strike). No dialogue in the film itself. The only spoken words are the narrator and the subscribe bumpers. Music: an original low drone bed, barely present, warming slightly in the final scene.

**Delivery spec:** Single MP4, ~5 Mbps, h264 video + aac audio, 1080p.

---

## 2. Script Sample

Full narration script with performance notation baked in. Ellipses (...) mark suspense pauses. Short hammer-blow sentences land the beats. Scene 3 uses a slow burn before the reveal, then a rising finish. Numbers in spoken form.

### Bumpers (spoken only, no text overlay)

**Open (start, 3 seconds):** "If you love slow fantasy tales, like this film and subscribe."

**Close (end, 4 seconds):** "One keeper. One light. Subscribe for the next tale."

### Scene 1: The Causeway

1. "Dusk settles over the marshes of Veylan... and the fog rises like a held breath."
2. "Mirell has walked this causeway for twenty two years. Every evening, the same path. The same nine lanterns."
3. "Tonight, eight burn. The ninth stands dark."

### Scene 2: The Long Walk

1. "She moves faster now. Her boots ring on the wet stone. The mist thickens between the posts."
2. "Behind her, the eight flames shrink to ember dots. Ahead, the ninth lantern waits... cold. Silent."
3. "A boat slides through the channel below. Sareth lifts his hand. He does not call out."

### Scene 3: The Ninth Lantern

1. "She opens the glass door. The hinge sighs. She strikes the match... once... twice."
2. "The flame catches. It climbs. Light spills across the black water, and the marsh holds still."
3. "And there, scratched in the soot beneath the wick, three small marks. Sareth's mark. He relights it every dusk... before she arrives."
4. "She smiles. The causeway is whole again. Nine lights, burning against the dark."

### Label-strip gate (how it works)

The raw script file carries speaker labels for the editor:

```
NARRATOR: "Behind her, the eight flames shrink to ember dots."
```

That label is never synthesized. The gate strips it before the text reaches TTS:

```
"Behind her, the eight flames shrink to ember dots."
```

Every script is checked for remaining labels (`NARRATOR:`, `KEEPER:`, etc.) before any synthesis run. One missed label means a rebuild.

---

## 3. Phonetic Notes

Rule: agree on the phonetic spelling of every invented name once, before any synthesis, and use that spelling in every script from then on. Never let TTS guess.

| Name     | Phonetic spelling | Notes                          |
|----------|-------------------|--------------------------------|
| Mirell   | "Mih-rell"        | Soft stress on the second syllable |
| Sareth   | "Sah-reth"        | Short "a", soft "th"           |
| Veylan   | "Vay-lun"         | "Vay" rhymes with "day"        |

If a name sounds wrong in the test render, change the spelling in this table, not in the script. The table is the single source of truth.

---

## 4. Voiceover Direction

**Voice:** `avocado_v2:MAI_03` ("Smooth", gentle American male).

**Per-scene pacing:**

- Scene 1: slow and hushed, narration sits under the fog. Long pauses after each ellipsis. Let the first line breathe.
- Scene 2: rising tension, slightly faster line spacing, no rush. Hammer-blow delivery on "Tonight, eight burn. The ninth stands dark."
- Scene 3: slow burn through lines 1 and 2 (the lighting is a ritual, not a race), then a rising finish from "Sareth's mark" to the end. The final line is warm and settled.

**Chunking notes (TTS):**

- The bumper lines ("If you love slow fantasy tales, like this film and subscribe.") are short but were kept as standalone chunks because they are the only lines in their segments; no merge needed since each exceeds ~20 characters.
- In scene 1, no merges were needed: each line is long enough to synthesize cleanly.
- The label-strip check ran on all chunks before synthesis: zero labels found.

**Post chain (ffmpeg):** `acompressor=threshold=-20dB:ratio=3:attack=15:release=200:makeup=3dB` + `aecho=0.8:0.6:25|40:0.18|0.12` + `loudnorm=I=-16:TP=-1.5:LRA=11`.

**Music bed:** original drone, mixed very low under voice, fading out over the final 5 seconds. 100% original, zero copyright-claim risk.

---

## 5. Directing Briefs

Each brief follows the 8-block formula in order. Style DNA is pasted byte-identical into every [Look] block. Dialogue and action never overlap (this film has no in-scene dialogue). Continuous motion in every shot: no stills, no slideshow feel.

### Scene 1: The Causeway

Last verified: 2026-10. Model-agnostic.

**[Output]** 40 seconds. 16:9. Photorealistic live-action look (video generation).

**[Subject]** Mirell, the lantern keeper. Identity anchors: woman in her fifties, silver-streaked dark hair in a low knot, plain oilskin coat with brass buttons, long wooden taper in her right hand, steady unhurried gait. Immutable details: brass buttons (five, tarnished), taper never leaves her right hand in this scene.

**[World]** Dusk. The causeway of Veylan crossing black marsh water. Thick fog rolling low over the water, visibility fading at twenty paces. Spatial layers: foreground, lantern post; midground, Mirell walking; background, a line of lit posts dissolving into fog.

**[Action]** Trigger: Mirell enters frame from the left, already walking. Continuous motion: she walks the full length of the causeway toward camera-side, coat hem shifting, fog drifting past her, each passing lantern flaring as she passes. Visible result: she reaches the middle of the causeway where the last two lit posts stand, then slows and looks ahead into the dark.

**[Camera]** Medium wide shot, eye level, slow lateral tracking matching her walk speed, one movement path, ending frame: she stops at the center of the causeway, the dark lantern gap visible far ahead in the fog.

**[Look]** Light: fading dusk light through fog plus warm ember glow from the lit lanterns. Palette: teal-and-ember per Style DNA. Material: wet polished stone, damp oilskin, warm glass lantern glow. Motion treatment: everything drifts slowly, fog particles visible in lantern light.

```
Photorealistic dusk fantasy. 35mm lens language: shallow depth of field, natural skin texture, no stylization. Teal-and-ember palette: fog reads cool teal, lantern light reads warm ember, no pure white highlights. Wet surfaces everywhere: mist, rain-polished stone, still black water. Camera moves are slow and deliberate, one path per shot.
```

**[Sound]** Ambience: marsh water movement, wind through reeds, distant frog calls. Action sound: her boots on wet stone, cloth shifting. Music: the original drone bed, very low. Dialogue: narrator only.

**[Constraints]** Mirell's costume and the five brass buttons must remain identical across all her shots. Lantern flame color must stay ember (not white). Most likely failure modes: the generator drops the taper from her hand mid-walk; fog thinning too much and revealing the background as empty black; her hair changing style between shots.

### Scene 2: The Long Walk

Last verified: 2026-10. Model-agnostic.

**[Output]** 40 seconds. 16:9. Photorealistic live-action look (video generation).

**[Subject]** Mirell, same identity anchors as Scene 1: woman in her fifties, silver-streaked dark hair in a low knot, oilskin coat with five tarnished brass buttons, wooden taper in her right hand. Now walking faster, coat pulling in the wind. Sareth, the boatman: hooded figure in a low marsh boat, gray wool cloak, weathered hands on a pole, face mostly hidden in the hood.

**[World]** Dusk deepening to early night. The causeway, mid-point. Fog is thicker now, visibility down to ten paces. Spatial layers: foreground, the last lit lantern; midground, Mirell quickening her pace; below, the black channel water with Sareth's boat sliding through the mist.

**[Action]** Trigger: Mirell breaks into a faster walk, taper swinging. Continuous motion: she moves past the last lit posts, the flames shrinking behind her as fog closes in; below the causeway, Sareth's boat glides forward, he lifts one hand toward her and lowers it; she glances down briefly, then forward. Visible result: Mirell is nearly running now, the dark gap ahead swallowing the path.

**[Camera]** High-angle medium shot from the causeway looking slightly down, slow push-in toward Mirell, one movement path, ending frame: tight on Mirell's back as she leans into the fog, the dark lantern posts faint ahead.

**[Look]** Light: the last lit lantern's ember glow behind her, cold teal fog ahead. Palette: teal-and-ember per Style DNA. Material: slick wet stone, fog catching the light, boat hull cutting black water. Motion treatment: fog flows continuously, water ripples behind the boat.

```
Photorealistic dusk fantasy. 35mm lens language: shallow depth of field, natural skin texture, no stylization. Teal-and-ember palette: fog reads cool teal, lantern light reads warm ember, no pure white highlights. Wet surfaces everywhere: mist, rain-polished stone, still black water. Camera moves are slow and deliberate, one path per shot.
```

**[Sound]** Ambience: fog-muffled marsh sounds, water lapping. Action sound: faster boot strikes on stone, boat hull sliding through water, the soft knock of the pole. Music: the drone bed, slightly more present. Dialogue: narrator only.

**[Constraints]** Mirell's coat buttons and taper must match Scene 1 exactly. The eight lit lanterns must visibly recede, not vanish. Sareth's face stays hidden in the hood (no revealed face). Most likely failure modes: the taper disappearing during faster motion; the boat floating above the water line; the lit lanterns popping out of frame abruptly instead of receding.

### Scene 3: The Ninth Lantern

Last verified: 2026-10. Model-agnostic.

**[Output]** 45 seconds. 16:9. Photorealistic live-action look (video generation).

**[Subject]** Mirell, same identity anchors: woman in her fifties, silver-streaked dark hair in a low knot, oilskin coat with five tarnished brass buttons. The ninth lantern: a tall stone post with an iron-and-glass housing, cold and dark, soot marks inside the glass.

**[World]** Night on the causeway's end. Fog thins slightly around the last beacon. Still black marsh water on both sides. Spatial layers: foreground, Mirell's hands at the lantern; midground, the lantern housing and its glow as it lights; background, the line of nine burning lanterns reflected in the water.

**[Action]** Trigger: Mirell reaches the ninth lantern and sets down the taper. Continuous motion: she opens the glass door (the hinge swings, the glass panel tilts outward), strikes a match (first strike fails, second catches), touches the flame to the wick, closes the door; the flame climbs and steadies; she leans close, and her fingers trace three small marks scratched in the soot. Visible result: the ninth lantern burns full and warm, and the causeway shows nine lights against the dark.

**[Camera]** Close shot on her hands and the lantern housing, slow push-in, one movement path, ending frame: the lit lantern fills the frame with its warm glow, Mirell's face half-lit beside it, smiling.

**[Look]** Light: the new ember flame is the dominant light source, warming her face. Palette: teal-and-ember per Style DNA. Material: soot-blackened glass, warm brass fittings, her weathered fingers. Motion treatment: the flame flickers naturally, fog drifts through the frame edges.

```
Photorealistic dusk fantasy. 35mm lens language: shallow depth of field, natural skin texture, no stylization. Teal-and-ember palette: fog reads cool teal, lantern light reads warm ember, no pure white highlights. Wet surfaces everywhere: mist, rain-polished stone, still black water. Camera moves are slow and deliberate, one path per shot.
```

**[Sound]** Ambience: near-still night marsh, faint water. Action sound: the glass door hinge sighing, the match scratching twice, the soft whoosh of the wick catching, her boots settling on the stone. Music: the drone bed warms slightly under the final lines, then fades. Dialogue: narrator only.

**[Constraints]** The lantern's soot marks (three small scratches) must be visible in the close-up. Flame color stays ember. Mirell's five brass buttons remain unchanged. Most likely failure modes: the flame appearing as a floating glow detached from the wick; her fingers warping while tracing the marks (regenerate the close-up if so); the door opening without the hinge motion.

---

## 6. Character Lock

One locked original design block per character. These were set once during design and never change across scenes, reshoots, or future films.

### Mirell (the lantern keeper)

- **Face:** Weathered oval face, late fifties, fine lines at the eyes, calm set mouth, light gray eyes.
- **Hair:** Dark hair with heavy silver streaking, worn in a low tight knot at the nape. No loose strands in the wind.
- **Build:** Medium height, sturdy, broad shoulders from years of walking with the taper.
- **Costume (immutable):** Dark brown oilskin coat with exactly five tarnished brass buttons down the front, high collar, deep side pockets. Heavy gray skirt below. Sturdy black boots. Long wooden taper carried in the right hand.
- **Must never change:** the five brass buttons, the low knot, the taper in the right hand, the gray eyes.

### Sareth (the boatman)

- **Face:** Mostly hidden. When the hood shifts, a lean weathered face in the thirties, close-cropped dark beard, one pale scar across the left cheek.
- **Hair:** Dark, short, barely visible under the hood.
- **Build:** Tall and lean, long arms, moves like someone used to water.
- **Costume (immutable):** Gray wool hooded cloak, frayed at the hem, no fastenings. Dark tunic and trousers. Bare hands. A long wooden pole always within reach of his boat.
- **Must never change:** the hood stays up in every shot, the scar stays on the left cheek, the frayed gray cloak, no revealed full face.

---

## 7. Assembly Settings

**Mix:** voiceover at full level with the post chain applied (compressor, subtle room echo, loudnorm). Original music bed mixed very low underneath, barely present, fading out over the final 5 seconds.

**Captions:** animated word-by-word captions, styled for the fantasy look (light serif, warm off-white text with soft shadow). Bumper lines get no text overlay: spoken only.

**Encode:** ~5 Mbps h264 video + aac audio, 1080p, yuv420p.

**Output:** single whole-film MP4 with a fresh filename. Never reuse a previous filename, so cached players do not replay the old file. Example: `lantern-keeper-of-mirell-v1.mp4`.

---

## 8. QC Log

Sample log from this film's delivery pass:

```
[QC] lantern-keeper-of-mirell-v1.mp4
[QC] 1. label-strip gate ............ PASS (0 speaker labels in TTS input)
[QC] 2. blackdetect ................. PASS (no black segments over 1.0s)
[QC] 3. full decode ................. PASS (ffmpeg decode, 0 errors, 125s duration)
[QC] 4. loudness .................... PASS (integrated -15.8 LUFS, target -16)
[QC] 5. file size guardrail .......... PASS (212 MB, well under 1 GB)
[QC] 6. caption timing spot check ... PASS (sampled 12 lines, all synced)
[QC] Result: SHIP
```

The file shipped as one whole-film MP4 after every check passed. Any failure would have meant a rebuild of the failed stage, not a patch on the shipped file.

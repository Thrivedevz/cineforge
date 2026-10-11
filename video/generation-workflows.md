# Generation Workflows

Three workflow modes. Pick one per shot. Never blend them in a single prompt.

## 1. Text-to-Video (T2V)

**When to use it:** the shot idea is open, no keyframe exists yet, and the scene needs a natural or atmospheric establishing frame.

**How to direct it:**
- Start from a written directing brief, not from vibes. The brief is a short paragraph built with the directing principles: character locked first, location second, physical actions only, the mechanism named (what the camera does, what moves), never the mood, never interior states.
- Write Style DNA once, paste it byte-identical at the head of every prompt in the block. Same bytes, every time. No paraphrasing.
- Example skeleton: `[Style DNA]. [Character: appearance from locked reference]. [Location]. [Camera move and duration]. [Physical action].`

## 2. Image-to-Video (I2V)

**When to use it:** a designed keyframe exists (character portrait, environment plate, composed frame) and the shot needs that exact composition animated.

**How to direct it:**
- Animate the keyframe. The prompt specifies exactly what moves and by how much: which elements, what direction, what amplitude, what speed. "The character's sleeve drifts left, about a hand's width, slowly." Not "she moves dramatically."
- Static elements stay static. Name them as locked: "background architecture does not shift."
- Same Style DNA block, byte-identical, appended to the motion description.

## 3. Reference-to-Video

**When to use it:** identity or style must be exact across scenes, or a motion pattern must repeat.

**How to direct it:**
- Assign one explicit role per reference image. One role, one job:
  - **Identity anchor:** locks the character's face, outfit, and key features.
  - **Style anchor:** locks the rendering style, palette, and lighting treatment.
  - **Motion anchor:** locks a repeatable motion pattern (walk cycle, attack stance).
- Never assign two roles to one reference. Never ask one image to be both identity and motion.
- Direct with @image-style referencing: tell the model to match the reference instead of re-describing the subject. Re-describing drifts. Matching holds.
- Reference images come from the character design library (`video/character-design-system.md`).

## Directing principles (all three modes)

1. Name the mechanism, never the mood. "Camera pushes in over 4 seconds" beats "builds dread."
2. Lock character first, location second, in that order, in every prompt.
3. Physical actions only. Never interior states ("he feels determined" is banned; "his jaw tightens" is allowed).
4. Style DNA is written once and pasted byte-identical across every block in the episode.
5. Dialogue and physical action never overlap in the same shot. Narration and dialogue speak; bodies act on separate beats.

## Regeneration and bridge-scene policy

Generators decline or botch shots. Violent or intense action prompts are the common failure. The policy:

1. Regenerate once with the prompt softened: less contact, more implication. Same choreography, lower explicitness.
2. If it still fails, use a **bridge scene**: environment shot, energy surge, debris, sky, ground impact, crowd reaction. These are fully legitimate shots, not fallbacks.
3. Pair the bridge scene with **outcome-level narration**: state what the source says happened and its result. Never invent choreography that did not happen in the source material.
4. Bridge scenes are planned, real animation, not stills. The "no stills, no slow-zoom fallbacks" rule applies to them too.

## Chaining shots for longer sequences

A fight or set piece longer than one shot is built as a chain:
- Break it into beats, one beat per shot, each 3 to 8 seconds.
- Alternate perspectives: action shot, reaction shot, environment/energy shot. This rhythm hides generation seams and keeps identity consistent.
- The final beat of the chain lands the outcome. The first beat of the next chain re-establishes location and characters before moving on.
- Keep a running shot list: shot number, mode (T2V/I2V/reference), references used, status. Review it before assembly so no beat is missing and no bridge is unexplained.

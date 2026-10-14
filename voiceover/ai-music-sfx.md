# AI-Generated Music and Sound Effects

(credit: Meta AudioCraft, 23.7k stars; MusicGen and AudioGen)

This doc covers text-prompted music and SFX generation as the premium audio tier in CineForge productions. The procedural drone bed stays the default for recap episodes (cheap, consistent, zero copyright risk); AI-generated music and SFX are the upgrade path when a project deserves more.

## What changes and what does not

The existing post chain (compressor, room echo, loudnorm) and the narrator voice direction do not change. AI music replaces the drone bed as the musical layer; AI SFX sit on top as a separate effects layer. Voice always stays on top of both, untouched by the music mix.

## Prompting music: direction, not description

Treat the music model like a composer with a brief. Write the prompt with these four elements:

1. Mood: dark, triumphant, mournful, tense, serene. Pick one primary mood per cue.
2. Tempo and energy: slow drone, driving pulse, swelling crescendo. Anchor it to what happens in the scene.
3. Instruments: name them. Guzheng and strings for an Eastern fantasy cue, low brass and percussion for a battle cue, piano and solo cello for a quiet character moment.
4. Era or style frame: "wuxia film score," "modern trailer," "ambient dark fantasy." This keeps the model from drifting between genres mid-track.

Example direction style: "Tense wuxia film cue, slow build, low strings and distant war drums, minor key, 90 seconds, no melody, pure tension."

## Workflow: iterate short, commit long

- Generate short loops (15 to 30 seconds) first to audition the mood. Iterate the prompt until the feel is right.
- Only then generate the full-length cue. Long generations on an unvalidated prompt waste time.
- Crossfade loops into full cues; do not hard-cut between different generations unless the scene itself cuts.
- Keep the bed low. The recap-episode lesson holds here too: music is a barely-there presence under narration, never a competitor with it. Raise it only in action montages where narration pauses.

## SFX generation for action scenes

- Whooshes: prompt with motion ("fast sword swing whoosh," "heavy object flying past").
- Impacts: prompt with weight and material ("wooden staff hitting stone," "energy blast detonation, no reverb tail").
- Ambience: one layer per environment (crowd murmur, rain on leaves, wind across a battlefield). Keep each loopable and low.
- Place SFX on their own tracks, panned and leveled per scene. Never bake SFX into the music cue.
- When a generated effect misses (wrong texture, audible artifacts), fall back to a shorter, simpler prompt before abandoning generation. Simpler prompts usually land better.

## When the procedural bed is still the right choice

- Recap episodes on a deadline: the drone bed is minutes of compute, fully predictable, and already tuned to the narration chain.
- Any project where consistency across 10+ episodes matters more than novelty.
- Any case where the licensing of a music model's weights is unclear. The procedural bed is 100 percent original code output, zero copyright-claim risk.

## Licensing note

Before using any AI music or SFX in a commercial release, verify the license of the model weights you generated with. Some weights permit commercial use, some do not, and the answer can change with the model version. Check it per model, per release, and note the license in the production log.

## Rule of thumb

Procedural bed is the default. AI music and SFX are the premium tier: better sounding, more work, and only shipped after the license check passes.

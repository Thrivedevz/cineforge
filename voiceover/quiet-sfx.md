# Quiet Scene Linked SFX

A sound method for narration led films: the story performs an action, and the
listener hears that action, naturally, at the moment it happens. Built from
production testing on the Nightmare Nexus horror channel, where two louder
approaches were rejected by the channel owner before this one was approved
and locked.

## The standard

Natural, subtle, sparse. Sounds a viewer barely notices are doing the work.
A long narration video is usually heard on headphones, often at night, so
viewer comfort outranks dramatic impact. If an effect calls attention to
itself, it is wrong.

## Rules

1. Real recordings only. Licensed library recordings (free first: Mixkit,
   Pixabay, Freesound CC0), with the license recorded per file. No movie
   clips, no rips, no extracted demo audio from other tools.
2. Synthesized imitations fail. A tone shaped like a knock does not sound
   like a knock, and listeners know instantly. Do not synthesize effects
   that imitate real world sounds.
3. One effect per real action. A door closes, a knock lands, footsteps cross
   a stated surface. If the scene performs no action with a natural sound,
   it gets no effect.
4. Effects live in narration pauses, not under the voice. The narrator says
   someone knocked three times; then, in the pause, the listener hears the
   three knocks. Overlap buries both.
5. Natural volume. Mix effects well below narration peaks. Reference levels
   from the approved production proof: a soft door close peaking near
   -16 dBFS, knocks near -13 dBFS, room tone near -46 dB mean, in a mix
   whose overall peak is about -1.5 dBFS with no clipping.
6. Silence is the scare tool. Before a reveal or a whisper, drop to room
   tone only for a beat (about 1.4 seconds or more). Never a sting,
   heartbeat, or riser.
7. Verify the recording, not the listing. Count the knocks in the waveform.
   A clip sold as one thing can contain four knocks, a slam, or a hidden
   music tail. Edit a real recording if needed (for example cutting a
   fourth knock), disclose the edit, and never repeat a short clip to fake
   a count.
8. One kit per channel. The same door, the same knocks, the same room tone,
   reused at the same gains, so listeners learn the channel's sound. New
   sounds join the kit only after the owner approves a sample using them.

## Workflow

1. At script stage, mark every story action that has a natural sound.
2. Build the cue sheet (see prompts/templates/direction-sheet-template.md):
   pause point, action, sound, source file, license, gain, peak target.
3. Source or pull each sound from the channel kit. Verify by waveform.
4. Synthesize narration sentence by sentence (or in timed sections) so
   pause points are known to the sample.
5. Mix: narration post chain first, then place effects in the pauses at
   cue sheet gains, room tone underneath everything at a barely audible
   level, gentle fades at the joins.
6. QC by measurement and by listening: check the level of each effect
   window against its peak target, check the silence windows are really
   quiet, and listen once on headphones at normal volume. If any effect
   makes you flinch or notice the edit, lower it or cut it.

## Locked preset: Nightmare Nexus

- Kit: nightmare-nexus/sfx-quiet-kit/ in the channel workspace (door close,
  three muffled knocks, bedroom room tone, with sources and licenses).
- Gains: room tone lowpass 800 Hz at 0.10; soft door close at 0.12; knocks
  lowpass 1600 Hz at 0.18.
- Banned: stings, heartbeats, risers, wind overload, synth effects, any
  effect under the voice.
- Proof file approved by the owner: nn-quiet-audio-test-20261029.mp3.

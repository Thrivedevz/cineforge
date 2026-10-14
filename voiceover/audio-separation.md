# Audio Separation

Vocal and background music separation: splitting a mixed audio track into
individual stems (dialogue, music, effects) so each element can be processed
and rebalanced independently. Technique inspired by
Anjok07/ultimatevocalremovergui (26.4k stars), described here in our own
words and adapted to the CineForge voiceover pipeline.

## What separation does

A mixed track locks dialogue and score together at fixed relative levels.
Separation (also called demixing or stem extraction) reverses that: an AI
model trained on mixed music and speech splits the track back into separate
stems, typically one for dialogue or vocals and one for everything else
(music, ambience, effects).

With stems in hand you can:

- Isolate dialogue from a mixed track for clean processing.
- Control the music bed precisely: raise, lower, duck, or replace the score
  without touching the voice.
- Fix balance problems (score drowning speech, effects masking consonants)
  that no amount of EQ on the full mix can solve.

## Primary use case: the photorealistic fantasy film channel

This is where separation earns its place. The film channel (multi-voice
performances, layered sound design, scored scenes) regularly works with audio
that arrives already mixed: dialogue baked over a score, room tone and
effects baked into the same track.

Separation lets you:

1. Pull the dialogue stem out of the mixed track.
2. Clean it up on its own (denoise, compression, the audio-post chain) with
   no risk of the score triggering the compressor or the reverb.
3. Rebalance the score stem against the cleaned dialogue: duck the music
   under speech, lift it in transitions, or replace it with the procedural
   bed when the original score cannot be licensed.
4. Re-mix and verify loudness targets as usual.

## Note: less needed for the recap channel

The recap channel does not need this step. Its voiceover chain already works
from clean stems: the narration is synthesized dry, the music bed is
generated procedurally, and the two are mixed together only at the end,
with the bed at the locked barely-there level. There is no mixed track to
un-mix, so separation would add processing with nothing to separate.

Only reach for separation on the recap channel if you ever receive
third-party audio that arrives pre-mixed (an interview clip, a licensed
soundbite). For the channel's own narration, it is unnecessary.

## Practical workflow

Run this workflow on any mixed track before it enters the normal post chain.

### Step 1: Separate the mixed track into stems

Feed the mixed file to the separation tool and request dialogue/vocal and
accompaniment (music plus effects) stems. Use the highest-quality model the
tool offers; the dialogue stem is the one you will keep, so it deserves the
best the tool can do. Keep the original mixed file untouched as a backup.

### Step 2: Process the dialogue stem

Treat the dialogue stem exactly like a raw voiceover track: run it through
the audio-post chain (compression, subtle room, loudness normalization).
Because the score is no longer in the track, the compressor reacts only to
the voice and the loudness measurement reflects speech alone, which makes
both steps more accurate.

Check the dialogue stem for separation artifacts before processing:
metallic or watery artifacts on sibilants, chopped word endings, or thin
sections where the model ate part of the voice. If artifacts are audible,
try a different model or a different separation pass; do not try to EQ away
missing audio.

### Step 3: Re-mix with the bed at the locked low level

Mix the processed dialogue stem back with the music at the locked level
from the music-bed doc: a barely-there presence under the narration, never
competing with it. If you kept the original score stem, lower it to the same
low level or duck it under speech; if the score is being replaced, use the
procedural bed instead and drop the original score stem entirely.

### Step 4: Re-run loudness verification

Separation and re-mixing change the loudness profile, so verify again on the
final mix: integrated loudness around -16 LUFS, true peak at or below
-1.5 dBTP. Do not trust the loudness numbers from the original mix; they
measured a different track.

## Caveats

- Separation is lossy. A clean stem is always better than a separated one,
  which is why the recap channel's synth-first workflow stays as it is.
- Process at 48 kHz throughout so stems and beds share the same sample rate
  and no resampling artifacts creep into the re-mix.
- Separation quality varies by source. Dense, heavily compressed mixes
  separate worse than clean ones; budget extra time to audition the dialogue
  stem on difficult material.
- When the separation tool offers multiple models, audition two or three on
  a 30-second excerpt and pick the one with the fewest artifacts on speech,
  not the one that sounds best on music. The dialogue stem is the deliverable.

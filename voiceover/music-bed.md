# Music Bed

The background music under every narration is 100% original and synthesized from scratch. This is the only way to guarantee zero copyright-claim risk.

## The recipe

A dark ambient drone in A minor, built as a stack of sine tones:

- Frequencies: 55 Hz, 110 Hz, 130.81 Hz, 164.81 Hz, 220 Hz (A1, A2, C3, E3, A3).
- Tremolo: slow amplitude modulation applied to the stack for a breathing, uneasy movement.
- Lowpass filter at 800 Hz: removes high-frequency harshness and keeps the drone dark.
- Multi-tap echo: layered short delays to add space and depth without turning it into a rhythm.

## Synthesis approach (ffmpeg)

Generate the bed with ffmpeg from sine sources, for example:

```
ffmpeg -f lavfi -i "sine=frequency=55:duration=<LEN>" \
       -f lavfi -i "sine=frequency=110:duration=<LEN>" \
       -f lavfi -i "sine=frequency=130.81:duration=<LEN>" \
       -f lavfi -i "sine=frequency=164.81:duration=<LEN>" \
       -f lavfi -i "sine=frequency=220:duration=<LEN>" \
       -filter_complex "amix=inputs=5,tremolo=f=0.5:d=0.5,lowpass=f=800,aecho=0.8:0.7:60|90|150:0.4|0.3|0.25" \
       bed-raw.wav
```

Adapt the tremolo rate, echo taps, and bed length to the episode's duration. The exact values above are a starting point; keep the character dark and slow.

## The "really low" mixing rule

Mix the bed REALLY low under the voice. It should be a barely-there background presence that supports mood, never a second thing to listen to. If a listener notices the music during narration, it is too loud. Duck it further if the voice ever competes with the drone.

## 7-second fade-out

Fade the bed out over the last 7 seconds of the episode (or its last scene) so it resolves cleanly instead of cutting off.

```
afade=t=out:st=<START>:d=7
```

## Why original-only

Fully synthesized audio cannot be claimed by any rights holder, so there is zero copyright-claim risk on YouTube or any other platform. This holds only if every element of the bed is generated from these raw tones.

## What never to do

- NEVER use stock music, sample packs, or any track of unknown license, no matter how convenient.
- NEVER layer library loops or loops "for commercial use" over the narration; their licenses can change or be disputed.
- NEVER let the bed volume creep up in mixing. When in doubt, turn it down.

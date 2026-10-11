# Audio Post

The exact ffmpeg filter chain applied to every finished voiceover track. Run the filters in this order.

## The chain

```
acompressor=threshold=-20dB:ratio=3:attack=15:release=200:makeup=3dB
aecho=0.8:0.6:25|40:0.18|0.12
loudnorm=I=-16:TP=-1.5:LRA=11
```

Example full command:

```
ffmpeg -i voiceover-raw.wav -af \
"acompressor=threshold=-20dB:ratio=3:attack=15:release=200:makeup=3dB,\
aecho=0.8:0.6:25|40:0.18|0.12,\
loudnorm=I=-16:TP=-1.5:LRA=11" \
voiceover-final.wav
```

## What each filter does and why

### 1. acompressor (compression)

- `threshold=-20dB`: compression starts on anything louder than -20 dB, which catches peaks while leaving quiet narration alone.
- `ratio=3`: reduces peaks above the threshold by a 3 to 1 ratio, taming loud moments without flattening the performance.
- `attack=15`: 15 ms attack catches transients fast enough to control pops and loud starts.
- `release=200`: 200 ms release lets the gain recover smoothly so there is no audible pumping.
- `makeup=3dB`: 3 dB of makeup gain brings the tamed signal back up to a healthy level.

Why: narration recorded or synthesized dry has wide dynamic range; compression keeps it even on phone and laptop speakers.

### 2. aecho (subtle room)

- `in_gain=0.8`, `out_gain=0.6`: keeps the echo level conservative relative to the dry signal.
- Delays of 25 and 40 ms with decays of 0.18 and 0.12: very short, quiet reflections that simulate a small treated room.

Why: dry TTS sounds flat and synthetic. A subtle room adds presence and warmth without sounding like a cave.

### 3. loudnorm (loudness normalization)

- `I=-16`: integrated loudness target of -16 LUFS.
- `TP=-1.5`: true peak ceiling of -1.5 dBTP, leaving headroom so encoding does not clip.
- `LRA=11`: loudness range of 11 LU, allowing natural dynamic contrast in narration.

Why: -16 LUFS is the standard target for video and podcast platforms; hitting it means consistent volume across episodes and against other content.

## Loudness targets explained

- Integrated loudness (I=-16): the average loudness across the whole file should read -16 LUFS.
- True peak (TP=-1.5): no sample may exceed -1.5 dBTP; this guarantees headroom for AAC/MP3 encoding.
- Loudness range (LRA=11): the difference between quiet and loud passages may span up to 11 loudness units; wider would feel uncontrolled, narrower would feel lifeless.

## Verification

Run ffmpeg's ebur128 filter or a two-pass loudnorm stats pass on the final file and confirm:

- Integrated loudness reads approximately -16 LUFS.
- True peak reads at or below -1.5 dBTP.
- Loudness range reads within roughly 9 to 12 LU.

Example measurement command:

```
ffmpeg -i voiceover-final.wav -af "ebur128=peak=true:framelog=quiet" -f null -
```

If the measured values miss the targets, adjust the loudnorm parameters or re-run with dual-pass mode, and measure again. Do not ship audio that misses true peak: clipping from encoding is audible and unfixable after the fact.

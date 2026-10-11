# Assembly

Assembly turns finished assets (voiceover, music bed, generated shots, captions) into one deliverable episode file.

## Pipeline order

1. **Voiceover and music bed mix.** Voiceover at full level. Music bed is 100% original (no licensed tracks, no copyright-claim risk) and mixed really low underneath the voice: a barely-there background presence, never distracting from narration. Fade the bed out over the last few seconds.
2. **Caption burn-in from ASS.** Captions are animated word-by-word style (AutoSubs-like): each word highlights as spoken. Not plain static subtitles. The ASS file is timed to the voiceover track, then burned into the video.
3. **Encode.** Codec: h264 video + aac audio. Video bitrate capped at approximately 5 to 6 Mbps. This cap is enforced here, before final assembly, not retrofitted afterward.
4. **Single MP4 out.** Exactly one whole-episode MP4 file. Never split parts.
5. **Fresh filename per version.** Every version gets a new filename (v1, v2, and so on). Players cache by filename; a reused path replays the cached old file.

## Why the size cap exists

Files around 1GB and larger choke consumer players: playback failures, frozen frames, files that verify as intact but will not open. The ~5-6 Mbps encode cap keeps episodes well under a gigabyte at typical episode lengths (15 to 23 minutes). If a file approaches ~900MB, re-encode lighter before shipping. Never ship a file at or above 1GB.

## Episode format targets

- Length: 15 to 23 minutes for recap episodes.
- Narration density: roughly 45 to 55 words per scene. Thin scripts (a few minutes of narration over a long timeline) are caught and expanded before assembly, never shipped.
- 3 chapters per episode for standard pacing, 4 for longer episodes. Scale scenes and word counts proportionally.
- No hallucination: every event, name, technique, and outcome stays exactly as the source has it. Value-add lives only in presentation (pacing, tension, vivid retelling, cinematic narration), never in invented material.

## Short channel bumpers

Every episode opens and closes with a short subscribe + like prompt: a few seconds of spoken narrator line at each end. No text overlay. Kept brief.

## Delivery

One whole-episode MP4 to its destination, filename named exactly, with a prompt to reload the view if the destination caches listings. No split parts, no chat attachments, direct links only when requested.

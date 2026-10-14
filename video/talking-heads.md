# Talking-Head Generation Direction

(credit: OpenTalker/SadTalker, 14.1k stars; portrait plus audio in, talking video out)

This doc covers talking-head generation: feeding a portrait and an audio clip into a model that animates the face to speak. It is a niche tool in the CineForge pipeline, useful in specific spots, dangerous as a default.

## When talking heads fit

- Dialogue-heavy scenes where a character speaks directly and the camera would naturally hold on their face.
- Presenter or narrator-to-camera shots (recap cold opens, film channel host segments).
- Reaction shots where the face carries the scene and full-body animation would add nothing.

## When they do not fit

- Action scenes. A talking head is a face; it cannot fight, run, or cast a technique.
- Long monologues. Drift accumulates and the face stops looking like the character.
- Any scene where the body language matters more than the words.

## Input requirements

- The portrait must be clean and front-facing: face centered, eyes open, neutral expression, good lighting. This is a hard requirement; a bad portrait produces a bad head, every time.
- The portrait must use the locked character design for that character (same discipline as every other visual: one locked design, reused consistently).
- The audio must be the final, mixed dialogue or narration line for that exact shot. Generate the voice first, then the head, never the reverse.
- Resolution: generate at the model's native resolution and upscale afterward if needed. Do not feed it a downscaled or cropped portrait and expect detail.

## Pairing with multi-voice audio

- Each talking head is generated against one locked character voice from the multi-voice production log (see `voiceover/multi-voice.md`). The voice in the audio and the face in the portrait must belong to the same character.
- Keep one head per speaker per scene. If two characters talk, generate two heads and cut between them; do not try to make one head deliver both sides of a conversation.
- Sync check every head before assembly: watch it once at full speed with the audio. If the lip timing is visibly off or the face warps, regenerate with a cleaner portrait before falling back.

## Limitations

- Stylized vs photorealistic quality: results vary by model and by how well the portrait matches the model's training. Anime-styled faces and photorealistic faces need different models; using the wrong one produces uncanny results.
- Long takes drift: faces lose consistency past roughly 20 to 30 seconds. Split long dialogue into shorter takes with cuts between them.
- Hands and background are not this tool's job. Frame heads as head-and-shoulders or close-ups; anything wider should be a standard generated scene.

## Fallback

When talking-head quality is insufficient after two regeneration attempts, direct the scene as a standard generated scene instead. A well-directed generated scene always beats a broken talking head. The fallback is the rule, not the exception, for action-adjacent dialogue and for stylized characters the talking-head models handle poorly.

## Rule of thumb

Talking heads are a scalpel: dialogue close-ups and presenter shots only, clean portrait in, final audio in, short takes, and fall back to standard scenes the moment quality dips.

# Multi-Character Voice Direction with Voice Cloning

(credit: resemble-ai/chatterbox, 26.6k stars; zero-shot voice cloning, multilingual)

This doc covers dialogue scenes where more than one character speaks: the primary use case is the photorealistic fantasy film channel, but the same discipline applies anywhere a script has real dialogue instead of a single narrator.

## The core lock: one voice per character

This is the same lock discipline as character designs. Once a character's voice is cast, it never changes across episodes, and it never changes between the original and a dubbed version (matched by casting, not randomized). A locked voice is recorded in the production log with the character's name, the reference used, and the date it was locked.

## Voice casting direction

Cast like a director, not a technician. For each role, decide:

- Age: child, young adult, middle-aged, elder. The voice must read as the character's apparent age.
- Timbre: warm, cold, rough, smooth, thin, deep. Pick two adjectives and hold them.
- Energy: calm authority, restless youth, quiet menace, warm humor. This is the performance baseline the clone must deliver.

Write the casting brief in one line per character before generating anything. Example: "Elder mentor, 60s, rough and low, calm authority that sharpens under pressure."

## Cloning from short reference clips

- Use a clean reference clip: single speaker, no music, no overlapping dialogue, 10 to 30 seconds of natural speech.
- The clip sets the voice's identity. The performance comes from the script direction, not from the clip.
- Lock the voice from the first successful generation and reuse it for every line that character speaks afterward. Do not re-clone per scene.
- Keep the reference clip and the locked voice settings together in the production log, so a future episode can reuse the exact same voice.

## Performance direction per character

- Each character gets directed individually. The narrator's cinematic pacing (ellipses, hammer-blow sentences) does not apply to dialogue; people talk like people.
- Direct emotional beats per line: who is angry, who is afraid, who is hiding something. Mark these in the script before generation.
- Do not let every character sound like the narrator. If two characters are hard to tell apart, the casting was wrong, and one of them needs a different voice.

## Dialogue mixing

- Level-match every character so no one is buried and no one shouts over the scene. Target the same loudness for all dialogue lines.
- Keep dialogue clear of the music and SFX beds: duck effects under speech, never the reverse.
- Pan slightly per speaker when two characters share a scene, just enough to give them space.
- Run the full post chain (compressor, room echo, loudnorm) on the dialogue bus the same way as narration, so dialogue and narration in one episode sound like they belong to the same production.

## Consistency across episodes

- New episode, same locked voices. Load the voice locks from the production log before generating a single line.
- If a locked voice is unavailable (model changed, reference lost), recast deliberately and document the change. Never silently substitute a different voice for an established character.
- Spot-check two or three lines from the previous episode against the new one when a character returns after a gap.

## Rule of thumb

Cast once, lock forever, direct every line, and mix so every character is heard. The audience should know who is speaking with their eyes closed.

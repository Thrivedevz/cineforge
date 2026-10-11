# Voiceover Block Template

One block per voice in the project. The voiceover block is the contract between the script and the TTS session: cast the voices, notate the performance, substitute the phonetics, strip the labels, then synthesize.

---

## Voice Cast

**[CHARACTER NAME]:** voice id `[VOICE ID]`, [pitch and pace direction, e.g. low female, unhurried].

**[CHARACTER NAME]:** voice id `[VOICE ID]`, [pitch and pace direction].

**NARRATOR:** voice id `[VOICE ID]`, [pitch and pace direction].

## Performance Notation Legend

Write the script with these marks. The TTS session reads them literally.

- `...` Ellipsis: a suspense pause, one beat. Use for tension before a reveal, never mid-word.
- Short sentences. Hammer-blow sentences: single impacts, one per line. Use for strikes, deaths, turning points.
- Slow burn: write the lead-up in longer, quieter lines that gather weight before the reveal.
- Rising finish: the last line of a scene climbs in energy and lands hard. Never trail off.
- `[beat]` One silent beat inside dialogue. Use sparingly: one per scene at most.
- `(direction)` Parenthetical delivery notes are stripped before synthesis and never spoken.

## Spoken-Form Numbers Rule

Write every number and time in spoken form. The voice must never read digits.

- `3` becomes `three`, `47` becomes `forty-seven`, `2:00 AM` becomes `two in the morning`.
- Years: `2026` becomes `twenty twenty-six`.
- Measurements: `6 feet` becomes `six feet`, `5 Mbps` becomes `five megabits per second`.

## Phonetic Substitution Reminder

Before synthesis, substitute phonetic spellings for every proper name using the project's pronunciation table. Write the script with proper names, then run the substitution pass, then synthesize. Never synthesize unsubstituted names and hope the TTS guesses right.

Example: `Xiao Yan` becomes `Shyaow Yen` (per the project's phonetic table).

## Label-Strip Reminder

Speaker labels must NEVER be spoken. Before synthesis, strip every label (`NARRATOR:`, `MARA:`, scene headings, direction lines in brackets) or map them through the TTS tool's speaker-mapping so the label is consumed, not read aloud. Run the label-strip check on every script, every time, before synthesis. A shipped line that starts with the word "narrator" is a failed session.

---

## Filled Example (short)

**NARRATOR:** voice id `studio:CALM_02`, mid male, steady, unhurried.

Script excerpt (pre-substitution):

```
NARRATOR: The tide took the harbor in a single night... and it did not give it back.
```

Substituted and label-stripped for synthesis:

```
The tide took the harbor in a single night... and it did not give it back.
```

Voice id `studio:CALM_02`. Numbers already in spoken form. No labels remain.

# Phonetics Guide

TTS engines pronounce written English by default. Fantasy names are not written English, so the engine will butcher them unless you tell it how they sound. This guide sets the workflow.

## Why it matters

A mispronounced lead character name breaks immersion on every single line. Phonetics are not optional polish; they are a first-pass correctness step. Every project keeps one authoritative substitution table, agreed once, used everywhere, updated only by project decision.

## Building a project substitution table

1. List every proper name that appears in the script: characters, places, techniques, artifacts, titles.
2. For each name, write the phonetic spelling as it should SOUND when read aloud by the voice.
3. Review the table against your source material's known pronunciations (author notes, official media, fan references). Do not guess; if unsure, research first.
4. Apply the substitutions to the script text BEFORE synthesis. The engine should only ever see the phonetic form.
5. Keep the table in the project folder (one file per project) and reuse it across episodes for consistency.

## Worked examples

Source name -> phonetic form used in the script:

- Xiao Yan -> "Shyaow Yen"
- Yao Lao -> "Yaow Laow"
- Cai Lin -> "Tsye Leen"

Same principle applies to any fantasy name in any project: agree the phonetic spelling once, use it everywhere.

## Blank table template

Copy this into your project and fill it in:

```
Source name | Phonetic spelling | Notes
------------|-------------------|------
            |                   |
            |                   |
            |                   |
```

## QA method

Before synthesizing the full script, synthesize the name list alone:

1. Create a test script containing every phonetic name in a few natural sentences.
2. Run `tts synthesize-script` on the test script.
3. Listen to the full output, carefully, at normal speed.
4. Fix any name that still sounds wrong by adjusting its phonetic spelling.
5. Only when every name sounds right, proceed to the full script synthesis.

Names drift over episodes. Re-run the name-list test at the start of each new production block and whenever a new named character or artifact appears.

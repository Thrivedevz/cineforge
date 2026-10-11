# Character Design System

## The rule

Characters must match their official designs. Before production on any episode, web-check every new character's appearance AND pronunciation. Never guess either one.

## The design library

One directory per production, structured like this:

```
character-design-library/
  INDEX.md                    # master register: every design, its status, its file
  xiao-yan.jpg                # per-character reference files
  yee-tianchen.jpg
  effects/
    heavenly-flame.jpg        # locked effect designs
  weapons/
    profound-heavy-ruler.jpg  # locked weapon designs
```

The INDEX.md registers each design with: character name, source of the design (official adaptation name and season, or "original: locked at first appearance"), the file path, pronunciation, and the date it was locked.

## The web-check rule

- For every character appearing in an episode, search official sources (the anime adaptation, official art books, studio releases) before writing any prompt that includes them.
- Check two things: what they look like, and how their name is pronounced.
- Save the reference image into the library and register it in INDEX.md before generation starts.
- If a search turns up nothing credible, the design is treated as original (see below), and that verdict is recorded in the INDEX.

## The one-locked-design rule (original characters)

Fanfic-original characters with no official design get ONE locked original design at first appearance. One design, created once, then reused consistently across the whole series.

- The locked design is described once, saved as a reference image, and registered in the INDEX with "original" status.
- Every later prompt uses the reference image with identity-anchor matching. Never re-describe the character from scratch in a later episode: re-describing drifts, matching holds.
- Corrections happen to the locked design, not around it. If the design needs a fix, update the reference image and the INDEX entry, then all later shots use the corrected version.

## Effects, weapons, and signature items

Effects fall under the same rule as characters. Flames, energy forms, weapons, and signature items each get ONE locked design and stay consistent series-wide.

- Pattern: a signature weapon is locked to one authoritative reference image (an official still, a key visual, a verified fan-art source the production approves). That image is registered in the INDEX and used as the identity anchor wherever the item appears.
- Element effects (fire, lightning, spiritual energy) get a locked visual baseline the same way: one reference image, registered, reused.
- When an effect changes form in the story (a flame evolves, a weapon is reforged), that is a new locked design: new reference image, new INDEX entry, and a production note on which episodes use which version.

## How references feed the video model

1. Pass the reference image(s) with the prompt, with one explicit role each: identity anchor, style anchor, or motion anchor (`video/generation-workflows.md`).
2. Use @image-style referencing: instruct the model to match the reference rather than re-describing the subject.
3. For multi-character shots, pass one identity anchor per character and name which anchor belongs to which character in the prompt.
4. Keep the reference files at high resolution. Low-res anchors produce low-res faces.

## Pronunciation

Phonetic pronunciations are locked alongside the design and recorded in the INDEX. Scripts are written with proper names, then phonetic spellings are substituted before TTS synthesis. Never synthesize a name that has not been web-checked or locked.

# Description Template

Placeholders are wrapped in braces. The packager fills them from episode data.
This is original boilerplate; write a fresh {HOOK} per episode, never a copy.

```
{HOOK}

SUBSCRIBE_LINE

Chapters:
{CHAPTERS}

{CHANNEL_BLURB}

SPOILER_NOTE

{HASHTAGS}
```

## Placeholder reference

- `{HOOK}` — two to three sentences on what happens in this episode. No spoilers beyond the episode itself. Written fresh every time.
- `{SUBSCRIBE_LINE}` — e.g. "New episodes every week. Subscribe to {CHANNEL_NAME} so you never miss the next one!"
- `{CHAPTERS}` — one `m:ss — label` line per chapter, generated from scene timings. First line is always `00:00`.
- `{CHANNEL_BLURB}` — e.g. "New cinematic recaps every week on {CHANNEL_NAME}, covering the greatest cultivation stories in English. Every episode is an original production: written, voiced, and animated for this channel."
- `{SPOILER_NOTE}` — e.g. "Spoilers for {SERIES_NAME}."
- `{HASHTAGS}` — up to three hashtags, space-separated, from the top keywords.

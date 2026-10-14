# YouTube Packaging

The packaging layer turns a finished episode plus its production data into an upload-ready YouTube package. It prepares everything. It never uploads or publishes anything; the creator does the upload by hand.

## What the package is

One folder per episode containing:

- `title.txt` — the video title, built from the channel's title formula.
- `description.txt` — the full description: hook line, chapter timestamps, subscribe call to action, channel blurb, spoiler note, hashtags.
- `tags.txt` — comma-separated tags, deduplicated.
- `thumbnail.png` — 1280x720 composite: episode number in gold at top-right, series name in gold along the bottom, over a frame pulled from the finished video.
- `upload-checklist.md` — the pre-upload policy checklist: the promise check, chapter accuracy, playlist, visibility, end screen, cards, pinned comment.

## Inputs

- The finished, QC-passed MP4.
- Scene data with timings (start seconds + label per scene), from the production pipeline.
- Episode metadata: episode number, episode title, series name, channel name, keywords.

## Outputs

The five files above, written to the package directory. Nothing leaves the machine.

## SEO principles

- Titles carry the series name, episode number, episode title, and the channel brand, with the highest-value keywords up front.
- Chapter labels use search terms, because chapters feed Google's key moments as well as YouTube navigation. A chapter titled "The Sky Spill Fist" earns search traffic; a chapter titled "Part 6" earns nothing.
- Tags combine episode keywords, series terms, and channel terms, deduplicated.
- Hashtags stay tight: the first three in the description are the ones YouTube surfaces above the title.

## Policy-first principle

The rules live in `policy-rules.yaml`, kept current, never hard-coded in the script. The packager reads that file and enforces the chapter rules on every run, failing loudly on violation. When YouTube changes a rule, one file gets updated and every future package follows it.

## Where it sits in the pipeline

Packaging is the last step of Stage 9, after QC passes. Nothing gets packaged that has not passed QC. See `scripts/package_youtube.py`.

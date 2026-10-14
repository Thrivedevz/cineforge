#!/usr/bin/env python3
"""CineForge YouTube packager.

Builds an upload-ready YouTube package from a finished episode + production
data: title, description (with policy-validated chapters), tags, thumbnail,
and an upload checklist. It prepares everything and uploads nothing.

Usage:
  package_youtube.py --episode-num 13 --episode-title "The Deadly Hunt" \\
      --series-name "Flame Ascension" --channel "Cultivation Chronicles" \\
      --scenes scenes.tsv --keywords "Flame Ascension,BTTH,Xiao Yi" \\
      --video episode.mp4 --out ./package-13 [--dry-run]

scenes.tsv: one chapter per line:  start_seconds<TAB>label
Policy rules are read from packaging/policy-rules.yaml and enforced.
"""
import argparse
import os
import re
import shutil
import subprocess
import sys

import yaml

HERE = os.path.dirname(os.path.abspath(__file__))
PACKAGING_DIR = os.path.join(HERE, "..", "packaging")
GOLD = "#D4AF37"
FONT_CANDIDATES = [
    "/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
]


def fail(msg):
    print(f"package_youtube: ERROR: {msg}", file=sys.stderr)
    sys.exit(1)


def load_policy(path):
    try:
        with open(path, "r", encoding="utf-8") as fh:
            return yaml.safe_load(fh)
    except FileNotFoundError:
        fail(f"policy file not found: {path}")
    except Exception as exc:  # noqa: BLE001 - surface any parse problem
        fail(f"could not parse policy file {path}: {exc}")


def read_scenes(path):
    scenes = []
    with open(path, "r", encoding="utf-8") as fh:
        for lineno, line in enumerate(fh, 1):
            line = line.rstrip("\n")
            if not line.strip():
                continue
            parts = line.split("\t")
            if len(parts) != 2:
                fail(f"{path}:{lineno}: expected 'start_seconds<TAB>label', got: {line!r}")
            try:
                start = float(parts[0].strip())
            except ValueError:
                fail(f"{path}:{lineno}: bad start time: {parts[0]!r}")
            label = parts[1].strip()
            if not label:
                fail(f"{path}:{lineno}: empty chapter label")
            scenes.append((start, label))
    if not scenes:
        fail(f"{path}: no chapters found")
    return scenes


def validate_chapters(scenes, policy, video_duration):
    rules = policy["chapters"]
    problems = []
    if len(scenes) < rules["min_chapters"]:
        problems.append(
            f"only {len(scenes)} chapters, policy requires at least {rules['min_chapters']}"
        )
    if abs(scenes[0][0]) > 0.001:
        problems.append(
            f"first chapter starts at {scenes[0][0]:.1f}s, policy requires {rules['first_timestamp']}"
        )
    for i in range(1, len(scenes)):
        if scenes[i][0] <= scenes[i - 1][0]:
            problems.append(
                f"chapter {i + 1} ({scenes[i][0]:.1f}s) is not after chapter {i} "
                f"({scenes[i - 1][0]:.1f}s); timestamps must ascend"
            )
    ends = [s[0] for s in scenes[1:]]
    if video_duration is not None:
        ends.append(video_duration)
    for i, (start, label) in enumerate(scenes):
        if i < len(ends):
            dur = ends[i] - start
            if dur < rules["min_chapter_seconds"]:
                problems.append(
                    f'chapter "{label}" is {dur:.1f}s, policy requires at least '
                    f"{rules['min_chapter_seconds']}s"
                )
        elif video_duration is None:
            print(
                f"package_youtube: WARNING: cannot check length of final chapter "
                f'"{label}" (no --video given for duration)',
                file=sys.stderr,
            )
    if problems:
        for p in problems:
            print(f"package_youtube: POLICY VIOLATION: {p}", file=sys.stderr)
        sys.exit(2)
    print(f"package_youtube: chapters OK ({len(scenes)} chapters, policy rules pass)")


def fmt_ts(seconds):
    seconds = int(round(seconds))
    if seconds <= 0:
        return "00:00"
    m, s = divmod(seconds, 60)
    return f"{m}:{s:02d}"


def hashtagify(keyword):
    tag = re.sub(r"[^0-9a-zA-Z ]", "", keyword).strip()
    tag = "".join(w[:1].upper() + w[1:] for w in tag.split())
    return f"#{tag}" if tag else ""


def drawtext_escape(text):
    return (
        text.replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace(":", "\\:")
        .replace("%", "\\%")
    )


def pick_font():
    for path in FONT_CANDIDATES:
        if os.path.exists(path):
            return path
    fail("no usable font found (looked for Noto Sans Bold / DejaVu Sans Bold)")


def probe_duration(video):
    out = subprocess.run(
        ["ffprobe", "-v", "error", "-show_entries", "format=duration",
         "-of", "csv=p=0", video],
        capture_output=True, text=True,
    )
    if out.returncode != 0 or not out.stdout.strip():
        fail(f"could not probe duration of {video}")
    return float(out.stdout.strip())


def build_thumbnail(video, episode_num, series_name, out_path, thumb_at=None):
    font = pick_font()
    duration = probe_duration(video)
    seek = thumb_at if thumb_at is not None else duration * 0.25
    if seek < 0 or seek >= duration:
        fail(f"--thumb-at {seek:.1f}s is outside the video (0-{duration:.1f}s)")
    num = drawtext_escape(str(episode_num))
    series = drawtext_escape(series_name.upper())
    vf = (
        "scale=1280:720,"
        f"drawtext=fontfile={font}:text='{num}':fontsize=120:fontcolor={GOLD}:"
        "borderw=3:bordercolor=black:x=w-text_w-60:y=60,"
        # subtle dark band behind the series name keeps it legible over
        # burned-in captions or busy backgrounds
        "drawbox=y=ih-150:w=iw:h=150:color=black@0.4:t=fill,"
        f"drawtext=fontfile={font}:text='{series}':fontsize=64:fontcolor={GOLD}:"
        "borderw=2:bordercolor=black:x=(w-text_w)/2:y=h-text_h-70"
    )
    cmd = ["ffmpeg", "-v", "error", "-y", "-ss", f"{seek:.1f}", "-i", video,
           "-frames:v", "1", "-vf", vf, out_path]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        fail(f"thumbnail build failed: {result.stderr.strip()[:300]}")
    print(f"package_youtube: thumbnail -> {out_path}")


def main():
    ap = argparse.ArgumentParser(description="Build a YouTube upload package.")
    ap.add_argument("--episode-num", required=True, help="episode number, e.g. 13")
    ap.add_argument("--episode-title", required=True, help="episode title")
    ap.add_argument("--series-name", required=True, help="series full name")
    ap.add_argument("--channel", default="Cultivation Chronicles")
    ap.add_argument("--hook", default="",
                    help="2-3 sentence hook paragraph (defaults to a plain line)")
    ap.add_argument("--scenes", required=True, help="TSV: start_seconds<TAB>label")
    ap.add_argument("--keywords", default="",
                    help="comma-separated keywords for tags/hashtags")
    ap.add_argument("--video", default="", help="finished MP4 (for thumbnail + duration)")
    ap.add_argument("--thumb-at", type=float, default=None,
                    help="thumbnail frame timestamp in seconds "
                         "(default: 25%% of video duration; pick a moment without "
                         "burned-in captions overlapping the lower third)")
    ap.add_argument("--out", required=True, help="package output directory")
    ap.add_argument("--policy", default=os.path.join(PACKAGING_DIR, "policy-rules.yaml"))
    ap.add_argument("--dry-run", action="store_true", help="print the plan, write nothing")
    args = ap.parse_args()

    policy = load_policy(args.policy)
    scenes = read_scenes(args.scenes)

    video_duration = None
    if args.video:
        if not os.path.exists(args.video):
            fail(f"video not found: {args.video}")
        video_duration = probe_duration(args.video)

    validate_chapters(scenes, policy, video_duration)

    keywords = [k.strip() for k in args.keywords.split(",") if k.strip()]
    series_terms = [args.series_name, f"{args.series_name} Episode {args.episode_num}"]
    tags = list(dict.fromkeys(keywords + series_terms + [args.channel]))

    max_tags = policy["hashtags"]["max_in_description"]
    hashtags = [h for h in (hashtagify(k) for k in keywords[:max_tags]) if h]
    hashtags = hashtags[:max_tags]

    hook = args.hook.strip() or (
        f"Episode {args.episode_num} of {args.series_name}: {args.episode_title}."
    )
    chapters_block = "\n".join(f"{fmt_ts(s)} - {label}" for s, label in scenes)
    subscribe = (
        f"New episodes every week. Subscribe to {args.channel} "
        "so you never miss the next one!"
    )
    blurb = (
        f"New cinematic recaps every week on {args.channel}, covering the greatest "
        "cultivation stories in English. Every episode is an original production: "
        "written, voiced, and animated for this channel."
    )
    spoiler = f"Spoilers for {args.series_name}."
    hashtag_block = " ".join(hashtags)

    title = f"{args.series_name} Ep {args.episode_num}: {args.episode_title} | {args.channel} Recap"
    description = (
        f"{hook}\n\n"
        f"{subscribe}\n\n"
        f"Chapters:\n{chapters_block}\n\n"
        f"{blurb}\n\n"
        f"{spoiler}\n\n"
        f"{hashtag_block}\n"
    )
    checklist = (
        f"# Upload checklist: {args.series_name} Ep {args.episode_num}\n\n"
        "## Promise check (policy)\n"
    )
    for item in policy["promise_check"]:
        checklist += f"- [ ] {item}\n"
    checklist += (
        "\n## Metadata honesty\n"
    )
    for item in policy["metadata_honesty"]:
        checklist += f"- [ ] {item}\n"
    checklist += (
        "\n## Upload steps\n"
        "- [ ] Visibility set as intended (unlisted first for review, then public)\n"
        "- [ ] Added to the series playlist\n"
        "- [ ] End screen: subscribe + next episode placeholder\n"
        "- [ ] Cards: link to previous episode\n"
        "- [ ] Pinned comment posted\n"
        "- [ ] Chapters render on the watch page after processing\n"
    )

    if args.dry_run:
        print("--- DRY RUN: package plan ---")
        print(f"Title: {title}")
        print(f"Description: {len(description)} chars, {len(scenes)} chapters")
        print(f"Tags: {len(tags)}")
        print(f"Hashtags: {hashtag_block or '(none)'}")
        print(f"Thumbnail: {'yes (from video)' if args.video else 'SKIPPED (no --video)'}")
        print("--- (no files written) ---")
        return

    os.makedirs(args.out, exist_ok=True)
    with open(os.path.join(args.out, "title.txt"), "w", encoding="utf-8") as fh:
        fh.write(title + "\n")
    with open(os.path.join(args.out, "description.txt"), "w", encoding="utf-8") as fh:
        fh.write(description)
    with open(os.path.join(args.out, "tags.txt"), "w", encoding="utf-8") as fh:
        fh.write(", ".join(tags) + "\n")
    with open(os.path.join(args.out, "upload-checklist.md"), "w", encoding="utf-8") as fh:
        fh.write(checklist)
    print(f"package_youtube: wrote title.txt, description.txt, tags.txt, upload-checklist.md -> {args.out}")

    if args.video:
        build_thumbnail(args.video, args.episode_num, args.series_name,
                        os.path.join(args.out, "thumbnail.png"),
                        thumb_at=args.thumb_at)
    else:
        print("package_youtube: WARNING: no --video given, thumbnail skipped",
              file=sys.stderr)

    print("package_youtube: done. Review everything before uploading; nothing was published.")


if __name__ == "__main__":
    main()

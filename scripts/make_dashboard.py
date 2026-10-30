#!/usr/bin/env python3
"""Build a static per video dashboard page (HTML) from a small JSON file.

The dashboard is a viewing page only: it links the video file, thumbnail,
packaging notes, chapters, and files. It starts no production and calls
nothing. Open it in any browser.

Usage:
    python3 scripts/make_dashboard.py dashboard.json [--out dashboard.html]

JSON fields:
    channel, episode, title, video (file name or URL), thumbnail,
    duration, size, md5, drive_id, playlist, slot,
    chapters: [[ "0:00", "Cold Open" ], ...],
    files: { "Packaging": "nn-v13-packaging.md", ... },
    pinned_comment
"""
import argparse
import html
import json
import sys


def esc(x):
    return html.escape(str(x), quote=True)


def main():
    ap = argparse.ArgumentParser(description="Build a static video dashboard page")
    ap.add_argument("data", help="Dashboard JSON file")
    ap.add_argument("--out", default="dashboard.html", help="Output HTML file")
    a = ap.parse_args()

    with open(a.data) as f:
        d = json.load(f)

    chapters = "\n".join(
        f"<tr><td>{esc(t)}</td><td>{esc(name)}</td></tr>"
        for t, name in d.get("chapters", []))
    files = "\n".join(
        f'<li><a href="{esc(v)}">{esc(k)}</a></li>'
        for k, v in d.get("files", {}).items())
    meta = " &middot; ".join(
        esc(d[k]) for k in ("duration", "size", "slot", "playlist") if d.get(k))

    page = f"""<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{esc(d.get('title', 'Video dashboard'))}</title>
<style>
 body {{ background:#0d0d10; color:#e8e4da; font-family:Georgia, serif; margin:0; }}
 main {{ max-width:880px; margin:0 auto; padding:32px 20px 64px; }}
 h1 {{ font-size:28px; line-height:1.25; }} h2 {{ color:#b3202e; margin-top:36px; }}
 .meta {{ color:#a49e8f; }} video, img.thumb {{ width:100%; border:1px solid #333; }}
 table {{ border-collapse:collapse; }} td {{ padding:4px 18px 4px 0; }}
 a {{ color:#d8b25c; }} code {{ color:#a49e8f; }}
</style></head><body><main>
<p class="meta">{esc(d.get('channel', ''))} &middot; Episode {esc(d.get('episode', ''))}</p>
<h1>{esc(d.get('title', ''))}</h1>
<p class="meta">{meta}</p>
<video controls preload="metadata" src="{esc(d.get('video', ''))}"
 poster="{esc(d.get('thumbnail', ''))}"></video>
<h2>Chapters</h2>
<table>{chapters}</table>
<h2>Files</h2>
<ul>{files}</ul>
<h2>Pinned comment</h2>
<p>{esc(d.get('pinned_comment', ''))}</p>
<h2>Verification</h2>
<p class="meta">MD5 <code>{esc(d.get('md5', ''))}</code><br>
Drive ID <code>{esc(d.get('drive_id', ''))}</code></p>
<p class="meta">Static page. It starts no production and changes nothing.</p>
</main></body></html>
"""
    with open(a.out, "w") as f:
        f.write(page)
    print(f"Wrote {a.out} ({len(page)} bytes)")


if __name__ == "__main__":
    sys.exit(main())

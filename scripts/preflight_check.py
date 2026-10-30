#!/usr/bin/env python3
"""CineForge preflight check.

Reports what a production build needs, before it starts: core tools, the TTS
CLI, disk space, and (optionally) a channel sound kit and music bed. Read
only: it installs nothing, downloads nothing, and makes no paid calls.

Usage:
    python3 scripts/preflight_check.py [--kit-dir DIR] [--music-bed FILE]
                                       [--min-free-gb N] [--json]

Exit code 0 if every required check passes, 1 otherwise.
"""
import argparse
import json
import shutil
import subprocess
import sys


def tool_version(cmd):
    try:
        out = subprocess.run(cmd, capture_output=True, text=True, timeout=15)
        first = (out.stdout or out.stderr).strip().splitlines()
        return first[0].strip() if first else "present"
    except Exception:
        return None


def main():
    ap = argparse.ArgumentParser(description="CineForge preflight check")
    ap.add_argument("--kit-dir", help="Sound kit folder that must exist with files in it")
    ap.add_argument("--music-bed", help="Music bed file that must exist")
    ap.add_argument("--min-free-gb", type=float, default=5.0,
                    help="Minimum free disk space in GB (default 5)")
    ap.add_argument("--json", action="store_true", help="Print a JSON report")
    args = ap.parse_args()

    checks = []

    def add(name, ok, detail, required=True):
        checks.append({"check": name, "ok": bool(ok), "required": required,
                       "detail": detail})

    for name, cmd in [("ffmpeg", ["ffmpeg", "-version"]),
                      ("ffprobe", ["ffprobe", "-version"]),
                      ("python3", ["python3", "--version"]),
                      ("node", ["node", "--version"])]:
        ver = tool_version(cmd) if shutil.which(cmd[0]) else None
        add(name, ver is not None, ver or "MISSING")

    tts = shutil.which("tts")
    add("tts CLI", tts is not None, tts or "MISSING (needed for narration synthesis)")

    fonts = tool_version(["fc-list"])
    add("fontconfig fonts", fonts is not None,
        "fonts available" if fonts else "fc-list MISSING or no fonts", required=False)

    free_gb = shutil.disk_usage(".").free / 1e9
    add("disk space", free_gb >= args.min_free_gb,
        f"{free_gb:.1f} GB free, need {args.min_free_gb:.1f} GB")

    if args.kit_dir:
        import os
        files = []
        if os.path.isdir(args.kit_dir):
            files = [f for f in os.listdir(args.kit_dir)
                     if os.path.isfile(os.path.join(args.kit_dir, f))]
        add("sound kit", len(files) > 0,
            f"{args.kit_dir}: {len(files)} files" if files else f"{args.kit_dir} MISSING or empty")
    if args.music_bed:
        import os
        add("music bed", os.path.isfile(args.music_bed),
            args.music_bed if os.path.isfile(args.music_bed) else f"{args.music_bed} MISSING")

    failed = [c for c in checks if c["required"] and not c["ok"]]
    report = {"ok": not failed, "checks": checks}

    if args.json:
        print(json.dumps(report, indent=2))
    else:
        print("CineForge preflight")
        for c in checks:
            mark = "OK  " if c["ok"] else ("FAIL" if c["required"] else "warn")
            print(f"  [{mark}] {c['check']}: {c['detail']}")
        print("RESULT:", "PASS" if not failed else f"FAIL ({len(failed)} required check(s) failed)")
    sys.exit(0 if not failed else 1)


if __name__ == "__main__":
    main()

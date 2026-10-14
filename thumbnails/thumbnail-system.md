# Thumbnail System

One locked template. Only the episode number swaps between episodes.

## Locked template spec

- **Episode badge:** the episode number as two digits ("01", "02", ... "12") inside an ornamented golden ring badge, positioned at top-right.
- **Series name:** the series full name in gold along the bottom of the frame.
- **Background and character art:** key character or scene art filling the frame, high contrast, readable at small sizes. Character art must match the locked character designs in the design library.
- **Layout:** badge top-right, series name bottom, central art unobstructed. Do not rearrange these elements between episodes. The template is locked; consistency is the point.

## The swap-only-the-number rule

Between episodes, exactly one thing changes: the episode number inside the golden ring badge. Same badge, same typography, same layout, same series name. A viewer scrolling the channel page should see a uniform grid where only the number advances.

## Typography

- Episode number: bold, high-contrast, legible inside the ring at 120px wide.
- Series name: gold, embossed or stroked for separation from the background, sized to be readable in feed thumbnails (test at 240px wide).
- No other text on the thumbnail. Titles and metadata live in the upload fields, not on the image.

## Export specs

- Resolution: 1280 x 720 (16:9).
- Format: PNG or high-quality JPEG.
- File size: under 2MB.
- Safe area: keep critical elements (badge, series name) clear of platform UI overlays at the corners and bottom edge.

## Workflow

1. Render or compose the episode's key art from a locked character design.
2. Apply the template: place the golden ring badge with the new episode number at top-right, lay the gold series name along the bottom.
3. Export at 1280 x 720, verify legibility at 240px wide, and confirm the number is the only element that changed from the previous episode.

## Automated composite (scripts/package_youtube.py)

For speed, the packager builds an achievable version of this template automatically: it pulls a frame from the finished video (default 25% duration, overridable with --thumb-at), scales to 1280x720, sets the episode number large in gold (#D4AF37) at top-right, and centers the series name in gold along the bottom over a subtle dark band for legibility. The ornamental ring badge remains the design aspiration for hand-finished variants; the automated composite keeps the same layout grammar (number top-right, series name bottom, nothing else on the image) so the channel grid stays uniform either way.

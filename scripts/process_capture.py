#!/usr/bin/env python3
"""Turn the CI capture into deliverables.

Usage: process_capture.py <capture-dir> <output-dir> <font-dir>

- Trims raw.mov to the app tour (between the "start" and "end" markers written
  by the UI test) and compresses it to H.264 720p.
- Builds App Store screenshots (6.9", 1320x2868): the plain simulator screenshots
  and marketing versions with a caption.
"""
import os
import subprocess
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

cap, out, fonts = sys.argv[1:4]
os.makedirs(out, exist_ok=True)

# ---------- video ----------
record_start = float(open(os.path.join(cap, "record_start.txt")).read().strip())
markers = dict(line.split() for line in open(os.path.join(cap, "markers.txt")) if line.strip())
start = float(markers["start"]) - record_start
end = float(markers["end"]) - record_start
print(f"trim {start:.2f}s – {end:.2f}s ({end - start:.1f}s)")
video = os.path.join(out, "Iceland-App-Demo.mp4")
subprocess.run([
    "ffmpeg", "-y", "-loglevel", "error", "-ss", f"{start:.3f}", "-i", os.path.join(cap, "raw.mov"),
    "-t", f"{end - start:.3f}", "-an",
    "-vf", "fps=30,scale=720:-2:flags=lanczos,format=yuv420p",
    "-c:v", "libx264", "-preset", "slow", "-crf", "26", "-profile:v", "high",
    "-movflags", "+faststart", video,
], check=True)
print("video", os.path.getsize(video) // 1024, "KB")

# ---------- screenshots ----------
W, H = 1320, 2868
shots = [
    ("01-explore", "探索冰島絕景", "13 個必訪景點，盡在掌握", ((8, 24, 52), (24, 110, 160))),
    ("02-detail", "深入認識每個景點", "最佳季節、停留時間、必看亮點", ((10, 40, 60), (40, 150, 130))),
    ("04-map-detail", "3D 地圖飛越冰島", "點一下，直達景點上空", ((14, 30, 70), (70, 90, 190))),
    ("05-favorites", "收藏你的夢想清單", "規劃專屬的冰島行程", ((60, 20, 40), (210, 90, 70))),
    ("06-info", "出發前的旅遊指南", "基本資訊與實用小提醒", ((6, 20, 40), (30, 150, 110))),
]
bold = ImageFont.truetype(os.path.join(fonts, "NotoSansTC_800ExtraBold.ttf"), 110)
medium = ImageFont.truetype(os.path.join(fonts, "NotoSansTC_500Medium.ttf"), 56)
raw_dir = os.path.join(out, "AppStore-Screenshots", "plain")
mk_dir = os.path.join(out, "AppStore-Screenshots", "marketing")
os.makedirs(raw_dir, exist_ok=True)
os.makedirs(mk_dir, exist_ok=True)

for n, (name, title, subtitle, (c1, c2)) in enumerate(shots, 1):
    src = os.path.join(cap, f"{name}.png")
    if not os.path.exists(src):
        print("missing", src)
        continue
    shot = Image.open(src).convert("RGB")
    print(name, shot.size)
    plain = shot if shot.size == (W, H) else shot.resize((W, H), Image.LANCZOS)
    plain.save(os.path.join(raw_dir, f"{n:02d}-{name[3:]}.png"))

    bg = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(bg)
    for y in range(H):
        t = y / H
        d.line([(0, y), (W, y)], fill=tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3)))
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse((-300, 1500, W + 300, H + 600), fill=(255, 255, 255, 40))
    bg.paste(glow.filter(ImageFilter.GaussianBlur(160)), (0, 0), glow.filter(ImageFilter.GaussianBlur(160)))

    d = ImageDraw.Draw(bg)
    d.text((W / 2, 250), title, font=bold, fill="white", anchor="mm")
    d.text((W / 2, 395), subtitle, font=medium, fill=(220, 235, 245), anchor="mm")

    sw = 1040
    sh = int(shot.height * sw / shot.width)
    screen = shot.resize((sw, sh), Image.LANCZOS)
    radius, bezel = 120, 26
    x0, y0 = (W - sw) // 2, 540
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        (x0 - bezel, y0 - bezel + 30, x0 + sw + bezel, y0 + sh + bezel + 30), radius + bezel, fill=(0, 0, 0, 120))
    shadow = shadow.filter(ImageFilter.GaussianBlur(40))
    bg.paste(shadow, (0, 0), shadow)
    d = ImageDraw.Draw(bg)
    d.rounded_rectangle((x0 - bezel, y0 - bezel, x0 + sw + bezel, y0 + sh + bezel), radius + bezel, fill=(18, 20, 24))
    mask = Image.new("L", (sw, sh), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, sw - 1, sh - 1), radius, fill=255)
    bg.paste(screen, (x0, y0), mask)
    bg.save(os.path.join(mk_dir, f"{n:02d}-{name[3:]}.png"))

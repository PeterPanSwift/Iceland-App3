#!/usr/bin/env python3
"""Draw the 1024x1024 app icon: aurora over a Kirkjufell-like peak."""
import math
import random
import sys

from PIL import Image, ImageDraw, ImageFilter

S = 1024
random.seed(7)


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


sky = Image.new("RGB", (S, S))
px = sky.load()
top, mid, bottom = (6, 14, 38), (12, 46, 78), (28, 98, 112)
for y in range(S):
    t = y / S
    c = lerp(top, mid, t / 0.6) if t < 0.6 else lerp(mid, bottom, (t - 0.6) / 0.4)
    for x in range(S):
        px[x, y] = c

# stars
stars = Image.new("RGBA", (S, S), (0, 0, 0, 0))
d = ImageDraw.Draw(stars)
for _ in range(140):
    x, y = random.randrange(S), random.randrange(int(S * 0.62))
    r = random.choice([1, 1, 1.5, 2, 2.5])
    a = random.randint(120, 255)
    d.ellipse((x - r, y - r, x + r, y + r), fill=(255, 255, 255, a))
sky.paste(stars, (0, 0), stars)

# aurora ribbons
def ribbon(color, y0, amp, phase, width, alpha):
    layer = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ld = ImageDraw.Draw(layer)
    for x in range(-40, S + 40, 4):
        y = y0 + amp * math.sin(x / S * 2.6 * math.pi + phase) + 40 * math.sin(x / 90 + phase)
        for k in range(0, int(width), 3):
            a = int(alpha * (1 - k / width) ** 1.6)
            ld.line([(x, y - k), (x + 4, y - k)], fill=color + (a,), width=4)
        ld.line([(x, y), (x + 4, y)], fill=color + (alpha,), width=6)
    return layer.filter(ImageFilter.GaussianBlur(14))


for color, y0, amp, ph, w, a in [
    ((70, 255, 175), 400, 90, 0.4, 280, 255),
    ((50, 230, 215), 300, 70, 1.9, 220, 190),
    ((170, 120, 255), 220, 60, 3.0, 170, 130),
]:
    layer = ribbon(color, y0, amp, ph, w, a)
    sky.paste(layer, (0, 0), layer)

glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
ImageDraw.Draw(glow).ellipse((150, 300, 900, 760), fill=(70, 255, 180, 60))
glow = glow.filter(ImageFilter.GaussianBlur(120))
sky.paste(glow, (0, 0), glow)

# mountain silhouette (Kirkjufell: steep asymmetric cone)
mountain = Image.new("RGBA", (S, S), (0, 0, 0, 0))
md = ImageDraw.Draw(mountain)
peak = (470, 420)
pts = [(-20, 860), (120, 820), (260, 730), (360, 590), (420, 490), peak,
       (520, 440), (600, 540), (700, 670), (820, 765), (940, 815), (1044, 835), (1044, S), (-20, S)]
md.polygon(pts, fill=(10, 26, 40, 255))
mountain = mountain.filter(ImageFilter.GaussianBlur(1.2))
# aurora light catching the left face of the mountain
lit = Image.new("RGBA", (S, S), (0, 0, 0, 0))
ImageDraw.Draw(lit).polygon([(150, 800), (260, 730), (360, 590), (420, 490), peak, (455, 560), (380, 720), (300, 820)],
                            fill=(60, 200, 170, 90))
lit = lit.filter(ImageFilter.GaussianBlur(30))
mask = mountain.split()[3]
mountain.paste(lit, (0, 0), Image.composite(lit.split()[3], Image.new("L", (S, S), 0), mask))
sky.paste(mountain, (0, 0), mountain)

# foreground hills and lake reflection
fg = Image.new("RGBA", (S, S), (0, 0, 0, 0))
fd = ImageDraw.Draw(fg)
fd.rectangle((0, 870, S, S), fill=(10, 40, 58, 255))
refl = Image.new("RGBA", (S, S), (0, 0, 0, 0))
ImageDraw.Draw(refl).ellipse((60, 900, 960, 1010), fill=(70, 255, 175, 90))
refl = refl.filter(ImageFilter.GaussianBlur(30))
fg.paste(refl, (0, 0), refl)
for i in range(12):
    y = 905 + i * 10
    fd.line([(random.randint(120, 380), y), (random.randint(600, 900), y)], fill=(120, 255, 200, 90 - i * 6), width=3)
fd.polygon([(-20, 900), (180, 862), (420, 880), (640, 868), (860, 888), (1044, 870), (1044, 900)], fill=(5, 16, 26, 255))
sky.paste(fg, (0, 0), fg)

sky.save(sys.argv[1])

#!/usr/bin/env python3
"""Fetch freely licensed Iceland landmark photos from Wikimedia Commons.

candidates: download small previews of several candidate photos per spot
            into ./image-candidates (for manual picking).
final:      download the photos listed in scripts/image_selection.json into
            the asset catalog and write Iceland/Resources/credits.json.
"""
import json
import os
import re
import sys
import time
import urllib.parse
import urllib.request

UA = "IcelandGuideApp/1.0 (https://github.com/PeterPanSwift/Iceland-App3)"
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

SPOTS = {
    "skogafoss": ("Skógafoss", "Skogafoss waterfall"),
    "seljalandsfoss": ("Seljalandsfoss", "Seljalandsfoss waterfall"),
    "gullfoss": ("Gullfoss", "Gullfoss waterfall"),
    "jokulsarlon": ("Jökulsárlón", "Jokulsarlon glacier lagoon"),
    "kirkjufell": ("Kirkjufell", "Kirkjufell Kirkjufellsfoss"),
    "bluelagoon": ("Blue Lagoon (geothermal spa)", "Blue Lagoon Iceland"),
    "hallgrimskirkja": ("Hallgrímskirkja", "Hallgrimskirkja Reykjavik"),
    "reynisfjara": ("Reynisfjara", "Reynisfjara black sand beach"),
    "thingvellir": ("Þingvellir", "Thingvellir national park"),
    "dettifoss": ("Dettifoss", "Dettifoss waterfall"),
    "strokkur": ("Strokkur", "Strokkur geyser eruption"),
    "landmannalaugar": ("Landmannalaugar", "Landmannalaugar rhyolite mountains"),
    "myvatn": ("Mývatn", "Myvatn lake Iceland"),
    "aurora": (None, "Aurora borealis Iceland"),
}

FREE = re.compile(r"^(CC0|CC BY|CC-BY|Public domain|PD)", re.I)


def get(url, binary=False):
    for attempt in range(5):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=60) as r:
                data = r.read()
            return data if binary else json.loads(data)
        except Exception as e:  # noqa: BLE001
            print("  retry", attempt, url[:120], e)
            time.sleep(2 + attempt * 3)
    raise RuntimeError("failed: " + url)


def api(base, **params):
    params.update(format="json", formatversion="2")
    return get(base + "?" + urllib.parse.urlencode(params))


COMMONS = "https://commons.wikimedia.org/w/api.php"
ENWIKI = "https://en.wikipedia.org/w/api.php"


def strip_html(s):
    return re.sub(r"<[^>]+>", "", s or "").strip()


def file_info(titles, width):
    res = api(COMMONS, action="query", titles="|".join(titles), prop="imageinfo",
              iiprop="url|size|extmetadata|mime", iiurlwidth=width,
              iiextmetadatafilter="LicenseShortName|Artist|LicenseUrl")
    out = []
    for p in res["query"]["pages"]:
        if "imageinfo" not in p:
            continue
        ii = p["imageinfo"][0]
        md = ii.get("extmetadata", {})
        out.append({
            "title": p["title"],
            "width": ii["width"], "height": ii["height"],
            "mime": ii.get("mime"),
            "thumb": ii.get("thumburl"),
            "page": ii.get("descriptionurl"),
            "license": md.get("LicenseShortName", {}).get("value", ""),
            "licenseUrl": md.get("LicenseUrl", {}).get("value", ""),
            "artist": strip_html(md.get("Artist", {}).get("value", "")),
        })
    order = {t: i for i, t in enumerate(titles)}
    out.sort(key=lambda x: order.get(x["title"], 99))
    return out


def candidates():
    outdir = os.path.join(ROOT, "image-candidates")
    os.makedirs(outdir, exist_ok=True)
    meta = {}
    for slug, (wiki, query) in SPOTS.items():
        print("==", slug)
        titles = []
        if wiki:
            r = api(ENWIKI, action="query", titles=wiki, prop="pageimages",
                    piprop="name", redirects=1)
            for p in r["query"]["pages"]:
                if p.get("pageimage"):
                    titles.append("File:" + p["pageimage"])
        r = api(COMMONS, action="query", list="search",
                srsearch=query + " filetype:bitmap", srnamespace=6, srlimit=30)
        titles += [s["title"] for s in r["query"]["search"] if s["title"] not in titles]
        infos = []
        for i in range(0, len(titles), 20):
            infos += file_info(titles[i:i + 20], 640)
        good = [x for x in infos
                if x["mime"] == "image/jpeg" and x["width"] >= 1600
                and x["width"] > x["height"] * 1.2 and FREE.match(x["license"])]
        good = good[:8]
        meta[slug] = good
        for n, x in enumerate(good):
            path = os.path.join(outdir, f"{slug}_{n}.jpg")
            with open(path, "wb") as f:
                f.write(get(x["thumb"], binary=True))
            print("  ", n, x["title"], x["width"], x["height"], x["license"])
            time.sleep(0.3)
    with open(os.path.join(outdir, "candidates.json"), "w") as f:
        json.dump(meta, f, ensure_ascii=False, indent=2)


def final():
    with open(os.path.join(ROOT, "scripts", "image_selection.json")) as f:
        selection = json.load(f)
    assets = os.path.join(ROOT, "Iceland", "Assets.xcassets")
    credits = []
    for slug, title in selection.items():
        info = file_info([title], 1600)[0]
        d = os.path.join(assets, f"{slug}.imageset")
        os.makedirs(d, exist_ok=True)
        with open(os.path.join(d, f"{slug}.jpg"), "wb") as f:
            f.write(get(info["thumb"], binary=True))
        with open(os.path.join(d, "Contents.json"), "w") as f:
            json.dump({"images": [{"filename": f"{slug}.jpg", "idiom": "universal"}],
                       "info": {"author": "xcode", "version": 1}}, f, indent=2)
        credits.append({"image": slug, "title": info["title"].removeprefix("File:"),
                        "artist": info["artist"], "license": info["license"],
                        "licenseUrl": info["licenseUrl"], "source": info["page"]})
        print(slug, info["title"], info["license"], info["artist"])
        time.sleep(0.3)
    res = os.path.join(ROOT, "Iceland", "Resources")
    os.makedirs(res, exist_ok=True)
    with open(os.path.join(res, "credits.json"), "w") as f:
        json.dump(credits, f, ensure_ascii=False, indent=2)


if __name__ == "__main__":
    {"candidates": candidates, "final": final}[sys.argv[1]]()

"""Read PNG alpha and emit source rectangles; never modifies image assets.
Run with a Python runtime that provides Pillow.
"""
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1] / 'assets/avatar/catalog'

def bbox(image, region):
    alpha = image.getchannel('A').crop(region)
    box = alpha.point(lambda a: 255 if a > 245 else 0).getbbox()
    if box is None:
        return None
    x, y, r, b = box
    return [region[0] + x, region[1] + y, r - x, b - y]

def bands(image):
    w, h = image.size
    alpha = image.getchannel('A')
    intervals, start, last = [], None, None
    for y in range(h):
        count = sum(v > 245 for v in alpha.crop((0, y, w, y + 1)).get_flattened_data())
        if count > w * .025:
            if last is not None and y - last > 24:
                intervals.append((start, last + 1))
                start = None
            if start is None:
                start = y
            last = y
    if start is not None:
        intervals.append((start, last + 1))
    return intervals

result = {}
for name in ['hair', 'tops', 'tops-wave', 'bottoms', 'footwear', 'extras']:
    image = Image.open(ROOT / f'{name}-v1.png')
    intervals = bands(image)
    if name == 'hair':
        assert len(intervals) == 7, intervals
        intervals.insert(3, None)
    assert len(intervals) == 8, (name, intervals)
    rows = []
    for interval in intervals:
        rows.append([None if interval is None else bbox(image, (round(col * image.width / 8), max(0, interval[0] - 4), round((col + 1) * image.width / 8), min(image.height, interval[1] + 4))) for col in range(8)])
    result[name] = rows
image = Image.open(ROOT / 'body-v1.png')
for part, top, bottom in [('head', 0, .51), ('hands', .51, .69), ('legs', .69, 1)]:
    result['body-' + part] = [[bbox(image, (round(col * image.width / 8), round((row + top) * image.height / 4), round((col + 1) * image.width / 8), round((row + bottom) * image.height / 4))) for col in range(8)] for row in range(4)]
result['body-raised'] = [[bbox(image, (round((col + (.71 if col < 4 else 0)) * image.width / 8), round((row + .17) * image.height / 4), round((col + (1 if col < 4 else .29)) * image.width / 8), round((row + .48) * image.height / 4))) for col in range(8)] for row in [2, 3]]
(ROOT / 'index-v1.json').write_text(json.dumps(result, indent=2) + '\n')
print('Indexed', len(result), 'layers; PNG files unchanged.')

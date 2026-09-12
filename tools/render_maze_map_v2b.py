"""Render the Maze V2-B layout captured from the live Studio place."""

import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
layout = json.loads((ROOT / "tools/maze_v2b_layout.json").read_text(encoding="utf-8"))
scale = 2.35
width, height = 1540, 1750
image = Image.new("RGB", (width, height), (18, 22, 28))
draw = ImageDraw.Draw(image)

try:
    title_font = ImageFont.truetype("arialbd.ttf", 30)
    label_font = ImageFont.truetype("arial.ttf", 19)
    small_font = ImageFont.truetype("arial.ttf", 15)
except OSError:
    title_font = label_font = small_font = ImageFont.load_default()


def pixel(x, z):
    return round(280 + (x + 260) * scale), round(155 + (z + 770) * scale)


def rect_world(x0, z0, x1, z1, **kwargs):
    a, b = pixel(x0, z0)
    c, d = pixel(x1, z1)
    draw.rectangle((min(a, c), min(b, d), max(a, c), max(b, d)), **kwargs)


def center(node):
    c, r = map(int, node.split(","))
    return layout["x0"] + c * layout["cell"], layout["z0"] - r * layout["cell"]


draw.text((40, 34), "THE THIRD LIGHT  /  LABIRINTO V2-B", font=title_font, fill=(240, 241, 231))
draw.text((40, 79), "Vista superior tecnica · norte para cima · sem estruturas construidas", font=label_font, fill=(180, 196, 188))

rect_world(-246, -670, 246, -140, fill=(49, 54, 59))
for first, last, color, label in (
    (0, 3, (62, 78, 70), "SETOR 1"),
    (4, 8, (72, 83, 65), "SETOR 2  +25%"),
    (9, 12, (69, 64, 80), "SETOR 3"),
):
    north = layout["z0"] - last * 40 - 20
    south = layout["z0"] - first * 40 + 20
    rect_world(-246, north, 246, south, fill=color)
    x, y = pixel(-240, north + 6)
    draw.text((x, y), label, fill=(206, 218, 204), font=label_font)

# The inserted row is deliberately shown as a distinct forest band.
rect_world(-224, -380, 224, -340, outline=(117, 159, 105), width=3)

main = set(layout["mainLinks"].split(";"))
clearings = set(layout["clearings"].split(";"))
pockets = set(layout["pockets"].split(";"))
for edge in layout["openWalls"].split(";"):
    a, b = edge.split("|")
    if not a or not b:
        continue
    main_route = edge in main or (b + "|" + a) in main
    draw.line((pixel(*center(a)), pixel(*center(b))), fill=(130, 155, 103) if main_route else (109, 132, 92), width=48 if main_route else 39)

for col in range(layout["cols"]):
    for row in range(layout["rows"]):
        key = f"{col},{row}"
        x, z = center(key)
        radius = 24 if key in clearings else 14 if key in pockets else 9
        px, py = pixel(x, z)
        rad = radius * scale
        draw.ellipse((px-rad, py-rad, px+rad, py+rad), fill=(139, 161, 109) if key in clearings else (120, 144, 101))
        if row == 5:
            draw.ellipse((px-3, py-3, px+3, py+3), fill=(235, 239, 213))

labels = {
    "RangerCabin": "CABANA · futura",
    "Observatory": "OBSERVATORIO · futuro",
    "WatchPost": "POSTO · futuro",
    "TechnicalArea": "AREA TECNICA · futura",
    "AncientFoundation": "FUNDACAO · futura",
}
for marker in layout["markers"]:
    x, z = marker["x"], marker["z"]
    w, h = marker["w"], marker["h"]
    color = (232, 183, 103) if marker["name"] != "AncientFoundation" else (176, 153, 177)
    rect_world(x-w/2, z-h/2, x+w/2, z+h/2, outline=color, width=3)
    px, py = pixel(x-w/2, z-h/2)
    draw.text((px+5, py+5), labels.get(marker["name"], marker["name"]), font=small_font, fill=color)

# Spawn and gate are location references, not implemented objectives.
sx, sy = pixel(-40, -200)
draw.ellipse((sx-10, sy-10, sx+10, sy+10), fill=(96, 187, 238))
draw.text((sx+15, sy-9), "RESPAWN", font=small_font, fill=(153, 212, 247))
gx, gy = pixel(80, -743)
draw.rectangle((gx-9, gy-9, gx+9, gy+9), fill=(243, 208, 99))
draw.text((gx+16, gy-9), "PORTAO FUTURO", font=small_font, fill=(243, 208, 99))

for row in range(layout["rows"]):
    x, y = pixel(-255, layout["z0"] - row * 40)
    draw.text((x-43, y-8), f"r{row}", font=small_font, fill=(177, 182, 179))

draw.text((40, height-158), "SETOR 1  70.400 studs²  |  SETOR 2  88.000 studs²  |  SETOR 3  70.400 studs²", font=label_font, fill=(213, 219, 207))
draw.text((40, height-117), "Verde claro: nova faixa de floresta  ·  Laranja: FutureStructureAreas (vazias)", font=small_font, fill=(178, 193, 174))
draw.text((40, height-91), "Corredores = grafo do Layout; a escavacao organica real pode variar.", font=small_font, fill=(178, 193, 174))
draw.text((40, height-64), "Fonte: place em Edit, 12 set 2026. Vista esquematica, nao captura do Studio.", font=small_font, fill=(178, 193, 174))

target = ROOT / "docs/img/mapa-labirinto-v2b.png"
target.parent.mkdir(parents=True, exist_ok=True)
image.save(target)
print(target)

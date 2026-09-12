# Renders a technical PNG map of the maze from Layout data (paste the attributes below).
# Usage: python tools/render_maze_map.py docs/img/mapa-labirinto.png
import sys
from PIL import Image, ImageDraw, ImageFont

OPENWALLS = open("tools/_layout_openwalls.txt").read().strip()
CLEARINGS = "2,2;8,1;6,2;5,5;1,7;8,4;9,6;2,9;4,9;8,10"
POCKETS = "3,10;7,0;7,2;7,5;7,7;8,3;8,4;8,6;9,0;9,2;9,5;9,7;9,9"
MAIN = open("tools/_layout_main.txt").read().strip()
CANDS = open("tools/_layout_cands.txt").read().strip()
EXTRA = dict(l.split("=", 1) for l in open("tools/_layout_extra.txt", encoding="utf-8").read().strip().splitlines())
AREA_R = {"2,2": 27, "8,1": 27, "6,2": 16, "5,5": 30, "1,7": 27, "8,4": 17, "9,6": 17, "2,9": 19, "4,9": 18, "8,10": 38}

COLS, ROWS, CELL = 11, 12, 40
X0, Z0 = -200, -160
S = 3.0  # px per stud
W, H = int(560 * S), int(860 * S)
OX, OZ = 280, -80  # world: x=-280..280, z=+80..-680 (north up)


def wx(x):
    return int((x + OX) * S)


def wz(z):
    return int((z + 780) * S)  # north (z=-680) at the top, camp (z=+80) at the bottom


def rect(x0, y0, x1, y1, **kw):
    d.rectangle([min(x0, x1), min(y0, y1), max(x0, x1), max(y0, y1)], **kw)


img = Image.new("RGB", (W, H), (18, 20, 26))
d = ImageDraw.Draw(img)
try:
    font = ImageFont.truetype("arial.ttf", 16)
    small = ImageFont.truetype("arial.ttf", 12)
    big = ImageFont.truetype("arialbd.ttf", 22)
except Exception:
    font = small = big = ImageFont.load_default()

# rock block
rect(wx(-250), wz(-650), wx(250), wz(-130), fill=(58, 62, 72))
# sector bands
for r0, r1, col, name in [(0, 3, (70, 78, 70), "SETOR 1 — observação · 3 clareiras"), (4, 7, (74, 70, 64), "SETOR 2 — exploração + objetivo · 4 áreas de estrutura"), (8, 11, (66, 60, 70), "SETOR 3 — sobrevivência · chave/código · 1 ruína pequena")]:
    z_top = Z0 - r1 * CELL - 20
    z_bot = Z0 - r0 * CELL + 20
    rect(wx(-250), wz(z_top), wx(250), wz(z_bot), fill=col)
    d.text((wx(-245), wz(z_top) + 4), name, fill=(200, 200, 210), font=font)

links = []
for pair in OPENWALLS.split(";"):
    a, b = pair.split("|")
    links.append((tuple(map(int, a.split(","))), tuple(map(int, b.split(",")))))
main = set(MAIN.split(";"))
clear = set(CLEARINGS.split(";"))
pockets = set(POCKETS.split(";"))


def center(c, r):
    return X0 + c * CELL, Z0 - r * CELL


# corridors
for a, b in links:
    key = f"{a[0]},{a[1]}|{b[0]},{b[1]}"
    ismain = key in main or f"{b[0]},{b[1]}|{a[0]},{a[1]}" in main
    ax, az = center(*a)
    bx, bz = center(*b)
    w = int(24 * S) if ismain else int(18 * S)
    col = (118, 138, 96) if ismain else (98, 116, 84)
    d.line([wx(ax), wz(az), wx(bx), wz(bz)], fill=col, width=w)
# nodes
for c in range(COLS):
    for r in range(ROWS):
        k = f"{c},{r}"
        x, z = center(c, r)
        if k in clear:
            rad = AREA_R.get(k, 27) * S
            d.ellipse([wx(x) - rad, wz(z) - rad, wx(x) + rad, wz(z) + rad], fill=(120, 140, 98))
        elif k in pockets:
            rad = 15 * S
            d.ellipse([wx(x) - rad, wz(z) - rad, wx(x) + rad, wz(z) + rad], fill=(108, 126, 90))
        else:
            rad = 10 * S
            d.ellipse([wx(x) - rad, wz(z) - rad, wx(x) + rad, wz(z) + rad], fill=(108, 126, 90))
# entrance approach + camp gate
path = [(0, -86), (-6, -98), (-18, -110), (-30, -122), (-33, -134), (-32, -146), (-40, -160)]
for i in range(len(path) - 1):
    d.line([wx(path[i][0]), wz(path[i][1]), wx(path[i + 1][0]), wz(path[i + 1][1])], fill=(150, 130, 90), width=int(20 * S))
d.line([wx(0), wz(-42), wx(0), wz(-86)], fill=(150, 130, 90), width=int(18 * S))
rect(wx(-60), wz(60), wx(60), wz(-40), outline=(200, 170, 110), width=3)
d.text((wx(-55), wz(-40) + 6), "ACAMPAMENTO (spawn)", fill=(230, 200, 140), font=font)
# barrier and trigger
d.line([wx(-52), wz(-135), wx(-12), wz(-135)], fill=(230, 80, 80), width=4)
d.text((wx(-10), wz(-135) + 4), "barreira/gatilho (z -135/-142)", fill=(230, 120, 120), font=small)
# exit corridor + gate
d.line([wx(80), wz(-600), wx(80), wz(-656)], fill=(118, 138, 96), width=int(19 * S))
d.line([wx(80), wz(-702), wx(80), wz(-760)], fill=(118, 138, 96), width=int(16 * S))
rect(wx(73), wz(-707), wx(87), wz(-699), fill=(240, 210, 100))
d.text((wx(90), wz(-712)), "PORTÃO FINAL (futuro) (80,-703) → trilha final", fill=(240, 210, 100), font=font)
# structure areas + S3 foundation
for item in EXTRA["STRUCT"].split(";"):
    name, vals = item.split(":")
    x, z, sx, sz = map(float, vals.split(","))
    col = (200, 150, 90) if name != "AncientFoundation" else (150, 120, 130)
    rect(wx(x - sx / 2), wz(z - sz / 2), wx(x + sx / 2), wz(z + sz / 2), outline=col, width=3)
    d.text((wx(x - sx / 2) + 4, wz(z - sz / 2) + 4), name, fill=col, font=font)
# gate antechamber
rect(wx(62), wz(-702), wx(98), wz(-656), outline=(230, 200, 80), width=2)
d.text((wx(100), wz(-690)), "antecâmara 36×46", fill=(240, 210, 100), font=small)
# future moon points
for item in EXTRA["MOON"].split(";"):
    name, pos = item.split(":")
    x, z = map(float, pos.split(","))
    r = 6 * S
    d.ellipse([wx(x) - r, wz(z) - r, wx(x) + r, wz(z) + r], outline=(235, 70, 70), width=3)
    d.text((wx(x) + r + 2, wz(z) - 7), name.split("_", 1)[1], fill=(235, 120, 120), font=small)
# easter egg areas
for item in EXTRA["EGGS"].split(";"):
    name, pos = item.split(":")
    x, z = map(float, pos.split(","))
    r = 6 * S
    d.polygon([(wx(x), wz(z) - r), (wx(x) + r, wz(z)), (wx(x), wz(z) + r), (wx(x) - r, wz(z))], fill=(90, 220, 120))
    d.text((wx(x) + r + 2, wz(z) - 7), name.split("_", 1)[1], fill=(140, 240, 160), font=small)
# candidates
for item in CANDS.split(";"):
    name, pos = item.split(":")
    x, z = map(float, pos.split(","))
    r = 5 * S
    d.ellipse([wx(x) - r, wz(z) - r, wx(x) + r, wz(z) + r], fill=(240, 220, 90), outline=(40, 40, 40))
# respawn + entry
d.ellipse([wx(-40) - 10, wz(-200) - 10, wx(-40) + 10, wz(-200) + 10], fill=(90, 180, 240))
d.text((wx(-40) + 14, wz(-200) - 8), "MazeRespawn (4,1)", fill=(140, 200, 250), font=small)
d.text((wx(-40) - 20, wz(-160) - 60), "E: área de leitura\n3 rotas", fill=(255, 255, 255), font=small)
# grid labels
for c in range(COLS):
    d.text((wx(X0 + c * CELL) - 8, wz(-655) - 16), f"c{c}", fill=(150, 150, 160), font=small)
for r in range(ROWS):
    d.text((wx(-270), wz(Z0 - r * CELL) - 7), f"r{r}", fill=(150, 150, 160), font=small)
# legend
lx, ly = wx(-275), wz(-780) + 6
d.text((lx, ly), "THE THIRD LIGHT — MAZE V2-A (norte para cima)", fill=(255, 255, 255), font=big)
d.text((lx, ly + 30), "corredor principal   secundário   ● clareira/área   ● candidato chave/código   ○ vermelho = futuro Moon Point   ◆ verde = easter egg   ▬ barreira", fill=(200, 200, 210), font=small)
d.text((lx, ly + 48), "Setor 1 = linhas 0–3 · Setor 2 = 4–7 · Setor 3 = 8–11 · passagens S1→S2 nas colunas 4 e 6 · S2→S3 nas colunas 1 e 10", fill=(200, 200, 210), font=small)

out = sys.argv[1] if len(sys.argv) > 1 else "docs/img/mapa-labirinto.png"
img.save(out)
print("saved", out, img.size)

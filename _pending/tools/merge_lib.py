"""Merge a new gun family's LIVE parts into RS_VR_Weapons: class file, zscript include,
MODELDEF blocks, CVARINFO sets, MENUDEF pages, build.ps1 prefix and verify list.

Every edit is anchored and must match exactly once; nothing is written unless every
anchor matched. Line endings are kept per file. menu_lint then runs with build.ps1's own
--prefix, read back from the file after the patch.
"""
import os
import re
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8")
ROOT = "E:/DOOMWork/RS_VR_Weapons/"
PY = sys.executable
LINT = r"E:\DOOMWork\tools\menu_lint.py"


class Patch:
    def __init__(self):
        self.files = {}
        self.new = {}

    def need(self, *rels):
        for r in rels:
            if not os.path.isfile(ROOT + r):
                raise SystemExit("missing " + r)

    def get(self, rel):
        if rel not in self.files:
            s = open(ROOT + rel, "rb").read().decode("utf-8")
            nl = "\r\n" if "\r\n" in s else "\n"
            self.files[rel] = [s.replace("\r\n", "\n"), nl]
        return self.files[rel]

    def rep(self, rel, old, new):
        f = self.get(rel)
        c = f[0].count(old)
        if c != 1:
            raise SystemExit(rel + ": anchor count " + str(c) + ": " + old[:80])
        f[0] = f[0].replace(old, new)

    def after_block(self, rel, header, text):
        f = self.get(rel)
        c = f[0].count(header)
        if c != 1:
            raise SystemExit(rel + ": header count " + str(c) + ": " + header)
        a = f[0].find(header)
        b = f[0].find("\n}\n", a)
        if b < 0:
            raise SystemExit(rel + ": no closing brace after " + header)
        b += 3
        f[0] = f[0][:b] + text + f[0][b:]

    def append(self, rel, text, guard):
        f = self.get(rel)
        if guard in f[0]:
            raise SystemExit(rel + " already has " + guard)
        if not f[0].endswith("\n"):
            f[0] += "\n"
        f[0] += text

    def newfile(self, rel, text):
        if os.path.exists(ROOT + rel):
            raise SystemExit(rel + " exists")
        self.new[rel] = text

    def commit(self):
        for rel, text in self.new.items():
            open(ROOT + rel, "wb").write(text.encode("utf-8"))
            print("ok", rel, "(new)")
        for rel, (s, nl) in self.files.items():
            open(ROOT + rel, "wb").write(s.replace("\n", nl).encode("utf-8"))
            print("ok", rel)


def cvar_set(stem, header):
    keys = [("ofs_x", "0.0"), ("ofs_y", "0.0"), ("ofs_z", "0.0"), ("yaw", "-90.0"), ("pitch", "0.0"),
            ("roll", "0.0"), ("scale", "1.0"), ("scale_x", "1.0"), ("scale_y", "1.0"), ("scale_z", "1.0")]
    out = "\n" + header + "\n// Every default an ESTIMATE: not yet seen on a controller.\n"
    w = len(stem) + 8
    for k, v in keys:
        name = stem + "_" + k
        out += "user float " + name.ljust(w) + " = " + v + ";\n"
    return out


def slider_page(page, title, stem, links):
    t = "\t"
    rows = [
        ("Left / right",   "ofs_x", "-100.0, 100.0, 0.25, 2"),
        ("Forward / back", "ofs_y", "-100.0, 100.0, 0.25, 2"),
        ("Down / up",      "ofs_z", "-100.0, 100.0, 0.25, 2"),
        ("Yaw",            "yaw",   "-180, 180, 1, 0"),
        ("Pitch",          "pitch", "-180, 180, 1, 0"),
        ("Roll",           "roll",  "-180, 180, 1, 0"),
        ("Size",           "scale", "0.05, 4.0, 0.01, 2"),
    ]
    axis = [("Size along X", "scale_x"), ("Size along Y", "scale_y"), ("Size along Z", "scale_z")]
    s = "\n// LINT-LIVE: " + page + "\nOptionMenu \"" + page + "\"\n{\n"
    s += t + "Title \"" + title + "\"\n"
    s += t + "StaticText \"WHERE IT SITS ON YOUR CONTROLLER -- MOVES LIVE\", \"Gold\"\n"
    for label, key, rng in rows:
        s += t + "Slider " + ("\"" + label + "\",").ljust(17) + " \"" + stem + "_" + key + "\", " + rng + "\n"
    s += t + "StaticText \"\"\n"
    s += t + "StaticText \"SIZE ON ONE AXIS -- MOVES LIVE\", \"Gold\"\n"
    for label, key in axis:
        s += t + "Slider " + ("\"" + label + "\",").ljust(17) + " \"" + stem + "_" + key + "\", 0.05, 3.0, 0.01, 2\n"
    s += t + "StaticText \"Above zero only -- the renderer ignores zero and below.\", \"DarkGray\"\n"
    s += t + "StaticText \"\"\n"
    for label, target in links:
        s += t + "Submenu \"" + label + "\", \"" + target + "\"\n"
    s += "}\n"
    return s


def add_prefix(patch, after_stem, stems):
    patch.rep("build.ps1", "," + after_stem + ",", "," + after_stem + "," + ",".join(stems) + ",")


def verify_lines(paths):
    return "          " + ",".join("'" + p + "'" for p in paths) + ",\n"


def lint():
    b = open(ROOT + "build.ps1", encoding="utf-8").read()
    m = re.search(r"--prefix '([^']+)'", b)
    if not m:
        raise SystemExit("no --prefix in build.ps1")
    cmd = [PY, LINT, r"E:\DOOMWork\RS_VR_Weapons", "--prefix", m.group(1),
           "--dep", r"E:\DOOMWork\RS_VR_Reload", "--dep", r"E:\DOOMWork\UZDXREMA\wadsrc\static"]
    r = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="replace")
    print(r.stdout.strip())
    if r.stderr.strip():
        print(r.stderr.strip())
    print("lint exit", r.returncode)
    return r.returncode

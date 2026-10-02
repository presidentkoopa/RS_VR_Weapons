#!/usr/bin/env python3
"""Does every engine member this mod touches actually exist in the engine it RUNS on?

Build 55 used PSprite.NoDraw. That field exists in E:/DOOMWork/QZD17-engine -- our own modified copy
of the engine -- and not in the stock QuestZDoom 17.3 the saber actually runs on. The load died with
"Unknown identifier 'NoDraw'" before a map opened, and nothing offline had caught it, because the
check had been run against the wrong tree.

This reads the ENGINE THE MOD RUNS ON, collects every member name declared anywhere in its ZScript,
collects every member name the mod declares for itself, and reports every `.Something` the mod
touches that neither of them declares. It is deliberately dumb: it over-reports rather than miss one,
because a miss is a load failure in a headset and a false positive is one line to read.

    python check_engine_members.py <mod.pk3> [engine dir or pk3 ...]

Default engine: the stock QuestZDoom the saber is played on, NOT E:/DOOMWork/QZD17-engine.
"""
import os
import re
import sys
import zipfile

STOCK = r"C:\Users\Command\Desktop\qzdoom-17-3-Windows-64bit"

# Declarations, in the engine's ZScript and in the mod's own.
DECL = [
    re.compile(r"\bnative\s+(?:readonly\s+)?(?:play\s+|ui\s+|clearscope\s+|static\s+|meta\s+)*"
               r"[\w<>,\s\[\]]+?\b(\w+)\s*(?:\[[^\]]*\])?\s*[;(]"),
    re.compile(r"^\s*(?:readonly\s+)?(?:private\s+|protected\s+|meta\s+|transient\s+)*"
               r"(?:int|uint|double|float|bool|String|Name|Vector2|Vector3|Actor|Class|Sound|"
               r"TextureID|SpriteID|Color|StateLabel|State|PlayerInfo|PSprite|Object|Array<[^>]+>|"
               r"[A-Z]\w+)\s+(\w+)\s*(?:\[[^\]]*\])?\s*[;,=]", re.M),
    re.compile(r"\b(?:virtual\s+|override\s+|static\s+|action\s+|clearscope\s+|play\s+|ui\s+|"
               r"protected\s+|private\s+|native\s+)*[\w<>,\s\[\]]+?\b(\w+)\s*\([^;{]*\)\s*(?:const\s*)?[{;]"),
    re.compile(r"^\s*(\w+)\s*(?:=\s*[^,;]+)?\s*,\s*$", re.M),          # enum members
    re.compile(r"^\s*const\s+(\w+)\s*=", re.M),
    re.compile(r"^\s*(?:class|struct|enum)\s+(\w+)", re.M),
]

USE = re.compile(r"\.\s*([A-Za-z_]\w*)")

SKIP_LINE = re.compile(r"^\s*//")


def strip_comments(t):
    t = re.sub(r"/\*.*?\*/", " ", t, flags=re.S)
    return "\n".join("" if SKIP_LINE.match(l) else re.sub(r"//.*$", "", l) for l in t.split("\n"))


def zscript_of(path):
    """Every .zs / .txt ZScript source in a pk3 or a directory tree."""
    out = []
    if os.path.isdir(path):
        for root, _d, files in os.walk(path):
            for f in files:
                if f.lower().endswith((".zs", ".zsc")) or f.lower() == "zscript.txt":
                    try:
                        out.append(open(os.path.join(root, f), encoding="utf-8",
                                        errors="replace").read())
                    except OSError:
                        pass
        for f in os.listdir(path):
            if f.lower().endswith(".pk3"):
                out += zscript_of(os.path.join(path, f))
        return out
    if zipfile.is_zipfile(path):
        z = zipfile.ZipFile(path)
        for n in z.namelist():
            if n.lower().endswith((".zs", ".zsc")) or n.split("/")[-1].lower() == "zscript.txt":
                out.append(z.read(n).decode("utf-8", "replace"))
    return out


def declared(sources):
    names = set()
    for t in sources:
        t = strip_comments(t)
        for rx in DECL:
            names.update(rx.findall(t))
    return names


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    mod = sys.argv[1]
    engines = sys.argv[2:] or [STOCK]

    mod_src = zscript_of(mod)
    if not mod_src:
        sys.exit("no ZScript found in %s" % mod)
    eng_src = []
    for e in engines:
        got = zscript_of(e)
        print("engine: %-62s %3d source(s)" % (e, len(got)))
        eng_src += got
    if not eng_src:
        sys.exit("no ZScript found in the engine path(s) -- check the path")

    known = declared(eng_src) | declared(mod_src)
    used = set()
    for t in mod_src:
        used.update(USE.findall(strip_comments(t)))

    unknown = sorted(n for n in used - known if not n[0].isdigit())
    print("\nmod: %s" % mod)
    print("  %d distinct members touched, %d declared somewhere" % (len(used), len(used) - len(unknown)))
    if not unknown:
        print("\n  OK -- every member the mod touches is declared in the engine it runs on.")
        return
    print("\n  NOT DECLARED ANYWHERE (%d) -- each is a load failure if it is a real member access:" % len(unknown))
    for n in unknown:
        for t in mod_src:
            for i, line in enumerate(strip_comments(t).split("\n")):
                if re.search(r"\.\s*" + re.escape(n) + r"\b", line):
                    print("    %-28s line %5d  %s" % (n, i + 1, line.strip()[:92]))
                    break
            else:
                continue
            break
    sys.exit(1)


if __name__ == "__main__":
    main()

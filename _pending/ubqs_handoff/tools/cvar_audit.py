#!/usr/bin/env python3
"""Every cvar in the pack, and whether it actually does what its menu row promises.

Three bugs of this family turned up in one evening:
  ubqs_glow_stub          declared, menued, read by nothing after the nub was removed in code
  rs_saber_throw_damage   declared, menued, accessor written, zero callers, while the thing it
                          scaled was pinned at maximum
  ubqs_throw              declared, menued "Thrown saber", default 0 -- and read ONLY inside the
                          already-flying saber, so turning it off did not stop the throw, it only
                          told the escaped saber to come home. The saber flew out on every release.

The third is the one a dead-cvar check misses: the cvar IS read, so it is not dead. It is read in the
wrong place. So this prints the read SITES, not just a count, and flags every cvar read exactly once
for a human to look at -- that is the shape the bug takes.

    python cvar_audit.py <pk3>
"""
import re
import sys
import zipfile

# ANY quoted occurrence of a declared name, anywhere in the script. The accessor is reached in several
# shapes -- UF("x", d), UInt(off ? "x" : "y", d), UBQS_Data.F(target, "x", d) -- and a regex that tries
# to match the CALL misses most of them: the first version of this tool reported 31 dead cvars and
# every single one was a false positive. Match the NAME, not the call. Over-reporting a cvar as live is
# the safe direction: it costs a look, where a false "dead" costs a working feature.
READ = re.compile(r'"(\w+)"')
DECL = re.compile(r'^\s*(user|server|nosave)\s+(\w+)\s+(\w+)\s*=\s*([^;]+);', re.M)
MENU = re.compile(r'^\s*(Option|Slider)\s+"[^"]*",\s*"(\w+)"', re.M)


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    z = zipfile.ZipFile(sys.argv[1])
    cv = z.read("CVARINFO").decode("utf-8")
    mn = z.read("MENUDEF").decode("utf-8")
    zs = z.read("zscript.txt").decode("utf-8")
    lines = zs.split("\n")

    declared = {m.group(3): (m.group(1), m.group(4).strip()) for m in DECL.finditer(cv)}
    menued = {m.group(2) for m in MENU.finditer(mn)}

    sites = {}
    for i, line in enumerate(lines):
        if line.strip().startswith("//"):
            continue
        for name in READ.findall(line):
            sites.setdefault(name, []).append((i + 1, line.strip()))

    print("%d cvars declared, %d in the menu, %d read somewhere in the script"
          % (len(declared), len(menued), len(sites)))

    dead = sorted(n for n in declared if n not in sites)
    if dead:
        print("\nDEAD -- declared and read by NOTHING (%d):" % len(dead))
        for n in dead:
            print("    %-26s = %-8s %s" % (n, declared[n][1], "IN THE MENU" if n in menued else ""))

    ghost = sorted(menued - set(declared))
    if ghost:
        print("\nMENUED BUT NOT DECLARED (%d) -- the row does nothing:" % len(ghost))
        for n in ghost:
            print("    %s" % n)

    hidden = sorted(n for n in declared if n not in menued and n in sites)
    if hidden:
        print("\nWORKS BUT HAS NO MENU ROW (%d) -- console only:" % len(hidden))
        print("    " + ", ".join(hidden))

    once = sorted(n for n in declared if len(sites.get(n, [])) == 1)
    if once:
        print("\nREAD EXACTLY ONCE (%d) -- LOOK AT EACH: this is the shape the ubqs_throw bug took,"
              % len(once))
        print("a cvar that is read, so not dead, but read somewhere that cannot keep its promise.")
        for n in once:
            ln, txt = sites[n][0]
            row = " [menu]" if n in menued else ""
            print("    %-26s = %-7s line %-5d %s%s" % (n, declared[n][1], ln, txt[:78], row))


if __name__ == "__main__":
    main()

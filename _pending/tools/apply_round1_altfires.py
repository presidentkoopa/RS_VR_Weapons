"""VANILLA+ ROUND 1 ALT FIRES, ON THE WEAPON CARDS -- run the moment RS_VR_Reload's sheet reader accepts the keys (the
reload lane's "keys in"). The owner, 09-15: "JUST PUT THE SHIT ON THE CARDS".

Adds, inside each gun's own `gun` block (verified after writing):
  pistols (Vanilla+ Pistol, Black Handgun, Blue Handgun)  altmode burst, altburst 3, altbursttics 4
  Rifle, M16                                              altmode selectfire, altburst 3
  SMG, Tec9                                               altmode shred, altratescale 2
  Steelgun, Shotgun (Vanilla+)                            altmode slamfire
  Super Shotgun (Vanilla+)                                altmode onebarrel
  Quad Super (Vanilla+)                                   altmode doubleshell, altdamagescale 2
  Moonlight, Sunset, Cola Revolver                        altmode fan, altfanmax 8
  every Vanilla+ gun in these files                       spreadshape cone
And teaches card_lint --sheets the same keys. Then build, check, install, push. Run from the RS_VR_Weapons root."""
import io
import re

ALT = {
    "WM_VP_M4A3": [("altmode", "burst"), ("altburst", "3"), ("altbursttics", "4")],
    "WM_VP_Pistolet": [("altmode", "burst"), ("altburst", "3"), ("altbursttics", "4")],
    "WM_PistoletBlue": [("altmode", "burst"), ("altburst", "3"), ("altbursttics", "4")],
    "WM_Rifle": [("altmode", "selectfire"), ("altburst", "3")],
    "WM_M16": [("altmode", "selectfire"), ("altburst", "3")],
    "WM_SMG": [("altmode", "shred"), ("altratescale", "2")],
    "WM_Tec9": [("altmode", "shred"), ("altratescale", "2")],
    "WM_VP_PumpM37": [("altmode", "slamfire")],
    "WM_VP_PumpDoom": [("altmode", "slamfire")],
    "WM_VP_SSG": [("altmode", "onebarrel")],
    # doubleshell scales damage only when the sheet states shotdamage; buckshot's ballistics roll 5 x 1d3, so 5-15.
    "WM_VP_BullpupPump": [("altmode", "doubleshell"), ("altdamagescale", "2"), ("shotdamage", "5, 15")],
    "WM_Moonlight": [("altmode", "fan"), ("altfanmax", "8")],
    "WM_Sunset": [("altmode", "fan"), ("altfanmax", "8")],
    "WM_ColaRevolver": [("altmode", "fan"), ("altfanmax", "8")],
}
import glob
# "All Vanilla+ gunfire" gets the cone: every Vanilla+ Weapon Card file.
FILES = sorted(glob.glob("WMSHEET.plus_*"))
NEW_KEYS = {"altmode", "altburst", "altbursttics", "altratescale", "altdamagescale", "altfanmax", "spreadshape"}
EXTRA_GUNS = {"WM_SMG", "WM_Tec9", "WM_Flamer", "WM_Flamethrower"}   # no Weapon Card yet: given one here (class numbers stay)

# ---- the SMGs get a Weapon Card of their own (their numbers stay their class Defaults)
p = "WMSHEET.plus_extras"
s = io.open(p, encoding="utf-8", newline="").read()
for gun in sorted(EXTRA_GUNS):
    if f'gun "{gun}"' not in s:
        s = s.rstrip("\n") + f'\n\ngun "{gun}"\nend\n'
io.open(p, "w", encoding="utf-8", newline="\n").write(s)

done = set()
for fn in FILES:
    s = io.open(fn, encoding="utf-8", newline="").read()
    nl = "\r\n" if "\r\n" in s else "\n"
    for m in list(re.finditer(r'^gun "(\w+)"\r?\n.*?^end\r?\n', s, re.M | re.S)):
        gun = m.group(1)
        blk = m.group(0)
        keys = list(ALT.get(gun, [])) + [("spreadshape", "cone")]
        add = "".join(f"  {k:<20} = {v}{nl}" for k, v in keys if not re.search(r"^  " + k + r"\s*=", blk, re.M))
        if not add:
            done.add(gun)
            continue
        closing = re.search(r"^end\r?\n\Z", blk, re.M)
        new = blk[:closing.start()] + add + blk[closing.start():]
        s = s.replace(blk, new, 1)
        done.add(gun)
    io.open(fn, "w", encoding="utf-8", newline="").write(s)
    print("wrote", fn)

# ---- verify in the files
text = "\n".join(io.open(f, encoding="utf-8").read() for f in FILES)
for gun, keys in ALT.items():
    blk = re.search(r'^gun "' + gun + r'"\n.*?^end', text, re.M | re.S)
    assert blk, gun
    for k, v in keys + [("spreadshape", "cone")]:
        assert re.search(r"^  " + k + r"\s*=\s*" + re.escape(v) + r"\s*$", blk.group(0), re.M), (gun, k)
print("verified: every round-1 gun carries its alt fire, and spreadshape cone")

# ---- card_lint learns the keys
p = "_pending/card_lint.py"
s = io.open(p, encoding="utf-8", newline="").read()
old = '"firesound", "model", "spinuptics", "spindowntics"}'
if '"altmode"' not in s:
    assert s.count(old) == 1
    s = s.replace(old, '"firesound", "model", "spinuptics", "spindowntics",\n'
                  '                  "altmode", "altburst", "altbursttics", "altratescale", "altdamagescale", "altfanmax", "spreadshape"}')
    io.open(p, "w", encoding="utf-8", newline="").write(s)
print("card_lint --sheets knows the round-1 alt-fire keys")

"""RS_VR_Weapons -- THE GUN CLASS WRITER.

A gun is its Weapon Card (a WMSHEET file): which Model Card it uses and what it shoots. The engine still needs a small
ZScript class per gun for what it reads at startup, before any card loads -- its name, slot, selection order, ammo,
which hand, pickup message. This writes those classes from each Weapon Card's `class` block, so a new gun is only its
card (the owner, 09-14: "a weapon card can be called anything and we could assign it to the RailGun or a Shotgun").

    gun "WM_LaserPistol"
      model = WM_M4A3            # the reload lane's reader: which Model Card
      class                      # read HERE only; the reader skips it
        slot           = 2
        selectionorder = 1900
        ammo           = "Cell"
        hand           = off     # main | off
        name           = "Laser Pistol"
        pickupmessage  = "Laser Pistol"
      end
      firetics = 10
      ...
    end

Writes zscript/rs_vr_weapons/generated_guns.zs (always, a header alone when no card has a `class` block). A gun with
special code (the Unmaker, the flamers, the Vanilla set's own classes) keeps its handwritten class and no `class` block;
a name in both places is refused. Run by build.ps1 before it packs; exits 1 on any refusal.

    python make_gun_classes.py [--root DIR] [--out FILE]
"""
import io
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))          # _pending/tools -> the package root
KEYS = {
    "slot": "int", "selectionorder": "int", "maxamount": "int",
    "ammo": "str", "name": "str", "pickupmessage": "str", "upsound": "str", "readysound": "str", "pickupsound": "str",
    "hand": "hand",
}


def arg(flag, default):
    return sys.argv[sys.argv.index(flag) + 1] if flag in sys.argv and sys.argv.index(flag) + 1 < len(sys.argv) else default


def zs_string(v):
    v = v.strip()
    if len(v) >= 2 and v[0] == '"' and v[-1] == '"':
        v = v[1:-1]
    return '"' + v.replace("\\", "\\\\").replace('"', '\\"') + '"'


def main():
    root = arg("--root", ROOT)
    out = None   # resolved below, once --sheets is known
    errors, guns = [], []

    # WHICH SHEETS THIS RUN IS FOR. The Vanilla+ guns ship in their own add-on pk3 now, so their
    # classes have to be written to their own lump -- a class defined in both archives would be a
    # fatal, global load error the moment the two were loaded together (2026-09-18).
    #   --sheets base   every sheet EXCEPT WMSHEET.plus_*      -> the base pk3
    #   --sheets plus   only WMSHEET.plus_*                    -> the add-on
    #   --sheets all    every sheet (the old behaviour, kept for one-pk3 builds)
    which = arg("--sheets", "all").lower()
    assert which in ("all", "base", "plus", "bwolf", "ww2"), "--sheets is all, base, plus, bwolf or ww2"

    OUTS = {"plus":  ("rs_vr_weapons_plus",  "generated_guns_plus.zs"),
            "bwolf": ("rs_vr_weapons_bwolf", "generated_guns_bwolf.zs"),
            "ww2":   ("rs_vr_weapons_ww2",   "generated_guns_ww2.zs")}
    # A SET NAME MISSING FROM THIS TABLE FALLS THROUGH TO THE BASE'S OUTPUT AND OVERWRITES IT --
    # silently, because writing a file is not an error. During the BWolf/WW2 rename these keys were
    # briefly right in their values and wrong in their names, and one run wrote eighteen WW2 guns
    # over the base pack's thirty-five. Refuse instead: a set this does not know is a mistake.
    if which not in ("all", "base") and which not in OUTS:
        sys.exit("--sheets %s: no output folder for that set. Add it to OUTS rather than letting it "
                 "fall through to the base pack's generated_guns.zs, which it would overwrite." % which)
    sub, fn = OUTS.get(which, ("rs_vr_weapons", "generated_guns.zs"))
    default_out = os.path.join(root, "zscript", sub, fn)
    out = arg("--out", default_out)
    os.makedirs(os.path.dirname(out), exist_ok=True)

    def wanted(n):
        u = n.upper()
        isplus = u.startswith("WMSHEET.PLUS_")
        isbwolf = u == "WMSHEET.BWOLF"
        isww2  = u == "WMSHEET.WW2"
        if which == "all":  return True
        if which == "plus": return isplus
        if which == "bwolf": return isbwolf
        if which == "ww2":  return isww2
        # base: everything that is not another set's. A NEW SET MUST BE ADDED HERE TOO, or its
        # sheet falls into the base pack and the same class ships in two archives -- which is a
        # fatal, global load error the moment both are loaded.
        return not (isplus or isbwolf or isww2)

    sheet_files = sorted(n for n in os.listdir(root)
                         if n.upper().startswith("WMSHEET.") and os.path.isfile(os.path.join(root, n))
                         and wanted(n))
    for fn in sheet_files:
        gun, depth, cls = None, 0, None
        for n, raw in enumerate(io.open(os.path.join(root, fn), encoding="utf-8"), 1):
            s = raw.split("#")[0].strip()
            if not s:
                continue
            m = re.match(r'gun\s+"(\w+)"\s*$', s)
            if m:
                gun, depth, cls = m.group(1), 1, None
                continue
            if gun is None:
                continue
            if s == "end":
                if cls is not None and depth == 2:
                    guns.append((gun, cls))
                    cls = None
                depth -= 1
                if depth == 0:
                    gun = None
                continue
            if depth == 1 and s == "class":
                cls, depth = {"_where": f"{fn} line {n}"}, 2
                continue
            if depth == 1 and re.match(r"\w+\s+\w+\s*$", s) and "=" not in s:   # another sub-block (`barrel <id>`)
                depth = 2
                continue
            if cls is not None:
                km = re.match(r"(\w+)\s*=\s*(.+?)\s*$", s)
                key = km.group(1).lower() if km else None
                if not km or key not in KEYS:
                    errors.append(f"{fn} line {n}: `{s}` is not a class key -- the keys are {', '.join(KEYS)}")
                    continue
                val, kind = km.group(2), KEYS[key]
                if kind == "int" and not re.fullmatch(r"-?\d+", val):
                    errors.append(f"{fn} line {n}: `{key}` needs a whole number, not {val}")
                elif kind == "hand" and val.lower() not in ("main", "off"):
                    errors.append(f"{fn} line {n}: `hand` is main or off, not {val}")
                elif key == "slot" and not (0 <= int(val) <= 9):
                    errors.append(f"{fn} line {n}: `slot` is 0 to 9, not {val}")
                else:
                    cls[key] = val

    # A name written here AND by hand is refused: one class per gun.
    handwritten = set()
    zdir = os.path.join(root, "zscript", "rs_vr_weapons")
    if os.path.isdir(zdir):
        for zf in os.listdir(zdir):
            if zf.endswith(".zs") and zf != os.path.basename(out):
                text = io.open(os.path.join(zdir, zf), encoding="utf-8").read()
                handwritten.update(re.findall(r"^class\s+(\w+)", text, re.M))
    seen = set()
    for gun, cls in guns:
        if gun in handwritten:
            errors.append(f"{cls['_where']}: {gun} already has a handwritten class -- give the card no `class` block, or remove the class")
        if gun in seen:
            errors.append(f"{cls['_where']}: a second `class` block for {gun}")
        seen.add(gun)
        # AMMO IS OPTIONAL. A melee weapon has none -- Doom's own fist and chainsaw declare no
        # AmmoType1 either -- so demanding one would put a clip on every knife in every set.
        if "slot" not in cls:
            errors.append(f"{cls['_where']}: {gun}'s `class` block needs at least `slot`")

    if errors:
        for e in errors:
            print("make_gun_classes: REFUSED " + e)
        return 1

    lines = [
        "// ============================================================================",
        "// GENERATED -- DO NOT EDIT. Written by _pending/tools/make_gun_classes.py from the Weapon Cards' `class` blocks",
        "// (WMSHEET.*) on every build. Change the card, then build. A gun with no `class` block keeps its handwritten",
        "// class. What a gun shoots is its Weapon Card's, applied at load and spawn by the reload system's reader.",
        "// ============================================================================",
    ]
    for gun, cls in guns:
        lines += ["", f"// {cls['_where']}", f"class {gun} : WM_Gun", "{", "\tDefault", "\t{"]
        if cls.get("hand", "main").lower() == "off":
            lines.append("\t\t+WEAPON.OFFHANDWEAPON")
        lines.append(f"\t\tWeapon.SlotNumber {cls['slot']};")
        if "selectionorder" in cls:
            lines.append(f"\t\tWeapon.SelectionOrder {cls['selectionorder']};")
        if cls.get("ammo"):
            lines.append(f"\t\tWeapon.AmmoType1 {zs_string(cls['ammo'])};")
        if "name" in cls:
            lines.append(f"\t\tTag {zs_string(cls['name'])};")
        if "pickupmessage" in cls:
            lines.append(f"\t\tInventory.PickupMessage {zs_string(cls['pickupmessage'])};")
        if "pickupsound" in cls:
            lines.append(f"\t\tInventory.PickupSound {zs_string(cls['pickupsound'])};")
        if "maxamount" in cls:
            lines.append(f"\t\tInventory.MaxAmount {cls['maxamount']};")
        if "upsound" in cls:
            lines.append(f"\t\tWeapon.UpSound {zs_string(cls['upsound'])};")
        if "readysound" in cls:
            lines.append(f"\t\tWeapon.ReadySound {zs_string(cls['readysound'])};")
        lines += ["\t}", "}"]
    io.open(out, "w", encoding="utf-8", newline="\n").write("\n".join(lines) + "\n")
    print(f"make_gun_classes: {len(guns)} gun class(es) from {len(sheet_files)} Weapon Card file(s) -> {os.path.relpath(out, root)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

"""Make gun families LIVE in RS_VR_Weapons: card into WMCARD.txt, the class's pending lines
into its Default block, StartItems and starting ammo, weapon slots, the "into your hands"
netevent, its KEYCONF alias and its row on the new-families menu page.

GATED ON THE RELOAD SOURCE. A family goes live only when RS_VR_Reload's parser.zs /
weapon.zs actually contain every key and property its card and class lines use -- an
unknown card key rejects the card, an unknown property is a fatal load error. The gate reads
source, not a build: the builder still compile-checks.

    python merge_live.py --check [family ...]     report readiness, write nothing
    python merge_live.py --dry [family ...]       run every edit in memory, write nothing
    python merge_live.py family [family ...]      apply the ready ones (refuses a family that is not)
    --interim-onehanded   drop `hands = 2` from a card when the parser has no `hands` key yet

Families: plasma railgun chaingun machinegun launchers bfg chainsaws flamers
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from merge_lib import Patch, lint, ROOT

RELOAD = "E:/DOOMWork/RS_VR_Reload/"


def src(path):
    return open(path, encoding="utf-8").read()


PARSER = src(RELOAD + "zscript/wm/parser.zs")
WEAPON = src(RELOAD + "zscript/wm/weapon.zs")

HAVE = {
    "firesfrom": 'key == "firesfrom"' in PARSER,
    "casing": 'key == "casing"' in PARSER,
    "hands": 'key == "hands"' in PARSER,
    "ShotClass": bool(re.search(r"property\s+ShotClass\s*:", WEAPON)),
    "RoundsPerShot": bool(re.search(r"property\s+RoundsPerShot\s*:", WEAPON)),
    "ShotRail": bool(re.search(r"property\s+ShotRail\s*:", WEAPON)),
    "ChargeTics": bool(re.search(r"property\s+ChargeTics\s*:", WEAPON)),
    "ChargeSound": bool(re.search(r"property\s+ChargeSound\s*:", WEAPON)),
    "ShotSaw": bool(re.search(r"property\s+ShotSaw\s*:", WEAPON)),
    "SawSounds": bool(re.search(r"property\s+SawSounds\s*:", WEAPON)),
    "FireHeld": bool(re.search(r"virtual\s+void\s+FireHeld\s*\(", WEAPON)),
    # the second-barrel grammar (uzdxrema-11's names, 2026-09-13): its `shotclass` key and the
    # `altfire` input word, both only in a parser that reads a `barrel` block
    "G-UBL": 'key == "shotclass"' in PARSER and '"altfire"' in PARSER,
}

# ------------------------------------------------------------------ the families
FAMILIES = {
    "plasma": {
        "doc": "PLASMA_CARDS.md", "file": "plasma.zs", "slot": 9,
        "requires": ["firesfrom", "casing", "ShotClass"],
        "classes": [
            ("WM_PlasmaRifle", 0, 'Tag "Plasma Rifle";', ['Weapon.AmmoType1 "Cell";', 'WM_Gun.ShotClass "PlasmaBall";']),
            ("WM_PlasmaCarbine", 1, 'Tag "Plasma Carbine";', ['Weapon.AmmoType1 "Cell";', 'WM_Gun.ShotClass "PlasmaBall";']),
        ],
        "ammo": ("Cell", 100), "event": "wm_giveplasma",
        "row": "Plasma rifle and plasma carbine into your hands (and 100 cells)",
        "said": "plasma rifle main, plasma carbine off",
    },
    "railgun": {
        "doc": "RAILGUN_CARDS.md", "file": "railguns.zs", "slot": 9,
        "requires": ["firesfrom", "casing", "ShotRail", "RoundsPerShot", "hands"],
        "classes": [
            ("WM_Railgun", 0, 'Tag "Railgun";', ['Weapon.AmmoType1 "Cell";', 'WM_Gun.ShotRail true;', 'WM_Gun.RoundsPerShot 10;']),
        ],
        "ammo": ("Cell", 100), "event": "wm_giverailgun",
        "row": "Railgun into the main hand (and 100 cells)",
        "said": "railgun main",
    },
    "chaingun": {
        "doc": "CHAINGUN_CARDS.md", "file": "chainguns.zs", "slot": 7,
        "requires": ["firesfrom", "hands"],
        "classes": [
            ("WM_Chaingun", 0, 'Tag "Chaingun";', ['Weapon.AmmoType1 "Clip";']),
        ],
        "ammo": ("Clip", 100), "event": "wm_givechaingun",
        "row": "Chaingun into the main hand (and 100 rounds)",
        "said": "chaingun main",
    },
    "machinegun": {
        "doc": "MACHINEGUN_UBL.md", "file": "chainguns.zs", "slot": 7,
        "requires": ["firesfrom", "hands", "G-UBL"],
        "classes": [
            ("WM_MachineGun", 1, 'Tag "Machine Gun";', ['Weapon.AmmoType1 "Clip";']),
        ],
        "ammo": ("Clip", 100), "event": "wm_givemachinegun",
        "row": "Machine gun into the off hand (and 100 rounds, 6 grenades with RS Grenade)",
        "said": "machine gun off",
        "grenades": 6,
    },
    "launchers": {
        "doc": "ROCKET_CARDS.md", "file": "launchers.zs", "slot": 8,
        "requires": ["firesfrom", "casing", "ShotClass", "hands"],
        "classes": [
            ("WM_RocketLauncher", 0, 'Tag "Rocket Launcher";', ['Weapon.AmmoType1 "RocketAmmo";', 'WM_Gun.ShotClass "Rocket";']),
            ("WM_RPG", 1, 'Tag "RPG";', ['Weapon.AmmoType1 "RocketAmmo";', 'WM_Gun.ShotClass "Rocket";']),
        ],
        "ammo": ("RocketAmmo", 12), "event": "wm_givelaunchers",
        "row": "Rocket launcher and RPG into your hands (and 12 rockets)",
        "said": "rocket launcher main, RPG off",
    },
    "bfg": {
        "doc": "BFG_CARDS.md", "file": "bfg.zs", "slot": 0,
        "requires": ["firesfrom", "casing", "ShotClass", "RoundsPerShot", "ChargeTics", "ChargeSound", "hands"],
        "classes": [
            ("WM_BFG", 0, 'Tag "BFG";', ['Weapon.AmmoType1 "Cell";', 'WM_Gun.RoundsPerShot 40;', 'WM_Gun.ShotClass "BFGBall";',
                                        'WM_Gun.ChargeTics 30;', 'WM_Gun.ChargeSound "wm/bfg/charge";']),
            ("WM_BFGHeavy", 1, 'Tag "Heavy BFG";', ['Weapon.AmmoType1 "Cell";', 'WM_Gun.RoundsPerShot 40;', 'WM_Gun.ShotClass "BFGBall";',
                                                 'WM_Gun.ChargeTics 30;', 'WM_Gun.ChargeSound "wm/bfg/charge";']),
        ],
        "ammo": ("Cell", 320), "event": "wm_givebfg",
        "row": "BFG and heavy BFG into your hands (and 320 cells)",
        "said": "BFG main, heavy BFG off",
    },
    "chainsaws": {
        "doc": "CHAINSAW_CARDS.md", "file": "chainsaws.zs", "slot": 1,
        "requires": ["firesfrom", "casing", "ShotSaw", "SawSounds"],
        "classes": [
            ("WM_Chainsaw", 0, 'Tag "Chainsaw";', ['WM_Gun.ShotSaw true;', 'WM_Gun.SawSounds "wm/saw/loop", "wm/saw/hit";',
                                                'Weapon.ReadySound "wm/saw/idle";', 'Weapon.UpSound "wm/saw/start";']),
            ("WM_ChainsawHeavy", 1, 'Tag "Heavy Chainsaw";', ['WM_Gun.ShotSaw true;', 'WM_Gun.SawSounds "wm/saw/loop", "wm/saw/hit";',
                                                          'Weapon.ReadySound "wm/saw/idle";', 'Weapon.UpSound "wm/saw/start";']),
        ],
        "ammo": None, "event": "wm_givechainsaws",
        "row": "Chainsaw and heavy chainsaw into your hands",
        "said": "chainsaw main, heavy chainsaw off",
    },
    "flamers": {
        "doc": "FLAMER_CARDS.md", "file": "flamers.zs", "slot": 0,
        "requires": ["firesfrom", "casing", "ShotClass", "FireHeld"],
        "classes": [
            ("WM_Flamer", 0, 'Tag "Flamer";', ['Weapon.AmmoType1 "Cell";', 'WM_Gun.ShotClass "WM_FlameShot";']),
            ("WM_Flamethrower", 1, 'Tag "Flamethrower";', ['Weapon.AmmoType1 "Cell";', 'WM_Gun.ShotClass "WM_NapalmShot";']),
        ],
        "ammo": ("Cell", 200), "event": "wm_giveflamers",
        "row": "Flamer and flamethrower into your hands (and 200 cells)",
        "said": "flamer main, flamethrower off",
    },
}
STAWW2_AMMO = {"Cell": 300, "RocketAmmo": 20}   # added once, the first time a family needs them


def ready(fam):
    return [r for r in FAMILIES[fam]["requires"] if not HAVE.get(r)]


def card_block(doc, cls):
    text = src(ROOT + "_pending/" + doc)
    for block in re.findall(r"```[a-z]*\n(.*?)```", text, re.S):
        if re.search(r'^weapon "' + re.escape(cls) + r'"\s*$', block, re.M):
            return block
    raise SystemExit(f"{doc}: no card block for {cls}")


def clean_card(block, onehanded):
    out = []
    for line in block.split("\n"):
        if "GRAMMAR PENDING" in line:
            stripped = line.strip()
            if stripped.startswith("#"):
                rest = re.sub(r"GRAMMAR PENDING(\s*\([^)]*\))?\s*:?\s*", "", stripped[1:]).strip()
                if not rest:
                    continue
                line = line[:len(line) - len(line.lstrip())] + "# " + rest
            else:
                line = line.split("#")[0].rstrip()
        if onehanded and re.match(r"^\s*hands\s*=\s*2", line):
            continue
        out.append(line)
    return "\n".join(out).rstrip() + "\n"


def apply(p, fam, onehanded):
    f = FAMILIES[fam]
    # 1. the cards
    cards = ""
    for cls, hand, tag, lines in f["classes"]:
        cards += "\n" + clean_card(card_block(f["doc"], cls), onehanded)
    p.append("WMCARD.txt", "\n# " + "=" * 74 + "\n# LIVE: the " + fam + " family (" + ", ".join(c[0] for c in f["classes"])
             + ").\n# Measured and drafted in _pending/" + f["doc"] + ".\n# " + "=" * 74 + "\n" + cards,
             'weapon "' + f["classes"][0][0] + '"')
    # 2. the class lines
    for cls, hand, tag, lines in f["classes"]:
        body = "".join("\t\t" + l + "\n" for l in lines)
        p.rep("zscript/rs_vr_weapons/" + f["file"], "\t\t" + tag + "\n",
              "\t\t" + tag + "\n\t\t// LIVE: the reload system's keys for this gun landed.\n" + body)
    # 3. StartItems and ammo
    lo = "zscript/rs_vr_weapons/loadout.zs"
    items = "".join('\t\tPlayer.StartItem "' + c[0] + '";\n' for c in f["classes"])
    s = p.get(lo)[0]
    if f["ammo"]:
        a = f["ammo"][0]
        if a in STAWW2_AMMO and ('Player.StartItem "' + a + '"') not in s:
            items += '\t\tPlayer.StartItem "' + a + '", ' + str(STAWW2_AMMO[a]) + ";\n"
    p.rep(lo, '\t\tPlayer.DisplayName "WM";\n',
          "\t\t// The " + fam + " family, carried, not put in hand.\n" + items + '\t\tPlayer.DisplayName "WM";\n')
    # 4. slots
    names = ", ".join('"' + c[0] + '"' for c in f["classes"])
    s = p.get(lo)[0]
    m = re.search(r"\t\tPlayer\.WeaponSlot " + str(f["slot"]) + r", ([^;]*);\n", s)
    if m:
        p.rep(lo, m.group(0), "\t\tPlayer.WeaponSlot " + str(f["slot"]) + ", " + m.group(1) + ", " + names + ";\n")
    else:
        p.rep(lo, '\t\tPlayer.WeaponSlot 6, "WM_SMG", "WM_Tec9";\n',
              '\t\tPlayer.WeaponSlot 6, "WM_SMG", "WM_Tec9";\n\t\tPlayer.WeaponSlot ' + str(f["slot"]) + ", " + names + ";\n")
    if "for (int slot = 1; slot <= 6; slot++)" in p.get(lo)[0]:
        p.rep(lo, "for (int slot = 1; slot <= 6; slot++)", "for (int slot = 0; slot <= 9; slot++)")
    # 5. the netevent
    ev = f["event"]
    tag = re.sub(r"[^A-Za-z]", "", fam.title())
    gives = "".join('\t\t\tpmo.GiveInventory("' + c[0] + '", 1);\n' for c in f["classes"])
    if f["ammo"]:
        gives += '\t\t\tpmo.GiveInventory("' + f["ammo"][0] + '", ' + str(f["ammo"][1]) + ");\n"
    if f.get("grenades"):
        gives += ('\t\t\tClass<Inventory> nade' + tag + ' = (Class<Inventory>)(Object.FindClass("RSVG_Ammo", "Inventory"));\n'
                  '\t\t\tif (nade' + tag + ') pmo.GiveInventory(nade' + tag + ', ' + str(f["grenades"]) + ');\n')
    puts = " + ".join('PutByName(pmo, "' + c[0] + '", ' + str(c[1]) + ")" for c in f["classes"])
    reserve = (', %d ' + f["ammo"][0] + ' in reserve') if f["ammo"] else ""
    printf_args = "put" + tag + ((', pmo.CountInv("' + f["ammo"][0] + '")') if f["ammo"] else "")
    branch = ('\t\telse if (e.Name ~== "' + ev + '")\n\t\t{\n' + gives
              + '\t\t\tint put' + tag + ' = ' + puts + ';\n'
              + '\t\t\tConsole.Printf("WM: %d of the ' + fam + ' family in hand -- ' + f["said"] + (' -- %d ' + f["ammo"][0] + ' in reserve.' if f["ammo"] else '.') + '", '
              + printf_args + ');\n\t\t}\n')
    p.rep(lo, "\t}\n\n\t// BY NAME AT RUN TIME.", branch + "\t}\n\n\t// BY NAME AT RUN TIME.")
    p.rep(lo, "//\n// KEYCONF makes both console words;",
          "//   " + ev.ljust(17) + " " + f["row"].lower() + "\n//\n// KEYCONF makes both console words;")
    # 6. alias and menu row
    p.append("KEYCONF.txt", "\n// " + f["row"] + ".\nalias " + ev + ' "netevent ' + ev + '"\n', "alias " + ev + " ")
    md = p.get("MENUDEF.txt")
    a = md[0].find('OptionMenu "WM_ArsenalTest"')
    b = md[0].find('\tStaticText "EACH GUN", "Gold"\n', a)
    if a < 0 or b < 0:
        raise SystemExit("MENUDEF: WM_ArsenalTest or its EACH GUN line not found")
    row = '\tCommand "' + f["row"] + '", "netevent ' + ev + '"\n'
    md[0] = md[0][:b] + row + md[0][b:]


def main(argv):
    check = "--check" in argv
    onehanded = "--interim-onehanded" in argv
    fams = [a for a in argv if not a.startswith("--")] or list(FAMILIES)
    for fam in fams:
        if fam not in FAMILIES:
            raise SystemExit("unknown family " + fam)
    print("reload source has:", ", ".join(k for k, v in HAVE.items() if v) or "nothing new")
    print("reload source lacks:", ", ".join(k for k, v in HAVE.items() if not v) or "nothing")
    todo = []
    for fam in fams:
        miss = ready(fam)
        if onehanded and miss == ["hands"]:
            miss = []
        state = "READY" if not miss else "waiting on " + ", ".join(miss)
        print(f"  {fam:11s} {state}")
        if not miss:
            todo.append(fam)
    if "--dry" in argv:
        # EVERY EDIT, IN MEMORY, NOTHING WRITTEN -- readiness ignored, so every family's anchors
        # are proven now rather than on the day its grammar lands.
        p = Patch()
        for fam in fams:
            apply(p, fam, onehanded)
        print("dry run: every anchor matched for", ", ".join(fams), "-- nothing written")
        return 0
    if check or not todo:
        return 0
    p = Patch()
    for fam in todo:
        apply(p, fam, onehanded)
    p.commit()
    return lint()


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

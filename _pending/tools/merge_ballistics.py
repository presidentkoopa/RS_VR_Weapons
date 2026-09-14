"""The guns fire RS_Ballistics: each class names its round, muzzle flash and casing profiles.

The weapons lane's half of Engine docs/RSB_CALL_SITES_HANDOFF.md (section 9), as the ballistics lane
(uzdxrema-c5) sent it on 2026-09-13, plus WM_DoubleBarrel on the SSG's profiles. It adds only these
property lines, at the top of each class's Default block.

GATED, like merge_live.py:
  - every property the table uses must be declared in RS_VR_Reload's weapon.zs (an unknown property is a
    fatal load error) -- that lands when the reload lane applies the handoff;
  - every profile name must exist in RS_Ballistics' RSBDEFS (flash "none" excepted) -- the ballistics
    lane's next pack adds plasma / rocket / bfg / rail.

    python merge_ballistics.py --check     report readiness, write nothing
    python merge_ballistics.py --dry       find every class's Default block, write nothing
    python merge_ballistics.py             apply, when --check says READY (refuses otherwise)
"""
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")
PKG = "E:/DOOMWork/RS_VR_Weapons/"
WEAPON = "E:/DOOMWork/RS_VR_Reload/zscript/wm/weapon.zs"
RSBDEFS = "E:/DOOMWork/RS_Ballistics/RSBDEFS.txt"

PISTOL_45 = [("RoundProfile", "pistol_45"), ("FlashProfile", "pistol"), ("EjectaProfile", "brass_45")]
BUCK = lambda flash: [("RoundProfile", "buckshot"), ("FlashProfile", flash), ("EjectaProfile", "hull_12ga")]
REVOLVER = [("RoundProfile", "revolver_357"), ("FlashProfile", "revolver"), ("EjectaProfile", "brass_357")]
TABLE = [  # (file, class, [(property, profile)])
    ("pistols.zs", "WM_M4A3", PISTOL_45),
    ("pistols.zs", "WM_Pistolet", [("RoundProfile", "pistol_9mm"), ("FlashProfile", "pistol"), ("EjectaProfile", "brass_9mm")]),
    ("smgs.zs", "WM_Tec9", [("RoundProfile", "pistol_9mm"), ("FlashProfile", "smg"), ("EjectaProfile", "brass_9mm")]),
    ("smgs.zs", "WM_SMG", [("RoundProfile", "pistol_45"), ("FlashProfile", "smg"), ("EjectaProfile", "brass_45")]),
    ("rifles.zs", "WM_Rifle", [("RoundProfile", "rifle_762"), ("FlashProfile", "rifle"), ("EjectaProfile", "brass_762")]),
    ("rifles.zs", "WM_M16", [("RoundProfile", "rifle_556"), ("FlashProfile", "rifle"), ("EjectaProfile", "brass_556")]),
    ("chainguns.zs", "WM_Chaingun", [("RoundProfile", "rifle_556"), ("FlashProfile", "smg"), ("EjectaProfile", "brass_556")]),
    ("chainguns.zs", "WM_MachineGun", [("RoundProfile", "rifle_762"), ("FlashProfile", "rifle"), ("EjectaProfile", "brass_762"),
                                       ("AltFlashProfile", "rocket")]),
    ("revolvers.zs", "WM_Moonlight", REVOLVER),
    ("revolvers.zs", "WM_Sunset", REVOLVER),
    ("revolvers.zs", "WM_ColaRevolver", REVOLVER),
    ("shotguns.zs", "WM_PumpM37", BUCK("shotgun")),
    ("shotguns.zs", "WM_PumpDoom", BUCK("shotgun")),
    ("ssg.zs", "WM_SSG", BUCK("shotgun_double")),
    ("ssg.zs", "WM_DoubleBarrel", BUCK("shotgun_double")),
    ("plasma.zs", "WM_PlasmaRifle", [("FlashProfile", "plasma")]),
    ("plasma.zs", "WM_PlasmaCarbine", [("FlashProfile", "plasma")]),
    ("launchers.zs", "WM_RocketLauncher", [("FlashProfile", "rocket")]),
    ("launchers.zs", "WM_RPG", [("FlashProfile", "rocket")]),
    ("bfg.zs", "WM_BFG", [("FlashProfile", "bfg")]),
    ("bfg.zs", "WM_BFGHeavy", [("FlashProfile", "bfg")]),
    ("railguns.zs", "WM_Railgun", [("FlashProfile", "rail")]),
    ("flamers.zs", "WM_Flamer", [("FlashProfile", "none")]),
    ("flamers.zs", "WM_Flamethrower", [("FlashProfile", "none")]),
    # the chainsaws name nothing
]
KIND = {"RoundProfile": "round", "FlashProfile": "flash", "AltFlashProfile": "flash", "EjectaProfile": "ejecta"}
MARK = "// RS_BALLISTICS: what its shots look like -- profiles in RS_Ballistics' RSBDEFS."


def main(argv):
    weapon = open(WEAPON, encoding="utf-8").read()
    defs = open(RSBDEFS, encoding="utf-8").read()
    props = sorted({p for _, _, lines in TABLE for p, _ in lines})
    have_prop = {p: bool(re.search(r"property\s+" + p + r"\s*:", weapon)) for p in props}
    names = {(kind, n) for kind, n in re.findall(r"^(round|flash|ejecta)\s+(\w+)", defs, re.M)}
    missing_prof = sorted({(KIND[p], n) for _, _, lines in TABLE for p, n in lines
                           if n != "none" and (KIND[p], n) not in names})
    print("weapon.zs declares:", ", ".join(p for p in props if have_prop[p]) or "none of them")
    print("weapon.zs lacks:   ", ", ".join(p for p in props if not have_prop[p]) or "nothing")
    print("RSBDEFS lacks:     ", ", ".join(f"{k} {n}" for k, n in missing_prof) or "nothing")
    ready = all(have_prop.values()) and not missing_prof
    print("READY" if ready else "WAITING")

    texts, plan, problems = {}, [], []
    for fname, cls, lines in TABLE:
        path = PKG + "zscript/rs_vr_weapons/" + fname
        text = texts.setdefault(path, open(path, encoding="utf-8").read())
        m = re.search(r"^class\s+" + cls + r"\s*:[^\n]*\n\{\s*\n\s*Default\s*\n(\t*)\{\n", text, re.M)
        if not m:
            problems.append(f"{fname}: no Default block found for {cls}")
            continue
        body_end = text.find("\n\t}", m.end())
        if MARK in text[m.end():body_end]:
            problems.append(f"{cls}: already carries its profiles")
            continue
        plan.append((path, cls, m.end(), lines))
    # THE CARDS' CASING SOUND (the reload lane, 09-13): with the handoff applied a card's default casingsound
    # is "", so a casing sounds like its RSBDEFS ejecta profile. A card that states casingsound = "wm/casing"
    # would override that brass with the old click, so the line goes -- only on a gun that names an
    # EjectaProfile, only that exact line, nothing else in the card moves.
    card_path = PKG + "WMCARD.txt"
    card = open(card_path, encoding="utf-8").read()
    eject_classes = {cls for _, cls, lines in TABLE if any(p == "EjectaProfile" for p, _ in lines)}
    starts = [(m.start(), m.group(1)) for m in re.finditer(r'^weapon "(\w+)"', card, re.M)] + [(len(card), None)]
    drop = []   # (start, end) spans of the lines to remove
    for (a, cls), (b, _) in zip(starts, starts[1:]):
        head_end = card.find("\nend", a, b)
        head_end = b if head_end < 0 else head_end
        if cls not in eject_classes:
            continue
        for lm in re.finditer(r'^[ \t]*casingsound[ \t]*=[ \t]*"wm/casing"[ \t]*(#[^\n]*)?\n', card[a:head_end + 1], re.M):
            drop.append((a + lm.start(), a + lm.end(), cls))
    print(f"WMCARD: {len(drop)} casingsound = \"wm/casing\" lines to drop ({', '.join(c for _, _, c in drop) or 'none'})")

    for p in problems:
        print("  - " + p)
    if "--check" in argv:
        return 0
    if "--dry" in argv:
        print(f"dry run: {len(plan)} of {len(TABLE)} classes found, nothing written")
        return 1 if problems else 0
    if not ready or problems:
        print("NOT APPLIED")
        return 1
    for s, e, cls in sorted(drop, reverse=True):
        card = card[:s] + card[e:]
    if drop:
        open(card_path, "w", encoding="utf-8", newline="").write(card)
        print("wrote", card_path)
    for path in {p for p, _, _, _ in plan}:
        text = texts[path]
        for _, cls, at, lines in sorted((x for x in plan if x[0] == path), key=lambda x: -x[2]):
            block = "\t\t" + MARK + "\n" + "".join(f'\t\tWM_Gun.{p} "{n}";\n' for p, n in lines)
            text = text[:at] + block + text[at:]
        open(path, "w", encoding="utf-8", newline="\n").write(text)
        print("wrote", path)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

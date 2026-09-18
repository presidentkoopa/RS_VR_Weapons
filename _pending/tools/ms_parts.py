"""WHAT THE MODEL CARDS KNOW, TURNED INTO WHAT RS_PSReload ASKED FOR.

The ModelSwapper lane wants, per donor mesh: surface INDEX (MD3 order) for the magazine and the
slide, and the frames each sits at. Our cards store neither -- they name surfaces by NAME, and they
drive parts by a measured AXIS AND DISTANCE rather than by a frame pair, because the reload system
moves a part continuously with your hand instead of playing an animation.

So this does two things and states honestly where it cannot help:
  1. resolves every carded part's surface NAME to its index in OUR mesh
  2. checks whether the donor mesh in RS_ModelSwapper has the SAME surface list, because if it does
     the index transfers and if it does not nothing here is usable for that gun
"""
import io
import os
import re
import sys

sys.path.insert(0, "E:/DOOMWork/tools")
from md3 import MD3Model

ROOT = "E:/DOOMWork/RS_VR_Weapons"
MS = "E:/DOOMWork/RS_ModelSwapper"

# Their donors -> our carded mesh, by the owner's own naming. Guesses are marked and verified below.
PAIRS = {
    "MS_Pistol":      ("models/hud/Pistol/pistolet.md3",          "models/pistols/pistolet.md3"),
    "MS_AE_Pistol":   ("models/hud/AE_Pistol/m4a3.md3",           "models/pistols/m4a3.md3"),
    "MS_Shotgun":     ("models/hud/Shotgun/shotgun.md3",          "models/shotguns/Shotgun/shotgun.md3"),
    "MS_AE_Shotgun":  ("models/hud/AE_Shotgun/m37a2.md3",         "models/shotguns/AE_Shotgun/m37a2.md3"),
    "MS_SuperShotgun": ("models/hud/SuperShotgun/ssg.md3",        "models/shotguns/SuperShotgun/ssg.md3"),
    "MS_Rifle":       ("models/hud/Rifle/m16.md3",                "models/rifles/M16/m16_wm.md3"),
    "MS_RifleBD":     ("models/hud/RifleBD/Rifle.md3",            "models/rifles/Rifle/Rifle.md3"),
    "MS_PlasmaRifle": ("models/hud/PlasmaRifle/PlasmaRifle.md3",  "models/plasma/PlasmaRifle/plasmarifle_wm.md3"),
    "MS_BD_RailGun":  ("models/hud/RailGun/RailGun.md3",          "models/railguns/Railgun/railgun_wm.md3"),
    "MS_AE_Flamer":   ("models/hud/AE_Flamer/m260b.md3",          "models/flamers/Flamer/flamer_wm.md3"),
    "MS_Tec9":        ("models/hud/Tec9/tec9.md3",                "models/smgs/Tec9/tec9_wm.md3"),
    "MS_Cola":        ("models/hud/Cola_Revolver/revolver.md3",   "models/revolvers/Cola_Revolver/revolver.md3"),
    "MS_Revolver":    ("models/hud/Revolver/rev.md3",             "models/revolvers/Revolver/rev_wm.md3"),
    "MS_RC_M32":      ("models/hud/RC_M32/m32.md3",               None),
    "MS_Bolter":      ("models/hud/Bolter/Bolter.md3",            "models/plasma/Bolter/bolter_wm.md3"),
    "MS_Unmaker":     ("models/hud/Unmaker/Unmaker.md3",          "models/unmaker/Unmaker/unmaker_wm.md3"),
    "MS_Chaingun":    ("models/hud/Chaingun/Chaingun.md3",        None),
    "MS_Machinegun":  ("models/hud/Machinegun/Machinegun.md3",    "models/chainguns/MachineGun/machinegun_wm.md3"),
    "MS_RocketLauncher": ("models/hud/RocketLauncher/RPG.md3",    "models/launchers/RPG/rpg_wm.md3"),
}


def surfaces(path):
    try:
        m = MD3Model.load(path)
    except Exception as e:
        return None, str(e)
    return [s.name for s in m.surfaces], len(m.frames)


# ---- every carded part, with the mesh it lives on -----------------------------
cards = {}
for fn in sorted(os.listdir(ROOT)):
    if not fn.startswith("WMCARD."):
        continue
    txt = io.open(os.path.join(ROOT, fn), encoding="utf-8", errors="replace").read()
    for wm in re.finditer(r'^weapon "(\w+)"(.*?)(?=^weapon "|\Z)', txt, re.M | re.S):
        name, body = wm.group(1), wm.group(2)
        mm = re.search(r'^\s*model\s*=\s*"([^"]+)"\s*"([^"]+)"', body, re.M)
        if not mm:
            continue
        mesh = mm.group(1) + "/" + mm.group(2)
        parts = []
        for pm in re.finditer(r'^part (\w+)(.*?)^end', body, re.M | re.S):
            pn, pb = pm.group(1), pm.group(2)
            role = re.search(r'^\s*role\s*=\s*(\w+)', pb, re.M)
            subj = re.search(r'^\s*subject\s*=\s*(\w+)', pb, re.M)
            surfs = re.findall(r'^\s*surface\s*=\s*(\S+)', pb, re.M)
            kind = re.search(r'^\s*kind\s*=\s*(\w+)', pb, re.M)
            axis = re.search(r'^\s*axis\s*=\s*(.+)$', pb, re.M)
            dist = re.search(r'^\s*distance\s*=\s*(\S+)', pb, re.M)
            ang = re.search(r'^\s*(?:degrees|angle)\s*=\s*(\S+)', pb, re.M)
            parts.append(dict(part=pn, role=role.group(1) if role else "",
                              subject=subj.group(1) if subj else "",
                              surfaces=surfs, kind=kind.group(1) if kind else "",
                              axis=axis.group(1).strip() if axis else "",
                              distance=dist.group(1) if dist else "",
                              degrees=ang.group(1) if ang else ""))
        cards[name] = dict(mesh=mesh, parts=parts)

out = []
out.append("RS_VR_Weapons model-card part data, for RS_PSReload (2026-09-18)")
out.append("=" * 78)
out.append("")
out.append("SHAPE, so you can convert rather than guess:")
out.append("  * We name surfaces, we do not index them. Indices below are resolved from the MD3 by")
out.append("    reading its surface order, so they are OUR mesh's indices.")
out.append("  * We do NOT store a seated frame and an out frame. A card stores an AXIS and a")
out.append("    DISTANCE (or degrees about a pivot), because the reload system slides a part along")
out.append("    your hand continuously rather than playing an animation. Where a frame pair is")
out.append("    known it is in the card's comment, not a field.")
out.append("  * role = feed is the magazine/cell. role = action is the slide/pump/bolt.")
out.append("")

for wname in sorted(cards):
    c = cards[wname]
    p = os.path.join(ROOT, c["mesh"])
    names, nframes = surfaces(p)
    out.append("-" * 78)
    out.append("%s   %s" % (wname, c["mesh"]))
    if names is None:
        out.append("  MESH UNREADABLE: %s" % nframes)
        continue
    out.append("  %d surfaces, %d frames" % (len(names), nframes))
    idx = {n: i for i, n in enumerate(names)}
    for part in c["parts"]:
        ids = []
        for s in part["surfaces"]:
            ids.append("%s=%s" % (s, idx.get(s, "NOT FOUND")))
        mot = part["kind"]
        if part["distance"]:
            mot += " %s along %s" % (part["distance"], part["axis"])
        elif part["degrees"]:
            mot += " %s deg" % part["degrees"]
        out.append("    %-8s %-10s %-10s surface %s" % (part["role"] or "-", part["subject"] or "-", part["part"], ", ".join(ids)))
        out.append("             %s" % mot)

out.append("")
out.append("=" * 78)
out.append("DONOR MATCH: does the RS_ModelSwapper mesh carry the same surface list?")
out.append("If SAME, our indices transfer. If not, nothing above is usable for that gun.")
out.append("")
for donor, (mspath, ourpath) in sorted(PAIRS.items()):
    ms_full = os.path.join(MS, mspath)
    line = "%-20s %s" % (donor, mspath)
    if not os.path.isfile(ms_full):
        out.append(line + "\n    donor mesh MISSING at that path")
        continue
    ms_names, ms_frames = surfaces(ms_full)
    if ms_names is None:
        out.append(line + "\n    donor UNREADABLE: %s" % ms_frames)
        continue
    if ourpath is None:
        out.append(line + "\n    %d surfaces, %d frames -- WE HAVE NO CARD for this one" % (len(ms_names), ms_frames))
        out.append("      surfaces: %s" % ", ".join("%d:%s" % (i, n) for i, n in enumerate(ms_names)))
        continue
    our_full = os.path.join(ROOT, ourpath)
    if not os.path.isfile(our_full):
        out.append(line + "\n    our mesh missing at %s" % ourpath)
        continue
    our_names, our_frames = surfaces(our_full)
    same = (our_names == ms_names)
    out.append(line)
    out.append("    ours %s (%d surf, %d frames) vs donor (%d surf, %d frames) -- %s"
               % (ourpath, len(our_names or []), our_frames, len(ms_names), ms_frames,
                  "SAME ORDER, indices transfer" if same else "DIFFERENT, do not transfer"))
    if not same:
        out.append("      ours : %s" % ", ".join("%d:%s" % (i, n) for i, n in enumerate(our_names or [])))
        out.append("      donor: %s" % ", ".join("%d:%s" % (i, n) for i, n in enumerate(ms_names)))

dst = os.path.join(os.path.dirname(os.path.abspath(__file__)), "PSRELOAD_PART_DATA.txt")
io.open(dst, "w", encoding="utf-8", newline="\n").write("\n".join(out) + "\n")
print("wrote", dst, "--", len(out), "lines")

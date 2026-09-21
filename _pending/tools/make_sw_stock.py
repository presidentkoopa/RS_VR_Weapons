#!/usr/bin/env python3
"""Star Wars MODELDEF packs for Wardusted and Xim -- the second build, after the owner's headset pass.

    python _pending/tools/make_sw_stock.py

WHAT THE HEADSET FOUND AND WHAT CHANGED:

  "all of the textures are badly mapped"
      Every model names its OWN textures, one per surface, and several have more than one --
      golan_arms four, disruptor three, demp2 / repeater / merr_sonn / concussion / detpack two.
      The first build painted each with a single Skin 0, so every surface but one wore the wrong
      image. Now each surface gets the texture its own mesh asks for, by SurfaceSkin.
      (The first build also believed the meshes named NO textures at all. That was my MD3 reader
      reading the shader count from the flags field. See md3read.py.)

  "you didn't make them animate during firing"
      Every one of these meshes is ONE frame -- there is no animation in them to play. So firing
      is built the way the owner's own VR_WeaponSetRebuild builds it: a second Model block per
      fire frame, the same gun drawn KICKED -- pulled back toward the player and the muzzle up.
      The idle frame is the gun at rest; the fire frames are the gun under recoil.

  "upside down, barrel pointing to the left, body tilted towards me 45"
      A single correction for how Jedi Academy's models sit versus Doom's, from exactly what the
      owner saw -- plus the per-weapon pitch / yaw / roll JKXR's own author tuned in a headset
      (weapons_vr.cfg, in JKXR's z_vr_assets_jka.pk3) layered on top.

WHERE EACH PIECE COMES FROM:
  GEOMETRY   Vince Crusty and Elin's VR Fully Modeled Weapons Pack (JKA).
  TEXTURE    the name each surface carries, resolved through the pack's own shader file and then
             Jedi Academy's own assets, where the pack leaves most of them to live.
  PLACEMENT  weapons_vr.cfg for the per-gun rotation; our own guns for the size class.
  FRAMES     read out of each mod: Wardusted's DECORATE states, Xim's Doom sprite names.
"""
import io
import os
import re
import sys
import zipfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from md3read import read

SW_PK3 = "E:/StarWarsWork/JKXR/assets/z_vr_weapons_jka_Crusty_and_Elin.pk3"
JKXR_ASSETS = "E:/StarWarsWork/JKXR/build/pk3/z_vr_assets_jka.pk3"
JKA = "D:/SteamLibrary/steamapps/common/Jedi Academy/GameData/base"
OUT = "D:/SteamLibrary/steamapps/Common/DooM VR/__Games/Wardusted"

# ---- THE MODELS: main mesh, the barrel part JK attaches to it, and JKA's weapon id ------------
# The id is the index into JKA's own weapon enum (code/game/weapons.h), which is what names the
# vr_weapon_adjustment_<id> line in weapons_vr.cfg.
MODELS = {
    "saber":          ("saber/saber_w.md3",                 None,                                  1),
    "blaster_pistol": ("blaster_pistol/blaster_pistol.md3", None,                                  2),
    "blaster_r":      ("blaster_r/blaster.md3",             None,                                  3),
    "disruptor":      ("disruptor/disruptor.md3",           "disruptor/disruptor_barrel.md3",      4),
    "bowcaster":      ("bowcaster/bowcaster.md3",           None,                                  5),
    "heavy_repeater": ("heavy_repeater/heavy_repeater.md3", "heavy_repeater/heavy_repeater_barrel.md3", 6),
    "demp2":          ("demp2/demp2.md3",                   None,                                  7),
    "golan_arms":     ("golan_arms/golan_arms.md3",         None,                                  8),
    "merr_sonn":      ("merr_sonn/merr_sonn.md3",           "merr_sonn/merr_sonn_barrel.md3",      9),
    "thermal":        ("thermal/thermal.md3",               None,                                 10),
    "laser_trap":     ("laser_trap/laser_trap.md3",         None,                                 11),
    "concussion":     ("concussion/c_rifle.md3",            "concussion/c_rifle_barrel.md3",      13),
    "briar_pistol":   ("briar_pistol/briar_pistol.md3",     None,                                 18),
}

# SIZE CLASS, measured against our own guns -- a pistol is a pistol (see the first build).
SCALE = {
    "blaster_pistol": 3.20, "briar_pistol": 2.25, "saber": 2.20, "thermal": 4.00,
    "laser_trap": 6.50, "blaster_r": 4.15, "bowcaster": 5.10, "demp2": 4.15,
    "disruptor": 4.85, "golan_arms": 4.75, "heavy_repeater": 2.15, "merr_sonn": 5.00,
    "concussion": 4.65,
}

# ---- THE ORIENTATION ---------------------------------------------------------------------------
# WHAT THE OWNER SAW: upside down, barrel to the left, body tilted toward him 45 degrees.
#   upside down           -> roll 180
#   barrel to the left    -> a quarter turn of yaw
#   tilted toward him 45  -> 45 of pitch back the other way
#
# THE MESHES DO NOT ALL POINT THE SAME WAY. Most are long on X; blaster_pistol and blaster_r are
# long on Y, a quarter turn from the rest. So the yaw is decided per model off its measured long
# axis, not once for the set -- one number would fix half the guns and break the other half.
BASE_ROLL = 180.0
BASE_PITCH = -45.0
YAW_FOR_AXIS = {"x": 90.0, "y": 0.0}

# ---- FIRING: the same gun, kicked ----------------------------------------------------------------
# Pulled back toward the player and the muzzle up. Small on purpose: a recoil you can see, not a
# gun that leaves the screen.
# NONE. The owner: "these are energy weapons, i expect them to not animate much, if at all. but
# if they DO i want it." The kick I added was INVENTED -- every one of these meshes is a single
# frame and nothing in the source moves them -- so it is gone. Kept as named zeroes rather than
# deleted so the fire block still exists: the fire frames draw the gun exactly as at rest, which is
# what the source does, and if a real firing pose ever turns up it goes here.
KICK_BACK = 0.0
KICK_PITCH = 0.0

# ---- WARDUSTED: its own classes; ready frame, then EVERY fire frame its DECORATE uses ------------
WARDUST = [
    ("Lightsaber",            "SABR", "D", [("SABA", "ABCDE")],          "saber"),
    ("DL44Blaster",           "DF01", "A", [("DF01", "B")],              "blaster_pistol"),
    ("E11Blaster",            "DF02", "A", [("DF02", "B")],              "blaster_r"),
    ("DarkBlaster",           "DB02", "A", [("DB02", "B")],              "briar_pistol"),
    ("RebelThermalDetonator", "DF03", "A", [("DF03", "BC")],             "thermal"),
    ("Bowcaster",             "DF05", "A", [("DF05", "BG")],             "bowcaster"),
    ("ProximityMines",        "DF06", "A", [("DF06", "B")],              "laser_trap"),
    ("ConcussionRifle",       "DF08", "A", [("DF08", "BC")],             "concussion"),
    ("DisruptorRifle",        "DRIF", "A", [("DRIF", "BCD")],            "disruptor"),
    ("SniperRifle",           "DC15", "A", [("DC15", "BCF")],            "disruptor"),
    ("Z6RotaryBlaster",       "DF04", "A", [("DF04", "BC")],             "heavy_repeater"),
    ("DLT19",                 "DLT1", "A", [("DLT1", "B")],              "golan_arms"),
    ("E22Blaster",            "DF22", "A", [("DF22", "B")],              "demp2"),
    ("DarkAssaultCannon",     "DF09", "A", [("DF09", "BCDG")],           "merr_sonn"),
]

# ---- XIM: DeHackEd, so Doom's own classes and sprites --------------------------------------------
XIM = [
    ("Chainsaw",       "SAWG", "A", [("SAWG", "BCD")], "saber"),
    ("Pistol",         "PISG", "A", [("PISG", "BCDE")], "blaster_pistol"),
    ("Shotgun",        "SHTG", "A", [("SHTG", "BCD")], "blaster_r"),
    ("SuperShotgun",   "SHT2", "A", [("SHT2", "BCDEFGHIJ")], "demp2"),
    ("Chaingun",       "CHGG", "A", [("CHGG", "B")], "heavy_repeater"),
    ("RocketLauncher", "MISG", "A", [("MISG", "BCD")], "bowcaster"),
    ("PlasmaRifle",    "PLSG", "A", [("PLSG", "B")], "golan_arms"),
    ("BFG9000",        "BFGG", "A", [("BFGG", "BC")], "thermal"),
]


# =================================================================================================
def load_cfg():
    """weapons_vr.cfg -> {id: (scale,right,up,forward,pitch,yaw,roll)} -- JKXR's own tuning."""
    t = zipfile.ZipFile(JKXR_ASSETS).read("weapons_vr.cfg").decode("latin1")
    out = {}
    for m in re.finditer(r'vr_weapon_adjustment_(\d+)\s+"([^"]+)"', t):
        out[int(m.group(1))] = tuple(float(x) for x in m.group(2).split(","))
    return out


def load_shaders():
    """shader name -> the image its first stage maps, from the pack and from Jedi Academy."""
    sh = {}
    srcs = [zipfile.ZipFile(SW_PK3)] + [zipfile.ZipFile(os.path.join(JKA, p))
                                       for p in ("assets0.pk3", "assets1.pk3")]
    for z in srcs:
        for n in z.namelist():
            if not n.lower().endswith(".shader"):
                continue
            t = z.read(n).decode("latin1", "replace")
            for m in re.finditer(r'(?m)^\s*(models/weapons2/[^\s{]+)\s*\n\s*\{(.*?)\n\}', t, re.S):
                mp = re.search(r'\bmap\s+(\S+)', m.group(2))
                if mp and mp.group(1) != "$lightmap":
                    sh.setdefault(m.group(1).lower(), mp.group(1))
    return sh


class Images:
    """Find an image by its name without an extension, in the pack first, then Jedi Academy's."""
    def __init__(self):
        self.srcs = [zipfile.ZipFile(SW_PK3)] + [zipfile.ZipFile(os.path.join(JKA, p))
                                                for p in ("assets0.pk3", "assets1.pk3",
                                                          "assets2.pk3", "assets3.pk3")]
        self.idx = {}
        for z in self.srcs:
            for n in z.namelist():
                low = n.lower()
                if low.endswith((".jpg", ".tga", ".png")):
                    self.idx.setdefault(low.rsplit(".", 1)[0], (z, n))

    def find(self, base):
        return self.idx.get(base.lower().rsplit(".", 1)[0] if "." in base.split("/")[-1] else base.lower())


def long_axis(m):
    v = [p for s in m["surfaces"] for p in s["verts"]]
    ext = [max(p[i] for p in v) - min(p[i] for p in v) for i in range(3)]
    return "xyz"[ext.index(max(ext))]


# ---- THE STOCK SABER'S BLADE -----------------------------------------------------------------------
# JKA never modelled a blade -- its code draws one -- so a hilt alone is all the pack had, and a saber
# with no blade is a torch handle. The owner: "a lightsaber stock friendly no real laser". So the
# blade is RS_Lightsaber's own mesh (tools/gen_saber_blade.py), built in the HILT'S OWN SPACE, so the
# block's one Scale / Offset / rotation fits it to the hilt with nothing extra.
#
# NO ADDITIVE ANYTHING, because stock MODELDEF cannot ask for it per model: the blade draws SOLID. So
# of its three shells only two show -- a white core inside a coloured shell -- and the outer glow
# shell wears a fully transparent skin, which the renderer's alpha test drops. Frame 8 is the blade at
# full length; a stock saber is simply always lit.
#
# THE COLOUR IS EACH MOD'S OWN, read off its sprites: Wardusted's saber is red, Xim's blue.
BLADE_SRC = "E:/DOOMWork/RS_Lightsaber/models/starwars/lightsaber"
BLADE_FULL_FRAME = 8


def blade_files(color):
    """blade.md3 and its three skins, as (archive name -> bytes), and the SurfaceSkin lines."""
    from PIL import Image
    files = {"blade.md3": open(BLADE_SRC + "/blade.md3", "rb").read(),
             "blade_core.png": open(BLADE_SRC + "/blade_core.png", "rb").read(),
             "blade_inner_%s.png" % color: open(BLADE_SRC + "/blade_inner_%s.png" % color, "rb").read(),
             "blade_mid_%s.png" % color: open(BLADE_SRC + "/blade_mid_%s.png" % color, "rb").read()}
    buf = io.BytesIO()
    Image.new("RGBA", (8, 8), (0, 0, 0, 0)).save(buf, "PNG")
    files["blade_clear.png"] = buf.getvalue()
    # THE BLADE HAS SIX SHELLS NOW (gen_saber_blade.py): core, inner, colour, and three halo rings.
    # Stock draws solid, so the halo rings wear the clear skin and only the first three show.
    skins = ['\tSurfaceSkin 1 0 "blade_core.png"',
             '\tSurfaceSkin 1 1 "blade_inner_%s.png"' % color,
             '\tSurfaceSkin 1 2 "blade_mid_%s.png"' % color] + [
             '\tSurfaceSkin 1 %d "blade_clear.png"' % i for i in (3, 4, 5)]
    return files, skins


def build(name, rows, title, source_note, saber_color):
    sw = zipfile.ZipFile(SW_PK3)
    swl = {n.lower(): n for n in sw.namelist()}
    cfg = load_cfg()
    shaders = load_shaders()
    imgs = Images()

    out_files = {}         # archive path -> bytes
    missing = []
    parsed = {}

    def add_model(rel):
        src = swl.get(("models/weapons2/" + rel).lower())
        if not src:
            missing.append(rel); return None
        data = sw.read(src)
        out_files["models/weapons2/" + rel] = data
        return read(data)

    def surface_skins(folder, model_index, m):
        """One SurfaceSkin per surface, off the texture that surface names."""
        lines = []
        for si, s in enumerate(m["surfaces"]):
            want = next((x for x in s["shaders"] if x), None)
            if not want:
                continue
            target = shaders.get(want.lower(), want)
            hit = imgs.find(target) or imgs.find(want)
            if not hit:
                missing.append("%s surface %d -> %s" % (folder, si, want)); continue
            z, n = hit
            fname = os.path.basename(n)
            out_files["models/weapons2/%s/%s" % (folder, fname)] = z.read(n)
            lines.append('\tSurfaceSkin %d %d "%s"' % (model_index, si, fname))
        return lines

    o = ["// " + "=" * 74,
         "// %s" % title,
         "//",
         "// GENERATED by RS_VR_Weapons/_pending/tools/make_sw_stock.py. Geometry from Vince Crusty and Elin's VR Fully Modeled",
         "// Weapons Pack; every surface textured with the image its own mesh names; the per-gun",
         "// rotation JKXR's author tuned in a headset (weapons_vr.cfg) layered on the correction",
         "// for how Jedi Academy models sit versus Doom's. %s" % source_note,
         "//",
         "// NO INVENTED ANIMATION. Every one of these meshes is a single frame and nothing in the",
         "// source moves them while firing, so the fire frames draw the gun exactly as at rest.",
         "// The ONE thing Jedi Academy does animate is the BARREL SPIN on the repeater, disruptor,",
         "// Merr-Sonn and concussion rifle -- CG_MachinegunSpinAngle, cg_weapons.cpp, in code. It",
         "// spins one part of the gun, and MODELDEF can only turn a whole model, so it is not faked",
         "// here. The barrels are attached as Model 1, ready for a ZScript spin when it is wanted.",
         "//",
         "// OFFSETS ARE STILL THE HEADSET'S JOB. The rotation now comes from what the owner saw and",
         "// from JKXR's own tuning; where a gun sits in the view is not something a mesh can measure.",
         "// " + "=" * 74, ""]

    for cls, rs, rf, fires, folder in rows:
        main, barrel, wid = MODELS[folder]
        m = parsed.get(folder) or add_model(main)
        parsed[folder] = m
        if not m:
            continue
        b = add_model(barrel) if barrel else None
        blade = None
        if folder == "saber":
            bf, blade = blade_files(saber_color)
            for k, v in bf.items():
                out_files["models/weapons2/saber/" + k] = v
        sc = SCALE[folder]
        c = cfg.get(wid, (1, 0, 0, 0, 0, 0, 0))
        yaw = YAW_FOR_AXIS.get(long_axis(m), 90.0) + c[5]
        pitch = BASE_PITCH + c[4]
        roll = BASE_ROLL + c[6]

        skins = surface_skins(folder, 0, m)
        if b:
            skins += surface_skins(folder, 1, b)

        def block(frames, back, climb, tag):
            lines = ["// %s" % tag, "Model %s" % cls, "{",
                     '\tPath "models/weapons2/%s"' % folder,
                     '\tModel 0 "%s"' % os.path.basename(main)]
            if b:
                lines.append('\tModel 1 "%s"' % os.path.basename(barrel))
            if blade:
                lines.append('\tModel 1 "blade.md3"')
            lines += skins
            if blade:
                lines += blade
            lines += ['\tScale %.2f %.2f %.2f' % (sc, sc, sc),
                      '\tOffset %.2f 0.00 0.00' % (-back),
                      '\tAngleOffset %.1f' % yaw,
                      '\tPitchOffset %.1f' % (pitch + climb),
                      '\tRollOffset %.1f' % roll, '']
            for spr, fr in frames:
                for f in fr:
                    lines.append('\tFrameIndex %s %s 0 0' % (spr, f))
                    if b:
                        lines.append('\tFrameIndex %s %s 1 0' % (spr, f))
                    if blade:
                        lines.append('\tFrameIndex %s %s 1 %d' % (spr, f, BLADE_FULL_FRAME))
            lines += ["}", ""]
            return lines

        # ONE BLOCK, the ready frame and every fire frame together: with nothing to animate there is
        # nothing to separate, and a second block that draws the same pose is just a second place
        # for the two to drift apart.
        o += block([(rs, rf)] + fires, 0.0, 0.0, "%s -- held and firing (no source animation)" % cls)

    out_files["MODELDEF"] = "\n".join(o).encode("utf-8")
    dest = os.path.join(OUT, name)
    with zipfile.ZipFile(dest, "w", zipfile.ZIP_DEFLATED) as z:
        for k in sorted(out_files):
            z.writestr(k, out_files[k])
    print("%-26s %3d entries  %s" % (name, len(out_files),
          "every surface textured" if not missing else "MISSING: %s" % missing))


# =================================================================================================
# THE THIRD BUILD (2026-09-21), after the owner's second headset pass: "the point to the right, angle
# 45 down, are too large". build() above turned the RAW Jedi Academy meshes with one correction for the
# whole pack -- and the pack does not sit one way: the DL-44 and E-11 are upside down, four meshes lie
# on their side, the rest are upright, and they are not to one scale. One correction could never fit
# all of them.
#
# SO THIS DRAWS THE MESHES THE REMA SETS ALREADY NORMALISED (make_sw_sets.py): each turned off its own
# tag_flash to barrel +X, up +Z, origin in the grip, sized to its real weapon. That is the SAME FRAME as
# m4a3.md3 -- barrel +X, up +Z, origin at the grip -- and the owner's own tuned VR pack draws m4a3 as a
# HUD model with NO angle offsets at all (VR_WeaponSetRebuild/WeaponSets/Aliens-Eradication-VR-addon/
# modeldef.pistol.txt: Scale -0.82, Offset 0 -29 -8). So every gun here takes exactly that block, and
# its size is the M4A3's on the HUD: 31.2 mesh units x 0.82 = 25.6 for a ~21 cm pistol, 1.22 a cm,
# against the REMA meshes' 1.75 a cm.
SETS_MODELS = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
                           "models", "wardusted")
# THE MESHES ARE NOW AT THE M4A3'S OWN SCALE (make_sw_sets.UNITS_PER_CM), so 1.0 would draw each at
# the M4A3 HUD's size per centimetre -- and the owner found that too large on the HUD as well
# (2026-09-21), the films' guns being long. STOCK_SHRINK is the one number for that: every stock gun
# and the saber are drawn at it.
STOCK_SHRINK = 0.75
HUD_SCALE = STOCK_SHRINK
HUD_OFFSET = (0.0, -29.0, -8.0)           # the M4A3 HUD block's own
SABER_SRC = "E:/DOOMWork/RS_Lightsaber/models/starwars/lightsaber"
SABER_HILT_CM = 28.0


# THE STOCK SABER'S POSES, frame by frame: (yaw, up) in degrees -- yaw left positive, up the blade's
# rise from level. Read off the mods' own sprites, which is the swing the mod plays:
#   WARDUSTED, SABA: the blade raised and cocked to the right (B-E), a blurred slash across and down
#   (F, G), the follow-through low to the left (H), back up (I-L), and a second slash (M, N). Its
#   ready frames (SABR C D G H I) hold the blade raised in front.
#   XIM, SAWG: Doom's chainsaw frames -- ready alternates C/D, fire alternates A/B -- dressed as a
#   saber; the extra frames E-K are bound too, to the same two-beat slash.
SABER_REST = (0.0, 50.0)
_WD_SWING = {"A": (-15, 60), "B": (-30, 70), "C": (-40, 75), "D": (-45, 75), "E": (-40, 65),
             "F": (0, 35), "G": (40, 10), "H": (55, -5), "I": (35, 20), "J": (10, 45),
             "K": (-10, 60), "L": (-20, 65), "M": (0, 30), "N": (40, 5)}
_XIM_SWING = {"A": (-35, 65), "B": (35, 15), "C": SABER_REST, "D": SABER_REST,
              "E": (-35, 65), "F": (0, 40), "G": (35, 15), "H": (-35, 65), "I": (0, 40),
              "J": (35, 15), "K": SABER_REST}
SABER_POSES = {
    "Lightsaber": [(("SABR", f), SABER_REST) for f in "CDGHI"] +
                  [(("SABA", f), p) for f, p in sorted(_WD_SWING.items())],
    "Chainsaw":   [(("SAWG", f), p) for f, p in sorted(_XIM_SWING.items())],
}


# A GUN THE OWNER SAW UPSIDE DOWN ON THE STOCK HUD (2026-09-21: "shotgun is upside down" -- Xim's
# shotgun, the E-11), turned over about its barrel here for the stock packs.
STOCK_ROLL = {"blaster_r": 180.0}


def _surface_skins(md3path, model_index):
    """The texture each surface of a normalised mesh names (make_sw_sets wrote them as its shaders)."""
    import struct as _s
    b = open(md3path, "rb").read()
    ns = _s.unpack_from("<i", b, 84)[0]
    o = _s.unpack_from("<i", b, 100)[0]
    out = []
    for si in range(ns):
        osh = _s.unpack_from("<i", b, o + 92)[0]
        oend = _s.unpack_from("<i", b, o + 104)[0]
        sh = b[o + osh:o + osh + 64].split(b"\0")[0].decode("latin1")
        if sh:
            out.append((si, sh))
        o += oend
    return out


def _write_anim_md3(path, surfs, frames):
    """One md3, every surface, one frame per pose: frames[f][si] is surface si's vertices in frame f.
    Normals are carried with each frame's turn. make_sw_sets.write_md3 writes one frame only."""
    import math as _m
    import struct as _s
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import make_sw_sets as S
    nf = len(frames)
    body = b""
    for si, s in enumerate(surfs):
        nv, nt = len(s["verts"]), len(s["tris"])
        o_sh, o_tri = 108, 108 + 68
        o_st = o_tri + 12 * nt
        o_xyz = o_st + 8 * nv
        o_end = o_xyz + 8 * nv * nf
        b = _s.pack("<4s64s10i", b"IDP3", s["name"].encode()[:63], 0, nf, 1, nv, nt, o_tri, o_sh, o_st, o_xyz, o_end)
        b += _s.pack("<64si", s["shader"].encode()[:63], 0)
        for tr in s["tris"]:
            b += _s.pack("<3i", *tr)
        for uv in s["st"]:
            b += _s.pack("<2f", *uv)
        for f in range(nf):
            vs, ns = frames[f][si]
            for v, n in zip(vs, ns):
                q = [max(-32768, min(32767, int(round(c * 64.0)))) for c in v]
                b += _s.pack("<3hH", q[0], q[1], q[2], S.encode_normal(n))
        body += b
    fr = b""
    for f in range(nf):
        allv = [v for vs, _ in frames[f] for v in vs]
        mn = [min(v[i] for v in allv) for i in range(3)]
        mx = [max(v[i] for v in allv) for i in range(3)]
        rad = max(_m.sqrt(sum(c * c for c in v)) for v in allv)
        fr += _s.pack("<3f3f3ff16s", *mn, *mx, 0, 0, 0, rad, ("pose%d" % f).encode())
    o_fr = 108
    o_surf = o_fr + len(fr)
    head = _s.pack("<4si64s9i", b"IDP3", 15, b"saber_anim", 0, nf, 0, len(surfs), 0,
                   o_fr, o_surf, o_surf, o_surf + len(body))
    open(path, "wb").write(head + fr + body)


def _pose(v, yaw, up):
    """A point of the saber turned to a pose about the hand: raised by `up` (the +X blade toward +Z),
    then swung by `yaw` about the vertical."""
    import math as _m
    x, y, z = v
    u, a = _m.radians(up), _m.radians(yaw)
    x, z = x * _m.cos(u) - z * _m.sin(u), x * _m.sin(u) + z * _m.cos(u)
    x, y = x * _m.cos(a) + y * _m.sin(a), -x * _m.sin(a) + y * _m.cos(a)
    return (x, y, z)


def _saber_anim(color, poses):
    """THE STOCK SABER AS ONE ANIMATED MESH, the way Brutal Doom draws its axe: the hilt and the lit
    blade together, one model frame per pose. The engine blends model frames from one tic to the next,
    so the swing FOLLOWS THROUGH instead of jumping -- a block per pose cannot, because the engine does
    not blend between two blocks' offsets, and the idle twitched between two of them (the owner,
    2026-09-21). Returns the file bytes and each pose's frame number."""
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import make_sw_sets as S
    lo, hi = -12.31, 3.61
    mid = (lo + hi) / 2.0
    _, hilt = S.read_md3(open(SABER_SRC + "/saber_w.md3", "rb").read())
    for s in hilt:
        s["shader"] = "saber.jpg"
    _, blade = S.read_md3(open(SABER_SRC + "/blade.md3", "rb").read(), BLADE_FULL_FRAME)
    for s, sh in zip(blade, ("blade_core.png", "blade_inner_%s.png" % color, "blade_mid_%s.png" % color,
                             "blade_clear.png", "blade_clear.png", "blade_clear.png")):
        s["shader"] = sh
    surfs = hilt + blade
    base = [([(z - mid, y, -x) for (x, y, z) in s["verts"]], [(z, y, -x) for (x, y, z) in s["norms"]])
            for s in surfs]
    order = []
    for p in poses:
        if p not in order:
            order.append(p)
    frames = [[([_pose(v, yaw, up) for v in vs], [_pose(n, yaw, up) for n in ns]) for vs, ns in base]
              for (yaw, up) in order]
    tmp = os.path.join(os.environ.get("TEMP", "."), "sw_stock_saber")
    os.makedirs(tmp, exist_ok=True)
    path = os.path.join(tmp, "saber_anim.md3")
    _write_anim_md3(path, surfs, frames)
    return open(path, "rb").read(), {p: i for i, p in enumerate(order)}, len(hilt)


def _saber_meshes(color):
    """The hilt and the full blade turned so the blade points down the barrel axis (+X) and the hand
    holds the middle of the hilt -- the same frame as every gun here. The hilt is long on Z with its
    emitter at +Z (gen_saber_blade.py measured it), so +Z becomes +X."""
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import make_sw_sets as S
    lo, hi = -12.31, 3.61                       # the hilt, measured (gen_saber_blade.py)
    mid = (lo + hi) / 2.0

    def turn(surfs):
        for s in surfs:
            s["verts"] = [(z - mid, y, -x) for (x, y, z) in s["verts"]]
            s["norms"] = [(z, y, -x) for (x, y, z) in s["norms"]]
        return surfs

    files = {}
    _, hilt = S.read_md3(open(SABER_SRC + "/saber_w.md3", "rb").read())
    for s in hilt:
        s["shader"] = "saber.jpg"
    tmp = os.path.join(os.environ.get("TEMP", "."), "sw_stock_saber")
    os.makedirs(tmp, exist_ok=True)
    S.write_md3(os.path.join(tmp, "saber_hud.md3"), turn(hilt))
    _, blade = S.read_md3(open(SABER_SRC + "/blade.md3", "rb").read(), BLADE_FULL_FRAME)
    for s, sh in zip(blade, ("blade_core.png", "blade_inner_%s.png" % color, "blade_mid_%s.png" % color,
                             "blade_clear.png", "blade_clear.png", "blade_clear.png")):
        s["shader"] = sh
    S.write_md3(os.path.join(tmp, "blade_hud.md3"), turn(blade))
    files["saber_hud.md3"] = open(os.path.join(tmp, "saber_hud.md3"), "rb").read()
    files["blade_hud.md3"] = open(os.path.join(tmp, "blade_hud.md3"), "rb").read()
    files["saber.jpg"] = open(SABER_SRC + "/saber.jpg", "rb").read()
    bf, _ = blade_files(color)
    for k, v in bf.items():
        if k.endswith(".png"):
            files[k] = v
    return files, (hi - lo)


def build_hud(name, rows, title, source_note, saber_color):
    out_files = {}
    o = ["// " + "=" * 74,
         "// %s" % title,
         "//",
         "// GENERATED by RS_VR_Weapons/_pending/tools/make_sw_stock.py (build_hud). Geometry from Vince",
         "// Crusty and Elin's VR Fully Modeled Weapons Pack, normalised per mesh by make_sw_sets.py;",
         "// textures Jedi Academy's own. %s" % source_note,
         "//",
         "// EVERY GUN TAKES THE M4A3 HUD BLOCK the owner's own VR pack draws that pistol with -- same frame,",
         "// no angle offsets -- at the M4A3's own size per centimetre. See build_hud's header in the tool.",
         "// No invented animation: every mesh is one frame and the fire frames draw it at rest.",
         "// " + "=" * 74, ""]
    sc = HUD_SCALE
    for cls, rs, rf, fires, folder in rows:
        frames = [(rs, rf)] + fires
        if folder == "saber":
            files, hilt_len = _saber_meshes(saber_color)
            for k, v in files.items():
                out_files["models/sw/saber/" + k] = v
            s2 = SABER_HILT_CM * (25.6 / 21.0) / hilt_len * STOCK_SHRINK
            # ONE BLOCK, ONE ANIMATED MESH (_saber_anim): every frame the mod's saber uses is bound, the
            # idle ones all to the one still pose, the swing's to its own frames in order, so the engine
            # blends the swing smoothly -- Brutal Doom's axe, the owner's reference.
            poses = SABER_POSES[cls]
            data, frame_of, nhilt = _saber_anim(saber_color, [p for _, p in poses])
            out_files["models/sw/saber/saber_anim.md3"] = data
            lines = ["// %s -- one animated mesh: the hilt and a lit blade, posed frame by frame" % cls,
                     "Model %s" % cls, "{",
                     '\tPath "models/sw/saber"', '\tModel 0 "saber_anim.md3"', '\tSkin 0 "saber.jpg"']
            blade_skins = ["blade_core.png", "blade_inner_%s.png" % saber_color, "blade_mid_%s.png" % saber_color,
                           "blade_clear.png", "blade_clear.png", "blade_clear.png"]
            lines += ['\tSurfaceSkin 0 %d "%s"' % (nhilt + i, sk) for i, sk in enumerate(blade_skins)]
            lines += ['\tScale %.3f %.3f %.3f' % (-s2, s2, s2), '\tCORRECTPIXELSTRETCH',
                      '\tOffset %.1f %.1f %.1f' % HUD_OFFSET, '']
            for (spr, f), p in poses:
                lines.append('\tFrameIndex %s %s 0 %d' % (spr, f, frame_of[p]))
            o += lines + ["}", ""]
            continue
            continue
        src = os.path.join(SETS_MODELS, folder)
        mesh = folder + "_wm.md3"
        out_files["models/sw/%s/%s" % (folder, mesh)] = open(os.path.join(src, mesh), "rb").read()
        # a surface whose texture JKA never shipped (the disruptor's scope_front) wears the gun's main skin
        skins = [(si, tx) for si, tx in _surface_skins(os.path.join(src, mesh), 0)
                 if os.path.exists(os.path.join(src, tx))]
        for _, tex in skins:
            out_files["models/sw/%s/%s" % (folder, tex)] = open(os.path.join(src, tex), "rb").read()
        lines = ["// %s" % cls, "Model %s" % cls, "{",
                 '\tPath "models/sw/%s"' % folder, '\tModel 0 "%s"' % mesh]
        if skins:
            lines.append('\tSkin 0 "%s"' % skins[0][1])
        lines += ['\tSurfaceSkin 0 %d "%s"' % (si, tex) for si, tex in skins]
        # CORRECTPIXELSTRETCH: Doom's 1.2 vertical stretch applied BEFORE the turn, not after it, so a
        # tilted gun is not sheared ("circles are ovals" -- the owner, 2026-09-21; models.cpp:1710).
        lines += ['\tScale %.3f %.3f %.3f' % (-sc, sc, sc), '\tCORRECTPIXELSTRETCH',
                  '\tOffset %.1f %.1f %.1f' % HUD_OFFSET]
        if folder in STOCK_ROLL:
            lines.append('\tRollOffset %.1f' % STOCK_ROLL[folder])
        lines.append('')
        for spr, fr in frames:
            for f in fr:
                lines.append('\tFrameIndex %s %s 0 0' % (spr, f))
        o += lines + ["}", ""]
    out_files["MODELDEF"] = "\n".join(o).encode("utf-8")
    dest = os.path.join(OUT, name)
    with zipfile.ZipFile(dest, "w", zipfile.ZIP_DEFLATED) as z:
        for k in sorted(out_files):
            z.writestr(k, out_files[k])
    print("%-26s %3d entries" % (name, len(out_files)))


if __name__ == "__main__":
    build_hud("SW_Models_Wardusted.pk3", WARDUST, "STAR WARS MODELS FOR WARDUST'S ROGUE REBEL -- 14 weapons",
              "Frames from Wardusted's own DECORATE.", "red")
    build_hud("SW_Models_Xim.pk3", XIM, "STAR WARS MODELS FOR XIM'S STAR WARS DOOM -- 8 weapons",
              "Xim is DeHackEd: Doom's own classes and sprites.", "blue")

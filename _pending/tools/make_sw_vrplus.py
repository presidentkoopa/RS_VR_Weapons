#!/usr/bin/env python3
"""Star Wars VR weapon packs for Xim's Star Wars Doom and Wardust's Rogue Rebel -- the Ermac / VanillaVR+ way.

    python make_sw_vrplus.py [SRC_DIR] [OUT_DIR]

    SRC_DIR  folder holding the previous build's SW_Models_Wardusted.pk3 and SW_Models_Xim.pk3 (the meshes and
             Jedi Academy skins come out of those -- nothing else is needed).  Default: the Wardusted game folder.
    OUT_DIR  where SW_VR_Wardusted.pk3 and SW_VR_Xim.pk3 are written. Default: SRC_DIR.

TRADITIONAL VR WEAPONS: psprite (HUD-layer) models via plain MODELDEF, no ZScript, no worldspace, no reloads.
Stock-parser safe for QuestZDoom -- only Path/Model/SurfaceSkin/Scale/Offset/RollOffset/FrameIndex/NOINTERPOLATION.

WHAT THIS BUILD CHANGES OVER make_sw_stock.py (build_hud):

  FRAME COVERAGE. Every sprite frame each weapon's own states show is bound (read from Wardusted's DECORATE and
      from Xim's DeHackEd frames 1100-1200). The old tables missed Bowcaster C/D/H, Disruptor E/F, DC-15 D/E,
      Z-6 D/E and E-22 C/D, so the gun flipped back to a flat sprite mid-fire.
  FIRING. Each gun is ONE animated md3 (frames below), so the engine blends the kick and the return the way it
      blends any model frame. The flash is a surface of the same mesh, parked at the muzzle when unlit.
        Wardusted bakes its flash into the fire frames (DF01 B etc. are the lit gun), so its fire frames light it.
        Xim is Doom: the flash is its own psprite layer (PISF/SHTF/CHGF/PLSF/MISF), so those frames get a
        flash-only block (gun surfaces clear), the Ermac muzzle-flash block.
  THROWABLES. The detonator leaves the hand on the throw frame instead of staying in it. Empty-hand frames
      (DF00 out of ammo, the saber throw) hide the model rather than float a flat hand in VR.
  XIM SABER. SAWG A/B both idle -- B was bound to a swing pose, so the idle twitched. Poses re-read off the sprites.
  XIM MAPPING matches Wardusted: the Heavy Blaster (Chaingun) is the DLT-19's golan_arms, the Rotary Blaster
      (PlasmaRifle) the Z-6's heavy_repeater.
  TEXTURES. concussion power32 alpha raised to opaque (it sat under the 0.5 model mask threshold and vanished);
      the disruptor's scope lens gets its own lens skin instead of falling back to the body texture.
  CORRECTPIXELSTRETCH dropped: it does nothing on HUD models (models.cpp RenderHUDModel never reads it) and an
      older Quest parser would reject the keyword.

ANIM MD3 FRAMES (guns):  0 rest | 1 kick + flash | 2 half kick | 3 thrown/hidden | 4 windup | 5 part kick + turned flash
                         | 6 rest + flash
"""
import io
import math
import os
import struct
import sys
import zipfile

SRC = sys.argv[1] if len(sys.argv) > 1 else "D:/SteamLibrary/steamapps/Common/DooM VR/__Games/Wardusted"
OUT = sys.argv[2] if len(sys.argv) > 2 else SRC

HUD_SCALE = 0.75                 # make_sw_stock.STOCK_SHRINK: the owner's size on the HUD, 2026-09-21
HUD_OFFSET = (0.0, -29.0, -8.0)  # the M4A3 HUD block's own
# UPSIDE DOWN, PER SET -- the owner in the headset: Xim's E-11 (09-21), Wardusted's E-22 (09-29). The E-22's
# mesh is also Xim's Ion Blaster, and turning it for both put the Ion Blaster upside down ("slot 3 is upside
# down", 09-29): so the roll belongs to the SET, not the mesh.
# 09-29 later: Wardusted's E-22 was upside down WITH the turn too ("that same gun is upside down") --
# the demp2 mesh is right way up as it stands, in both sets.
# 09-29, the owner's lineup: the E-11 drawn turned over is plainly upside down (grip up). Every mesh is right
# way up as make_sw_sets.py normalised it; the 09-21 turn was for an older build.
# ...and the E-22's mesh (demp2, also Xim's Ion Blaster) IS upside down as normalised: the owner's lineup,
# "second gun down in each column" -- the E-11 (turned) and the E-22 (not). So the E-22 turns, the E-11 does not.
SET_ROLL = {"wardusted": {"demp2": 180.0}, "xim": {"demp2": 180.0}}

# SURFACES A GUN DRAWS WITHOUT: the disruptor's separate barrel part, which make_sw_sets placed at the gun's own
# origin -- a second long tube under the gun (the owner: "looks like it's two guns"). The body alone is whole.
# Same story for EVERY "_barrel" part (Jedi Academy's spinning/recoiling barrel pieces): make_sw_sets left
# each one off-axis -- the Merr-Sonn's drum hangs under the gun ("is that two guns merged?"), the repeater's
# and the concussion rifle's jut out of the side. The bodies are whole without them.
HIDE_SURFACES = {"disruptor": ("models/disruptor_barrel",), "merr_sonn": ("models/merr_sonn_barrel",),
                 "heavy_repeater": ("models/heavy_repeater_barrel",), "concussion": ("models/c_rifle_barrel",)}
# EXTRA MODELDEF LINES PER MESH: the proximity mine lies flat in the hand, as the mod's sprite holds it (the
# disc faces +X; turned about its side axis it faces up)
MESH_EXTRA = {"laser_trap": ["\tPitchOffset -90"]}

# THE FIRING LINE. The owner, 09-29: "all the guns i need to move up or down some so their barrels are on the
# firing line". The M4A3 HUD block (Scale 0.82, Offset z -8) is the tuned reference; its muzzle, measured,
# sits at mesh z 3.41, so its bore is at 0.82 * 3.41 - 8 on the HUD. Every gun's Offset z is set so ITS bore
# lands at the same height: zoff = BORE - HUD_SCALE * (muzzle z, after any roll).
BORE_HEIGHT = 0.82 * 3.41 - 8.0
# THE MUZZLES, Jedi Academy's own tag_flash carried through make_sw_sets.build_mesh (the same move that made
# the meshes), clamped to the front face -- not the tip of the mesh, which on the Merr-Sonn is its top tube.
MUZZLE = {"blaster_pistol": (29.59, 0.0, 6.04), "briar_pistol": (28.27, 0.0, 5.52),
          "blaster_r": (31.60, 0.0, 6.90), "demp2": (48.21, 0.0, 10.55),
          "heavy_repeater": (68.16, 0.0, 10.26), "golan_arms": (67.59, 0.0, 29.66),
          "disruptor": (38.70, 0.0, 27.92), "bowcaster": (62.88, 0.0, 17.06),
          "merr_sonn": (80.74, 0.0, 25.99), "concussion": (62.30, 0.0, 15.67)}

# ---- per mesh: kick back (mesh units), kick pitch (deg), flash length, flash width -------------------
GUN = {
    "blaster_pistol": (2.5, 6.0, 10.0, 8.0),
    "briar_pistol":   (2.5, 6.0, 10.0, 8.0),
    "blaster_r":      (2.5, 3.0, 14.0, 10.0),
    "demp2":          (2.5, 3.0, 16.0, 13.0),
    "disruptor":      (3.0, 3.0, 16.0, 11.0),
    "concussion":     (3.0, 3.0, 16.0, 13.0),
    "golan_arms":     (2.5, 2.5, 16.0, 12.0),
    "heavy_repeater": (2.0, 1.5, 18.0, 13.0),
    "merr_sonn":      (3.0, 2.0, 20.0, 15.0),
    "bowcaster":      (3.0, 2.5, 14.0, 11.0),
    "thermal":        (0.0, 0.0, 0.0, 0.0),
    "laser_trap":     (0.0, 0.0, 0.0, 0.0),
}
WINDUP = (-6.0, 0.0, 4.0, -15.0)          # back, side, up, pitch -- the arm drawn back to throw
THROWN = (60.0, 0.0, 18.0)                # where a thrown thing leaves sight (collapsed to a point there)
TOSS_HOLD = (18.0, 0.0, -13.0)            # the off hand's detonator, under the Bowcaster's fore-end

FLASH_RGB = {"orange": (255, 150, 40), "red": (255, 40, 30), "blue": (60, 150, 255),
             "green": (60, 255, 80), "white": (200, 230, 255)}

# ZOOM: the mods swap the gun for a flat scope circle (SCOP) while zoomed. In VR the gun stays in the hand:
# every SCOP frame is bound to the gun at rest, so zooming changes nothing you see.
# ---- the sets -----------------------------------------------------------------------------------------
# rows: (class, mesh, [(sprite, frames, anim frame, flash colour or None, flags)])
#   flags: "flashonly" = gun surfaces clear (Doom flash layer); "noint" = NOINTERPOLATION block
#   frame letters sharing a (anim, colour, flags) go in one block.
WARDUST = [
    ("DL44Blaster", "blaster_pistol", [("DF01", "A", 0, "orange", ""), ("DF01", "B", 1, "orange", ""),
                                    ("SCOP", "G", 0, "orange", "")]),
    ("E11Blaster", "blaster_r", [("DF02", "A", 0, "red", ""), ("DF02", "B", 1, "red", ""),
                             ("SCOP", "E", 0, "red", "")]),
    ("DarkBlaster", "briar_pistol", [("DB02", "A", 0, "orange", ""), ("DB02", "B", 1, "orange", "")]),
    ("RebelThermalDetonator", "thermal", [("DF03", "A", 0, None, ""), ("DF03", "B", 4, None, ""),
                                          ("DF03", "C", 3, None, "noint"), ("DF00", "A", 0, None, "dim noint")]),
    # G/H: the AltFire -- the off hand brings a thermal detonator under the bow (G) and throws it (H)
    ("Bowcaster", "bowcaster", [("DF05", "AEF", 0, "orange", ""), ("DF05", "B", 1, "orange", ""),
                                ("DF05", "C", 2, "orange", ""), ("DF05", "D", 0, "orange", ""),
                                ("DF05", "G", 0, "orange", "toss0"), ("DF05", "H", 0, "orange", "toss1 noint"),
                                ("SCOP", "R", 0, "orange", "")]),
    ("ProximityMines", "laser_trap", [("DF06", "AB", 0, None, ""), ("DF00", "A", 0, None, "dim noint")]),
    ("ConcussionRifle", "concussion", [("DF08", "A", 0, "blue", ""), ("DF08", "B", 1, "blue", ""),
                                       ("DF08", "C", 2, "blue", "")]),
    ("DisruptorRifle", "disruptor", [("DRIF", "A", 0, "white", ""), ("DRIF", "BF", 1, "white", ""),
                                     ("DRIF", "CD", 2, "white", ""), ("DRIF", "E", 0, "white", ""),
                                     # A_GunFlash("ChargeFlash"): the charge glow, a flash-layer sprite -- a
                                     # muzzle glow on the resting gun instead of a flat sprite floating in VR
                                     ("HGNG", "KLMNO", 6, "white", "flashonly"),
                                     ("SCOP", "YO", 0, "white", "")]),
    ("SniperRifle", "disruptor", [("DC15", "AE", 0, "green", ""), ("DC15", "BF", 1, "green", ""),
                                  ("DC15", "C", 5, "green", ""), ("DC15", "D", 2, "green", ""),
                                  ("SCOP", "Y", 0, "green", "")]),
    ("Z6RotaryBlaster", "heavy_repeater", [("DF04", "A", 0, "blue", ""), ("DF04", "B", 1, "blue", ""),
                                           ("DF04", "C", 5, "blue", ""), ("DF04", "D", 1, "red", ""),
                                           ("DF04", "E", 5, "red", "")]),
    ("DLT19", "golan_arms", [("DLT1", "A", 0, "orange", ""), ("DLT1", "B", 1, "orange", "")]),
    ("E22Blaster", "demp2", [("DF22", "A", 0, "red", ""), ("DF22", "B", 1, "red", ""),
                             ("DF22", "C", 2, "red", ""), ("DF22", "D", 1, "green", ""),
                             ("SCOP", "Y", 0, "red", "")]),
    ("DarkAssaultCannon", "merr_sonn", [("DF09", "AEG", 0, "blue", ""), ("DF09", "BD", 1, "blue", ""),
                                        ("DF09", "C", 5, "blue", "")]),
]
# Enemy-drop weapons: empty subclasses with every state inherited. The engine finds a psprite model by the
# EXACT class (models.cpp FindModelFrameRaw, smff->type == ti), never a parent, so each needs its own blocks
# or a picked-up trooper E-11 is a flat sprite. (Enemy/StormFin, Enemy/*, 2024 pk3)
WARDUST_FAKES = {"StormDropFAKE": "E11Blaster", "ShoreDropFAKE": "E11Blaster", "TIEPILOTDropFAKE": "E11Blaster",
                 "Z6RotaryBlasterFake": "Z6RotaryBlaster", "DLT19Fake": "DLT19", "LauncherFake": "Bowcaster",
                 "Phase2DropFAKE": "ConcussionRifle"}

XIM = [
    ("Pistol", "blaster_pistol", [("PISG", "ADE", 0, "orange", "gunonly"), ("PISG", "B", 1, "orange", "gunonly"),
                                  ("PISG", "C", 2, "orange", "gunonly"),
                                  ("PISF", "A", 1, "orange", "flashonly")]),
    ("Shotgun", "blaster_r", [("SHTG", "ABCD", 0, "red", "gunonly"),
                              ("SHTF", "AB", 6, "red", "flashonly")]),
    # Ion Blaster: no A_GunFlash anywhere in its states (frames 1141-1160), so its flash is the lit B-E frames
    ("SuperShotgun", "demp2", [("SHT2", "AFGHIJ", 0, "blue", ""), ("SHT2", "B", 1, "blue", ""),
                               ("SHT2", "CD", 5, "blue", ""), ("SHT2", "E", 2, "blue", "")]),
    ("Chaingun", "golan_arms", [("CHGG", "A", 0, "orange", "gunonly"), ("CHGG", "B", 2, "orange", "gunonly"),
                                ("CHGF", "AB", 6, "orange", "flashonly")]),
    ("PlasmaRifle", "heavy_repeater", [("PLSG", "A", 0, "blue", "gunonly"), ("PLSG", "B", 2, "blue", "gunonly"),
                                       ("PLSF", "A", 6, "blue", "flashonly"), ("PLSF", "B", 5, "blue", "flashonly")]),
    # PLSF B shows while PLSG B is up: frame 5 = part kick + turned flash, near enough the half kick under it
    ("RocketLauncher", "bowcaster", [("MISG", "A", 0, "green", "gunonly"), ("MISG", "B", 1, "green", "gunonly"),
                                     ("MISF", "AC", 1, "green", "flashonly"), ("MISF", "BD", 5, "green", "flashonly")]),
    ("BFG9000", "thermal", [("BFGG", "A", 0, None, ""), ("BFGG", "B", 4, None, ""),
                            ("BFGG", "C", 3, None, "noint")]),
]

# ---- the sabers: (yaw, up) per sprite frame, read off each mod's own sprites --------------------------
SABER_REST = (0.0, 50.0)
# THE IDLE SHIMMER (09-29, "how pretty can we make the lightsabers in stock qzd"): each mod cycles its idle
# frames (Wardusted SABR D / I / H, 2 tics each; Xim SAWG A / B, 4 tics), and those frames now draw the
# blade a little thicker or thinner -- a third number, the blade's width. The engine blends model frames
# tic to tic, so the cycle becomes a living pulse on a blade that would otherwise be a painted stick.
WD_SABER = [(("SABR", f), SABER_REST) for f in "CG"] + [
    (("SABR", "D"), SABER_REST + (1.0,)), (("SABR", "I"), SABER_REST + (1.14,)),
    (("SABR", "H"), SABER_REST + (0.92,))] + [
    (("SABA", f), p) for f, p in [("A", (-15, 60)), ("B", (-30, 70)), ("C", (-40, 75)), ("D", (-45, 75)),
                                  ("E", (-40, 65)), ("F", (0, 35)), ("G", (40, 10)), ("H", (55, -5)),
                                  ("I", (35, 20)), ("J", (10, 45)), ("K", (-10, 60)), ("L", (-20, 65)),
                                  ("M", (0, 30)), ("N", (40, 5))]]
WD_SABER_HIDE = [("DF03", "C"), ("DF00", "A")]          # saber thrown (AltFire), out of ammo
# XIM (SAWG, DeHackEd 1100-1115): A/B idle, then C..K the swing: C a jab forward, E raised, F-H overhead,
# I/J chopped forward (the blade seen end-on), K back to guard. Idle A and B are the SAME pose now.
XIM_SABER = [(("SAWG", f), p) for f, p in [("A", SABER_REST + (1.0,)), ("B", SABER_REST + (1.14,)), ("C", (0, 8)),
                                            ("D", SABER_REST), ("E", (-20, 72)), ("F", (-5, 90)),
                                            ("G", (5, 80)), ("H", (10, 60)), ("I", (12, 28)),
                                            ("J", (8, 12)), ("K", SABER_REST)]]


# =======================================================================================================
# MD3
def read_md3(b):
    _, _, _, _, nf, ntag, ns, _, ofr, _, osurf, _ = struct.unpack_from("<4si64s9i", b, 0)
    surfs = []
    o = osurf
    for _ in range(ns):
        _, sname, _, snf, nsh, nv, nt, otri, osh, ost, oxyz, send = struct.unpack_from("<4s64s10i", b, o)
        shader = b[o + osh:o + osh + 64].split(b"\0")[0].decode("latin1") if nsh else ""
        tris = [struct.unpack_from("<3i", b, o + otri + 12 * k) for k in range(nt)]
        st = [struct.unpack_from("<2f", b, o + ost + 8 * k) for k in range(nv)]
        frames = []
        for f in range(snf):
            vs, ns_ = [], []
            for k in range(nv):
                x, y, z, n = struct.unpack_from("<3hH", b, o + oxyz + 8 * (f * nv + k))
                vs.append((x / 64.0, y / 64.0, z / 64.0))
                lat = ((n >> 8) & 255) * 2 * math.pi / 255
                lng = (n & 255) * 2 * math.pi / 255
                ns_.append((math.cos(lat) * math.sin(lng), math.sin(lat) * math.sin(lng), math.cos(lng)))
            frames.append((vs, ns_))
        surfs.append(dict(name=sname.split(b"\0")[0].decode("latin1"), shader=shader, tris=tris, st=st,
                          frames=frames))
        o += send
    return surfs


def enc_normal(n):
    x, y, z = n
    ln = math.sqrt(x * x + y * y + z * z) or 1.0
    x, y, z = x / ln, y / ln, z / ln
    if abs(x) < 1e-9 and abs(y) < 1e-9:
        return 0 if z > 0 else (128 << 8)
    lng = int(round(math.acos(max(-1.0, min(1.0, z))) * 255 / (2 * math.pi))) & 255
    lat = int(round(math.atan2(y, x) * 255 / (2 * math.pi))) & 255
    return (lat << 8) | lng


def write_md3(name, surfs, nf):
    """surfs: name, shader, tris, st, frames[nf] = (verts, norms). Returns the file bytes."""
    body = b""
    for s in surfs:
        nv, nt = len(s["st"]), len(s["tris"])
        o_tri = 108 + 68
        o_st = o_tri + 12 * nt
        o_xyz = o_st + 8 * nv
        o_end = o_xyz + 8 * nv * nf
        b = struct.pack("<4s64s10i", b"IDP3", s["name"].encode()[:63], 0, nf, 1, nv, nt, o_tri, 108, o_st, o_xyz,
                        o_end)
        b += struct.pack("<64si", s["shader"].encode()[:63], 0)
        b += b"".join(struct.pack("<3i", *t) for t in s["tris"])
        b += b"".join(struct.pack("<2f", *uv) for uv in s["st"])
        for f in range(nf):
            vs, ns = s["frames"][f]
            for v, n in zip(vs, ns):
                q = [max(-32768, min(32767, int(round(c * 64.0)))) for c in v]
                b += struct.pack("<3hH", q[0], q[1], q[2], enc_normal(n))
        body += b
    fr = b""
    for f in range(nf):
        allv = [v for s in surfs for v in s["frames"][f][0]]
        mn = [min(v[i] for v in allv) for i in range(3)]
        mx = [max(v[i] for v in allv) for i in range(3)]
        rad = max(math.sqrt(sum(c * c for c in v)) for v in allv)
        fr += struct.pack("<3f3f3ff16s", *mn, *mx, 0, 0, 0, rad, ("f%d" % f).encode())
    o_surf = 108 + len(fr)
    head = struct.pack("<4si64s9i", b"IDP3", 15, name.encode()[:63], 0, nf, 0, len(surfs), 0, 108, o_surf, o_surf,
                       o_surf + len(body))
    return head + fr + body


# =======================================================================================================
# transforms (mesh frame: barrel +X, up +Z, origin in the grip)
def rot_pitch(v, deg):
    """muzzle up by deg about the grip (+X toward +Z)."""
    a = math.radians(deg)
    x, y, z = v
    return (x * math.cos(a) - z * math.sin(a), y, x * math.sin(a) + z * math.cos(a))


def kicked(v, back, pitch):
    x, y, z = rot_pitch(v, pitch)
    return (x - back, y, z)


def saber_pose(v, yaw, up):          # make_sw_stock._pose
    x, y, z = v
    u, a = math.radians(up), math.radians(yaw)
    x, z = x * math.cos(u) - z * math.sin(u), x * math.sin(u) + z * math.cos(u)
    x, y = x * math.cos(a) + y * math.sin(a), -x * math.sin(a) + y * math.cos(a)
    return (x, y, z)


def saber_unpose(v, yaw, up):
    x, y, z = v
    u, a = math.radians(up), math.radians(yaw)
    x, y = x * math.cos(a) - y * math.sin(a), x * math.sin(a) + y * math.cos(a)
    x, z = x * math.cos(u) + z * math.sin(u), -x * math.sin(u) + z * math.cos(u)
    return (x, y, z)


def muzzle_of(surfs, mesh=None):
    vs = [v for s in surfs for v in s["frames"][0][0]]
    if mesh in MUZZLE:
        # ON THE BORE (tag_flash's line), and as far forward as the gun reaches ALONG it -- the repeater's
        # barrel part runs past where Jedi Academy parked its tag
        _, my, mz = MUZZLE[mesh]
        near = [v[0] for v in vs if (v[1] - my) ** 2 + (v[2] - mz) ** 2 < 9.0]
        return (max(near) if near else MUZZLE[mesh][0], my, mz)
    mx = max(v[0] for v in vs)
    tip = [v for v in vs if v[0] > mx - 1.5]
    # the middle of the front face, not the average of its vertices (the Golan's face is one big slab and
    # its vertices bunch at the top corner)
    return (mx, (min(v[1] for v in tip) + max(v[1] for v in tip)) / 2, (min(v[2] for v in tip) + max(v[2] for v in tip)) / 2)


def flash_surface(muzzle, length, width):
    """Three crossed quads: two along the barrel (a flame seen from the side), one facing forward (the star).
    Both windings, so it shows from either side with culling on. Returns (surface, rest verts, norms)."""
    mx, my, mz = muzzle
    h = width / 2.0
    quads = [
        # along X, in the XZ plane
        [(mx, my, mz - h), (mx + length, my, mz - h), (mx + length, my, mz + h), (mx, my, mz + h)],
        # along X, in the XY plane
        [(mx, my - h, mz), (mx + length, my - h, mz), (mx + length, my + h, mz), (mx, my + h, mz)],
        # facing forward, in the YZ plane, a little out from the muzzle
        [(mx + 1.0, my - h, mz - h), (mx + 1.0, my + h, mz - h), (mx + 1.0, my + h, mz + h), (mx + 1.0, my - h, mz + h)],
    ]
    uv_side = [(0.5, 1.0), (1.0, 1.0), (1.0, 0.0), (0.5, 0.0)]     # right half of the skin: the side flame
    uv_face = [(0.0, 1.0), (0.5, 1.0), (0.5, 0.0), (0.0, 0.0)]     # left half: the star
    verts, st, tris, norms = [], [], [], []
    for qi, q in enumerate(quads):
        base = len(verts)
        uvs = uv_face if qi == 2 else uv_side
        nrm = [(0, 1, 0), (0, 0, 1), (1, 0, 0)][qi]
        for v, uv in zip(q, uvs):
            verts.append(v); st.append(uv); norms.append(nrm)
        tris += [(base, base + 1, base + 2), (base, base + 2, base + 3),
                 (base, base + 2, base + 1), (base, base + 3, base + 2)]
    return dict(name="muzzleflash", shader="flash.png", tris=tris, st=st), verts, norms


def turn_flash(verts, muzzle, deg, scale):
    """the flash spun about the barrel and scaled about the muzzle -- a second look for alternate fire frames."""
    mx, my, mz = muzzle
    a = math.radians(deg)
    out = []
    for x, y, z in verts:
        dx, dy, dz = (x - mx) * scale, (y - my) * scale, (z - mz) * scale
        dy, dz = dy * math.cos(a) - dz * math.sin(a), dy * math.sin(a) + dz * math.cos(a)
        out.append((mx + dx, my + dy, mz + dz))
    return out


def build_gun_anim(surfs, mesh):
    """rest | kick+flash | half kick | thrown | windup | part kick+turned flash | rest+flash"""
    back, pitch, flen, fwid = GUN[mesh]
    gun = [s for s in surfs if s["st"]]
    muzzle = muzzle_of(gun, mesh)
    has_flash = flen > 0
    if has_flash:
        fsurf, fverts, fnorms = flash_surface(muzzle, flen, fwid)
    rest = [(list(s["frames"][0][0]), list(s["frames"][0][1])) for s in gun]
    shut = [muzzle] * (len(fverts) if has_flash else 0)       # an unlit flash: every corner at the muzzle

    def pose(fn_v, fn_n, flash_v):
        fr = [([fn_v(v) for v in vs], [fn_n(n) for n in ns]) for vs, ns in rest]
        if has_flash:
            fr.append(([fn_v(v) for v in flash_v], [fn_n(n) for n in fnorms]))
        return fr

    ident = lambda v: v
    k1 = lambda v: kicked(v, back, pitch)
    k1n = lambda n: rot_pitch(n, pitch)
    k2 = lambda v: kicked(v, back * 0.5, pitch * 0.5)
    k2n = lambda n: rot_pitch(n, pitch * 0.5)
    k5 = lambda v: kicked(v, back * 0.7, pitch * 0.7)
    k5n = lambda n: rot_pitch(n, pitch * 0.7)
    wb, ws, wu, wp = WINDUP
    wv = lambda v: (lambda r: (r[0] + wb, r[1] + ws, r[2] + wu))(rot_pitch(v, wp))
    wn = lambda n: rot_pitch(n, wp)
    gone = lambda v: THROWN

    frames = [
        pose(ident, ident, shut),                                           # 0 rest
        pose(k1, k1n, fverts if has_flash else []),                         # 1 kick + flash
        pose(k2, k2n, shut),                                                # 2 half kick
        pose(gone, ident, shut),                                            # 3 thrown / hidden
        pose(wv, wn, shut),                                                 # 4 windup
        pose(k5, k5n, turn_flash(fverts, muzzle, 45, 0.8) if has_flash else []),  # 5 part kick + turned flash
        pose(ident, ident, fverts if has_flash else []),                    # 6 rest + flash
    ]
    out = []
    for i, s in enumerate(gun):
        out.append(dict(name=s["name"][:63], shader=s["shader"], tris=s["tris"], st=s["st"],
                        frames=[fr[i] for fr in frames]))
    if has_flash:
        out.append(dict(fsurf, frames=[fr[len(gun)] for fr in frames]))
    return out, len(gun), has_flash


def build_saber_anim(surfs, rest_frame, poses):
    """Recover the saber's un-posed mesh from the old build's rest frame, then pose it per sprite frame.
    Adds a last frame collapsed out of sight (thrown / hidden). Returns (surfs, {pose: frame}, hidden frame)."""
    base = [([saber_unpose(v, *SABER_REST) for v in s["frames"][rest_frame][0]],
             [saber_unpose(n, *SABER_REST) for n in s["frames"][rest_frame][1]]) for s in surfs]
    order = []
    for _, p in poses:
        if p not in order:
            order.append(p)
    def widen(i, vs, w):
        # the BLADE's surfaces (the hilt is the first five), thickened about its own axis (+X in this frame)
        if i < 5 or w == 1.0:
            return vs
        return [(x, y * w, z * w) for (x, y, z) in vs]
    frames = [[([saber_pose(v, *p[:2]) for v in widen(i, vs, p[2] if len(p) > 2 else 1.0)],
                [saber_pose(n, *p[:2]) for n in ns]) for i, (vs, ns) in enumerate(base)] for p in order]
    frames.append([([THROWN] * len(vs), ns) for vs, ns in base])
    out = [dict(name=s["name"][:63], shader=s["shader"], tris=s["tris"], st=s["st"],
                frames=[fr[i] for fr in frames]) for i, s in enumerate(surfs)]
    return out, {p: i for i, p in enumerate(order)}, len(order)


# =======================================================================================================
# skins
def png(img):
    b = io.BytesIO()
    img.save(b, "PNG")
    return b.getvalue()


def flash_png(rgb):
    """left half the star seen head-on, right half the flame seen from the side. Hard alpha: the model mask
    (gl_mask_threshold, 0.5) would cut a soft edge anyway."""
    from PIL import Image, ImageDraw
    W = 128
    img = Image.new("RGBA", (W, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    r, g, b = rgb
    hot = tuple(min(255, int(c * 0.35 + 255 * 0.65)) for c in rgb)
    # star, centred in the left 64x64
    cx, cy = 32, 32
    for rad, col in ((31, (r, g, b, 255)), (17, hot + (255,)), (8, (255, 255, 255, 255))):
        pts = []
        for i in range(16):
            a = math.pi * 2 * i / 16
            rr = rad if i % 2 == 0 else rad * 0.42
            pts.append((cx + rr * math.cos(a), cy + rr * math.sin(a)))
        d.polygon(pts, fill=col)
    # side flame, right 64x64: muzzle at the left edge (u=0.5), tip at the right (u=1.0)
    ox = 64

    def flame(scale, col):
        pts = [(ox, 32 - 14 * scale), (ox + 20 * scale, 32 - 18 * scale), (ox + 36 * scale, 32 - 9 * scale),
               (ox + 62 * scale, 32), (ox + 36 * scale, 32 + 9 * scale), (ox + 20 * scale, 32 + 18 * scale),
               (ox, 32 + 14 * scale)]
        d.polygon(pts, fill=col)
    flame(1.0, (r, g, b, 255))
    flame(0.7, hot + (255,))
    flame(0.4, (255, 255, 255, 255))
    return png(img)


def dim_png(data):
    """An empty weapon's skin: desaturated, a third as bright."""
    from PIL import Image, ImageEnhance
    im = Image.open(io.BytesIO(data)).convert("RGBA")
    a = im.getchannel("A")
    im = ImageEnhance.Brightness(ImageEnhance.Color(im.convert("RGB")).enhance(0.15)).enhance(0.35).convert("RGBA")
    im.putalpha(a)
    b = io.BytesIO(); im.save(b, "PNG"); return b.getvalue()


def clear_png():
    from PIL import Image
    return png(Image.new("RGBA", (8, 8), (0, 0, 0, 0)))


def lens_png():
    from PIL import Image, ImageDraw
    img = Image.new("RGBA", (32, 32), (8, 14, 12, 255))
    d = ImageDraw.Draw(img)
    d.ellipse((4, 4, 27, 27), fill=(20, 60, 45, 255))
    d.ellipse((9, 8, 15, 14), fill=(120, 200, 170, 255))
    return png(img)


def opaque(data):
    from PIL import Image
    im = Image.open(io.BytesIO(data)).convert("RGBA")
    im.putalpha(255)
    return png(im)


# =======================================================================================================
# THE LONG GUNS, SMALLER (09-29, the owner: "some of the same models in each set are huge"). They are drawn at
# their real lengths -- the repeater and the Merr-Sonn a metre, the disruptor 95 cm, the Golan a tall slab --
# and next to the pistols they fill the view. Pistols and rifles stay as they were; these shrink.
MESH_SCALE = {"heavy_repeater": 0.68, "merr_sonn": 0.46, "golan_arms": 0.46, "disruptor": 0.72,
              "concussion": 0.56, "bowcaster": 0.78}


def gun_scale(mesh):
    return HUD_SCALE * MESH_SCALE.get(mesh, 1.0)


def bore_offset(mesh, roll):
    """HUD Offset for a gun: the M4A3's x and y, and a z that puts this gun's bore on the M4A3's."""
    if mesh not in MUZZLE:
        return HUD_OFFSET
    mz = MUZZLE[mesh][2] * (-1.0 if abs(roll - 180.0) < 1.0 else 1.0)
    return (HUD_OFFSET[0], HUD_OFFSET[1], BORE_HEIGHT - gun_scale(mesh) * mz)


def block(cls, path, mdl, skins, frames, flags, extra=(), second=None, offset=HUD_OFFSET, scale=None):
    """second: (md3, [(surface, skin)], frame) -- a second model drawn in the same block (the toss detonator)."""
    lines = ["Model %s" % cls, "{", '\tPath "%s"' % path, '\tModel 0 "%s"' % mdl]
    if second:
        lines.append('\tModel 1 "%s"' % second[0])
    lines += ['\tSurfaceSkin 0 %d "%s"' % (i, sk) for i, sk in skins]
    if second:
        lines += ['\tSurfaceSkin 1 %d "%s"' % (i, sk) for i, sk in second[1]]
    sc = HUD_SCALE if scale is None else scale
    lines += ["\tScale %.3f %.3f %.3f" % (-sc, sc, sc),
              "\tOffset %.2f %.2f %.2f" % offset]
    lines += list(extra)
    if "noint" in flags:
        lines.append("\tNOINTERPOLATION")
    lines.append("")
    lines += ["\tFrameIndex %s %s 0 %d" % f for f in frames]
    if second:
        lines += ["\tFrameIndex %s %s 1 %d" % (s, L, second[2]) for s, L, _ in frames]
    return lines + ["}", ""]


NO_EMPTY = {"wardusted": ("RebelThermalDetonator", "ProximityMines")}
EMPTY_ZS = r"""version "4.10"
// GENERATED by make_sw_vrplus.py -- empty grenades and mines out of the weapon cycle (sw_skip_empty).
class SWVR_EmptySkip : EventHandler
{
	override void WorldTick()
	{
		if ((level.maptime %% 5) != 0) return;
		let sc = CVar.FindCVar("sw_skip_empty");
		bool skip = !sc || sc.GetBool();
		Array<String> names;
		String list = "%s";
		list.Split(names, " ", TOK_SKIPEMPTY);
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo || players[i].health <= 0) continue;
			let p = players[i];
			for (int k = 0; k < names.Size(); k++)
			{
				class<Actor> c = names[k];
				let wc = (class<Weapon>)(c);
				if (!wc) continue;
				let w = Weapon(p.mo.FindInventory(wc));
				if (!w) continue;
				w.bAMMO_OPTIONAL = !skip;
				w.bALT_AMMO_OPTIONAL = !skip;
				if (skip && p.ReadyWeapon == w && p.PendingWeapon == WP_NOCHANGE
					&& !w.CheckAmmo(Weapon.EitherFire, false))
					p.mo.PickNewWeapon(null);
			}
		}
	}
}
"""


# FROM THE BARREL (the owner, 10-01: "projectiles come from the barrel and not off to the side ... one rapid
# fire weapon"). QuestZDoom spawns a weapon's missile at the CONTROLLER, plus the mod's own sideways and height
# offsets -- written for a flat screen, where the gun sprite sits low and right: Wardust's Z-6 puts every bolt 6
# units to the right, the E-11, DL-44 and Bowcaster 5, the detonators 10 right and 5 up. This moves each one, the
# tic it is born, to the muzzle of the gun drawn in that hand: out along its own line of flight by the gun's
# reach, sideways and up by nothing. The reach is the HUD model's own (models.cpp RenderHUDModel): a mesh point x
# sits Scale * x * vr_weaponScale - 1 model units in front of the controller, and a model unit is a centimetre
# (vr_vunits_per_meter / 100 map units). Never through a wall: traced from the hand first.
MUZZLE_ZS = r"""
class SWVR_Muzzle : EventHandler
{
	static double Reach(String cls)
	{
		static const String C[] = { %(names)s };
		static const double R[] = { %(reach)s };
		for (int i = 0; i < C.Size(); i++) if (C[i] ~== cls) return R[i];
		return -1;
	}
	static double CF(String n, double fb) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : fb; }

	override void WorldThingSpawned(WorldEvent e)
	{
		let mo = e.Thing;
		// a projectile, OR one of the mod's look-alike "Fake" bolts fired beside the real one (Wardust's burst
		// blaster fires BlasterRedBoltFake with every shot; it is not a missile, so it stayed in the hand and
		// came out of the back of the gun -- the owner, 10-01)
		if (!mo || !mo.target || !mo.target.player) return;
		String cn = mo.GetClassName();
		cn = cn.MakeLower();
		if (!mo.bMissile && cn.IndexOf("fake") < 0) return;
		let pl = mo.target.player;
		let pmo = pl.mo;
		if (!pmo) return;
		let on = CVar.FindCVar("sw_from_barrel");
		if (on && !on.GetBool()) return;
		// WHICH HAND: the one it was born beside (the mod's offsets are at most a dozen units)
		double da = level.Vec3Diff(pmo.AttackPos, mo.pos).Length();
		double dof = level.Vec3Diff(pmo.OffhandPos, mo.pos).Length();
		int hand = (dof < da) ? 1 : 0;
		if (min(da, dof) > 40.0) return;
		Weapon w = hand ? pl.OffhandWeapon : pl.ReadyWeapon;
		if (!w) return;
		double cm = Reach(String.Format("%%s", w.GetClassName()));
		if (cm < 0) return;
		Vector3 hp = hand ? pmo.OffhandPos : pmo.AttackPos;
		Vector3 dir;
		if (mo.vel.Length() > 0.01) dir = mo.vel.Unit();
		else dir = (cos(mo.angle) * cos(mo.pitch), sin(mo.angle) * cos(mo.pitch), -sin(mo.pitch));
		double reach = max(0.0, cm * CF("vr_weaponScale", 1.02) - 1.0 - CF("vr_3dweaponOffsetZ", 0)) * CF("vr_vunits_per_meter", 34.0) / 100.0;
		Vector3 at = hp + dir * reach;
		let tr = new("SWVR_WallTrace");
		if (tr.Trace(hp, level.PointInSector(hp.xy), dir, reach, 0, 0xFFFFFFFF, true) && tr.Results.HitType != TRACE_HitNone)
			at = hp + dir * max(0.0, tr.Results.Distance - mo.radius - 1.0);
		mo.SetOrigin(at, false);
		mo.ClearInterpolation();
	}
}
class SWVR_WallTrace : LineTracer
{
	override ETraceStatus TraceCallback() { return (Results.HitType == TRACE_HitActor) ? TRACE_Skip : TRACE_Stop; }
}
"""


def muzzle_zs(rows):
    """The table: every weapon class drawn by a gun mesh, and how far in front of the controller (model units,
    before vr_weaponScale) that mesh's muzzle sits."""
    names, reach = [], []
    for cls, mesh, _ in rows:
        if mesh not in MUZZLE and mesh not in ("thermal",):
            continue
        mx = MUZZLE[mesh][0] if mesh in MUZZLE else 5.5
        names.append('"%s"' % cls)
        reach.append("%.2f" % (gun_scale(mesh) * mx))
    return MUZZLE_ZS % dict(names=", ".join(names), reach=", ".join(reach))


def build(name, title, rows, saber_cls, saber_poses, saber_hide, src_zip, out_dir, fakes=None, setname="",
          projectiles=(), glow=None):
    """glow: the mod saber's colour name ("red" / "blue") -- turns on SW SaberPlus for this pack."""
    z = zipfile.ZipFile(src_zip)
    rows = list(rows) + [(fake, mesh, fr) for fake, parent in (fakes or {}).items()
                         for cls, mesh, fr in rows if cls == parent]
    files = {}
    o = ["// " + "=" * 96,
         "// %s" % title,
         "//",
         "// GENERATED by make_sw_vrplus.py -- traditional VR weapons: psprite models, plain MODELDEF, no ZScript.",
         "// Geometry: Vince Crusty and Elin's VR Fully Modeled Weapons Pack (Jedi Academy), normalised by",
         "// make_sw_sets.py; skins Jedi Academy's own. Each gun is one animated md3 -- 0 rest, 1 kick+flash,",
         "// 2 half kick, 3 thrown/hidden, 4 windup, 5 part kick+turned flash, 6 rest+flash -- so the engine",
         "// blends the kick. Every sprite frame the weapon's own states show is bound.",
         "// " + "=" * 96, ""]

    for cls, mesh, frames in rows:
        folder = "models/sw/%s" % mesh
        src = read_md3(z.read("%s/%s_wm.md3" % (folder, mesh)))
        surfs, ngun, has_flash = build_gun_anim(src, mesh)
        mdl = "%s_vr.md3" % mesh
        if folder + "/" + mdl not in files:
            files[folder + "/" + mdl] = write_md3(mesh + "_vr", surfs, 7)
            for s in surfs[:ngun]:
                tex = s["shader"]
                if tex.startswith("models/"):          # the disruptor's scope lens: no Jedi Academy image
                    continue
                data = z.read("%s/%s" % (folder, tex))
                files["%s/%s" % (folder, tex)] = opaque(data) if tex == "power32.png" else data
        gun_skins = []
        for i, s in enumerate(surfs[:ngun]):
            if s["name"] in HIDE_SURFACES.get(mesh, ()):
                files[folder + "/clear.png"] = clear_png()
                gun_skins.append((i, "clear.png"))
            elif s["shader"].startswith("models/"):
                files["%s/lens.png" % folder] = lens_png()
                gun_skins.append((i, "lens.png"))
            else:
                gun_skins.append((i, s["shader"]))
        # group frames into blocks by (anim frame, colour, flags)
        groups = {}
        for spr, letters, af, col, flags in frames:
            groups.setdefault((af, col, flags), []).extend((spr, L, af) for L in letters)
        roll = SET_ROLL.get(setname, {}).get(mesh, 0.0)
        extra = (['\tRollOffset %.1f' % roll] if roll else []) + MESH_EXTRA.get(mesh, [])
        offset = bore_offset(mesh, roll)
        o.append("// %s -- %s" % (cls, mesh))
        for (af, col, flags), fl in groups.items():
            skins = list(gun_skins)
            # every skin lives in the gun's own folder: SurfaceSkin names resolve against Path, no "../"
            if "flashonly" in flags:
                files[folder + "/clear.png"] = clear_png()
                skins = [(i, "clear.png") for i, _ in gun_skins]
            # EMPTY-HANDED: Wardusted STARTS you with the thermal and the mines but no Detonators / IMMines,
            # so their Ready is DF00 (a bare hand). The owner, 09-29: "why do i start with thermal detonator and
            # prox in my inventory and no weapon models?" -- show the prop at rest, dark and grey, so the
            # slot reads "you have this, it's empty" instead of an invisible weapon.
            if "dim" in flags:
                dimmed = []
                for i, sk in skins:
                    if sk.endswith(".png") and sk not in ("clear.png", "lens.png") or sk.endswith(".jpg"):
                        dn = sk.rsplit(".", 1)[0] + "_empty.png"
                        files["%s/%s" % (folder, dn)] = dim_png(files.get("%s/%s" % (folder, sk)) or z.read("%s/%s" % (folder, sk)))
                        dimmed.append((i, dn))
                    else:
                        dimmed.append((i, sk))
                skins = dimmed
            if has_flash:
                if col and "gunonly" not in flags:
                    fname = "flash_%s.png" % col
                    files[folder + "/" + fname] = flash_png(FLASH_RGB[col])
                    skins.append((ngun, fname))
                else:
                    files[folder + "/clear.png"] = clear_png()
                    skins.append((ngun, "clear.png"))
            second = None
            if "toss" in flags:
                toss = "thermal_toss.md3"
                if folder + "/" + toss not in files:
                    th = [s for s in read_md3(z.read("models/sw/thermal/thermal_wm.md3")) if s["st"]]
                    hold = [(v[0] + TOSS_HOLD[0], v[1] + TOSS_HOLD[1], v[2] + TOSS_HOLD[2])
                            for s in th for v in s["frames"][0][0]]
                    out, k = [], 0
                    for s in th:
                        n = len(s["st"])
                        out.append(dict(name=s["name"], shader=s["shader"], tris=s["tris"], st=s["st"],
                                        frames=[(hold[k:k + n], s["frames"][0][1]), ([THROWN] * n, s["frames"][0][1])]))
                        k += n
                    files[folder + "/" + toss] = write_md3("thermal_toss", out, 2)
                    files[folder + "/thermal.png"] = z.read("models/sw/thermal/thermal.png")
                second = (toss, [(0, "thermal.png"), (1, "thermal.png")], 1 if "toss1" in flags else 0)
            # THE REST POSE DOES NOT BLEND TOWARD WHAT COMES NEXT. A fire sequence ends on a rest frame
            # followed by a zero-length ReFire state on a KICK frame (Xim's pistol: PISG A 2, PISG B 0), and
            # a model blends toward the next state's frame -- so the gun eased back into the kick and
            # snapped home: the owner's "hiccup" (09-29). Rest never blends; the kick lands the tic you
            # fire, and the recovery still blends, because it lives in the recover frames' blocks.
            # (Not the Bowcaster's toss: its G must blend into H, that IS the throw.)
            if af == 0 and "toss" not in flags and "noint" not in flags:
                flags = flags + " noint"
            o += block(cls, folder, mdl, skins, fl, flags, extra, second, offset, gun_scale(mesh))

    # ---- the saber -------------------------------------------------------------------------------------
    old = read_md3(z.read("models/sw/saber/saber_anim.md3"))
    # the old build's REST frame: Wardusted put its SABR frames first (frame 0); Xim bound SAWG C to it (frame 2)
    rest_frame = 0 if saber_cls == "Lightsaber" else 2
    surfs, frame_of, hidden = build_saber_anim(old, rest_frame, saber_poses)
    files["models/sw/saber/saber_vr.md3"] = write_md3("saber_vr", surfs, hidden + 1)
    # the old anim mesh names each surface's own skin: hilt saber.jpg, blade core / inner / colour, clear halos
    skins = [(i, s["shader"]) for i, s in enumerate(surfs)]
    for _, sk in skins:
        files["models/sw/saber/" + sk] = z.read("models/sw/saber/" + sk)
    saber_skins = list(skins)
    o.append("// %s -- one animated mesh, the hilt and a lit blade posed per sprite frame" % saber_cls)
    # THE SABER'S OWN SCALE (make_sw_stock build_hud's s2), not the guns' 0.75 -- which drew it half size
    o += block(saber_cls, "models/sw/saber", "saber_vr.md3", skins,
               [(spr, f, frame_of[p]) for (spr, f), p in saber_poses], "", scale=1.608)
    if saber_hide:
        o += block(saber_cls, "models/sw/saber", "saber_vr.md3", skins,
                   [(spr, f, hidden) for spr, f in saber_hide], "noint", scale=1.608)

    # ---- the thrown things, in the WORLD: a model the whole way, like the Brutal Doom grenade -----------
    # The owner, 09-29: "can the thermal detonator be a model the entire time instead of fading into a
    # sprite? see BD grenade". Each projectile class the mod throws is bound on its flight sprite to the
    # held mesh's rest frame, tumbling. Exact class, as every model lookup is -- hence the long lists.
    for classes, spr, letters, mesh, scale, extra_lines in projectiles:
        folder = "models/sw/%s" % mesh
        mdl = "%s_vr.md3" % mesh
        if folder + "/" + mdl not in files:
            continue
        body = [s for s in read_md3(files[folder + "/" + mdl]) if s["st"]]
        skins = [(i, s["shader"]) for i, s in enumerate(body) if not s["shader"].startswith("models/")
                 and s["shader"] != "flash.png"]
        o.append("// thrown %s -- %d classes" % (mesh, len(classes)))
        for cls in classes:
            o += ["Model %s" % cls, "{", '\tPath "%s"' % folder, '\tModel 0 "%s"' % mdl]
            o += ['\tSurfaceSkin 0 %d "%s"' % (i, sk) for i, sk in skins]
            if any(s["shader"] == "flash.png" for s in body):
                files[folder + "/clear.png"] = clear_png()
                o.append('\tSurfaceSkin 0 %d "clear.png"' % [s["shader"] for s in body].index("flash.png"))
            o += ["\tScale %.2f %.2f %.2f" % (scale, scale, scale)] + list(extra_lines) + [""]
            o += ["\tFrameIndex %s %s 0 0" % (spr, L) for L in letters]
            o += ["}", ""]

    # ---- THE SABER, AS PRETTY AS STOCK QUESTZDOOM ALLOWS ---------------------------------------------
    # 1. THE BLADE IS LIGHT, NOT PAINT: a brightmap on its three skins draws it fullbright whatever the
    #    room's light -- Xim's saber frames are not Bright, so its blade went grey in the dark. The hilt
    #    keeps the room's light (on Wardusted its frames are Bright anyway).
    # 2. IT LIGHTS THE ROOM: whoever holds it carries a pulsing light in its colour, at hand height a step
    #    ahead. A plain actor moved by an EventHandler, off nothing but the playsim -- every machine sees
    #    every player's saber glow in netplay. GZDoom 3.x ZScript and GLDEFS, nothing newer.
    if glow:
        # ---- THE SABER, AS PRETTY AND AS PLAYABLE AS STOCK QUESTZDOOM 17.x ALLOWS -------------------------
        # SW SaberPlus (sw_saberplus.py): the mod's saber becomes a ZScript weapon -- size / colour menu,
        # ignition, alt fire (second blade or throw), deflection, a second saber, blade lights. The mod's own
        # saber keeps its HUD model above (used when sw_saberplus is off), with its blade fullbright.
        import sw_saberplus as SP
        from PIL import Image
        bm = io.BytesIO()
        Image.new("RGB", (8, 8), (255, 255, 255)).save(bm, "PNG")
        files["models/sw/saber/blade_bm.png"] = bm.getvalue()
        g = ["// GENERATED by make_sw_vrplus.py -- the mod saber's blade is fullbright.", ""]
        for sk in sorted({sk for i, sk in saber_skins if i >= 5 and "clear" not in sk}):
            g += ['brightmap texture "models/sw/saber/%s"' % sk, "{", '\tmap "models/sw/saber/blade_bm.png"', "}", ""]
        # SW SABERPLUS SHIPS AS ITS OWN ADD-ON PACK (the owner, 09-29: "just make our saber shit an addon pk3"):
        # SW_SaberPlus_<Mod>.pk3, loaded after SW_VR_<Mod>.pk3. Without it the mod's own saber keeps the HUD
        # model above. Everything SaberPlus writes goes into sfiles / so, nothing into this pack.
        sfiles, so = {}, ["// " + "=" * 96,
                          "// SW SABERPLUS for %s -- GENERATED by make_sw_vrplus.py + sw_saberplus.py." % setname,
                          "// SW QUESTSABER, the lightsaber add-on: load it after SW_VR_%s.pk3." % setname.capitalize(),
                          "// " + "=" * 96, ""]
        zs, cv, md, mi, gl, snd = SP.add(sfiles, so, z, setname, read_md3, write_md3, (saber_pose, saber_unpose),
                                         clear_png, rest_frame, glow)
        files["GLDEFS"] = ("\n".join(g) + "\n").encode("utf-8")
        sfiles["GLDEFS"] = gl.encode("utf-8")
        sfiles["zscript.txt"] = zs.encode("utf-8")
        sfiles["CVARINFO"] = cv.encode("utf-8")
        sfiles["MENUDEF"] = md.encode("utf-8")
        sfiles["MAPINFO"] = mi.encode("utf-8")
        sfiles["SNDINFO"] = snd.encode("utf-8")
        sfiles["MODELDEF"] = "\n".join(so).encode("utf-8")
        # THE SABER NEEDS A SLOT. Wardusted's KEYCONF rewrites slot 1 with SetSlot (RebelFists Lightsaber), which
        # overrides Weapon.SlotNumber -- so once the bridge swapped their saber for ours, key 1 never reached it
        # (the owner, 09-29: "i cannot find the saber now"; idkfa skipped it too). AddSlot runs after their
        # SetSlot and puts it back. Wardusted only: Xim sets no local slots, and its saber gets slot 1 from
        # Weapon.SlotNumber, which is filled in for weapons no class slot names.
        if setname == "wardusted":
            sfiles["KEYCONF"] = b"AddSlot 1 SWSP_Saber\nAddSlotDefault 1 SWSP_Saber\n"
        sname = "SW_QuestSaber_%s.pk3" % setname.capitalize()
        with zipfile.ZipFile(os.path.join(out_dir, sname), "w", zipfile.ZIP_DEFLATED) as zo:
            for k in sorted(sfiles):
                zo.writestr(k, sfiles[k])
        print("%-22s %3d entries -> %s" % (sname, len(sfiles), os.path.join(out_dir, sname)))

    # ---- THE WEAPONS PACK'S OWN OPTIONS: grenades and mines you have none of drop out of the cycle -----
    # Wardusted starts you "holding" the thermal detonator and the mines with no ammo for either (+AMMO_OPTIONAL):
    # an empty hand in slot 8. The owner, 09-29: "why do i even switch to shit i don't have". While
    # sw_skip_empty is on they leave the cycle until you pick some up, and you leave them when you throw the last.
    zs = 'version "4.10"\n'
    handlers = ["SWVR_Muzzle"]
    cvars = ["server bool sw_from_barrel = true;"]
    menu = ['\tOption "Shots leave from the barrel", "sw_from_barrel", "OnOff"']
    if setname in NO_EMPTY:
        zs += (EMPTY_ZS % " ".join(NO_EMPTY[setname])).replace('version "4.10"\n', "")
        handlers.append("SWVR_EmptySkip")
        cvars.append("server bool sw_skip_empty = true;")
        menu.append('\tOption "Skip grenades/mines with no ammo", "sw_skip_empty", "OnOff"')
    zs += muzzle_zs(rows)
    files["zscript.txt"] = zs.encode("utf-8")
    files["CVARINFO"] = ("\n".join(cvars) + "\n").encode("utf-8")
    files["MAPINFO"] = ('GameInfo\n{\n\tAddEventHandlers = %s\n}\n' % ", ".join('"%s"' % h for h in handlers)).encode("utf-8")
    files["MENUDEF"] = ('OptionMenu "SWVR_Options"\n{\n\tTitle "%s VR WEAPON OPTIONS"\n' % setname.upper()
                        + "\n".join(menu) + '\n}\nAddOptionMenu "OptionsMenu"\n{\n\tSubmenu "%s VR Weapon Options", "SWVR_Options"\n}\n'
                        % setname.capitalize()).encode("utf-8")

    # ---- THE FIST: ERMAC'S HAND (the owner, 10-01: "we will need hands taken from ... forceunleashed, Ermac
    # hands ... at least for the melee fist", "in all packs"). Rusted Legacy's hand.md3, cut to four frames
    # (0 relaxed, 1 fist, 2 jab, 3 open) by hand/ (CREDIT.txt), on Ermac's own HUD numbers. In VR your arm is
    # the punch, so the fist stays in the hand: the wind-up clenches, the hit is a short jab, then back.
    hand_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "hand")
    files["models/swvr/hand/ermac_hand.md3"] = open(os.path.join(hand_dir, "ermac_hand.md3"), "rb").read()
    files["models/swvr/hand/ermac_hand.png"] = open(os.path.join(hand_dir, "ermac_hand.png"), "rb").read()
    fist_cls, fist_spr = FIST[setname]
    o += ["// THE FIST: Ermac's hand (Rusted Legacy). Ready relaxed, wind-up a fist, the hit a jab.",
          "Model %s" % fist_cls, "{", '\tPath "models/swvr/hand"', '\tModel 0 "ermac_hand.md3"',
          '\tSkin 0 "ermac_hand.png"', "\tScale -1.0 1.0 1.0", "\tOffset 0.0 -24.0 -10.0", "",
          "\tFrameIndex %s A 0 0" % fist_spr, "\tFrameIndex %s B 0 1" % fist_spr,
          "\tFrameIndex %s C 0 2" % fist_spr, "\tFrameIndex %s D 0 1" % fist_spr, "}", ""]
    files["MODELDEF"] = "\n".join(o).encode("utf-8")
    dest = os.path.join(out_dir, name)
    with zipfile.ZipFile(dest, "w", zipfile.ZIP_DEFLATED) as zo:
        for k in sorted(files):
            zo.writestr(k, files[k])
    print("%-22s %3d entries -> %s" % (name, len(files), dest))
    return dest


# THE FISTS: Wardusted's RebelFists (DF00 A ready, B wind-up, C hit, D follow-through); Xim's is Doom's own Fist
# (PUNG A-D, the same order).
FIST = {"wardusted": ("RebelFists", "DF00"), "xim": ("Fist", "PUNG")}

# THE THROWN THINGS: (classes, flight sprite, frames, mesh, world Scale, extra MODELDEF lines).
# Scale: the detonator is ~9 cm, 11 mesh units; 0.45 draws it ~5 map units, big enough to follow in flight.
TUMBLE = ["\tROTATING", "\tRotation-Speed 12", "\tRotation-Vector 1 0.35 0"]     # ~2 turns a second
WD_THROWN = [
    (["ThermalDetonator"] + ["ThermalDetonator%d" % n for n in range(16, 36)] +
     ["BonceThermalDetonator"] + ["BonceThermalDetonator%d" % n for n in range(16, 36)] +
     ["ReeYeesDetonator"], "DFP4", "M", "thermal", 0.45, TUMBLE),
    # THE PLACED MINE lies on the floor: the laser trap is a disc facing +X, so it is turned face-up
    (["IMMineInstantaneous", "IMMinePermanent"], "DFP5", "A", "laser_trap", 0.5,
     ["\tPitchOffset 90", "\tZOffset 1"]),
]
# Xim: Thing 36 (DeHackEd "Thermal Detonator") is Doom's BFGBall, flying on BFS1 A/B (frames 1200-1201)
XIM_THROWN = [(["BFGBall"], "BFS1", "AB", "thermal", 0.45, TUMBLE)]


if __name__ == "__main__":
    build("SW_VR_Wardusted.pk3", "STAR WARS VR WEAPONS FOR WARDUST'S ROGUE REBEL -- 14 weapons (Wardusted DECORATE)",
          WARDUST, "Lightsaber", WD_SABER, WD_SABER_HIDE, os.path.join(SRC, "SW_Models_Wardusted.pk3"), OUT,
          WARDUST_FAKES, "wardusted", WD_THROWN, "red")
    build("SW_VR_Xim.pk3", "STAR WARS VR WEAPONS FOR XIM'S STAR WARS DOOM -- 8 weapons (Xim DeHackEd 1100-1200)",
          XIM, "Chainsaw", XIM_SABER, [], os.path.join(SRC, "SW_Models_Xim.pk3"), OUT, None, "xim", XIM_THROWN, "blue")

#!/usr/bin/env python3
"""The two Star Wars REMA sets -- Wardusted and Xim -- from Jedi Academy's VR weapon meshes.

    python _pending/tools/make_sw_sets.py            report only
    python _pending/tools/make_sw_sets.py --write    write meshes, textures, sounds, cards, sheets, SNDINFO

THE OWNER, 2026-09-21: "worldstarwars xim and wardusted weaponset with wardusted sounds / rema engine
lightsaber for them, swapping out any lightsaber they might call for themselves", and, through the
ballistics lane: standalone packs "that i can use with the mods or not". So each set carries its own
meshes and its own sounds and needs neither mod. The lightsaber is RS_Lightsaber.pk3's, named by
string: a class in two set packs would be fatal the moment both load.

WHAT THIS WRITES, PER SET, and nothing else:
  models/<set>/<mesh>/<mesh>_wm.md3 + its textures   the mesh turned into the package's frame
  sounds/<set>/<gun>.ogg                               Wardusted's own recordings, converted
  WMCARD.<set>, WMSHEET.<set>, <set>/SNDINFO.txt
The ZScript (props, loadout, bridge, thrown things) is hand-written beside the other sets'; MODELDEF,
CVARINFO and MENUDEF come from the package's own generators off the card this writes.

THE MESHES ARE MOVED INTO THE PACKAGE'S FRAME HERE, ONCE, rather than turned by MODELDEF numbers:
  +X is where the barrel points, +Z is up, and +Y is the gun's RIGHT -- the same mirrored frame every
  other set's _wm mesh is in, which MODELDEF's `Scale -1 1 1` then un-mirrors.
Each mesh's forward is its own tag_flash axis (the muzzle Jedi Academy fires from), not a guess. Its
up was read off a render of each gun: the VR pack sits some upright, some upside down (the DL-44 and
the E-11 hold the grip toward +Z) and some on their side (grip toward -Y).

THE ORIGIN IS MOVED TO THE HAND: the middle of the grip, read off the same renders. So a gun drawn
at offset 0 sits in the hand, and the placement sliders start at zero (make_cvarinfo --at-hand).

THE SIZE IS THE REAL WEAPON'S, not the mesh's. The VR pack's meshes are not to one scale (the Bryar
and the DL-44 are the same length; the real pistols are not), so each is scaled to a stated real
length at 1.75 map units a centimetre -- our own ~20 cm pistol draws ~35 units. The owner's _scale
slider is the fine adjustment, and a hand-and-gun positioning pass is next.

NO RELOAD. These are energy weapons (the owner: "i guess we don't need to physically reload these").
Every card says `firesfrom = reserve` -- a pull spends the reserve directly -- and `casing = none`.
"""
import io
import math
import os
import re
import shutil
import struct
import subprocess
import sys
import zipfile

HERE = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SW_PK3 = "E:/StarWarsWork/JKXR/assets/z_vr_weapons_jka_Crusty_and_Elin.pk3"
JKA = "D:/SteamLibrary/steamapps/common/Jedi Academy/GameData/base"
WARDUST = "D:/SteamLibrary/steamapps/Common/DooM VR/__Games/Wardusted/01_WARDUSTs_ROGUEREBEL_10_06_2024.pk3"
BALLISTICS_SHEET = ["python", "E:/DOOMWork/RS_Ballistics/tools/gen_starwars_profiles.py", "--sheet"]
FFMPEG = shutil.which("ffmpeg") or ("C:/Users/Command/AppData/Local/Microsoft/WinGet/Packages/"
                                    "Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe/ffmpeg-9.0-full_build/bin/ffmpeg.exe")
UNITS_PER_CM = 1.75

# ---- THE MESHES -------------------------------------------------------------------------------------
# up: the gun's up in the SOURCE mesh, read off a render (forward is always its tag_flash axis).
# grip: the hand, in SOURCE mesh units -- the middle of the grip, read off the same render.
# cm: the real weapon's length. extra: the barrel part JK draws separately; placed at the gun's own
# origin, as JK places it when a mesh has no tag_barrel, and merged in here (nothing spins it).
MESHES = {
    "blaster_pistol": dict(src="blaster_pistol/blaster_pistol.md3", up=(0, 0, -1), roll="thin", grip=(0.0, 0.5, 0.35), cm=30),
    "briar_pistol":   dict(src="briar_pistol/briar_pistol.md3", up=(0, 1, 0), grip=(-1.2, 1.8, -0.8), cm=28),
    "blaster_r":      dict(src="blaster_r/blaster.md3", up=(0, 0, -1), roll="thin", grip=(0.0, 0.5, 0.6), cm=50),
    "demp2":          dict(src="demp2/demp2.md3", up=(0, 0, 1), grip=(2.4, 0.0, -5.5), cm=60),
    "heavy_repeater": dict(src="heavy_repeater/heavy_repeater.md3", extra="heavy_repeater/heavy_repeater_barrel.md3",
                           up=(0, 1, 0), grip=(-0.8, -2.2, 0.0), cm=100),
    "golan_arms":     dict(src="golan_arms/golan_arms.md3", up=(0, 0, 1), grip=(5.3, 0.0, -4.2), cm=75),
    "disruptor":      dict(src="disruptor/disruptor.md3", extra="disruptor/disruptor_barrel.md3",
                           up=(0, 0, -1), grip=(5.4, 0.0, 2.0), cm=95),
    "bowcaster":      dict(src="bowcaster/bowcaster.md3", up=(0, 1, 0), grip=(0.3, -1.2, 0.0), cm=90),
    "merr_sonn":      dict(src="merr_sonn/merr_sonn.md3", extra="merr_sonn/merr_sonn_barrel.md3",
                           up=(0, 1, 0), grip=(-4.76, 0.0, -0.9), cm=110),
    "concussion":     dict(src="concussion/c_rifle.md3", extra="concussion/c_rifle_barrel.md3",
                           up=(0, 1, 0), grip=(4.6, -3.0, -2.5), cm=80),
    "thermal":        dict(src="thermal/thermal.md3", up=(0, 0, 1), grip=None, cm=9),
    "laser_trap":     dict(src="laser_trap/laser_trap.md3", up=(0, 0, 1), grip=None, cm=14),
}

# ---- THE GUNS ---------------------------------------------------------------------------------------
# (class, mesh, slot, ammo, name, sheet key, Wardusted sound lump, type, firetics, fullauto, damage,
#  pounds, throwclass)
# sheet key: the name ballistics' --sheet prints the gun under (Wardusted's own class names; XIM_*).
# THE SOUND IS WARDUSTED'S OWN RECORDING OF THAT GUN, from its SNDINFO: DL44/fire is DL44, PistolFire
# is PISTOL, and so on. The disruptor has no sound of its own in the mod (its disruptor/* names are
# never defined), so it fires the sniper's beam, its nearest kin in the same set.
WARDUSTED = [
    ("WD_DL44",          "blaster_pistol", 2, "Clip",       "DL-44 Heavy Blaster",   "DL44Blaster",       "DL44",     "pistol",   10, False, (14, 22), 2.8,  None),
    ("WD_DarkBlaster",   "briar_pistol",   2, "Clip",       "Dark Blaster",          "DarkBlaster",       "PISTOL",   "pistol",    7, False, (10, 18), 2.4,  None),
    ("WD_E22",           "demp2",          3, "Shell",      "E-22 Blaster Rifle",    "E22Blaster",        "FUSION1",  "plasma",   14, False, (18, 30), 9.0,  None),
    ("WD_E11",           "blaster_r",      3, "Clip",       "E-11 Blaster Rifle",    "E11Blaster",        "RIFLE",    "rifle",     5, True,  (10, 16), 6.4,  None),
    ("WD_Z6",            "heavy_repeater", 4, "Clip",       "Z-6 Rotary Blaster",    "Z6RotaryBlaster",   "AUTOGN",   "chaingun",  2, True,  (8, 12),  30.0, None),
    ("WD_DLT19",         "golan_arms",     4, "Clip",       "DLT-19 Heavy Blaster",  "DLT19",             "PISTOL2",  "mg",        3, True,  (10, 15), 18.0, None),
    ("WD_Bowcaster",     "bowcaster",      5, "Shell",      "Bowcaster",             "Bowcaster",         "BOW5",     "rifle",    18, False, (35, 55), 15.0, None),
    ("WD_Concussion",    "concussion",     6, "Cell",       "Concussion Rifle",      "ConcussionRifle",   "PLASMA50", "plasma",   20, False, (50, 80), 14.0, None),
    ("WD_Disruptor",     "disruptor",      6, "Cell",       "Disruptor Rifle",       "DisruptorRifle",    "SNIPERB",  "rifle",    25, False, (45, 70), 11.0, None),
    ("WD_Sniper",        "disruptor",      6, "Cell",       "Sniper Rifle",          "SniperRifle",       "SNIPER2",  "rifle",    30, False, (60, 90), 12.0, None),
    ("WD_AssaultCannon", "merr_sonn",      7, "RocketAmmo", "Dark Assault Cannon",   "DarkAssaultCannon", "CONCUSS5", "launcher", 10, True,  (40, 60), 28.0, None),
    ("WD_Thermal",       "thermal",        8, None,         "Thermal Detonator",     "RebelThermalDetonator", "NEWDET", "thrown", 0, False, None,   1.0,  "WD_ThrownThermal"),
    ("WD_Mines",         "laser_trap",     8, None,         "Proximity Mine",        "ProximityMines",    "CLAYMOR1", "thrown",    0, False, None,     1.5,  "WD_ThrownMine"),
]
XIM = [
    ("XM_Pistol",         "blaster_pistol", 2, "Clip",       "Blaster Pistol",   "XIM_Pistol",         "DL44",    "pistol",   10, False, (12, 20), 2.8,  None),
    ("XM_Shotgun",        "blaster_r",      3, "Shell",      "Blaster Rifle",    "XIM_Shotgun",        "RIFLE",   "rifle",     8, False, (20, 32), 6.4,  None),
    ("XM_SuperShotgun",   "demp2",          3, "Shell",      "Ion Blaster",      "XIM_SuperShotgun",   "FUSION1", "plasma",   16, False, (30, 50), 9.0,  None),
    ("XM_Chaingun",       "heavy_repeater", 4, "Clip",       "Heavy Blaster",    "XIM_Chaingun",       "AUTOGN",  "chaingun",  3, True,  (9, 14),  30.0, None),
    ("XM_RocketLauncher", "bowcaster",      5, "RocketAmmo", "Bowcaster",        "XIM_RocketLauncher", "BOW5",    "rifle",    20, False, (60, 90), 15.0, None),
    ("XM_PlasmaRifle",    "golan_arms",     6, "Cell",       "Rotary Blaster",   "XIM_PlasmaRifle",    "PISTOL2", "mg",        3, True,  (10, 16), 18.0, None),
    ("XM_Thermal",        "thermal",        7, None,         "Thermal Detonator", "XIM_BFG",           "NEWDET",  "thrown",    0, False, None,     1.0,  "XM_ThrownThermal"),
]
SETS = [("wardusted", "Wardusted", "WD", WARDUSTED), ("xim", "Xim", "XM", XIM)]

# ---- THE SOUNDS, Wardusted's lumps by name (its SNDINFO: logical name -> lump -> file) ----------------
SOUND_FILES = {
    "DL44": "Sounds/Blaster Pistol/DL44.mp3", "PISTOL": "Sounds/MIX/PISTOL.wav", "RIFLE": "Sounds/MIX/RIFLE.mp3",
    "PISTOL2": "Sounds/Blaster Pistol/PISTOL2", "FUSION1": "Sounds/MIX/FUSION1.wav", "AUTOGN": "Sounds/AUTOGUN/AUTOGN",
    "BOW5": "Sounds/Weapons/BOW5", "PLASMA50": "Sounds/Weapons/PLASMA50.mp3", "SNIPERB": "Sounds/Sniper Rifle/SNIPERB.ogg",
    "SNIPER2": "Sounds/Sniper Rifle/SNIPER2", "CONCUSS5": "Sounds/MIX/CONCUSS5.wav", "NEWDET": "Sounds/Weapons/NEWDET.wav",
    "CLAYMOR1": "Sounds/MIX/CLAYMOR1.wav",
    # what the thrown things do when they go off, and the mine's arming beep
    "EX-SMALL": "Sounds/MIX/EX-SMALL.wav", "EX-LRG1": "Sounds/MIX/EX-LRG1.wav", "BEEP-10": "Sounds/MIX/BEEP-10.wav",
}
EXTRA_SOUNDS = [("thermal/boom", "EX-SMALL"), ("mine/boom", "EX-LRG1"), ("mine/beep", "BEEP-10")]


# =====================================================================================================
def v_sub(a, b): return (a[0] - b[0], a[1] - b[1], a[2] - b[2])
def v_dot(a, b): return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]
def v_cross(a, b): return (a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0])
def v_scale(a, s): return (a[0] * s, a[1] * s, a[2] * s)
def v_add(a, b): return (a[0] + b[0], a[1] + b[1], a[2] + b[2])
def v_norm(a):
    l = math.sqrt(v_dot(a, a)) or 1.0
    return (a[0] / l, a[1] / l, a[2] / l)


def decode_normal(n):
    lat = ((n >> 8) & 255) * 2 * math.pi / 255
    lng = (n & 255) * 2 * math.pi / 255
    return (math.cos(lat) * math.sin(lng), math.sin(lat) * math.sin(lng), math.cos(lng))


def encode_normal(v):
    x, y, z = v
    if abs(x) < 1e-6 and abs(y) < 1e-6:
        return 0 if z > 0 else (128 & 255)
    lng = int(math.acos(max(-1.0, min(1.0, z))) * 255 / (2 * math.pi)) & 255
    lat = int(math.atan2(y, x) * 255 / (2 * math.pi)) & 255
    return (lat << 8) | lng


def read_md3(data, frame=0):
    """Frame 0 of every surface, with tags."""
    nf, nt, ns = struct.unpack_from("<3i", data, 76)
    ofr, otag, osurf = struct.unpack_from("<3i", data, 92)
    tags = {}
    for i in range(nt):
        o = otag + i * 112
        name = data[o:o + 64].split(b"\0")[0].decode("latin1")
        org = struct.unpack_from("<3f", data, o + 64)
        ax = struct.unpack_from("<9f", data, o + 76)
        tags[name] = (org, ax[0:3])
    surfs = []
    o = osurf
    for _ in range(ns):
        name = data[o + 4:o + 68].split(b"\0")[0].decode("latin1")
        nfr, nsh, nv, ntri, otri, osh, ost, oxyz, oend = struct.unpack_from("<9i", data, o + 72)
        shaders = [data[o + osh + i * 68:o + osh + i * 68 + 64].split(b"\0")[0].decode("latin1") for i in range(nsh)]
        tris = [struct.unpack_from("<3i", data, o + otri + 12 * i) for i in range(ntri)]
        st = [struct.unpack_from("<2f", data, o + ost + 8 * i) for i in range(nv)]
        verts, norms = [], []
        for i in range(nv):
            x, y, z, n = struct.unpack_from("<3hH", data, o + oxyz + 8 * (frame * nv + i))
            verts.append((x / 64.0, y / 64.0, z / 64.0))
            norms.append(decode_normal(n))
        surfs.append(dict(name=name, shader=(shaders[0] if shaders else ""), tris=tris, st=st, verts=verts, norms=norms))
        o += oend
    return tags, surfs


def write_md3(path, surfs):
    """One frame, no tags; each surface names its own texture file (used only for the record --
    MODELDEF's SurfaceSkin is what binds them)."""
    allv = [v for s in surfs for v in s["verts"]]
    mn = [min(v[i] for v in allv) for i in range(3)]
    mx = [max(v[i] for v in allv) for i in range(3)]
    rad = max(math.sqrt(v_dot(v, v)) for v in allv)
    body = b""
    for s in surfs:
        nv, nt = len(s["verts"]), len(s["tris"])
        hdr = 108
        o_sh = hdr
        o_tri = o_sh + 68
        o_st = o_tri + 12 * nt
        o_xyz = o_st + 8 * nv
        o_end = o_xyz + 8 * nv
        b = struct.pack("<4s64s10i", b"IDP3", s["name"].encode()[:63], 0, 1, 1, nv, nt, o_tri, o_sh, o_st, o_xyz, o_end)
        b += struct.pack("<64si", s["shader"].encode()[:63], 0)
        for t in s["tris"]:
            b += struct.pack("<3i", *t)
        for uv in s["st"]:
            b += struct.pack("<2f", *uv)
        for v, n in zip(s["verts"], s["norms"]):
            q = [max(-32768, min(32767, int(round(c * 64.0)))) for c in v]
            b += struct.pack("<3hH", q[0], q[1], q[2], encode_normal(n))
        body += b
    o_frames = 108
    o_surf = o_frames + 56
    head = struct.pack("<4si64s9i", b"IDP3", 15, os.path.basename(path).encode()[:63], 0, 1, 0, len(surfs), 0,
                       o_frames, o_frames + 56, o_surf, o_surf + len(body))
    frame = struct.pack("<3f3f3ff16s", *mn, *mx, 0, 0, 0, rad, b"frame0")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, "wb").write(head + frame + body)


class Textures:
    """A surface's texture, by the name its shader names: the pack's shader files first, then JKA's."""

    def __init__(self):
        self.zips = [zipfile.ZipFile(SW_PK3)] + [zipfile.ZipFile(os.path.join(JKA, "assets%d.pk3" % i)) for i in range(4)]
        self.shader = {}
        for z in self.zips[:3]:
            for n in z.namelist():
                if n.lower().endswith(".shader"):
                    t = z.read(n).decode("latin1", "replace")
                    for m in re.finditer(r'(?m)^\s*(models/weapons2/[^\s{]+)\s*\n\s*\{(.*?)\n\}', t, re.S):
                        mp = re.search(r'\bmap\s+(\S+)', m.group(2))
                        if mp and mp.group(1) != "$lightmap":
                            self.shader.setdefault(m.group(1).lower(), mp.group(1))
        self.idx = {}
        for z in self.zips:
            for n in z.namelist():
                low = n.lower()
                if low.endswith((".jpg", ".tga", ".png")):
                    self.idx.setdefault(low.rsplit(".", 1)[0], (z, n))

    def find(self, shader):
        for cand in (self.shader.get(shader.lower(), shader), shader):
            key = cand.lower()
            key = key.rsplit(".", 1)[0] if "." in key.split("/")[-1] else key
            if key in self.idx:
                return self.idx[key]
        return None


def build_mesh(key, spec, sw, tex, out_dir):
    """The mesh in the package's frame: forward +X, up +Z, right +Y; origin at the hand; real size.
    Returns (md3 name, [texture file per surface], muzzle, length)."""
    sl = {n.lower(): n for n in sw.namelist()}
    tags, surfs = read_md3(sw.read(sl["models/weapons2/" + spec["src"].lower()]))
    if spec.get("extra"):
        _, more = read_md3(sw.read(sl["models/weapons2/" + spec["extra"].lower()]))
        surfs += more
    flash = tags.get("tag_flash")
    F = v_norm(flash[1]) if flash else (1.0, 0.0, 0.0)
    U = spec["up"]
    U = v_norm(v_sub(U, v_scale(F, v_dot(U, F))))
    allsrc = [v for s in surfs for v in s["verts"]]
    if spec.get("roll") == "thin":
        # THE ROLL OFF THE GUN'S OWN SHAPE, for the two meshes the VR pack left canted about the
        # barrel (the DL-44 and the E-11 read ~40 degrees over in a render). A gun is thin side to
        # side, so across the barrel its LEAST spread is its side and its MOST is up and down --
        # the principal axes of the vertices in the plane square to the barrel. The hand-read up
        # only picks which way round.
        W = v_norm(v_cross(F, U))
        c = [sum(v[i] for v in allsrc) / len(allsrc) for i in range(3)]
        a = b_ = cc = 0.0
        for v in allsrc:
            d = v_sub(v, c)
            pu, pw = v_dot(d, U), v_dot(d, W)
            a += pu * pu; b_ += pu * pw; cc += pw * pw
        ang = 0.5 * math.atan2(2 * b_, a - cc)          # the most-spread direction, from U toward W
        U2 = v_norm(v_add(v_scale(U, math.cos(ang)), v_scale(W, math.sin(ang))))
        U = U2 if v_dot(U2, U) > 0 else v_scale(U2, -1.0)
    R = v_cross(F, U)                              # the gun's right, in the source's right-handed space
    grip = spec["grip"]
    allv = [v for s in surfs for v in s["verts"]]
    if grip is None:                               # a thrown thing: held by its middle
        grip = tuple((min(v[i] for v in allv) + max(v[i] for v in allv)) / 2 for i in range(3))

    def frame(p):
        return (v_dot(p, F), v_dot(p, R), v_dot(p, U))

    xs = [frame(v)[0] for v in allv]
    length = max(xs) - min(xs)
    scale = spec["cm"] * UNITS_PER_CM / length
    g = frame(grip)
    # THE HAND IS UNDER THE BARREL, side to side. A grip read off a render is good fore-and-aft and
    # up-and-down and poor sideways (the DL-44's put the hand eight units off the gun), and a hand
    # beside the bore is a gun held crooked. So sideways it is taken from the barrel line itself.
    if flash:
        g = (g[0], frame(flash[0])[1], g[2])

    def place(p):
        q = frame(p)
        return ((q[0] - g[0]) * scale, (q[1] - g[1]) * scale, (q[2] - g[2]) * scale)

    files = []
    for si, s in enumerate(surfs):
        s["verts"] = [place(v) for v in s["verts"]]
        s["norms"] = [v_norm(frame(n)) for n in s["norms"]]
        # the frame mirrors, so each triangle's winding flips to keep its face outward
        s["tris"] = [(t[0], t[2], t[1]) for t in s["tris"]]
        hit = tex.find(s["shader"]) if s["shader"] else None
        if hit:
            from PIL import Image
            z, n = hit
            fn = os.path.splitext(os.path.basename(n))[0].lower() + ".png"
            dest = os.path.join(out_dir, fn)
            if not os.path.exists(dest):
                Image.open(io.BytesIO(z.read(n))).convert("RGBA").save(dest)
            files.append(fn)
            s["shader"] = fn
        else:
            files.append(None)
    # THE MUZZLE is tag_flash, but NEVER AHEAD OF THE GUN. Jedi Academy parks some flash tags in the
    # air in front of the barrel (the disruptor's is ten mesh units clear of its tip), and a shot that
    # starts there starts inside whatever you are pressed against. So it is clamped to the front face.
    front = max(v[0] for s in surfs for v in s["verts"])
    muzzle = place(flash[0]) if flash else (front, 0.0, 0.0)
    muzzle = (min(muzzle[0], front), muzzle[1], muzzle[2])
    name = key + "_wm.md3"
    write_md3(os.path.join(out_dir, name), surfs)
    return name, files, muzzle, length * scale, scale


def ballistics_sheet():
    """gun -> {key: value} from the ballistics lane's own tool, which is the one place those names live."""
    t = subprocess.run(BALLISTICS_SHEET, capture_output=True, text=True).stdout
    out, cur = {}, None
    for line in t.splitlines():
        m = re.match(r'gun "(\w+)"', line)
        if m:
            cur = out.setdefault(m.group(1), {})
            continue
        m = re.match(r'\s+(\w+profile)\s*=\s*"([^"]+)"', line)
        if m and cur is not None:
            cur[m.group(1)] = m.group(2)
    return out


def convert_sound(wz, lump, dest):
    data = wz.read(SOUND_FILES[lump])
    tmp = dest + ".src"
    open(tmp, "wb").write(data)
    subprocess.run([FFMPEG, "-y", "-loglevel", "error", "-i", tmp, "-ac", "1", "-c:a", "libvorbis", "-q:a", "5", dest],
                   check=True)
    os.remove(tmp)


def main():
    write = "--write" in sys.argv
    prof = ballistics_sheet()
    sw = zipfile.ZipFile(SW_PK3)
    tex = Textures() if write else None
    wz = zipfile.ZipFile(WARDUST)
    for set_dir, set_name, prefix, guns in SETS:
        print("== %s: %d guns" % (set_name, len(guns)))
        built = {}
        for g in guns:
            key = g[1]
            if key in built:
                continue
            spec = MESHES[key]
            if write:
                out_dir = os.path.join(HERE, "models", set_dir, key)
                os.makedirs(out_dir, exist_ok=True)
                built[key] = build_mesh(key, spec, sw, tex, out_dir)
                name, files, mz, ln, sc = built[key]
                print("   %-15s %5.1f units long (x%.2f)  muzzle %s  %d surfaces, %d textures"
                      % (key, ln, sc, tuple(round(c, 2) for c in mz), len(files), len(set(f for f in files if f))))
            else:
                built[key] = None
        if not write:
            continue
        card, sheet, snd = [], [], []
        HDR = ("# ==========================================================================\n"
               "# %s -- THE %s SET'S %s. GENERATED by _pending/tools/make_sw_sets.py. DO NOT EDIT --\n"
               "# change the tool and run it again.\n"
               "# ==========================================================================\n\n")
        card.append(HDR % ("WMCARD." + set_dir, set_name.upper(), "MODEL CARDS"))
        card.append("# ENERGY WEAPONS, NOTHING A HAND WORKS: every card fires from the reserve and throws no brass.\n"
                    "# The mesh is in the package's frame with its origin at the hand (make_sw_sets.py header).\n"
                    "# `# surfaceskin` is read by make_modeldef.py (the engine's parser would refuse a real key):\n"
                    "# these meshes carry a texture per surface, as Jedi Academy drew them.\n\n")
        sheet.append(HDR % ("WMSHEET." + set_dir, set_name.upper(), "WEAPON SHEETS"))
        sheet.append("# The profiles are the ballistics lane's, by the name its own tool prints for each gun\n"
                     "# (RS_Ballistics/tools/gen_starwars_profiles.py --sheet): films' colours, no brass, no\n"
                     "# powder smoke, and a stated kick on every gun. \"STAR WARS, NOT JOHN WICK.\"\n\n")
        snd.append("// THE %s SET'S SOUNDS -- Wardust's Rogue Rebel's own recordings, converted to ogg.\n"
                   "// GENERATED by _pending/tools/make_sw_sets.py. DO NOT EDIT.\n\n" % set_name.upper())
        sounds_dir = os.path.join(HERE, "sounds", set_dir)
        os.makedirs(sounds_dir, exist_ok=True)
        done_snd = set()
        order = 0
        for (cls, key, slot, ammo, label, pkey, lump, typ, tics, auto, dmg, lb, throw) in guns:
            name, files, mz, ln, sc = built[key]
            prop = "%s_Prop%s" % (prefix, cls.split("_", 1)[1])
            path = "models/%s/%s" % (set_dir, key)
            body = next((f for f in files if f), None)
            card.append("weapon \"%s\"\n" % cls)
            card.append("  hand       = main\n  type       = %s\n  firesfrom  = reserve\n" % typ)
            if typ != "thrown":
                card.append("  casing     = none\n")
            card.append("  prop       = \"%s\"\n" % prop)
            card.append("  model      = \"%s\" \"%s\"\n" % (path, name))
            card.append("  skin       = \"%s\" \"%s\"\n" % (path, body))
            for si, f in enumerate(files):
                if f:
                    card.append("  # surfaceskin = %d \"%s\"\n" % (si, f))
            if throw:
                # THE THING IN FLIGHT DRAWS THE MESH IN THE HAND (make_modeldef.py reads this)
                card.append("  # flightclass = \"%s\"\n" % throw)
            if typ != "thrown":
                card.append("# THE MUZZLE: MEASURED, Jedi Academy's own tag_flash, carried through the same move as the mesh.\n")
                card.append("  muzzle     = %.2f, %.2f, %.2f\n  barrel     = 1, 0, 0\n" % mz)
            card.append("end\n\n")

            p = prof.get(pkey, {})
            sheet.append("gun \"%s\"\n  class\n" % cls)
            sheet.append("    slot               = %d\n" % slot)
            sheet.append("    selectionorder     = %d\n" % (9000 + slot * 100 + 90 + order % 10))
            if ammo:
                sheet.append("    ammo               = \"%s\"\n" % ammo)
            sheet.append("    hand               = main\n    name               = \"%s\"\n    pickupmessage      = \"%s\"\n  end\n"
                         % (label, label))
            logical = "%s/%s/fire" % (set_dir, cls.split("_", 1)[1].lower())
            sheet.append("  firesound            = \"%s\"\n" % logical)
            if typ == "thrown":
                # A WHOLE-WEAPON THROW FIRES ITS SHOTCLASS (BL_Lighter's shape); `throwclass` is altmode's.
                sheet.append("  shotclass            = \"%s\"\n" % throw)
            else:
                sheet.append("  firetics             = %d\n" % tics)
                if auto:
                    sheet.append("  fullauto             = true\n")
                sheet.append("  shotdamage           = %d, %d\n" % dmg)
            for k in ("flashprofile", "recoilprofile", "roundprofile", "ejectaprofile"):
                if k in p:
                    sheet.append("  %-20s = \"%s\"\n" % (k, p[k]))
            if not p:
                print("   !! no ballistics profiles printed for %s (%s)" % (cls, pkey))
            sheet.append("  baseweight           = %.2f\n" % lb)
            sheet.append("end\n\n")

            fn = "%s.ogg" % cls.split("_", 1)[1].lower()
            convert_sound(wz, lump, os.path.join(sounds_dir, fn))
            snd.append("%-34s sounds/%s/%s\n" % (logical, set_dir, fn))
            order += 1
        for logical, lump in EXTRA_SOUNDS:
            fn = logical.replace("/", "_") + ".ogg"
            convert_sound(wz, lump, os.path.join(sounds_dir, fn))
            snd.append("%-34s sounds/%s/%s\n" % ("%s/%s" % (set_dir, logical), set_dir, fn))
        io.open(os.path.join(HERE, "WMCARD." + set_dir), "w", encoding="utf-8", newline="\n").write("".join(card))
        io.open(os.path.join(HERE, "WMSHEET." + set_dir), "w", encoding="utf-8", newline="\n").write("".join(sheet))
        os.makedirs(os.path.join(HERE, set_dir), exist_ok=True)
        io.open(os.path.join(HERE, set_dir, "SNDINFO.txt"), "w", encoding="utf-8", newline="\n").write("".join(snd))
        print("   wrote WMCARD.%s, WMSHEET.%s, %s/SNDINFO.txt" % (set_dir, set_dir, set_dir))


if __name__ == "__main__":
    main()

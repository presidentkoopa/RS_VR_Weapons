"""volglow.py -- VOLUMETRIC lightsaber glow assets for the WORLD layer (additive md3 + PNG).

DESIGN: NESTED CLOSED CAPSULES ("onion shells"), not crossed planes.
  A capsule of radius r around the blade segment is the set of points within r of the segment. Any straight
  line of sight crosses its closed surface iff the line passes within r of the segment. With RenderStyle Add
  (which in QZD turns on back-face culling for models, hw_models.cpp BeginDrawModel) each capsule is drawn
  exactly ONCE per pixel it covers, front faces only. So N nested capsules of constant colour C_k give

        pixel = sum_{k : dist(ray, segment) < r_k} C_k  =  T(dist(ray, segment))

  i.e. the image is an exact radial staircase of the target profile T of the distance from the line of sight
  to the blade SEGMENT -- the same from the side, at 45 deg, grazing, and straight down the axis (a soft round
  disc), with a rounded tip for free and no plane edges or stars. Overlap cannot blow out: the sum along any
  line of sight is T by construction. The colours C_k are the differences of T between successive shells.

  Texture: one RGB PNG per saber colour, a vertical band per shell (U) x along-blade fade (V). V is mapped
  piecewise from mesh z so the hilt-end fade is in absolute units (independent of blade length):
     z in [ZLO, ZKNEE]  -> v in [0, VKNEE]   (the emitter fade lives here)
     z in [ZKNEE, L0+ZHI_PAD] -> v in [VKNEE, 1]   (full brightness)

UNITS / PLACEMENT: the mesh is in WORLD map units for a blade of nominal length L0 (default 26) and nominal
  outer radius R (default 3.0): model z=0 is the emitter (blade base point), +Z is the blade direction, the
  shells start just below the emitter and their base fades out into the hilt mouth. With MODELDEF Scale 1 1 1
  and USEACTORPITCH the actor's scale = (s, L / L0) where s = radius multiplier (saber size): at L == s*L0 the
  model is uniformly scaled (perfect round caps); during ignition the caps squash a little (unnoticeable).

md3 conventions as ubqs.py / make_sw_vrplus.write_md3: md3 (x,y,z) -> GL (x,z,y); triangle winding as in
Wardust's saber_anim.md3 (Quake 3 convention: (v1-v0)x(v2-v0) points INTO a closed surface; all 11 of its
surfaces have negative signed volume) so the front faces survive QZD's translucent-model culling.
"""
import io
import math
import os
import struct
import sys

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))

# the project's saber colours (ubqs.py COLORS)
COLORS = [("B", "Blue", (70, 140, 255)), ("G", "Green", (60, 255, 90)), ("R", "Red", (255, 40, 35)),
          ("P", "Purple", (175, 70, 255)), ("Y", "Yellow", (255, 225, 50)), ("O", "Orange", (255, 130, 25)),
          ("C", "Cyan", (40, 235, 255)), ("W", "White", (235, 240, 255))]

L0 = 26.0            # nominal blade length (map units) the mesh is built at
R_OUT = 3.5          # outer glow radius (map units) at s = 1
TUBE_R = 0.6         # the solid saber blade's radius in the world (for the previews)
BASE_Z = -0.6        # where the shells' base hemispheres are centred (just into the emitter)
FADE_LO, FADE_HI = -1.6, 1.2   # the glow is 0 below FADE_LO and full above FADE_HI (z, map units)
ZLO, ZKNEE = -8.0, 4.0
VKNEE = 0.875
TEX_BAND = 8         # texels per shell band (keeps bilinear/mip bleed inside the band)
TEX_H = 64

# QUALITY TIERS: shell radii (fractions of R_OUT are derived from the profile), radial segments, cap rings
TIERS = {
    "low":  dict(n=6, seg=10, cap=3),
    "med":  dict(n=10, seg=14, cap=4),
    "high": dict(n=16, seg=18, cap=5),
    "ultra": dict(n=24, seg=20, cap=6),
}


# ---- the target look -----------------------------------------------------------------------------------
def profile(d, rgb, r_out=R_OUT):
    """Target side-view brightness (framebuffer units, may exceed 1 in the core = white-hot) at distance d
    (map units) from the blade line: a hot white core of about the tube's radius, then the saturated colour,
    soft exponential bloom to nothing at r_out. Returns (len(d), 3)."""
    d = np.asarray(d, float)[..., None]
    col = np.array(rgb, float) / 255.0
    col = col / col.max()                                   # fully saturated, max channel 1
    k = r_out / 3.5
    core = 1.20 * np.exp(-(d / (0.45 * k)) ** 2.5)          # white-hot core, a little narrower than the tube
    halo = 1.00 * np.exp(-(d / (0.95 * k)) ** 2) + 0.80 * np.exp(-d / (1.60 * k))   # saturated bloom
    e = np.clip((r_out - d) / (0.45 * r_out), 0, 1)
    edge = e * e * (3 - 2 * e)                                # reaches exactly 0 at r_out
    return core + halo * edge * col


def shell_design(rgb, n, r_out=R_OUT, radii=None):
    """Radii r_1<..<r_n (= r_out) and per-shell colours C_k so that sum_{k: d<r_k} C_k ~ profile(d).
    Radii are placed at equal steps of the profile's peak channel (equal framebuffer steps ~ perceptually even
    banding), with the first shell(s) carrying the white core."""
    if radii is None:
        radii = shell_radii(n, r_out)
    return radii, shell_colours(rgb, radii, r_out)


def shell_radii(n, r_out=R_OUT, rgb=(70, 140, 255)):
    """The shells' radii, shared by every colour (one mesh for all skins): designed on the blue profile."""
    dd = np.linspace(0, r_out, 4000)
    P = profile(dd, rgb, r_out)
    lum = np.clip(P, 0, 1).mean(axis=1)                      # what the screen shows (clipped), mean channel
    # equal steps of log(displayed brightness): Weber-even banding from the white core out to the faint rim
    m = np.log(lum + 0.03)
    levels = np.linspace(m[0], math.log(0.012 + 0.03), n + 1)[1:]
    radii = [float(np.interp(-L, -m, dd)) for L in levels]
    radii = sorted(set(round(r, 4) for r in radii))
    while len(radii) < n:                                   # (degenerate: split the widest gap)
        g = np.argmax(np.diff([0] + radii))
        radii.insert(g, ((radii[g - 1] if g else 0) + radii[g]) / 2)
    return np.array(radii)


def shell_colours(rgb, radii, r_out=R_OUT):
    radii = np.asarray(radii, float)
    # value inside the band (r_{k-1}, r_k]: profile at the band's mean (area-weighted) radius
    inner = np.concatenate([[0.0], radii[:-1]])
    rep = np.array([float(np.sqrt((a * a + b * b) / 2)) if a > 0 else b * 0.35 for a, b in zip(inner, radii)])
    T = profile(rep, rgb, r_out)                             # (n,3) staircase values
    C = T - np.vstack([T[1:], np.zeros((1, 3))])            # what each shell adds
    return np.clip(C, 0, None)


def fade_z(z):
    t = np.clip((np.asarray(z, float) - FADE_LO) / (FADE_HI - FADE_LO), 0, 1)
    return t * t * (3 - 2 * t)


def z_to_v(z, l0=L0):
    z = np.asarray(z, float)
    lo = (z - ZLO) / (ZKNEE - ZLO) * VKNEE
    hi = VKNEE + (z - ZKNEE) / (l0 + 8.0 - ZKNEE) * (1 - VKNEE)
    return np.clip(np.where(z < ZKNEE, lo, hi), 0, 1)


def v_to_z(v, l0=L0):
    v = np.asarray(v, float)
    return np.where(v < VKNEE, ZLO + v / VKNEE * (ZKNEE - ZLO), ZKNEE + (v - VKNEE) / (1 - VKNEE) * (l0 + 8.0 - ZKNEE))


# ---- the mesh ------------------------------------------------------------------------------------------
def capsule(r, z0, z1, seg, cap, band_u, l0=L0):
    """Closed capsule around the z axis, centres z0 (base) .. z1 (tip). Returns verts, st, tris (Q3 winding:
    cross product points inward)."""
    rings = []                                              # (radius, z)
    for i in range(cap, 0, -1):                             # base hemisphere, pole excluded
        a = math.pi / 2 * i / cap
        rings.append((r * math.cos(a), z0 - r * math.sin(a)))
    rings.append((r, z0))
    for zk in (ZKNEE,):                                     # the V-mapping knee needs a vertex ring
        if z0 < zk < z1:
            rings.append((r, zk))
    rings.append((r, z1))
    for i in range(1, cap + 1):
        a = math.pi / 2 * i / cap
        rings.append((r * math.cos(a), z1 + r * math.sin(a)))
    rings = [rr for rr in rings]
    verts, st = [], []
    # base pole
    verts.append((0.0, 0.0, z0 - r)); st.append((band_u, float(z_to_v(z0 - r, l0))))
    ring_idx = []
    for (rr, z) in rings:
        if rr < 1e-6:
            continue
        idx = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            verts.append((rr * math.cos(a), rr * math.sin(a), z))
            st.append((band_u, float(z_to_v(z, l0))))
            idx.append(len(verts) - 1)
        ring_idx.append(idx)
    verts.append((0.0, 0.0, z1 + r)); st.append((band_u, float(z_to_v(z1 + r, l0))))
    top = len(verts) - 1
    tris = []
    # outward-facing CCW (seen from outside) would be (a, b, c) with increasing angle going up; Q3 wants the
    # reverse, so every triangle is emitted reversed.
    def tri(a, b, c):
        tris.append((a, c, b))
    R0 = ring_idx[0]
    for j in range(seg):
        tri(0, R0[(j + 1) % seg], R0[j])
    for A, B in zip(ring_idx[:-1], ring_idx[1:]):
        for j in range(seg):
            j1 = (j + 1) % seg
            tri(A[j], A[j1], B[j1])
            tri(A[j], B[j1], B[j])
    RT = ring_idx[-1]
    for j in range(seg):
        tri(top, RT[j], RT[(j + 1) % seg])
    return verts, st, tris


def volglow_mesh(tier="med", r_out=R_OUT, l0=L0, rgb_for_radii=(70, 140, 255), radii=None):
    """All shells of a tier as ONE md3 surface (one draw call). Returns (verts, st, tris, radii)."""
    t = TIERS[tier]
    if radii is None:
        radii, _ = shell_design(rgb_for_radii, t["n"], r_out)
    V, S, T = [], [], []
    n = len(radii)
    for k, r in enumerate(radii):
        u = (k * TEX_BAND + TEX_BAND / 2) / (n * TEX_BAND)
        v, s, tr = capsule(float(r), BASE_Z, l0, t["seg"], t["cap"], u, l0)
        b = len(V)
        V += v; S += s; T += [(a + b, c + b, d + b) for a, c, d in tr]
    return V, S, T, np.asarray(radii)


def write_md3(name, surfs, nf=1):
    """Same as make_sw_vrplus.write_md3 (ubqs.py's writer), inlined so this module stands alone."""
    def enc_normal(n):
        return 0
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
            for v in vs:
                q = [max(-32768, min(32767, int(round(c * 64.0)))) for c in v]
                b += struct.pack("<3hH", q[0], q[1], q[2], 0)
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


def volglow_tex(rgb, tier="med", r_out=R_OUT, gain=1.0, l0=L0):
    """float (H, W, 3) texture: band k = shell k's colour, rows = the hilt-end fade along V (row 0 = v=0)."""
    radii, C = shell_design(rgb, TIERS[tier]["n"], r_out)
    n = len(radii)
    v = (np.arange(TEX_H) + 0.5) / TEX_H
    f = fade_z(v_to_z(v, l0))                                # (H,)
    tex = np.zeros((TEX_H, n * TEX_BAND, 3))
    for k in range(n):
        tex[:, k * TEX_BAND:(k + 1) * TEX_BAND, :] = f[:, None, None] * C[k][None, None, :] * gain
    return np.clip(tex, 0, 1)


def volglow_png(rgb, tier="med", r_out=R_OUT, gain=1.0, l0=L0):
    """PNG bytes (RGB, no alpha: black = invisible under RenderStyle Add). md3 t=0 is the top image row in
    GZDoom (ubqs.py beamglow_png puts v=0 = base at the BOTTOM row with t=1 there); here st's t = 1 - v."""
    tex = volglow_tex(rgb, tier, r_out, gain, l0)
    img = (np.round(tex[::-1] * 255)).astype(np.uint8)       # row 0 = top = t 0 = v 1 (tip)
    b = io.BytesIO()
    Image.fromarray(img, "RGB").save(b, "PNG")
    return b.getvalue()


def _flip_t(st):
    return [(u, 1.0 - v) for u, v in st]


# the md3's t coordinate: image row = t * H with t=0 the top row. Our st above holds v (0 at the hilt end);
# the writer stores t = 1 - v so the PNG's bottom row is the hilt end, like ubqs.py's beamglow.
def volglow_md3(tier="med", r_out=R_OUT, l0=L0):
    V, S, T, radii = volglow_mesh(tier, r_out, l0)
    return write_md3("volglow_" + tier, [{"name": "vglow", "shader": "volglow.png", "tris": T, "st": _flip_t(S),
                                          "frames": [(V, [(0.0, 0.0, 1.0)] * len(V))]}], 1)


def overdraw(tier, r_out=R_OUT, l0=L0):
    """Side-view pixel coverage in 'outer-glow footprints': sum of shells' projected areas / outer area."""
    radii, _ = shell_design((70, 140, 255), TIERS[tier]["n"], r_out)
    area = lambda r: 2 * r * (l0 - BASE_Z) + math.pi * r * r
    return sum(area(r) for r in radii) / area(radii[-1]), len(volglow_mesh(tier, r_out, l0)[2])


def modeldef(cls="UBQS_VolGlow", spr="UBVG", tier="med", folder="models/ubqs"):
    lines = ["Model %s" % cls, "{", '\tPath "%s"' % folder]
    for i, (tag, _, _) in enumerate(COLORS):
        lines += ['\tModel %d "volglow_%s.md3"' % (i, tier), '\tSkin %d "volglow_%s_%s.png"' % (i, tier, tag)]
    lines += ["\tScale 1.0 1.0 1.0", "\tUSEACTORPITCH", ""]
    lines += ["\tFrameIndex %s %s %d 0" % (spr, chr(ord("A") + i), i) for i in range(len(COLORS))]
    lines += ["}"]
    return "\n".join(lines)


def build(outdir, tiers=("low", "med", "high", "ultra"), folder="models/ubqs"):
    """Write every md3 + PNG + a MODELDEF fragment into outdir/<folder>."""
    d = os.path.join(outdir, folder)
    os.makedirs(d, exist_ok=True)
    for t in tiers:
        open(os.path.join(d, "volglow_%s.md3" % t), "wb").write(volglow_md3(t))
        for tag, _, rgb in COLORS:
            open(os.path.join(d, "volglow_%s_%s.png" % (t, tag)), "wb").write(volglow_png(rgb, t))
    open(os.path.join(outdir, "MODELDEF.volglow"), "w").write(
        "\n\n".join(modeldef(spr="UBV%d" % (i + 1), tier=t, folder=folder) for i, t in enumerate(tiers)) + "\n")


if __name__ == "__main__":
    build(os.path.join(HERE, "out"))
    for t in TIERS:
        print(t, "overdraw x%.2f of outer footprint, %d tris" % overdraw(t))

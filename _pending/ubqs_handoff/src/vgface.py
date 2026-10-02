"""vgface.py -- build 51's world glow: SMOOTH nested shells that FACE the viewer (replaces vgsplit.py's use).

WHY (the owner in the headset, build 50: "almost" -- the glow was too fat, and close up the nested shells showed
as hard concentric rings). A constant-colour shell adds a hard step where its silhouette is, whatever the number
of shells: N shells = N steps. This build makes every shell's own contribution fall SMOOTHLY to zero at its
silhouette, so the sum has no steps at all:

  * The actor is ROLLED every tic (UBQS_BeamGlow.Place) so the mesh's +Y meridian faces the viewer: +Y = the
    part of (eye - beam) square to the beam. (The beam is rotationally symmetric, so the roll changes nothing
    but which way the texture faces.)
  * The texture's U runs round each shell (theta, +Y = the middle of the shell's band), so a texel knows its
    angle phi from the facing meridian. A shell of radius r seen from the side shows, at distance d from the beam
    line, its surface at sin(phi) = d / r. Brightness g(cos phi) (a smoothstep from cos 0.4 to 1) makes each
    shell a smooth BUMP b_r(d) = g(sqrt(1 - d^2/r^2)) that is 0 from 0.92 r out -- no edge. The shells' colours
    are fitted (bounded least squares) so the bumps add up to the target profile.
  * This holds from ANY angle to the beam except straight down its axis (perpendicular distance from the beam
    line is what the shells measure), with a perspective camera too until the eye is within ~3 radii of the
    shell (then the silhouette moves in to cos phi = r / dist and a faint step can show on the outermost shell).
  * PERSPECTIVE: close up, an eye at distance E from the beam line sees a round shell of radius r only to
    cos(phi) = r / E -- inside g's ramp for the wide shells (a fan of faint wedges on the rig, from behind the
    hilt). So every shell is FLATTENED toward the eye (depth flat_of(r) * r, width r): its silhouette is
    then at cos(phi) = flat * r / E, below G_LO while the eye is more than ~2.6 units from the beam line. Seen from the side it is the same bump (d = r sin(phi)).
  * The tip cap's rows hold g(cos(lat) cos(phi)): the round tip has the same soft profile seen from the side.
  * THE BOTTOM: no flat cut. A shell wider than the emitter mouth (R_MOUTH) closes onto the mouth in a short
    rounded taper, and each shell fades in up the blade over a length that grows with its radius (the white core
    in ~0.3 units, the bloom in ~1.5). Nothing bulges below the emitter.

Two parts, as vgsplit: CORE (white, faded in fast swings) and HALO (colour). Units: WORLD map units at width
factor 1 (UBQS_BeamGlow scale.x = factor), blade length L0 along md3 +Z from the emitter (z = 0).
md3 winding as volglow.capsule (Q3: the cross product points inward).
"""
import io
import math

import numpy as np
from PIL import Image
from scipy.optimize import lsq_linear

import volglow as VG

L0 = VG.L0                 # 26: the mesh's nominal blade
R_MOUTH = 0.38             # the emitter mouth (Wardust's hilt: 0.34-0.42 at the top, size 1)
G_LO = 0.40                # g(): 0 below this cos(phi) (the shell is invisible from 0.917 r out)


def flat_of(r):
    """a shell's depth toward the eye / its width (see PERSPECTIVE): the wide faint shells flat, the bright
    narrow ones nearly round (they make the tip's shape seen from behind the hilt)"""
    return min(0.85, max(0.25, 0.9 - 0.25 * r))
BW = 64                    # texels per shell band (round the shell)
TEX_H = 128
V_KNEE, V_BODY = 0.5, 0.75  # z 0..Z_KNEE -> v 0..V_KNEE; Z_KNEE..L0 -> ..V_BODY; the tip cap -> V_BODY..1
Z_KNEE = 4.0

# THE LOOK (the owner: "the film look: the white core about as wide as the emitter mouth, the colour tight
# round it, only a faint wide bloom")
CORE_W, CORE_A = 0.36, 1.35          # white-hot core: 1.35 exp(-(d / 0.36)^2.2) -- white out to ~0.33
HALO_W = 0.75                        # the colour: exp(-(d / 0.75)^2) -- half strength out to ~0.73
BLOOM_A, BLOOM_W, R_OUT = 0.32, 0.80, 2.8   # the faint bloom: 0.32 exp(-d / 0.80), to nothing at R_OUT (rig: 0.25 / 0.7 read as a bare line at 50 units)

TIERS = {
    "low":   dict(core=4, halo=5, seg=14, cap=4, taper=4),
    "med":   dict(core=5, halo=6, seg=16, cap=5, taper=5),
    "high":  dict(core=6, halo=8, seg=20, cap=6, taper=6),
    "ultra": dict(core=7, halo=10, seg=24, cap=7, taper=7),
}


def g(c):
    t = np.clip((np.asarray(c, float) - G_LO) / (1.0 - G_LO), 0, 1)
    return t * t * (3 - 2 * t)


def bump(d, r):
    x = np.clip(np.asarray(d, float) / r, 0, 1)
    return np.where(np.asarray(d) < r, g(np.sqrt(1 - x * x)), 0.0)


def core_profile(d):
    d = np.asarray(d, float)
    return CORE_A * np.exp(-(d / CORE_W) ** 2.2)


def halo_profile(d, rgb):
    d = np.asarray(d, float)
    col = np.array(rgb, float) / 255.0
    col = col / col.max()
    edge = np.clip((R_OUT - d) / 1.0, 0, 1) ** 2
    return (np.exp(-(d / HALO_W) ** 2) + BLOOM_A * np.exp(-d / BLOOM_W) * edge)[..., None] * col


def radii(tier, part):
    t = TIERS[tier]
    return np.geomspace(0.12, 0.90, t["core"]) if part == "core" else np.geomspace(0.20, R_OUT + 0.1, t["halo"])


def weights(tier, part, rgb):
    """(n, 3) per-shell colours, each channel in [0, 1], so sum_k C_k b_k(d) ~ the part's profile"""
    R = radii(tier, part)
    d = np.linspace(0, R_OUT + 0.2, 1500)
    T = np.repeat(core_profile(d)[:, None], 3, 1) if part == "core" else halo_profile(d, rgb)
    A = np.stack([bump(d, r) for r in R], 1)
    W = np.zeros((len(R), 3))
    for ch in range(3):
        w = 1.0 / (T[:, ch] + 0.03)                  # relative error matters in the faint bloom too
        if T[:, ch].max() < 1e-6:
            continue
        W[:, ch] = lsq_linear(A * w[:, None], T[:, ch] * w, bounds=(0, 1)).x
    return W


def fade_len(r):
    """how far up the blade a shell of radius r takes to come to full brightness"""
    return 0.25 + 0.55 * r


def z_to_v(z):
    z = np.asarray(z, float)
    lo = z / Z_KNEE * V_KNEE
    hi = V_KNEE + (z - Z_KNEE) / (L0 - Z_KNEE) * (V_BODY - V_KNEE)
    return np.clip(np.where(z < Z_KNEE, lo, hi), 0, V_BODY)


def v_to_z(v):
    v = np.asarray(v, float)
    return np.where(v < V_KNEE, v / V_KNEE * Z_KNEE, Z_KNEE + (v - V_KNEE) / (V_BODY - V_KNEE) * (L0 - Z_KNEE))


def lat_to_v(lat_deg):
    return V_BODY + (1 - V_BODY) * np.asarray(lat_deg, float) / 90.0


def shell(r, seg, cap, ntaper, u0, uw):
    """one closed shell. Returns verts, st (u, v), tris. Rings run theta = -90 .. 270 deg (seg + 1 vertices,
    the seam at the back, theta 270 = -Y); theta 90 (+Y) is the facing meridian = the middle of the band."""
    rings = []                                         # (radius, z, v)
    if r > R_MOUTH + 1e-6:
        T = 0.9 * (r - R_MOUTH) + 0.15
        for i in range(ntaper + 1):
            t = i / ntaper
            rr = R_MOUTH + (r - R_MOUTH) * math.sqrt(max(0.0, 1 - (1 - t) ** 2))
            rings.append((rr, T * t))
        z0 = T
    else:
        rings.append((r, 0.0))
        z0 = 0.0
    fl = fade_len(r)
    for z in sorted(set([fl * 0.5, fl, Z_KNEE])):
        if z0 < z < L0:
            rings.append((r, z))
    rings.append((r, L0))
    ringv = [float(z_to_v(z)) for _, z in rings]
    for i in range(1, cap + 1):
        a = math.pi / 2 * i / cap
        if i < cap:
            rings.append((r * math.cos(a), L0 + r * math.sin(a)))
            ringv.append(float(lat_to_v(math.degrees(a))))
    verts, st = [], []
    r0 = rings[0][0]
    fl_r = flat_of(r)
    verts.append((0.0, 0.0, 0.0))
    st.append((u0 + uw * 0.5, 0.0))
    ring_idx = []
    for (rr, z), v in zip(rings, ringv):
        idx = []
        for j in range(seg + 1):
            th = math.radians(-90.0 + 360.0 * j / seg)
            verts.append((rr * math.cos(th), fl_r * rr * math.sin(th), z))
            st.append((u0 + uw * j / seg, v))
            idx.append(len(verts) - 1)
        ring_idx.append(idx)
    verts.append((0.0, 0.0, L0 + r))
    st.append((u0 + uw * 0.5, 1.0))
    top = len(verts) - 1
    tris = []

    def tri(a, b, c):
        tris.append((a, c, b))
    R0 = ring_idx[0]
    for j in range(seg):
        tri(0, R0[j + 1], R0[j])
    for A, B in zip(ring_idx[:-1], ring_idx[1:]):
        for j in range(seg):
            tri(A[j], A[j + 1], B[j + 1])
            tri(A[j], B[j + 1], B[j])
    RT = ring_idx[-1]
    for j in range(seg):
        tri(top, RT[j], RT[j + 1])
    _ = r0
    return verts, st, tris


def part_mesh(tier, part):
    t = TIERS[tier]
    R = radii(tier, part)
    n = len(R)
    V, S, T = [], [], []
    for k, r in enumerate(R):
        # half a texel in from each band edge (the edges are black anyway: the back of the shell)
        u0 = (k * BW + 0.5) / (n * BW)
        uw = (BW - 1.0) / (n * BW)
        v, s, tr = shell(float(r), t["seg"], t["cap"], t["taper"], u0, uw)
        b = len(V)
        V += v
        S += s
        T += [(a + b, c + b, d + b) for a, c, d in tr]
    return V, S, T


def part_md3(tier, part):
    V, S, T = part_mesh(tier, part)
    return VG.write_md3("vgf%s_%s" % (part, tier), [{"name": "vglow", "shader": "vgface.png", "tris": T,
                                                    "st": [(u, 1.0 - v) for u, v in S],
                                                    "frames": [(V, [(0.0, 0.0, 1.0)] * len(V))]}], 1)


def part_tex(rgb, tier, part):
    """float (TEX_H, n * BW, 3); row 0 = v 0 (the emitter end)"""
    R = radii(tier, part)
    W = weights(tier, part, rgb)
    n = len(R)
    v = (np.arange(TEX_H) + 0.5) / TEX_H
    j = (np.arange(BW) + 0.5) / BW                      # across the band: theta -90 .. 270
    phi = np.radians(-180.0 + 360.0 * j)                # 0 = the facing meridian
    cphi = np.cos(phi)
    body = v < V_BODY
    z = v_to_z(np.minimum(v, V_BODY))
    lat = np.radians(np.clip((v - V_BODY) / (1 - V_BODY), 0, 1) * 90.0)
    tex = np.zeros((TEX_H, n * BW, 3))
    for k, r in enumerate(R):
        t = np.clip(z / fade_len(r), 0, 1)
        fz = np.where(body, t * t * (3 - 2 * t), 1.0)                       # (H,)
        c = np.where(body[:, None], cphi[None, :], np.cos(lat)[:, None] * cphi[None, :])
        tex[:, k * BW:(k + 1) * BW, :] = (fz[:, None] * g(c))[..., None] * W[k][None, None, :]
    return np.clip(tex, 0, 1)


def part_png(rgb, tier, part):
    tex = part_tex(rgb, tier, part)
    img = (np.round(tex[::-1] * 255)).astype(np.uint8)   # top row = t 0 = v 1
    b = io.BytesIO()
    Image.fromarray(img, "RGB").save(b, "PNG")
    return b.getvalue()


if __name__ == "__main__":
    for t in TIERS:
        for p in ("core", "halo"):
            V, S, T = part_mesh(t, p)
            print(t, p, "shells", len(radii(t, p)), "verts", len(V), "tris", len(T), "radii", np.round(radii(t, p), 2))

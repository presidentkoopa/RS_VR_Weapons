"""vgsplit.py -- the volumetric capsule glow (volglow.py, shells agent) split into two additive parts:

  CORE: the white-hot inner shells only (the profile's core term) -- the part that reads as "a second blade"
        when the world glow is off the zero-lag hand-layer tube in a fast swing, so it is faded with motion.
  HALO: the coloured bloom (the profile's halo term) on every shell -- reads as motion blur around the tube.

Same radii and tiers as volglow (both parts share volglow.shell_radii), so CORE + HALO == the full profile
before the framebuffer clips (additive). Each part is its own md3 (subset of shells) + PNG per colour.
"""
import io

import numpy as np
from PIL import Image

import math

import volglow as VG

# BUILD 50 -- the owner: "it's centered on the hilt". The capsules no longer round off BELOW the emitter (their
# bottom hemispheres reached ~4.7 units down over the hilt at width 1.35): each shell now starts FLAT at z = 0,
# the emitter, and the glow fades in over the first FADE_TOP units up the blade. Only the tip is rounded.
FADE_TOP = 1.5


def fade_flat(z):
    t = np.clip(np.asarray(z, float) / FADE_TOP, 0, 1)
    return t * t * (3 - 2 * t)


def capsule_flat(r, z1, seg, cap, band_u, l0=VG.L0):
    """A closed shell: a flat disc at z = 0, the tube up to z1, a hemisphere on top. Same winding as
    volglow.capsule (Q3: the cross product points inward), so its front faces survive the culling."""
    rings = [(r, 0.0)]
    for zk in (FADE_TOP, VG.ZKNEE):
        if 0.0 < zk < z1:
            rings.append((r, zk))
    rings.append((r, z1))
    for i in range(1, cap + 1):
        a = math.pi / 2 * i / cap
        rings.append((r * math.cos(a), z1 + r * math.sin(a)))
    verts, st = [(0.0, 0.0, 0.0)], [(band_u, float(VG.z_to_v(0.0, l0)))]
    ring_idx = []
    for (rr, z) in rings:
        if rr < 1e-6:
            continue
        idx = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            verts.append((rr * math.cos(a), rr * math.sin(a), z))
            st.append((band_u, float(VG.z_to_v(z, l0))))
            idx.append(len(verts) - 1)
        ring_idx.append(idx)
    verts.append((0.0, 0.0, z1 + r))
    st.append((band_u, float(VG.z_to_v(z1 + r, l0))))
    top = len(verts) - 1
    tris = []

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


def core_profile(d, rgb, r_out=VG.R_OUT):
    d = np.asarray(d, float)[..., None]
    k = r_out / 3.5
    c = 1.20 * np.exp(-(d / (0.45 * k)) ** 2.5)
    return np.repeat(c, 3, axis=-1)


def halo_profile(d, rgb, r_out=VG.R_OUT):
    return VG.profile(d, rgb, r_out) - core_profile(d, rgb, r_out)


def _colours(prof, rgb, radii, r_out=VG.R_OUT):
    radii = np.asarray(radii, float)
    inner = np.concatenate([[0.0], radii[:-1]])
    rep = np.array([float(np.sqrt((a * a + b * b) / 2)) if a > 0 else b * 0.35 for a, b in zip(inner, radii)])
    T = prof(rep, rgb, r_out)
    C = T - np.vstack([T[1:], np.zeros((1, 3))])
    return np.clip(C, 0, None)


def part_shells(tier, part):
    """indices of the shells a part uses: the core only where its white still adds >= 1/255"""
    radii = VG.shell_radii(VG.TIERS[tier]["n"])
    if part == "halo":
        return radii, list(range(len(radii)))
    C = _colours(core_profile, (255, 255, 255), radii)
    idx = [k for k in range(len(radii)) if C[k].max() >= 1.0 / 255]
    return radii, idx or [0]


def part_md3(tier, part):
    radii, idx = part_shells(tier, part)
    t = VG.TIERS[tier]
    V, S, T = [], [], []
    n = len(idx)
    for j, k in enumerate(idx):
        u = (j * VG.TEX_BAND + VG.TEX_BAND / 2) / (n * VG.TEX_BAND)
        v, s, tr = capsule_flat(float(radii[k]), VG.L0, t["seg"], t["cap"], u, VG.L0)
        b = len(V)
        V += v
        S += s
        T += [(a + b, c + b, d + b) for a, c, d in tr]
    return VG.write_md3("vg%s_%s" % (part, tier), [{"name": "vglow", "shader": "volglow.png", "tris": T,
                                                   "st": VG._flip_t(S), "frames": [(V, [(0.0, 0.0, 1.0)] * len(V))]}], 1)


def part_png(rgb, tier, part):
    radii, idx = part_shells(tier, part)
    C = _colours(core_profile if part == "core" else halo_profile, rgb, radii)
    # a subset keeps its own colours, except the core's last used shell also carries what the dropped
    # (sub-1/255) shells would have added, so nothing is lost
    n = len(idx)
    v = (np.arange(VG.TEX_H) + 0.5) / VG.TEX_H
    f = fade_flat(VG.v_to_z(v))
    tex = np.zeros((VG.TEX_H, n * VG.TEX_BAND, 3))
    for j, k in enumerate(idx):
        ck = C[k] if (part == "halo" or j < n - 1) else C[k:].sum(axis=0)
        tex[:, j * VG.TEX_BAND:(j + 1) * VG.TEX_BAND, :] = f[:, None, None] * ck[None, None, :]
    img = (np.round(np.clip(tex, 0, 1)[::-1] * 255)).astype(np.uint8)
    b = io.BytesIO()
    Image.fromarray(img, "RGB").save(b, "PNG")
    return b.getvalue()


if __name__ == "__main__":
    for t in VG.TIERS:
        print(t, "core shells", part_shells(t, "core")[1], "of", len(part_shells(t, "halo")[1]))

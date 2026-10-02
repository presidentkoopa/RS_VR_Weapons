"""glowpreview.py -- offline software renderer for the additive glow models (numpy).

Reads the actual md3 BYTES (so the writer is exercised) and the PNG texture, rasterises every triangle with
perspective-correct UVs, bilinear sampling, QZD's translucent-model back-face culling (front = Q3 winding:
(v1-v0)x(v2-v0) points away from the viewer), additive accumulation, and an optional opaque 'tube' (the solid
saber: analytic capsule r=TUBE_R + hilt) with three compositing modes:
   none  -- no tube
   world -- tube in the world depth buffer: glow in front of it adds over it, glow behind is hidden
   hand  -- tube on the HUD/hand layer (QZD VR: depth range 0..0.3, drawn before translucents): it occludes ALL
            world glow wherever it covers
Output: PNG contact sheets in preview/.
"""
import io
import math
import os
import struct
import sys

import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import volglow as G  # noqa: E402

PREV = os.path.join(HERE, "preview")


def read_md3(b):
    _, _, _, _, nf, ntag, ns, _, ofr, _, osurf, _ = struct.unpack_from("<4si64s9i", b, 0)
    out = []
    o = osurf
    for _ in range(ns):
        _, sname, _, snf, nsh, nv, nt, otri, osh, ost, oxyz, send = struct.unpack_from("<4s64s10i", b, o)
        tris = np.array([struct.unpack_from("<3i", b, o + otri + 12 * k) for k in range(nt)])
        st = np.array([struct.unpack_from("<2f", b, o + ost + 8 * k) for k in range(nv)])
        xyz = np.array([struct.unpack_from("<3h", b, o + oxyz + 8 * k) for k in range(nv)], float) / 64.0
        out.append((xyz, st, tris))
        o += send
    return out


def load_tex(png_bytes):
    a = np.asarray(Image.open(io.BytesIO(png_bytes)).convert("RGBA"), float) / 255.0
    return a[..., :3] * a[..., 3:4]          # Add: src*alpha + dst


def sample(tex, u, v):
    """bilinear, clamp; md3 st: u across, t down from the top row."""
    H, W, _ = tex.shape
    x = np.clip(u * W - 0.5, 0, W - 1)
    y = np.clip(v * H - 0.5, 0, H - 1)
    x0 = np.floor(x).astype(int); y0 = np.floor(y).astype(int)
    x1 = np.minimum(x0 + 1, W - 1); y1 = np.minimum(y0 + 1, H - 1)
    fx = (x - x0)[..., None]; fy = (y - y0)[..., None]
    return (tex[y0, x0] * (1 - fx) * (1 - fy) + tex[y0, x1] * fx * (1 - fy) +
            tex[y1, x0] * (1 - fx) * fy + tex[y1, x1] * fx * fy)


class Cam:
    def __init__(self, eye, target, up=(0, 0, 1), fov=50.0, W=300, H=300):
        self.eye = np.array(eye, float)
        f = np.array(target, float) - self.eye
        f /= np.linalg.norm(f)
        up = np.array(up, float)
        if abs(np.dot(up, f)) > 0.98:
            up = np.array([0.0, 1.0, 0.0])
        r = np.cross(f, up); r /= np.linalg.norm(r)
        u = np.cross(r, f)
        self.f, self.r, self.u = f, r, u
        self.W, self.H = W, H
        self.k = (H / 2) / math.tan(math.radians(fov) / 2)

    def project(self, P):
        d = P - self.eye
        z = d @ self.f
        x = d @ self.r
        y = d @ self.u
        return np.stack([self.W / 2 + self.k * x / z, self.H / 2 - self.k * y / z], -1), z

    def rays(self):
        j, i = np.meshgrid(np.arange(self.W) + 0.5, np.arange(self.H) + 0.5)
        x = (j - self.W / 2) / self.k
        y = -(i - self.H / 2) / self.k
        d = self.f[None, None] + x[..., None] * self.r + y[..., None] * self.u
        return d / np.linalg.norm(d, axis=-1, keepdims=True)


def capsule_hit(ro, rd, pa, pb, r):
    """iq's capsule intersection, vectorised over rays. Returns t (inf = miss)."""
    ba = pb - pa
    oa = ro - pa
    baba = ba @ ba
    bard = rd @ ba
    baoa = oa @ ba
    rdoa = (rd * oa).sum(-1)
    oaoa = oa @ oa
    a = baba - bard * bard
    b = baba * rdoa - baoa * bard
    c = baba * oaoa - baoa * baoa - r * r * baba
    h = b * b - a * c
    t = np.full(rd.shape[:-1], np.inf)
    ok = h >= 0
    with np.errstate(invalid="ignore", divide="ignore"):
        tc = (-b - np.sqrt(np.maximum(h, 0))) / a
        y = baoa + tc * bard
        body = ok & (y > 0) & (y < baba)
        t = np.where(body, tc, t)
        oc = np.where((y <= 0)[..., None], oa, ro - pb)
        bb = (rd * oc).sum(-1)
        cc = (oc * oc).sum(-1) - r * r
        hh = bb * bb - cc
        tcap = -bb - np.sqrt(np.maximum(hh, 0))
        capok = ok & ~body & (hh > 0)
        t = np.where(capok, tcap, t)
    return t


def render_tube(cam, frame_pts):
    """opaque tube: blade capsule r=TUBE_R emitter..tip, hilt r=0.95 below. Returns colour (H,W,3), depth."""
    A, Dz, L = frame_pts
    rd = cam.rays()
    ro = cam.eye
    tb = capsule_hit(ro, rd, A, A + Dz * L, G.TUBE_R)
    th = capsule_hit(ro, rd, A - Dz * 9.0, A - Dz * 0.25, 0.95)
    t = np.minimum(tb, th)
    hitb = np.isfinite(tb) & (tb <= th)
    hith = np.isfinite(th) & (th < tb)
    P = ro + rd * np.where(np.isfinite(t), t, 0)[..., None]
    # normal: from nearest axis point
    s = np.clip(((P - A) @ Dz), -9.0, L)
    N = P - (A + s[..., None] * Dz)
    N /= np.linalg.norm(N, axis=-1, keepdims=True) + 1e-9
    light = np.array([0.4, -0.6, 0.7]); light /= np.linalg.norm(light)
    lam = 0.35 + 0.65 * np.clip(N @ light, 0, 1)
    spec = np.clip((N * -rd).sum(-1), 0, 1) ** 8 * 0.25
    col = np.zeros(rd.shape)
    col[hitb] = (np.array([0.80, 0.80, 0.82]) * lam[hitb, None] + spec[hitb, None])   # light grey plastic tube
    col[hith] = (np.array([0.22, 0.22, 0.24]) * lam[hith, None] + spec[hith, None])
    # depth as view-space z (along cam.f)
    z = np.where(np.isfinite(t), t * (rd @ cam.f), np.inf)
    return col, z, (hitb | hith), hitb


def raster_add(cam, mesh, tex, M, depth=None, alpha=1.0):
    """Additively rasterise an md3 surface. M: 3x4 model->world. Front faces only (Q3 winding)."""
    xyz, st, tris = mesh
    P = xyz @ M[:, :3].T + M[:, 3]
    scr, z = cam.project(P)
    acc = np.zeros((cam.H, cam.W, 3))
    a, b, c = P[tris[:, 0]], P[tris[:, 1]], P[tris[:, 2]]
    nin = np.cross(b - a, c - a)                    # points INTO the surface for front faces
    det = np.linalg.det(M[:, :3])
    if det < 0:
        nin = -nin
    front = ((cam.eye - a) * nin).sum(-1) < 0       # inward normal points away from the eye
    for ti in np.nonzero(front)[0]:
        i0, i1, i2 = tris[ti]
        if min(z[i0], z[i1], z[i2]) < 0.1:
            continue
        p0, p1, p2 = scr[i0], scr[i1], scr[i2]
        xmin = max(int(math.floor(min(p0[0], p1[0], p2[0]))), 0)
        xmax = min(int(math.ceil(max(p0[0], p1[0], p2[0]))), cam.W - 1)
        ymin = max(int(math.floor(min(p0[1], p1[1], p2[1]))), 0)
        ymax = min(int(math.ceil(max(p0[1], p1[1], p2[1]))), cam.H - 1)
        if xmin > xmax or ymin > ymax:
            continue
        area = (p1[0] - p0[0]) * (p2[1] - p0[1]) - (p1[1] - p0[1]) * (p2[0] - p0[0])
        if abs(area) < 1e-9:
            continue
        X, Y = np.meshgrid(np.arange(xmin, xmax + 1) + 0.5, np.arange(ymin, ymax + 1) + 0.5)
        w0 = ((p1[0] - X) * (p2[1] - Y) - (p1[1] - Y) * (p2[0] - X)) / area
        w1 = ((p2[0] - X) * (p0[1] - Y) - (p2[1] - Y) * (p0[0] - X)) / area
        w2 = 1 - w0 - w1
        inside = (w0 >= 0) & (w1 >= 0) & (w2 >= 0)
        if not inside.any():
            continue
        iz = np.array([1 / z[i0], 1 / z[i1], 1 / z[i2]])
        q = w0 * iz[0] + w1 * iz[1] + w2 * iz[2]
        uu = (w0 * st[i0, 0] * iz[0] + w1 * st[i1, 0] * iz[1] + w2 * st[i2, 0] * iz[2]) / q
        vv = (w0 * st[i0, 1] * iz[0] + w1 * st[i1, 1] * iz[1] + w2 * st[i2, 1] * iz[2]) / q
        zz = 1 / q
        if depth is not None:
            inside &= zz < depth[ymin:ymax + 1, xmin:xmax + 1]
        if not inside.any():
            continue
        col = sample(tex, uu[inside], vv[inside]) * alpha
        sub = acc[ymin:ymax + 1, xmin:xmax + 1]
        sub[inside] += col
    return acc


def blade_frame(A=(0, 0, 0), D=(0, 0, 1), L=G.L0, s=1.0, L0=G.L0):
    """model->world for actor scale (s, L/L0) placed at A pointing along D (model +Z -> D)."""
    D = np.array(D, float); D /= np.linalg.norm(D)
    X = np.cross(D, [0, 1, 0]) if abs(D[1]) < 0.9 else np.cross(D, [1, 0, 0])
    X /= np.linalg.norm(X)
    Y = np.cross(D, X)
    R = np.stack([X * s, Y * s, D * (L / L0)], 1)
    return np.concatenate([R, np.array(A, float)[:, None]], 1)


# the views: (name, angle between view direction and the blade axis, side)
VIEWS = [("side 90", 90.0), ("45", 45.0), ("grazing 15", 15.0), ("down-axis 3", 3.0), ("tip close", -1), ("emitter close", -2)]


def view_cam(ang, L, W=300, H=300, dist=24.0):
    """camera looking at the blade's middle; ang = angle between the line of sight and the blade axis,
    camera beyond the tip side for small angles."""
    mid = np.array([0, 0, L * 0.5])
    if ang == -1:
        return Cam(np.array([0, -9.0, L - 1.0]), np.array([0, 0, L - 1.0]), fov=52, W=W, H=H)
    if ang == -2:
        return Cam(np.array([-4.0, -8.0, 1.0]), np.array([0, 0, 1.0]), fov=52, W=W, H=H)
    a = math.radians(ang)
    if ang >= 89:
        eye = mid + np.array([0, -dist, 0])
        return Cam(eye, mid, up=(0, 0, 1), fov=52, W=W, H=H)
    # line of sight direction from eye: (-sin a * ..., cos a) toward -z (looking back down the blade)
    tipside = np.array([0, 0, L])
    eye = tipside + np.array([0, -math.sin(a), math.cos(a)]) * dist
    tgt = mid if ang > 20 else np.array([0, 0, L * 0.5])
    return Cam(eye, tgt, up=(0, 1, 0) if ang < 20 else (0, 0, 1), fov=52, W=W, H=H)


def render(mesh, tex, ang, bg=0.0, tube="none", alpha=1.0, L=G.L0, W=300, H=300, M=None):
    cam = view_cam(ang, L, W, H)
    M = blade_frame(L=L) if M is None else M
    depth = None
    tcol = tz = tmask = None
    if tube != "none":
        tcol, tz, tmask, _ = render_tube(cam, (np.zeros(3), np.array([0, 0, 1.0]), L))
        depth = tz
    acc = raster_add(cam, mesh, tex, M, depth if tube == "world" else None, alpha)
    img = np.full((H, W, 3), bg, float)
    if tube == "world":
        img[tmask] = tcol[tmask]
        img = img + acc
    elif tube == "hand":
        img = img + acc
        img[tmask] = tcol[tmask]
    else:
        img = img + acc
    return np.clip(img, 0, 1)


def to_img(a):
    return Image.fromarray((np.clip(a, 0, 1) * 255).astype(np.uint8), "RGB")


def sheet(rows, cols, cells, title, path, cw=300, ch=300):
    """cells[r][c] float images."""
    pad, top, left = 4, 30, 150
    im = Image.new("RGB", (left + len(cols) * (cw + pad), top + len(rows) * (ch + pad) + 4), (24, 24, 28))
    d = ImageDraw.Draw(im)
    d.text((6, 6), title, fill=(230, 230, 230))
    for j, c in enumerate(cols):
        d.text((left + j * (cw + pad) + 4, 18), c, fill=(200, 200, 200))
    for i, r in enumerate(rows):
        d.text((6, top + i * (ch + pad) + ch // 2), r, fill=(200, 200, 200))
        for j in range(len(cols)):
            im.paste(to_img(cells[i][j]), (left + j * (cw + pad), top + i * (ch + pad)))
    os.makedirs(os.path.dirname(path), exist_ok=True)
    im.save(path)
    return path


# ---- the build-37 reference (ubqs.py beamglow_md3 / beamglow_png), laid the way UBQS_BeamGlow laid it ----
def b37_assets(nplanes=3):
    sys.path.insert(0, os.path.join(HERE, "..", "src"))
    sys.path.insert(0, os.path.join(HERE, "..", "src"))
    argv = sys.argv
    sys.argv = sys.argv[:1]
    import ubqs  # noqa
    sys.argv = argv
    md3 = ubqs.beamglow_md3(nplanes)
    png = ubqs.beamglow_png((70, 140, 255))
    return read_md3(md3)[0], load_tex(png)


def b37_frame(L=G.L0, w=G.R_OUT):
    """UBQS_BeamGlow.Lay: scale = (w, L/64); the mesh is 64 long, +-1 wide."""
    M = blade_frame(L=L)
    M[:, 0] *= w; M[:, 1] *= w
    M[:, 2] *= (L / 64.0) / (L / G.L0)
    return M


def main(tiers=("low", "med", "high", "ultra"), rgb=(70, 140, 255), tag="B"):
    variants = [("build37 3-plane", b37_assets(3), 0.6, b37_frame())]
    for t in tiers:
        variants.append(("volglow " + t, (read_md3(G.volglow_md3(t))[0], load_tex(G.volglow_png(rgb, t))), 1.0, None))
    cols = [v[0] for v in VIEWS]
    out = []
    for bgname, bg, tube in (("black", 0.0, "none"), ("grey", 0.5, "none"), ("tube-world", 0.0, "world"),
                             ("tube-hand", 0.0, "hand")):
        cells = [[render(m, tx, ang, bg, tube, a, M=M) for _, ang in VIEWS] for (_, (m, tx), a, M) in variants]
        p = sheet([v[0] for v in variants], cols, cells, "%s glow, bg %s, tube %s" % (tag, bgname, tube),
                  os.path.join(PREV, "sheet_%s_%s.png" % (tag, bgname)))
        out.append(p)
        print(p)
    return out


if __name__ == "__main__":
    main()


def colours_sheet(tier="high"):
    m = read_md3(G.volglow_md3(tier))[0]
    views = [("side 90", 90.0), ("45", 45.0), ("down-axis 3", 3.0), ("tip close", -1)]
    cells, rows = [], []
    for tag, name, rgb in G.COLORS:
        tx = load_tex(G.volglow_png(rgb, tier))
        cells.append([render(m, tx, a, 0.0, "none", 1.0, W=220, H=220) for _, a in views])
        rows.append(name)
    return sheet(rows, [v[0] for v in views], cells, "all colours, tier %s, black" % tier,
                 os.path.join(PREV, "colours_%s.png" % tier), 220, 220)


def hero(tier="high", rgb=(70, 140, 255)):
    """big side-by-side: build-37 vs volglow, 3 views incl. the worst case for planes."""
    b37m, b37t = b37_assets(3)
    m = read_md3(G.volglow_md3(tier))[0]
    tx = load_tex(G.volglow_png(rgb, tier))
    views = [("side 90", 90.0), ("grazing 15", 15.0), ("tip close", -1), ("down-axis 3", 3.0)]
    cells = [[render(b37m, b37t, a, 0.0, "none", 0.6, W=360, H=360, M=b37_frame()) for _, a in views],
             [render(m, tx, a, 0.0, "none", 1.0, W=360, H=360) for _, a in views],
             [render(m, tx, a, 0.0, "world", 1.0, W=360, H=360) for _, a in views]]
    return sheet(["build37 3-plane", "volglow " + tier, tier + " over grey tube"], [v[0] for v in views], cells,
                 "hero: build-37 vs volglow-%s (black bg)" % tier, os.path.join(PREV, "hero_%s.png" % tier), 360, 360)

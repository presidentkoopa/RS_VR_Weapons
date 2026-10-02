"""preview51.py -- offline close-range previews of the b50 (vgsplit) and b51 (vgface) world glow, with the hand-layer
hilt + emitter stub drawn opaque over it (the hand layer occludes world FX). Uses the shells agent's glowpreview
rasteriser (read-only import). Views include the owner's headset shot: saber close, blade going away."""
import math, os, sys, io
import numpy as np
from PIL import Image, ImageDraw
P = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(P, "ubqs"))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "src"))
import glowpreview as GP
import vgface as VF
import importlib.util
spec = importlib.util.spec_from_file_location("vgsplit50", os.path.join(P, "b50src_final", "vgsplit.py"))
VS = importlib.util.module_from_spec(spec); spec.loader.exec_module(VS)

BLUE = (70, 140, 255)
L = 26.0

def frame(D, F, s, L):
    D = np.array(D, float); D /= np.linalg.norm(D)
    F = np.array(F, float); F = F - D * (F @ D); F /= np.linalg.norm(F)
    X = np.cross(F, D)
    return np.stack([X * s, F * s, D * (L / VF.L0)], 1)

def render(cam, D, assets, facing, s, stub_r, stub_len, size=1.0, ferr=0.0):
    A = np.zeros(3); D = np.array(D, float) / np.linalg.norm(D)
    eye = cam.eye
    F = (eye - A) - D * ((eye - A) @ D)
    if not facing:            # b50: no roll -- any perpendicular frame (the mesh is symmetric)
        F = np.cross(D, [1, 0, 0]) if abs(D[0]) < 0.9 else np.cross(D, [0, 1, 0])
    if ferr:
        F = F / np.linalg.norm(F); Sx = np.cross(D, F)
        F = F * math.cos(math.radians(ferr)) + Sx * math.sin(math.radians(ferr))
    R = frame(D, F, s, L)
    M = np.concatenate([R, A[:, None]], 1)
    acc = np.zeros((cam.H, cam.W, 3))
    for mesh, tex, a in assets:
        acc += GP.raster_add(cam, mesh, tex, M, None, a)
    img = 0.06 + acc
    # the hand layer: hilt (r 0.6, 8.7 long below the emitter) and the stub, opaque, over everything
    rd = cam.rays(); ro = cam.eye
    th = GP.capsule_hit(ro, rd, A - D * 8.5, A - D * 0.2, 0.62 * size)
    hit = np.isfinite(th)
    img[hit] = np.array([0.32, 0.32, 0.34])
    if stub_len > 0:
        ts = GP.capsule_hit(ro, rd, A, A + D * stub_len, stub_r)
        hs = np.isfinite(ts) & (ts < th)
        # white core with the colour rim
        Pp = ro + rd * np.where(np.isfinite(ts), ts, 0)[..., None]
        s_ = np.clip((Pp - A) @ D, 0, stub_len)
        rr = np.linalg.norm(Pp - (A + s_[..., None] * D), axis=-1)
        img[hs] = np.array([1.0, 1.0, 1.0])
    return np.clip(img, 0, 1)

def assets50():
    out = []
    for part in ("halo", "core"):
        m = GP.read_md3(VS.part_md3("high", part))[0]
        t = GP.load_tex(VS.part_png(BLUE, "high", part))
        out.append((m, t, 1.0))
    return out

def assets51(tier="high"):
    out = []
    for part in ("halo", "core"):
        m = GP.read_md3(VF.part_md3(tier, part))[0]
        t = GP.load_tex(VF.part_png(BLUE, tier, part))
        out.append((m, t, 1.0))
    return out

def views(W=360, H=360):
    D = np.array([0.0, 0.8, 0.6]); D /= np.linalg.norm(D)
    v = []
    # the owner's shot: eye behind and above the hilt, blade going away (about 25 deg off the line of sight)
    for name, ang, dist, tgt_along in (("headset: away 25deg", 25, 11.0, 7.0), ("away 40deg", 40, 12.0, 7.0),
                                        ("side 90 close", 90, 14.0, 4.0), ("side 90 mid", 90, 30.0, 13.0)):
        a = math.radians(ang)
        side = np.cross(D, [1, 0, 0]); side /= np.linalg.norm(side)      # 'up' perpendicular
        eye = -D * dist * math.cos(a) + side * dist * math.sin(a) + np.array([0.6, 0, 0])
        if ang == 90:
            eye = D * tgt_along + np.array([1, 0, 0]) * dist
        cam = GP.Cam(eye, D * tgt_along, up=(0, 0, 1), fov=60, W=W, H=H)
        v.append((name, cam, D))
    # tip close
    cam = GP.Cam(D * (L - 1) + np.array([9.0, 0, 0]), D * (L - 1), up=(0, 0, 1), fov=60, W=W, H=H)
    v.append(("tip close", cam, D))
    return v

if __name__ == "__main__":
    rows = [("b50 (ships)", assets50(), False, 1.35, 0.171, 4.0),
            ("b51 high", assets51("high"), True, 1.0, float(sys.argv[1]) if len(sys.argv) > 1 else 0.30, 4.0),
            ("b51 low", assets51("low"), True, 1.0, float(sys.argv[1]) if len(sys.argv) > 1 else 0.30, 4.0)]
    vs = views()
    cells = [[render(cam, D, a, f, s, sr, sl) for _, cam, D in vs] for _, a, f, s, sr, sl in rows]
    out = sys.argv[2] if len(sys.argv) > 2 else os.path.join(P, "preview51.png")
    GP.sheet([r[0] for r in rows], [v[0] for v in vs], cells, "b50 vs b51 world glow, opaque hand-layer hilt + stub over it", out, 360, 360)
    print(out)

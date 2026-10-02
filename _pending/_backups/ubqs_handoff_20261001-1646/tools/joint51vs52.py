"""joint51vs52.py -- does the beam reach the hilt?

Renders the REAL shipped glow meshes out of a pk3 (no scipy, no vgface: the md3s and their skins are
already built), with the opaque hand-layer hilt drawn over them exactly as preview51.py does. Each
glow shell fades in over a length that grows with its radius, so at the emitter mouth the glow is far
below full brightness -- a dark band between the hilt and where the beam becomes visible, present at
zero prediction error. Starting a part below the mouth and lengthening it to match closes that without
moving the tip. Too much and the halo's bloom sleeves the hilt instead.

    python joint51vs52.py [pk3] [out.png]      # the comparison sheet
    python joint51vs52.py [pk3] --profile      # brightness along the beam, per part
"""
import math
import os
import sys
import zipfile

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, "..", "src"))      # volglow, which glowpreview imports

import glowpreview as GP  # noqa: E402

PK3 = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
    HERE, "..", "build", "UltraBadassQuestSaber_b51.pk3")
OUT = sys.argv[2] if len(sys.argv) > 2 and not sys.argv[2].startswith("--") else \
    os.path.join(HERE, "preview", "joint.png")

L0 = 26.0            # the glow md3 is built for a 26-unit blade, model z 0 at the emitter
BLADE = 26.0
HILT_R = 0.62        # the hand-layer hilt's radius (preview51.py)
HILT_BELOW = 8.5     # emitter down to the pommel, world units at size 1

# base errors to show: zero, the measured RMS, the measured p99 (sim_real.py, lead 1.0, 0.2 deg noise)
ERRS = [("exact", 0.0), ("RMS 0.38", 0.376), ("p99 1.24", 1.242)]


def assets(pk3, tier="high", col="B"):
    """(mesh, tex) for the halo then the core, straight out of the pk3's built lumps."""
    z = zipfile.ZipFile(pk3)
    out = []
    for part in ("halo", "core"):
        base = "models/ubqs/vg%s_%s" % (part, tier)
        out.append((GP.read_md3(z.read(base + ".md3"))[0],
                    GP.load_tex(z.read("%s_%s.png" % (base, col))), 1.0))
    return out


def frame(D, F, s, length):
    """model->world: md3 +Z along the beam, +Y the meridian facing the eye (UBQS_BeamGlow.Place)."""
    D = np.array(D, float); D /= np.linalg.norm(D)
    F = np.array(F, float); F = F - D * (F @ D); F /= np.linalg.norm(F)
    X = np.cross(F, D)
    return np.stack([X * s, F * s, D * (length / L0)], 1)


def glow_acc(cam, D, ast, ovs, err_dir, err, size=1.0):
    """ovs = (halo overlap, core overlap): how far below the emitter each part starts. Pushing a part
    down by ov and lengthening it by ov leaves its tip where it was."""
    A = np.zeros(3)
    D = np.array(D, float) / np.linalg.norm(D)
    acc = np.zeros((cam.H, cam.W, 3))
    for (mesh, tex, a), ov in zip(ast, ovs):
        Ag = A - D * ov + err_dir * err             # only the glow carries the prediction error
        F = (cam.eye - Ag) - D * ((cam.eye - Ag) @ D)
        M = np.concatenate([frame(D, F, size, BLADE + ov), Ag[:, None]], 1)
        acc += GP.raster_add(cam, mesh, tex, M, None, a)
    return acc


def render(cam, D, ast, ovs, err_dir, err, size=1.0):
    """The glow, then the EXACT hilt opaque over it (the hand layer occludes world FX)."""
    A = np.zeros(3)
    D = np.array(D, float) / np.linalg.norm(D)
    img = 0.06 + glow_acc(cam, D, ast, ovs, err_dir, err, size)
    th = GP.capsule_hit(cam.rays(), cam.rays() * 0 + cam.eye, A, A, 1.0) if False else \
        GP.capsule_hit(cam.eye, cam.rays(), A - D * HILT_BELOW * size, A - D * 0.2, HILT_R * size)
    img[np.isfinite(th)] = np.array([0.32, 0.32, 0.34])
    return np.clip(img, 0, 1)


def escaped(cam, D, ast, ovs, err_dir, err, size=1.0):
    """Glow light landing BELOW the emitter mouth and OUTSIDE the hilt -- the visible overrun."""
    A = np.zeros(3)
    D = np.array(D, float) / np.linalg.norm(D)
    acc = glow_acc(cam, D, ast, ovs, err_dir, err, size)
    th = GP.capsule_hit(cam.eye, cam.rays(), A - D * HILT_BELOW * size, A - D * 0.2, HILT_R * size)
    scr, _ = cam.project(np.stack([A, A - D * HILT_BELOW * size]))
    y0, y1 = sorted((scr[0][1], scr[1][1]))
    _, ii = np.meshgrid(np.arange(cam.W), np.arange(cam.H))
    band = (ii >= max(int(y0), 0)) & (ii <= min(int(y1), cam.H - 1))
    lit = (acc.max(-1) > 0.02) & band & ~np.isfinite(th)
    return float(acc.max(-1)[lit].sum())


def views(W=360, H=360):
    D = np.array([0.0, 0.8, 0.6]); D /= np.linalg.norm(D)
    out = []
    for name, ang, dist, along in (("headset: away 25deg", 25, 11.0, 5.0),
                                   ("side 90, joint close", 90, 9.0, 2.0),
                                   ("side 90, whole blade", 90, 30.0, 13.0),
                                   ("grazing 50deg", 50, 10.0, 4.0)):
        a = math.radians(ang)
        side = np.cross(D, [1, 0, 0]); side /= np.linalg.norm(side)
        eye = (D * along + side * dist) if ang == 90 else \
            (-D * dist * math.cos(a) + side * dist * math.sin(a) + np.array([0.6, 0, 0]))
        out.append((name, GP.Cam(eye, D * along, up=(0, 0, 1), fov=60, W=W, H=H), D))
    return out


def profile(ast):
    """Brightness along the beam, per part: where does each actually reach full?"""
    D = np.array([0., 0., 1.])
    cam = GP.Cam(np.array([14., 0., 6.]), np.array([0., 0., 6.]), up=(0, 0, 1), fov=60, W=420, H=420)
    for (mesh, tex, a), name in zip(ast, ("halo", "core")):
        b = glow_acc(cam, D, [(mesh, tex, a)], [0.0], np.zeros(3), 0.0).max(-1)
        zs = np.linspace(0.0, 4.0, 17)
        scr, _ = cam.project(np.stack([D * z for z in zs]))
        vals = [(z, float(b[int(round(y)), max(0, int(round(x)) - 6):int(round(x)) + 7].max()))
                for z, (x, y) in zip(zs, scr) if 0 <= int(round(y)) < cam.H]
        peak = max(v for _, v in vals)
        print("==", name)
        for z, v in vals:
            print("   z=%4.2f  %5.1f%%  %s" % (z, 100 * v / peak, "#" * int(40 * v / peak)))


def main():
    ast = assets(PK3)
    if "--profile" in sys.argv:
        profile(ast)
        return
    D = np.array([0.0, 0.8, 0.6]); D /= np.linalg.norm(D)
    err_dir = np.cross(D, [1, 0, 0]); err_dir /= np.linalg.norm(err_dir)
    builds = [("b51  halo 0  core 0", (0.0, 0.0)),
              ("b54  halo 1.5 core 0.5", (1.5, 0.5)),
              ("halo 3.0 core 1.0", (3.0, 1.0)),
              ("halo 4.0 core 4.0 (too much)", (4.0, 4.0))]
    vs = views()
    rows, cells = [], []
    print("glow light below the emitter mouth and outside the hilt (lower = less sleeving):")
    for bname, ovs in builds:
        for ename, err in ERRS:
            rows.append("%s | %s" % (bname, ename))
            cells.append([render(cam, Dv, ast, ovs, err_dir, err) for _, cam, Dv in vs])
            print("  %-30s %-10s %10.1f" % (bname, ename, escaped(vs[1][1], D, ast, ovs, err_dir, err)))
    GP.sheet(rows, [v[0] for v in vs], cells,
             "does the beam reach the hilt? (hilt drawn exact, over the glow)", OUT, 360, 360)
    print(OUT)


if __name__ == "__main__":
    main()

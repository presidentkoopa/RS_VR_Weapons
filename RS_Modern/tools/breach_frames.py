"""Which animation frames stand a BREACH rig's gun straight: for every frame, where the root bone points the muzzle
and the top in file space, and the angle from straight (muzzle along +x, top along +z). Only the joints are posed --
fast enough for every frame. Frames within --tol degrees are marked STRAIGHT.
    python breach_frames.py <iqm> --root <bone> --forward <axis> --up <axis> [--tol 1.0] [--every 1]
"""
import argparse, math, struct
import numpy as np

AX = {"+x": (1, 0, 0), "-x": (-1, 0, 0), "+y": (0, 1, 0), "-y": (0, -1, 0), "+z": (0, 0, 1), "-z": (0, 0, -1)}
ap = argparse.ArgumentParser()
ap.add_argument("iqm")
ap.add_argument("--root", required=True)
ap.add_argument("--forward", required=True, choices=AX)
ap.add_argument("--up", required=True, choices=AX)
ap.add_argument("--tol", type=float, default=1.0)
ap.add_argument("--every", type=int, default=1)
a = ap.parse_args()

d = open(a.iqm, "rb").read()
h = struct.unpack_from("<27I", d, 16)
num_text, ofs_text = h[3], h[4]
num_joints, ofs_joints, num_poses, ofs_poses = h[13], h[14], h[15], h[16]
num_frames, num_fch, ofs_frames = h[19], h[20], h[21]
text = d[ofs_text:ofs_text + num_text]
cstr = lambda o: text[o:text.find(b"\0", o)].decode("latin-1")


def trs(t, q):
    x, y, z, w = q
    n = math.sqrt(x * x + y * y + z * z + w * w) or 1.0
    x, y, z, w = x / n, y / n, z / n, w / n
    m = np.eye(4)
    m[:3, :3] = [[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
                 [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
                 [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)]]
    m[:3, 3] = t
    return m


parents, names = [], []
for i in range(num_joints):
    nm, parent = struct.unpack_from("<Ii", d, ofs_joints + 48 * i)
    names.append(cstr(nm))
    parents.append(parent)
root = names.index(a.root)
chain = []
j = root
while j >= 0:
    chain.append(j)
    j = parents[j]
chain.reverse()
poses = [(struct.unpack_from("<iI", d, ofs_poses + 88 * i)[1], struct.unpack_from("<10f", d, ofs_poses + 8 + 88 * i),
          struct.unpack_from("<10f", d, ofs_poses + 48 + 88 * i)) for i in range(num_poses)]
data = struct.unpack_from(f"<{num_frames * num_fch}H", d, ofs_frames)
k = 0
fwd0, up0 = np.array(AX[a.forward], float), np.array(AX[a.up], float)
straight = []
for f in range(num_frames):
    local = []
    for (mask, off, sc) in poses:
        ch = []
        for c in range(10):
            v = off[c]
            if mask & (1 << c):
                v += data[k] * sc[c]
                k += 1
            ch.append(v)
        local.append(ch)
    if f % a.every:
        continue
    M = np.eye(4)
    for jj in chain:
        ch = local[jj]
        M = M @ trs(ch[0:3], ch[3:7])
    R = M[:3, :3] / np.linalg.norm(M[:3, :3], axis=0)[None, :]
    fw, up = R @ fwd0, R @ up0
    off_f = math.degrees(math.acos(max(-1, min(1, fw[0]))))
    off_u = math.degrees(math.acos(max(-1, min(1, up[2]))))
    tag = "STRAIGHT" if max(off_f, off_u) <= a.tol else ""
    if tag:
        straight.append(f)
    print("frame %3d  muzzle (%6.3f %6.3f %6.3f) %5.1f deg off   top (%6.3f %6.3f %6.3f) %5.1f deg off  %s"
          % (f, fw[0], fw[1], fw[2], off_f, up[0], up[1], up[2], off_u, tag))
print("STRAIGHT FRAMES (within %.1f deg): %s" % (a.tol, straight if straight else "none"))

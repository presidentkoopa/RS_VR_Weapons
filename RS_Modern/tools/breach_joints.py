"""Where named joints of a BREACH rig are at one animation frame, in file space (the card's axes).
Used for seat landmarks a gun has no bone for: Breach's own right index finger rests on the trigger.
    python breach_joints.py <iqm> --frame N --joints a,b,c
"""
import argparse, math, struct
import numpy as np

ap = argparse.ArgumentParser()
ap.add_argument("iqm")
ap.add_argument("--frame", type=int, required=True)
ap.add_argument("--joints", required=True)
a = ap.parse_args()

d = open(a.iqm, "rb").read()
h = struct.unpack_from("<27I", d, 16)
num_text, ofs_text = h[3], h[4]
num_joints, ofs_joints, num_poses, ofs_poses = h[13], h[14], h[15], h[16]
num_frames, num_fch, ofs_frames = h[19], h[20], h[21]
text = d[ofs_text:ofs_text + num_text]
cstr = lambda o: text[o:text.find(b"\0", o)].decode("latin-1")


def trs(t, q, s):
    x, y, z, w = q
    n = math.sqrt(x * x + y * y + z * z + w * w) or 1.0
    x, y, z, w = x / n, y / n, z / n, w / n
    m = np.eye(4)
    m[:3, :3] = np.array([[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
                          [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
                          [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)]]) * np.array(s)[None, :]
    m[:3, 3] = t
    return m


names, parents = [], []
for i in range(num_joints):
    nm, parent = struct.unpack_from("<Ii", d, ofs_joints + 48 * i)
    names.append(cstr(nm))
    parents.append(parent)
poses = [(struct.unpack_from("<iI", d, ofs_poses + 88 * i)[1], struct.unpack_from("<10f", d, ofs_poses + 8 + 88 * i),
          struct.unpack_from("<10f", d, ofs_poses + 48 + 88 * i)) for i in range(num_poses)]
data = struct.unpack_from(f"<{num_frames * num_fch}H", d, ofs_frames)
k, local = 0, None
for f in range(a.frame + 1):
    row = []
    for (mask, off, sc) in poses:
        ch = []
        for c in range(10):
            v = off[c]
            if mask & (1 << c):
                v += data[k] * sc[c]
                k += 1
            ch.append(v)
        row.append(ch)
    local = row
W = [None] * num_joints
for i in range(num_joints):
    ch = local[i]
    m = trs(ch[0:3], ch[3:7], ch[7:10])
    W[i] = m if parents[i] < 0 else W[parents[i]] @ m
for n in a.joints.split(","):
    if n not in names:
        print("%-30s not in this rig" % n)
        continue
    p = W[names.index(n)][:3, 3]
    print("%-30s %.3f, %.3f, %.3f" % (n, p[0], p[1], p[2]))

"""Measure a BREACH rigged gun in the pose its prop draws (animation frame 0), for its card and its seat.

Card points are written in the model's FILE axes (x toward the muzzle, y across, z up, as every card), and the
renderer draws an IQM skinned: posed = sum_k w_k * (World_frame[j_k] * inverse(World_bind[j_k])) * v. This poses every
mesh but the rig's own arms that way and reports:
  * the root bone's frame-0 place and axes in file space, and the rotation (if any) that stands the gun with its muzzle
    along file +x and its top along +z -- NONE when the rig already stands that way;
  * the posed gun's box in the root's space (length, height, width) and in file space;
  * every bone that carries gun geometry: vertex count, centroid, box (file space), its frame-0 origin;
  * the muzzle (the front-most verts, centred), in file space;
  * the rig's own arms meshes (by material) and any bone whose geometry sits far from the gun at frame 0 (a parked
    duplicate magazine, a carried shell) -- those want `hidejoint`.
    python breach_measure.py <iqm> --root <bone> --forward <axis> --up <axis> [--frame N] [--json out.json]
axis: +x -x +y -y +z -z, in the root bone's own space.
"""
import argparse, json, math, struct
import numpy as np

AX = {"+x": (1, 0, 0), "-x": (-1, 0, 0), "+y": (0, 1, 0), "-y": (0, -1, 0), "+z": (0, 0, 1), "-z": (0, 0, -1)}
ARMS = ("v_hands", "soldier_hand", "soldier_arm")

ap = argparse.ArgumentParser()
ap.add_argument("iqm")
ap.add_argument("--root", required=True)
ap.add_argument("--forward", required=True, choices=AX)
ap.add_argument("--up", required=True, choices=AX)
ap.add_argument("--frame", type=int, default=0)
ap.add_argument("--json")
ap.add_argument("--exclude", default="", help="bones whose geometry is not the gun (a parked duplicate magazine, a carried shell)")
a = ap.parse_args()
EXCLUDE = {n for n in a.exclude.split(",") if n}

d = open(a.iqm, "rb").read()
h = struct.unpack_from("<27I", d, 16)
(version, filesize, flags, num_text, ofs_text, num_meshes, ofs_meshes, num_va, num_verts, ofs_va, num_tris, ofs_tris,
 ofs_adj, num_joints, ofs_joints, num_poses, ofs_poses, num_anims, ofs_anims, num_frames, num_fch, ofs_frames,
 ofs_bounds, num_comment, ofs_comment, num_ext, ofs_ext) = h
text = d[ofs_text:ofs_text + num_text]


def cstr(o):
    return text[o:text.find(b"\0", o)].decode("latin-1")


def trs(t, q, s):
    x, y, z, w = q
    n = math.sqrt(x * x + y * y + z * z + w * w) or 1.0
    x, y, z, w = x / n, y / n, z / n, w / n
    r = np.array([[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
                  [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
                  [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)]])
    m = np.eye(4)
    m[:3, :3] = r * np.array(s)[None, :]
    m[:3, 3] = t
    return m


joints = []
for i in range(num_joints):
    nm, parent = struct.unpack_from("<Ii", d, ofs_joints + 48 * i)
    joints.append((cstr(nm), parent, struct.unpack_from("<3f", d, ofs_joints + 8 + 48 * i),
                   struct.unpack_from("<4f", d, ofs_joints + 20 + 48 * i), struct.unpack_from("<3f", d, ofs_joints + 36 + 48 * i)))
names = [j[0] for j in joints]
J = {n: i for i, n in enumerate(names)}
poses = []
for i in range(num_poses):
    parent, mask = struct.unpack_from("<iI", d, ofs_poses + 88 * i)
    poses.append((mask, struct.unpack_from("<10f", d, ofs_poses + 8 + 88 * i), struct.unpack_from("<10f", d, ofs_poses + 48 + 88 * i)))
data = struct.unpack_from(f"<{num_frames * num_fch}H", d, ofs_frames) if num_frames else ()
k = 0
local = None
for f in range(num_frames):
    row = []
    for (mask, off, sc) in poses:
        ch = []
        for c in range(10):
            v = off[c]
            if mask & (1 << c):
                v += data[k] * sc[c]
                k += 1
            ch.append(v)
        row.append((ch[0:3], ch[3:7], ch[7:10]))
    if f == a.frame:
        local = row
        break


def worlds(get):
    w = [None] * num_joints
    for i, (nm, parent, t, q, s) in enumerate(joints):
        m = trs(*get(i))
        w[i] = m if parent < 0 else w[parent] @ m
    return w


bind = worlds(lambda i: joints[i][2:])
W = worlds(lambda i: local[i]) if local else bind
pal = np.array([W[j] @ np.linalg.inv(bind[j]) for j in range(num_joints)])

posa = bidx = bwt = None
for i in range(num_va):
    vtype, vflags, vfmt, vsize, vofs = struct.unpack_from("<5I", d, ofs_va + 20 * i)
    if vtype == 0 and vfmt == 7:
        posa = np.array(struct.unpack_from(f"<{num_verts * vsize}f", d, vofs)).reshape(-1, vsize)[:, :3]
    if vtype == 4 and vfmt == 1:
        bidx = np.frombuffer(d[vofs:vofs + num_verts * vsize], dtype=np.uint8).reshape(-1, vsize)
    if vtype == 5 and vfmt == 1:
        bwt = np.frombuffer(d[vofs:vofs + num_verts * vsize], dtype=np.uint8).reshape(-1, vsize).astype(float) / 255.0
meshes = []
for i in range(num_meshes):
    nm, mat, fv, nv, ft, nt = struct.unpack_from("<6I", d, ofs_meshes + 24 * i)
    meshes.append((cstr(nm), cstr(mat), fv, nv))

gv = np.concatenate([np.arange(fv, fv + nv) for (nm, mat, fv, nv) in meshes if not mat.lower().startswith(ARMS)])
P4 = np.c_[posa[gv], np.ones(len(gv))]
posed = np.zeros((len(gv), 4))
for kk in range(bidx.shape[1]):
    posed += bwt[gv, kk][:, None] * np.einsum("nij,nj->ni", pal[bidx[gv, kk]], P4)
posed = posed[:, :3]
dom = bidx[gv, np.argmax(bwt[gv], axis=1)]
if EXCLUDE:
    keep = np.array([names[int(j)] not in EXCLUDE for j in dom], dtype=bool)
    print("excluded %d verts riding %s" % (int((~keep).sum()), ", ".join(sorted(EXCLUDE))))
    posed, dom = posed[keep], dom[keep]

G = W[J[a.root]]
scale = np.linalg.norm(G[:3, :3], axis=0)
R = G[:3, :3] / scale[None, :]
fwd_f = R @ np.array(AX[a.forward], dtype=float)
up_f = R @ np.array(AX[a.up], dtype=float)
f3 = lambda v: [round(float(x), 3) for x in v]
out = dict(iqm=a.iqm, root=a.root, frame=a.frame, root_at=f3(G[:3, 3]), root_scale=f3(scale),
           forward_file=f3(fwd_f), up_file=f3(up_f))
aligned = np.allclose(fwd_f, [1, 0, 0], atol=1e-3) and np.allclose(up_f, [0, 0, 1], atol=1e-3)
out["stands_straight"] = bool(aligned)
print("%s frame %d root %s at %s; muzzle points file %s, top points file %s -> %s"
      % (a.iqm.split("/")[-1], a.frame, a.root, out["root_at"], out["forward_file"], out["up_file"],
         "STANDS STRAIGHT (no rotation)" if aligned else "NEEDS A ROTATION"))

# In a 'card frame': x along the muzzle, z up, y = z cross x (left).
left_f = np.cross(up_f, fwd_f)
C = np.vstack([fwd_f, left_f, up_f])                      # file -> card-frame
cs = posed @ C.T
lo, hi = cs.min(axis=0), cs.max(axis=0)
out["length"], out["width"], out["height"] = round(float(hi[0] - lo[0]), 3), round(float(hi[1] - lo[1]), 3), round(float(hi[2] - lo[2]), 3)
print("gun (no arms): length %.2f  width %.2f  height %.2f   file box %s .. %s" % (out["length"], out["width"], out["height"], f3(posed.min(0)), f3(posed.max(0))))
front = cs[:, 0] >= hi[0] - 0.3
mz_card = np.array([hi[0], cs[front, 1].mean(), cs[front, 2].mean()])
out["muzzle_file"] = f3(C.T @ mz_card)
print("muzzle (front face centre) file %s" % out["muzzle_file"])

gunc = posed.mean(axis=0)
out["bones"] = {}
for j in sorted(set(int(x) for x in dom)):
    sel = dom == j
    c = posed[sel].mean(axis=0)
    far = float(np.linalg.norm(c - gunc))
    out["bones"][names[j]] = dict(verts=int(sel.sum()), centroid_file=f3(c), lo_file=f3(posed[sel].min(0)), hi_file=f3(posed[sel].max(0)),
                                  origin_file=f3(W[j][:3, 3]), from_gun_centre=round(far, 2))
    print("  %-34s %5d verts centroid %-26s origin %-26s %s" % (names[j], sel.sum(), f3(c), f3(W[j][:3, 3]),
          ("FAR from the gun (%.0f) -- hidejoint?" % far) if far > 1.5 * max(out["length"], 1) / 2 else ""))
out["arms_meshes"] = [mat for (nm, mat, fv, nv) in meshes if mat.lower().startswith(ARMS)]
out["mesh_names"] = [nm for (nm, mat, fv, nv) in meshes]
print("meshes:", out["mesh_names"], " arms:", out["arms_meshes"])
if a.json:
    json.dump(out, open(a.json, "w"), indent=1)

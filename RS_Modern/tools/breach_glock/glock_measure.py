"""Breach Glock (glockrerig.iqm) in the pose the prop draws -- animation frame 0 -- measured for its card.

Card points are in the model's FILE axes (WM_Space: x, y, z as the file stores them), and the renderer draws an IQM
with every vertex skinned: posed = sum_k w_k * (World_frame0[j_k] * inverse(World_bind[j_k])) * v. So this poses the
gun mesh exactly that way and reports, in file space:
  the gun root bone's frame-0 place and axes (j_gun: +x runs to the REAR, +z up, -y to the right -- read off the rig:
  hammer and sling behind the trigger, the extractor on the right),
  each moving part's verts (by strongest weight), the trigger landmark for the seat, the muzzle from the mesh front,
  the slide / trigger travel axes, and the magazine's insertion axis from its reload frames 51-58.
    python glock_measure.py <glockrerig.iqm>
"""
import json, math, struct, sys
import numpy as np

P = sys.argv[1]
d = open(P, "rb").read()
h = struct.unpack_from("<27I", d, 16)
(version, filesize, flags, num_text, ofs_text, num_meshes, ofs_meshes, num_va, num_verts, ofs_va, num_tris, ofs_tris,
 ofs_adj, num_joints, ofs_joints, num_poses, ofs_poses, num_anims, ofs_anims, num_frames, num_fch, ofs_frames,
 ofs_bounds, num_comment, ofs_comment, num_ext, ofs_ext) = h
text = d[ofs_text:ofs_text + num_text]
cstr = lambda o: text[o:text.find(b"\0", o)].decode("latin-1")


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
    t = struct.unpack_from("<3f", d, ofs_joints + 8 + 48 * i)
    q = struct.unpack_from("<4f", d, ofs_joints + 20 + 48 * i)
    s = struct.unpack_from("<3f", d, ofs_joints + 36 + 48 * i)
    joints.append((cstr(nm), parent, t, q, s))
names = [j[0] for j in joints]
J = {n: i for i, n in enumerate(names)}

poses = []
for i in range(num_poses):
    parent, mask = struct.unpack_from("<iI", d, ofs_poses + 88 * i)
    off = struct.unpack_from("<10f", d, ofs_poses + 8 + 88 * i)
    sc = struct.unpack_from("<10f", d, ofs_poses + 48 + 88 * i)
    poses.append((mask, off, sc))
data = struct.unpack_from(f"<{num_frames * num_fch}H", d, ofs_frames)
local, k = [], 0
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
    local.append(row)


def worlds(get):
    w = [None] * num_joints
    for i, (nm, parent, t, q, s) in enumerate(joints):
        m = trs(*get(i))
        w[i] = m if parent < 0 else w[parent] @ m
    return w


bind = worlds(lambda i: (joints[i][2], joints[i][3], joints[i][4]))
frames = [worlds(lambda i, f=f: local[f][i]) for f in range(num_frames)]
W0 = frames[0]

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

pal = np.array([W0[j] @ np.linalg.inv(bind[j]) for j in range(num_joints)])
gun_mesh = next(m for m in meshes if m[1] == "skin.png")
gv = np.arange(gun_mesh[2], gun_mesh[2] + gun_mesh[3])
P4 = np.c_[posa[gv], np.ones(len(gv))]
posed = np.zeros((len(gv), 4))
for kk in range(bidx.shape[1]):
    w = bwt[gv, kk][:, None]
    posed += w * np.einsum("nij,nj->ni", pal[bidx[gv, kk]], P4)
posed = posed[:, :3]
dom = bidx[gv, np.argmax(bwt[gv], axis=1)]

G = W0[J["j_gun"]]
scale = np.linalg.norm(G[:3, :3], axis=0)
R = G[:3, :3] / scale[None, :]
ax_rear, ax_left, ax_up = R[:, 0], R[:, 1], R[:, 2]      # file-space directions of gun +x, +y, +z
Ginv = np.linalg.inv(G)
gs = (np.c_[posed, np.ones(len(posed))] @ Ginv.T)[:, :3]  # the posed gun in j_gun's own frame-0 space

out = {}
f3 = lambda v: [round(float(x), 3) for x in v]
print("frame 0 j_gun: at %s  scale %s" % (f3(G[:3, 3]), f3(scale)))
print("  gun +x (rear) in file space %s, +y (left) %s, +z (up) %s" % (f3(ax_rear), f3(ax_left), f3(ax_up)))
out["j_gun"] = dict(at=f3(G[:3, 3]), rear=f3(ax_rear), left=f3(ax_left), up=f3(ax_up), scale=f3(scale))
lo, hi = gs.min(axis=0), gs.max(axis=0)
print("gun in its own space: x %.2f..%.2f  y %.2f..%.2f  z %.2f..%.2f  (length %.2f, height %.2f, width %.2f)"
      % (lo[0], hi[0], lo[1], hi[1], lo[2], hi[2], hi[0] - lo[0], hi[2] - lo[2], hi[1] - lo[1]))
out["gun_box_gunspace"] = dict(lo=f3(lo), hi=f3(hi))

to_file = lambda p: (G @ np.append(p, 1.0))[:3]
groups = {}
for jn in ("j_slide", "j_trigger", "j_mag1", "tag_weapon", "tag_sling", "j_gun"):
    sel = dom == J[jn]
    if not sel.any():
        continue
    c = gs[sel].mean(axis=0)
    glo, ghi = gs[sel].min(axis=0), gs[sel].max(axis=0)
    groups[jn] = dict(n=int(sel.sum()), centroid_gun=f3(c), lo_gun=f3(glo), hi_gun=f3(ghi), centroid_file=f3(to_file(c)))
    print("  %-11s %5d verts  centroid gun %s file %s  box gun %s..%s" % (jn, sel.sum(), f3(c), f3(to_file(c)), f3(glo), f3(ghi)))
out["groups"] = groups

# MUZZLE: the mesh's front (least gun x), centred on the verts within 0.3 of it.
front = gs[:, 0] <= lo[0] + 0.3
mz = np.array([lo[0], gs[front, 1].mean(), gs[front, 2].mean()])
print("muzzle (front face centre) gun %s file %s" % (f3(mz), f3(to_file(mz))))
out["muzzle"] = dict(gun=f3(mz), file=f3(to_file(mz)))

# Joint origins at frame 0, gun space and file space.
for jn in ("j_slide", "j_trigger", "j_mag1", "j_extractor", "j_slide_release", "j_hammer", "j_magrel", "j_mag2"):
    p = (Ginv @ W0[J[jn]])[:3, 3]
    print("  joint %-16s gun %s file %s" % (jn, f3(p), f3(W0[J[jn]][:3, 3])))
    out.setdefault("joints", {})[jn] = dict(gun=f3(p), file=f3(W0[J[jn]][:3, 3]))

# MAGAZINE INSERTION: j_mag1 against the gun root over frames 51 ('clip starts back in') .. 58 ('seats home').
mp = [(np.linalg.inv(frames[f][J["j_gun"]]) @ frames[f][J["j_mag1"]])[:3, 3] for f in range(51, 59)]
for f, p in zip(range(51, 59), mp):
    print("  mag1 frame %d gun %s" % (f, f3(p)))
ins = mp[-1] - mp[0]
ins_u = ins / (np.linalg.norm(ins) or 1)
out_gun = -ins_u
print("magazine comes OUT along gun %s (file %s); last 7 frames moved %.2f" % (f3(out_gun), f3(R @ out_gun), np.linalg.norm(ins)))
out["mag_out"] = dict(gun=f3(out_gun), file=f3(R @ out_gun))
if "j_mag1" in groups:
    sel = dom == J["j_mag1"]
    proj = gs[sel] @ out_gun
    print("  magazine extent along that axis %.2f (%.2f .. %.2f)" % (proj.max() - proj.min(), proj.min(), proj.max()))
    out["mag_extent_along_out"] = round(float(proj.max() - proj.min()), 3)

# The hand mesh at frame 0, for reference: where Breach's own right hand holds it (gun space box).
hand_mesh = next(m for m in meshes if m[1] == "v_hands.bmp")
print("meshes:", [(m[0], m[1], m[3]) for m in meshes])
json.dump(out, open(P.replace("\\", "/").split("/")[-1] + ".measure.json", "w"), indent=1)

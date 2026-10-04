"""Cut a loose part (a magazine) out of a BREACH rig, the way tools/md3_write.py extract() cuts one from an MD3.

The reload system's convention (WM_Rig.DropMagazine / TurnLikeDrawn): loose = R (gun - magcenter), R the shortest turn
carrying the feed part's dof axis onto -z. So: every triangle -- of every mesh but the rig's own arms -- whose three
verts all ride one of --joints (strongest weight), posed at --frame exactly as the prop draws them, in the file's
axes; re-origined on their centroid (the card's magcenter), turned by R, written as a one-frame MD3 through md3_write
and read back by md3.py.

ONE MD3 SURFACE PER MATERIAL, each shader the texture's full path (--texdir + the material), so a magazine drawn from
two textures (its body and the rounds showing in it) keeps both: the card then states no magskin, and the engine loads
each surface's own. --axis pca takes the part's own long axis (a magazine cannot turn in its well).
    python breach_extract.py <iqm> <out.md3> --frame N --joints j_mag1[,..] --axis x,y,z|pca --texdir models/breach/<gun>
"""
import argparse, math, struct, sys
import numpy as np

# md3.py / md3_write.py left E:/DOOMWork/tools in the tools clearout; the live pair, and the one
# every other model tool in the house reads and writes with, is CardPipeline's.
sys.path.insert(0, "E:/DOOMWork/CardPipeline/tools")
import md3, md3_write

ARMS = ("v_hands", "soldier_hand", "soldier_arm")
ap = argparse.ArgumentParser()
ap.add_argument("iqm")
ap.add_argument("out")
ap.add_argument("--frame", type=int, required=True)
ap.add_argument("--joints", required=True)
ap.add_argument("--axis", required=True)
ap.add_argument("--texdir", required=True)
ap.add_argument("--ext", default="", help="replace each material's extension with this one (the texture as packed)")
a = ap.parse_args()

d = open(a.iqm, "rb").read()
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
    m = np.eye(4)
    m[:3, :3] = np.array([[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
                          [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
                          [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)]]) * np.array(s)[None, :]
    m[:3, 3] = t
    return m


joints = []
for i in range(num_joints):
    nm, parent = struct.unpack_from("<Ii", d, ofs_joints + 48 * i)
    joints.append((cstr(nm), parent, struct.unpack_from("<3f", d, ofs_joints + 8 + 48 * i),
                   struct.unpack_from("<4f", d, ofs_joints + 20 + 48 * i), struct.unpack_from("<3f", d, ofs_joints + 36 + 48 * i)))
J = {j[0]: i for i, j in enumerate(joints)}
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
        row.append((ch[0:3], ch[3:7], ch[7:10]))
    local = row


def worlds(get):
    w = [None] * num_joints
    for i, (nm, parent, t, q, s) in enumerate(joints):
        m = trs(*get(i))
        w[i] = m if parent < 0 else w[parent] @ m
    return w


bind = worlds(lambda i: joints[i][2:])
W = worlds(lambda i: local[i])
pal = np.array([W[j] @ np.linalg.inv(bind[j]) for j in range(num_joints)])

posa = bidx = bwt = texc = norm = None
for i in range(num_va):
    vtype, vflags, vfmt, vsize, vofs = struct.unpack_from("<5I", d, ofs_va + 20 * i)
    arr = lambda: np.array(struct.unpack_from(f"<{num_verts * vsize}f", d, vofs)).reshape(-1, vsize)
    if vtype == 0 and vfmt == 7:
        posa = arr()[:, :3]
    if vtype == 1 and vfmt == 7:
        texc = arr()[:, :2]
    if vtype == 2 and vfmt == 7:
        norm = arr()[:, :3]
    if vtype == 4 and vfmt == 1:
        bidx = np.frombuffer(d[vofs:vofs + num_verts * vsize], dtype=np.uint8).reshape(-1, vsize)
    if vtype == 5 and vfmt == 1:
        bwt = np.frombuffer(d[vofs:vofs + num_verts * vsize], dtype=np.uint8).reshape(-1, vsize).astype(float) / 255.0
want = {J[n] for n in a.joints.split(",")}
dom = bidx[np.arange(num_verts), np.argmax(bwt, axis=1)]
groups = []                                   # (material, triangles)
for i in range(num_meshes):
    nm, mat, fv, nv, ft, nt = struct.unpack_from("<6I", d, ofs_meshes + 24 * i)
    if cstr(mat).lower().startswith(ARMS):
        continue
    tris = np.array(struct.unpack_from(f"<{nt * 3}I", d, ofs_tris + 12 * ft)).reshape(-1, 3)
    got = [t for t in tris if all(int(dom[v]) in want for v in t)]
    if got:
        groups.append((cstr(mat), got))
if not groups:
    raise SystemExit("no triangles ride %s" % a.joints)


def pose(v):
    acc, nacc = np.zeros(4), np.zeros(3)
    for kk in range(bidx.shape[1]):
        w = bwt[v, kk]
        if w > 0:
            Mx = pal[bidx[v, kk]]
            acc += w * (Mx @ np.append(posa[v], 1.0))
            nacc += w * (Mx[:3, :3] @ norm[v])
    return acc[:3], nacc / (np.linalg.norm(nacc) or 1.0)


allused = sorted({int(v) for _, tris in groups for t in tris for v in t})
posed = {v: pose(v) for v in allused}
P = np.array([posed[v][0] for v in allused])
c = P.mean(axis=0)
if a.axis == "pca":
    w_, v_ = np.linalg.eigh((P - c).T @ (P - c) / len(P))
    AXIS = v_[:, -1].copy()
    AXIS[1] = 0.0
    AXIS /= np.linalg.norm(AXIS)
    if AXIS[2] > 0:
        AXIS = -AXIS
    proj = P @ AXIS
    print("axis (pca, out of the well) = %.3f, %.3f, %.3f; %.1f deg off vertical; length along it %.2f"
          % (AXIS[0], AXIS[1], AXIS[2], math.degrees(math.atan2(abs(AXIS[0]), -AXIS[2])), proj.max() - proj.min()))
else:
    AXIS = np.array([float(x) for x in a.axis.split(",")])
    AXIS /= np.linalg.norm(AXIS)
R = np.array(md3_write._rotation_onto(list(AXIS), [0.0, 0.0, -1.0]), dtype=float)

surfs = []
for si, (mat, tris) in enumerate(groups):
    used = sorted({int(v) for t in tris for v in t})
    remap = {v: i for i, v in enumerate(used)}
    tex = mat
    if a.ext:
        tex = tex.rsplit(".", 1)[0] + a.ext
    shader = a.texdir.rstrip("/") + "/" + tex
    surfs.append(md3.MD3Surface(index=si, name="part%d" % si, num_frames=1, shaders=[md3.MD3Shader(name=shader, shader_index=0)],
                                triangles=[tuple(remap[int(v)] for v in t) for t in tris],
                                st=[(float(texc[v][0]), float(texc[v][1])) for v in used],
                                verts=[[tuple(float(x) for x in R @ (posed[v][0] - c)) for v in used]],
                                normals=[[tuple(float(x) for x in R @ posed[v][1]) for v in used]]))
frame0 = md3.MD3Frame(mins=(0, 0, 0), maxs=(0, 0, 0), origin=(0, 0, 0), radius=0.0, name="rest")
md3_write.write(md3.MD3Model(source=a.out, name="loose", num_frames=1, frames=[frame0], tags=[], surfaces=surfs), a.out)
back = md3.MD3Model.load(a.out)
allv = np.array([v for s in back.surfaces for v in s.verts[0]], dtype=float)
size = allv.max(axis=0) - allv.min(axis=0)
print("wrote %s: %s" % (a.out, "; ".join("%s -> %s (%d tris)" % (m, s.shaders[0].name, len(t)) for (m, t), s in zip(groups, back.surfaces))))
print("magcenter = %.3f, %.3f, %.3f" % tuple(c))
print("size %.2f x %.2f x %.2f (after the turn)" % tuple(size))

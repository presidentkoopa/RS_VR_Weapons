"""The Breach Glock's loose magazine, cut out of the rig the way tools/md3_write.py extract() cuts one out of an MD3.

The reload system's convention (WM_Rig.DropMagazine / TurnLikeDrawn): loose = R (gun - magcenter), R the shortest turn
carrying the feed part's dof axis onto -z. So: every triangle of the gun mesh whose three verts all ride j_mag1
(strongest weight), posed at animation frame 0 exactly as the prop draws them (glock_measure.py), in the file's axes;
re-origined on their centroid (the card's magcenter), turned by R, and written as a one-frame MD3 through md3_write --
the writer the pistols' loose magazines came from -- then read back by md3.py.
    python extract_mag.py <glockrerig.iqm> <out.md3> [--flip]
--flip reverses each triangle's winding, for a loader that winds the other way.
"""
import os, runpy, struct, sys
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
# md3.py / md3_write.py left E:/DOOMWork/tools in the tools clearout; the live pair, and the one
# every other model tool in the house reads and writes with, is CardPipeline's.
sys.path.insert(0, "E:/DOOMWork/CardPipeline/tools")
import md3, md3_write

IQM, OUT = sys.argv[1], sys.argv[2]
FLIP = "--flip" in sys.argv
AXIS = (-0.339, 0.0, -0.941)          # WMCARD.breach, part magazine, dof axis

sys.argv = ["glock_measure.py", IQM]
g = runpy.run_path(os.path.join(HERE, "glock_measure.py"))
d, posa, pal, bidx, bwt, J = g["d"], g["posa"], g["pal"], g["bidx"], g["bwt"], g["J"]
num_va, num_verts, ofs_va = g["num_va"], g["num_verts"], g["ofs_va"]
num_meshes, ofs_meshes, ofs_tris = g["num_meshes"], g["ofs_meshes"], g["ofs_tris"]

texc = norm = None
for i in range(num_va):
    vtype, vflags, vfmt, vsize, vofs = struct.unpack_from("<5I", d, ofs_va + 20 * i)
    if vtype == 1 and vfmt == 7:
        texc = np.array(struct.unpack_from(f"<{num_verts * vsize}f", d, vofs)).reshape(-1, vsize)[:, :2]
    if vtype == 2 and vfmt == 7:
        norm = np.array(struct.unpack_from(f"<{num_verts * vsize}f", d, vofs)).reshape(-1, vsize)[:, :3]
if texc is None or norm is None:
    raise SystemExit("no texcoords or normals in %s" % IQM)

gun = None
for i in range(num_meshes):
    nm, mat, fv, nv, ft, nt = struct.unpack_from("<6I", d, ofs_meshes + 24 * i)
    if g["cstr"](mat) == "skin.png":
        gun = (fv, nv, ft, nt)
fv, nv, ft, nt = gun
tris = np.array(struct.unpack_from(f"<{nt * 3}I", d, ofs_tris + 12 * ft)).reshape(-1, 3)
dom = bidx[np.arange(num_verts), np.argmax(bwt, axis=1)]
jm = J["j_mag1"]
sel = [t for t in tris if all(dom[int(v)] == jm for v in t)]
used = sorted({int(v) for t in sel for v in t})
remap = {v: i for i, v in enumerate(used)}

P, N = [], []
for v in used:
    acc, nacc = np.zeros(4), np.zeros(3)
    for k in range(bidx.shape[1]):
        w = bwt[v, k]
        if w > 0:
            Mx = pal[bidx[v, k]]
            acc += w * (Mx @ np.append(posa[v], 1.0))
            nacc += w * (Mx[:3, :3] @ norm[v])
    P.append(acc[:3])
    N.append(nacc / (np.linalg.norm(nacc) or 1.0))
P, N = np.array(P), np.array(N)
c = P.mean(axis=0)
ax = np.array(AXIS) / np.linalg.norm(AXIS)
R = np.array(md3_write._rotation_onto(list(ax), [0.0, 0.0, -1.0]), dtype=float)
L, LN = (P - c) @ R.T, N @ R.T

triangles = [tuple(remap[int(v)] for v in ((t[2], t[1], t[0]) if FLIP else t)) for t in sel]
surf = md3.MD3Surface(index=0, name="mag", num_frames=1, shaders=[md3.MD3Shader(name="skin.png", shader_index=0)],
                      triangles=triangles, st=[(float(u), float(t)) for u, t in texc[used]],
                      verts=[[tuple(float(x) for x in p) for p in L]], normals=[[tuple(float(x) for x in n) for n in LN]])
frame0 = md3.MD3Frame(mins=(0, 0, 0), maxs=(0, 0, 0), origin=(0, 0, 0), radius=0.0, name="rest")
md3_write.write(md3.MD3Model(source=OUT, name="breachglock_mag", num_frames=1, frames=[frame0], tags=[], surfaces=[surf]), OUT)

back = md3.MD3Model.load(OUT)
allv = np.array(back.surfaces[0].verts[0], dtype=float)
lo, hi = allv.min(axis=0), allv.max(axis=0)
size = hi - lo
print("wrote %s: %d triangles, %d verts, winding %s" % (OUT, len(triangles), len(used), "flipped" if FLIP else "as the IQM"))
print("magcenter (gun file space) = %.3f, %.3f, %.3f" % tuple(c))
print("size %.2f x %.2f x %.2f (x y z, after the turn); half the thinnest side %.3f" % (size[0], size[1], size[2], size.min() / 2))
print("read back: %d verts, max |xyz| %.2f" % (len(allv), np.abs(allv).max()))

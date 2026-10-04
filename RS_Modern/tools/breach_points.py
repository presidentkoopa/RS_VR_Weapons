"""A BREACH gun's card points, off the pose its prop draws (one animation frame, skinned as the renderer skins it).

Every point is in the file's axes (the card's). The gun must stand with its muzzle along file +x and its top along +z
at --frame (breach_frames.py finds such a frame); Breach's rigs put the gun's RIGHT side on file +y (the right hand's
fingers are on that side), so an ejection port is on +y.

  muzzle     the front-most verts (within 0.3), centred -- --muzzle-upper keeps only the upper half of them (a barrel
             over a magazine tube)
  grab       for --grab JOINT: its rear-most quarter, top 0.8 -- a slide's serrations, a charging handle's T
  mag        for --mag JOINT: its long axis (in the middle plane, out of the well), length, centroid (magcenter), and
             the floorplate (the verts within 0.5 of the bottom along that axis)
  trigger    --trigger JOINT's centroid, or, with no trigger bone, Breach's right index fingertip (j_index_ri_3) plus
             the fingertip-to-trigger offset measured on the Glock, whose trigger is a bone
  support    the mean of --support joints (Breach's left hand), put on the bore's centre line; or --strap Z: the grip's
             front strap at that height (a pistol)
  ejectport  the gun's right-side surface at station --eject-x, at the bore's height (or --eject-z)
    python breach_points.py <iqm> --frame N --root BONE --forward AX --up AX [--exclude a,b] [--grab J] [--mag J]
           [--trigger J] [--support a,b,c | --strap Z] [--eject-x X] [--eject-z Z] [--muzzle-upper] --json out.json
"""
import argparse, json, math, struct
import numpy as np

AX = {"+x": (1, 0, 0), "-x": (-1, 0, 0), "+y": (0, 1, 0), "-y": (0, -1, 0), "+z": (0, 0, 1), "-z": (0, 0, -1)}
ARMS = ("v_hands", "soldier_hand", "soldier_arm")
FINGER_TO_TRIGGER = np.array([-0.593, -0.919, -0.099])   # Glock frame 0: trigger centroid - j_index_ri_3

ap = argparse.ArgumentParser()
ap.add_argument("iqm")
ap.add_argument("--frame", type=int, required=True)
ap.add_argument("--root", required=True)
ap.add_argument("--forward", required=True, choices=AX)
ap.add_argument("--up", required=True, choices=AX)
ap.add_argument("--exclude", default="")
ap.add_argument("--grab")
ap.add_argument("--mag")
ap.add_argument("--trigger")
ap.add_argument("--support")
ap.add_argument("--strap", type=float)
ap.add_argument("--eject-x", type=float)
ap.add_argument("--eject-z", type=float)
ap.add_argument("--muzzle-upper", action="store_true")
ap.add_argument("--json", required=True)
a = ap.parse_args()
EXCLUDE = {n for n in a.exclude.split(",") if n}

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
names = [j[0] for j in joints]
J = {n: i for i, n in enumerate(names)}
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
posa = bidx = bwt = None
for i in range(num_va):
    vtype, vflags, vfmt, vsize, vofs = struct.unpack_from("<5I", d, ofs_va + 20 * i)
    if vtype == 0 and vfmt == 7:
        posa = np.array(struct.unpack_from(f"<{num_verts * vsize}f", d, vofs)).reshape(-1, vsize)[:, :3]
    if vtype == 4 and vfmt == 1:
        bidx = np.frombuffer(d[vofs:vofs + num_verts * vsize], dtype=np.uint8).reshape(-1, vsize)
    if vtype == 5 and vfmt == 1:
        bwt = np.frombuffer(d[vofs:vofs + num_verts * vsize], dtype=np.uint8).reshape(-1, vsize).astype(float) / 255.0
gv = []
for i in range(num_meshes):
    nm, mat, fv, nv, ft, nt = struct.unpack_from("<6I", d, ofs_meshes + 24 * i)
    if not cstr(mat).lower().startswith(ARMS):
        gv.append(np.arange(fv, fv + nv))
gv = np.concatenate(gv)
P4 = np.c_[posa[gv], np.ones(len(gv))]
posed = np.zeros((len(gv), 4))
for kk in range(bidx.shape[1]):
    posed += bwt[gv, kk][:, None] * np.einsum("nij,nj->ni", pal[bidx[gv, kk]], P4)
posed = posed[:, :3]
dom = bidx[gv, np.argmax(bwt[gv], axis=1)]
keep = np.array([names[int(j)] not in EXCLUDE for j in dom], dtype=bool)
posed, dom = posed[keep], dom[keep]

G = W[J[a.root]]
R = G[:3, :3] / np.linalg.norm(G[:3, :3], axis=0)[None, :]
fwd, up = R @ np.array(AX[a.forward], float), R @ np.array(AX[a.up], float)
f3 = lambda v: [round(float(x), 3) for x in v]
out = {"frame": a.frame, "forward_file": f3(fwd), "up_file": f3(up)}
if fwd[0] < 0.999 or up[2] < 0.995:
    print("WARNING: the gun does not stand straight at frame %d (muzzle %s, top %s)" % (a.frame, f3(fwd), f3(up)))

xmax = posed[:, 0].max()
front = posed[posed[:, 0] >= xmax - 0.3]
if a.muzzle_upper:
    front = front[front[:, 2] >= np.median(front[:, 2])]
muzzle = np.array([xmax, front[:, 1].mean(), front[:, 2].mean()])
out["muzzle"] = f3(muzzle)
out["length"] = round(float(xmax - posed[:, 0].min()), 3)
print("muzzle %s   length %.2f" % (out["muzzle"], out["length"]))


def of(joint):
    sel = dom == J[joint]
    if not sel.any():
        return None
    return posed[sel]


if a.grab:
    v = of(a.grab)
    lo, hi = v[:, 0].min(), v[:, 0].max()
    rear = v[v[:, 0] <= lo + 0.25 * (hi - lo)]
    top = rear[rear[:, 2] >= rear[:, 2].max() - 0.8]
    out["grab"] = f3(top.mean(axis=0))
    out["grab_joint_centroid"] = f3(v.mean(axis=0))
    print("grab (%s rear top) %s" % (a.grab, out["grab"]))
if a.mag:
    v = of(a.mag)
    c = v.mean(axis=0)
    w_, v_ = np.linalg.eigh((v - c).T @ (v - c) / len(v))
    ax = v_[:, -1].copy()
    ax[1] = 0.0
    ax /= np.linalg.norm(ax)
    if ax[2] > 0:
        ax = -ax
    proj = v @ ax
    floor = v[proj >= proj.max() - 0.5]
    out["mag"] = dict(axis=f3(ax), length=round(float(proj.max() - proj.min()), 3), center=f3(c), floorplate=f3(floor.mean(axis=0)))
    print("mag %s: axis %s length %.2f center %s floorplate %s" % (a.mag, out["mag"]["axis"], out["mag"]["length"], out["mag"]["center"], out["mag"]["floorplate"]))
if a.trigger:
    v = of(a.trigger)
    out["trigger"] = f3(v.mean(axis=0))
    out["trigger_from"] = "bone " + a.trigger
else:
    tip = W[J["j_index_ri_3"]][:3, 3]
    out["trigger"] = f3(tip + FINGER_TO_TRIGGER)
    out["trigger_from"] = "j_index_ri_3 + the Glock's fingertip-to-trigger offset"
print("trigger %s (%s)" % (out["trigger"], out["trigger_from"]))
if a.support:
    p = np.mean([W[J[n]][:3, 3] for n in a.support.split(",")], axis=0)
    p[1] = muzzle[1]
    out["support"] = f3(p)
    out["support_from"] = "Breach's left hand (%s), on the centre line" % a.support
elif a.strap is not None:
    # THE GRIP'S FRONT STRAP: the forward-most grip verts in a band at that height, the magazine's own left out. A
    # shorter grip has none there: the band widens, then moves up, until it holds some -- and says where it looked.
    notmag = (dom != J[a.mag]) if a.mag else np.ones(len(posed), dtype=bool)
    trig_x = np.array(out["trigger"])[0]
    got = None
    for half in (0.5, 1.0, 1.5):
        for z in (a.strap, a.strap + 1.0, a.strap + 2.0, a.strap + 3.0):
            band = posed[(np.abs(posed[:, 2] - z) < half) & notmag & (posed[:, 0] < trig_x)]
            if len(band):
                got = (z, half, band)
                break
        if got:
            break
    if not got:
        raise SystemExit("no grip verts found for a front strap near z %.2f" % a.strap)
    z, half, band = got
    out["support"] = [round(float(band[:, 0].max()), 3), round(float(muzzle[1]), 3), round(z, 3)]
    out["support_from"] = "the grip's front strap at z %.2f (band +-%.1f)" % (z, half)
if "support" in out:
    print("support %s (%s)" % (out["support"], out["support_from"]))
if a.eject_x is not None:
    zz = a.eject_z if a.eject_z is not None else muzzle[2]
    band = posed[(np.abs(posed[:, 0] - a.eject_x) < 1.5) & (np.abs(posed[:, 2] - zz) < 1.5)]
    out["ejectport"] = [round(a.eject_x, 3), round(float(band[:, 1].max()), 3), round(float(zz), 3)]
    print("ejectport %s" % out["ejectport"])
json.dump(out, open(a.json, "w"), indent=1)

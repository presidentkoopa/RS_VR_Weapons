"""Every BREACH card point, carried back onto the BIND POSE (for the body/hands lane, 2026-09-18).

WHY: the cards' points were measured on the pose each prop DRAWS (frame 0 / 25 / 59 / 109), because the seat had to
match what the eye sees. The engine's piece E (FollowActorJoint / FollowActorOfsInModel, build 12) wants a point on the
BIND-POSE mesh instead. Feeding a draw-pose number into a joint ride misplaces the hand by however far that frame sits
from bind -- on a slide or a charging handle that is exactly the travel we care about.

HOW: a card point sits on a rigid part, so it rides one joint. The skinning palette for that joint is
    pal[j] = W[j] @ inv(bind[j])          (breach_points.py, the same maths the renderer uses)
and a drawn point maps home exactly by
    P_bind = inv(pal[j]) @ P_draw
The joint is the part's own joint where the card names one (`joint = j_slide`), and otherwise the joint that dominates
the mesh nearest that point -- which is what a muzzle or an eject port sits on anyway.

The draw-pose numbers are NOT touched: tools/points/*.json and the cards keep them, and they stay correct for the seats
that were derived from them. This writes a second, separate table.

    python breach_bindpoints.py            # -> tools/points_bind/<gun>.json and tools/points_bind/TABLE.md
"""
import json, math, os, re, struct
import numpy as np

M = "E:/DOOMWork/RS_Modern/"
OUT = M + "tools/points_bind/"
ARMS = ("v_hands", "soldier_hand", "soldier_arm")

# A point's kind decides how the body lane may read it (the owner, 2026-09-18, through the body lane): a FACT is a
# property of the mesh, measurable offline and verifiable against the model; an OPINION is where a HAND was put, which
# nobody has confirmed in a headset and which was fitted to the RS hand at its size.
KIND = {"muzzle": "fact", "ejectport": "fact", "magcenter": "fact", "part": "fact", "barrel": "fact",
        "grab": "opinion", "support": "opinion", "handseat": "opinion"}


# ---- the cards ---------------------------------------------------------------------------------------------------
def cards():
    guns = []
    for f in ("WMCARD.breach", "WMCARD.breach_set"):
        cur = part = None
        for raw in open(M + f, encoding="utf-8"):
            s = raw.split("#")[0].rstrip()
            if not s.strip():
                continue
            m = re.match(r'^weapon\s+"([^"]+)"', s)
            if m:
                cur = dict(cls=m.group(1), pts={}, parts=[])
                guns.append(cur)
                part = None
                continue
            if cur is None:
                continue
            m = re.match(r'^part\s+([a-z_]+)\s*$', s)
            if m:
                part = dict(id=m.group(1), joint=None, grab=None)
                cur["parts"].append(part)
                continue
            if re.match(r'^end\s*$', s):
                part = None
                continue
            m = re.match(r'^\s*([a-z_]+)\s*=\s*(.+?)\s*$', s)
            if not m:
                continue
            k, v = m.group(1), m.group(2)
            nums = [float(x) for x in re.findall(r'-?\d+\.?\d*', v)] if re.match(r'^-?[\d.,\s-]+$', v) else None
            if k == "model":
                q = re.findall(r'"([^"]+)"', v)
                cur["dir"], cur["iqm"] = q[0], q[1]
            elif part is not None:
                if k == "joint":
                    part["joint"] = v.strip('"')
                elif k == "grab" and nums and len(nums) == 3:
                    part["grab"] = nums
            elif k in ("muzzle", "ejectport", "magcenter", "barrel") and nums and len(nums) == 3:
                cur["pts"][k] = nums
    return guns


def frames():
    fr, cls = {}, None
    for raw in open(M + "MODELDEF.txt", encoding="utf-8"):
        s = raw.split("//")[0].strip()
        m = re.match(r'^Model\s+(\S+)', s)
        if m and not m.group(1).isdigit():   # `Model 0 "x.iqm"` inside a block is a model slot, not a class
            cls = m.group(1)
        m = re.match(r'^FrameIndex\s+\S+\s+\S+\s+0\s+(\d+)', s)
        if m and cls:
            fr[cls] = int(m.group(1))
    return fr


# ---- one rig -----------------------------------------------------------------------------------------------------
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


def rig(path, frame):
    d = open(path, "rb").read()
    (version, filesize, flags, num_text, ofs_text, num_meshes, ofs_meshes, num_va, num_verts, ofs_va, num_tris,
     ofs_tris, ofs_adj, num_joints, ofs_joints, num_poses, ofs_poses, num_anims, ofs_anims, num_frames, num_fch,
     ofs_frames, ofs_bounds, num_comment, ofs_comment, num_ext, ofs_ext) = struct.unpack_from("<27I", d, 16)
    text = d[ofs_text:ofs_text + num_text]
    cstr = lambda o: text[o:text.find(b"\0", o)].decode("latin-1")
    joints = []
    for i in range(num_joints):
        nm, parent = struct.unpack_from("<Ii", d, ofs_joints + 48 * i)
        joints.append((cstr(nm), parent, struct.unpack_from("<3f", d, ofs_joints + 8 + 48 * i),
                       struct.unpack_from("<4f", d, ofs_joints + 20 + 48 * i),
                       struct.unpack_from("<3f", d, ofs_joints + 36 + 48 * i)))
    names = [j[0] for j in joints]
    poses = [(struct.unpack_from("<iI", d, ofs_poses + 88 * i)[1], struct.unpack_from("<10f", d, ofs_poses + 8 + 88 * i),
              struct.unpack_from("<10f", d, ofs_poses + 48 + 88 * i)) for i in range(num_poses)]
    data = struct.unpack_from(f"<{num_frames * num_fch}H", d, ofs_frames)
    k, local = 0, None
    for f in range(frame + 1):
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
    gv, gtri = [], []
    for i in range(num_meshes):
        nm, mat, fv, nv, ft, nt = struct.unpack_from("<6I", d, ofs_meshes + 24 * i)
        if not cstr(mat).lower().startswith(ARMS):
            gv.append(np.arange(fv, fv + nv))
            gtri.append(np.array(struct.unpack_from(f"<{nt * 3}I", d, ofs_tris + 12 * ft)).reshape(-1, 3))
    gv = np.concatenate(gv)
    tris = np.concatenate(gtri) if gtri else np.zeros((0, 3), int)
    P4 = np.c_[posa[gv], np.ones(len(gv))]
    posed = np.zeros((len(gv), 4))
    for kk in range(bidx.shape[1]):
        posed += bwt[gv, kk][:, None] * np.einsum("nij,nj->ni", pal[bidx[gv, kk]], P4)
    dom = bidx[gv, np.argmax(bwt[gv], axis=1)]
    # THE GUN'S OWN FRAME: the joint that carries most of the gun's geometry. Every point is compared in this frame, so
    # that "the bind pose puts the whole gun somewhere else" (these are character rigs) stays separate from "this part
    # had travelled at that frame", which is the only part-level error a card could actually carry.
    js, counts = np.unique(dom, return_counts=True)
    root = int(js[np.argmax(counts)])
    # THE BIND MESH AND ITS FACES: a bind-pose vertex is the authored position, untouched by any palette, so the
    # surface a hand lands on is measurable straight off the file. Faces carry the normal the body lane needs to turn
    # a hand; the whole gun's centroid only decides which way is out.
    fa, fb, fc = posa[tris[:, 0]], posa[tris[:, 1]], posa[tris[:, 2]]
    fn = np.cross(fb - fa, fc - fa)
    area = np.linalg.norm(fn, axis=1)
    keep = area > 1e-9
    fn, fcen, area = fn[keep] / area[keep, None], ((fa + fb + fc) / 3.0)[keep], area[keep]
    return dict(names=names, J={n: i for i, n in enumerate(names)}, pal=pal, posed=posed[:, :3],
                bind=bind, W=W, root=root, bindv=posa[gv], dom=dom, tris=tris, vpos=posa,
                fn=fn, fcen=fcen, farea=area, hull=posa[gv].mean(axis=0))


def surface(r, p, k=24):
    """The mesh surface under a bind-pose point: where it lands, which way that surface faces, how far off it was.

    Area-weighted mean of the nearest faces' normals, flipped to point OUT of the gun. The body lane turns a hand with
    this plus the bore line, so no rotation has to be tuned per gun.
    """
    p = np.array(p, float)
    if len(r["fcen"]) == 0:
        return None
    d = np.linalg.norm(r["fcen"] - p[None, :], axis=1)
    near = np.argsort(d)[:k]
    w = r["farea"][near] / (d[near] + 1e-6)
    n = (r["fn"][near] * w[:, None]).sum(axis=0)
    nn = np.linalg.norm(n)
    at = r["fcen"][near[0]]
    # ENCLOSED POINTS HAVE NO NORMAL. A point on the centre line inside a handguard is surrounded by faces whose
    # normals cancel; what survives is a residual along the tube, which would read as "this surface faces down the
    # barrel" and turn a hand nonsense. Coherence is how much of the total weight the mean keeps: near 1 the point
    # faces one way, near 0 the mesh wraps it.
    coherence = float(nn / w.sum()) if w.sum() else 0.0
    if nn < 1e-9 or coherence < 0.35:
        return dict(at=f3(at), normal=None, off_surface=round(float(d[near[0]]), 3),
                    coherence=round(coherence, 3), enclosed=True,
                    note="the mesh wraps this point (a centre-line place inside a tube or grip): no single surface "
                         "faces it, so a normal here would be an artefact")
    n /= nn
    if np.dot(n, p - r["hull"]) < 0:      # out of the gun, not into it
        n = -n
    return dict(at=f3(at), normal=f3(n), off_surface=round(float(d[near[0]]), 3),
                coherence=round(coherence, 3), enclosed=False)


def home(r, p, joint=None):
    """Carry a drawn point back onto the bind pose.

    Returns (bind point, joint name, part_moved) -- part_moved being the point's travel IN THE GUN'S OWN FRAME between
    bind and the drawn frame. A part at rest on that frame gives ~0; a slide held back, or a magazine out, gives its
    travel. The whole gun's own displacement (bind pose vs drawn) is reported once per gun, not per point.
    """
    p = np.array(p, float)
    if joint is None or joint not in r["J"]:
        near = np.argsort(np.linalg.norm(r["posed"] - p[None, :], axis=1))[:16]
        js, counts = np.unique(r["dom"][near], return_counts=True)
        j = int(js[np.argmax(counts)])
    else:
        j = r["J"][joint]
    b = (np.linalg.inv(r["pal"][j]) @ np.r_[p, 1.0])[:3]
    rel_draw = (np.linalg.inv(r["W"][r["root"]]) @ np.r_[p, 1.0])[:3]
    rel_bind = (np.linalg.inv(r["bind"][r["root"]]) @ np.r_[b, 1.0])[:3]
    return b, r["names"][j], float(np.linalg.norm(rel_draw - rel_bind))


def f3(v):
    return [round(float(x), 3) for x in v]


def outward(r, p, bore, n=32):
    """Where a point on the centre line actually meets the gun's outside, all the way round the bore.

    A brace point measured from a hand's centre sits INSIDE the handguard: the surface a palm rests on is out from it,
    and which way out is the whole question. This fires rays from the point perpendicular to the bore, once every
    360/n degrees, and reports each wall it hits -- so the underside of a handguard is a real measured place with a
    real normal, not a guess. Moller-Trumbore, vectorised over the gun's faces.
    """
    p = np.array(p, float)
    b = np.array(bore, float)
    b /= (np.linalg.norm(b) or 1.0)
    u = np.cross(b, [0.0, 0.0, 1.0])
    if np.linalg.norm(u) < 1e-6:
        u = np.cross(b, [0.0, 1.0, 0.0])
    u /= np.linalg.norm(u)
    v = np.cross(b, u)
    tri = r["tris"]
    if len(tri) == 0:
        return []
    v0, v1, v2 = r["vpos"][tri[:, 0]], r["vpos"][tri[:, 1]], r["vpos"][tri[:, 2]]
    e1, e2 = v1 - v0, v2 - v0
    hits = []
    for i in range(n):
        a = 2.0 * math.pi * i / n
        dirv = math.cos(a) * u + math.sin(a) * v
        h = np.cross(dirv, e2)
        det = np.einsum("ij,ij->i", e1, h)
        ok = np.abs(det) > 1e-9
        inv = np.where(ok, 1.0 / np.where(ok, det, 1.0), 0.0)
        s = p[None, :] - v0
        uu = inv * np.einsum("ij,ij->i", s, h)
        q = np.cross(s, e1)
        vv = inv * (q @ dirv)
        t = inv * np.einsum("ij,ij->i", e2, q)
        good = ok & (uu >= 0) & (uu <= 1) & (vv >= 0) & (uu + vv <= 1) & (t > 1e-4)
        if not good.any():
            continue
        j = int(np.argmin(np.where(good, t, np.inf)))
        nrm = np.cross(e1[j], e2[j])
        nrm /= (np.linalg.norm(nrm) or 1.0)
        if np.dot(nrm, dirv) > 0:        # the wall faces back at the ray, i.e. out of the gun
            nrm = -nrm
        hits.append(dict(deg=round(math.degrees(a), 1), dist=round(float(t[j]), 3),
                         at=f3(p + t[j] * dirv), normal=f3(nrm)))
    return hits


# ---- run ---------------------------------------------------------------------------------------------------------
if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    fr, rows, guns_moved = frames(), [], []
    for g in cards():
        prop = g["cls"].replace("WM_", "WM_Prop")
        frame = fr.get(prop)
        if frame is None:
            print("!! no MODELDEF frame for %s" % prop)
            continue
        r = rig(M + g["dir"] + "/" + g["iqm"], frame)
        gun_moved = float(np.linalg.norm(r["W"][r["root"]][:3, 3] - r["bind"][r["root"]][:3, 3]))
        out = dict(weapon=g["cls"], model=g["dir"] + "/" + g["iqm"], drawn_frame=frame,
                   gun_frame_joint=r["names"][r["root"]], gun_moved=round(gun_moved, 3),
                   note="bind-pose points for FollowActorOfsInModel; that call takes them as (x, z, y)", points={})
        for k, v in g["pts"].items():
            if k == "barrel":
                continue
            b, jn, moved = home(r, v)
            out["points"][k] = dict(kind=KIND[k], bind=f3(b), drawn=f3(v), moved=round(moved, 3), joint=jn,
                                    surface=surface(r, b))
        # THE BORE, ON THE BIND POSE: the card's barrel line carried through the same joint the muzzle rides. The body
        # lane turns a hand with this plus a surface normal, so the gun's own geometry supplies both.
        if "muzzle" in g["pts"] and "barrel" in g["pts"]:
            mb, mj, _ = home(r, g["pts"]["muzzle"])
            R = np.linalg.inv(r["pal"][r["J"][mj]])[:3, :3]
            v = R @ np.array(g["pts"]["barrel"], float)
            out["bore"] = dict(kind="fact", muzzle_bind=f3(mb), dir_bind=f3(v / (np.linalg.norm(v) or 1.0)),
                               dir_drawn=f3(g["pts"]["barrel"]), joint=mj)
        for p in g["parts"]:
            if not p["grab"]:
                continue
            b, jn, moved = home(r, p["grab"], p["joint"])
            sf = surface(r, b)
            out["points"]["grab:" + p["id"]] = dict(kind=KIND["support" if p["id"] == "support" else "grab"],
                                                    bind=f3(b), drawn=f3(p["grab"]), moved=round(moved, 3), joint=jn,
                                                    card_joint=p["joint"], surface=sf)
            if p["id"] == "support" and "bore" in out:
                hits = outward(r, b, out["bore"]["dir_bind"])
                out["points"]["grab:support"]["outward"] = hits
                if hits:
                    near = min(hits, key=lambda h: h["dist"])
                    out["points"]["grab:support"]["nearest_wall"] = near
                    sf = dict(sf or {}, wall_at=near["at"], wall_normal=near["normal"], wall_dist=near["dist"])
                    out["points"]["grab:support"]["surface"] = sf
            rows.append((g["cls"], p["id"], p["joint"] or jn, f3(b), f3(p["grab"]), round(moved, 3),
                         (sf.get("wall_normal") or sf.get("normal")) if sf else None,
                         sf.get("wall_dist", sf.get("off_surface")) if sf else None))
        guns_moved.append((g["cls"], r["names"][r["root"]], frame, round(gun_moved, 1)))
        json.dump(out, open(OUT + g["cls"] + ".json", "w"), indent=1)
        print("%-22s frame %-4d gun %6.1f from bind   %d point(s)" % (g["cls"], frame, gun_moved, len(out["points"])))

    with open(OUT + "TABLE.md", "w", encoding="utf-8", newline="\n") as fh:
        fh.write("# BREACH grabs on the bind pose (reload lane, 2026-09-18)\n\n"
                 "Every grab point the cards author, carried back onto the BIND POSE for piece E "
                 "(`FollowActorOfsInModel` takes a bind-pose point as **(x, z, y)**; these are file axes x, y, z).\n\n"
                 "**These are hand positions, and nobody has confirmed one in a headset.** They were fitted to the RS "
                 "hand at its size, so treat them as a starting guess per body, not as truth. The mesh facts "
                 "(muzzle, eject port, magazine centre, joint names) are in each gun's JSON beside them.\n\n"
                 "## The headline: the bind pose is NOT the gun you see\n\n"
                 "These are character rigs, and their bind pose parks the whole gun far from where the drawn frame puts "
                 "it. Feeding a drawn number into `FollowActorOfsInModel` would not be off by a slide's travel -- it "
                 "would be off by this much:\n\n"
                 "| Gun | Gun-frame joint | Drawn frame | Whole gun sits this far from bind |\n|---|---|---|---|\n")
        for cls, jn, frame, gm in guns_moved:
            fh.write("| %s | `%s` | %d | **%.1f** |\n" % (cls.replace("WM_Breach", ""), jn, frame, gm))
        fh.write("\n## The points\n\n"
                 "`part travel` is the point's own movement IN THE GUN'S OWN FRAME between bind and the drawn frame. "
                 "~0 means the part was at rest on that frame, so the card's relative geometry and the bind geometry "
                 "agree and only the whole-gun placement above differs. Anything large is a part that was mid-motion.\n\n"
                 "`surface normal` is the way the mesh faces where that point lands, on the bind pose, pointing out of "
                 "the gun (area-weighted mean of the nearest faces). With the bore line it gives the hand's turn, so no "
                 "rotation needs tuning per gun. `off` is how far the point sits from the nearest face -- a grab point "
                 "is meant to be a little off the surface, so this is a sanity number, not an error.\n\n"
                 "| Gun | Part | Joint | Bind (x, y, z) | Drawn (x, y, z) | part travel | Surface normal | off |\n"
                 "|---|---|---|---|---|---|---|---|\n")
        for cls, pid, jn, b, dr, moved, nrm, off in rows:
            fh.write("| %s | %s | `%s` | %s | %s | %.3f | %s | %s |\n"
                     % (cls.replace("WM_Breach", ""), pid, jn, ", ".join("%.3f" % x for x in b),
                        ", ".join("%.3f" % x for x in dr), moved,
                        ", ".join("%.3f" % x for x in nrm) if nrm else "-",
                        ("%.2f" % off) if off is not None else "-"))
    print("wrote %sTABLE.md (%d rows)" % (OUT, len(rows)))

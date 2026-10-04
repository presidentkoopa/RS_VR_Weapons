"""Seat the Breach Glock like the M4A3 in the main hand: same placement (wm_main's values as the Glock set's defaults),
no rotation offsets, a size from the M4A3's in-hand length times Glock 17 / 1911 (202 / 216 mm), and a MODELDEF Offset
that puts the Glock's trigger exactly where the M4A3's trigger is. Uses the engine chain of RS_VRBody/tools/ermac
(ingame_chain.py) exactly as the seat solver does.
    python glock_seat.py
"""
import json, os, sys
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
# ingame_chain.py HAS NO LIVE HOME. RS_VRBody is gone from the top level and the only copy outside
# the quarantined _old/ is this 09-18 backup snapshot. md3.py moved to CardPipeline's tools.
# TRUST NOTHING THIS PRINTS UNTIL IT IS RE-CHECKED: the chain module predates the 2026-09-25
# hand-units change, and --scale comes from you while the reference gun's Scale is read live out of
# RS_VR_Weapons/MODELDEF.txt, so re-solve a seat you already know before accepting a new one.
sys.path.insert(0, "E:/DOOMWork/_backups/handsbody_before_stabilize_merge_2026-09-18/RS_VRBody/tools/ermac")
sys.path.insert(0, "E:/DOOMWork/CardPipeline/tools")
import ingame_chain as ic
from md3 import MD3Model

ini = ic.read_ini()
props = ic.read_props()
m4 = props["WM_PropM4A3"]
mm = MD3Model.load(m4["md3"])
allv = np.vstack([np.array(s.verts[0], dtype=float) for s in mm.surfaces])
trig = next(s for s in mm.surfaces if s.name == "m4a3_trigger")
tp = np.array(trig.verts[0], dtype=float).mean(axis=0)
pl = ic.placement(m4["prefix"], ini)
print("wm_main placement (ini):", pl)
Mm = ic.chain(m4["scale"], m4["offset"], *m4["base"], pl)
target = ic.to_engine(tp[None, :], Mm)[0]
Lm = (allv[:, 0].max() - allv[:, 0].min()) * abs(m4["scale"][0])
print("M4A3: trigger engine %s; in-hand length %.2f (file %.2f x %.2f)" % (target.round(3), Lm, allv[:, 0].max() - allv[:, 0].min(), abs(m4["scale"][0])))


def dirs(M, vecs):
    e = np.array([[v[0], v[2], v[1]] for v in vecs], dtype=float) @ M[:3, :3].T
    return [x / np.linalg.norm(x) for x in e]


mb, mu, mr = dirs(Mm, [(1, 0, 0), (0, 0, 1), (0, -1, 0)])
print("M4A3 engine barrel %s up %s right %s" % (mb.round(3), mu.round(3), mr.round(3)))

pts = json.load(open(os.path.join(HERE, "glock_points.json")))
GLOCK_LEN = 20.88
s = round(Lm * 202.0 / 216.0 / GLOCK_LEN, 3)
gt = np.array(pts["trigger"]["file"], dtype=float)
M0 = ic.chain((s, s, s), (0.0, 0.0, 0.0), 0.0, 0.0, 0.0, pl)
e0 = ic.to_engine(gt[None, :], M0)[0]
delta = target - e0                       # engine (x, y up, z) = MODELDEF Offset (x, z, y)
offset = (round(float(delta[0]), 3), round(float(delta[2]), 3), round(float(delta[1]), 3))
M1 = ic.chain((s, s, s), offset, 0.0, 0.0, 0.0, pl)
e1 = ic.to_engine(gt[None, :], M1)[0]
gb, gu, gr = dirs(M1, [(1, 0, 0), (0, 0, 1), (0, 1, 0)])
print("Glock: Scale %s; Offset %s; trigger engine %s (gap %.4f)" % (s, offset, e1.round(3), np.linalg.norm(e1 - target)))
print("Glock engine barrel %s up %s right %s  (vs M4A3: barrel %.4f, up %.4f, right %.4f)"
      % (gb.round(3), gu.round(3), gr.round(3), np.dot(gb, mb), np.dot(gu, mu), np.dot(gr, mr)))
mz = np.array(pts.get("muzzle", {}).get("file", [50.914, 5.767, -4.034]), dtype=float)
m4mz = np.array([18.99, -0.07, 4.27])
print("muzzle engine: Glock %s  M4A3 %s" % (ic.to_engine(mz[None, :], M1)[0].round(2), ic.to_engine(m4mz[None, :], Mm)[0].round(2)))
json.dump(dict(scale=s, offset=offset, placement=pl), open(os.path.join(HERE, "glock_seat.json"), "w"), indent=1)

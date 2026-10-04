"""Seat a BREACH gun in a hand like the reference pistol of that hand: the M4A3 on wm_main, the Pistolet on wm_off (the
owner's tuned seats; RS_VRBody/tools/ermac/seat_solve.py's rule). Same placement as the reference, no rotation offset;
the gun's trigger landmark goes exactly onto the reference's trigger through the engine chain (ingame_chain.py).
Prints the MODELDEF Scale and Offset, the trigger gap, and how the gun points against the reference -- barrel, top and
right side in engine space -- so a gun that would sit turned is caught here, not in a headset.
    python breach_seat.py --hand main|off --landmark x,y,z --scale S [--signs sx,sy,sz]
                          [--barrel x,y,z] [--up x,y,z] [--right x,y,z] [--muzzle x,y,z]
landmark, muzzle, barrel, up, right: in the gun's FILE axes (its card's). signs: MODELDEF Scale's signs -- -1,-1,1 turns
the mesh 180 degrees about its vertical without any rotation offset. barrel/up/right default +x, +z, +y.
"""
import argparse, json, sys
import numpy as np

# ingame_chain.py HAS NO LIVE HOME. RS_VRBody is gone from the top level and the only copy outside
# the quarantined _old/ is this 09-18 backup snapshot. md3.py moved to CardPipeline's tools.
# TRUST NOTHING THIS PRINTS UNTIL IT IS RE-CHECKED: the chain module predates the 2026-09-25
# hand-units change, and --scale comes from you while the reference gun's Scale is read live out of
# RS_VR_Weapons/MODELDEF.txt, so re-solve a seat you already know before accepting a new one.
sys.path.insert(0, "E:/DOOMWork/_backups/handsbody_before_stabilize_merge_2026-09-18/RS_VRBody/tools/ermac")
sys.path.insert(0, "E:/DOOMWork/CardPipeline/tools")
import ingame_chain as ic
from md3 import MD3Model

vec = lambda s: np.array([float(x) for x in s.split(",")], dtype=float)
ap = argparse.ArgumentParser()
ap.add_argument("--hand", choices=("main", "off"), required=True)
ap.add_argument("--landmark", type=vec, required=True)
ap.add_argument("--scale", type=float, required=True)
ap.add_argument("--signs", type=vec, default=vec("1,1,1"))
ap.add_argument("--barrel", type=vec, default=vec("1,0,0"))
ap.add_argument("--up", type=vec, default=vec("0,0,1"))
ap.add_argument("--right", type=vec, default=vec("0,1,0"))
ap.add_argument("--muzzle", type=vec)
a = ap.parse_args()

REF = {"main": ("WM_PropM4A3", "m4a3_trigger", (1, 0, 0), (0, 0, 1), (0, -1, 0)),
       "off": ("WM_PropPistolet", "rec.001", (1, 0, 0), (0, 0, 1), (0, 1, 0))}
ini = ic.read_ini()
props = ic.read_props()
rname, rsurf, rb, ru, rr = REF[a.hand]
rp = props[rname]
m = MD3Model.load(rp["md3"])
tp = np.array(next(s for s in m.surfaces if s.name == rsurf).verts[0], dtype=float).mean(axis=0)
pl = ic.placement(rp["prefix"], ini)
Mr = ic.chain(rp["scale"], rp["offset"], *rp["base"], pl)
target = ic.to_engine(tp[None, :], Mr)[0]


def dirs(M, vs):
    e = np.array([[v[0], v[2], v[1]] for v in vs], dtype=float) @ M[:3, :3].T
    return [x / np.linalg.norm(x) for x in e]


scale = tuple(float(a.scale * s) for s in a.signs)
M0 = ic.chain(scale, (0.0, 0.0, 0.0), 0.0, 0.0, 0.0, pl)
delta = target - ic.to_engine(a.landmark[None, :], M0)[0]
offset = (round(float(delta[0]), 3), round(float(delta[2]), 3), round(float(delta[1]), 3))
M1 = ic.chain(scale, offset, 0.0, 0.0, 0.0, pl)
e1 = ic.to_engine(a.landmark[None, :], M1)[0]
rB, rU, rR = dirs(Mr, [rb, ru, rr])
gB, gU, gR = dirs(M1, [a.barrel, a.up, a.right])
out = dict(hand=a.hand, prefix=rp["prefix"], scale=[round(s, 4) for s in scale], offset=offset,
           trigger_gap=round(float(np.linalg.norm(e1 - target)), 4),
           barrel_dot=round(float(gB @ rB), 4), up_dot=round(float(gU @ rU), 4), right_dot=round(float(gR @ rR), 4))
if a.muzzle is not None:
    out["muzzle_engine"] = [round(float(x), 2) for x in ic.to_engine(a.muzzle[None, :], M1)[0]]
print("reference %s on %s: trigger engine %s" % (rname, rp["prefix"], target.round(3)))
print("Scale %s   Offset %s   PlacementCVars %s   trigger gap %.4f" % (" ".join("%.3f" % s for s in scale), " ".join("%.3f" % o for o in offset), rp["prefix"], out["trigger_gap"]))
print("points like the reference: barrel %.4f  top %.4f  right %.4f  %s" % (out["barrel_dot"], out["up_dot"], out["right_dot"],
      "OK" if min(out["barrel_dot"], out["up_dot"], out["right_dot"]) > 0.999 else "TURNED -- not as the reference"))
print(json.dumps(out))

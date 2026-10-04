"""The rest of the Breach Glock's card points, off the frame-0 posed mesh (glock_measure.py does the posing).
Gun space: +x rear, +y left, +z up. File space is what the card is written in.
    python glock_points.py <glockrerig.iqm>
"""
import json, os, runpy, sys
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
IQM = sys.argv[1]
sys.argv = ["glock_measure.py", IQM]
g = runpy.run_path(os.path.join(HERE, "glock_measure.py"))
gs, dom, J, R, to_file = g["gs"], g["dom"], g["J"], g["R"], g["to_file"]
f3 = lambda v: [round(float(x), 3) for x in v]
pts = {}


def say(name, gun_pt, note=""):
    pts[name] = dict(gun=f3(gun_pt), file=f3(to_file(np.asarray(gun_pt, dtype=float))))
    print("%-16s gun %-28s file %-28s %s" % (name, f3(gun_pt), pts[name]["file"], note))


print("=" * 100)
# MAGAZINE: its own long axis (PCA of its verts), in the gun's symmetry plane, pointing out of the well (down).
mag = gs[dom == J["j_mag1"]]
c = mag.mean(axis=0)
w, v = np.linalg.eigh((mag - c).T @ (mag - c) / len(mag))
ax = v[:, -1].copy()
ax[1] = 0.0
ax /= np.linalg.norm(ax)
if ax[2] > 0:
    ax = -ax
proj = mag @ ax
print("magazine long axis (out) gun %s file %s; %.1f deg off vertical; length along it %.2f"
      % (f3(ax), f3(R @ ax), np.degrees(np.arctan2(ax[0], -ax[2])), proj.max() - proj.min()))
pts["mag_axis"] = dict(gun=f3(ax), file=f3(R @ ax), length=round(float(proj.max() - proj.min()), 3))
floor = mag[proj >= proj.max() - 0.5]
say("mag_floorplate", floor.mean(axis=0), "(%d verts within 0.5 of the bottom)" % len(floor))
say("mag_centroid", c)

# SLIDE: the rear serrations, top of the slide.
sl = gs[dom == J["j_slide"]]
rear = sl[sl[:, 0] >= sl[:, 0].max() - 2.5]
top = rear[rear[:, 2] >= rear[:, 2].max() - 0.8]
say("slide_grab", top.mean(axis=0), "(rear 2.5, top 0.8: %d verts)" % len(top))

# GRIP: the front strap at mid-grip -- where a support hand wraps.
body = gs[dom == J["tag_weapon"]]
band = body[(body[:, 2] > -7.5) & (body[:, 2] < -6.5)]
say("support_grab", [band[:, 0].min(), 0.0, -7.0], "(front strap, z -7.5..-6.5: min x of %d verts)" % len(band))
say("backstrap", [band[:, 0].max(), 0.0, -7.0])

# EJECTION PORT: the slide's right side (-y) at the top, at the extractor's station.
ext = gs[(dom == J["j_slide"]) & (np.abs(gs[:, 0] - 13.0) < 2.0) & (gs[:, 1] < 0)]
say("ejectport", [13.0, ext[:, 1].min(), ext[:, 2].max() - 0.3], "(slide right side near the extractor)")

# TRIGGER: the blade's centroid (the seat landmark).
say("trigger", gs[dom == J["j_trigger"]].mean(axis=0))

json.dump(pts, open(os.path.join(HERE, "glock_points.json"), "w"), indent=1)

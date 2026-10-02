#!/usr/bin/env python3
"""Copy a UBQS saber pk3, adding the TEST RIG HOOK to UBQS_SaberBase's hand accessors (see rig_hook.diff).
Usage: patch_hook.py <in.pk3> <out.pk3>.  Already-hooked pk3s are copied unchanged."""
import sys
import zipfile

OLD = """	Vector3 HandPos()
	{
		Vector3 p = bOffhandWeapon ? owner.OffhandPos : owner.AttackPos;
		if (p == (0, 0, 0)) p = owner.Vec3Offset(0, 0, owner.player ? owner.player.viewheight * 0.8 : 40.0);
		return p;
	}
	double HA() { return (bOffhandWeapon ? owner.OffhandAngle : owner.AttackAngle) + 90.0; }
	double HP() { return -(bOffhandWeapon ? owner.OffhandPitch : owner.AttackPitch); }
	double HR() { return bOffhandWeapon ? owner.OffhandRoll : owner.AttackRoll; }
"""
NEW = """	// TEST RIG HOOK (inert unless a rig sets rigPose): a hand pose to use in place of the engine's controller
	// fields, which are readonly and on a PC without a headset are just the body's centre and the view angles
	bool   rigPose;
	Vector3 rigPos;
	double rigAngle, rigPitch, rigRoll;   // the same meaning as AttackAngle / AttackPitch / AttackRoll
	Vector3 HandPos()
	{
		if (rigPose) return rigPos;
		Vector3 p = bOffhandWeapon ? owner.OffhandPos : owner.AttackPos;
		if (p == (0, 0, 0)) p = owner.Vec3Offset(0, 0, owner.player ? owner.player.viewheight * 0.8 : 40.0);
		return p;
	}
	double HA() { return (rigPose ? rigAngle : (bOffhandWeapon ? owner.OffhandAngle : owner.AttackAngle)) + 90.0; }
	double HP() { return -(rigPose ? rigPitch : (bOffhandWeapon ? owner.OffhandPitch : owner.AttackPitch)); }
	double HR() { return rigPose ? rigRoll : (bOffhandWeapon ? owner.OffhandRoll : owner.AttackRoll); }
"""

# (predict copy) build 50 moved HandPos into a shared static, UBQS_Data.HandPosOf
OLD50 = """	Vector3 HandPos() { return UBQS_Data.HandPosOf(owner, bOffhandWeapon); }
	double HA() { return (bOffhandWeapon ? owner.OffhandAngle : owner.AttackAngle) + 90.0; }
	double HP() { return -(bOffhandWeapon ? owner.OffhandPitch : owner.AttackPitch); }
	double HR() { return bOffhandWeapon ? owner.OffhandRoll : owner.AttackRoll; }
"""
NEW50 = NEW.replace("""		Vector3 p = bOffhandWeapon ? owner.OffhandPos : owner.AttackPos;
		if (p == (0, 0, 0)) p = owner.Vec3Offset(0, 0, owner.player ? owner.player.viewheight * 0.8 : 40.0);
		return p;""", """		return UBQS_Data.HandPosOf(owner, bOffhandWeapon);""")

src, dst = sys.argv[1], sys.argv[2]
zin = zipfile.ZipFile(src)
done = False
with zipfile.ZipFile(dst, "w", zipfile.ZIP_DEFLATED) as zout:
    for info in zin.infolist():
        data = zin.read(info.filename)
        if info.filename.lower().startswith("zscript") and b"class UBQS_SaberBase" in data:
            s = data.decode("latin1")
            if "rigPose" in s:
                done = True
            elif s.count(OLD) == 1:
                s = s.replace(OLD, NEW)
                data = s.encode("latin1")
                done = True
            elif s.count(OLD50) == 1:
                s = s.replace(OLD50, NEW50)
                data = s.encode("latin1")
                done = True
        zout.writestr(info, data)
if not done:
    sys.exit("patch_hook: UBQS_SaberBase hand accessors not found in %s (source changed?)" % src)
print("patch_hook: hooked %s -> %s" % (src, dst))

"""Generate RS_Modern's BREACH set from the measurements (tools/points/*.json) and the table below.

Regenerated whole every run -- change the table, not the output:
  zscript/rs_modern/breach_glock.zs   the Glock's class
  zscript/rs_modern/breach_set.zs     every other gun's class and prop
  zscript/rs_modern/player.zs         the Modern class: its start and its slots
  zscript.txt                         the includes
  WMCARD.breach_set                   every card but the Glock's (WMCARD.breach, written by hand)
  MODELDEF.txt, SNDINFO.txt           every prop and every sound, the Glock's included
  licenses/breach_weapons_CREDIT.txt  what came from Breach, and what was made from it
SOURCES: a card point is a measurement (tools/points/<gun>.json, breach_points.py, on the frame the prop draws); a seat is
breach_seat.py's (the trigger on the reference pistol's trigger, pointing as it does); a shot, a capacity or a sound is
Breach's own zscript, cited as file:line from the survey of zscript/*.zs.
    python gen_breach_set.py
"""
import json, os

M = "E:/DOOMWork/RS_Modern/"
T = "\t"


def pts(name):
    return json.load(open(M + "tools/points/%s.json" % name))


def v3(v):
    return "%.3f, %.3f, %.3f" % tuple(v)


BRASS = "rsm/breachglock/casing"
# SEATS ARE IN BREACH_SEAT.PY'S UNITS, as solved on 09-15 -- not in MODELDEF units. The 2026-09-25
# hand-units change made every follow-hand model 1/2.9412 of what it was, so the MODELDEF writer
# below takes scale and offset x0.34, exactly as the card's magscale already does. Record here what
# the seat tool prints; never paste a number back out of MODELDEF.txt or it gets the factor twice.
RIFLE_SEAT = dict(scale=1.145, offset=(-5.826, -4.846, 4.162), prefix="wm_main", frame=25)
RIFLE_FRAME_NOTE = ("frame 25, Breach's own Ready frame (FrameIndex MK18 Z 0 25): muzzle along +x to 0.0 degrees, top 2.5 "
                    "degrees off (a roll Breach's MODELDEF evens out on two of the rifles; left for the owner's eye)")
MAG2 = [("j_mag2", "BREACH'S SECOND MAGAZINE: the reload animation's spare, parked far below the gun on this frame.")]


def rifle(key, cls, title, tag, src, iqm, pname, family, icon, sel, spread, dmg, fire, magout, magin, prof, supp, extra=None, muzzle=None,
          handle_surface=None, handle_surface_why=()):
    p = pts(pname)
    grab = p.get("grab", [15.722, p["muzzle"][1], -4.999])
    return dict(key=key, cls=cls, title=title, tag=tag, src=src, hand="main", type="rifle", dir="models/breach/" + iqm[0],
                iqm=iqm[1], extra=extra or [], seat=RIFLE_SEAT, frame_note=RIFLE_FRAME_NOTE, p=p, muzzle=muzzle or p["muzzle"],
                capacity=30, family=family, cap_note="Breach's magazine holds 30 (%s)." % src, hidejoints=MAG2,
                mag=dict(model="wm_breach%s_mag.md3" % iqm[0], scale=1.145), round_=("models/vanilla/pistols", "bullet.md3", "bullet.png", 0.31),
                sounds=dict(fire="rsm/breach%s/fire" % key, dry="rsm/breach/click", magout=magout, magin=magin,
                            rackapex="rsm/breach/boltback", rackreset="rsm/breach/boltclose", magdrop="wm/magdrop", casing=BRASS),
                parts=[dict(id="charginghandle", role="action", subject="slide", joint="j_charginghandle", grab=grab,
                            surface=handle_surface, surface_why=handle_surface_why,
                            dof=dict(kind="slide", axis=(-1, 0, 0), distance=5.55, detach=0.95),
                            note="THE CHARGING HANDLE: joint j_charginghandle, 5.55 straight back along -x on the rig's rack frames "
                                 "221-243. The grab is its rear T" + ("." if "grab" in p else
                                 " -- this rig gives the handle no mesh of its own, so the grab is the joint and nothing is seen to move.")),
                       "magazine", "support"],
                shot=dict(spread=spread, damage=dmg, tics=3, first=0, altmode="selectfire", burst=3, bursttics=3),
                profiles=(prof,) * 4, suppressed=supp, icon=icon, slot=4, sel=sel,
                shotnote="%s: A_FireBullets(%.2f, %.2f, -1, %d) aimed -- one bullet, always within that spread, %d x 1d3 -- ready "
                         "again 3 tics later (700 a minute). Breach toggles semi and full (rof_firemode); here the second button "
                         "steps single, burst, full (AltMode selectfire)." % (src, spread[0], spread[1], dmg[0], dmg[0]))


GUNS = [
    dict(key="glocks", cls="WM_BreachGlockS", title="Breach Glock (suppressed)", tag="Glock (suppressed)", src="glocks.zs:258",
         hand="main", type="pistol", dir="models/breach/glocksil", iqm="glocksil.iqm",
         seat=dict(scale=1.145, offset=(-6.535, 16.154, -0.233), prefix="wm_main", frame=0),
         frame_note="frame 0, Breach's Ready frame; it stands straight", p=pts("glocks"),
         capacity=17, family="glock", cap_note="Breach's GlocksMagazine holds 17 (glocks.zs:13); the Glock's family, so either Glock's magazine seats.",
         mag=dict(model="wm_breachglocksil_mag.md3", scale=1.145), round_=("models/vanilla/pistols", "bullet.md3", "bullet.png", 0.16),
         sounds=dict(fire="rsm/breachglocks/fire", dry="rsm/breach/click", magout="rsm/breachglock/magout", magin="rsm/breachglock/magin",
                     rackapex="rsm/breachglock/slideback", rackreset="rsm/breachglock/slidefwd", magdrop="wm/magdrop", casing=BRASS),
         parts=[dict(id="slide", role="action", subject="slide", joint="j_slide", grab=(32.844, 5.813, -2.770),
                     dof=dict(kind="slide", axis=(-1, 0, 0), distance=4.5, detach=0.95),
                     note="THE SLIDE: joint j_slide, 4.50 back along -x on the rig's fire frames (its Kobra sight rides it). The grab is "
                          "the rear serrations, as the Glock's -- the slide's highest verts here are the sight's."),
                "magazine",
                dict(id="trigger", role="trigger", joint="j_trigger", dof=dict(kind="slide", axis=(-1, 0, 0), distance=0.96),
                     note="THE TRIGGER: joint j_trigger, 0.96 straight back along -x -- a Glock's trigger slides. Follows your finger."),
                "support"],
         shot=dict(spread=(3.0, 3.0), damage=(20, 60), tics=6, first=1), profiles=("glock17_sup",) * 4,
         suppressed=True, icon="GLOKB0", slot=2, sel=160,
         shotnote="glocks.zs:258: A_FireBullets(3, 3, 1, 20) aimed, ready again 6 tics later, semi-auto; one bullet on a fresh pull "
                  "flies dead on (FirstShotsAccurate 1). Suppressed: ZBulletPuffSil and no alert."),
    dict(key="kimber", cls="WM_BreachKimber", title="Breach Kimber", tag="Kimber", src="kimber.zs:244",
         hand="off", type="pistol", dir="models/breach/kimber", iqm="kimber.iqm",
         seat=dict(scale=1.145, offset=(-6.565, 14.758, 1.510), prefix="wm_off", frame=0),
         frame_note="frame 0, Breach's Ready frame; it stands straight", p=pts("kimber"),
         capacity=8, family="kimber", cap_note="Breach's KimberMagazine holds 8 (kimber.zs:13). Its own family: a 1911's 8-round magazine.",
         mag=dict(model="wm_breachkimber_mag.md3", scale=1.145), round_=("models/vanilla/pistols", "bullet.md3", "bullet.png", 0.175),
         sounds=dict(fire="rsm/breachkimber/fire", dry="rsm/breach/click", magout="rsm/breach/clipout", magin="rsm/breach/clipin",
                     rackapex="rsm/breachglock/slideback", rackreset="rsm/breachglock/slidefwd", magdrop="wm/magdrop", casing=BRASS),
         parts=[dict(id="slide", role="action", subject="slide", joint="j_slide", grab=None,
                     dof=dict(kind="slide", axis=(-1, 0, 0), distance=4.5, detach=0.95),
                     note="THE SLIDE: joint j_slide, 4.50 back along -x on the rig's fire frames. The grab is its rear top. "
                          "(Its trigger and hammer are fused into the frame in this mesh: no part for them.)"),
                "magazine", "support"],
         shot=dict(spread=(3.0, 3.0), damage=(34, 102), tics=6, first=1), profiles=("kimber1911",) * 4,
         suppressed=False, icon="KIMBER", slot=2, sel=9100,
         shotnote="kimber.zs:244: A_FireBullets(3, 3, 1, 34) aimed -- .45, 34 x 1d3 -- ready again 6 tics later, semi-auto; one bullet "
                  "on a fresh pull flies dead on. OFF HAND, the Pistolet's seat."),
    rifle("mk18", "WM_BreachMK18", "Breach MK18", "MK18", "mk18.zs:255", ("mk18", "mk18nosil.iqm"), "mk18", "stanag", "MKUSA0", 900,
          (3.0, 3.0), (30, 90), None, "rsm/breach/clipout", "rsm/breach/clipin", "mk18", False,
          handle_surface="charge_ar15_gry.bmp",
          handle_surface_why=("TEST 2026-09-26: was `joint = j_charginghandle`. The engine's joint drive",
                              "(model_reach.cpp) is no longer in the tree, so a joint part cannot move.",
                              "This mesh is EXCLUSIVELY the charging handle (3359 verts), so it can be",
                              "driven as a surface -- the same path every MD3 gun uses. Travel and axis",
                              "unchanged: both were measured off the rig and are correct.")),
    rifle("mk18s", "WM_BreachMK18S", "Breach MK18 (suppressed)", "MK18 (suppressed)", "mk18s.zs:250", ("mk18", "mk18nosil.iqm"), "mk18",
          "stanag", "MK18A0", 910, (3.0, 3.0), (30, 90), None, "rsm/breach/clipout", "rsm/breach/clipin", "mk18_sup", True,
          extra=[(1, "mk18newsilencer.iqm"), (2, "mk18laser.iqm")], muzzle=pts("mk18s_silencer")["muzzle"]),
    rifle("hk416s", "WM_BreachHK416S", "Breach HK416 (suppressed)", "HK416 (suppressed)", "hk416s.zs:247", ("hk416", "hk416.iqm"), "hk416s",
          "stanag", "HK416", 920, (1.75, 1.75), (28, 84), None, "rsm/breach/cmagout", "rsm/breach/cmagin", "hk416_sup", True),
    rifle("mcx", "WM_BreachMCX", "Breach MCX (suppressed)", "MCX (suppressed)", "mcx.zs:248", ("mcx", "mcxrig.iqm"), "mcx",
          "stanag", "MCX", 930, (2.0, 2.0), (28, 84), None, "rsm/breach/cmagout", "rsm/breach/cmagin", "mcx_sup", True),
    rifle("g36c", "WM_BreachG36C", "Breach G36C (suppressed)", "G36C (suppressed)", "g36c.zs:247", ("g36", "g36rerig.iqm"), "g36c",
          "g36", "G36C", 940, (2.0, 2.0), (28, 84), None, "rsm/breach/cmagout", "rsm/breach/cmagin", "g36c_sup", True),
    dict(key="mp5", cls="WM_BreachMP5", title="Breach MP5", tag="MP5", src="mp5.zs:329",
         hand="main", type="smg", dir="models/breach/mp5", iqm="mp5.iqm",
         seat=dict(scale=2.29, offset=(-7.667, -1.614, 6.122), prefix="wm_main", frame=109),
         frame_note="frame 109 (end of Breach's idle wobble): muzzle and top within 0.3 degrees; Breach's Ready frame 0 is 2 degrees off, "
                    "which its MODELDEF pitches out", p=pts("mp5"),
         capacity=30, family="mp5", cap_note="Breach's MP5Magazine holds 30 (mp5.zs:5).", hidejoints=MAG2,
         mag=dict(model="wm_breachmp5_mag.md3", scale=2.29), round_=("models/vanilla/pistols", "bullet.md3", "bullet.png", 0.16),
         sounds=dict(fire="rsm/breachmp5/fire", dry="rsm/breach/click", magout="rsm/breach/cmagout", magin="rsm/breach/cmagin",
                     rackapex="rsm/breach/boltback", rackreset="rsm/breach/boltclose", magdrop="wm/magdrop", casing=BRASS),
         parts=[dict(id="charginghandle", role="action", subject="slide", joint="j_charging_tube", grab=None,
                     dof=dict(kind="slide", axis=(-1, 0, 0), distance=1.29, detach=0.95),
                     note="THE COCKING HANDLE: joint j_charging_tube, 1.29 back along -x on the rig's rack frames 199-216, on the left of "
                          "the tube over the barrel. The grab is its rear."),
                "magazine", "support"],
         shot=dict(spread=(0.8, 0.8), damage=(20, 60), tics=3, first=0, altmode="selectfire", burst=3, bursttics=3),
         profiles=("mp5",) * 4, suppressed=False, icon="MP5", slot=4, sel=950,
         shotnote="mp5.zs:329: A_FireBullets(0.8, 0.8, -1, 20) aimed, ready again 3 tics later; Breach has semi, 3-round burst and full "
                  "-- the second button steps them here (AltMode selectfire, a burst of 3, 3 tics apart)."),
    dict(key="benelli", cls="WM_BreachBenelli", title="Breach Benelli M4", tag="Benelli M4", src="benelli.zs:212",
         hand="main", type="shotgun", dir="models/breach/benelli", iqm="benelli.iqm",
         seat=dict(scale=2.62, offset=(-9.151, -5.119, 5.404), prefix="wm_main", frame=59),
         frame_note="frame 59: top within 0.6 degrees, the muzzle 3.1 degrees to the left (no frame of this rig is straighter; left "
                    "for the owner's eye, and the barrel below is the gun's own measured line)", p=pts("benelli"),
         capacity=7, family="12ga", cap_note="Breach's BenelliMagazine: a 7-shell tube (benelli.zs:6-7).",
         hidejoints=[("shell", "THE SHELL BREACH'S LEFT HAND LOADS, parked at the muzzle on this frame.")],
         mag=None, round_=("models/shared/shell", "shell.md3", "shell.png", 0.228), barrel=(0.999, -0.054, 0.007),
         support_y=2.9,
         sounds=dict(fire="rsm/breachbenelli/fire", dry="rsm/breach/click", cycleout="rsm/breach/pump1", cyclehome="rsm/breach/boltclose",
                     load="rsm/breach/lshell1", casing="rsm/breach/sshell1"),
         parts=[dict(id="bolt", subject="slide", joint="bolt", grab=None,
                     dof=dict(kind="slide", axis=(-0.999, 0.054, -0.007), distance=3.23, detach=0.95),
                     note="THE BOLT HANDLE: joint bolt, 3.23 back along the gun's own line on the rig's rack frames 153-182. No role: the "
                          "cycle below names it, which makes it grabbable. The grab is its rear."),
                dict(id="trigger", role="trigger", joint="trigger",
                     dof=dict(kind="hinge", axis=(0, 1, 0), degrees=17.8, pivot=(9.151, 3.930, -4.749)),
                     note="THE TRIGGER: joint trigger, 17.8 degrees about its own pin on the rig's fire frames 22-41 (the pin is the "
                          "joint's origin). Follows your finger."),
                "support"],
         stores=True,
         shot=dict(spread=(4.5, 5.0), damage=(15, 45), tics=16, first=0, pellets=30, fullauto=True),
         profiles=("benelli_m4",) * 4, suppressed=False, icon="BENNA0", slot=3, sel=1300, ammo="Shell",
         shotnote="benelli.zs:212: A_FireBullets(4.5, 5, 30, 15) aimed -- thirty pellets, 15 x 1d3 each -- and 16 tics to the next; "
                  "Breach's Benelli fires again while the trigger is held (FullAuto here). It is SEMI-AUTO: the bolt cycles itself on "
                  "every shot (the cycle's auto = onshot)."),
]


def part_block(g, p):
    pp = g["p"]
    L = []
    if p == "magazine":
        m = pp["mag"]
        L.append("# THE MAGAZINE: joint j_mag1. The axis is its own long axis, %.1f degrees off vertical in the gun's middle plane (a "
                 "magazine cannot turn in its well), the distance its length along it, %.2f, and a little to clear the well. The grab "
                 "is the floorplate." % (abs(__import__("math").degrees(__import__("math").atan2(m["axis"][0], -m["axis"][2]))), m["length"]))
        L += ["part magazine", "  role    = feed", "  subject = magazine", "  take    = no          # out by its button, in by the hand carrying one",
              "  joint   = j_mag1", "  grab       = " + v3(m["floorplate"]), "  grabradius = 3.0", "  dof", "    kind     = slide",
              "    axis     = " + v3(m["axis"]), "    distance = %.1f" % round(m["length"] + 0.5, 1), "    detach   = 0.9", "  end", "end"]
        return L
    if p == "support":
        s = list(pp["support"])
        if g.get("support_y") is not None:
            s[1] = g["support_y"]
        L.append("# Not a moving part: where the other hand holds -- %s." % pp["support_from"])
        L += ["part support", "  role    = support", "  subject = support", "  grab       = " + v3(s), "  grabradius = 3.0", "end"]
        return L
    L.append("# " + p["note"])
    L.append("part %s" % p["id"])
    if p.get("role"):
        L.append("  role    = %s" % p["role"])
    if p.get("subject"):
        L.append("  subject = %s" % p["subject"])
    if p.get("surface"):
        # A part may be driven by SURFACE instead of by its joint. Regeneration used to write the
        # joint back over a hand edit that had deliberately moved a part off it, so the reason for
        # the move travels with the part (surface_why) and the card keeps explaining itself.
        L += ["  # " + ln for ln in p.get("surface_why", ())]
        L.append("  surface = %s" % p["surface"])
    else:
        L.append("  joint   = %s" % p["joint"])
    if "grab" in p:
        grab = p["grab"] if p["grab"] is not None else pp["grab"]
        L += ["  grab       = " + v3(grab), "  grabradius = 3.0"]
    d = p["dof"]
    L += ["  dof", "    kind     = %s" % d["kind"]]
    L.append("    axis     = " + ", ".join("%g" % c for c in d["axis"]))
    if d["kind"] == "slide":
        L.append("    distance = %g" % d["distance"])
    else:
        L.append("    degrees  = %g" % d["degrees"])
        L.append("    pivot    = " + v3(d["pivot"]))
    if "detach" in d:
        L.append("    detach   = %g" % d["detach"])
    L += ["  end", "end"]
    return L


def card(g):
    pp, s, snd = g["p"], g["seat"], g["sounds"]
    L = ["", "", "# " + "=" * 60 + " %s -- %s HAND" % (g["title"].upper(), g["hand"].upper()),
         'weapon "%s"' % g["cls"], "  hand      = %s" % g["hand"], "  type      = %s" % g["type"],
         '  prop      = "%s"' % g["cls"].replace("WM_", "WM_Prop"), '  model     = "%s" "%s"' % (g["dir"], g["iqm"]),
         "  # " + g["cap_note"], "  capacity  = %d" % g["capacity"], '  magfamily = "%s"' % g["family"], "",
         "  # BREACH'S VIEW ARMS: the rig's own arms mesh, never drawn in a VR hand.", "  hidesurface = v_hands.bmp"]
    for j, why in g.get("hidejoints", []):
        L += ["  # " + why, "  hidejoint   = " + j]
    L += ["", "  # The front-most verts, centred%s; the bore points along the barrel." % (
              " (the silencer's end)" if g["key"] == "mk18s" else ""),
          "  muzzle    = " + v3(g.get("muzzle") or pp["muzzle"]), "  barrel    = " + v3(g.get("barrel", (1, 0, 0))), "",
          "  # The right side's surface at the port (Breach's rigs put the right on +y). Brass goes right, up, back.",
          "  ejectport = " + v3(pp["ejectport"]), "  ejectdir  = -0.3, 0.9, 0.4"]
    if g["mag"]:
        m = pp["mag"]
        L += ["", "  # THE LOOSE MAGAZINE: the rig's own, cut out at this frame, re-origined on its centroid (magcenter, the gun's space) and "
                  "turned so it leaves straight down (breach_extract.py); its surfaces carry their own textures, so no magskin. "
                  "magscale = the gun's %.3f x 0.34." % g["mag"]["scale"],
              '  magmodel  = "%s" "%s"' % (g["dir"], g["mag"]["model"]), "  magscale  = %.3f" % round(g["mag"]["scale"] * 0.34, 3),
              "  magcenter = " + v3(m["center"])]
    r = g["round_"]
    L += ["", '  roundmodel = "%s" "%s"' % (r[0], r[1]), '  roundskin  = "%s" "%s"' % (r[0], r[2]), "  roundscale = %g" % r[3], "",
          "  # Breach's own sounds (" + g["src"].split(":")[0] + "): its two fire layers as one, and the rest it plays."]
    order = [("firesound", "fire"), ("drysound", "dry"), ("magoutsound", "magout"), ("maginsound", "magin"), ("rackapexsound", "rackapex"),
             ("rackresetsound", "rackreset"), ("cycleoutsound", "cycleout"), ("cyclehomesound", "cyclehome"), ("loadsound", "load"),
             ("magdropsound", "magdrop"), ("casingsound", "casing")]
    for key, k in order:
        if k in snd:
            L.append('  %-14s = "%s"' % (key, snd[k]))
    L.append("end")
    if g.get("stores"):
        L += ["", "store tube", "  kind     = counted", "  capacity = 7", "  detach   = no", "end", "", "store chamber", "  kind  = slotted",
              "  slots = 1", "end"]
    for p in g["parts"]:
        L += [""] + part_block(g, p)
    if g.get("stores"):
        L += ["", "# SEMI-AUTO: the shot throws the bolt back and home -- eject the spent shell, feed the next from the tube -- and a hand "
                  "may rack it the same way. Empty, it locks open.",
              "cycle bolt", "  part     = bolt", "  outat    = 0.85", "  apex     = 0.95", "  onout    = eject",
              "  from     = chamber", "  onhome   = feed", "  feed     = tube", "  into     = chamber", "  return   = spring",
              "  holdopen = whenempty", "  auto     = onshot", "end", "",
              "# THE LOADING GATE, under the receiver where Breach's shutter is (joint shutter, centroid %s): one shell at a time up "
              "into the tube." % v3(pp.get("shutter", (14.34, 3.149, -5.038))),
              "load gate", "  into    = tube", "  at      = 14.340, 3.149, -6.038", "  size    = 2.5, 2.0, 2.0", "  subject = shell",
              "  dir     = 0, 0, 1", "end"]
    return L


def cls_block(g):
    sh, pr = g["shot"], g["profiles"]
    L = ["", "// " + "=" * 108, "// %s -- %s HAND. %s" % (g["title"].upper(), g["hand"].upper(), g["shotnote"]),
         "// Its card is WMCARD.breach_set; its looks are RS_Ballistics' own '%s' profiles -- round, flash, brass and recoil, one id%s." % (
             pr[0], " (its suppressed look: a faint glow at the can, gas out of the port, a quiet room)" if g["suppressed"] else ""),
         "// " + "=" * 108, "class %s : WM_Gun" % g["cls"], "{", T + "Default", T + "{"]
    if sh.get("pellets"):
        L.append(T * 2 + "WM_Gun.ShotPellets %d;" % sh["pellets"])
    L += [T * 2 + "WM_Gun.ShotSpread %g, %g;" % sh["spread"], T * 2 + "WM_Gun.ShotDamage %d, %d;" % sh["damage"],
          T * 2 + "WM_Gun.FireTics %d;" % sh["tics"]]
    if sh.get("first"):
        L.append(T * 2 + "WM_Gun.FirstShotsAccurate %d;" % sh["first"])
    if sh.get("fullauto"):
        L.append(T * 2 + "WM_Gun.FullAuto true;")
    if sh.get("altmode"):
        L += [T * 2 + 'WM_Gun.AltMode "%s";' % sh["altmode"], T * 2 + "WM_Gun.AltBurst %d;" % sh["burst"],
              T * 2 + "WM_Gun.AltBurstTics %d;" % sh["bursttics"]]
    L += [T * 2 + 'WM_Gun.RoundProfile "%s";' % pr[0], T * 2 + 'WM_Gun.FlashProfile "%s";' % pr[1],
          T * 2 + 'WM_Gun.EjectaProfile "%s";' % pr[2], T * 2 + 'WM_Gun.RecoilProfile "%s";' % pr[3]]
    if g.get("ammo"):
        L.append(T * 2 + 'Weapon.AmmoType1 "%s";' % g["ammo"])
    if g["hand"] == "off":
        L.append(T * 2 + "+WEAPON.OFFHANDWEAPON")
    L += [T * 2 + "Weapon.SelectionOrder %d;" % g["sel"], T * 2 + "Weapon.SlotNumber %d;" % g["slot"],
          T * 2 + 'Inventory.PickupMessage "%s";' % g["tag"], T * 2 + 'Tag "%s";' % g["tag"],
          T * 2 + "// Breach's own icon (graphics/%s.png): the weapon wheel shows AltHUDIcon first, then Icon." % g["icon"],
          T * 2 + 'Inventory.Icon "%s";' % g["icon"], T * 2 + 'Inventory.AltHUDIcon "%s";' % g["icon"], T + "}", "}",
          "class %s : WM_Prop {}" % g["cls"].replace("WM_", "WM_Prop")]
    return L


def modeldef_block(g):
    s = g["seat"]
    ref = "the Pistolet's (wm_off)" if s["prefix"] == "wm_off" else "the M4A3's (wm_main)"
    L = ["", "// %s -- %s HAND: BREACH's %s at %s. Seat: its trigger on %s trigger, pointing as that gun does, no rotation "
             "(tools/breach_seat.py); Scale %g." % (g["title"].upper(), g["hand"].upper(), g["iqm"], g["frame_note"], ref, s["scale"]),
         "Model %s" % g["cls"].replace("WM_", "WM_Prop"), "{", T + 'Path "%s"' % g["dir"], T + 'Model 0 "%s"' % g["iqm"]]
    for idx, f in g.get("extra", []):
        L.append(T + 'Model %d "%s"' % (idx, f))
    # x0.34 (1/2.9412): the seat table is pre-2026-09-25 hand units, MODELDEF is not. Without it a
    # regeneration silently draws every Breach gun 2.94 times too big. 4 dp because that is the
    # precision the shipped MODELDEF.txt carries, so re-running produces no diff at all.
    sc = round(s["scale"] * 0.34, 4)
    L += [T + "Scale %g %g %g" % (sc, sc, sc), T + "Offset %.4f %.4f %.4f" % tuple(c * 0.34 for c in s["offset"]),
          T + "PlacementCVars %s" % s["prefix"], T + "NOAUTOREVERSE", T + ("FollowOffHand" if g["hand"] == "off" else "FollowMainHand"),
          T + "FrameIndex WMPR A 0 %d" % s["frame"]]
    for idx, f in g.get("extra", []):
        L.append(T + "FrameIndex WMPR A %d %d" % (idx, s["frame"]))
    L.append("}")
    return L


def w(path, lines):
    open(M + path, "w", encoding="utf-8", newline="\n").write("\n".join(lines).rstrip("\n") + "\n")
    print("wrote %s (%d lines)" % (path, len(lines)))


# ---- zscript ----------------------------------------------------------------------------------------------------------
glock = ["// " + "=" * 108,
         "// THE BREACH GLOCK -- the first rigged IQM gun (the owner, 2026-09-15: \"Yes, start it\"; \"Let's make it 17\").",
         "// ZeroDoomThirty's BREACH Weapons (licenses/breach_weapons_CREDIT.txt): glockrerig.iqm, whose slide, trigger and magazine are",
         "// bones moved by their joints (WMCARD.breach). Its mesh, skin, sounds, icon and shot are Breach's; the seat and the card's",
         "// numbers are measured here (tools/). Its muzzle flash, smoke and brass are RS_Ballistics' -- nothing 2D but the icon.",
         "//",
         "// THE SHOT IS BREACH'S GLOCK: glock.zs fires A_FireBullets(3, 3, 1, 20) aimed -- one bullet, 3 degrees either way, 20 x 1d3 --",
         "// ready again 6 tics later, semi-auto; one bullet on a fresh pull flies dead on (FirstShotsAccurate 1). VR aims down the gun, so",
         "// the aimed (ADS) numbers. ITS LOOK IS ITS OWN: RS_Ballistics' 'glock17' round, flash, brass and recoil -- the showpiece 9mm.",
         "// " + "=" * 108, "", "class WM_BreachGlock : WM_Gun", "{", T + "Default", T + "{",
         T * 2 + "WM_Gun.ShotSpread 3.0, 3.0;", T * 2 + "WM_Gun.ShotDamage 20, 60;", T * 2 + "WM_Gun.FireTics 6;",
         T * 2 + "WM_Gun.FirstShotsAccurate 1;", T * 2 + 'WM_Gun.RoundProfile "glock17";', T * 2 + 'WM_Gun.FlashProfile "glock17";',
         T * 2 + 'WM_Gun.EjectaProfile "glock17";', T * 2 + 'WM_Gun.RecoilProfile "glock17";', T * 2 + "Weapon.SelectionOrder 150;",
         T * 2 + "Weapon.SlotNumber 2;", T * 2 + 'Inventory.PickupMessage "Glock";', T * 2 + 'Tag "Glock";',
         T * 2 + "// Breach's own icon (graphics/GLOKA0.png): the weapon wheel shows AltHUDIcon first, then Icon.",
         T * 2 + 'Inventory.Icon "GLOKA0";', T * 2 + 'Inventory.AltHUDIcon "GLOKA0";', T + "}", "}", "",
         "// WHAT IT IS DRAWN AS: MODELDEF binds glockrerig.iqm and the main hand to it.", "class WM_PropBreachGlock : WM_Prop {}"]
w("zscript/rs_modern/breach_glock.zs", glock)

setzs = ["// " + "=" * 108, "// THE BREACH SET (the owner, 2026-09-15: \"go on the rest of the set. Get the Modern set finished\").",
         "// Generated by tools/gen_breach_set.py -- edit its table, not this file. Each gun: its shot from Breach's own zscript, its",
         "// card in WMCARD.breach_set, its prop's MODELDEF block. Nothing 2D comes with them but Breach's icons; their muzzle flash,",
         "// smoke and brass are RS_Ballistics', and every gun has its own (RS_Ballistics 0cc3ff5: glock17_sup, kimber1911, mk18,",
         "// mk18_sup, hk416_sup, mcx_sup, g36c_sup, mp5, benelli_m4 -- one id across round, flash, ejecta and recoil).",
         "// " + "=" * 108]
for g in GUNS:
    setzs += cls_block(g)
w("zscript/rs_modern/breach_set.zs", setzs)

names = ["WM_BreachGlock"] + [g["cls"] for g in GUNS]
player = ["// " + "=" * 108,
          "// THE MODERN CLASS -- on the New Game menu whenever RS_Modern is loaded (its MAPINFO: AddPlayerClasses). Generated by",
          "// tools/gen_breach_set.py.",
          "//",
          "// A WM_Player (RS_VR_Weapons' loadout.zs), so everything that attaches to that class attaches to this one -- the hands and",
          "// body, the wrist HUD, the reload system, the ballistics, the grenade and ShieldSaw grants -- and every `is 'WM_Player'` holds.",
          "// ITS OWN START: the whole BREACH set, the Glock raised in the main hand and the Kimber in the off hand, both fists, 200 Clip",
          "// and 50 Shell. The engine starts a class's start items afresh at the first Player.StartItem it declares, so the Vanilla",
          "// arsenal is not carried. SLOTS as Breach's (player.zs:42-51): 2 the pistols, 3 the Benelli, 4 the rifles and the MP5 -- each",
          "// with the Vanilla guns a Doom pickup hands this class (weaponset.zs: WeaponSet 0) after them. StartGuns names the Glock and the",
          "// Kimber, so with wm_start_arsenal off the fresh-start trim keeps them (WM_WeaponSet.ApplyStart).",
          "// " + "=" * 108, "", "class RSM_PlayerModern : WM_Player", "{", T + "Default", T + "{",
          T * 2 + "WM_Player.WeaponSet 0;", T * 2 + 'WM_Player.StartGuns "WM_BreachGlock", "WM_BreachKimber";',
          T * 2 + 'Player.DisplayName "Modern";', "",
          T * 2 + 'Player.StartItem "WM_BreachGlock";', T * 2 + 'Player.StartItem "WM_BreachKimber";',
          T * 2 + 'Player.StartItem "RS_WorldFist";', T * 2 + 'Player.StartItem "RS_WorldFistOff";',
          T * 2 + 'Player.StartItem "Clip", 200;', T * 2 + 'Player.StartItem "Shell", 50;']
for n in names:
    if n not in ("WM_BreachGlock", "WM_BreachKimber"):
        player.append(T * 2 + 'Player.StartItem "%s";' % n)
player += ["",
           T * 2 + 'Player.WeaponSlot 2, "WM_BreachGlock", "WM_BreachGlockS", "WM_BreachKimber", "WM_M4A3", "WM_Pistolet";',
           T * 2 + 'Player.WeaponSlot 3, "WM_BreachBenelli", "WM_PumpM37", "WM_PumpDoom", "WM_SSG", "WM_AssaultShotgun", "WM_BullpupPump";',
           T * 2 + 'Player.WeaponSlot 4, "WM_BreachMK18", "WM_BreachMK18S", "WM_BreachHK416S", "WM_BreachMCX", "WM_BreachG36C", "WM_BreachMP5", '
                   '"WM_Moonlight", "WM_Sunset", "WM_ColaRevolver";',
           T + "}", "}"]
w("zscript/rs_modern/player.zs", player)

w("zscript.txt", ['version "5.0.0"', "",
                  "// RS_Modern -- modern weapon sets for the VR reload system (the owner, 2026-09-15: \"RS_Weapons_Vanilla, RS_Weapons_VanillaPlus,",
                  "// RS_Modern -- and every pk3 you load would add a selectable class from the new game menu\"). Each gun is a WM_Gun with its card",
                  "// (WMCARD.*) and its prop; the Modern class starts with them. Loads AFTER RS_VR_Reload (WM_Gun, WM_Prop, the cards) and",
                  "// RS_VR_Weapons (WM_Player). Paths are this package's own (zscript/rs_modern/).", "",
                  '#include "zscript/rs_modern/breach_glock.zs"', '#include "zscript/rs_modern/breach_set.zs"',
                  '#include "zscript/rs_modern/player.zs"'])

# ---- cards ------------------------------------------------------------------------------------------------------------
cards = ["# " + "=" * 116,
         "# WMCARD.breach_set -- the rest of ZeroDoomThirty's BREACH set (the owner, 2026-09-15: \"go on the rest of the set\"). The Glock's",
         "# card is WMCARD.breach. Generated by tools/gen_breach_set.py -- edit its table, not this file.",
         "#",
         "# Every gun is a rigged IQM whose moving parts are JOINTS (`joint = ...`), moved by the engine's bone drive; the rig's own view arms",
         "# are hidden (`hidesurface`), and anything the animation parks away from the gun on the drawn frame is too (`hidejoint`).",
         "# EVERY POINT IS MEASURED off the frame the prop draws, skinned as the renderer skins it (tools/breach_points.py; tools/points/<gun>",
         "# .json), in the file's own axes: x toward the muzzle, y across (+y the gun's right, where Breach's right hand is), z up. A gun with",
         "# no trigger bone takes its trigger from Breach's right index fingertip plus the offset measured on the Glock, whose trigger is a",
         "# bone -- which lands each rifle's on its bore's centre line to 0.15. A support grab is Breach's own left hand. Grab radii are MAP",
         "# units. No mechanism and no verbs on a magazine gun: its action cycle and magazine swap are synthesised from `role = action` and",
         "# `role = feed`, as the pistols' and the M16's are.",
         "# " + "=" * 116]
for g in GUNS:
    cards += card(g)
w("WMCARD.breach_set", cards)

# ---- MODELDEF ---------------------------------------------------------------------------------------------------------
md = ["// RS_Modern -- what its guns are drawn as. Generated by tools/gen_breach_set.py (the Glock's block as it was written by hand).", "",
      "// THE BREACH GLOCK -- MAIN HAND: glockrerig.iqm at frame 0, Breach's Ready frame, standing straight. Mesh 0 is Breach's view arms",
      "// (hidden by its card). Seat: its trigger on the M4A3's (wm_main), pointing as the M4A3 does, no rotation; Scale 1.145: a Glock 17",
      "// (202 mm) against the M4A3's in-hand length as a 1911 (216 mm) -- the scale every Breach rig drawn at the Glock's size shares.",
      "Model WM_PropBreachGlock", "{", T + 'Path "models/breach/glock"', T + 'Model 0 "glockrerig.iqm"', T + 'SurfaceSkin 0 1 "skin.png"',
      # Hand-written block, so the x0.34 in modeldef_block cannot reach it: these are that same
      # seat (1.145, -6.565 16.154 -0.233) already converted. The comment above still says 1.145
      # on purpose -- that is the seat, and it is what breach_seat.py would print for it again.
      T + "Scale 0.3893 0.3893 0.3893", T + "Offset -2.2321 5.4924 -0.0792", T + "PlacementCVars wm_main", T + "NOAUTOREVERSE",
      T + "FollowMainHand", T + "FrameIndex WMPR A 0 0", "}"]
for g in GUNS:
    md += modeldef_block(g)
w("MODELDEF.txt", md)

# ---- SNDINFO ----------------------------------------------------------------------------------------------------------
snd = ["// RS_Modern -- its guns' sounds: BREACH Weapons' own (licenses/breach_weapons_CREDIT.txt). Generated by tools/gen_breach_set.py.",
       "// A <gun>_fire.wav is that gun's two Breach fire layers mixed into one mono file (tools/make_breach_sounds.py) -- a card has one",
       "// fire sound. Everything else is Breach's file as it was.", "",
       "// THE GLOCK", "rsm/breachglock/fire       sounds/breach/glockfire.wav", "rsm/breachglock/magout     sounds/breach/clipout2.wav",
       "rsm/breachglock/magin      sounds/breach/clipin2.wav", "rsm/breachglock/slideback  sounds/breach/slidebk.wav",
       "rsm/breachglock/slidefwd   sounds/breach/sliderel.wav",
       "$random rsm/breachglock/casing { rsm/breachglock/casing1 rsm/breachglock/casing2 rsm/breachglock/casing3 }",
       "rsm/breachglock/casing1    sounds/breach/hshell1.wav", "rsm/breachglock/casing2    sounds/breach/hshell2.wav",
       "rsm/breachglock/casing3    sounds/breach/hshell3.wav", "", "// SHARED BY THE SET"]
for s in ("click", "clipout", "clipin", "cmagout", "cmagin", "boltback", "boltclose", "pump1", "lshell1", "sshell1"):
    snd.append("rsm/breach/%-14s sounds/breach/%s.wav" % (s, s))
snd += ["", "// EACH GUN'S SHOT"]
for g in GUNS:
    snd.append("rsm/breach%s/fire %s sounds/breach/%s_fire.wav" % (g["key"], " " * max(1, 10 - len(g["key"])), g["key"]))
w("SNDINFO.txt", snd)

# ---- credit -----------------------------------------------------------------------------------------------------------
made = {"glockfire.wav", "wm_breachglock_mag.md3"} | {"%s_fire.wav" % g["key"] for g in GUNS} | {"wm_breach%s_mag.md3" % d for d in ("glocksil", "kimber", "mk18", "hk416", "mcx", "g36", "mp5")}
cr = ["BREACH Weapons -- by ZeroDoomThirty (initial release 8 September 2026)",
      "https://www.moddb.com/mods/breach2    https://www.youtube.com/@Zerodoom30", "",
      "Used in RS_Modern -- part of a private VR build that is not distributed -- at the owner's direction, 2026-09-15, for the BREACH set:",
      "the Glock, the suppressed Glock, the Kimber, the MK18 and suppressed MK18, the suppressed HK416, MCX and G36C, the MP5 and the",
      "Benelli M4 (WMCARD.breach, WMCARD.breach_set, zscript/rs_modern/). Their shots, rates, capacities and sounds follow Breach's zscript.",
      "No 2D effect art is used: Breach's muzzle flash, smoke, tracer and impact sprites stay out. Its weapon icons are used.", "",
      "From Breach, unchanged (sounds and icons only gained a file extension; models keep their folder under models/breach/):"]
made_lines = []
for root in ("models/breach", "sounds/breach", "graphics"):
    for dp, dn, fn in os.walk(M + root):
        for f in sorted(fn):
            rel = os.path.relpath(os.path.join(dp, f), M).replace("\\", "/")
            (made_lines if f in made else cr).append("  " + rel)
cr += ["", "MADE HERE from Breach's files (tools/): the loose magazines, cut from each rig (breach_extract.py, extract_mag.py); each gun's",
       "fire sound, Breach's two layers mixed into one (make_breach_sounds.py, make_sounds.py):"] + made_lines
cr += ["", "Breach's README states no licence. Ask the author before anything here is shared outside this build."]
w("licenses/breach_weapons_CREDIT.txt", cr)

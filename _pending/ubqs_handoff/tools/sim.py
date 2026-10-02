#!/usr/bin/env python3
"""Offline timeline sim of the UBQS world-layer blade glow vs the live (hand-layer) saber.  (v3: zero drift)

Engine model (QZD 17.3 source, verified):
  * frames at FPS (90). Each frame: I_SetFrameTime(T); run every tic k with k*TT <= T (P_Ticker:
    ClearInterpolation on all actors -> Prev=Pos, PrevAngles=Angles; then the player's Tick -> saber
    DoEffect -> glow placed); then render: OpenXR SetUp writes AttackPos = hand(T) (read by the NEXT tic),
    the glow is drawn at lerp(Prev, Pos, f), f = frac(T/TT); yaw/pitch lerped with deltaangle.
  * a tic run in frame T reads the hand sampled at the PREVIOUS frame (T - 1/FPS); the hand layer draws hand(T).
Predictors:
  none -- the sample as is.
  p2   -- phase 2 (lead 1, half the acceleration term, braking damp).
  p3   -- v3 "zero drift" == UBQS_SaberBase.GlowPredict now: a pure function of the last 3 samples (+ one
          hysteresis bit): deadband (lead 0 + interpolation cleared) when still, lead ramped in with speed,
          lead 0 + interpolation cleared on a stop / reversal / hard braking, core fade from speed + accel.
Metrics (after a 0.5 s settle): angle error RMS / max of the drawn glow vs the live blade; ghost = max over
frames of (angle error * the core's alpha: the visible white second blade); overshoot = how far (deg) the drawn
glow ever goes past the furthest the live blade ever goes (the stop point / the turnaround).
"""
import math
import numpy as np

FPS, TR = 90.0, 35.0
TT = 1.0 / TR
TICMS = 1000.0 * TT
AGE = 1000.0 / 90.0              # ms: AttackPos is a frame old (assumed 90 Hz) -- GLOW_AGE
MAX_ANG, MAX_LIN = 35.0, 24.0    # GLOW_MAXANG / GLOW_MAXLIN
ACC = 0.5                        # GLOW_ACC
# v3 thresholds (deg/s, map units/s) -- the zscript's GLOW_* constants
STILL_IN_W, STILL_IN_V = 6.0, 3.0        # enter the deadband below both
STILL_OUT_W, STILL_OUT_V = 12.0, 6.0     # leave it above either
RAMP_W, RAMP_V = 60.0, 30.0              # lead fully in by these speeds (smoothstep from the out thresholds)
STOP = 0.85                               # speed below STOP x the last step's (or reversed) = a stop: lead 0, no slide
FADE_W0, FADE_W1 = 200.0, 500.0          # core fades with angular speed between these
FADE_A0, FADE_A1 = 100.0, 300.0          # ... or with the change of angular velocity between samples


def norm(v):
    return v / np.linalg.norm(v)


def rot(v, axis, ang):
    a = math.radians(ang)
    return v * math.cos(a) + np.cross(axis, v) * math.sin(a) + axis * np.dot(axis, v) * (1 - math.cos(a))


def rotvec(a, b):
    ax = np.cross(a, b)
    sn = np.linalg.norm(ax)
    if sn < 1e-9:
        return np.zeros(3)
    return ax / sn * math.degrees(math.atan2(sn, float(np.dot(a, b))))


def dang(a, b):
    return (b - a + 180.0) % 360.0 - 180.0


def angles(d, prev_yaw):
    yaw = math.degrees(math.atan2(d[1], d[0]))
    pit = math.degrees(math.acos(max(-1, min(1, d[2]))))
    if prev_yaw is not None and abs(dang(prev_yaw, yaw + 180.0)) < abs(dang(prev_yaw, yaw)):
        yaw, pit = yaw + 180.0, -pit
    return yaw, pit


def from_angles(yaw, pit):
    y, p = math.radians(yaw), math.radians(pit)
    return np.array([math.sin(p) * math.cos(y), math.sin(p) * math.sin(y), math.cos(p)])


def ss(a, b, x):
    t = min(max((x - a) / (b - a), 0.0), 1.0)
    return t * t * (3 - 2 * t)


AXIS = norm(np.array([0.2, 0.3, 1.0]))
D0 = norm(norm(np.cross(AXIS, np.array([1.0, 0, 0]))) + np.array([0, 0, 0.8]))


def hand_from(theta):
    """a hand whose blade turns theta(t) degrees about AXIS; the base rides the forearm's arc"""
    def hand(t):
        a = theta(t)
        return (np.array([0.0, 0.0, 40.0]) + rot(np.array([16.0, 0.0, 0.0]), AXIS, a * 0.6),
                norm(rot(D0, AXIS, a)))
    return hand


def theta_of(d):
    """the in-plane angle of a direction (about AXIS, from D0)"""
    e1 = norm(D0 - AXIS * np.dot(D0, AXIS))
    e2 = np.cross(AXIS, e1)
    return math.degrees(math.atan2(float(np.dot(d, e2)), float(np.dot(d, e1))))


# ---- predictors: (hist, lead, frac, st) -> (base, dir, snap, coreFade) ----------------------------------
def pred_none(hist, lead, frac, st):
    return hist[-1][1], hist[-1][2], False, 0.0


def pred_p2(hist, lead, frac, st):
    (t2, b2, d2) = hist[-1]
    if len(hist) < 2:
        return b2, d2, False, 0.0
    (t1, b1, d1) = hist[-2]
    dt = max(t2 - t1, 1.0)
    tau = lead * ((1.0 - frac) * TICMS + AGE)
    v = (b2 - b1) / dt
    w = rotvec(d1, d2) / dt
    if len(hist) >= 3:
        t0, b0, d0 = hist[-3]
        dt0 = max(t1 - t0, 1.0)
        v0, w0 = (b1 - b0) / dt0, rotvec(d0, d1) / dt0
        vn, wn = np.linalg.norm(v), np.linalg.norm(w)
        h = 0.5 * (dt + dt0)
        v = v + (v - v0) * (tau * 0.5 * ACC / h)
        w = w + (w - w0) * (tau * 0.5 * ACC / h)
        if wn < np.linalg.norm(w0) * 0.6:
            w = w * wn / (np.linalg.norm(w0) * 0.6)
        if vn < np.linalg.norm(v0) * 0.6:
            v = v * vn / (np.linalg.norm(v0) * 0.6)
    return extrap(b2, d2, v, w, tau) + (False, 0.0)


def extrap(b, d, v, w, tau):
    step = v * tau
    if np.linalg.norm(step) > MAX_LIN:
        step = step / np.linalg.norm(step) * MAX_LIN
    rv = w * tau
    a = np.linalg.norm(rv)
    pd = d if a < 1e-3 else norm(rot(d, rv / a, min(a, MAX_ANG)))
    return b + step, pd


def pred_p3(hist, lead, frac, st):
    """== GlowPredict (v3). st = {'still': bool} -- the only carried bit besides the samples."""
    (t2, b2, d2) = hist[-1]
    if len(hist) < 2:
        return b2, d2, False, 0.0
    (t1, b1, d1) = hist[-2]
    dt = max(t2 - t1, 1.0)
    v = (b2 - b1) / dt                       # per ms
    w = rotvec(d1, d2) / dt
    ws, vs = np.linalg.norm(w) * 1000.0, np.linalg.norm(v) * 1000.0
    snap = False
    if st["still"]:
        if ws > STILL_OUT_W or vs > STILL_OUT_V:
            st["still"] = False
    elif ws < STILL_IN_W and vs < STILL_IN_V:
        st["still"] = True
        snap = True
    if st["still"]:
        return b2, d2, snap, 0.0
    fade = ss(FADE_W0, FADE_W1, ws)
    tau = lead * max(ss(STILL_OUT_W, RAMP_W, ws), ss(STILL_OUT_V, RAMP_V, vs)) * ((1.0 - frac) * TICMS + AGE)
    lin_cap, ang_cap = MAX_LIN, MAX_ANG
    if len(hist) >= 3:
        t0, b0, d0 = hist[-3]
        dt0 = max(t1 - t0, 1.0)
        v0, w0 = (b1 - b0) / dt0, rotvec(d0, d1) / dt0
        ws0, vs0 = np.linalg.norm(w0) * 1000.0, np.linalg.norm(v0) * 1000.0
        fade = max(fade, ss(FADE_A0, FADE_A1, np.linalg.norm(w - w0) * 1000.0))
        h = 0.5 * (dt + dt0)
        # a reversal, or nearly stopped from a real speed: lead 0 this tic, and no slide from the last pose
        if (ws0 > STILL_OUT_W and (np.dot(w, w0) <= 0 or ws < STOP * ws0)) or \
           (vs0 > STILL_OUT_V and (np.dot(v, v0) <= 0 or vs < STOP * vs0)):
            return b2, d2, True, fade
        # braking: never lead past where it can still get to -- the stopping distance at this deceleration
        wn, wn0 = ws / 1000.0, ws0 / 1000.0
        if wn < wn0:
            ang_cap = min(ang_cap, wn * wn / (2.0 * (wn0 - wn) / h))
        else:
            w = w + (w - w0) * (tau * 0.5 * ACC / h)
        vn, vn0 = vs / 1000.0, vs0 / 1000.0
        if vn < vn0:
            lin_cap = min(lin_cap, vn * vn / (2.0 * (vn0 - vn) / h))
        else:
            v = v + (v - v0) * (tau * 0.5 * ACC / h)
    step = v * tau
    if np.linalg.norm(step) > lin_cap:
        step = step / np.linalg.norm(step) * lin_cap
    rv = w * tau
    a = np.linalg.norm(rv)
    pd = d2 if a < 1e-3 else norm(rot(d2, rv / a, min(a, ang_cap)))
    return b2 + step, pd, False, fade


def simulate(hand, pred, lead=1.0, secs=3.0, after=0.5, noise=(0.0, 0.0), seed=1):
    rng = np.random.default_rng(seed)
    st = {"still": False}
    sample = hand(0.0)
    hist = []
    pos = prev = ang = pang = None
    fade = 0.0
    tic = 0
    ea, gh = [], []
    # overshoot: past the furthest the live blade EVER goes either way (every case is built so that is the
    # stop point / the turnaround), so leading into where the blade is about to go never counts
    ths = [theta_of(hand(n / 1000.0)[1]) for n in range(int(secs * 1000))]
    reach_hi, reach_lo = max(ths), min(ths)
    over = 0.0
    for n in range(1, int(secs * FPS)):
        T = n / FPS
        while tic * TT <= T:
            prev, pang = pos, ang                            # ClearInterpolation
            b, d = sample
            if not hist or T * 1000.0 - hist[-1][0] >= 4.0:
                hist = (hist + [(T * 1000.0, b, d)])[-3:]
            f = T * TR - math.floor(T * TR)
            pb, pd, snap, fade = pred(hist, lead, f, st)
            pos = (pb, pd)
            ang = angles(pd, ang[0] if ang else None)
            if prev is None or snap:
                prev, pang = pos, ang
            tic += 1
        f = T * TR - math.floor(T * TR)
        rd = from_angles(pang[0] + dang(pang[0], ang[0]) * f, pang[1] + dang(pang[1], ang[1]) * f)
        lb, ld = hand(T)
        sample = (lb, ld)
        if noise[0] > 0:
            ax = norm(rng.standard_normal(3))
            sample = (lb + rng.standard_normal(3) * noise[1], norm(rot(ld, ax, rng.standard_normal() * noise[0])))
        if T > after:
            e = math.degrees(math.acos(max(-1, min(1, float(np.dot(rd, ld))))))
            ea.append(e)
            gh.append(e * (1.0 - fade))
            tr = theta_of(rd)
            over = max(over, tr - reach_hi, reach_lo - tr)
    ea = np.array(ea)
    return dict(rms=math.sqrt((ea ** 2).mean()), mx=ea.max(), ghost=max(gh), over=max(over, 0.0))


# ---- the hands --------------------------------------------------------------------------------------------
def sine(f, A):
    return lambda t: A * math.sin(2 * math.pi * f * t)


def instant_stop(speed, t_stop, sweep=120.0):
    """held, then a sweep of `sweep` deg at constant speed (deg/s) frozen dead at t_stop: the worst stop"""
    t0 = t_stop - sweep / speed
    return lambda t: speed * (min(max(t, t0), t_stop) - t0) - sweep / 2


def minjerk_stop(speed, t_stop, dur, sweep=120.0):
    """the same at constant speed, then a minimum-jerk stop over `dur` s (a real arm brakes over ~60-120 ms)"""
    t0 = t_stop - sweep / speed

    def th(t):
        if t <= t_stop:
            return speed * (max(t, t0) - t0) - sweep / 2
        u = min((t - t_stop) / dur, 1.0)
        # velocity v(u) = speed * (1 - (10u^3 - 15u^4 + 6u^5)); its integral
        return sweep / 2 + speed * dur * (u - (2.5 * u ** 4 - 3 * u ** 5 + u ** 6))
    return th


def triangle(speed, A):
    """instant reversals at +-A, constant speed between: the worst reversal"""
    P = 4 * A / speed
    def th(t):
        x = (t % P) / P
        return A * (4 * x - 1 if x < 0.5 else 3 - 4 * x)
    return th


def still(A=10.0):
    return lambda t: A


def worst(make, pred, lead, **kw):
    """the worst over 8 phases of the event within a tic (stops/reversals can land anywhere in it)"""
    rs = [simulate(hand_from(make(1.0 + j * TT / 8.0)), pred, lead, **kw) for j in range(8)]
    return {k: max(r[k] for r in rs) for k in rs[0]}


def main():
    cases = [
        ("rest (exact pose)", lambda o: still(), {}),
        ("rest + tracker noise 0.2deg *", lambda o: still(), {"noise": (0.2, 0.05)}),
        ("slow  0.5Hz +-30 (94 deg/s)", lambda o: sine(0.5, 30), {}),
        ("med   1.5Hz +-60 (565 deg/s)", lambda o: sine(1.5, 60), {}),
        ("fast  3.0Hz +-80 (1508 deg/s)", lambda o: sine(3.0, 80), {}),
        ("stop instant @565 (w/8)", lambda o: instant_stop(565.0, o), {"after": 0.93}),
        ("stop instant @1508 (w/8)", lambda o: instant_stop(1508.0, o, 240.0), {"after": 0.93}),
        ("stop min-jerk 80ms @565 (w/8)", lambda o: minjerk_stop(565.0, o, 0.08), {"after": 0.93}),
        ("stop min-jerk 80ms @1200 (w/8)", lambda o: minjerk_stop(1200.0, o, 0.08, 240.0), {"after": 0.93}),
        ("reversal instant @565", lambda o: triangle(565.0, 50), {}),
    ]
    preds = [("none", pred_none, 1.0), ("phase2 L1", pred_p2, 1.0), ("v3 L1", pred_p3, 1.0),
             ("v3 L0.72", pred_p3, 0.72)]
    print("drawn glow vs live blade, 90 Hz frames / 35 Hz tics. deg: RMS / max error; ghost = max(error x core")
    print("alpha) = the visible white second blade; over = max overshoot past the furthest the live blade ever goes.")
    print("(* noise: 'over' there is just the tracker noise itself -- 'none' shows the same)")
    print("%-33s %-10s %7s %7s %7s %7s" % ("case", "predictor", "RMS", "max", "ghost", "over"))
    for name, mk, kw in cases:
        for pn, p, L in preds:
            r = worst(mk, p, L, **kw) if "w" in name.split("(")[-1] else simulate(hand_from(mk(1.0)), p, L, **kw)
            print("%-33s %-10s %7.3f %7.3f %7.3f %7.3f" % (name, pn, r["rms"], r["mx"], r["ghost"], r["over"]))
        print()


if __name__ == "__main__":
    main()

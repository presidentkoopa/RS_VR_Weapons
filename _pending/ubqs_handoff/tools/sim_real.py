#!/usr/bin/env python3
"""sim_real.py -- the glow timeline (as sim.py) on REALISTIC input, for build 50's retune.

Input: 90 Hz frames (tics land 2 or 3 frames apart), tracker noise per frame (gaussian, default 0.2 deg on the
direction and 0.5 mm = 0.017 map units on the position), a long human-like session made of
  * min-jerk point-to-point moves (random amplitude 15-110 deg, 0.15-0.5 s, pauses 0.05-0.5 s between),
  * sinusoid sweeps (0.6-2 Hz, +-20-70 deg, ~2.5 s), and
  * twirls (the blade turning in a vertical plane at 500-900 deg/s for ~1 s, through the vertical).
The hand (wrist) moves too (min-jerk, +-8 units); the blade base (emitter) = wrist + dir * 4 units.
Predictors: none, b49 (sim.pred_p3, lead 0.75), b50 (pred_b50 here == GlowPredict in build 50).
Reported: angle error (deg) and BASE error (map units) of the drawn glow vs the live blade, RMS / p99 / max;
how often the stop/reversal detector fires while moving, how many of those are FALSE (the true motion
was not braking below the threshold nor reversing), and the lead actually used (mean, while moving).
"""
import math
import sys

import numpy as np

import sim as S

EMIT = 4.0


def mj(u):
    u = np.clip(u, 0, 1)
    return 10 * u ** 3 - 15 * u ** 4 + 6 * u ** 5


def dir_of(az, el):
    az, el = np.radians(az), np.radians(el)
    return np.stack([np.cos(el) * np.cos(az), np.cos(el) * np.sin(az), np.sin(el)], axis=-1)


def session(secs=40.0, seed=7):
    """per-ms arrays: dirs (N,3), wrist (N,3); and a per-ms 'kind' label"""
    rng = np.random.default_rng(seed)
    N = int(secs * 1000)
    az = np.zeros(N); el = np.zeros(N); wr = np.zeros((N, 3)); kind = np.zeros(N, int)
    twd = np.full((N, 3), np.nan)
    t = 0
    caz, cel, cw = 0.0, 40.0, np.zeros(3)
    while t < N:
        r = rng.random()
        if r < 0.55:                                   # point to point, then a pause
            dur = int(rng.uniform(150, 500)); amp = rng.uniform(15, 110); ang = rng.uniform(0, 2 * math.pi)
            naz = float(np.clip(caz + amp * math.cos(ang), -80, 80)); nel = float(np.clip(cel + amp * math.sin(ang), -30, 85))
            nw = np.clip(cw + rng.uniform(-8, 8, 3), -10, 10)
            for i in range(dur):
                if t + i >= N: break
                m = mj((i + 1) / dur)
                az[t + i] = caz + (naz - caz) * m; el[t + i] = cel + (nel - cel) * m
                wr[t + i] = cw + (nw - cw) * m; kind[t + i] = 1
            t += dur; caz, cel, cw = naz, nel, nw
            pause = int(rng.uniform(50, 500))
            for i in range(pause):
                if t + i >= N: break
                az[t + i], el[t + i], wr[t + i], kind[t + i] = caz, cel, cw, 0
            t += pause
        elif r < 0.85:                                 # a sweep
            f = rng.uniform(0.6, 2.0); A = rng.uniform(20, 70); dur = int(2500)
            ax = rng.random() < 0.5
            for i in range(dur):
                if t + i >= N: break
                ramp = min(1.0, i / 150.0, (dur - i) / 150.0)
                s_ = A * math.sin(2 * math.pi * f * i / 1000.0) * ramp
                az[t + i] = caz + (s_ if ax else 0); el[t + i] = cel + (0 if ax else s_)
                wr[t + i] = cw + np.array([0, s_ * 0.08, 0]); kind[t + i] = 2
            t += dur
        else:                                          # a twirl in a vertical plane, through the vertical
            w = rng.uniform(500, 900); dur = 1000
            th0 = math.radians(cel)
            a0 = math.radians(caz)
            for i in range(dur):
                if t + i >= N: break
                ramp = mj(min(i, 200) / 200.0) * 200 / 1000.0 if i < 200 else (i - 100) / 1000.0
                th = th0 + math.radians(w) * ramp
                twd[t + i] = [math.cos(th) * math.cos(a0), math.cos(th) * math.sin(a0), math.sin(th)]
                az[t + i], el[t + i], wr[t + i], kind[t + i] = caz, cel, cw, 3
            # end where it ended
            d = twd[min(t + dur, N) - 1]
            caz = math.degrees(math.atan2(d[1], d[0])); cel = math.degrees(math.asin(np.clip(d[2], -1, 1)))
            t += dur
    D = dir_of(az, el)
    m = ~np.isnan(twd[:, 0])
    D[m] = twd[m]
    base = wr + D * EMIT + np.array([0, 0, 40.0])
    return D, base, kind


def angspeed(D, i, dt_ms):
    j = max(i - dt_ms, 0)
    c = float(np.clip(np.dot(D[i], D[j]), -1, 1))
    return math.degrees(math.acos(c)) / max(dt_ms, 1) * 1000.0


# ---- build 50's predictor (== UBQS_SaberBase.GlowPredict) --------------------------------------------------
P = dict(STILL_IN_W=6.0, STILL_IN_V=3.0, STILL_OUT_W=12.0, STILL_OUT_V=6.0, RAMP_W=60.0, RAMP_V=30.0,
         STOP=0.6, STOP_MINW=90.0, STOP_MINV=20.0, FADE_W0=200.0, FADE_W1=500.0, FADE_A0=100.0, FADE_A1=300.0)


def pred_b50(hist, lead, frac, st, p=P):
    """returns base, dir, snapAng, snapLin, fade, info{fireA, fireL, k}"""
    (t2, b2, d2) = hist[-1]
    info = {"fireA": False, "fireL": False, "k": 0.0}
    if len(hist) < 2:
        return b2, d2, False, False, 0.0, info
    (t1, b1, d1) = hist[-2]
    dt = max(t2 - t1, 1.0)
    v = (b2 - b1) / dt
    w = S.rotvec(d1, d2) / dt
    ws, vs = np.linalg.norm(w) * 1000.0, np.linalg.norm(v) * 1000.0
    snap = False
    if st["still"]:
        if ws > p["STILL_OUT_W"] or vs > p["STILL_OUT_V"]:
            st["still"] = False
    elif ws < p["STILL_IN_W"] and vs < p["STILL_IN_V"]:
        st["still"] = True
        snap = True
    if st["still"]:
        return b2, d2, snap, snap, 0.0, info
    fade = S.ss(p["FADE_W0"], p["FADE_W1"], ws)
    tn = (1.0 - frac) * S.TICMS + S.AGE
    kA = lead * S.ss(p["STILL_OUT_W"], p["RAMP_W"], ws)
    kL = lead * max(S.ss(p["STILL_OUT_V"], p["RAMP_V"], vs), S.ss(p["STILL_OUT_W"], p["RAMP_W"], ws))
    angCap, linCap = S.MAX_ANG, S.MAX_LIN
    snapA = snapL = False
    if len(hist) >= 3:
        t0, b0, d0 = hist[-3]
        dt0 = max(t1 - t0, 1.0)
        v0, w0 = (b1 - b0) / dt0, S.rotvec(d0, d1) / dt0
        ws0, vs0 = np.linalg.norm(w0) * 1000.0, np.linalg.norm(v0) * 1000.0
        fade = max(fade, S.ss(p["FADE_A0"], p["FADE_A1"], np.linalg.norm(w - w0) * 1000.0))
        h = 0.5 * (dt + dt0)
        # the turn and the hand are judged APART: a stopping turn does not stop the base's lead
        if ws0 > p["STOP_MINW"] and (np.dot(w, w0) <= 0 or ws < p["STOP"] * ws0):
            snapA = True
            info["fireA"] = True
        if vs0 > p["STOP_MINV"] and (np.dot(v, v0) <= 0 or vs < p["STOP"] * vs0):
            snapL = True
            info["fireL"] = True
        wn, wn0, vn, vn0 = ws / 1000.0, ws0 / 1000.0, vs / 1000.0, vs0 / 1000.0
        if not snapA:
            if wn < wn0:
                angCap = min(angCap, wn * wn / (2.0 * (wn0 - wn) / h))
            else:
                w = w + (w - w0) * (tn * kA * 0.5 * S.ACC / h)
        if not snapL:
            if vn < vn0:
                linCap = min(linCap, vn * vn / (2.0 * (vn0 - vn) / h))
            else:
                v = v + (v - v0) * (tn * kL * 0.5 * S.ACC / h)
    info["k"] = kA if not snapA else 0.0
    pb, pd = b2, d2
    if not snapL:
        step = v * kL * tn
        n = np.linalg.norm(step)
        if n > linCap:
            step = step / n * linCap
        pb = b2 + step
    if not snapA:
        rv = w * kA * tn
        a = np.linalg.norm(rv)
        if a > 1e-3:
            pd = S.norm(S.rot(d2, rv / a, min(a, angCap)))
    return pb, pd, snapA, snapL, fade, info


def wrap_old(pred):
    def f(hist, lead, frac, st):
        b, d, snap, fade = pred(hist, lead, frac, st)
        return b, d, snap, snap, fade, {"fireA": snap and not st["still"], "fireL": False, "k": 0.0}
    return f


def run(D, B, pred, lead, noise=(0.2, 0.017), seed=3, p=None):
    rng = np.random.default_rng(seed)
    N = len(D)
    st = {"still": False}
    hist = []
    pos = prev = ang = pang = None
    sample = (B[0], D[0])
    tic = 0
    ea, eb, fires, false_fires, moving, ks = [], [], 0, 0, 0, []
    hidx = []
    sample_i = 0
    for n in range(1, int(N / 1000.0 * S.FPS) - 1):
        T = n / S.FPS
        while tic * S.TT <= T:
            prev, pang = pos, ang
            b, d = sample
            if not hist or T * 1000.0 - hist[-1][0] >= 4.0:
                hist = (hist + [(T * 1000.0, b, d)])[-3:]
                hidx = (hidx + [sample_i])[-3:]
            f = T * S.TR - math.floor(T * S.TR)
            out = pred(hist, lead, f, st) if p is None else pred(hist, lead, f, st, p)
            pb, pd, sA, sL, fade, info = out
            # truth at the sample times: was the turn really braking below the line / reversing?
            i2 = hidx[-1]
            i1 = hidx[-2] if len(hidx) > 1 else i2
            tws = angspeed(D, i2, max(i2 - i1, 1))
            if tws > 60.0:
                moving += 1
                if info["fireA"]:
                    fires += 1
                    i0 = hidx[-3] if len(hidx) > 2 else i1
                    tws0 = angspeed(D, i1, max(i1 - i0, 1))
                    wa = S.rotvec(D[i0], D[i1]); wb = S.rotvec(D[i1], D[i2])
                    thr = p["STOP"] if p is not None else S.STOP
                    really = np.dot(wa, wb) <= 0 or tws < thr * tws0
                    if not really:
                        false_fires += 1
                ks.append(info["k"])
            pos = (pb, pd)
            ang = S.angles(pd, ang[0] if ang else None)
            if prev is None:
                prev, pang = pos, ang
            else:
                if sA:
                    pang = ang
                if sL:
                    prev = (pos[0], prev[1])
            tic += 1
        f = T * S.TR - math.floor(T * S.TR)
        rb = prev[0] + (pos[0] - prev[0]) * f
        rd = S.from_angles(pang[0] + S.dang(pang[0], ang[0]) * f, pang[1] + S.dang(pang[1], ang[1]) * f)
        i = int(T * 1000.0)
        lb, ld = B[i], D[i]
        sample_i = i
        ax = S.norm(rng.standard_normal(3))
        sample = (lb + rng.standard_normal(3) * noise[1], S.norm(S.rot(ld, ax, rng.standard_normal() * noise[0])))
        if T > 1.0:
            ea.append(math.degrees(math.acos(max(-1, min(1, float(np.dot(rd, ld)))))))
            eb.append(float(np.linalg.norm(rb - lb)))
    ea, eb = np.array(ea), np.array(eb)
    return dict(aR=math.sqrt((ea ** 2).mean()), a99=np.percentile(ea, 99), aM=ea.max(),
                bR=math.sqrt((eb ** 2).mean()), b99=np.percentile(eb, 99), bM=eb.max(),
                fire=fires / max(moving, 1), false=false_fires / max(fires, 1), k=np.mean(ks) if ks else 0)


def main():
    D, B, kind = session()
    print("realistic session: %.0f s, 90 Hz, truth = the noiseless hand; angle deg, base map units" % (len(D) / 1000))
    print("%-24s %-6s %6s %6s %6s | %6s %6s %6s | %6s %6s %5s" % ("predictor", "noise", "aRMS", "a99", "aMax", "bRMS",
                                                                  "b99", "bMax", "fire%", "false%", "leadA"))
    rows = [("none", wrap_old(S.pred_none), 0.0, None, 24.0), ("b49 (v3, lead .75)", wrap_old(S.pred_p3), 0.75, None, 24.0),
            ("b50 (lead .75)", pred_b50, 0.75, P, 4.0), ("b50 (lead 1.0, default)", pred_b50, 1.0, P, 4.0)]
    for nz in ((0.1, 0.017), (0.2, 0.017), (0.3, 0.017)):
        for name, pr, L, p, ml in rows:
            S.MAX_LIN = ml
            r = run(D, B, pr, L, p=p, noise=nz)
            print("%-24s %-6s %6.2f %6.2f %6.2f | %6.3f %6.3f %6.3f | %6.1f %6.1f %5.2f" % (
                name, "%.1f" % nz[0], r["aR"], r["a99"], r["aM"], r["bR"], r["b99"], r["bM"], 100 * r["fire"],
                100 * r["false"], r["k"]))
        print()
    S.MAX_LIN = 24.0
    if "--tune" in sys.argv:
        S.MAX_LIN = 4.0
        for stop in (0.5, 0.6, 0.7, 0.85):
            for mw in (30.0, 90.0, 150.0):
                p = dict(P); p["STOP"] = stop; p["STOP_MINW"] = mw
                r = run(D, B, pred_b50, 1.0, p=p)
                print("tune STOP %.2f MINW %4.0f: aRMS %.2f a99 %.2f bRMS %.3f fire %.1f%% false %.1f%%" % (
                    stop, mw, r["aR"], r["a99"], r["bR"], 100 * r["fire"], 100 * r["false"]))


if __name__ == "__main__":
    main()

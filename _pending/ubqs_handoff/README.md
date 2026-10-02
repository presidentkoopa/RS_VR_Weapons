# UBQS handoff: volumetric saber, build 51

The full write-up is in the "UBQS Volumetric Saber: Lead Coder Handoff" doc. This file only covers how to run things.

## Layout
- build/UltraBadassQuestSaber_b51.pk3 — the build 51 candidate. It has passed the rig but not a headset.
- src/ — generator and source
  - ubqs.py (generator), ubqs_zscript.txt (ZScript template)
  - vgface.py — the b51 glow; volglow.py and vgsplit.py are earlier versions, still imported
  - make_sw_vrplus.py, sw_saberplus.py — helpers
  - cfx/ (CombatFX sprites), snd/, parts/, remote/ (thermal-detonator remote model)
- hand/ — Ermac hand md3 (credit in CREDIT.txt)
- tools/
  - sim.py, sim_real.py — offline lag simulations (numpy)
  - glowpreview.py, preview51.py — offline glow renderer and close-range previews
  - ENGINE_FACTS.md — QZD 17.3 renderer facts with file:line refs
  - sheet_b51.png — rig comparison, b50 vs b51
  - rig/ — headless screenshot rig (Linux/WSL)

## Build (Windows or Linux, Python 3 + numpy + Pillow)
    cd src
    python ubqs.py <path to SW_Models_Wardusted.pk3> snd ..\build
The output pk3 has the same contents as the shipped b51. The md5 differs only because of zip timestamps.
Never add a cvar twice to CVARINFO: QZD hangs at startup.

## Lint
    qzdoom -iwad doom2.wad -file build\UltraBadassQuestSaber.pk3 -norun +logfile lint.log
The "Unknown texture M_NEWG" error is expected. Any other ZScript error means the pk3 is broken.

## Simulations
    cd tools
    python sim_real.py      # realistic 90 Hz tracker noise: angle/base error per predictor
    python sim.py           # idealised timeline
    python preview51.py     # close-range glow previews (PNG)

## Rig (Linux or WSL; needs a Linux QZD 17.3 build)
    export QZD_DIR=/path/with/qzdoom+qzdoom.pk3+game_support.pk3+doom2.wad
    ./tools/rig/run_rig.sh build/UltraBadassQuestSaber_b51.pk3 out_rig
    # optional: RIG_CVARS="ubqs_glow_lead 0.72" RIG_HUD=1 RIG_LEAD=1
    # RIG_WEAPONS=1 also needs WARDUSTED_MODELS=... and WARDUSTED_VR=...
- Takes screenshots of idle, + and X crossings, motion, stop and reversal.
- Logs per-tic glow error as `UBQSRIG err` in out_rig/_work/rig.log.
- The rig uses a world stand-in for the hand-layer saber, because desktop QZD draws HUD models fixed to the camera. It cannot show the VR depth squeeze.
- The rig patches a pose debug hook into a temp copy of the pk3 (patch_hook.py). Shipping pk3s never contain it.

## Headset telemetry
1. Launch QZD with `+logfile ubqs_tel.txt`.
2. In the console, type `ubqs_diag 2`.
3. Hold still for about 5 s, then do about 30 s of sweeps, fast swings, hard stops and twirls.
4. Type `ubqs_diag 0`.
5. The `UBQSTEL` lines give, per frame: ms, frac, angle error, base error, hand deg/s, and the last tic's still/snapA/snapL/tauA/tauL/fade.

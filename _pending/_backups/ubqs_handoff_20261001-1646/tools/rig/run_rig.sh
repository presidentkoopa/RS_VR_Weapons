#!/bin/bash
# UBQS headless visual test rig.
#   run_rig.sh <saber.pk3> <outdir>
# env: RIG_CVARS="a 1;b 2"  extra console commands (predict copy)
#      RIG_WEAPONS=1  also load the Wardusted weapon pack (SW_Models_Wardusted.pk3 + SW_VR_Wardusted.pk3)
#      RIG_HUD=1      also draw the desktop HUD-layer psprite models (fixed to the camera -- NOT the VR pose)
#      RIG_LEAD=<t>   tics the stand-in hand model leads the world layer (default 1)
#      RIG_W / RIG_H  resolution (default 960x540)
set -u
SABER=$(readlink -f "$1"); OUT=$(mkdir -p "$2" && readlink -f "$2")
HERE=$(dirname "$(readlink -f "$0")")
QZD_DIR=${QZD_DIR:?set QZD_DIR to a folder holding a Linux qzdoom build + qzdoom.pk3 + game_support.pk3 + doom2.wad}
L=$QZD_DIR
W=$OUT/_work; rm -rf "$W"; mkdir -p "$W/home"
RW=${RIG_W:-960}; RH=${RIG_H:-540}

# 1. the saber pk3 with the TEST RIG HOOK patched into a temporary copy (the input pk3 is not modified)
python3 "$HERE/patch_hook.py" "$SABER" "$W/saber_hooked.pk3" || exit 1
# 2. the rig pk3
(cd "${RIG_SRC:-$HERE/rigsrc}" && rm -f "$W/rig.pk3" && zip -qr "$W/rig.pk3" .) || exit 1   # (predict copy: + phases 5, 6)

FILES=()
if [ "${RIG_WEAPONS:-0}" = 1 ]; then
  FILES+=(${WARDUSTED_MODELS:?} ${WARDUSTED_VR:?})
fi
FILES+=("$W/saber_hooked.pk3" "$W/rig.pk3")

# 3. the script: settle, then each pose, screenshots by full path
S() { echo "screenshot $OUT/$1"; }
{
  echo "screenshot_quiet 1"
  echo "r_drawplayersprites ${RIG_HUD:-0}"
  echo "crosshair 0"; echo "screenblocks 12"; echo "cl_capfps 1"; echo "vid_fps 0"
  echo "ubqs_flick 0"; echo "ubqs_join 0"; echo "ubqs_force_gestures 0"; echo "ubqs_twirl 0"; echo "ubqs_diag 0"
  echo "rig_lead ${RIG_LEAD:-1}"
  [ -n "${RIG_CVARS:-}" ] && echo "$RIG_CVARS" | tr ';' '\n'
  echo "wait 140"
  echo "rig_phase 1"; echo "wait 50"; S 1_idle_apart
  echo "rig_phase 2"; echo "wait 11"; S 2_plus_impact; echo "wait 45"; S 2_plus_lock
  echo "rig_phase 1"; echo "wait 30"
  echo "rig_phase 3"; echo "wait 11"; S 3_x_impact; echo "wait 45"; S 3_x_lock
  echo "rig_phase 1"; echo "wait 30"
  echo "rig_phase 4"; echo "wait 40"; S 4_motion_a; echo "wait 3"; S 4_motion_b; echo "wait 4"; S 4_motion_c
  echo "rig_phase 1"; echo "wait 30"
  echo "rig_phase 5"; echo "wait 8"; for i in 08 09 10 11 12 13 14 15 16 17 18; do S 5_stop_$i; echo "wait 1"; done; echo "wait 10"; S 5_stop_rest
  echo "rig_phase 1"; echo "wait 30"
  echo "rig_phase 6"; echo "wait 20"; for i in 20 21 22 23 24 25 26 27 28 29 30; do S 6_rev_$i; echo "wait 1"; done
  echo "rig_phase 7"; echo "wait 25"; S 7_headset_away; echo "rig_phase 8"; echo "wait 25"; S 8_side_close
  echo "rig_phase 9"; echo "wait 25"; S 9_emitter_close
  echo "wait 10"; echo "quit"
} > "$W/rig.lines"
# ONE line per file (`wait` only defers the rest of its own command string), chained by exec: the console
# truncates a line at ~4 KB (predict copy)
python3 - "$W" <<'PYEOF'
import sys, os
W = sys.argv[1]
lines = open(os.path.join(W, "rig.lines")).read().split("\n")
lines = [l for l in lines if l.strip()]
chunks, cur = [], []
for l in lines:
    if cur and len(";".join(cur + [l])) > 2500:
        chunks.append(cur); cur = []
    cur.append(l)
chunks.append(cur)
for i, c in enumerate(chunks):
    name = os.path.join(W, "rig.cfg" if i == 0 else "rig%d.cfg" % i)
    if i + 1 < len(chunks):
        c = c + ["exec " + os.path.join(W, "rig%d.cfg" % (i + 1))]
    open(name, "w").write(";".join(c) + "\n")
PYEOF

# 4. run: xvfb, OpenGL (llvmpipe), no sound, isolated HOME/ini
cd "$L"
export LD_LIBRARY_PATH=${QZD_LIBS:-$QZD_DIR}
HOME=$W/home timeout ${RIG_TIMEOUT:-240} xvfb-run -a -s "-screen 0 ${RW}x${RH}x24" ./qzdoom -iwad doom2.wad -file "${FILES[@]}" \
  -nosound -nomonsters -skill 3 -width "$RW" -height "$RH" +vid_fullscreen 0 +win_w "$RW" +win_h "$RH" +map map01 +exec "$W/rig.cfg" \
  +logfile "$W/rig.log" +developer 0 > "$W/stdout.txt" 2>&1
echo "exit $?"
grep -E "UBQSRIG|error|Error|rror:" "$W/rig.log" | grep -v "M_NEWG" | head -60
ls -la "$OUT"/*.png 2>/dev/null

# Build RS_VR_Weapons.pk3
#
# The test guns for the VR reload system, and their models. Loads AFTER the
# reload system; nothing in the reload system may name anything in here.
#
# Entry-by-entry ZipArchive with forward slashes and an ALLOWLIST, as the
# reload system's own build does: Compress-Archive writes backslashes SLADE will
# not open, and a lump name ignores its extension, so a stray .bak in the root
# can silently shadow the real lump.
#
# THE MENU IS LINTED FIRST (tools/menu_lint.py): a slider on a cvar nothing
# reads, a placement set missing a name, or a class MODELDEF or a card names
# that no ZScript here declares fails the build before it reaches a headset.
#
# STAGED, THEN INSTALLED: the pk3 is packed to a scratch folder and compile-checked there, and only a
# pass copies it over the installed RS_VR_Weapons.pk3 in the owner's load order. A pk3 with a script
# error must never sit where the owner launches from (the build lane, 2026-09-13).
#
# -NoCompileCheck skips the last step, which runs doomxr.exe -norun -- and so installs NOTHING: the
# pack stays staged (for a build lock, when the exe is mid-link).
param([switch]$NoCompileCheck)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

# THE RELOAD SYSTEM this package's classes derive from (WM_Gun, WM_Prop) and whose
# WM_LooseMag / WM_LooseRound this MODELDEF draws -- the one line to change when it
# is renamed.
$reloadPk3 = 'E:\DOOMWork\RS_VR_Reload\RS_VR_Reload.pk3'

$root      = $PSScriptRoot
$installed = Join-Path $root 'RS_VR_Weapons.pk3'
$stage     = Join-Path $env:TEMP 'rs_vr_weapons_stage'
New-Item -ItemType Directory -Force $stage | Out-Null
$out       = Join-Path $stage 'RS_VR_Weapons.pk3'

# --prefix: every stem THIS package declares cvars under -- the shotguns' sets and
# wm_pump_start_in_hands (wm_pump), one placement set per revolver, and the
# rifle's (wm_rifle). Add a
# gun's stem here when you add its CVARINFO set, or the lint drops its set and
# calls every slider on its page dead (E7). The pistols add no cvars -- their
# blocks read the reload system's per-hand seats wm_main / wm_off, which that
# package declares and lints. --dep: MODELDEF here draws the reload system's
# WM_LooseMag and WM_LooseRound, and Doom's own ammo classes (Clip, Shell, ...),
# so the reload system's classes and the engine's own ZScript count as declared.
& python 'E:\DOOMWork\tools\menu_lint.py' $root --prefix 'wm_pump,wm_moonlight,wm_sunset,wm_cola,wm_rifle,wm_ssg,wm_doublebarrel,wm_m16,wm_tec9,wm_smg,wm_railgun,wm_plasmarifle,wm_plasmacarbine,wm_chaingun,wm_machinegun,wm_rocketlauncher,wm_rpg,wm_bfg,wm_bfgheavy,wm_chainsaw,wm_chainsawheavy,wm_flamer,wm_flamethrower,wm_pu_clip,wm_pu_clipbox,wm_pu_shell,wm_pu_shellbox,wm_pu_rocket,wm_pu_rocketbox,wm_pu_cell,wm_pu_cellpack,wm_pu_backpack,wm_assaultshotgun,wm_bullpuppump,wm_bolter,wm_bfgrifle,wm_rotarygun,wm_rotarylauncher,wm_longbarchainsaw' --dep (Split-Path $reloadPk3) --dep 'E:\DOOMWork\UZDXREMA\wadsrc\static'
if ($LASTEXITCODE -ne 0) { throw "menu lint failed -- see above." }

$rootLumps = @('zscript.txt', 'WMCARD.txt', 'MAPINFO.txt', 'MODELDEF.txt', 'CVARINFO.txt', 'MENUDEF.txt', 'KEYCONF.txt', 'SNDINFO.txt', 'language.txt')
$files = @()
foreach ($l in $rootLumps) {
    $p = Join-Path $root $l
    if (-not (Test-Path $p)) { throw "missing required lump: $l" }
    $files += Get-Item $p
}
$files += Get-ChildItem -Path (Join-Path $root 'zscript') -Recurse -File -Filter *.zs
$files += Get-ChildItem -Path (Join-Path $root 'models')  -Recurse -File | Where-Object { $_.Extension -in '.md3', '.png', '.obj' }
# RS_Grenade's sounds (folded in 09-14) are extensionless lumps, so its folder packs whole.
$files += Get-ChildItem -Path (Join-Path $root 'sounds')  -Recurse -File | Where-Object { $_.Extension -in '.ogg', '.wav' -or $_.FullName -like '*\sounds\rs_grenade\*' }
# RS_Grenade's and RS_ShieldSaw's sprites (folded in 09-14).
$files += Get-ChildItem -Path (Join-Path $root 'sprites') -Recurse -File

# KEYCONF WITH A BYTE ORDER MARK SILENTLY KILLS ITS FIRST ALIAS.
$kb = [System.IO.File]::ReadAllBytes((Join-Path $root 'KEYCONF.txt'))
if ($kb.Length -ge 3 -and $kb[0] -eq 0xEF -and $kb[1] -eq 0xBB -and $kb[2] -eq 0xBF) { throw "KEYCONF.txt starts with a UTF-8 BOM -- its first alias would do nothing" }

if (Test-Path $out) { Remove-Item $out -Force }
$fs  = [System.IO.File]::Open($out, [System.IO.FileMode]::CreateNew)
$zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)
foreach ($f in $files) {
    $rel = ($f.FullName.Substring($root.Length + 1)) -replace ([regex]::Escape([char]92)), '/'
    $e = $zip.CreateEntry($rel, [System.IO.Compression.CompressionLevel]::Optimal)
    $st = $e.Open(); $b = [System.IO.File]::ReadAllBytes($f.FullName)
    $st.Write($b, 0, $b.Length); $st.Dispose()
}
$zip.Dispose(); $fs.Dispose()

# VERIFY RATHER THAN TRUST: a model that fails to pack is SILENT -- it resolves
# to nothing and simply draws nothing.
$check = [System.IO.Compression.ZipFile]::OpenRead($out)
$names = @($check.Entries | ForEach-Object { $_.FullName })
$check.Dispose()
$must = @('zscript.txt','WMCARD.txt','MODELDEF.txt','CVARINFO.txt','MENUDEF.txt','MAPINFO.txt','KEYCONF.txt','SNDINFO.txt',
          'zscript/rs_vr_weapons/pistols.zs','zscript/rs_vr_weapons/shotguns.zs','zscript/rs_vr_weapons/loadout.zs',
          'zscript/rs_vr_weapons/weaponset.zs',
          'models/pistols/m4a3.md3','models/pistols/m4a3.png','models/pistols/pistolet.md3','models/pistols/WPN-9mm.png',
          'models/pistols/wm_m4a3_mag.md3','models/pistols/wm_pistolet_mag.md3',
          'models/pistols/bullet.md3','models/pistols/bullet.png',
          'sounds/pistols/PFIRE01.ogg','sounds/pistols/PFIRE02.ogg','sounds/pistols/PFIRE03.ogg',
          'sounds/pistols/PCOUT.ogg','sounds/pistols/PCIN.ogg','sounds/pistols/PSLID.ogg','sounds/pistols/PSNAP.ogg',
          'sounds/pistols/9mmshoot.wav','sounds/pistols/9mmclip1.wav','sounds/pistols/9mmclip2.wav','sounds/pistols/9mmslide.wav',
          'sounds/rifles/RIFIRE1.ogg','sounds/rifles/RIFIRE2.ogg','sounds/rifles/RIFIRE3.ogg','sounds/rifles/RCOUT.ogg',
          'sounds/rifles/RCIN.ogg','sounds/rifles/RCKBCK.ogg','sounds/rifles/RCKFWD.ogg',
          'sounds/revolvers/SINGLE1.ogg','sounds/revolvers/SINGLE2.ogg','sounds/revolvers/DBOPN.ogg',
          'sounds/revolvers/DBCLS.ogg','sounds/revolvers/DBLOD.ogg',
          'models/shotguns/AE_Shotgun/m37a2.md3','models/shotguns/AE_Shotgun/m37a2.png',
          'models/shotguns/Shotgun/shotgun.md3','models/shotguns/Shotgun/WPN-GUNS-k1.png',
          'models/shotguns/Shotgun/wm_shotshell.md3',
          'models/shotguns/AssaultShotgun/AssaultShotgun.md3','models/shotguns/AssaultShotgun/AssaultShotgun.png',
          'models/shotguns/SuperShotgun/ssg.md3','models/shotguns/SuperShotgun/WPN-GUNS-k1.png',
          'models/shotguns/DoubleBarrel/doublebarrel_wm.md3','models/shotguns/DoubleBarrel/wm_doublebarrel_shell.md3',
          'models/shotguns/DoubleBarrel/ssg_HD.png','models/shotguns/DoubleBarrel/shells.png',
          'sounds/shotguns/DoubleBarrel/ssgfire.ogg','sounds/shotguns/DoubleBarrel/DSDBOPN.ogg',
          'sounds/shotguns/DoubleBarrel/DSDBCLS.ogg','sounds/shotguns/DoubleBarrel/CLIPINSS.ogg',
          'zscript/rs_vr_weapons/revolvers.zs',
          'models/revolvers/Revolver/rev_wm.md3','models/revolvers/Revolver/wm_speedloader.md3',
          'models/revolvers/Revolver/WPN-REV.png','models/revolvers/Revolver/WPN-REV2.png',
          'models/revolvers/Cola_Revolver/revolver.md3','models/revolvers/Cola_Revolver/revolver.png',
          'models/revolvers/Cola_Revolver/wm_cola_rounds.md3',
          'zscript/rs_vr_weapons/rifles.zs','zscript/rs_vr_weapons/ssg.zs',
          'models/rifles/Rifle/Rifle.md3','models/rifles/Rifle/Rifle.png','models/rifles/Rifle/wm_rifle_mag.md3',
          'models/rifles/M16/m16_wm.md3','models/rifles/M16/WPN-M16-k1.png','models/rifles/M16/wm_m16_mag.md3',
          'zscript/rs_vr_weapons/smgs.zs',
          'models/smgs/Tec9/tec9_wm.md3','models/smgs/Tec9/tec9.png','models/smgs/Tec9/wm_tec9_mag.md3',
          'models/smgs/SMG/smg_wm.md3','models/smgs/SMG/smg.png','models/smgs/SMG/wm_smg_mag.md3',
          'zscript/rs_vr_weapons/railguns.zs',
          'models/railguns/Railgun/railgun_wm.md3','models/railguns/Railgun/railgun.png','models/railguns/Railgun/wm_railgun_mag.md3',
          'zscript/rs_vr_weapons/plasma.zs',
          'models/plasma/PlasmaRifle/plasmarifle_wm.md3','models/plasma/PlasmaRifle/wm_plasmarifle_cell.md3','models/plasma/PlasmaRifle/PlasmaRifle.png',
          'models/plasma/PlasmaCarbine/plasmacarbine_wm.md3','models/plasma/PlasmaCarbine/wm_plasmacarbine_cell.md3','models/plasma/PlasmaCarbine/plasmacarbine.png',
          'zscript/rs_vr_weapons/chainguns.zs',
          'models/chainguns/Chaingun/chaingun_wm.md3','models/chainguns/Chaingun/wm_chaingun_mag.md3','models/chainguns/Chaingun/chaingun_HD.png',
          'models/chainguns/MachineGun/machinegun_wm.md3','models/chainguns/MachineGun/wm_machinegun_mag.md3','models/chainguns/MachineGun/Machinegun.png',
          'zscript/rs_vr_weapons/launchers.zs',
          'models/launchers/RocketLauncher/rocketlauncher_wm.md3','models/launchers/RocketLauncher/rocketlauncher.png','models/launchers/RocketLauncher/wm_rocketlauncher_mag.md3','models/launchers/RocketLauncher/wm_rocket.md3',
          'models/launchers/RPG/rpg_wm.md3','models/launchers/RPG/rpg.png','models/launchers/RPG/wm_rpg_mag.md3','models/launchers/RPG/wm_rocket.md3',
          'zscript/rs_vr_weapons/bfg.zs',
          'models/bfg/BFG/bfg_wm.md3','models/bfg/BFG/wm_bfg_cell.md3','models/bfg/BFG/bfg9000.png','models/bfg/BFG/bfg_meter1.png',
          'models/bfg/BFGHeavy/bfgheavy_wm.md3','models/bfg/BFGHeavy/wm_bfgheavy_cell.md3','models/bfg/BFGHeavy/bfg.png',
          'zscript/rs_vr_weapons/chainsaws.zs',
          'models/chainsaws/Chainsaw/chainsaw_wm.md3','models/chainsaws/Chainsaw/chainsaw.png',
          'models/chainsaws/ChainsawHeavy/chainsaw_heavy_wm.md3','models/chainsaws/ChainsawHeavy/chainsaw.png',
          'zscript/rs_vr_weapons/flamers.zs',
          'zscript/rs_vr_weapons/meatgrinder.zs',
          'models/shotguns/AssaultShotgunGH/assaultshotgun_wm.md3','models/shotguns/AssaultShotgunGH/wm_assaultshotgun_mag.md3','models/shotguns/AssaultShotgunGH/AssaultShotgun.png',
          'models/shotguns/BullpupPump/bullpuppump_wm.md3','models/shotguns/BullpupPump/ssg.png',
          'models/plasma/Bolter/bolter_wm.md3','models/plasma/Bolter/wm_bolter_mag.md3','models/plasma/Bolter/bolter.png',
          'models/bfg/BFGRifle/bfgrifle_wm.md3','models/bfg/BFGRifle/BFG_9k.png',
          'models/chainguns/RotaryGun/rotarygun_wm.md3','models/chainguns/RotaryGun/Chaingun.png',
          'models/launchers/RotaryLauncher/rotarylauncher_wm.md3','models/launchers/RotaryLauncher/RPG.png',
          'models/chainsaws/LongbarChainsaw/longbarchainsaw_wm.md3','models/chainsaws/LongbarChainsaw/Saw.png',
          'models/flamers/Flamer/flamer_wm.md3','models/flamers/Flamer/wm_flamer_can.md3','models/flamers/Flamer/flamer.png',
          'models/flamers/Flamethrower/flamethrower_wm.md3','models/flamers/Flamethrower/wm_flamethrower_can.md3','models/flamers/Flamethrower/flamethrower.png',
          'models/grenades/nade.md3','models/grenades/nade.png','sounds/launchers/RLGCY.ogg',
          'language.txt','zscript/rs_grenade/rs_vrgrenade.zs','zscript/rs_grenade/rs_blast.zs','models/grenade/nade.md3','sounds/rs_grenade/GPIN','sprites/JGRNA0',
          'zscript/rs_shieldsaw/rs_shieldsaw.zs','zscript/rs_shieldsaw/rs_shieldsaw_state.zs','zscript/rs_shieldsaw/rs_shieldsaw_world.zs','sprites/SSAWA0.png',
          'sounds/chainguns/MGFIRE.ogg','sounds/chainguns/MGCHAIN.ogg','sounds/chainguns/MGLOAD.ogg','sounds/chainguns/MGSTRT.ogg','sounds/chainguns/MGSPIN.ogg','sounds/chainguns/MGSTOP.ogg',
          'sounds/launchers/RLFIRE.ogg','sounds/launchers/RLCOUT.ogg','sounds/launchers/RLCIN.ogg','sounds/launchers/RLCYCL.ogg',
          'sounds/plasma/PLFIRE1.ogg','sounds/plasma/PLFIRE2.ogg','sounds/plasma/PLFIRE3.ogg','sounds/plasma/PLCOUT.ogg','sounds/plasma/PLCIN.ogg','sounds/plasma/PLCHRG.ogg','sounds/plasma/PLBEEP.ogg','sounds/plasma/PLALTF.ogg',
          'sounds/bfg/BFGFIRE.ogg','sounds/bfg/BFGPFR.ogg','sounds/bfg/BFGCHRG.ogg','sounds/bfg/BFGOPN.ogg','sounds/bfg/BFGCOUT.ogg','sounds/bfg/BFGCLS.ogg','sounds/bfg/BFGCLI01.ogg','sounds/bfg/BFGCLI02.ogg','sounds/bfg/BFGCLI03.ogg',
          'sounds/chainsaws/CSTRT.ogg','sounds/chainsaws/CSIDLE.ogg','sounds/chainsaws/CSLOOP.ogg','sounds/chainsaws/CSTOP.ogg','sounds/chainsaws/CSOFF.ogg','sounds/chainsaws/CSZIP.ogg','sounds/chainsaws/SAWCORD.wav','sounds/chainsaws/CSHIT1.ogg','sounds/chainsaws/CSHIT2.ogg','sounds/chainsaws/CSHIT3.ogg','sounds/chainsaws/CSIDLE_HEAVY.wav','sounds/chainsaws/DSSAWIDL_LONGBAR.wav',
          'sounds/magdrops/DSAOUNC1.ogg','sounds/magdrops/DSAOUNC2.ogg','sounds/magdrops/DSAOUNC3.ogg',
          'models/ammo/AmmoClip_Case.md3','models/ammo/AmmoBox.md3','models/ammo/Shells.md3','models/ammo/ShellBox.md3',
          'models/ammo/IRocket.md3','models/ammo/RocketBox.md3','models/ammo/Cell.md3','models/ammo/CellLarge.md3','models/ammo/Backpack.md3','models/ammo/Backpack.png')
foreach ($m in $must) {
    if ($names -notcontains $m) { throw "verification failed: $m missing" }
}

# EVERY MESH AND SKIN A MODELDEF BLOCK OR A CARD NAMES IS IN THIS PK3. The
# compile check cannot see this: -norun exits before models load. Lump names
# are case-insensitive, so the comparison is too.
$lower = @($names | ForEach-Object { $_.ToLowerInvariant() })
$refs = @()
$path = ''
foreach ($line in (Get-Content (Join-Path $root 'MODELDEF.txt'))) {
    $t = ($line -replace '//.*$', '').Trim()
    if ($t -match '^Path\s+"([^"]+)"') { $path = $Matches[1] }
    elseif ($t -match '^(Model|Skin)\s+\d+\s+"([^"]+)"') { $refs += ("MODELDEF", "$path/$($Matches[2])") }
}
foreach ($line in (Get-Content (Join-Path $root 'WMCARD.txt'))) {
    $t = ($line -replace '#.*$', '').Trim()
    if ($t -match '^(model|skin|magmodel|magskin|roundmodel|roundskin)\s*=\s*"([^"]+)"\s+"([^"]+)"') {
        $refs += ("WMCARD $($Matches[1])", "$($Matches[2])/$($Matches[3])")
    }
}
for ($i = 0; $i -lt $refs.Count; $i += 2) {
    if ($lower -notcontains $refs[$i + 1].ToLowerInvariant()) { throw "verification failed: $($refs[$i]) names $($refs[$i + 1]), which is not in the pk3" }
}
Write-Output "RS_VR_Weapons.pk3  --  $($names.Count) entries, verified; $($refs.Count / 2) mesh/skin references resolve"

if ($NoCompileCheck) { Write-Output "compile check SKIPPED (-NoCompileCheck) -- packed to $out, NOT installed"; return }

# PROVE IT COMPILES, through the shared hidden check (hidden -norun, scratch
# config copy, scratch working directory -- see its header). The reload system
# first, then this package.
#
# IN PROCESS, not a child `powershell -File`: -File passes every argument as one
# string, so an array cannot reach -Files that way. compile_check.ps1's `exit`
# ends only that script and sets $LASTEXITCODE here.
if (-not (Test-Path $reloadPk3)) { throw "no reload system pk3 at $reloadPk3 -- build it first" }
# RS_BALLISTICS FIRST: the flamethrowers call its RSB_Flame for their flame (flamers.zs), a
# compile-time reference, so it loads before this package here as in the owner's order.
$ballisticsPk3 = 'E:\DOOMWork\RS_Ballistics\RS_Ballistics.pk3'
if (-not (Test-Path $ballisticsPk3)) { throw "no RS_Ballistics pk3 at $ballisticsPk3 -- the flamethrowers need it" }
& 'E:\DOOMWork\tools\compile_check.ps1' -Files $ballisticsPk3, $reloadPk3, $out
if ($LASTEXITCODE -ne 0) { throw "compile check FAILED -- see above; NOT installed, the owner's RS_VR_Weapons.pk3 is untouched" }
Copy-Item $out $installed -Force
Write-Output "installed $installed"

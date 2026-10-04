# Build RS_Modern.pk3
#
# Modern weapon sets for the VR reload system, and the Modern player class that starts with them. Loads AFTER
# RS_Ballistics, RS_VR_Reload and RS_VR_Weapons (its guns are WM_Gun / WM_Prop, its class starts from WM_Player).
#
# Entry-by-entry ZipArchive with forward slashes and an ALLOWLIST, as the other packages' builds do: Compress-Archive
# writes backslashes SLADE will not open, and a lump name ignores its extension, so a stray file in the root can
# silently shadow a real lump.
#
# STAGED, THEN INSTALLED: packed to a scratch folder, verified, compile-checked there with the data validators on (the
# card checker reads every WMCARD, this package's included), and copied over RS_Modern.pk3 only on a pass.
# -NoCompileCheck packs and verifies and installs NOTHING (for a build lock, when the exe is mid-link).
param([switch]$NoCompileCheck)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root      = $PSScriptRoot
$installed = Join-Path $root 'RS_Modern.pk3'
$stage     = Join-Path $env:TEMP 'rs_modern_stage'
New-Item -ItemType Directory -Force $stage | Out-Null
$out       = Join-Path $stage 'RS_Modern.pk3'

$ballisticsPk3 = 'E:\DOOMWork\RS_Ballistics\RS_Ballistics.pk3'
$reloadPk3     = 'E:\DOOMWork\RS_VR_Reload\RS_VR_Reload.pk3'
$weaponsPk3    = 'E:\DOOMWork\RS_VR_Weapons\RS_VR_Weapons.pk3'

$rootLumps = @('zscript.txt', 'MAPINFO.txt', 'MODELDEF.txt', 'SNDINFO.txt')
$files = @()
foreach ($l in $rootLumps) {
    $p = Join-Path $root $l
    if (-not (Test-Path $p)) { throw "missing required lump: $l" }
    $files += Get-Item $p
}
$cardFiles = @(Get-ChildItem -Path $root -File -Filter 'WMCARD.*' | Sort-Object Name)
if ($cardFiles.Count -eq 0) { throw 'missing required lump: no WMCARD.* file' }
$files += $cardFiles
$files += Get-ChildItem -Path (Join-Path $root 'zscript') -Recurse -File -Filter *.zs
$files += Get-ChildItem -Path (Join-Path $root 'models')  -Recurse -File | Where-Object { $_.Extension -in '.iqm', '.md3', '.png', '.obj', '.bmp' }
$files += Get-ChildItem -Path (Join-Path $root 'sounds')  -Recurse -File | Where-Object { $_.Extension -in '.ogg', '.wav' }
# Icons (graphics/<LUMP>.png): a gun's Inventory.Icon / AltHUDIcon, which the weapon wheel shows.
if (Test-Path (Join-Path $root 'graphics')) { $files += Get-ChildItem -Path (Join-Path $root 'graphics') -Recurse -File | Where-Object { $_.Extension -in '.png' } }

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

# VERIFY RATHER THAN TRUST. A model or sound that fails to pack is SILENT -- it draws nothing, it plays nothing -- and
# -norun exits before models load, so the compile check cannot see it.
$check = [System.IO.Compression.ZipFile]::OpenRead($out)
$names = @($check.Entries | ForEach-Object { $_.FullName })
$check.Dispose()
$lower = @($names | ForEach-Object { $_.ToLowerInvariant() })
$refs = @()
$path = ''
foreach ($line in (Get-Content (Join-Path $root 'MODELDEF.txt'))) {
    $t = ($line -replace '//.*$', '').Trim()
    if ($t -match '^Path\s+"([^"]+)"') { $path = $Matches[1] }
    elseif ($t -match '^(Model|Skin)\s+\d+\s+"([^"]+)"') { $refs += ("MODELDEF $($Matches[1])", "$path/$($Matches[2])") }
    elseif ($t -match '^SurfaceSkin\s+\d+\s+\d+\s+"([^"]+)"') { $refs += ("MODELDEF SurfaceSkin", "$path/$($Matches[1])") }
}
foreach ($line in ($cardFiles | ForEach-Object { Get-Content $_.FullName })) {
    $t = ($line -replace '#.*$', '').Trim()
    if ($t -match '^(model|skin|magmodel|magskin|roundmodel|roundskin)\s*=\s*"([^"]+)"\s+"([^"]+)"') {
        $refs += ("WMCARD $($Matches[1])", "$($Matches[2])/$($Matches[3])")
    }
}
# A card may borrow RS_VR_Weapons' shared meshes (the pistols' round): those resolve against that pk3.
$weaponsNames = @()
if (Test-Path $weaponsPk3) {
    $wz = [System.IO.Compression.ZipFile]::OpenRead($weaponsPk3)
    $weaponsNames = @($wz.Entries | ForEach-Object { $_.FullName.ToLowerInvariant() })
    $wz.Dispose()
}
for ($i = 0; $i -lt $refs.Count; $i += 2) {
    $want = $refs[$i + 1].ToLowerInvariant()
    if ($lower -notcontains $want -and $weaponsNames -notcontains $want) { throw "verification failed: $($refs[$i]) names $($refs[$i + 1]), which is in neither this pk3 nor RS_VR_Weapons" }
}
foreach ($line in (Get-Content (Join-Path $root 'SNDINFO.txt'))) {
    $t = ($line -replace '//.*$', '').Trim()
    if ($t -match '^(\S+)\s+(sounds/\S+)$' -and $lower -notcontains $Matches[2].ToLowerInvariant()) { throw "verification failed: SNDINFO $($Matches[1]) names $($Matches[2]), which is not in the pk3" }
}
# EVERY CLASS MODELDEF DRAWS IS DECLARED HERE: a MODELDEF block for a class nothing declares is ignored, silently.
$zs = ($files | Where-Object { $_.Extension -eq '.zs' } | ForEach-Object { Get-Content $_.FullName -Raw }) -join "`n"
foreach ($line in (Get-Content (Join-Path $root 'MODELDEF.txt'))) {
    if ($line -match '^\s*Model\s+(\w+)\s*$' -and $zs -notmatch "(?m)^\s*class\s+$($Matches[1])\b") { throw "verification failed: MODELDEF draws class $($Matches[1]), which no zscript here declares" }
}
Write-Output "RS_Modern.pk3  --  $($names.Count) entries, verified; $($refs.Count / 2) mesh/skin references resolve (staged at $out)"

if ($NoCompileCheck) { Write-Output "compile check SKIPPED (-NoCompileCheck) -- packed to $out, NOT installed"; return }

# PROVE IT COMPILES AND ITS CARDS LOAD: the shared hidden check (-norun -validatedata) on the staged pk3, after
# every package it builds on, in the owner's order.
foreach ($dep in @($ballisticsPk3, $reloadPk3, $weaponsPk3)) { if (-not (Test-Path $dep)) { throw "no $dep -- RS_Modern builds on it" } }
& 'E:\DOOMWork\tools\compile_check.ps1' -Files $ballisticsPk3, $reloadPk3, $weaponsPk3, $out
if ($LASTEXITCODE -ne 0) { throw "compile check FAILED -- see above; NOT installed, $installed is untouched" }
Copy-Item $out $installed -Force
Write-Output "installed $installed ($((Get-Item $installed).LastWriteTime.ToString('MM-dd HH:mm:ss')))"

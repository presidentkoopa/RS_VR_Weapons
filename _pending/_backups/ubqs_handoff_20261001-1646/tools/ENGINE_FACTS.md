# ENGINE_FACTS — mod-side levers for a lightsaber glow on stock QZD 17.3 VR

Source: /tmp/claude-0/audit/ema17/src (paths relative to it) + /tmp/claude-0/audit/ema17/wadsrc.
Everything below was established by **reading code only**. Nothing here was run in a headset. Where a claim
depends on GL spec semantics rather than engine code, it says so.

Legend: **USABLE: yes / no / how**.

---------------------------------------------------------------------------------------------------
## A. LAG / INTERPOLATION

### A1. When Prev is captured (correction to BRIEF)
`p_tick.cpp:152-162`: at the start of every tic, **before** any thinker or player runs, P_Ticker calls
`ac->ClearInterpolation()` for *every* actor:
```
while ((ac = it.Next())) { ac->ClearInterpolation(); ac->ClearFOVInterpolation(); }
```
`playsim/actorinlines.h:29-35`: `ClearInterpolation(){ Prev = Pos(); PrevAngles = Angles; PrevPortalGroup=... }`
So Prev/PrevAngles hold the state from the end of the previous tic. This is not done in Actor.Tick.
**USABLE: yes.** Anything the mod writes to Prev during the tic replaces this.

### A2. Render position/angles
`playsim/actor.h:1488-1500`:
```
DVector3 InterpolatedPosition(double ticFrac) const
{ if (renderflags & RF_DONTINTERPOLATE) return Pos(); else return Prev + (ticFrac * (Pos() - Prev)); }
DRotator InterpolatedAngles(double ticFrac) const   // yaw, pitch AND roll, each via deltaangle
```
- Sprites: `rendering/hwrenderer/scene/hw_sprites.cpp:829` `thingpos = thing->InterpolatedPosition(vp.TicFrac)`;
  `:917-920` angles are interpolated only with `RF_INTERPOLATEANGLES`, otherwise they use the current Angles.
- Models: `r_data/models.cpp:89-92` `if (actor->renderflags & RF_INTERPOLATEANGLES) angles = actor->InterpolatedAngles(ticFrac); else angles = actor->Angles;`
  The **same interpolated `angles`** feeds pitch (`:132-137`, USEACTORPITCH) and roll (`:138`, USEACTORROLL).
  So yes, with +INTERPOLATEANGLES the model's pitch and roll are interpolated too.
- TicFrac: `rendering/r_utility.cpp:951-953` `viewPoint.TicFrac = I_GetTimeFrac(); if (cl_capfps || r_NoInterpolate) viewPoint.TicFrac = 1.0;`
  With **cl_capfps=1 nothing is interpolated** and every actor shows its end-of-tic pose (35 Hz steps).
- `+DONTINTERPOLATE` (RF_DONTINTERPOLATE, `scripting/thingdef_data.cpp:378`) makes the actor render at Pos.
  This applies to position only. Angles are controlled by INTERPOLATEANGLES.

### A3. What ZScript can write
- `wadsrc/static/zscript/actors/actor.zs:99` `native vector3 Prev;` is **writable** (it is not readonly).
- `actor.zs:734` `native void ClearInterpolation();` sets Prev=Pos and PrevAngles=Angles.
- `actor.zs:753` `SetOrigin(vector3 newpos, bool moving)` → `playsim/p_maputl.cpp:563-571`:
  `SetXYZ; LinkToWorld; P_FindFloorCeiling; if (!moving) ClearInterpolation();`
  - `moving=false` snaps the actor: Prev=Pos and PrevAngles=Angles, so it shows no interpolation for that tic.
  - `moving=true` keeps Prev, so the actor interpolates from the start-of-tic Prev to the new Pos.
- PrevAngles is not exposed, but it can be set indirectly: set Angles to the start value → `ClearInterpolation()` →
  set Angles to the end value. Then write `Prev` and call `SetOrigin(end, true)`.
  **USABLE: yes. The mod has full control of BOTH interpolation endpoints (pos + yaw/pitch/roll) every tic.**
  This is the core of motion prediction.

### A4. Anything rendered with per-frame (not per-tic) data?
| Candidate | Per-frame? | Evidence | Usable for glow |
|---|---|---|---|
| HUD/psprite models in VR | YES: live controller pose | `r_data/models.cpp:219-227` `vrmode->GetWeaponTransform(&objectToWorldMatrix, hand)` → OpenXR `GetHandTransform` (`common/rendering/hwrenderer/data/hw_openxrdevice.cpp:431-480`) uses `r_viewpoint.CenterEyePos` (interpolated) + live `weaponoffset/weaponangles` | Hand layer only (see B) |
| `Weapon.ModifyBobLayer3D` / `ModifyBobPivotLayer3D` | YES, ZScript called per frame (per eye) during render prep | `hw_weapon.cpp:891-975` (VMCall at :961, :974), `weapons.zs:46,48` `virtual ui ...` | Adds a translation/rotation to a **HUD model** layer, and only when the layer has PSPF_ADDBOB. ui scope, so it cannot touch the world. |
| Player pawn position | Partly: OpenXR SetUp runs `P_XYMovement` each frame for room-scale | `hw_openxrdevice.cpp:~663-680` | Only the camera actor itself, which is not drawn. **no** |
| Teleport marker | per-frame | `hw_sprites.cpp:855-860` (`GetTeleportLocation`) | Only the camera actor. **no** |
| VisualThinker | **no**, per tic | `playsim/p_effect.cpp:1158` `Prev = PT.Pos;` in Tick; `:1204-1210` lerp | Same lag as actors (see C9) |
| Dynamic lights | **no**, per tic and **not interpolated** | `playsim/a_dynlight.cpp:377-392` `Pos = target->Vec3Offset(...)` uses target's *current* Pos | They step at 35 Hz |
| md3 frame tweening | per frame, but driven by TicFrac and not by live data | `models.cpp:370-379` | **no** for pose |
| IQM decoupled anim set from UI | per frame from UI, with a one-frame delay | `actor.zs:1341` `native ui void SetAnimationUI`; `playsim/p_actionfunctions.cpp:5346-5349`; render uses `totaltime+I_GetTimeFrac()` (`models.cpp:613-618`) | Exotic. IQM + `+DECOUPLEDANIMATIONS` only (`models_iqm.cpp:450`; md3 has no named anims, `model.h:92`) |
| Coronas | disabled | `hw_drawinfo.cpp:935` commented out, `#if 0` in DrawCoronas | **no** |

### A5. Per-frame ZScript
- `EventHandler.RenderOverlay / RenderUnderlay` (`events.zs:181-182`, `virtual ui`) are called from the status-bar draw (`g_statusbar/shared_sbar.cpp:1197,1234`),
  once per frame, **after** the 3D scene of that frame has been rendered. RenderEvent provides ViewPos, angles and `FracTic` (`events.zs:59-67`).
  They can READ play data such as `players[consoleplayer].mo.AttackPos`. Because they are ui scope, they can only draw 2D (Screen/Shape2D). In VR that 2D goes to the HUD/overlay layer, which has no world stereo depth.
  **USABLE for 3D glow: no.** Exceptions are ui-callable natives that change actors, such as `SetAnimationUI` (above). These take effect on the next frame.
- `UiTick` runs per tic, not per frame.
- `System.GetTimeFrac()` exists (`engine/base.zs:246`) and is useful for timing/latency measurements. I did not verify which scopes may call it.

### A6. The VR hand pose exposed to ZScript
`actor.zs:268-277` (all `native readonly`): `AttackPos, AttackPitch, AttackRoll, AttackAngle, OffhandPos, OffhandPitch, OffhandRoll, OffhandAngle, OverrideAttackPosDir, HmdPosition`.
`AttackDir(actor, angle, pitch)` / `OffhandDir(...)` natives are at `actor.zs:858-859`.
- They are written in `VRMode::SetUp` (`hw_vrmodes.cpp:434-446`, generic defaults), and OpenXR then overrides them in
  `OpenXRDeviceMode::SetUp` (`hw_openxrdevice.cpp:521-612`):
  ```
  AttackAngle = -90 + getViewpointYaw() + (weaponangles[YAW]-playerYaw);  AttackPitch = -weaponangles[PITCH]; AttackRoll = weaponangles[ROLL];
  AttackPos.X = mo->X() - weaponoffset[0]*vr_vunits_per_meter; ... Z = CenterEyePos.Z + (hmd+offset)*vunits/pixelstretch - height
  ```
- **SetUp is called once per rendered frame** (`rendering/hwrenderer/hw_entrypoint.cpp:143`, before the eye loop). It is called again from the 2D
  postprocess path (`gl_postprocess.cpp:126`). So the values are **refreshed per frame**. Play code reading them during tic N sees the
  sample from the **last frame rendered before that tic** (≈1 frame old).
- Caveat: OpenXR AttackPos uses `mo->X()` (current, not interpolated) for XY. The rendered hand uses interpolated
  `CenterEyePos`. When the player moves, AttackPos and the rendered hand differ by the body interpolation offset.
  Recommendation: predict the hand **relative to the body** (AttackPos − mo.Pos) and re-add the body as `mo.Prev` / `mo.Pos` for the two endpoints.
  The OpenVR backend instead takes AttackPos from the hand matrix (`rendering/gl/stereo3d/gl_openvr.cpp:2524-2530`).

### A7. Lag arithmetic and the prediction recipe
At frame time t in [t_N, t_N+T) the renderer shows `Prev_N + frac*(Pos_N-Prev_N)`, frac=(t−t_N)/T, T=1/35 s.
The latest pose sample play can see in tic N was taken at about t_N − 1 frame. For a lag-free result set:
`Prev_N := pose_pred(t_N)` and `Pos_N := pose_pred(t_N + T)` (extrapolated from the last samples, e.g. velocity/angular velocity over the last 2–3 tics),
using the write order from A3. The residual error is the extrapolation error over about 1 frame + 1 tic (≈40 ms horizon for Pos).

---------------------------------------------------------------------------------------------------
## B. HAND LAYER (HUD models in VR)

### B1. Where the hand layer is drawn
`hw_drawinfo.cpp:1064-1086` (DrawScene):
```
RenderState.SetDepthMask(true);  ...  RenderScene(RenderState);
if (drawmode == DM_MAINVIEW && vrmode->RenderPlayerSpritesInScene())
    DrawPlayerSprites(IsHUDModelForPlayerAvailable(...), RenderState);
...  portalState.EndFrame(this, RenderState);  RenderTranslucent(RenderState);
```
`RenderPlayerSpritesInScene()` is hard-wired `true` for OpenXR (`hw_openxrdevice.h:81`) and OpenVR (`gl_openvr.h:117`).
`vr_render_weap_in_scene` (`hw_vrmodes.cpp:148`, used at `:427-430`) only affects the **base/non-HMD** VRMode. It is "only used for testing on PC".
With it false, HUD models are drawn in EndDrawScene after `state.Clear(CT_Depth)` (`hw_drawinfo.cpp:940-951`). **That path is never taken in real VR.**

### B2. What the hand layer does (HUD model path)
`hw_weapon.cpp:78-110` DrawPSprite → `hw_models.cpp:84-116` BeginDrawHUDModel:
- Blending: `state.SetRenderStyle(huds->RenderStyle)` (`hw_weapon.cpp:89`). **The psprite RenderStyle DOES change blending**
  (`gl_renderstate.cpp:388-418` ApplyBlendMode). Use A_OverlayFlags(PSPF_RENDERSTYLE) + A_OverlayRenderStyle; resolution is in `p_pspr.cpp:391-420` and `hw_weapon.cpp:551-610`.
- Alpha test: `state.AlphaFunc(Alpha_GEqual, gl_mask_threshold)` (`hw_weapon.cpp:105`), unconditional for models; the cvar defaults to 0.5 (`hw_drawinfo.cpp:61`).
  The shader does `if (frag.a <= uAlphaThreshold) discard;` on **material.Base.a** (`wadsrc/static/shaders/glsl/main.fp:877-879`), *before*
  vColor/psprite Alpha is applied. So psprite `Alpha < 1` does **not** remove pixels; it only scales blending.
  `disablealphatest` in GLDEFS (`r_data/gldefs.cpp:1259-1267`) only flags the texture "translucent". The HUD-model path ignores that flag.
- Depth: `SetDepthFunc(DF_LEqual)`, `SetDepthClamp(true)`, `SetDepthRange(0, 0.3)` (`hw_models.cpp:86-92`).
  **Depth mask is never touched.** `SetDepthMask` is called only in hw_drawinfo/hw_decal/hw_portal (grep). It is `true` from DrawScene:1064 / RenderScene:538.
- Culling: back faces are culled if style != Normal or FORCECULLBACKFACES (`hw_models.cpp:97-100`). DONTCULLBACKFACES is **ignored** for HUD models.
- Not deferred: DrawPlayerSprites draws immediately, in psprite-list order (`hw_weapon.cpp:247-261`). **A psprite with STYLE_Add is NOT put in
  the translucent list.** It is drawn right after opaque, before portals and before all world translucents.

### B3. THE CRUX: can a HUD additive model avoid occluding world translucents?
**No, not with depth writes. Every fragment that survives the alpha test writes depth at z_w ≤ 0.3, whatever RenderStyle is used.**
World translucents are drawn later with depth test on (`RenderTranslucent`, `hw_drawinfo.cpp:596-613`, mask false but test on).
With zNear=0.5 (`v_video.h:294`), anything a few units away has z_w ≈ 1−0.5/d ≈ 0.9+, so it fails behind any hand-layer pixel.
- `gl_FragDepth` from a custom shader: GL_DEPTH_CLAMP is enabled for HUD models (`hw_models.cpp:87`, `gl_renderstate.cpp:615-619`). Per the GL 4.x
  depth-test rules, the fragment depth is then clamped to the depth range [0, 0.3]. You can't push it behind the world.
  (This is GL spec reasoning, not tested. The conclusion holds even without clamp only if you write ≥ world depth, which then also hides the blade core behind walls.)
- The only way to not occlude is to **not emit the fragment**: alpha < threshold, or `discard` in a custom shader (e.g. a screen-door dither). Partial
  coverage then gives partial visibility of the sparks (noisy).
- `gl_mask_threshold` can only be changed from a menu (`common/scripting/interface/vmnatives.cpp:947-958`: "Only menus are allowed to change non-mod CVARs").
  Lowering it gives soft alpha on the hand layer, but it **increases** the occluding area.
**Verdict: hand-layer glow must be thin. Any wide halo must live in the world layer or come from bloom (D2).**

### B4. Per-frame hand-layer hook
`ModifyBobLayer3D(Translation, Rotation, layer, ticfrac)` is called per frame per eye for every model psprite layer with PSPF_ADDBOB
(`hw_weapon.cpp:952-962`). It can offset or rotate a glow overlay layer per frame, for example jitter or flicker by angle. It **cannot** change scale/alpha/style.
ui scope.

---------------------------------------------------------------------------------------------------
## C. WORLD LAYER TOOLS

C1. **Translucent world models**: any non-Normal RenderStyle sends the actor to GLDL_TRANSLUCENT (`hw_drawlistadd.cpp:141-152`). That list is drawn
    with `SetDepthMask(false)` and DrawSorted (`hw_drawinfo.cpp:603-605`). Alpha: `hw_sprites.cpp:135-139`: if the texture has
    translucency (PNG with partial alpha) the test is `Alpha_Greater 0` (fully soft); otherwise it is gl_mask_sprite_threshold (0.5).
    Translucent models **do not write depth**. Additive shells are order-independent. **USABLE: yes (this is BeamGlow's path).**
    Back-face culling for non-Normal styles unless DONTCULLBACKFACES (`hw_models.cpp:66`).
C2. **MODELDEF keywords (17.3)** (`models.cpp` parser): `model path skin surfaceskin scale offset zoffset frame frameindex animation baseframe
    angleoffset pitchoffset rolloffset ignoretranslation pitchfrommomentum inheritactorpitch inheritactorroll useactorpitch useactorroll
    noperpixellighting scaleweaponfov modelsareattachments rotating rotation-speed rotation-vector rotation-center userotationcenter
    interpolatedoubledframes nointerpolation dontcullbackfaces forcecullbackfaces correctpixelstretch`. Flags enum: `r_data/models.h:48-62`.
    Model transform: `models.cpp:149-195`.
C3. **RenderStyles**: Add (blend SRC_ALPHA,ONE, additive fog `hw_sprites.cpp:162-165`); Add+fullbright may become ColorAdd when
    gl_usecolorblending (`:121-127`); Shaded/AddShaded use TM_ALPHATEXTURE (alpha = luminance), so an alpha-test on luminance applies on the hand layer.
    Brightmaps are disabled for non-Add translucent styles (`:117-120`).
C4. **Sprites**: FLATSPRITE uses yaw/pitch/roll, a fully oriented quad (`hw_sprites.cpp:376-403`). WALLSPRITE, ROLLSPRITE, FORCEXYBILLBOARD,
    BILLBOARDFACECAMERA (`:411-430`). Billboards use the per-eye HWAngles. A sprite **with nonzero Vel within 2 units XY of the eye is culled**
    (`:889-893`; models are exempt).
C5. **Dynamic lights**: A_AttachLight (`actor.zs:1336-1338`). Position is not interpolated (A4). Fine for wall spill; it steps at 35 Hz.
C6. **Bloom**: `gl_bloom` (default false, `hw_postprocess_cvars.cpp:30`). It runs per eye inside RenderViewpoint (`hw_entrypoint.cpp:198` → Pass1
    `hw_postprocess.cpp:1132-1137`). Extract: `max((color+0.001)*exposure - 1, 0)` (`shaders/pp/bloomextract.fp`), with
    exposure = 1/max(0.35 + light*1.3, 0.35) (`exposurecombine.fp`), i.e. ≈2.9 in dark scenes and ≈1 in bright ones. The scene buffer is RGBA16F
    (`gl_renderbuffers.cpp:198,207`). **Hand-layer pixels are in the scene buffer, so they bloom with zero lag and correct per-eye placement.**
    A mod can only enable it through a MENUDEF option (cvar rule above). It is global, and its screen-space radius is fixed by `gl_bloom_amount`.
C7. **Fullbright / brightmaps / GLDEFS glow**: these work as usual. The light multiplier is clamped (`main.fp:744`, `material_normal.fp:108,125`). Output >1 comes
    from Base.rgb>1 (custom shader) or from additive overlap. A dynamic light in range clamps that surface to ≤1 (`material_normal.fp:125`).
C8. **Dither-trans / Coronas / camera textures / portals**: coronas are disabled. Camera textures re-render the scene and don't help. Portals are irrelevant.
C9. **VisualThinker** (`zscript/visualthinker.zs`, `hw_sprites.cpp:1636-1705`): sprite-only billboards. They are **always NoAlphaTest** (fully soft,
    `:1704`) and interpolate Prev→Pos with writable `Prev` (`visualthinker.zs:3-4`), so the same prediction trick works. Roll needs SPF_ROLL. No models, no flat
    orientation. Cheaper than actors and good for glow dots.

---------------------------------------------------------------------------------------------------
## D. SHADERS AND OTHER CLEVER THINGS

D1. **GLDEFS material shaders on model skins: allowed.** Model skins are full-path textures created by CheckForTexture
    (`common/models/model.cpp:116-125`, `common/textures/texturemanager.cpp:248-262`). GLDEFS `material texture "models/x.png" { shader "..." }`
    resolves the same texture (`gldefs.cpp:1301`). FMaterial takes the user shader index when `gl_customshader` (default true, `hw_material.cpp:33`) is set
    and the shader type matches (`hw_material.cpp:128-140`). The HUD model path passes overrideshader -1 (`hw_models.cpp:130`), so the texture's own
    user shader is used for **both world and HUD models**.
    What the shader controls: `SetupMaterial`/`ProcessMaterial` sets `material.Base` (rgb **and the alpha that is alpha-tested**, `main.fp:877`).
    It can `discard`. It can read `pixelpos` (world pos), `vWorldNormal`, `vEyeNormal`, `uCameraPos` (per eye), `vTexCoord`, `vColor`, `timer`
    (`gl_shader.cpp:227-345`), and custom textures.
    What it cannot control: blend mode (RenderStyle), depth mask, depth test, depth range. gl_FragDepth is technically writable but clamped (B3).
    There is no depth-buffer sampler. **Use:** fresnel/view-angle falloff on cylinder shells for a volumetric look (world). Hand-layer core: Base.a=1 with soft or HDR rgb (>1 for bloom).
    Not tested in-engine.
D2. **Post-process shaders** (GLDEFS HardwareShader PostProcess, `hw_postprocess.cpp:936-1006`): inputs are only InputTexture + user textures + user
    uniforms (PPShader.SetUniform*). There is **no depth, no view/projection, and no eye index**, and the same uniforms are used for both eyes. They can't place a stereo-correct
    3D glow. **no.**
D3. **IQM + SetAnimationUI per-frame correction**: theoretically a ui handler could pick a pre-baked bone pose each frame to shift a world glow
    toward the live hand. It is quantized, one frame stale, and has a high authoring cost. **Exotic; not recommended.**

---------------------------------------------------------------------------------------------------
## TOP 5 LEVERS FOR A LAG-FREE VOLUMETRIC GLOW (ranked)

1. **World-layer additive shells + full interpolation-endpoint control (A3/A7).** Write Prev (writable) and the start/end angles
   (ClearInterpolation sandwich + INTERPOLATEANGLES) to *predicted* poses for t_N and t_N+T. Base this on per-frame-sampled AttackPos/Angle/Pitch/Roll,
   predicted body-relative. Shells keep soft alpha, write no depth and sort with sparks (C1). Feasibility: **high**. Pure ZScript; the risk is
   overshoot when the swing reverses (needs clamped/damped extrapolation).
2. **GLDEFS custom material shader on the shell skins (D1).** View-dependent (fresnel/rim) falloff from `vWorldNormal` and `uCameraPos`
   turns 1–2 cylinder or crossed-plane md3s into a convincing volume from every angle. It can add HDR rgb. Feasibility: **high-medium** (GLSL authoring;
   test that it compiles on the user's GPU).
3. **Bloom from the hand-layer core (C6).** The hand layer is zero-lag and in the per-eye scene buffer. A fullbright core already reaches the bloom
   threshold in dark/medium scenes, or use HDR via shader / overlapping additive layers. This gives a soft halo that is genuinely lag-free and stereo-correct, with no
   depth problem (post-pass). Feasibility: **medium**. It needs the user to enable gl_bloom (MENUDEF toggle), it is global, and it is untested in VR.
4. **Thin hand-layer inner glow (B2/D1).** An additive overlay layer (A_OverlayRenderStyle Add) whose shader outputs Base.a=1 with a soft rgb falloff,
   kept within ~1–2 blade radii. It is zero-lag but occludes world FX inside its silhouette (B3), so keep it thin. A dithered `discard` is an option.
   Feasibility: **medium**.
5. **Cheap soft fill: VisualThinker glow dots with predicted Prev (C9)** + **ModifyBobLayer3D per-frame flicker on the hand layer (B4).**
   VisualThinkers are fully soft and as cheap as particles, and the same prediction applies. Feasibility: **high** but cosmetic.
   (IQM SetAnimationUI correction, D3, is the only per-frame route to world geometry and is a research project.)

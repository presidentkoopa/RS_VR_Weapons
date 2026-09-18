# RS_VR_Weapons — netplay audit, part 2: cvars, hands, and the desktop player

Part 1 (`NETPLAY_AUDIT.md`, 424bc63) covered gameplay keyed to `consoleplayer` or to a local pose. Its
three real findings are **fixed** (0d0998d). This is the rest of what the build lane asked for, against
`Engine docs/CROSSPLATFORM_COOP_RULE.md`: one player in a headset, one at a desk with hands and body
toggled **off**, same exe, same load order, co-op.

---

## 5. `user` CVARS ON GAMEPLAY PATHS — and a correction to the rule

**A `user` cvar in CVARINFO is `CVAR_USERINFO`, and userinfo is networked.** `ForceSet` fires
`UserInfoChanged` on any `CVAR_USERINFO` change (`c_cvars.cpp:254`), which is how player colour, name and
skin already reach every machine. So every machine knows **every player's** value.

That makes the shape of the bug narrower than "a `user` cvar reached gameplay":

> **`CVar.GetCVar(name, thatPlayer)` on a `user` cvar is deterministic and safe** — every machine reads
> the same player's networked value.
> **`CVar.GetCVar(name, players[consoleplayer])` is the bug** — it asks about a *different player*
> depending on which machine is asking.

That is exactly the `wm_verbs` failure: not that it was `user`, but that it was read through
`consoleplayer` on a path that runs for everyone. A blanket "make them all `server`" would also be wrong
in the other direction — it would take away per-player seating and comfort settings that are correctly
personal.

**This package reads 37 `user` and 28 `server` cvars. None is undeclared.**

**Every accessor that takes a player passes the right one:**

| Accessor | Player it asks about | Verdict |
|---|---|---|
| `RS_ShieldSaw.cvNum/cvOn/cvInt` | `owner.player` — the weapon's own holder | correct |
| `RS_ShieldSaw.mountNum/mountMode` | `owner.player`, and defaults in multiplayer | correct |
| `RS_ShieldState.cvNum/cvOn` | the loop's `p` per player; `consoleplayer` only inside `pollLocalGrip`, which is console-local by design | correct |
| `RS_VRGrenade.Flag/Num` | **always `players[consoleplayer]`** | see below |
| `RS_ShieldSawWorld.Flag` | `consoleplayer`, drawing only | presentation |

**`RS_VRGrenade.Flag/Num` is the one risky shape, and it is currently safe by discipline rather than by
construction.** Every read is `consoleplayer`. It survives because:

- every grenade cvar that reaches gameplay is `server` — gravity, bounce, wallbounce, friction, fuse,
  cook, blast, autoarm, impact, dud_delay, dud_range, throw, throw_min, lift, enable, start. A `server`
  cvar ignores the player argument, so the `consoleplayer` is harmless;
- every `user` one it reads is either presentation (`flash`, `light`, `psprite`, `spin`, `spin_wrist`)
  or gesture-only (`face`, `face_near`, `face_far`, `face_hold`, `pin_reach`, `offhand_pin`), and the
  gesture block returns early for anyone but the local player.

**Recommended:** give `Flag/Num` an optional player argument defaulting to `consoleplayer` and pass
`Owner.player` from the gameplay paths. One cvar moved to `user` by a future edit currently turns into a
desync with nothing to catch it.

---

## 6. GAMEPLAY THAT NEEDS HANDS TO EXIST

Nothing in this package refuses gameplay because hands are absent, in the shape that broke the fire path
(`CanFire` answering "no hands, therefore no" everywhere but the hand-owner's machine). What it has
instead is **gameplay that can only be *started* by a hand**, which is the desktop problem below rather
than a desync.

The one structural risk is now closed: since 0d0998d the ShieldSaw's guard, lock cone and homing read a
**published** pose rather than the local device's, so a desktop player with no hands simply never
publishes one and every machine agrees about that.

---

## 7. THE DESKTOP PLAYER'S PATH TO EVERY ACTION — the real gaps

| Weapon | Action | Non-VR path? |
|---|---|---|
| ShieldSaw | draw | **Yes** — `rs-ss-toggle`, a bound key |
| ShieldSaw | stow | **Yes** — same key while drawn |
| ShieldSaw | recall in flight | **Yes** — same key while flying |
| ShieldSaw | **throw** | **NO.** The key's `SS_DRAWN` branch always stows. Throwing is decided by `HandMoving()` in the grip poll, which a desktop player never runs. **A desktop player can draw the shield and put it away, and can never throw it.** |
| ShieldSaw | grind / paint | Yes — psprite fire states, ordinary attack buttons |
| Grenade | select | Yes — slot 9 |
| Grenade | **pull the pin** | **NO.** Two routes only: the face dwell (needs `HmdPos`) and the off-hand reach (needs both palms, and ships off). There is no bound command for `rsvg-arm`. |
| Grenade | **throw** | **Effectively no.** The release is the throw, but the velocity comes from hand motion; a desktop player's release measures ~0 and the grenade drops at their feet — which since 09-18 is the *designed* behaviour for a still release. |
| Grenade | cook | Follows the pin — unreachable for the same reason |

**So on a desktop co-op machine today the grenade is inert and the shield is a melee weapon.** Both are
starting equipment in Vanilla and Vanilla+.

**Cheapest honest fixes, not built:**

- **ShieldSaw:** a second bound command, or a modifier on the existing one, that sends `rs-ss-throw` with
  a zero release velocity. `LaunchNow` already handles zero — it flies the aimed line. One `else if` in
  `NetworkProcess` and a KEYCONF alias.
- **Grenade:** a bound command that sends `rsvg-arm` for the held hand, and one that sends `rsvg-throw`
  with a forward velocity derived from the pawn's aim rather than a hand. Both events exist and are
  already applied identically on every machine; only the *trigger* is missing. Roughly twenty lines.

Neither needs engine work and neither touches the fire path.

---

**Status:** report only, as asked. Part 1's findings are fixed; nothing here is.

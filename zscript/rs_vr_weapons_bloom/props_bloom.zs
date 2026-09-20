// ==========================================================================
// THE BLOOM SET'S PROPS -- one per gun, the actor its card names.
//
// EVERY SET IS ITS OWN SET OF CARDS (the owner, 2026-09-20). Bloom used to have none: its guns
// named `model = BL_*`, so they drew as BLOOD'S props, off Blood's placement cvars. Tuning a
// Bloom gun moved the Blood one, and Bloom had no slider page because it had nothing of its own
// to point at. It does now.
//
// THE SAME MESH, A DIFFERENT DRAWING OF IT. WMCARD.bloom inherits Blood's measurements with
// `base =` and states only its own id and its own prop, so these eleven lines are the whole of
// what makes a Bloom gun a separate object to the renderer.
//
// THE NAMES ARE THE CARD'S, NOT A CHOICE. A prop class whose name does not match its card's
// `prop =` line resolves to nothing and the gun draws as a one-pixel sprite -- silently.
// ==========================================================================
class BM_Prop : WM_Prop {}

class BM_PropDynamite : BM_Prop {}
class BM_PropFlareGun : BM_Prop {}
class BM_PropLifeLeech : BM_Prop {}
class BM_PropNapalm : BM_Prop {}
class BM_PropPitchfork : BM_Prop {}
class BM_PropShotgun : BM_Prop {}
class BM_PropSprayCan : BM_Prop {}
class BM_PropTeslaGun : BM_Prop {}
class BM_PropTommyGun : BM_Prop {}
class BM_PropVoodoo : BM_Prop {}

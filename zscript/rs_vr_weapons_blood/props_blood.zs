// ==========================================================================
// THE BLOOD SET'S PROPS -- one per gun, the actor its card names.
//
// A prop is a drawing: MODELDEF binds the mesh to it and the renderer rides it on the
// controller. It carries no behaviour, which is why 11 of them are 11 lines.
//
// THE NAMES ARE THE CARD'S, NOT A CHOICE. A prop class whose name does not match its card's
// `prop =` line resolves to nothing and the gun draws as a one-pixel sprite -- silently.
// ==========================================================================
class BL_Prop : WM_Prop {}

class BL_PropFlareGun : BL_Prop {}
class BL_PropLifeLeech : BL_Prop {}
class BL_PropNapalm : BL_Prop {}
class BL_PropPitchfork : BL_Prop {}
class BL_PropShotgun : BL_Prop {}
class BL_PropSigil : BL_Prop {}
class BL_PropSprayCan : BL_Prop {}
class BL_PropTeslaGun : BL_Prop {}
class BL_PropDynamite : BL_Prop {}
class BL_PropTommyGun : BL_Prop {}
class BL_PropVoodoo : BL_Prop {}

// THE LIGHTER, a WEAPON in this set rather than a part of two others -- the owner resolved
// that by changing what the object IS. One surface, 77 vertices, no parts worth carding.
class BL_PropLighter : BL_Prop {}

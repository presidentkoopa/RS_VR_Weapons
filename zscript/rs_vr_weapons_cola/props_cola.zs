// ==========================================================================
// THE COLA 3 SET'S PROPS -- one per gun, the actor its card names.
//
// A prop is a drawing: MODELDEF binds the mesh to it and the renderer rides it on the
// controller. It carries no behaviour, which is why eight of them are eight lines.
//
// THE NAMES ARE THE CARD'S, NOT A CHOICE. A prop class whose name does not match its card's
// `prop =` line resolves to nothing and the gun draws as a one-pixel sprite.
// ==========================================================================
class CL_Prop : WM_Prop {}

class CL_PropRevolver : CL_Prop {}
class CL_PropKS23 : CL_Prop {}
class CL_PropJackhammer : CL_Prop {}
class CL_PropSidewinder : CL_Prop {}
class CL_PropPlasmaGun : CL_Prop {}
class CL_PropParticleGun : CL_Prop {}
class CL_PropFryPan : CL_Prop {}
class CL_PropCardDeck : CL_Prop {}

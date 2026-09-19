// ==========================================================================
// THE ROBOCOP SET'S PROPS -- one per gun, the actor its card names.
//
// A prop is a drawing: MODELDEF binds the mesh to it and the renderer rides it on the
// controller. It carries no behaviour, which is why 8 of them are 8 lines.
//
// THE NAMES ARE THE CARD'S, NOT A CHOICE. A prop class whose name does not match its card's
// `prop =` line resolves to nothing and the gun draws as a one-pixel sprite -- silently.
// ==========================================================================
class RC_Prop : WM_Prop {}

class RC_PropAuto9 : RC_Prop {}
class RC_PropChaingun : RC_Prop {}
class RC_PropChainsaw : RC_Prop {}
class RC_PropCobra : RC_Prop {}
class RC_PropKSG : RC_Prop {}
class RC_PropM27 : RC_Prop {}
class RC_PropM32 : RC_Prop {}
class RC_PropShotgun : RC_Prop {}

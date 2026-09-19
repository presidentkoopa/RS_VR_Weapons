// ==========================================================================
// THE HACX SET'S PROPS -- one per gun, the actor its card names.
//
// A prop is a drawing: MODELDEF binds the mesh to it and the renderer rides it on the
// controller. It carries no behaviour, which is why 9 of them are 9 lines.
//
// THE NAMES ARE THE CARD'S, NOT A CHOICE. A prop class whose name does not match its card's
// `prop =` line resolves to nothing and the gun draws as a one-pixel sprite -- silently.
// ==========================================================================
class HX_Prop : WM_Prop {}

class HX_PropCryogun : HX_Prop {}
class HX_PropMelee : HX_Prop {}
class HX_PropNuker : HX_Prop {}
class HX_PropPistol : HX_Prop {}
class HX_PropReznator : HX_Prop {}
class HX_PropStick : HX_Prop {}
class HX_PropTazer : HX_Prop {}
class HX_PropUzi : HX_Prop {}
class HX_PropZooka : HX_Prop {}

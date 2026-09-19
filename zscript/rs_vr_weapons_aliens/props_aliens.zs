// ==========================================================================
// THE ALIENS SET'S PROPS -- one per gun, the actor its card names.
//
// A prop is a drawing: MODELDEF binds the mesh to it and the renderer rides it on the
// controller. It carries no behaviour, which is why eight of them are eight lines.
//
// THE NAMES ARE THE CARD'S, NOT A CHOICE. A prop class whose name does not match its card's
// `prop =` line resolves to nothing and the gun draws as a one-pixel sprite.
//
// THESE WERE ALL NAMED WW2_Prop* WHEN THE SET ARRIVED -- the card generator had the prefix
// hardcoded, so a third set's name was stamped on two sets' props days after those very sets were
// renamed to stop exactly that collision. Fixed at the generator; the names below are AE_Prop*
// because that is what WMCARD.aliens now says.
// ==========================================================================
class AE_Prop : WM_Prop {}

class AE_PropM4A3 : AE_Prop {}
class AE_PropM37A2 : AE_Prop {}
class AE_PropPulseRifle : AE_Prop {}
class AE_PropSmartgun : AE_Prop {}
class AE_PropFlamer : AE_Prop {}
class AE_PropKnife : AE_Prop {}
class AE_PropPowerLoader : AE_Prop {}
class AE_PropSatchel : AE_Prop {}

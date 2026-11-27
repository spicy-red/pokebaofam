ExclamationText::
	text_far _ExclamationText
	text_end

GroundRoseText::
	text_far _GroundRoseText
	text_end

BoulderText::
	text_asm
	callfar CheckForStrength
	rst TextScriptEnd

MartSignText::
	text_far _MartSignText
	text_end

PokeCenterSignText::
	text_far _PokeCenterSignText
	text_end

PickUpItemText::
	text_asm
	predef PickUpItem
	rst TextScriptEnd

MonCouldSurfText:: ; bfe - HMs in overworld
    text_far _MonCouldSurfText
    text_end

SurfingGotOnText:: ; bfe - HMs in overworld, moved from item_effects.asm
    text_far _SurfingGotOnText
    text_end

CurrentTooFastOverworldText:: ; bfe - HMs in overworld
	text_far _CurrentTooFastOverworldText
	text_end

CyclingIsFunOverworldText:: ; bfe - HMs in overworld
	text_far _CyclingIsFunOverworldText
	text_end

TreeCanBeCutText:: ; bfe - HMs in overworld
    text_far _TreeCanBeCutText
    text_end

UsedCutText:: ; bfe - HMs in overworld, moved from cut.asm
	text_far _UsedCutText
	text_end

ThisRequiresStrengthText:: ; bfe - HMs in overworld
	text_far _BoulderText
	text_end

WantToStrengthText:: ; bfe - HMs in overworld
	text_far _WantToStrengthText
	text_end

CanMoveBouldersText:: ; bfe - HMs in overworld, moved from field_move_messages.asm
	text_far _CanMoveBouldersText
	text_end


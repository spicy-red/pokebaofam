WhichTechniqueString: ; bfe - modified to solve misprinting bug
;	db "WHICH TECHNIQUE?@"
	db   "MIMIC which move?"
	next "           @"

OldManName:
	db "OLD MAN@"

DisabledText: ; bfe - was "disabled!@", removed "!" for narrower box
	db "disabled@"

TypeText:
	db "TYPE@"

PowerText:    ; bfe - new
	db "PWR@"

AccuracyText: ; bfe - new
	db "ACC@"

PPText:       ; bfe - new
	db "PP@"

NoPowerText:  ; bfe - new
	db "-@"

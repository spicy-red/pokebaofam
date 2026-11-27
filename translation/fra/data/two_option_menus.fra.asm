NoYesMenuText:
	db   "NON"
	next "OUI@"

YesNoMenuText:
	db   "OUI"
	next "NON@"

BoyGirlMenuText: ; bfe - add female player
	db   "GARCON"
	next "FILLE@"

;SouthEastMenuText: ; bfe - unused
;	db   "SOUTH"
;	next "EAST@"

;NorthEastMenuText: ; bfe - unused
;	db   "NORTH"
;	next "EAST@"

TradeCancelMenuText:
	db   "ECHANGE"
	next "RETOUR@"

HealCancelMenuText:
	db   "SOIN"
	next "RETOUR@"

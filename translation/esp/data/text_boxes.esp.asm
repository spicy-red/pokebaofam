BuySellQuitText:
	db   "COMPRAR"
	next "VENDER"
	next "¡ADIÓS!@"

UseTossText:
	db   "USAR"
	next "TIRAR@"

UseSlctText: ; bfe - use items with SELECT
	db   "USAR"
	next "SLCT@"

MoneyText:
	db "DIN.@"

FloorText: ; bfe - new for elevator current floor
	db "PLANTA@"

BattleMenuText:
	db   "LUCHA <PK><MN>"
	next "OBJ.  ESC@"

SafariZoneBattleMenuText:
	db   "BALL×       CEBO"
	next "LANZA ROCA  CORRE@"

SwitchStatsCancelText:
	db   "CAMBIO"
	next "ESTAD."
	next "SALIR@"

MomDaisyCancelText: ; bfe - new for pay phones
	db   "MAMÁ"
	next "DALIA"
	next "SALIR@"

BuySellQuitText:
	db   "ACHETER"
	next "VENDRE"
	next "SALUT!@"

UseTossText:
	db   "UTIL."
	next "JETER@"

UseSlctText: ; bfe - use items with SELECT
	db   "UTIL."
	next "SLCT@"

MoneyText:
	db "ARG.@"

FloorText: ; bfe - new for elevator current floor
	db "ETAGE@"

BattleMenuText:
	db   "ATTAQ <PK><MN>"
	next "OBJET FUITE@"

SafariZoneBattleMenuText:
	db   "BALL×      APPAT"
	next "CAILLOU    FUITE@"

SwitchStatsCancelText:
	db   "ORDRE"
	next "STATS"
	next "RETOUR@"

MomDaisyCancelText: ; bfe - new for pay phones
	db   "MAMAN"
	next "NINA"
	next "RETOUR@"

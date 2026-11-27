	object_const_def
	const_export ROUTE22_RIVAL1
	const_export ROUTE22_RIVAL2

Route22_Object:
	db $2c ; border block

	def_warp_events
	warp_event  8,  7, ANY_DIR,    ROUTE_22_GATE, 1 ; bfe - modified to accommodate Route22OldRodHouse
	warp_event  9,  7, ANY_DIR,    ROUTE_22_GATE, 1 ; bfe - second gate entrance tile
	warp_event 33,  3, ANY_DIR,    ROUTE_22_OLD_ROD_HOUSE, 1 ; bfe - new location
	warp_event  1,  4, WARP_RIGHT, ROUTE_22_GATE, 5 ; bfe - added for access to Route28
	warp_event  1,  5, WARP_RIGHT, ROUTE_22_GATE, 6 ; bfe - added for access to Route28

	def_bg_events
	bg_event  7, 13, TEXT_ROUTE22_POKEMON_LEAGUE_SIGN ; bfe - modified to accommodate Route22OldRodHouse

	def_object_events
	object_event 25,  7, SPRITE_BLUE, STAY, NONE, TEXT_ROUTE22_RIVAL1 ; bfe - modified to accommodate Route22OldRodHouse
	object_event 25,  7, SPRITE_BLUE, STAY, NONE, TEXT_ROUTE22_RIVAL2 ; bfe - modified to accommodate Route22OldRodHouse

	def_warps_to ROUTE_22

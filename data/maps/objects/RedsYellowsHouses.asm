; bfe - merged RedsHouse floors, added Yellow's
	object_const_def
	const_export REDSHOUSE1F_MOM
	const_export YELLOWSHOUSE1F_DAD1   ; bfe - Yellow's dad unpacking
	const_export YELLOWSHOUSE1F_DAD2   ; bfe - Yellow's dad sitting
	const_export YELLOWSHOUSE2F_ASLEEP ; bfe - Yellow asleep
	const_export YELLOWSHOUSE2F_YELLOW ; bfe - Yellow

RedsYellowsHouses_Object:
	db $0 ; border block

	def_warp_events
	; Red's house
	warp_event  2,  7, WARP_DOWN, LAST_MAP, 1
	warp_event  3,  7, WARP_DOWN, LAST_MAP, 1
	warp_event  7,  1, ANY_DIR,   REDS_YELLOWS_HOUSES, 4 ; bfe - merged RedsHouse floors
	warp_event 21,  1, ANY_DIR,   REDS_YELLOWS_HOUSES, 3 ; bfe - merged RedsHouse floors
	; Yellow's house
	warp_event 30,  7, WARP_DOWN, LAST_MAP, 4
	warp_event 31,  7, WARP_DOWN, LAST_MAP, 4
	warp_event 35,  1, ANY_DIR,   REDS_YELLOWS_HOUSES, 8
	warp_event 49,  1, ANY_DIR,   REDS_YELLOWS_HOUSES, 7

	def_bg_events
	bg_event  3,  1, TEXT_REDSHOUSE1F_TV
	bg_event  7,  6, TEXT_REDSHOUSE1F_PHONE         ; bfe - new
	bg_event 17,  5, TEXT_REDSHOUSE2F_SNES          ; bfe - moved from hidden objects
	bg_event 31,  1, TEXT_YELLOWSHOUSE1F_TV         ; bfe - new for Yellow's house
	bg_event 44,  1, TEXT_YELLOWSHOUSE2F_GAMEBOY    ; bfe - new for Yellow's bedroom
	bg_event 43,  4, TEXT_YELLOWSHOUSE2F_TV         ; bfe - new for Yellow's bedroom
	bg_event 35,  2, TEXT_YELLOWSHOUSE_UNPACKED_BOX ; bfe - new for Yellow's house
	bg_event 28,  3, TEXT_YELLOWSHOUSE_UNPACKED_BOX ; bfe - new for Yellow's house
	bg_event 35,  4, TEXT_YELLOWSHOUSE_UNPACKED_BOX ; bfe - new for Yellow's house
	bg_event 29,  6, TEXT_YELLOWSHOUSE_UNPACKED_BOX ; bfe - new for Yellow's house
	bg_event 34,  7, TEXT_YELLOWSHOUSE_UNPACKED_BOX ; bfe - new for Yellow's house
	bg_event 48,  3, TEXT_YELLOWSHOUSE_UNPACKED_BOX ; bfe - new for Yellow's house
	bg_event 47,  6, TEXT_YELLOWSHOUSE_UNPACKED_BOX ; bfe - new for Yellow's house

	def_object_events
	object_event  5,  4, SPRITE_MOM, STAY, LEFT, TEXT_REDSHOUSE1F_MOM
	object_event 29,  3, SPRITE_DAD, WALK, UP_DOWN, TEXT_YELLOWSHOUSE1F_DAD_UNPACKING ; bfe - Yellow's dad
	object_event 33,  4, SPRITE_DAD, STAY, LEFT, TEXT_YELLOWSHOUSE1F_DAD_SITTING      ; bfe - Yellow's dad
	object_event 42,  6, SPRITE_YELLOW_ASLEEP, STAY, NONE, TEXT_YELLOWSHOUSE2F_ASLEEP ; bfe - Yellow asleep
	object_event 31,  3, SPRITE_RED, WALK, ANY_DIR, TEXT_YELLOWSHOUSE2F_YELLOW        ; bfe - Odo

	def_warps_to REDS_YELLOWS_HOUSES

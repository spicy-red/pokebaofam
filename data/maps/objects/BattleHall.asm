; bfe - new location
	object_const_def
	const_export BAO_1
	const_export APPRENTICE
	const_export BAO_2
	const_export BAO_3
	const_export BAO_4
	const_export BAO_5
	const_export BAO_6
	const_export BAO_7
	const_export BAO_8
	const_export BAO_9
	const_export BAO_10
	const_export BATTLEHALL_RECEPTIONIST

BattleHall_Object:
	db $0e ; border block

	def_warp_events
	warp_event 11,  9, ANY_DIR, ROUTE_22_GATE, 9 ; entry coordinates; exit is scripted

	def_bg_events
	bg_event 11,  9, TEXT_BATTLEHALL_EXIT  ; Exit prompt

	def_object_events
	; All Elite Baos and Apprentice at position (4,6) - only one visible at a time via toggles
	object_event  4,  6, SPRITE_RED,    STAY, RIGHT, TEXT_ELITE_BAO_1,  OPP_ELITE_BAO, 1  ; BAO SNOOPY (text ptr 1)
	object_event  4,  6, SPRITE_GREEN,  STAY, RIGHT, TEXT_APPRENTICE,  OPP_BAO_APPRENTICE, 1 ; APPRENTICE (text ptr 2)
	object_event  4,  6, SPRITE_GREEN,  STAY, RIGHT, TEXT_ELITE_BAO_2,  OPP_ELITE_BAO, 2  ; FILLER2 (text ptr 3)
	object_event  4,  6, SPRITE_GREEN,  STAY, RIGHT, TEXT_ELITE_BAO_3,  OPP_ELITE_BAO, 3  ; FILLER3 (text ptr 4)
	object_event  4,  6, SPRITE_GREEN,  STAY, RIGHT, TEXT_ELITE_BAO_4,  OPP_ELITE_BAO, 4  ; FILLER4 (text ptr 5)
	object_event  4,  6, SPRITE_GREEN,  STAY, RIGHT, TEXT_ELITE_BAO_5,  OPP_ELITE_BAO, 5  ; FILLER5 (text ptr 6)
	object_event  4,  6, SPRITE_GREEN,  STAY, RIGHT, TEXT_ELITE_BAO_6,  OPP_ELITE_BAO, 6  ; FILLER6 (text ptr 7)
	object_event  4,  6, SPRITE_GREEN,  STAY, RIGHT, TEXT_ELITE_BAO_7,  OPP_ELITE_BAO, 7  ; FILLER7 (text ptr 8)
	object_event  4,  6, SPRITE_GREEN,  STAY, RIGHT, TEXT_ELITE_BAO_8,  OPP_ELITE_BAO, 8  ; FILLER8 (text ptr 9)
	object_event  4,  6, SPRITE_GREEN,  STAY, RIGHT, TEXT_ELITE_BAO_9,  OPP_ELITE_BAO, 9  ; FILLER9 (text ptr 10)
	object_event  4,  6, SPRITE_GREEN,  STAY, RIGHT, TEXT_ELITE_BAO_10, OPP_ELITE_BAO, 10 ; FILLER10 (text ptr 11)
	object_event 10,  4, SPRITE_LINK_RECEPTIONIST, STAY, DOWN, TEXT_BATTLEHALL_RECEPTIONIST ; RECEPTIONIST (text ptr 12)

	def_warps_to BATTLE_HALL
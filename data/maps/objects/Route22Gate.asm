	object_const_def
	const_export ROUTE22GATE_GUARD
	const_export ROUTE22GATE_GUARD2        ; bfe - new guard
	const_export ROUTE22GATE_COOLTRAINER_M ; bfe - new NPC
	const_export ROUTE22GATE_COOLTRAINER_F ; bfe - new NPC
	const_export ROUTE22GATE_YOUNGSTER     ; bfe - new NPC
	const_export ROUTE22GATE_RECEPTIONIST  ; bfe - new NPC

Route22Gate_Object:
	db $0 ; border block

	def_warp_events
	warp_event 12,  7, WARP_DOWN, ROUTE_22, 1 ; bfe - adjusted coords, was LAST_MAP
	warp_event 13,  7, WARP_DOWN, ROUTE_22, 1 ; bfe - adjusted coords, was LAST_MAP
	warp_event 12,  0, ANY_DIR,   ROUTE_23, 1 ; bfe - adjusted coords, was LAST_MAP
	warp_event 13,  0, ANY_DIR,   ROUTE_23, 2 ; bfe - adjusted coords, was LAST_MAP
	warp_event  0,  3, WARP_LEFT, ROUTE_22, 4 ; Route 22 warp 3 is the fishing house
	warp_event  0,  4, WARP_LEFT, ROUTE_22, 5 ; west passage toward Route 28
	warp_event  7,  7, ANY_DIR,   ROUTE_22_GATE, 8 ; bfe - added 2nd floor
	warp_event 25,  7, ANY_DIR,   ROUTE_22_GATE, 7 ; bfe - added 2nd floor
	warp_event 35,  7, ANY_DIR,   BATTLE_HALL, 1   ; bfe - added 3rd floor

	def_bg_events
	; bfe - binoculars are handled as hidden object

	def_object_events
	object_event 14,  2, SPRITE_GUARD, STAY, LEFT, TEXT_ROUTE22GATE_GUARD  ; bfe - adjusted coords
	object_event  3,  1, SPRITE_GUARD, STAY, DOWN, TEXT_ROUTE22GATE_GUARD2 ; bfe - new guard
	object_event  8,  2, SPRITE_COOLTRAINER_M, WALK, UP_DOWN, TEXT_ROUTE22GATE_COOLTRAINER_M    ; bfe - new NPC
	object_event 31,  3, SPRITE_COOLTRAINER_F, WALK, LEFT_RIGHT, TEXT_ROUTE22GATE_COOLTRAINER_F ; bfe - new NPC
	object_event 26,  5, SPRITE_YOUNGSTER, STAY, RIGHT, TEXT_ROUTE22GATE_YOUNGSTER              ; bfe - new NPC
	object_event 34,  4, SPRITE_LINK_RECEPTIONIST, STAY, DOWN, TEXT_ROUTE22GATE_RECEPTIONIST    ; bfe - new NPC

	def_warps_to ROUTE_22_GATE

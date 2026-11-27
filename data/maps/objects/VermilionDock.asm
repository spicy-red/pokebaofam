	object_const_def
	const_export VERMILIONDOCK_SAILOR ; bfe - new

VermilionDock_Object:
	db $f ; border block

	def_warp_events
	warp_event 38,  0, WARP_UP,   VERMILION_CITY, 10    ; bfe - new dock
	warp_event 38,  3, WARP_DOWN, CITRUS_FERRY_DECK, 1  ; bfe - new dock
	warp_event 14,  0, WARP_UP,   VERMILION_CITY, 6     ; bfe - was LAST_MAP
	warp_event 14,  2, WARP_DOWN, SS_ANNE_1F, 2

	def_bg_events

	def_object_events
	object_event 38,  3, SPRITE_SAILOR, STAY, UP, TEXT_VERMILIONDOCK_SAILOR ; bfe - new

	def_warps_to VERMILION_DOCK

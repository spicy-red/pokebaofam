; bfe - merged 4F 5F + new 6F
	object_const_def
	const_export CELADONMART4F_CLERK
	const_export CELADONMART4F_SUPER_NERD
	const_export CELADONMART4F_YOUNGSTER
	const_export CELADONMART5F_GENTLEMAN
	const_export CELADONMART5F_SAILOR
	const_export CELADONMART5F_CLERK1
	const_export CELADONMART5F_CLERK2
	const_export CELADONMART6F_CLERK             ; bfe - new floor
	const_export CELADONMART6F_BEAUTY            ; bfe - new floor
	const_export CELADONMART6F_MIDDLE_AGED_WOMAN ; bfe - new floor

CeladonMart4F5F6F_Object:
	db $f ; border block

	def_warp_events
	warp_event 12, 29, ANY_DIR, CELADON_MART_1F2F3F, 10 ; bfe - 4F going downstairs
	warp_event 16, 29, ANY_DIR, CELADON_MART_4F5F6F, 5 ; bfe - 4F going upstairs
	warp_event  1, 29, ANY_DIR, CELADON_MART_ELEVATOR, 1 ; bfe - elevator 4F
	warp_event 12, 15, ANY_DIR, CELADON_MART_4F5F6F, 7 ; bfe - 5F going upstairs
	warp_event 16, 15, ANY_DIR, CELADON_MART_4F5F6F, 2 ; bfe - 5F going downstairs
	warp_event  1, 15, ANY_DIR, CELADON_MART_ELEVATOR, 1 ; bfe - elevator 5F
	warp_event 12,  1, ANY_DIR, CELADON_MART_4F5F6F, 4 ; bfe - 6F going downstairs
	warp_event 16,  1, ANY_DIR, CELADON_MART_ROOF, 1 ; bfe - 6F going upstairs
	warp_event  1,  1, ANY_DIR, CELADON_MART_ELEVATOR, 1 ; bfe - elevator 6F

	def_bg_events
	bg_event 14, 29, TEXT_CELADONMART4F_CURRENT_FLOOR_SIGN
	bg_event 14, 15, TEXT_CELADONMART5F_CURRENT_FLOOR_SIGN
	bg_event 14,  1, TEXT_CELADONMART6F_CURRENT_FLOOR_SIGN ; bfe - new floor

	def_object_events
	object_event  5, 35, SPRITE_CLERK, STAY, NONE, TEXT_CELADONMART4F_CLERK
	object_event 15, 33, SPRITE_SUPER_NERD, WALK, LEFT_RIGHT, TEXT_CELADONMART4F_SUPER_NERD
	object_event  5, 30, SPRITE_YOUNGSTER, WALK, LEFT_RIGHT, TEXT_CELADONMART4F_YOUNGSTER
	object_event 14, 19, SPRITE_GENTLEMAN, WALK, UP_DOWN, TEXT_CELADONMART5F_GENTLEMAN
	object_event  2, 20, SPRITE_SAILOR, STAY, NONE, TEXT_CELADONMART5F_SAILOR
	object_event  5, 17, SPRITE_CLERK, STAY, DOWN, TEXT_CELADONMART5F_CLERK1
	object_event  6, 17, SPRITE_CLERK, STAY, DOWN, TEXT_CELADONMART5F_CLERK2
	object_event 10,  5, SPRITE_CLERK, STAY, RIGHT, TEXT_CELADONMART6F_CLERK                           ; bfe - new floor
	object_event 15,  6, SPRITE_BEAUTY, STAY, UP, TEXT_CELADONMART6F_BEAUTY                            ; bfe - new floor
	object_event  4,  4, SPRITE_MIDDLE_AGED_WOMAN, WALK, UP_DOWN, TEXT_CELADONMART6F_MIDDLE_AGED_WOMAN ; bfe - new floor

	def_warps_to CELADON_MART_4F5F6F

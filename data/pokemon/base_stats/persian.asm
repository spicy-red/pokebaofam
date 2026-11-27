	db DEX_PERSIAN ; pokedex id

	db  65,  70,  60, 115,  65
	;   hp  atk  def  spd  spc

	db NORMAL, NORMAL ; type
	db 90 ; catch rate
	db 148 ; base exp

	db SPRITE_DIM_LARGE ; bfe - modified data structure
	dw PersianPics
	dw 0 ; empty

	db SCRATCH, GROWL, NO_MOVE, NO_MOVE ; level 1 learnset ; bfe - removed BITE and SCREECH
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	; bfe - added CUT
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  BUBBLEBEAM,   \
	     WATER_GUN,    HYPER_BEAM,   PAY_DAY,      RAGE,         THUNDERBOLT,  \
	     THUNDER,      MIMIC,        DOUBLE_TEAM,  BIDE,         SWIFT,        \
	     SKULL_BASH,   REST,         SUBSTITUTE,   CUT
	; end

	; bfe - improve Pokemon picture system tutorial
	db BANK(PersianPicFront)
	assert BANK(PersianPicFront) == BANK(PersianPicBack)

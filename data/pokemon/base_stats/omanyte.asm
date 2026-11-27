	db DEX_OMANYTE ; pokedex id

	db  35,  40, 100,  35,  100
	;   hp  atk  def  spd  spc

	db ROCK, WATER ; type
	db 45 ; catch rate
	db 120 ; base exp

	db SPRITE_DIM_SMALL ; bfe - modified data structure
	dw OmanytePics
	dw 0 ; empty

	db CONSTRICT, WITHDRAW, NO_MOVE, NO_MOVE ; level 1 learnset ; bfe - replaced WATER_GUN by CONSTRICT
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  BUBBLEBEAM,   \
	     WATER_GUN,    ICE_BEAM,     BLIZZARD,     RAGE,         MIMIC,        \
	     DOUBLE_TEAM,  REFLECT,      BIDE,         REST,         SUBSTITUTE,   \
	     SURF
	; end

	; bfe - improve Pokemon picture system tutorial
	db BANK(OmanytePicFront)
	assert BANK(OmanytePicFront) == BANK(OmanytePicBack)

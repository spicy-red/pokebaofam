	db DEX_TENTACRUEL ; pokedex id

	db  80,  70,  65, 110, 120
	;   hp  atk  def  spd  spc

	db WATER, POISON ; type
	db 60 ; catch rate
	db 205 ; base exp

	db SPRITE_DIM_MEDIUM ; bfe - modified data structure
	dw TentacruelPics
	dw 0 ; empty

	db POISON_STING, NO_MOVE, NO_MOVE, NO_MOVE ; level 1 learnset ; bfe - changed from ACID, SUPERSONIC, WRAP, NO_MOVE
	db GROWTH_SLOW ; growth rate

	; tm/hm learnset
	; bfe - added HEX
	tmhm SWORDS_DANCE, TOXIC,        TAKE_DOWN,    DOUBLE_EDGE,  BUBBLEBEAM,   \
	     WATER_GUN,    ICE_BEAM,     BLIZZARD,     HYPER_BEAM,   RAGE,         \
	     MEGA_DRAIN,   MIMIC,        DOUBLE_TEAM,  REFLECT,      BIDE,         \
	     SKULL_BASH,   REST,         SUBSTITUTE,   CUT,          SURF,         \
	     HEX
	; end

	; bfe - improve Pokemon picture system tutorial
	db BANK(TentacruelPicFront)
	assert BANK(TentacruelPicFront) == BANK(TentacruelPicBack)

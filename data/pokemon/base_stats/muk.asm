	db DEX_MUK ; pokedex id

	db 120, 105, 105,  50, 120
	;   hp  atk  def  spd  spc

	db POISON, POISON ; type
	db 75 ; catch rate
	db 157 ; base exp

	db SPRITE_DIM_LARGE ; bfe - modified data structure
	dw MukPics
	dw 0 ; empty

	db POUND, DISABLE, NO_MOVE, NO_MOVE ; level 1 learnset ; bfe - removed POISON_GAS
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	; bfe - added STRENGTH, HEX
	tmhm TOXIC,        BODY_SLAM,    HYPER_BEAM,   RAGE,         MEGA_DRAIN,   \
	     THUNDERBOLT,  THUNDER,      MIMIC,        DOUBLE_TEAM,  BIDE,         \
	     SELFDESTRUCT, FIRE_BLAST,   REST,         EXPLOSION,    SUBSTITUTE,   \
	     STRENGTH,     HEX
	; end

	; bfe - improve Pokemon picture system tutorial
	db BANK(MukPicFront)
	assert BANK(MukPicFront) == BANK(MukPicBack)

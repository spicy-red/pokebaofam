	db DEX_KOFFING ; pokedex id

	db  40,  65,  95,  35,  60
	;   hp  atk  def  spd  spc

	db POISON, POISON ; type
	db 190 ; catch rate
	db 114 ; base exp

	db SPRITE_DIM_MEDIUM ; bfe - modified data structure
	dw KoffingPics
	dw 0 ; empty

	db TACKLE, POISON_GAS, NO_MOVE, NO_MOVE ; level 1 learnset ; bfe - replaced SMOG by POISON_GAS
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	; bfe - added DOUBLE_EDGE
	tmhm TOXIC,        RAGE,         THUNDERBOLT,  THUNDER,      MIMIC,        \
	     DOUBLE_TEAM,  BIDE,         SELFDESTRUCT, FIRE_BLAST,   REST,         \
	     EXPLOSION,    SUBSTITUTE,   DOUBLE_EDGE
	; end

	; bfe - improve Pokemon picture system tutorial
	db BANK(KoffingPicFront)
	assert BANK(KoffingPicFront) == BANK(KoffingPicBack)

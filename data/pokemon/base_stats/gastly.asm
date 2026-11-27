	db DEX_GASTLY ; pokedex id

	db  30,  35,  30,  80, 100
	;   hp  atk  def  spd  spc

	db GHOST, POISON ; type
	db 190 ; catch rate
	db 95 ; base exp

	db SPRITE_DIM_LARGE ; bfe - modified data structure
	dw GastlyPics
	dw 0 ; empty

	db LICK, NO_MOVE, NO_MOVE, NO_MOVE ; level 1 learnset ; bfe - removed CONFUSE_RAY, NIGHT_SHADE
	db GROWTH_MEDIUM_SLOW ; growth rate

	; tm/hm learnset
	; bfe - added HEX
	tmhm TOXIC,        RAGE,         MEGA_DRAIN,   THUNDERBOLT,  THUNDER,      \
	     PSYCHIC_M,    MIMIC,        DOUBLE_TEAM,  BIDE,         SELFDESTRUCT, \
	     DREAM_EATER,  REST,         PSYWAVE,      EXPLOSION,    SUBSTITUTE,   \
	     HEX
	; end

	; bfe - improve Pokemon picture system tutorial
	db BANK(GastlyPicFront)
	assert BANK(GastlyPicFront) == BANK(GastlyPicBack)

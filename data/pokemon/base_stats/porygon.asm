	db DEX_PORYGON ; pokedex id

	db  85, 110,  85, 100, 100
	;   hp  atk  def  spd  spc

	db NORMAL, NORMAL ; type
	db 45 ; catch rate
	db 130 ; base exp

	db SPRITE_DIM_MEDIUM ; bfe - modified data structure
	dw PorygonPics
	dw 0 ; empty

	db TACKLE, CONVERSION, NO_MOVE, NO_MOVE ; level 1 learnset ; bfe - removed SHARPEN
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	; bfe - added FIRE_BLAST
	tmhm TOXIC,        TAKE_DOWN,    DOUBLE_EDGE,  ICE_BEAM,     BLIZZARD,     \
	     HYPER_BEAM,   RAGE,         THUNDERBOLT,  THUNDER,      PSYCHIC_M,    \
	     TELEPORT,     MIMIC,        DOUBLE_TEAM,  REFLECT,      BIDE,         \
	     SWIFT,        SKULL_BASH,   REST,         THUNDER_WAVE, PSYWAVE,      \
	     TRI_ATTACK,   SUBSTITUTE,   FLASH,        FIRE_BLAST
	; end

	; bfe - improve Pokemon picture system tutorial
	db BANK(PorygonPicFront)
	assert BANK(PorygonPicFront) == BANK(PorygonPicBack)

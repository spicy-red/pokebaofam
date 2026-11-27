	db DEX_FLAREON ; pokedex id

	db  90, 130,  90,  65, 130
	;   hp  atk  def  spd  spc

	db FIRE, FIRE ; type
	db 45 ; catch rate
	db 198 ; base exp

	db SPRITE_DIM_MEDIUM ; bfe - modified data structure
	dw FlareonPics
	dw 0 ; empty

	db TACKLE, SAND_ATTACK, NO_MOVE, NO_MOVE ; level 1 learnset ; bfe - removed QUICK_ATTACK, EMBER
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	; bfe - added SOLARBEAM, FLASH
	tmhm TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  HYPER_BEAM,   \
	     RAGE,         MIMIC,        DOUBLE_TEAM,  REFLECT,      BIDE,         \
	     FIRE_BLAST,   SWIFT,        SKULL_BASH,   REST,         SUBSTITUTE,   \
	     SOLARBEAM,    FLASH
	; end

	; bfe - improve Pokemon picture system tutorial
	db BANK(FlareonPicFront)
	assert BANK(FlareonPicFront) == BANK(FlareonPicBack)

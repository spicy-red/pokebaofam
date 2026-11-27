	db DEX_TANGELA ; pokedex id

	db 130,  20, 130,  60, 130
	;   hp  atk  def  spd  spc

	db GRASS, GRASS ; type
	db 45 ; catch rate
	db 166 ; base exp

	db SPRITE_DIM_MEDIUM ; bfe - modified data structure
	dw TangelaPics
	dw 0 ; empty

	db CONSTRICT, NO_MOVE, NO_MOVE, NO_MOVE ; level 1 learnset ; bfe - removed BIND
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm SWORDS_DANCE, TOXIC,        BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  \
	     HYPER_BEAM,   RAGE,         MEGA_DRAIN,   SOLARBEAM,    MIMIC,        \
	     DOUBLE_TEAM,  BIDE,         SKULL_BASH,   REST,         SUBSTITUTE,   \
	     CUT
	; end

	; bfe - improve Pokemon picture system tutorial
	db BANK(TangelaPicFront)
	assert BANK(TangelaPicFront) == BANK(TangelaPicBack)

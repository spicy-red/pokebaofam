	db DEX_PONYTA ; pokedex id

	db  50,  85,  55,  90,  65
	;   hp  atk  def  spd  spc

	db FIRE, FIRE ; type
	db 190 ; catch rate
	db 152 ; base exp

	db SPRITE_DIM_MEDIUM ; bfe - modified data structure
	dw PonytaPics
	dw 0 ; empty

	db EMBER, TAIL_WHIP, NO_MOVE, NO_MOVE ; level 1 learnset ; bfe - added TAIL_WHIP
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset ; bfe - added MEGA_KICK
	tmhm TOXIC,        HORN_DRILL,   BODY_SLAM,    TAKE_DOWN,    DOUBLE_EDGE,  \
	     RAGE,         MIMIC,        DOUBLE_TEAM,  REFLECT,      BIDE,         \
	     FIRE_BLAST,   SWIFT,        SKULL_BASH,   REST,         SUBSTITUTE,   \
	     MEGA_KICK
	; end

	; bfe - improve Pokemon picture system tutorial
	db BANK(PonytaPicFront)
	assert BANK(PonytaPicFront) == BANK(PonytaPicBack)

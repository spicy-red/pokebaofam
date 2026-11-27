	db DEX_FARFETCHD ; pokedex id

	db  52, 100,  55,  60,  58
	;   hp  atk  def  spd  spc

	db NORMAL, FLYING ; type
	db 45 ; catch rate
	db 94 ; base exp

	db SPRITE_DIM_MEDIUM ; bfe - modified data structure
	dw FarfetchdPics
	dw 0 ; empty

	db PECK, SHARPEN, NO_MOVE, NO_MOVE ; level 1 learnset ; bfe - replaced SAND_ATTACK with SHARPEN
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	; bfe - added SKY_ATTACK
	tmhm RAZOR_WIND,   SWORDS_DANCE, WHIRLWIND,    TOXIC,        BODY_SLAM,    \
	     TAKE_DOWN,    DOUBLE_EDGE,  RAGE,         MIMIC,        DOUBLE_TEAM,  \
	     REFLECT,      BIDE,         SWIFT,        SKULL_BASH,   REST,         \
	     SUBSTITUTE,   CUT,          FLY,          SKY_ATTACK
	; end

	; bfe - improve Pokemon picture system tutorial
	db BANK(FarfetchdPicFront)
	assert BANK(FarfetchdPicFront) == BANK(FarfetchdPicBack)

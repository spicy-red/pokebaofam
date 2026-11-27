	db DEX_FEAROW ; pokedex id

	db  65,  90,  65, 100,  61
	;   hp  atk  def  spd  spc

	db NORMAL, FLYING ; type
	db 90 ; catch rate
	db 162 ; base exp

	db SPRITE_DIM_LARGE ; bfe - modified data structure
	dw FearowPics
	dw 0 ; empty

	db PECK, GROWL, NO_MOVE, NO_MOVE ; level 1 learnset ; bfe - removed LEER
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	tmhm RAZOR_WIND,   WHIRLWIND,    TOXIC,        TAKE_DOWN,    DOUBLE_EDGE,  \
	     HYPER_BEAM,   RAGE,         MIMIC,        DOUBLE_TEAM,  BIDE,         \
	     SWIFT,        SKY_ATTACK,   REST,         SUBSTITUTE,   FLY
	; end

	; bfe - improve Pokemon picture system tutorial
	db BANK(FearowPicFront)
	assert BANK(FearowPicFront) == BANK(FearowPicBack)

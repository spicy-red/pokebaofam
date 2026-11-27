	db DEX_KAKUNA ; pokedex id

	db  45,  25,  50,  35,  25
	;   hp  atk  def  spd  spc

	db BUG, POISON ; type
	db 120 ; catch rate
	db 71 ; base exp

	db SPRITE_DIM_SMALL ; bfe - modified data structure
	dw KakunaPics
	dw 0 ; empty

	db POISON_STING, STRING_SHOT, HARDEN, NO_MOVE ; level 1 learnset ; bfe - added POISON_STING and STRING_SHOT
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	; bfe - added TAKE_DOWN and DOUBLE_EDGE
	tmhm TAKE_DOWN,    DOUBLE_EDGE
	; end

	; bfe - improve Pokemon picture system tutorial
	db BANK(KakunaPicFront)
	assert BANK(KakunaPicFront) == BANK(KakunaPicBack)

	db DEX_WEEZING ; pokedex id

	db 100,  90, 120,  60, 100 
	;   hp  atk  def  spd  spc

	db POISON, POISON ; type
	db 60 ; catch rate
	db 173 ; base exp

	db SPRITE_DIM_LARGE ; bfe - modified data structure
	dw WeezingPics
	dw 0 ; empty

	db TACKLE, POISON_GAS, NO_MOVE, NO_MOVE ; level 1 learnset ; bfe - changed from TACKLE, SMOG, SLUDGE, NO_MOVE
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	; bfe - added DOUBLE_EDGE
	tmhm TOXIC,        HYPER_BEAM,   RAGE,         THUNDERBOLT,  THUNDER,      \
	     MIMIC,        DOUBLE_TEAM,  BIDE,         SELFDESTRUCT, FIRE_BLAST,   \
	     REST,         EXPLOSION,    SUBSTITUTE,   DOUBLE_EDGE
	; end

	; bfe - improve Pokemon picture system tutorial
	db BANK(WeezingPicFront)
	assert BANK(WeezingPicFront) == BANK(WeezingPicBack)

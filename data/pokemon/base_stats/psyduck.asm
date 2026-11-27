	db DEX_PSYDUCK ; pokedex id

	db  50,  52,  48,  55,  50
	;   hp  atk  def  spd  spc

	db WATER, WATER ; type
	db 190 ; catch rate
	db 80 ; base exp

	db SPRITE_DIM_SMALL ; bfe - modified data structure
	dw PsyduckPics
	dw 0 ; empty

	db SCRATCH, TAIL_WHIP, NO_MOVE, NO_MOVE ; level 1 learnset ; bfe - added TAIL_WHIP
	db GROWTH_MEDIUM_FAST ; growth rate

	; tm/hm learnset
	; bfe - added PSYCHIC_M
	tmhm MEGA_PUNCH,   MEGA_KICK,    TOXIC,        BODY_SLAM,    TAKE_DOWN,    \
	     DOUBLE_EDGE,  BUBBLEBEAM,   WATER_GUN,    ICE_BEAM,     BLIZZARD,     \
	     PAY_DAY,      SUBMISSION,   COUNTER,      SEISMIC_TOSS, RAGE,         \
	     DIG,          MIMIC,        DOUBLE_TEAM,  BIDE,         SWIFT,        \
	     SKULL_BASH,   REST,         SUBSTITUTE,   SURF,         STRENGTH,     \
	     PSYCHIC_M
	; end

	; bfe - improve Pokemon picture system tutorial
	db BANK(PsyduckPicFront)
	assert BANK(PsyduckPicFront) == BANK(PsyduckPicBack)

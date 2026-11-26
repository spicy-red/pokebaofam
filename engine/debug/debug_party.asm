SetDebugNewGameParty: ; unreferenced except in _DEBUG
	ld de, DebugNewGameParty
.loop
	ld a, [de]
	cp -1
	ret z
	ld [wCurPartySpecies], a
	inc de
	ld a, [de]
	ld [wCurEnemyLevel], a
	inc de
	call AddPartyMon
	push de
	call MaxDebugPartyMonStatExp
	pop de
	jr .loop

; Maximize the newly added party member's stat experience, then apply it.
MaxDebugPartyMonStatExp:
	ld a, [wCurPartySpecies]
	ld [wCurSpecies], a
	call GetMonHeader
	ld a, [wPartyCount]
	dec a
	ld hl, wPartyMon1HPExp
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	push hl
	ld a, $ff
	ld bc, NUM_STATS * 2
	call FillMemory
	pop hl

	; CalcStats expects the byte before HP experience and writes all five stats.
	push hl
	ld bc, MON_STATS - MON_HP_EXP
	add hl, bc
	ld d, h
	ld e, l
	pop hl
	dec hl
	push de
	ld b, 1 ; include stat experience
	call CalcStats
	pop hl ; maximum HP

	; Start at full health after increasing maximum HP.
	ld d, h
	ld e, l
	ld bc, MON_HP - MON_MAXHP
	add hl, bc
	push hl
	push de
	pop hl
	pop de
	ld bc, 2
	jp CopyData


DebugNewGameParty: ; unreferenced except in _DEBUG
	; Exeggutor is the only debug party member shared with Red, Green, and Japanese Blue.
	; "Tsunekazu Ishihara: Exeggutor is my favorite. That's because I was
	; always using this character while I was debugging the program."
	; From https://web.archive.org/web/20000607152840/http://pocket.ign.com/news/14973.html
	db EXEGGUTOR, 100
	db ONIX, 100
	db JYNX, 100
	db CHANSEY, 100
	db VENUSAUR, 100
	db CROBAT, 100
	db -1 ; end

SetDebugNewGameMoves:
	ld hl, DebugNewGameMoves
	ld de, wPartyMon1Moves
	ld b, PARTY_LENGTH
.loop
	push bc
	ld bc, NUM_MOVES
	call CopyData

	; Move from the end of the moves to the start of this member's PP.
	push hl
	ld hl, wPartyMon1PP - wPartyMon1Moves - NUM_MOVES
	add hl, de
	ld d, h
	ld e, l
	pop hl
	ld bc, NUM_MOVES
	call CopyData

	; Advance to the next party member's moves.
	push hl
	ld hl, wPartyMon2Moves - wPartyMon1PP - NUM_MOVES
	add hl, de
	ld d, h
	ld e, l
	pop hl
	pop bc
	dec b
	jr nz, .loop
	ret

DebugNewGameMoves:
	; Preserve Exeggutor's debug HM moves and PP.
	db FLY, CUT, SURF, STRENGTH
	db 15, 25, 15, 15
	; Onix
	db FISSURE, EARTHQUAKE, REST, SUBSTITUTE
	db 15, 15, 10, 10
	; Jynx
	db LOVELY_KISS, PSYCHIC_M, BLIZZARD, DREAM_EATER
	db 25, 25, 15, 15
	; Chansey
	db SOFTBOILED, FIRE_BLAST, THUNDERBOLT, BLIZZARD
	db 10, 15, 25, 15
	; Venusaur
	db RAZOR_LEAF, REST, LEECH_SEED, TOXIC
	db 25, 10, 10, 10
	; Crobat 
	db TOXIC, BRAVE_BIRD, SUBSTITUTE, HAZE 
	db 10, 15, 10, 10
	ASSERT @ - DebugNewGameMoves == PARTY_LENGTH * NUM_MOVES * 2

SetDebugNewGameBoxes: ; marcelnote - added boxed mons to debug
	ld hl, DebugNewGameBox1
	call LoadDebugBoxData
	xor a ; PLAYER_PARTY_DATA
	ld [wCurrentBoxNum], a
	ld [wMonDataLocation], a
	ret

LoadDebugBoxData:
	push hl
	xor a
	ld hl, wBoxDataStart
	ld bc, wBoxDataEnd - wBoxDataStart
	call FillMemory
	ld hl, wBoxSpecies + MONS_PER_BOX
	ld [hl], $ff
	pop de
.loop
	ld a, [de]
	cp -1
	ret z
	ld [wCurPartySpecies], a
	ld [wEnemyMonSpecies2], a
	inc de
	ld a, [de]
	ld [wCurEnemyLevel], a
	inc de
	push de
	xor a
	ld [wEnemyBattleStatus3], a
	ld [wIsInBattle], a
	callfar LoadEnemyMonData
	call AddDebugBoxMon
	pop de
	jr .loop

AddDebugBoxMon:
	ld hl, wBoxCount
	ld a, [hl]
	cp MONS_PER_BOX
	ret nc
	ld [wPlayerMonNumber], a
	inc [hl]

	ld c, a
	ld b, 0
	ld hl, wBoxSpecies
	add hl, bc
	ld a, [wCurPartySpecies]
	ld [hl], a

	ld hl, wBoxMons
	ld bc, BOXMON_STRUCT_LENGTH
	ld a, [wPlayerMonNumber]
	call AddNTimes
	ld d, h
	ld e, l
	callfar CopyEnemyMonToBoxSlot

	ld hl, wBoxMonOT
	ld a, [wPlayerMonNumber]
	call SkipNameEntries
	ld d, h
	ld e, l
	ld hl, wPlayerName
	ld bc, NAME_LENGTH
	call CopyData

	ld hl, wBoxMonNicks
	ld a, [wPlayerMonNumber]
	call SkipNameEntries
	ld d, h
	ld e, l
	ld hl, wEnemyMonNick
	ld bc, NAME_LENGTH
	jp CopyData

DebugNewGameBox1:
	db BULBASAUR, 12
	db CHARMANDER, 14
	db SQUIRTLE, 13
	db PIKACHU, 18
	db CLEFAIRY, 20
	db ZUBAT, 22
	db ODDISH, 24
	db DIGLETT, 26
	db ABRA, 28
	db MACHOP, 30
	db SNORLAX, 30
	db GASTLY, 23
	db -1 ; end

PrepareNewGameDebug: ; dummy except in _DEBUG
IF DEF(_DEBUG)
	xor a ; PLAYER_PARTY_DATA
	ld [wMonDataLocation], a

	; Fly anywhere.
	dec a ; $ff (all bits)
	ld [wTownVisitedFlag], a
	ld [wTownVisitedFlag + 1], a

	; Get all badges except Earth Badge.
	ld a, ~(1 << BIT_EARTHBADGE)
	ld [wObtainedBadges], a

	call SetDebugNewGameParty
	call SetDebugNewGameBoxes

	call SetDebugNewGameMoves

	SetEvent EVENT_PASSED_SENIOR_TEST

	; Get some debug items.
	ld hl, wNumBagItems
	ld de, DebugNewGameItemsList
.itemsLoop
	ld a, [de]
	cp -1
	jr z, .itemsEnd
	ld [wCurItem], a
	inc de
	ld a, [de]
	inc de
	ld [wItemQuantity], a
	call AddItemToInventory
	jr .itemsLoop
.itemsEnd

	; Get some more debug items. ; marcelnote - new for Key items pocket
	ld hl, wNumBagKeyItems
	ld de, DebugKeyItemsList
.keyItemsLoop
	ld a, [de]
	cp -1
	jr z, .keyItemsEnd
	ld [wCurItem], a
	inc de
	ld a, [de]
	inc de
	ld [wItemQuantity], a
	call AddItemToInventory
	jr .keyItemsLoop
.keyItemsEnd

	; Complete the Pokédex.
	ld hl, wPokedexOwned
	call DebugSetPokedexEntries
	ld hl, wPokedexSeen
	call DebugSetPokedexEntries
	SetEvent EVENT_GOT_POKEDEX

	; Set money
	ld hl, wPlayerMoney
	ld a, $90 ; 900 000
	ld [hli], a
	xor a
	ld [hli], a
	ld [hli], a

	; Set coins
	ld [hl], $90


	; Rival chose Squirtle,
	; Player chose Charmander.
	ld hl, wRivalStarter
	ASSERT wRivalStarter + 2 == wPlayerStarter
	ld a, STARTER2
	ld [hli], a
	inc hl ; hl = wPlayerStarter
	ld a, STARTER1
	ld [hl], a

	ret

DebugSetPokedexEntries:
IF NUM_POKEMON / 8 != 0
	ld b, NUM_POKEMON / 8 ; 151 / 8 == 18
	ld a, %11111111
.loop
	ld [hli], a
	dec b
	jr nz, .loop
ENDC
IF NUM_POKEMON % 8 != 0
	ld [hl], (1 << (NUM_POKEMON % 8)) - 1 ; (1 << 151 % 8)) - 1 == %01111111
ENDC
	ret

DebugNewGameItemsList: ; marcelnote - moved some to key items pocket
	;db BICYCLE, 1
	db MASTER_BALL, 99
	db RARE_CANDY, 99
	db FULL_RESTORE, 99
	db FULL_HEAL, 99
	db ESCAPE_ROPE, 99
	db MAX_ELIXIR, 99 ; marcelnote - added
	db BOTTLE_CAP, 10 ; marcelnote - added
;	db TOWN_MAP, 1
;	db SECRET_KEY, 1
;	db CARD_KEY, 1
;	db S_S_TICKET, 1
;	db LIFT_KEY, 1
	db TM_TELEPORT, 1
	db TM_DIG, 1
	db TM_SOFTBOILED, 1
	db -1 ; end

DebugKeyItemsList:    ; marcelnote - new for Key Items pocket
	db BICYCLE, 1
	db TOWN_MAP, 1
	db POKE_BEEPER, 1 ; marcelnote - added
	db OLD_ROD, 1
	db ITEMFINDER, 1
	db POKE_FLUTE, 1
	db SECRET_KEY, 1
	db CARD_KEY, 1
	db S_S_TICKET, 1
	db LIFT_KEY, 1
	db SILPH_SCOPE, 1 ; marcelnote - added
	db CITRUS_PASS, 1 ; marcelnote - added
	db COIN_CASE, 1 ; marcelnote - added
;	db SURFBOARD, 1 ; marcelnote - added
	db HM_CUT, 1 ; marcelnote - added
	db HM_FLY, 1 ; marcelnote - added
	db HM_SURF, 1 ; marcelnote - added
	db HM_STRENGTH, 1 ; marcelnote - added
	db HM_FLASH, 1 ; marcelnote - added
	db -1 ; end

ELSE
	ret
ENDC

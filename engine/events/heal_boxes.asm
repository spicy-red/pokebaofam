; Nurse Joy only: heal the live box in WRAM and the inactive boxes in SRAM.
; No box swapping or saving the current game: the active box's SRAM slot is
; deliberately empty, and sCurBoxData remains part of the last manual save.
ASSERT BANK("Saved Boxes 1") == 2 && BANK("Saved Boxes 2") == 3
ASSERT sBox7 == sBox1
ASSERT sBank3AllBoxesChecksum == sBank2AllBoxesChecksum
ASSERT sBank3IndividualBoxChecksums == sBank2IndividualBoxChecksums

HealAllBoxes::
	ld a, [wCurEnemyLevel]
	push af
	ld a, [wCurSpecies]
	push af

	ld hl, wBoxDataStart
	call HealBox
	ld a, [wCurrentBoxNum]
	bit BIT_HAS_CHANGED_BOXES, a
	jr z, .done ; other SRAM boxes are uninitialized until the first box change

	ld a, RAMG_SRAM_ENABLE
	ld [rRAMG], a
	ld a, BMODE_ADVANCED
	ld [rBMODE], a
	ld a, BANK("Saved Boxes 1")
	call .healBank
	ld a, BANK("Saved Boxes 2")
	call .healBank
	xor a
	ld [rBMODE], a
	ld [rRAMG], a
.done
	pop af
	ld [wCurSpecies], a
	pop af
	ld [wCurEnemyLevel], a
	ret

.healBank
	ld [rRAMB], a
	ld hl, sBox1 ; same addresses for boxes 7-12 in the second SRAM bank
	ld b, NUM_BOXES / 2
.box
	push bc
	push hl
	call HealBox
	pop hl
	ld bc, wBoxDataEnd - wBoxDataStart
	add hl, bc
	pop bc
	dec b
	jr nz, .box
	jpfar UpdateStoredBoxChecksums

; hl = box start. Use the species list to handle both sparse slots and legacy
; contiguous boxes with an early $ff terminator. Never touch an empty record.
HealBox:
	ld a, [hli]
	and a
	ret z
	push hl
	ld de, wBoxMons - wBoxSpecies
	add hl, de
	ld d, h
	ld e, l
	pop hl
	ld b, MONS_PER_BOX
.slot
	ld a, [hli]
	cp $ff
	ret z
	and a
	jr z, .next
	push bc
	push hl
	push de
	call HealBoxMon
	pop de
	pop hl
	pop bc
.next
	push hl
	ld hl, BOXMON_STRUCT_LENGTH
	add hl, de
	ld d, h
	ld e, l
	pop hl
	dec b
	jr nz, .slot
	ret

; de = boxed record. Work in the existing loaded-mon buffer so calculations
; never mistake a 33-byte box record for a 44-byte party record.
HealBoxMon:
	push de
	ld h, d
	ld l, e
	ld de, wLoadedMon
	ld bc, BOXMON_STRUCT_LENGTH
	call CopyData
	ld a, [wLoadedMonSpecies]
	ld [wCurSpecies], a
	call GetMonHeader
; Depositing/catching records the level here, as used by the box status screen.
; Avoid an expensive level-from-experience scan for every stored Pokemon.
	ld a, [wLoadedMonBoxLevel]
	ld [wCurEnemyLevel], a
	ld hl, wLoadedMonHPExp - 1
	lb bc, 1, 1 ; include stat experience, calculate HP only
	call CalcStat
	ldh a, [hQuotient + 2]
	ld [wLoadedMonHP], a
	ldh a, [hQuotient + 3]
	ld [wLoadedMonHP + 1], a
	xor a
	ld [wLoadedMonStatus], a

	ld hl, wLoadedMonMoves
	ld de, wLoadedMonPP
	ld b, NUM_MOVES
.move
	ld a, [hli]
	and a
	jr z, .nextMove
	push bc
	push hl
	push de
	ld h, d
	ld l, e
	call HealBoxMovePP
	pop de
	pop hl
	pop bc
.nextMove
	inc de
	dec b
	jr nz, .move

; Copy back only the healed fields; retain experience, DVs, levels and names.
	pop de
	inc de ; MON_HP
	ld hl, wLoadedMonHP
	ld bc, 2
	call CopyData
	inc de ; skip MON_BOX_LEVEL
	xor a
	ld [de], a ; MON_STATUS
	ld hl, MON_PP - MON_STATUS
	add hl, de
	ld d, h
	ld e, l
	ld hl, wLoadedMonPP
	ld bc, NUM_MOVES
	jp CopyData

; a = move, hl = PP byte. Apply the same capped PP Up rule as AddBonusPP,
; using Divide directly because AddBonusPP assumes its caller shares bank 3.
HealBoxMovePP:
	push hl
	dec a
	ld hl, Moves
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld de, wMoveData
	ld a, BANK(Moves)
	call FarCopyData
	pop hl
	ld a, [wMoveData + MOVE_PP]
	ld b, a
	ld a, [hl]
	and PP_UP_MASK
	add b
	ld [hl], a
	and PP_UP_MASK
	ret z
	swap a
	srl a
	srl a
	ld c, a ; PP Ups used
	ld a, b ; base PP
	ldh [hDividend + 3], a
	xor a
	ldh [hDividend], a
	ldh [hDividend + 1], a
	ldh [hDividend + 2], a
	ld a, 5
	ldh [hDivisor], a
	call Divide
	ldh a, [hQuotient + 3]
	cp 8
	jr c, .bonus
	ld a, 7
.bonus
	ld b, a
	ld a, [hl]
.addBonus
	add b
	dec c
	jr nz, .addBonus
	ld [hl], a
	ret

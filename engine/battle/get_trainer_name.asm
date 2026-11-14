GetTrainerName::
	ld hl, wLinkEnemyTrainerName
	ld a, [wLinkState]
	and a
	jr nz, .foundName
	ld hl, wRivalName
	ld a, [wTrainerClass]
	cp ELITE_BAO
	jr z, .eliteBaoName
	cp RIVAL1
	jr z, .foundName
	cp RIVAL2
	jr z, .foundName
	cp RIVAL3
	jr z, .foundName
	ld [wNamedObjectIndex], a ; marcelnote - GetName optim
	ld a, TRAINER_NAME
	ld [wNameListType], a
	ld a, BANK(TrainerNames)
	ld [wPredefBank], a
	call GetName ; stores name in wNameBuffer
	ld hl, wNameBuffer
	jr .foundName
.eliteBaoName
	ld a, [wTrainerNo]
	dec a
	add a
	ld c, a
	ld b, 0
	ld hl, EliteBaoNamePointers
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
.foundName
	ld de, wTrainerName
	ld bc, TRAINER_NAME_LENGTH
	jp CopyData

EliteBaoNamePointers:
	dw .Name1
	dw .Name2
	dw .Name3
	dw .Name4
	dw .Name5
	dw .Name6
	dw .Name7
	dw .Name8
	dw .Name9
	dw .Name10
.Name1
	db "BAO SNOOPY@"
	ds TRAINER_NAME_LENGTH - (@ - .Name1), $50
.Name2
	db "BAO FILLER2@"
	ds TRAINER_NAME_LENGTH - (@ - .Name2), $50
.Name3
	db "BAO FILLER3@"
	ds TRAINER_NAME_LENGTH - (@ - .Name3), $50
.Name4
	db "BAO FILLER4@"
	ds TRAINER_NAME_LENGTH - (@ - .Name4), $50
.Name5
	db "BAO FILLER5@"
	ds TRAINER_NAME_LENGTH - (@ - .Name5), $50
.Name6
	db "BAO FILLER6@"
	ds TRAINER_NAME_LENGTH - (@ - .Name6), $50
.Name7
	db "BAO FILLER7@"
	ds TRAINER_NAME_LENGTH - (@ - .Name7), $50
.Name8
	db "BAO FILLER8@"
	ds TRAINER_NAME_LENGTH - (@ - .Name8), $50
.Name9
	db "BAO FILLER9@"
	ds TRAINER_NAME_LENGTH - (@ - .Name9), $50
.Name10
	db "BAO FILLER10@"
	ds TRAINER_NAME_LENGTH - (@ - .Name10), $50

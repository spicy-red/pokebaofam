; marcelnote - new floor for Elite Baos gauntlet (20 battles: 10 Apprentices + 10 Elite Baos)
; wBattleHallState: bits 0-2 = curScript (0-6), bits 3-7 = battleIndex (0-19)
; battleIndex even (0,2,4...18) = Apprentices 1-10 (level 110)
; battleIndex odd (1,3,5...19) = Elite Baos 1-10 (level 130)
BattleHall_Script:
	call EnableAutoTextBoxDrawing
	ld hl, BattleHall_ScriptPointers
	ld a, [wBattleHallState]
	and $07 ; mask lower 3 bits for script state
	jp CallFunctionInTable

BattleHall_ScriptPointers:
	def_script_pointers
	dw_const BattleHallSetUpScript,         SCRIPT_BATTLEHALL_DEFAULT
	dw_const BattleHallMovePlayerScript,    SCRIPT_BATTLEHALL_MOVE_PLAYER
	dw_const BattleHallPlayerMovingScript,  SCRIPT_BATTLEHALL_PLAYER_MOVING
	dw_const BattleHallStartBattleScript,   SCRIPT_BATTLEHALL_START_BATTLE
	dw_const BattleHallPostBattleScript,    SCRIPT_BATTLEHALL_POST_BATTLE
	dw_const BattleHallExitPromptScript,    SCRIPT_BATTLEHALL_EXIT_PROMPT
	dw_const BattleHallExitWarpScript,      SCRIPT_BATTLEHALL_EXIT_WARP

; Set up which sprite is visible based on battleIndex (0-19)
BattleHallSetUpScript:
	; The stair warp is handled here so leaving always requires confirmation.
	ld a, [wYCoord]
	cp 9
	jr nz, .setUpOpponent
	ld a, [wXCoord]
	cp 11
	jr nz, .setUpOpponent
	; A map load can leave the player facing down on the arrival stair.
	; Move into the room before accepting exit requests, including on reload.
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_LOADED_1, [hl]
	jp nz, BattleHallStepOffStairs
	; Stepping onto the stair requests exit from any approach direction.
	ld a, TEXT_BATTLEHALL_EXIT
	ldh [hTextID], a
	jp DisplayTextID
.setUpOpponent
	ld a, [wBattleHallState]
	and $F8 ; get battleIndex (upper 5 bits)
	rrca
	rrca
	rrca ; shift right 3 to get battleIndex 0-19
	cp 20
	jr z, .completed
	jr nc, .resetProgress
	ld l, a
	ld h, 0
	add hl, hl ; multiply by 2 for word table
	ld de, BattleHallShowSpritePointers
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl
.completed
	ld hl, wCurrentMapScriptFlags
	res BIT_CUR_MAP_LOADED_1, [hl]
	jp BattleHallHideOpponents
.resetProgress
	xor a
	ld [wBattleHallState], a
	jp showApprentice

BattleHallShowSpritePointers:
	dw showApprentice
	dw showEliteBao1
	dw showApprentice
	dw showEliteBao2
	dw showApprentice
	dw showEliteBao3
	dw showApprentice
	dw showEliteBao4
	dw showApprentice
	dw showEliteBao5
	dw showApprentice
	dw showEliteBao6
	dw showApprentice
	dw showEliteBao7
	dw showApprentice
	dw showEliteBao8
	dw showApprentice
	dw showEliteBao9
	dw showApprentice
	dw showEliteBao10

showEliteBao1:
	ld a, TOGGLE_BAO_1
	jp BattleHallShowOpponent

showEliteBao2:
	ld a, TOGGLE_BAO_2
	jp BattleHallShowOpponent

showEliteBao3:
	ld a, TOGGLE_BAO_3
	jp BattleHallShowOpponent

showEliteBao4:
	ld a, TOGGLE_BAO_4
	jp BattleHallShowOpponent

showEliteBao5:
	ld a, TOGGLE_BAO_5
	jp BattleHallShowOpponent

showEliteBao6:
	ld a, TOGGLE_BAO_6
	jp BattleHallShowOpponent

showEliteBao7:
	ld a, TOGGLE_BAO_7
	jp BattleHallShowOpponent

showEliteBao8:
	ld a, TOGGLE_BAO_8
	jp BattleHallShowOpponent

showEliteBao9:
	ld a, TOGGLE_BAO_9
	jp BattleHallShowOpponent

showEliteBao10:
	ld a, TOGGLE_BAO_10
	jp BattleHallShowOpponent

showApprentice:
	ld a, TOGGLE_APPRENTICE
	jp BattleHallShowOpponent

; Only update sprites when the opponent changes. Preserve the packed progress.
BattleHallShowOpponent:
	push af
	; Older saves have zeroes in the newly allocated toggle flags. Rebuild
	; visibility on map entry even if the selected opponent looks visible.
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_LOADED_1, [hl]
	res BIT_CUR_MAP_LOADED_1, [hl]
	jr nz, .refresh
	ld c, a
	ld b, FLAG_TEST
	ld hl, wToggleableObjectFlagsCont
	predef FlagActionPredef
	ld a, c
	and a
	jr nz, .refresh
	pop af
	ret ; already visible
.refresh
	call BattleHallHideOpponents
	pop af
	ld [wToggleableObjectIndex], a
	predef_jump ShowObjectCont

BattleHallHideOpponents:
	ld hl, .ToggleIDs
	ld b, 11
.loop
	ld a, [hli]
	push hl
	push bc
	ld c, a
	ld b, FLAG_SET
	ld hl, wToggleableObjectFlagsCont
	predef FlagActionPredef
	pop bc
	pop hl
	dec b
	jr nz, .loop
	jp UpdateSprites
.ToggleIDs
	db TOGGLE_BAO_1, TOGGLE_APPRENTICE, TOGGLE_BAO_2, TOGGLE_BAO_3
	db TOGGLE_BAO_4, TOGGLE_BAO_5, TOGGLE_BAO_6, TOGGLE_BAO_7
	db TOGGLE_BAO_8, TOGGLE_BAO_9, TOGGLE_BAO_10

BattleHallMovePlayerScript:
	ld a, PAD_BUTTONS | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld hl, wSimulatedJoypadStatesEnd
	ld a, [wSpritePlayerStateData1FacingDirection]
	cp SPRITE_FACING_LEFT
	ld de, .SpriteOnRightMovement
	jr z, .decodeList
	cp SPRITE_FACING_RIGHT
	ld de, .SpriteOnLeftMovement
	jr z, .decodeList
	cp SPRITE_FACING_UP
	ld de, .SpriteOnBottomMovement
	jr z, .decodeList
	ld de, .SpriteOnTopMovement
.decodeList
	call DecodeRLEList
	ld [wSimulatedJoypadStatesIndex], a
	call StartSimulatingJoypadStates
	ld a, [wBattleHallState]
	and $F8 ; preserve battleIndex bits
	or SCRIPT_BATTLEHALL_PLAYER_MOVING
	ld [wBattleHallState], a
	ret

.SpriteOnRightMovement:
	db 2, PAD_RIGHT
	db -1 ; end

.SpriteOnLeftMovement:
	db 1, PAD_DOWN
	db 4, PAD_RIGHT
	db 1, PAD_UP
	db -1 ; end

.SpriteOnTopMovement:
	db 1, PAD_DOWN
	db 3, PAD_RIGHT
	db -1 ; end

.SpriteOnBottomMovement:
	db 1, PAD_UP
	db 3, PAD_RIGHT
	db -1 ; end

BattleHallPlayerMovingScript:
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	ld a, SPRITE_FACING_RIGHT
	ldh [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
	ld a, PLAYER_DIR_LEFT
	ld [wPlayerMovingDirection], a
	ld a, [wBattleHallState]
	and $F8 ; preserve battleIndex bits
	or SCRIPT_BATTLEHALL_START_BATTLE
	ld [wBattleHallState], a
	ret

BattleHallStartBattleScript:
	ld c, 30
	call DelayFrames
	call EngageMapTrainer
	; EngageMapTrainer reads the shared Apprentice object as set 1. Select
	; its numbered encounter before InitBattleEnemyParameters copies it.
	ld a, [wBattleHallState]
	and $F8
	rrca
	rrca
	rrca
	srl a
	inc a
	ld [wEngagedTrainerSet], a
	call InitBattleEnemyParameters
	ld a, [wBattleHallState]
	and $F8 ; preserve battleIndex bits
	or SCRIPT_BATTLEHALL_POST_BATTLE
	ld [wBattleHallState], a
	ret

BattleHallPostBattleScript:
	xor a
	ld [wJoyIgnore], a
	ld a, [wBattleResult]
	and a
	jr nz, .lost
	; Advancing the upper five bits also returns the script to DEFAULT.
	ld a, [wBattleHallState]
	and $F8
	add 1 << 3
	ld [wBattleHallState], a
	cp 20 << 3
	ret nz
	SetEvent EVENT_BATTLED_BATTLE_HALL_TRAINER
	jp BattleHallHideOpponents
.lost
	xor a
	ld [wBattleHallState], a
	ResetEvent EVENT_BATTLED_BATTLE_HALL_TRAINER
	ret

BattleHall_TextPointers:
	def_text_pointers
	dw_const EliteBao1Text,        TEXT_ELITE_BAO_1      ; 1: BAO_1
	dw_const ApprenticeText,       TEXT_APPRENTICE       ; 2: APPRENTICE (all 10)
	dw_const EliteBao2Text,        TEXT_ELITE_BAO_2      ; 3: BAO_2
	dw_const EliteBao3Text,        TEXT_ELITE_BAO_3      ; 4: BAO_3
	dw_const EliteBao4Text,        TEXT_ELITE_BAO_4      ; 5: BAO_4
	dw_const EliteBao5Text,        TEXT_ELITE_BAO_5      ; 6: BAO_5
	dw_const EliteBao6Text,        TEXT_ELITE_BAO_6      ; 7: BAO_6
	dw_const EliteBao7Text,        TEXT_ELITE_BAO_7      ; 8: BAO_7
	dw_const EliteBao8Text,        TEXT_ELITE_BAO_8      ; 9: BAO_8
	dw_const EliteBao9Text,        TEXT_ELITE_BAO_9      ; 10: BAO_9
	dw_const EliteBao10Text,       TEXT_ELITE_BAO_10     ; 11: BAO_10
	dw_const BattleHallReceptionistText, TEXT_BATTLEHALL_RECEPTIONIST ; 12: RECEPTIONIST
	dw_const BattleHallExitText,           TEXT_BATTLEHALL_EXIT          ; 13: bg_event

EliteBao1Text:
	text_asm
	ld hl, .PreBattleText
	call PrintText
	ld a, [wPartyCount]
	cp 6
	jr nz, .textScriptEnd
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld hl, .TrainerDefeatedText
	ld de, .TrainerDefeatedText
	call SaveEndBattleTextPointers
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	ld a, [wBattleHallState]
	and $F8 ; preserve battleIndex bits
	or SCRIPT_BATTLEHALL_MOVE_PLAYER
	ld [wBattleHallState], a
.textScriptEnd
	rst TextScriptEnd

.PreBattleText:
	text_far _EliteBao1BattleText
	text_end

.TrainerDefeatedText:
	text_far _EliteBao1DefeatedText
	text_end

ApprenticeText:
	text_asm
	ld hl, .PreBattleText
	call PrintText
	ld a, [wPartyCount]
	cp 6
	jr nz, .textScriptEnd
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld hl, .TrainerDefeatedText
	ld de, .TrainerDefeatedText
	call SaveEndBattleTextPointers
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	ld a, [wBattleHallState]
	and $F8 ; preserve battleIndex bits
	or SCRIPT_BATTLEHALL_MOVE_PLAYER
	ld [wBattleHallState], a
.textScriptEnd
	rst TextScriptEnd

.PreBattleText:
	text_far _ApprenticeBattleText
	text_end

.TrainerDefeatedText:
	text_far _ApprenticeDefeatedText
	text_end

EliteBao2Text:
	text_asm
	ld hl, .PreBattleText
	call PrintText
	ld a, [wPartyCount]
	cp 6
	jr nz, .textScriptEnd
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld hl, .TrainerDefeatedText
	ld de, .TrainerDefeatedText
	call SaveEndBattleTextPointers
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	ld a, [wBattleHallState]
	and $F8 ; preserve battleIndex bits
	or SCRIPT_BATTLEHALL_MOVE_PLAYER
	ld [wBattleHallState], a
.textScriptEnd
	rst TextScriptEnd

.PreBattleText:
	text_far _EliteBao2BattleText
	text_end

.TrainerDefeatedText:
	text_far _EliteBao2DefeatedText
	text_end

EliteBao3Text:
	text_asm
	ld hl, .PreBattleText
	call PrintText
	ld a, [wPartyCount]
	cp 6
	jr nz, .textScriptEnd
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld hl, .TrainerDefeatedText
	ld de, .TrainerDefeatedText
	call SaveEndBattleTextPointers
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	ld a, [wBattleHallState]
	and $F8 ; preserve battleIndex bits
	or SCRIPT_BATTLEHALL_MOVE_PLAYER
	ld [wBattleHallState], a
.textScriptEnd
	rst TextScriptEnd

.PreBattleText:
	text_far _EliteBao3BattleText
	text_end

.TrainerDefeatedText:
	text_far _EliteBao3DefeatedText
	text_end

EliteBao4Text:
	text_asm
	ld hl, .PreBattleText
	call PrintText
	ld a, [wPartyCount]
	cp 6
	jr nz, .textScriptEnd
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld hl, .TrainerDefeatedText
	ld de, .TrainerDefeatedText
	call SaveEndBattleTextPointers
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	ld a, [wBattleHallState]
	and $F8 ; preserve battleIndex bits
	or SCRIPT_BATTLEHALL_MOVE_PLAYER
	ld [wBattleHallState], a
.textScriptEnd
	rst TextScriptEnd

.PreBattleText:
	text_far _EliteBao4BattleText
	text_end

.TrainerDefeatedText:
	text_far _EliteBao4DefeatedText
	text_end

EliteBao5Text:
	text_asm
	ld hl, .PreBattleText
	call PrintText
	ld a, [wPartyCount]
	cp 6
	jr nz, .textScriptEnd
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld hl, .TrainerDefeatedText
	ld de, .TrainerDefeatedText
	call SaveEndBattleTextPointers
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	ld a, [wBattleHallState]
	and $F8 ; preserve battleIndex bits
	or SCRIPT_BATTLEHALL_MOVE_PLAYER
	ld [wBattleHallState], a
.textScriptEnd
	rst TextScriptEnd

.PreBattleText:
	text_far _EliteBao5BattleText
	text_end

.TrainerDefeatedText:
	text_far _EliteBao5DefeatedText
	text_end

EliteBao6Text:
	text_asm
	ld hl, .PreBattleText
	call PrintText
	ld a, [wPartyCount]
	cp 6
	jr nz, .textScriptEnd
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld hl, .TrainerDefeatedText
	ld de, .TrainerDefeatedText
	call SaveEndBattleTextPointers
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	ld a, [wBattleHallState]
	and $F8 ; preserve battleIndex bits
	or SCRIPT_BATTLEHALL_MOVE_PLAYER
	ld [wBattleHallState], a
.textScriptEnd
	rst TextScriptEnd

.PreBattleText:
	text_far _EliteBao6BattleText
	text_end

.TrainerDefeatedText:
	text_far _EliteBao6DefeatedText
	text_end

EliteBao7Text:
	text_asm
	ld hl, .PreBattleText
	call PrintText
	ld a, [wPartyCount]
	cp 6
	jr nz, .textScriptEnd
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld hl, .TrainerDefeatedText
	ld de, .TrainerDefeatedText
	call SaveEndBattleTextPointers
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	ld a, [wBattleHallState]
	and $F8 ; preserve battleIndex bits
	or SCRIPT_BATTLEHALL_MOVE_PLAYER
	ld [wBattleHallState], a
.textScriptEnd
	rst TextScriptEnd

.PreBattleText:
	text_far _EliteBao7BattleText
	text_end

.TrainerDefeatedText:
	text_far _EliteBao7DefeatedText
	text_end

EliteBao8Text:
	text_asm
	ld hl, .PreBattleText
	call PrintText
	ld a, [wPartyCount]
	cp 6
	jr nz, .textScriptEnd
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld hl, .TrainerDefeatedText
	ld de, .TrainerDefeatedText
	call SaveEndBattleTextPointers
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	ld a, [wBattleHallState]
	and $F8 ; preserve battleIndex bits
	or SCRIPT_BATTLEHALL_MOVE_PLAYER
	ld [wBattleHallState], a
.textScriptEnd
	rst TextScriptEnd

.PreBattleText:
	text_far _EliteBao8BattleText
	text_end

.TrainerDefeatedText:
	text_far _EliteBao8DefeatedText
	text_end

EliteBao9Text:
	text_asm
	ld hl, .PreBattleText
	call PrintText
	ld a, [wPartyCount]
	cp 6
	jr nz, .textScriptEnd
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld hl, .TrainerDefeatedText
	ld de, .TrainerDefeatedText
	call SaveEndBattleTextPointers
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	ld a, [wBattleHallState]
	and $F8 ; preserve battleIndex bits
	or SCRIPT_BATTLEHALL_MOVE_PLAYER
	ld [wBattleHallState], a
.textScriptEnd
	rst TextScriptEnd

.PreBattleText:
	text_far _EliteBao9BattleText
	text_end

.TrainerDefeatedText:
	text_far _EliteBao9DefeatedText
	text_end

EliteBao10Text:
	text_asm
	ld hl, .PreBattleText
	call PrintText
	ld a, [wPartyCount]
	cp 6
	jr nz, .textScriptEnd
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld hl, .TrainerDefeatedText
	ld de, .TrainerDefeatedText
	call SaveEndBattleTextPointers
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	ld a, [wBattleHallState]
	and $F8 ; preserve battleIndex bits
	or SCRIPT_BATTLEHALL_MOVE_PLAYER
	ld [wBattleHallState], a
.textScriptEnd
	rst TextScriptEnd

.PreBattleText:
	text_far _EliteBao10BattleText
	text_end

.TrainerDefeatedText:
	text_far _EliteBao10DefeatedText
	text_end

BattleHallReceptionistText:
	text_asm
	CheckEvent EVENT_BATTLED_BATTLE_HALL_TRAINER
	ld hl, .WhatABattleText
	ret nz
	ld a, [wPartyCount]
	cp 6
	ld hl, .TeamReadyText
	ret z
	ld hl, .NeedSixMonText
	ret

.NeedSixMonText:
	text_far _BattleHallReceptionistNeedSixMonText
	text_end

.TeamReadyText:
	text_far _BattleHallReceptionistTeamReadyText
	text_end

.WhatABattleText:
	text_far _BattleHallReceptionistWhatABattleText
	text_end

BattleHallExitPromptScript:
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	ld a, [wBattleHallState]
	and $F8
	ld [wBattleHallState], a
	ret

BattleHallStepOffStairs:
	ld a, PAD_UP
	ld [wSimulatedJoypadStatesEnd], a
	ld a, 1
	ld [wSimulatedJoypadStatesIndex], a
	call StartSimulatingJoypadStates
	ld a, [wBattleHallState]
	and $F8
	or SCRIPT_BATTLEHALL_EXIT_PROMPT
	ld [wBattleHallState], a
	ret

BattleHallExitText:
	text_asm
	ld hl, .WarningText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr z, .confirmedExit
	call BattleHallStepOffStairs
	rst TextScriptEnd
.confirmedExit
	; Close the dialog before disabling input or writing warp scratch HRAM.
	; Text cleanup also uses hWarpDestinationMap's shared storage.
	ld a, SCRIPT_BATTLEHALL_EXIT_WARP
	ld [wBattleHallState], a
	ResetEvent EVENT_BATTLED_BATTLE_HALL_TRAINER
	ld a, 1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	rst TextScriptEnd
.WarningText:
	text_far _BattleHallExitPromptText
	text_end

BattleHallExitWarpScript:
	ld a, PAD_BUTTONS | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld a, ROUTE_22_GATE
	ldh [hWarpDestinationMap], a
	ld a, 8 ; destination warp 9, stored zero-based
	ld [wDestinationWarpID], a
	ld hl, wStatusFlags3
	set BIT_WARP_FROM_CUR_SCRIPT, [hl]
	xor a
	ld [wBattleHallState], a
	ret

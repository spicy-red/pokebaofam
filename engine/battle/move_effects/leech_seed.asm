LeechSeedEffect:
	call MoveHitTest ; why is this here? main effect
	ld a, [wMoveMissed]
	and a
	jr nz, .evadedAttack
	ldh a, [hWhoseTurn]
	and a
	ld hl, wEnemyBattleStatus2
	ld de, wEnemyMonType1
	jr z, .gotPointers ; jump on player's turn
	ld hl, wPlayerBattleStatus2
	ld de, wBattleMonType1
.gotPointers
; Block new seeds behind Substitute without clearing an existing seed.
	bit HAS_SUBSTITUTE_UP, [hl]
	jr nz, .didntAffect
; miss if the target is grass-type or already seeded
	ld a, [de]
	cp GRASS
	jr z, .didntAffect
	inc de
	ld a, [de]
	cp GRASS
	jr z, .didntAffect
	bit SEEDED, [hl]
	jr nz, .didntAffect
	set SEEDED, [hl]
	call PlayCurrentMoveAnimation
	ld hl, WasSeededText
	jp PrintText

.evadedAttack
	ld c, 50
	call DelayFrames
	ld hl, EvadedAttackText
	jp PrintText

.didntAffect ; marcelnote - new for immunity
	ld c, 50
	call DelayFrames
	jp PrintDidntAffectText


WasSeededText:
	text_far _WasSeededText
	text_end

EvadedAttackText:
	text_far _EvadedAttackText
	text_end

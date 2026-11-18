; Fixed-damage moves are reduced after their effects supply the final damage.
ReduceCalculatedDamageWhileCharging:
	ldh a, [hWhoseTurn]
	and a
	ld a, [wPlayerMoveEffect]
	jr z, .gotEffect
	ld a, [wEnemyMoveEffect]
.gotEffect
	cp OHKO_EFFECT
	ret z
	cp SUPER_FANG_EFFECT
	ret z
	cp SPECIAL_DAMAGE_EFFECT
	ret z
	; fallthrough

; Halve incoming attack damage while the target braces, rounding down, minimum 1.
; Apply once when damage is calculated, before multi-hit/trapping damage is reused.
; Direct self-damage and OHKO attacks bypass this routine.
ReduceDamageWhileCharging:
	ldh a, [hWhoseTurn]
	and a
	ld hl, wEnemyBattleStatus1
	ld a, [wEnemyMoveNum]
	jr z, .gotTarget
	ld hl, wPlayerBattleStatus1
	ld a, [wPlayerMoveNum]
.gotTarget
	bit CHARGING_UP, [hl]
	ret z
	cp SOLARBEAM
	jr z, .reduce
	cp SKY_ATTACK
	jr z, .reduce
	cp SKULL_BASH
	ret nz
.reduce
	ld hl, wDamage
	ld a, [hli]
	or [hl]
	ret z ; preserve zero damage (including type immunities)
	dec hl
	srl [hl]
	inc hl
	rr [hl]
	ld a, [hld]
	or [hl]
	ret nz
	inc hl
	inc [hl] ; a successful hit always deals at least 1
	ret

; Explain protection after the move's own charging message, excluding Fly/Dig.
ShowChargeDefenseText:
	ld a, [wChargeMoveNum]
	cp SOLARBEAM
	jr z, .show
	cp SKY_ATTACK
	jr z, .show
	cp SKULL_BASH
	ret nz
.show
	ld hl, ChargeDefenseText
	jp PrintText

ChargeDefenseText:
	text_far _ChargeDefenseText
	text_end

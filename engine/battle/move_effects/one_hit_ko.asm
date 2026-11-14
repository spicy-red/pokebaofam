OneHitKOEffect:
	; Always allow OHKO if the move passes its accuracy check.
	ld hl, wDamage
	ld a, $ff
	ld [hli], a
	ld [hl], a

	; Mark the move as an OHKO.
	ld a, $2
	ld [wCriticalHitOrOHKO], a
	ret
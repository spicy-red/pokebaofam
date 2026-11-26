; BUMI SPRITE
CheckCustomTrainerSprite:
    ; Only apply to trainer Odo.
    ld a, [wTrainerClass]
    cp ODO
    ret nz

    ; Only replace PORYGON's artwork.
    ld a, [wEnemyMonSpecies2]
    cp PORYGON
    ret nz

    ; Bumi uses 7x7 tiles, rather than Porygon's 6x6.
    ld a, SPRITE_DIM_LARGE
    ld [wMonHFrontPicDim], a

    ; Porygon's empty back pointer selects the legacy picture layout.
    ; LoadMonFrontPic adds this offset before selecting the sprite style.
    ld hl, BumiPicFront - (BulbasaurPicFront - BulbasaurPics)
    ld a, l
    ld [wMonHPics], a
    ld a, h
    ld [wMonHPics + 1], a

    ; Set the graphics bank for Bumi.
    ld a, BANK(BumiPicFront)
    ld [wMonHPicBank], a

    ret
    

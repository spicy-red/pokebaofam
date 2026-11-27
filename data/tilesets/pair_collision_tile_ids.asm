; FORMAT: tileset number, tile 1, tile 2
; terminated by -1
; these entries indicate that the player may not cross between tile 1 and tile 2
; it's mainly used to simulate differences in elevation

TilePairCollisionsLand::
	db CAVERN,   $20, $05 ; bfe - ground to floor
	db CAVERN,   $41, $05 ; bfe - floors of different elevations
	db CAVERN,   $41, $20 ; bfe - new, ground to floor
	db CAVERN,   $2A, $05 ; bfe - ground to floor
	db CAVERN,   $05, $21 ; bfe - carpet to floor
	db CAVERN,   $18, $41 ; bfe - stairs to elevated floor
	db SAFARI,   $30, $2E ; bfe - new tileset from FOREST
	db SAFARI,   $52, $2E
	db SAFARI,   $55, $2E
	db SAFARI,   $56, $2E
	db SAFARI,   $20, $2E
	db SAFARI,   $5E, $2E
	db SAFARI,   $5F, $2E
	db FOREST,   $4B, $10 ; bfe - platform to ground
	db FOREST,   $5E, $10 ; bfe - platform to ground
	db FOREST,   $1E, $01 ; bfe - stairs (roof) to grassy ground
	db MOUNTAIN, $2E, $20 ; bfe - floors of different elevations
	db MOUNTAIN, $20, $5C ; bfe - upper floor to cave door
	db MOUNTAIN, $2E, $01 ; bfe - floors of different elevations
	db -1 ; end

TilePairCollisionsWater::
	db SAFARI,   $14, $2E ; bfe - new tileset from FOREST
	db SAFARI,   $48, $2E ; $48 is a shore tile
	db CAVERN,   $14, $05
	db CAVERN,   $14, $41 ; bfe - collision with elevation tile
	db MOUNTAIN, $14, $2E ; bfe - new tileset
	db -1 ; end

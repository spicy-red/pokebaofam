MACRO tileset
	db BANK(\1_GFX)
	dw \1_Block, \1_GFX, \1_Coll
	db \2, \3, \4 ; counter tiles
	db \5         ; grass tile
	db \6         ; animations (TILEANIM_* value)
ENDM

; bfe - see also:
; data/tilesets/collision_tile_ids.asm
; data/tilesets/pair_collision_tile_ids.asm
; data/tilesets/bookshelf_tile_ids.asm
; data/tilesets/dungeon_tilesets.asm
; data/tilesets/door_tile_ids.asm

Tilesets:
	table_width 12
	; name, 3 counter tiles, grass tile, animations
	tileset Overworld,    -1, -1, -1, $52, TILEANIM_OVERWORLD ; bfe - was TILEANIM_WATER_FLOWER
	tileset BigHouse,     -1, -1, -1,  -1, TILEANIM_NONE      ; bfe - renamed REDS_HOUSE_1 tileset
	tileset Forest,       -1, -1, -1, $11, TILEANIM_WATER     ; bfe - reorganized tileset
	tileset Safari,       -1, -1, -1, $20, TILEANIM_WATER     ; bfe - new tileset from FOREST
	tileset Pokecenter,  $58,$25,$3C,  -1, TILEANIM_NONE      ; bfe - modified tileset
	tileset Gym,         $3A, -1, -1,  -1, TILEANIM_WATER_FLOWER
	tileset House,        -1, -1, -1,  -1, TILEANIM_NONE
	tileset Underground,  -1, -1, -1,  -1, TILEANIM_NONE
	tileset Gate,        $30,$33, -1,  -1, TILEANIM_NONE      ; bfe - modified tileset
	tileset Ship,         -1, -1, -1,  -1, TILEANIM_WATER
	tileset ShipPort,     -1, -1, -1,  -1, TILEANIM_WATER_WBOLLARD ; bfe - was TILEANIM_WATER
	tileset Cemetery,    $12, -1, -1,  -1, TILEANIM_LANTERN ; bfe - was TILEANIM_NONE
	tileset Interior,     -1, -1, -1,  -1, TILEANIM_NONE
	tileset Cavern,       -1, -1, -1,  -1, TILEANIM_CAVERN ; bfe - was TILEANIM_WATER
	tileset Lobby,       $15,$36, -1,  -1, TILEANIM_NONE
	tileset Mansion,     $16,$36, -1,  -1, TILEANIM_NONE    ; bfe - added counter tiles
	tileset Lab,          -1, -1, -1,  -1, TILEANIM_NONE
	tileset Club,        $07,$17, -1,  -1, TILEANIM_NONE
	tileset Facility,    $12, -1, -1,  -1, TILEANIM_WATER
	tileset Plateau,      -1, -1, -1, $45, TILEANIM_WATER
	tileset Academy,      -1, -1, -1,  -1, TILEANIM_NONE     ; bfe - new tileset
	tileset Mountain,     -1, -1, -1,  -1, TILEANIM_MOUNTAIN ; bfe - new tileset
	tileset BeachHouse,  $19, -1, -1,  -1, TILEANIM_NONE     ; bfe - new tileset from pokeyellow
	tileset Plant,        -1, -1, -1,  -1, TILEANIM_PLANT    ; bfe - new tileset for Power Plant
	tileset Game,        $46,$57, -1,  -1, TILEANIM_NONE     ; bfe - new tileset for Game Corner
	assert_table_length NUM_TILESETS

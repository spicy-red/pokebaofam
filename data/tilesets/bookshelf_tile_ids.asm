MACRO bookshelf_tile
	db \1, \2
	db_tx_pre \3
ENDM

BookshelfTileIDs:
	; tileset id, bookshelf tile id, text id
	bookshelf_tile PLATEAU,      $30, IndigoPlateauStatues
	bookshelf_tile HOUSE,        $3D, TownMapText
	bookshelf_tile HOUSE,        $1E, BookOrSculptureText
	bookshelf_tile MANSION,      $32, BookOrSculptureText
	bookshelf_tile BIG_HOUSE,    $32, BookOrSculptureText ; bfe - merged REDS_HOUSE tilesets
	bookshelf_tile LAB,          $40, BookOrSculptureText ; bfe - reorganized tileset
	bookshelf_tile LOBBY,        $16, ElevatorText
	bookshelf_tile GYM,          $1D, BookOrSculptureText
	bookshelf_tile GATE,         $22, BookOrSculptureText
	bookshelf_tile POKECENTER,   $52, PokemonStuffText  ; bfe - modified tileset
	bookshelf_tile POKECENTER,   $53, PokemonStuffText  ; bfe - modified tileset
	bookshelf_tile POKECENTER,   $3E, ColdDrinksText    ; bfe - new for Marts
	bookshelf_tile POKECENTER,   $1C, HotSnacksText     ; bfe - new for Marts
	bookshelf_tile LOBBY,        $50, PokemonStuffText
	bookshelf_tile LOBBY,        $52, PokemonStuffText
	bookshelf_tile GAME,         $50, PokemonStuffText
	bookshelf_tile GAME,         $52, PokemonStuffText
	bookshelf_tile SHIP,         $36, BookOrSculptureText
	bookshelf_tile ACADEMY,      $32, BookOrSculptureText ; bfe - new tileset
	bookshelf_tile ACADEMY,      $3A, BookOrSculptureText ; bfe - new tileset
	bookshelf_tile ACADEMY,      $3C, BookOrSculptureText ; bfe - new tileset
	bookshelf_tile ACADEMY,      $22, BookOrSculptureText ; bfe - new tileset
	bookshelf_tile BEACH_HOUSE,  $50, HolidayBrochuresText ; bfe - new tileset from pokeyellow
	bookshelf_tile BEACH_HOUSE,  $52, HolidayBrochuresText ; bfe - new tileset from pokeyellow
	db -1 ; end

BookshelfTileFacingDownIDs: ; bfe - new for SPRITE_FACING_DOWN
	; tileset id, bookshelf tile id, text id
	bookshelf_tile LOBBY,        $3A, PokemonStuffText
	bookshelf_tile LOBBY,        $3C, PokemonStuffText
	bookshelf_tile POKECENTER,   $32, PokemonStuffText
	bookshelf_tile POKECENTER,   $33, PokemonStuffText
	db -1 ; end

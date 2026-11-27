DoorTileIDPointers:
	dbw OVERWORLD,   .OverworldDoorTileIDs
	dbw SAFARI,      .SafariDoorTileIDs ; bfe - new tileset from FOREST
	dbw POKECENTER,  .PokecenterDoorTileIDs ; bfe - was MART, replaced
	dbw HOUSE,       .HouseDoorTileIDs
	dbw GATE,        .GateDoorTileIDs ; bfe - changed from .TilesetMuseumDoorTileIDs
	dbw UNDERGROUND, .UndergroundDoorTileIDs ; bfe - stairs exit
	dbw SHIP,        .ShipDoorTileIDs
	dbw LOBBY,       .LobbyDoorTileIDs
	dbw MANSION,     .MansionDoorTileIDs
	dbw LAB,         .LabDoorTileIDs
	dbw FACILITY,    .FacilityDoorTileIDs
	dbw PLATEAU,     .PlateauDoorTileIDs
	dbw ACADEMY,     .AcademyDoorTileIDs    ; bfe - new tileset
	dbw MOUNTAIN,    .MountainDoorTileIDs   ; bfe - new tileset
	dbw GAME,        .GameDoorTileIDs       ; bfe - new tileset
	dbw INTERIOR,    .InteriorDoorTileIDs   ; bfe - added door tiles
	db -1 ; end

MACRO door_tiles
	IF _NARG
		db \# ; all args
	ENDC
	db 0 ; end
ENDM

.OverworldDoorTileIDs: ; bfe - see also PlayMapChangeSound
	door_tiles $1B, $58

.SafariDoorTileIDs: ; bfe - new tileset from FOREST
	door_tiles $3a

.MountainDoorTileIDs:   ; bfe - new tileset
	db $5c
.GateDoorTileIDs: ; bfe - changed from .TilesetMuseumDoorTileIDs
.LabDoorTileIDs: ; bfe - reorganized tileset
.GameDoorTileIDs:
.PokecenterDoorTileIDs: ; bfe - was MartDoorTileIDs, replaced
.UndergroundDoorTileIDs: ; bfe - stairs exit
	door_tiles $5e

.HouseDoorTileIDs:
	door_tiles $54

.ShipDoorTileIDs:
	door_tiles $1e

.LobbyDoorTileIDs:
	door_tiles $1c, $38, $1a

.MansionDoorTileIDs:
	door_tiles $1a, $1c, $53

.FacilityDoorTileIDs:
	door_tiles $43, $58, $1b

.PlateauDoorTileIDs:
	door_tiles $3b, $1b

.AcademyDoorTileIDs:    ; bfe - new tileset
	door_tiles $1a, $1c

.InteriorDoorTileIDs:    ; bfe - added door tiles
	door_tiles $04, $15

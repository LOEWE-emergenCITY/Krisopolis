@tool
class_name EMC_Stage
extends Node2D

enum Atlases{ #Tileset Atlasses
	FURNITURE_PNG = 0,
	GROUND_PNG = 1,
	WALLS_PNG = 2,
	NAVIGATION_PNG = 3,
	TELEPORTERS_PNG = 4,
	UPGRADE_FURNITURE_PNG = 5,
	TOOLTIPS_PNG = 6,
	INTERACTABLE_FURNITURE = 7,
}

enum CustomDataLayers{
	ACTION_ID  = 0,
	TOOLTIP = 1,
	BOOK = 2,
}

const INVALID_TILE: Vector2 = Vector2(-1, -1)

var _npcs : Control
var _opt_event_mngr : EMC_OptionalEventMngr

@onready var navigation: TileMapLayer = $Navigation
@onready var background: TileMapLayer = $Background
@onready var middleground_1: TileMapLayer = $"Middleground 1"
@onready var middleground_2: TileMapLayer = $"Middleground 2"
@onready var middleground_3: TileMapLayer = $"Middleground 3"
@onready var foreground: TileMapLayer = $Foreground
@onready var tooltips: TileMapLayer = $Tooltips

@onready var spots: Node2D = $Spots

func setup(p_npcs : Control, p_opt_event_mngr : EMC_OptionalEventMngr) -> void:
	_npcs = p_npcs
	_opt_event_mngr = p_opt_event_mngr

####################Public Methods#######################

func _ready() -> void:
	
	if not Engine.is_editor_hint() and name == "home":
		_place_upgrade_furniture()
	
		show_electricity()
	
func get_tile_type(p_click_pos : Vector2) -> String:
	var tile_coord := _global_to_map(p_click_pos)
	
	var tile_data : TileData
	
	var layers_to_check := [tooltips, foreground, middleground_2, middleground_1, background]
	for layer: TileMapLayer in layers_to_check:
		tile_data = layer.get_cell_tile_data(tile_coord)
		if tile_data != null:
			break
	
	if tile_data == null:
		return "background"
			
	var tooltip : String = tile_data.get_custom_data_by_layer_id(CustomDataLayers.TOOLTIP)
	if tooltip != "":
		return "tooltip\\" + tooltip
	
	var book_id : int = tile_data.get_custom_data_by_layer_id(CustomDataLayers.BOOK)
	if book_id != 0:
		return "book\\" + str(book_id) 
		
	var action_id : String = tile_data.get_custom_data_by_layer_id(CustomDataLayers.ACTION_ID)
	if not action_id.is_empty():
		return "action\\" + action_id 
	
	return "background"
	
func get_avatar_target(p_click_pos : Vector2) -> Vector2:
	var _target_position := _determine_adjacent_free_tile(p_click_pos)
	if _target_position != INVALID_TILE:
		return _target_position
	
	return Vector2.INF
	
func show_electricity(_tmp: int = 0) -> void:
	if OverworldStatesMngr.is_effective_state_eq("ElectricityState", "UNLIMITED"): # REMOVE OverworldStatesMngr.get_electricity_state() == OverworldStatesMngr.ElectricityState.UNLIMITED:
		middleground_3.hide()
	else:
		middleground_3.show()

###################Private Methods######################

#************OPTIONAL EVENTS*****************

func _load_optional_event() -> void:
	for opt_event in _opt_event_mngr.get_active_events():
		if name == opt_event.stage_name:
			#Spawn Tiles
			var spawn_tiles_arr := opt_event.spawn_tiles_arr
			if spawn_tiles_arr != null && !spawn_tiles_arr.is_empty():
				for spawn_tiles in spawn_tiles_arr:
					_place_furniture_on_position(spawn_tiles.tilemap_pos, middleground_1,
					 spawn_tiles.atlas_coord, Atlases.FURNITURE_PNG,
					spawn_tiles.tiles_cols, spawn_tiles.tiles_rows, spawn_tiles.overwrite_existing_tiles)
					
			var spawn_NPCs_arr := opt_event.spawn_NPCs_arr
			if spawn_NPCs_arr != null && !spawn_NPCs_arr.is_empty():
				for spawn_NPCs in spawn_NPCs_arr:
					var stage_comp: EMC_NPC_Stage = (_npcs.get_node(spawn_NPCs.NPC_name) as EMC_NPC).get_comp(EMC_NPC_Stage)
					stage_comp.override_spawn(spawn_NPCs.pos)
					#_spawn_NPC(spawn_NPCs.NPC_name, spawn_NPCs.pos)
					
#********************NPCs******************

func request_spot(spot_name: String) -> EMC_Stage_Spot:
	var spot: EMC_Stage_Spot = spots.get_node(spot_name)

	if spot == null:
		printerr("EMC_Stage: no such spot %s" % spot_name)
	elif spot_name == "start":
		return spot
	elif spot.is_occupied():
		EMC_Util.print_warn("EMC_Stage: spot occupied.")
	else:
		occupy_spot(spot)
		return spot
		
	for alternative_spot: EMC_Stage_Spot in spots.get_children():
		if not alternative_spot.is_occupied():
			occupy_spot(alternative_spot)
			return alternative_spot
			
	printerr("EMC_Stage: no unoccupied spot found.")
	return null

func occupy_spot(spot: EMC_Stage_Spot) -> void:
	spot.set_occupied(true)
	for tile_coord: Vector2i in spot.tile_coords:
		navigation.erase_cell(tile_coord)

#*************UPGRADES*****************

func _place_upgrade_furniture() -> void:
	for upgrade: EMC_Upgrade in OverworldStatesMngr.get_upgrades():
		var spawn_pos : Vector2i = upgrade.get_spawn_pos()
		var atlas_coords : Vector2i = upgrade._atlas_coord
		_place_furniture_on_position(spawn_pos, middleground_2,
		atlas_coords, Atlases.UPGRADE_FURNITURE_PNG, 1, 2, true)

#***************UTIL******************

## Places a tile from the furniture-Atlas on the Middleground 1 Layer
func _place_furniture_on_position(p_tilemap_pos: Vector2i, p_layer : TileMapLayer,\
p_atlas_coord: Vector2i, p_altlas : Atlases, p_tiles_cols: int = 1, p_tiles_rows: int = 1, \
p_overwrite_existing_tiles: bool = false) -> void:
	
	if p_tiles_cols < 1: p_tiles_cols = 1
	if p_tiles_rows < 1: p_tiles_rows = 1
	
	#Place new tiles
	for x_offset in range(0, p_tiles_cols):
		for y_offset in range(0, p_tiles_rows):
			#If necessary, check if previous tile exists and exit
			if p_overwrite_existing_tiles == false:
				var previous_tile := p_layer.get_cell_tile_data(p_tilemap_pos)
				if previous_tile != null: continue
			
			var tilemap_pos := Vector2i(p_tilemap_pos.x + x_offset, p_tilemap_pos.y + y_offset)
			var atlas_coord := Vector2i(p_atlas_coord.x + x_offset, p_atlas_coord.y + y_offset)
			p_layer.set_cell(tilemap_pos, p_altlas, atlas_coord)
			navigation.erase_cell(tilemap_pos)
			
func _global_to_map(p_click_pos: Vector2) -> Vector2i:
	#The click position has to be scaled according to the scale of the stage
	var scaled_click_pos := to_local(p_click_pos)
	return navigation.local_to_map(scaled_click_pos)

func _map_to_global(p_click_pos: Vector2) -> Vector2i:
	#The click position has to be scaled according to the scale of the stage
	var scaled_click_pos := navigation.map_to_local(p_click_pos)
	return to_global(scaled_click_pos)
	

func is_tile_walkable(tile_coord: Vector2i) -> bool:
	return navigation.get_cell_source_id(tile_coord) != -1

func _determine_adjacent_free_tile(p_click_pos: Vector2) -> Vector2:
	var tile_coord := _global_to_map(p_click_pos)
	
	if is_tile_walkable(tile_coord):
		#return _map_to_global(tile_coord)
		return p_click_pos

	#navigation.get_surrounding_cells(tile_coord)
	#
	#var priority_list: Array[Vector2i]
	#
	#priority_list.append(navigation.get_neighbor_cell(tile_coord, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE))
	#priority_list.append(navigation.get_neighbor_cell(tile_coord, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE))
	#priority_list.append(navigation.get_neighbor_cell(tile_coord, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE))
	#priority_list.append(navigation.get_neighbor_cell(tile_coord, TileSet.CELL_NEIGHBOR_LEFT_SIDE))
	#priority_list.append(navigation.get_neighbor_cell(tile_coord, TileSet.CELL_NEIGHBOR_RIGHT_SIDE))
	#priority_list.append(navigation.get_neighbor_cell(tile_coord, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE))
	#priority_list.append(navigation.get_neighbor_cell(tile_coord, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE))
	#priority_list.append(navigation.get_neighbor_cell(tile_coord, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE))
	#priority_list.append(navigation.get_neighbor_cell(tile_coord, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE))
	#
	#return INVALID_TILE
			
	const search_area : Array[Vector2i] = [
		Vector2i(-1, -1), 	Vector2i(0, -1), 	Vector2i(1, -1),
		Vector2i(-1, 0), 						Vector2i(1, 0),
		Vector2i(-1, 1), 	Vector2i(0, 1), 	Vector2i(1, 1)
	]
	
	var goal : Vector2i = search_area.reduce(
		func(accum : Vector2i, pos : Vector2i) -> Vector2i:
			var tile := tile_coord + pos
			var accum_tile := tile_coord + accum
			if (is_tile_walkable(tile)
			and (_map_to_global(tile) as Vector2 - p_click_pos).length_squared() < (_map_to_global(accum_tile) as Vector2 - p_click_pos).length_squared()):
				return pos
			return accum
	, Vector2i.MAX)
	
	if goal == Vector2i.MAX:
		push_warning("The clicked furniture has no adjacent free tiles that the Avatar can navigate towards!")
		return INVALID_TILE
	
	return _map_to_global(goal + tile_coord)# - 2*  goal

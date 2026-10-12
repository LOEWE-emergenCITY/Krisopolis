@tool
extends Resource
class_name EMC_Upgrade

signal was_pressed(p_upgrade : EMC_Upgrade)

enum IDs{
	EMPTY_SLOT = 0,
	RAINWATER_BARREL = 1,
	ELECTRIC_RADIO = 2,
	CRANK_RADIO = 3,
	GAS_COOKER = 4,
	POWER_BANK = 5,
	WATER_RESERVOIR = 6,
}

@export var id : IDs
@export var display_name : String
@export var description : String
@export var price : int
@export var state : int
@export var state_maximum : int
@export var spawn_pos: Vector2i
@export var texture : AtlasTexture = AtlasTexture.new()
@export var _atlas_coord: Vector2i = Vector2i(1, 1)

func _init() -> void:
	texture.set_atlas(load("res://assets/tilesets/furniture_upgrades.png"))

func setup(p_upgrade_id: IDs) -> EMC_Upgrade:
	id = p_upgrade_id

	var data : Dictionary = JsonMngr.id_to_upgrade_data(id)
	display_name = data.get("display_name", "")
	description = data.get("description", "")
	price = data.get("price", 0)
	state = data.get("state", 0)
	state_maximum = data.get("state_maximum", 0)
	_atlas_coord = data.get("atlas_coord")
	
	if data.has("spawn_pos"):
		spawn_pos = data["spawn_pos"]
	
	return self
	
func load_texture() -> void:
	const UPGARDE_WIDTH := 64
	const UPGARDE_HEIGHT := 128
	const SEPARATION := 64*3
	const UPGRADE_COLS = 4
	var x_offset: int = (id % UPGRADE_COLS) * SEPARATION + 64
	var y_offset: int = (floor(id / UPGRADE_COLS)) * SEPARATION + 64
	texture.set_region(Rect2(x_offset, y_offset, UPGARDE_WIDTH, UPGARDE_HEIGHT))

func get_texture() -> AtlasTexture:
	load_texture()
	return texture

func get_id() -> IDs:
	return id

func get_display_name() -> String:
	return display_name

func get_description() -> String:
	return description

func get_price() -> int:
	return price

func get_state() -> int:
	return state

func get_spawn_pos() -> Vector2i:
	return spawn_pos

func set_state(new_state : int) -> void:
	if new_state > state_maximum || new_state < 0:
			push_error("Unerwarteter Fehler: upgrade state out of bounds")
	state = new_state

func get_state_maximum() -> int:
	return state_maximum

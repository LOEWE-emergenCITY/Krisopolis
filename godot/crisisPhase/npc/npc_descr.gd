extends Resource
class_name EMC_NPC_Descr

@export var npc_name: String
@export var descr : String
@export var portrait: Texture2D
@export var sprite: Texture2D

func setup(dict: Dictionary) -> void:
	npc_name = dict.get("name", "dummy")
	descr = dict.get("descr", "Das ist Niemand")
	
	var portait_name: String = dict.get("portait", "dummy")
	portrait = load("res://assets/characters/portrait_" + portait_name + ".png")
	
	var sprite_name: String = dict.get("sprite", "dummy")
	sprite = load("res://assets/characters/sprite_" + sprite_name + ".png")

func get_npc_name() -> String:
	return npc_name

func get_desc() -> String:
	return descr
	
func get_portrait() -> Texture2D:
	return portrait

func get_sprite_texture() -> Texture2D:
	return sprite

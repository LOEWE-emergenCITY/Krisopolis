@tool
extends Sprite2D
class_name EMC_NPC_Sprite

var texture_name: String = "dummy"

func _init(dict: Dictionary = {"texture_name": "dummy"}) -> void:
	texture_name = dict.get("texture_name", "dummy")

func _ready() -> void:
	texture = load("res://assets/characters/sprite_" + texture_name + ".png")
	offset = Vector2(0, -46)
	hframes = 3

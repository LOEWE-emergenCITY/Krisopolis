extends Node2D
class_name EMC_Stage_Spot

@export var tile_coords: Array[Vector2i]

var occupied: bool

func is_occupied() -> bool:
	return occupied
	
func set_occupied(value: bool) -> void:
	occupied = value

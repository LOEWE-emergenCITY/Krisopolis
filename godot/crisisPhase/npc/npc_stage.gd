extends Resource
class_name EMC_NPC_Stage

@export var stage_name: String = "Park"
@export var spot: String = "default"

func setup(dict: Dictionary) -> void:
	stage_name = dict.get("stage_name", stage_name)
	spot = dict.get("spot", spot)

func change_stage(_stage_name: String, spot_name: String) -> void:
	stage_name = _stage_name
	spot = spot_name

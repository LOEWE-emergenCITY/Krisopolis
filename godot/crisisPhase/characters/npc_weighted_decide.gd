extends EMC_NPC_Decide
class_name EMC_NPC_Weighted_Decide

@export var weights: Dictionary

func _init(data: Dictionary) -> void:
	weights = data.get("weight")

func choose_option(options: Array[String]) -> String:
	var weight: Array[float] = []
	for option in options:
		weight.append(weights.get(option, 0.0) as float)
		if weight.back() == 0.0:
			print_debug("Action: " + option + " is not present.")
	
	return EMC_Util.pick_weighted_random(options, weight, 1)[0]

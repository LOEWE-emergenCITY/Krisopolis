extends EMC_IC_Consumable
class_name EMC_IC_Food

@export var _nutritionness: int = 0

const UNIT: String = "[img=center,center]res://assets/GUI/icons/food_capsule.png[/img]"
const UNIT_FACTOR: int = 250 #1 Unit = 250kcal

########################################## PUBLIC METHODS ##########################################
func _init() -> void:
	super("Essen", EMC_Palette.LIGHT_GREEN)

func setup(data: Dictionary) -> EMC_IC_Food:
	_nutritionness = data.get("value", _nutritionness)
	
	return self

func consume(p_avatar : EMC_Avatar) -> void:
	p_avatar.modify_food_delta(self.get_nutritionness())

## Get the internal nutritionness value
func get_nutritionness() -> int:
	return _nutritionness


## Get the nutritionness value scaled to fit real-life units
func get_unit_nutritionness() -> int:
	return _nutritionness * UNIT_FACTOR


## RENAME WITH CAUTION: It overrides superclass method!
func get_name_with_values() -> String:
	if _nutritionness >= 0:
		return "Nährwert: " + "+\u2060".repeat(_nutritionness).left(-1) #name + " (" + str(get_unit_nutritionness()) + UNIT + ")"
	else:
		return "Nährwert: " + "-\u2060".repeat(-_nutritionness).left(-1)

func to_dict() -> Dictionary:
	var data : Dictionary = {
		"name": "food",
		"params": _nutritionness,
	}
	return data

########################################## PRIVATE METHODS #########################################

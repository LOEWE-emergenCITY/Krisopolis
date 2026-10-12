extends EMC_IC_Consumable
class_name EMC_IC_Drink

@export var _hydration: int = 0 

const UNIT: String = " ml"
const UNIT_FACTOR: int = 500 #1 Unit = 500ml

########################################## PUBLIC METHODS ##########################################
func _init() -> void:
	super("Getränk", Color.CADET_BLUE)

func setup(data: Dictionary) -> EMC_IC_Drink:
	_hydration = data.get("value", _hydration)
	
	return self 
 
func consume(p_avatar : EMC_Avatar) -> void:
	p_avatar.modify_drink_delta(self.get_hydration())

## Get the internal hydration value
func get_hydration() -> int:
	return _hydration

## Get the hydration value scaled to fit real-life units
func get_unit_hydration() -> int:
	return _hydration * UNIT_FACTOR

## RENAME WITH CAUTION: It overrides superclass method!
func get_name_with_values() -> String:
	if _hydration >= 0:
		return "Durstlöschend: " + "+\u2060".repeat(_hydration).left(-1) #name + " (" + str(get_unit_nutritionness()) + UNIT + ")"
	else:
		return "Durstig machend: " + "-\u2060".repeat(-_hydration).left(-1)
	
	#return name + " (" + str(get_unit_hydration()) + UNIT + ")"
	
func to_dict() -> Dictionary:
	var data : Dictionary = {
		"name": "drink",
		"params": _hydration,
	}
	return data

########################################## PRIVATE METHODS #########################################

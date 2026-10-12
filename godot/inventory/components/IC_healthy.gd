extends EMC_IC_Consumable
class_name EMC_IC_Healthy
## For unenjoyable or enjoyable food or drink items

@export var _health_change: int

const UNIT: String = "% ♡"
const UNIT_FACTOR: int = 10

########################################## PUBLIC METHODS ##########################################
func _init() -> void:
	super("Gesund", Color.HOT_PINK)

func setup(data: Dictionary) -> EMC_IC_Healthy:
	_health_change = data.get("value", _health_change)
	
	return self

func consume(p_avatar : EMC_Avatar) -> void:
	p_avatar.modify_health_delta(self.get_health_change())

## Get the internal nutritionness value
func get_health_change() -> int:
	return _health_change


## Get the hydration value scaled to fit real-life units
func get_unit_health_change() -> int:
	return get_health_change() * UNIT_FACTOR


## RENAME WITH CAUTION: It overrides superclass method!
func get_name_with_values() -> String:
	if _health_change >= 0:
		return "Gesund: " + "+\u2060".repeat(_health_change).left(-1)
	else:
		return "Ungesund: " + "-\u2060".repeat(-_health_change).left(-1)
	
	#if _health_change < 0:
		#return "Un" + name.to_lower() + " (" + str(get_unit_health_change()) + " " + UNIT + ")"
	#else:
		#return name + " (+" + str(get_unit_health_change()) + " " + UNIT + ")"

func to_dict() -> Dictionary:
	var data : Dictionary = {
		"name": "healthy",
		"params": _health_change,
	}
	return data

########################################## PRIVATE METHODS #########################################

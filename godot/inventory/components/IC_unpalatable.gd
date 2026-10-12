extends EMC_IC_Consumable
class_name EMC_IC_Unpalatable
## For unhealthy or spoiled items

@export var _health_reduction: int

const UNIT: String = "% ♡"

########################################## PUBLIC METHODS ##########################################
func _init(_p_health_reduction : int = 0) -> void:
	super("Ungenießbar", Color.MEDIUM_SEA_GREEN)
	_health_reduction = _p_health_reduction
	if _health_reduction < 0:
		_health_reduction = _health_reduction * -1 #only accept positive numbers

func consume(p_avatar : EMC_Avatar) -> void:
	p_avatar.modify_health_delta(-self.get_health_reduction())

## Get the internal nutritionness value
func get_health_reduction() -> int:
	return _health_reduction


## Get the hydration value scaled to fit real-life units
func get_unit_health_reduction() -> int:
	return get_health_reduction() * EMC_IC_Healthy.UNIT_FACTOR


## RENAME WITH CAUTION: It overrides superclass method!
func get_name_with_values() -> String:
	return name + "(-" + str(get_unit_health_reduction()) + UNIT + ")"

func to_dict() -> Dictionary:
	var data : Dictionary = {
		"name": "unpalatable",
		"params": _health_reduction,
	}
	return data

########################################## PRIVATE METHODS #########################################

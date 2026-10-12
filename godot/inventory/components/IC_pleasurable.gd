extends EMC_IC_Consumable
class_name EMC_IC_Pleasurable
## For unenjoyable or enjoyable food or drink items

@export var _happiness_change: int

const UNIT: String = "Genuss"
const UNIT_FACTOR: int = 10

########################################## PUBLIC METHODS ##########################################
func _init() -> void:
	super("Köstlich", EMC_Palette.ORNAGE)

func setup(data: Dictionary) -> EMC_IC_Pleasurable:
	_happiness_change = data.get("value", _happiness_change)
	
	return self 

func consume(p_avatar : EMC_Avatar) -> void:
	p_avatar.modify_social_delta(self.get_happiness_change())

## Get the internal nutritionness value
func get_happiness_change() -> int:
	return _happiness_change


## Get the hydration value scaled to fit real-life units
func get_unit_happiness_change() -> int:
	return get_happiness_change() * UNIT_FACTOR


## RENAME WITH CAUTION: It overrides superclass method!
func get_name_with_values() -> String:
	if _happiness_change >= 0:
		return "Lecker: " + "+\u2060".repeat(_happiness_change).left(-1)
	else:
		return "Ekelhaft: " + "-\u2060".repeat(-_happiness_change).left(-1)
	
	#return name + "(" + str(get_unit_happiness_change()) + " " + UNIT + ")"


func to_dict() -> Dictionary:
	var data : Dictionary = {
		"name": "pleasurable",
		"params": _happiness_change,
	}
	return data

########################################## PRIVATE METHODS #########################################

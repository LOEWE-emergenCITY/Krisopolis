extends EMC_ItemComponent
class_name EMC_IC_Shelflife

@export var _shelflife: int 

const DECAY_RATE_NO_ELECTRICITY: int = 2
const DECAY_RATE_WITH_ELECTRICITY: int = 1
const UNIT: String = "Tage"

########################################## PUBLIC METHODS ##########################################
func _init() -> void:
	super("Haltbarkeit", Color.CHOCOLATE)

func setup(data: Dictionary) -> EMC_IC_Shelflife:
	_shelflife = data.get("value", _shelflife)
	
	return self

## Get the internal nutritionness value
func get_shelflife() -> int:
	if OverworldStatesMngr.is_effective_state_eq("ElectricityState", "NONE"):
		# Note: When electricity is missing, the shelflife is reduced by 2 each day, and thus
		# has to be displayed by half of its amount, rounded up:
		return ceil(_shelflife / 2.0)
	else:
		return _shelflife


func is_spoiled() -> bool:
	return _shelflife <= 0


func reduce_shelflife() -> void:
	if OverworldStatesMngr.is_effective_state_eq("ElectricityState", "NONE"):
		_shelflife -= DECAY_RATE_NO_ELECTRICITY
		if _shelflife < 0: _shelflife = 0
	else:
		_shelflife -= DECAY_RATE_WITH_ELECTRICITY


## RENAME WITH CAUTION: It overrides superclass method!
func get_name_with_values() -> String:
	if is_spoiled():
		return name + ": Verdorben"
	else:
		return name + ": " + str(get_shelflife()) + " " + UNIT

func to_dict() -> Dictionary:
	var data : Dictionary = {
		"name": "shelflife",
		"params": _shelflife,
	}
	return data

########################################## PRIVATE METHODS #########################################

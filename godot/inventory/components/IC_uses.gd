extends EMC_ItemComponent
class_name EMC_IC_Uses

@export var _uses_left : int = 0
#var _MAX_USES : int = 0

#------------------------------------------ PUBLIC METHODS -----------------------------------------
func _init() -> void:
	super("Uses", Color.DARK_CYAN)
	#_MAX_USES = _p_max_uses
	#
#func get_max_uses() -> int: 
	#return _MAX_USES

func setup(data: Dictionary) -> EMC_IC_Uses:
	_uses_left = data.get("value", _uses_left)
	
	return self

func no_uses_left() -> bool:
	return get_uses_left() <= 0

func get_uses_left() -> int:
	return _uses_left

## MRM: Renamed from "item_used" to "use_item", as the past-timetense implicitly 
## suggests it is a signal not a function
func use_item(_p_uses : int = 1) -> void:
	_uses_left -=_p_uses
	if _uses_left < 0 :
		_uses_left = 0


func get_name_with_values() -> String:
	return str(_uses_left) + " " + "Nutzungen übrig."


func to_dict() -> Dictionary:
	var data : Dictionary = {
		"name": "uses",
		"params": _uses_left,
	}
	return data

#----------------------------------------- PRIVATE METHODS -----------------------------------------

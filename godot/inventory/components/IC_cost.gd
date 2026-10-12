extends EMC_ItemComponent
class_name EMC_IC_Cost

@export var _cost : int = 0
@export var _buyable: bool = true

#------------------------------------------ PUBLIC METHODS -----------------------------------------
func _init() -> void:
	super("Cost", Color.GOLDENROD)

func setup(data: Dictionary) -> EMC_IC_Cost:
	_cost = data.get("cost", _cost)
	_buyable = data.get("buyable", _buyable)
	
	return self

func get_cost() -> int:
	return _cost

func is_buyable() -> bool:
	return _buyable

## RENAME WITH CAUTION: It overrides superclass method!
func get_name_with_values() -> String:
	if Global.is_in_crisis_phase():
		return ""
	else:
		return str(_cost) + " [img=center,center]res://assets/GUI/icons/ecoin_small.png[/img]"


func to_dict() -> Dictionary:
	var data : Dictionary = {
		"name": "cost",
		"params": _cost,
	}
	return data

#----------------------------------------- PRIVATE METHODS -----------------------------------------

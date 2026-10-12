extends EMC_Action
class_name EMC_Condition_Action

@export var then_exe: EMC_Action
@export var if_exe: EMC_Action
@export var else_exe: EMC_Action

## Format:
##NAME {
##	"type": "condition",
##	"cond": ACTION,
##	"if": ACTION,
##	"else": ACTION
##}
## If NAME starts with an "!", the condition will be evaluated during the supply
## ACTION represents any other action
func _init(data : Dictionary = {}) -> void:
	if not data.has_all(["if", "then", "else"]):
		#print_debug("Missing Dictionary entries")
		return
	
	var type: String = data["if"].get("type", "")
	if type != "":
		if_exe = _load_helper(type, data["if"])
	else:
		print_debug("Cond invalid type")
		
	type = data["then"].get("type", "")
	if type != "":
		then_exe = _load_helper(type, data["then"])
	else:
		print_debug("If invalid type")
		
	type = data["else"].get("type", "")
	if type != "":
		else_exe = _load_helper(type, data["else"])
	else:
		print_debug("Else invalid type")

func set_comp(get_exe: Callable) -> void:
	if_exe.set_comp(get_exe)
	then_exe.set_comp(get_exe)
	else_exe.set_comp(get_exe)

func execute(context: Dictionary = {"result": {}}) -> Dictionary:
	context = if_exe.execute(context)
	if context["current"]:
		return then_exe.execute(context)
	else:
		return else_exe.execute(context)

func execute_then(context: Dictionary = {"result": {}}) -> Dictionary:
	return then_exe.execute(context)

func pre_cond() -> bool:
	return if_exe.execute({"result": {}})["current"]

func _load_helper(type : String, data: Dictionary) -> EMC_Action:
	var res: Variant = Preloader.get_resource("res://util/action/" + type + "_action.gd")
	assert(res != null, "Resource with path: res://util/action/" + type + "_action.gd not found!")
	return res.new(data)
	

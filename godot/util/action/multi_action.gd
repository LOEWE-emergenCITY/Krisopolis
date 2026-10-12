extends EMC_Action
class_name EMC_Multi_Action

const AND := "and"
const ARRAY := "array"
const OR := "or"

@export var exes: Array[EMC_Action]
@export var acc: String = ARRAY

func _init(data : Dictionary = {}) -> void:
	if not data.has_all(["acc", "actions"]):
		#print_debug("Missing Accumulator")
		return
	#else:
		#acc = data["acc"]
	
	for action: Dictionary in data.get("actions"):
		if typeof(action) != TYPE_DICTIONARY:
			continue
		
		var type: String = action.get("type", "")
		if type != "":
			var res: Variant = ResourceLoader.load("res://util/action/" + type + "_action.gd")
			#if res == null:
				#res = ResourceLoader.load("res://util/action/" + type + "_action.gd")
				
			exes.append(res.new(action))

func set_comp(get_exe: Callable) -> void:
	for action in exes:
		action.set_comp(get_exe)

func execute(context: Dictionary = {"result": {}}) -> Dictionary:
	if acc == AND:
		for exe : EMC_Action in exes:
			context = exe.execute(context)
			if context["current"] == null or not context["current"]:
				context["current"] = false
				return context
		context["current"] = true
		return context
	elif acc == OR:
		for exe : EMC_Action in exes:
			context = exe.execute(context)
			if context["current"] != null and context["current"]:
				context["current"] = true
				return context
		context["current"] = false
		return context
	elif acc == ARRAY:
		var result := []
		for exe : EMC_Action in exes:
			context = exe.execute(context)
		return context
	context["current"] = null
	return context

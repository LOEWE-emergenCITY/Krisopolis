extends EMC_Action
class_name EMC_Single_Action

@export var method: String
@export var params: Array
@export var comp_name: String
@export var result_name: String
@export var needs_resolve: bool
var exe: Callable
var get_exe: Callable
var comp: Node = null
var comp_path: NodePath

func _init(data : Dictionary = {}) -> void:
	if not data.has_all(["method", "params", "system"]):
		#print_debug("Missing Dictionary entries")
		return
		
	method = data["method"]
	params = data["params"]
	for param: Variant in params:
		if typeof(param) == TYPE_ARRAY:
			for p: Variant in param:
				if typeof(p) == TYPE_STRING and (p as String).begins_with("$"):
					needs_resolve = true
					break
		elif typeof(param) == TYPE_STRING and (param as String).begins_with("$"):
			needs_resolve = true
			break
					
	comp_name = data["system"]
	result_name = data.get("as", "")

func set_comp(get_exe: Callable) -> void:
	comp = get_exe.call(comp_name)
	comp_path = comp.get_path()
	exe = Callable(comp, method)
		
func execute(context: Dictionary = {"result": {}}) -> Dictionary:
	if exe.is_null() or not exe.is_valid():
		if comp == null:
			comp = Global.get_node(comp_path)
		if comp != null and comp.has_method(method):
			exe = Callable(comp, method)
		else:
			print_debug(comp_name + " does not have method " + method)
			
	var resolved_params: Array = params
	if needs_resolve:
		resolved_params = resolve_params(context)
		
	var result: Variant = exe.callv(resolved_params)
	if not result_name.is_empty():
		context["result"][result_name] = result
	context["current"] = result
	return context

func resolve_params(context: Dictionary) -> Array:
	var result: Array = []
	for param: Variant in params:
		if typeof(param) == TYPE_ARRAY:
			var deep_result: Array = []
			for p: Variant in param:
				if typeof(p) == TYPE_STRING:
					if (p as String).begins_with("$result."):
						p = p.substr(8)
						if context["result"].has(p):
							deep_result.append(context["result"][p])
						else:
							printerr("Action: %s with method %s, parameter %s not set" % [comp_name, method, p])
					elif (p as String) == "$context":
						deep_result.append(context)
					else:
						deep_result.append(p)
				else:
					deep_result.append(p)
			result.append(deep_result)
			
		elif typeof(param) == TYPE_STRING:
			if (param as String).begins_with("$result."):
				param = param.substr(8)
				if context["result"].has(param):
					result.append(context["result"][param])
				else:
					printerr("Action: %s with method %s, parameter %s not set" % [comp_name, method, param])
			elif (param as String) == "$context":
				result.append(context)
			else:
				result.append(param)
		else:
			result.append(param)
	return result

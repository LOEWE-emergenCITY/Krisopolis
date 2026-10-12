extends Node
class_name VRV_GSI

## GSI stands for Game Script Interface.
## The name is inspiered by API

var method_cache: Dictionary = {}
func _init() -> void:
	for dict in get_method_list():
		var args: Array
		var default_count: int = len(dict["default_args"])
		for arg: Dictionary in dict["args"]:
			args.append(arg["type"])
		
		method_cache[dict["name"]] = {
			"args": args,
			"default": default_count,
			"return": dict["return"]
		}

func get_method_signature(method_name: String) -> Dictionary:
	return method_cache[method_name]
	
func call_method(method_name: String, args: Array) -> Variant:
	return callv(method_name, args)
	
func has_method_name(method_name: String) -> bool:
	return method_cache.has(method_name)

func get_var_or(variable: Variant, value: Variant) -> Variant:
	if variable == null:
		return value
	return variable

func and_bool(a: bool, b: bool) -> bool:
	return a and b

func not_bool(a: bool) -> bool:
	return not a

func eq_bool(a: bool, b: bool) -> bool:
	return a == b

func _and(...values: Array) -> bool:
	return values.all(func(a: bool) -> bool: return a)

func or_bool(a: bool, b: bool) -> bool:
	return a or b

func add(a: int, b: int) -> int:
	return a + b

func neq_int(a: int, b: int) -> bool:
	return a != b 
	
func eq_int(a: int, b: int) -> bool:
	return a == b 

func int_to_string(v: int) -> String:
	return String.num(v)

func output(stuff: Variant) -> Variant:
	print(stuff)
	return stuff

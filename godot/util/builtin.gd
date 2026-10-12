extends Node
class_name EMC_Builtin

func define(value: Variant) -> Variant:
	return value

func call_act(action_name: String, context: Variant) -> Variant:
	return JsonMngr.get_action(action_name).execute(context)
	

extends Resource
class_name EMC_NPC_Resource

@export var comps: Array[Resource]

func add_comp(comp: Variant) -> void:
	comps.append(comp)

func get_comp(comp_class: Script) -> Variant:
	for comp: Variant in comps:
		if  is_instance_of(comp, comp_class):
			return comp
	return null
	
func has_comp(comp_class: Variant) -> bool:
	for comp: Variant in comps:
		if  is_instance_of(comp, comp_class):
			return true
	return false

func get_comp_by_name(comp_name: String) -> Variant:
	for comp: Variant in comps:
		if comp.get_script().resource_path.get_file().split(".")[0].split("_")[1] == comp_name:
			return comp
	return null

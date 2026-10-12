extends Resource
class_name EMC_AllRes

@export var data: Dictionary
 
func add_res(p_name: String, p_data: Variant) -> void:
	data[p_name] = p_data
	emit_changed()

func get_res(p_name: String, default: Variant = null) -> Variant:
	return data.get(p_name, default)

static func load_res(file_name: String, flag: ResourceLoader.CacheMode = ResourceLoader.CacheMode.CACHE_MODE_REUSE) -> EMC_AllRes:
	var data : EMC_AllRes
	if ResourceLoader.exists(file_name):
		data = ResourceLoader.load(file_name, "", flag)
	else:
		data = EMC_AllRes.new()
	return data

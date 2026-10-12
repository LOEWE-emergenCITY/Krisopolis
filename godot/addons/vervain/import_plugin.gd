@tool
extends EditorImportPlugin

enum Presets { DEFAULT }

func _get_importer_name():
	return "spexify.vervain"

func _get_visible_name():
	return "Vervain Script"

func _get_recognized_extensions():
	return ["vrv"]

func _get_save_extension():
	return "tres"

func _get_resource_type():
	return "VRV_Script"

func _get_preset_count():
	return Presets.size()

func _get_preset_name(preset_index):
	match preset_index:
		Presets.DEFAULT:
			return "Default"
		_:
			return "Unknown"

func _get_import_options(path, preset_index):
	match preset_index:
		Presets.DEFAULT:
			return []
		_:
			return []

func _get_option_visibility(path, option_name, options):
	return true

func _import(source_file, save_path, options, r_platform_variants, r_gen_files):
	var file = FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()

	var line = file.get_as_text(true)
	print("Vervain: Importing VRV_Script %s" % source_file)
	var dialogue: VRV_Script = VRV_Script_Parser.parse_script(line) # VRV_Dialogue.parse_dialogue(line)
	if dialogue != null:
		EMC_Util.print_success("Vervain: Imported %s" % source_file)
		return ResourceSaver.save(dialogue, "%s.%s" % [save_path, _get_save_extension()])
	else:
		printerr("Vervain: Import Failed %s" % source_file)

func _get_priority():
	return 1.0

func _get_import_order():
	return ResourceImporter.ImportOrder.IMPORT_ORDER_DEFAULT

@tool
extends EditorPlugin

var import_plugin

func _enter_tree() -> void:
	import_plugin = preload("import_plugin.gd").new()
	add_import_plugin(import_plugin)

func _exit_tree() -> void:
	import_plugin = preload("import_plugin.gd").new()
	add_import_plugin(import_plugin)

@abstract
extends Control
class_name EMC_GUI

signal opened
signal closed(gui : EMC_GUI)

@abstract func close() -> void
#	hide()
#	closed.emit()

#func _unhandled_input(event : InputEvent) -> void:
	#if visible:
		#get_viewport().set_input_as_handled()

#func open() -> void:
	#pass
	#opened.emit()

#func close() -> void:
	#pass
	#closed.emit()

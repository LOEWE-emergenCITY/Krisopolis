extends EMC_GUI
class_name EMC_Icon_Information_GUI


func open(_irrelevant : Variant = null) -> void:
	show()
	opened.emit()


func _on_continue_btn_pressed() -> void:
	close()


func close() -> void:
	hide()
	closed.emit(self)

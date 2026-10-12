extends EMC_GUI
class_name EMC_TooltipGUI


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


func open(p_text: String) -> void:
	$VBoxContainer/PanelContainer/RichTextLabel.text = "[color=black]" + p_text + "[/color]"
	show()
	opened.emit()

func close() -> void:
	hide()
	closed.emit(self)

func _on_back_btn_pressed() -> void:
	close()

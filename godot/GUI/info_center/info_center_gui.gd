extends EMC_GUI
class_name EMC_Info_Center

@onready var vbc: VBoxContainer = $Panel/Margin/VBC/PanelContainer/VBC
const ICON_AND_TEXT := preload("res://GUI/info_center/icon_and_text.tscn")
const NO_ENTRY_ICON : Texture = preload("res://assets/GUI/icons/no_entry_icon.png")

func _create_entry(text: String, icon: Texture) -> HBoxContainer:
	var new: HBoxContainer = ICON_AND_TEXT.instantiate()
	(new.get_node("Text") as RichTextLabel).set_text(text)
	(new.get_node("Icon") as TextureRect).set_texture(icon)
	return new

func open() -> void:
	for child: Control in vbc.get_children():
		vbc.remove_child(child)
		child.queue_free()
	
	for state: String in OverworldStatesMngr.get_every_state_as_name():
		vbc.add_child(_create_entry(
			"[center]" + OverworldStatesMngr.state_to_descr[state],
			 OverworldStatesMngr.state_to_icon[state]))
	
	for flag: String in OverworldStatesMngr.get_flags("NoEntry"):
		vbc.add_child(_create_entry(
			"[center]" + flag,
				NO_ENTRY_ICON))
	
	show()
	opened.emit()
	
func close() -> void:
	hide()
	closed.emit(self)

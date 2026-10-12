extends EMC_GUI

var _inventory_ref : EMC_Inventory

@onready var rich_text_label :RichTextLabel = $PanelContainer/VBoxContainer/PanelContainer/RichTextLabel


func setup(p_inventory_ref: EMC_Inventory) -> void:
	_inventory_ref = p_inventory_ref
	rich_text_label.text = "In der Regentonne sind [color=#7bb0df]" + str(float(OverworldStatesMngr.get_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL)) / 4) + "l Wasser[/color]."

func _on_get_water_btn_pressed() -> void:
	SoundMngr.play_sound("water")
	if OverworldStatesMngr.get_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL) > 0:
		if _inventory_ref.add_new_item(EMC_Item.IDs.WATER_DIRTY):
			OverworldStatesMngr.set_furniture_state(
				EMC_Upgrade.IDs.RAINWATER_BARREL,
				OverworldStatesMngr.get_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL) - 1
			)
			rich_text_label.text = "In der Regentonne sind [color=#7bb0df]" + str(float(OverworldStatesMngr.get_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL)) / 4) + "l Wasser[/color]."

func _on_done_btn_pressed() -> void:
	close()

func open() -> void:
	rich_text_label.text = "In der Regentonne sind [color=#7bb0df]" + str(float(OverworldStatesMngr.get_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL)) / 4) + "l Wasser[/color]."
	#$SFX/OpenGUISFX.play()
	show()
	opened.emit()

func close() -> void:
	hide()
	closed.emit(self)

extends EMC_GUI
class_name EMC_UpgradeInfo

const UX_BUTTON = preload("res://util/UX_button.tscn")

@onready var upgrade_name: RichTextLabel = $Panel/Margin/VBC/Description/VBC/Name
@onready var components: RichTextLabel = $Panel/Margin/VBC/Description/VBC/Components
@onready var description: RichTextLabel = $Panel/Margin/VBC/Description/VBC/Description
@onready var slot: EMC_Upgrade_Slot = $Panel/Margin/VBC/CC/Upgrade

@onready var buttons: HBoxContainer = $Panel/Margin/VBC/HBC/Buttons

func open(sender: EMC_Upgrade, p_buttons: Array[Dictionary] = []) -> void:
	for button in buttons.get_children():
		button.queue_free()
	
	for button_dict in p_buttons:
		if not button_dict.has_all(["text", "callback", "design"]):
			printerr("In ItemInfoGui: missing button entries!")
			
		var button: Button = UX_BUTTON.instantiate()
		button.text = button_dict.get("text", "NOTEXT")
		var callback: Callable = (func () -> void:
			self.close()
			button_dict.get("callback", Callable()).call())
		button.pressed.connect(callback)
		button.set_theme_type_variation(button_dict.get("design", "Button"))
		
		if button_dict.has("disable"):
			button.disabled = button_dict["disable"]
		
		buttons.add_child(button)
	
	# Item Name
	upgrade_name.clear()
	upgrade_name.append_text("[color=black]" + sender.get_display_name() + "[/color]")
	
	const price_color = Color.GOLDENROD
	components.clear()
	components.append_text("[color=" + price_color.to_html(false) + "]" + str(sender.get_price()) + "eC[/color]")
	
	#Description of item:
	description.clear()
	description.append_text("[color=black][i]" + sender.get_description() + "[/i][/color]")
	
	slot.set_upgrade(sender)
	
	show()
	opened.emit()
	

func close() -> void:
	hide()
	
	for button in buttons.get_children():
		button.queue_free()
	
	closed.emit(self)

func _on_cancel_pressed() -> void:
	close()

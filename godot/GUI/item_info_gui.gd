extends EMC_GUI
class_name EMC_ItemInfo

const UX_BUTTON = preload("res://util/UX_button.tscn")

@onready var item_name: RichTextLabel = $Panel/Margin/VBC/Description/VBC/Name
@onready var components: RichTextLabel = $Panel/Margin/VBC/Description/VBC/Components
@onready var description: RichTextLabel = $Panel/Margin/VBC/Description/VBC/Description
@onready var slot: EMC_Item_Slot = $Panel/Margin/VBC/CC/Slot

@onready var buttons: HBoxContainer = $Panel/Margin/VBC/HBC/Buttons

func open(sender: EMC_Item, p_buttons: Array = []) -> void:
	for button in buttons.get_children():
		button.queue_free()
	
	for button_dict: Dictionary in p_buttons:
		if not button_dict.has_all(["text", "callback", "design"]):
			printerr("In ItemInfoGui: missing button entries!")
			
		var button: Button = UX_BUTTON.instantiate()
		button.text = button_dict.get("text", "NOTEXT")
		var callback: Callable = (func () -> void:
			self.close()
			button_dict.get("callback", Callable()).call(sender))
		button.pressed.connect(callback)
		button.set_theme_type_variation(button_dict.get("design", "Button"))
		
		buttons.add_child(button)
	
	# Item Name
	item_name.clear()
	item_name.append_text("[color=black]" + sender.get_item_name() + "[/color]")
	
	#Components of item
	var comps := sender.get_comps()
	var comp_string: String = ""
	for comp in comps:
		var str: String = comp.get_colored_name_with_vals()
		if not str.is_empty():
			comp_string += str + ", "
	#Remove superfluous comma:
	comp_string = comp_string.left(comp_string.length() - 2)
	
	components.clear()
	components.append_text("[color=black]" + comp_string + "[/color]")
	
	#Description of item:
	description.clear()
	description.append_text("[color=black][i]" + sender.get_descr() + "[/i][/color]")
	
	slot.set_item(sender)
	
	show()
	opened.emit()
	

func close() -> void:
	hide()
	
	for button in buttons.get_children():
		button.queue_free()
	
	closed.emit(self)

func _on_cancel_pressed() -> void:
	close()

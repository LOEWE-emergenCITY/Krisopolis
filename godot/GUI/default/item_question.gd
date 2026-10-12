extends EMC_GUI
class_name EMC_ItemQuestion

@onready var confirm_btn : Button = $VBoxContainer/HBoxContainer/ConfirmBtn
@onready var back_btn : Button = $VBoxContainer/HBoxContainer/BackBtn
@onready var question : RichTextLabel = $VBoxContainer/PanelContainer/RichTextLabel
@onready var slot : EMC_Item_Slot = $VBoxContainer/CC/Slot

@export var _avatar : EMC_Avatar
@export var _gui_mngr: EMC_GUIMngr

var _inventory : EMC_Inventory
var _item : EMC_Item

func setup(p_inventory : EMC_Inventory) -> void:
	_inventory = p_inventory
	slot.item_long_pressed.connect(item_long_pressed)

func open(p_item : EMC_Item, text : Dictionary = {}) -> void: 
	
	var question_text : String = text.get("question", "Möchstest du %s jetzt essen oder für später aufheben?")
	var answere_text : String = text.get("answere", "Essen")
	var decline_text : String = text.get("decline", "Aufheben")
	
	self.show()
	opened.emit()
	
	_item = p_item
	
	if question_text.find("%s") != -1:
		question.set_text(question_text % _item.name)
	else:
		question.set_text(question_text)
	if not answere_text.is_empty():
		confirm_btn.set_text(answere_text)
		confirm_btn.show()
	else:
		confirm_btn.hide()
	
	slot.set_item(_item)
	
func close() -> void:
	if slot.has_item():
		slot.remove_item()
	
	self.hide()
	closed.emit(self)

func _on_confirm_btn_pressed() -> void:
	slot.remove_item()
	_avatar.consume_item(_item)
	_inventory.remove_item(_item)
	close()

func _on_back_btn_pressed() -> void:
	slot.remove_item()
	close()

func item_long_pressed(item: EMC_Item, blocked: bool) -> void:
	_gui_mngr.request_gui("ItemInfoGui", [item])

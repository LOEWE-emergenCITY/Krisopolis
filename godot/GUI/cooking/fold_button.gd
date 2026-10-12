extends MarginContainer
class_name EMC_FoldButton

signal pressed

@onready var _label: Label = $Margin/HBoxContainer/Label
@onready var _slot: EMC_Item_Slot = $Margin/HBoxContainer/Slot_BG

@export var text: String:
	get: 
		return _label.get_text()
	set(p_text):
		await ready
		_label.set_text(p_text)

@export var item: EMC_Item:
	get:
		return _slot.get_item()
	set(p_item):
		await ready
		_slot.set_item(p_item)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var parent_rect := get_parent_control().get_rect()
	var child_rect := get_global_rect()
	
	var child_pos := parent_rect.size - child_rect.size
	
	var left := -child_pos.x - child_rect.size.x
	var right := -15
	
	var top := -(parent_rect.size.y - child_rect.size.y)
	var bottom := -(parent_rect.size.y - child_rect.size.y)
	
	add_theme_constant_override("margin_left", left)
	add_theme_constant_override("margin_right", right)
	add_theme_constant_override("margin_top", top)
	add_theme_constant_override("margin_bottom", bottom)


func _on_button_pressed() -> void:
	pressed.emit()

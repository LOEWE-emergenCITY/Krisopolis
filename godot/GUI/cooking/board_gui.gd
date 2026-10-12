extends EMC_GUI
class_name EMC_Board_GUI

@export var _gui_mngr: EMC_GUIMngr

var _ingredients: EMC_Inventory = EMC_Inventory.new(6)
var _inventory: EMC_Inventory

@onready var bowl: EMC_Inventory_UI = $VBC/Panel/Margin/VBC/VBC/VBC/Panel/Bowl
@onready var ingredients_button: Button = $VBC/Panel/Margin/VBC/VBC/VBC/Panel/Ingredients
@onready var consume: Button = $VBC/Panel/Margin/VBC/VBC/HBC/CC/HBC/Consume

#func _ready() -> void:
	#bowl.set_inventory(_inventory)

func setup(p_inventory: EMC_Inventory) -> void:
	_inventory = p_inventory
	bowl.set_inventory(_ingredients)

func open(p_ingredients: EMC_Inventory = null) -> void:
	if p_ingredients != null and not p_ingredients.is_empty():
		_ingredients = p_ingredients
		ingredients_button.hide()
		consume.set_disabled(false)
		bowl.set_inventory(_ingredients)
	else:
		ingredients_button.show()
		consume.set_disabled(true)
		
	bowl.reload()
	
	show()
	opened.emit()
	
func _on_ingredients_pressed() -> void:
	_gui_mngr.queue_gui("FridgeGui", ["BoardGui"])
	close()

func close() -> void:
	hide()
	closed.emit(self)

func _on_back_pressed() -> void:
	for item: EMC_Item in _ingredients.get_items():
		_inventory.add_item(item)
		
	_ingredients.clear_items()
	
	close()

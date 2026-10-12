extends EMC_GUI
class_name EMC_Fridge_GUI

@export var _gui_mngr: EMC_GUIMngr

@onready var inventory_ui: EMC_Inventory_UI = $VBC/Panel/Margin/VBC/VBC/VBC/VBC/Panel/InventoryUI
@onready var bowl_ui: EMC_Inventory_UI = $VBC/Panel/Margin/VBC/VBC/VBC/VBC/Panel2/Bowl

var _inventory: EMC_Inventory
var _bowl: EMC_Inventory = EMC_Inventory.new(6)
var _gui_name: String

func setup(p_inventory: EMC_Inventory) -> void:
	_inventory = p_inventory
	inventory_ui.set_inventory(_inventory)

func _ready() -> void:
	bowl_ui.set_inventory(_bowl)

func open(p_gui_name: String) -> void:
	_gui_name = p_gui_name
	
	bowl_ui.reload()
	inventory_ui.reload()
	
	show()
	opened.emit()

func _on_continue_pressed() -> void:
	_gui_mngr.queue_gui(_gui_name, [_bowl])
	close()

func close() -> void:
	hide()
	closed.emit(self)

func _on_back_pressed() -> void:
	for item: EMC_Item in _bowl.get_items():
		_inventory.add_item(item)
		
	_bowl.clear_items()
	
	close()

func _on_inventory_item_clicked(sender: EMC_Item) -> void:
	if not _bowl.has_space():
		return
	
	_inventory.remove_item(sender)
	_bowl.add_item(sender)

func _on_bowl_item_clicked(sender: EMC_Item) -> void:
	_bowl.remove_item(sender)
	_inventory.add_item(sender)

func _on_inventory_item_long_pressed(item: EMC_Item, _blocked: bool) -> void:
	var info: Array[Dictionary]

	info.append({"text": "Auswählen", "callback": _on_inventory_item_clicked, "design": "ConfirmButton"})

	_gui_mngr.overlay_gui("ItemInfoGui", [item, info])

func _on_bowl_item_long_pressed(item: EMC_Item, _blocked: bool) -> void:
	var info: Array[Dictionary]

	info.append({"text": "Abwählen", "callback": _on_bowl_item_clicked, "design": "CancelButton"})

	_gui_mngr.overlay_gui("ItemInfoGui", [item, info])

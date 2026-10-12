extends Control

const buy_text: String = "Kaufen"
const sell_text: String = "Zurückgeben"

var _inventory : EMC_Inventory
var _tmp_inventory := EMC_Inventory.new()
var _shop_inventory := EMC_Inventory.new()
var _balance : int = Global.get_e_coins()

@onready var label_ecoins := $ColorRect/MarginContainer/PanelContainer/HBoxContainer/RichTextLabel
@onready var inventory_ui : EMC_Inventory_UI = $ColorRect/Margin/Main/InventoryPanel/InventorySection/Panel/InventoryUI
@onready var shop_ui : EMC_Inventory_UI = $ColorRect/Margin/Main/ShopPanel/ShopSection/Panel/InventoryUI
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var item_info_gui: EMC_ItemInfo = $CanvasLayer/ItemInfoGui

# Tutorial
@onready var tutorial: Control = $CanvasLayer/Tutorial
@onready var root_shop: MarginContainer = $ColorRect/Margin
@onready var root_coin: MarginContainer = $ColorRect/MarginContainer


func _ready() -> void:
	_add_balance(0)
	
	item_info_gui.closed.connect(hide_canvas)
	
	_inventory = Global.session["inventory"]# Global.get_inventory()
	if _inventory == null:
		_inventory = EMC_Inventory.new()
	
	for item in _inventory.get_dup_items():
		_tmp_inventory.add_item(item)
	
	inventory_ui.set_inventory(_tmp_inventory)
	inventory_ui.reload()
	inventory_ui.block_first_items(_inventory.get_num_item())
	inventory_ui.item_clicked.connect(_on_inventory_item_clicked)
	inventory_ui.item_long_pressed.connect(_on_item_long_pressed.bindv([sell_text, _on_inventory_item_clicked, "CancelButton"]))
	
	for item_id : EMC_Item.IDs in JsonMngr.get_all_ids():
		if item_id == EMC_Item.IDs.DUMMY:
			continue
		var item := EMC_Item.make_from_id(item_id)
		if item.has_comp(EMC_IC_Cost) and (item.get_comp(EMC_IC_Cost) as EMC_IC_Cost).is_buyable():
			_shop_inventory.add_item(item)
			
	_shop_inventory.num_slots = _shop_inventory.get_num_item()
	shop_ui.set_inventory(_shop_inventory)
	shop_ui.item_clicked.connect(_on_shop_item_clicked)
	shop_ui.item_long_pressed.connect(_on_item_long_pressed.bindv([buy_text, _on_shop_item_clicked, "ConfirmButton"]))
	shop_ui.reload()
	#reload()

func hide_canvas(args: Variant) -> void:
	canvas_modulate.hide()

func reload() -> void:
	shop_ui.reload()
	inventory_ui.reload()

func _on_item_long_pressed(sender: EMC_Item, blocked: bool, text: String, callback: Callable, design: String) -> void:
	#_display_info(sender)
	sender.clicked_sound()
	canvas_modulate.show()
	var info: Array[Dictionary]
	info.assign([] if blocked else [{"text": text, "callback": callback, "design": design}])
	item_info_gui.open(sender, info)
	
	#callback.call(sender)

func _on_shop_item_clicked(sender: EMC_Item) -> void:
	sender.clicked_sound()
	canvas_modulate.hide()
	#item_info_gui.hide()
	
	#_display_info(sender)
	#sender.clicked_sound()
	
	var comp := sender.get_comp(EMC_IC_Cost)
	if comp == null:
		return
	
	var cost : int = comp.get_cost()

	var new_item : EMC_Item = EMC_Item.make_from_id(sender.get_id())
	if _balance - cost >= 0 and _tmp_inventory.has_space():
		_tmp_inventory.add_item(new_item)
		_add_balance(-cost)
		
	shop_ui.reconnect()

func _on_inventory_item_clicked(sender : EMC_Item) -> void:
	canvas_modulate.hide()
	sender.clicked_sound()
	#item_info_gui.hide()
	
	#_display_info(sender)
	_tmp_inventory.remove_item(sender)
	var comp := sender.get_comp(EMC_IC_Cost)
	if comp != null:
		_add_balance(comp.get_cost())

func _add_balance(value : int) -> void:
	_balance += value
	label_ecoins.clear()
	label_ecoins.append_text("[right][color=black]" + str(_balance) + "[/color][/right]")

func _notification(what : int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if item_info_gui.visible:
			item_info_gui.close()
		elif tutorial.visible:
			_on_tu_back_pressed()
		else:
			_on_cancel_pressed()

func _on_home_pressed() -> void:
	_tmp_inventory.sort_custom(EMC_Inventory.sort_by_id)
	Global.session["inventory"] = _tmp_inventory
	#Global.set_inventory(_tmp_inventory)
	Global.set_e_coins(_balance)
	Global.goto_scene(Global.CRISIS_START_SCENE)


func _on_cancel_pressed() -> void:
	Global.session["inventory"] = _inventory
	#Global.set_inventory(_inventory)
	#Global.goto_scene(Global.MAIN_MENU_SCENE)
	Global.goto_scene(Global.UPGRADE_CENTER_SCENE)

func _on_help_pressed() -> void:
	root_coin.hide()
	root_shop.hide()
	canvas_modulate.show()
	tutorial.show()

func _on_tu_back_pressed() -> void:
	root_coin.show()
	root_shop.show()
	canvas_modulate.hide()
	tutorial.hide()

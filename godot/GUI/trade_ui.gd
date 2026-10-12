class_name EMC_TradeUI
extends EMC_GUI

@export var mood_texture : AtlasTexture
@export var gui_mngr : EMC_GUIMngr

@onready var portrait : TextureRect = $VBC/Header/HBC/VBC/Portrait
@onready var monologe : RichTextLabel = $VBC/Header/HBC/Baloon/Text
@onready var mood : TextureRect = $VBC/Header/HBC/VBC/Mood

@onready var inventory_grid : EMC_Inventory_UI = $VBC/Inventories/Inventory/InventoryGrid
@onready var trader_grid : EMC_Inventory_UI = $VBC/Inventories/Trader/InventoryGrid
@onready var inventories : TabContainer = $VBC/Inventories

@onready var sell : HBoxContainer = $VBC/Exchange/Sell/HBC
@onready var buy : HBoxContainer = $VBC/Exchange/Buy/HBC

#@onready var deal : Button = $VBC/Buttons/Deal
@onready var deal: Button = $VBC/Buttons/Control/Deal
@onready var progress_deal: TextureProgressBar = $VBC/Buttons/Control/ProgressDeal
@onready var overload: CPUParticles2D = $VBC/Header/HBC/VBC/Mood/Overload

var _ITEM_PANEL_SCN := preload("res://inventory/item_panel.tscn")

var _inventory : EMC_Inventory

var _npc_trade: EMC_NPC_Trading
var _npc_descr: EMC_NPC_Descr
var _npc_inventory : EMC_Inventory

var _sell_items : Array[EMC_Item]
var _buy_items : Array[EMC_Item]

var trade_score : float = -1.0

func setup(p_inventory : EMC_Inventory) -> void:
	_inventory = p_inventory
	
	inventory_grid.set_inventory(_inventory)
	
	inventory_grid.item_clicked.connect(_on_inventory_item_clicked.bind(true))
	trader_grid.item_clicked.connect(_on_inventory_item_clicked.bind(false))
	inventory_grid.item_long_pressed.connect(
		_on_item_long_pressed.bind([{"text": "Verkaufen", "callback": _on_inventory_item_clicked.bind(true), "design": "CancelButton"}]))
	trader_grid.item_long_pressed.connect(
		_on_item_long_pressed.bind([{"text": "Einkaufen", "callback": _on_inventory_item_clicked.bind(false), "design": "ConfirmButton"}]))
		#gui_mngr.request_gui.bind("ItemInfoGui", [self, {"text": "Einkaufen", "callback": _on_inventory_item_clicked.bind(false), "design": "ConfirmButton"}]))
	
	inventories.set_tab_title(0, "Rucksack")

func _on_item_long_pressed(sender: EMC_Item, blocked: bool, info: Array) -> void:
	#self.modulate = Color("#787878")
	gui_mngr.overlay_gui("ItemInfoGui", [sender, info])

func open(npc : EMC_NPC) -> void:
	_npc_trade = npc.npc_resource.get_comp(EMC_NPC_Trading)
	_npc_descr = npc.npc_resource.get_comp(EMC_NPC_Descr)
	
	inventories.set_tab_title(1, _npc_descr.get_npc_name())
	inventories.set_current_tab(1)
	
	_npc_inventory = _npc_trade.get_inventory()
	trader_grid.set_inventory(_npc_inventory)
	
	#Reset mood texture
	mood_texture.set_region(Rect2(1 * 64, 0, 64, 64))
	mood.set_texture(mood_texture)
	
	portrait.set_texture(_npc_descr.get_portrait())
	
	inventory_grid.reload()
	trader_grid.reload()

	progress_deal.set_max(_npc_trade._top)

	show()
	opened.emit()
	
func close() -> void:
	if not _sell_items.is_empty() or not _buy_items.is_empty():
		_on_cancel_pressed()
	
	hide()
	closed.emit(self)

###########################################Private Methods##########################################

func _on_inventory_item_clicked(sender : EMC_Item, backpack : bool) -> void:
	if ((backpack and 
			(sell.get_child_count() >= 5
			or sell.get_child_count() > _npc_inventory.get_free_num_slot())) or
		(not backpack and
			(buy.get_child_count() >= 5
			or buy.get_child_count() > _inventory.get_free_num_slot()))):
		SoundMngr.play_sound("talk", 0, 1.5)
		return
	sender.clicked_sound()
	
	var grid : EMC_Inventory_UI = inventory_grid if backpack else trader_grid
	var to_current : HBoxContainer = sell if backpack else buy
	var to_current_items : Array[EMC_Item] = _sell_items if backpack else _buy_items
	
	
	grid.get_inventory().remove_item(sender)
	var item_panel := _ITEM_PANEL_SCN.instantiate()
	var item_slot : EMC_Item_Slot = item_panel.get_child(0)
	item_slot.set_item(sender)
	to_current.add_child(item_panel)
	to_current.move_child(item_panel, 0 if backpack else -1)
	to_current_items.push_back(sender)

	var start_global: Vector2 = grid.get_item_slot(sender).get_global_position()
	
	animate.call_deferred(item_slot, start_global)
	
	item_slot.item_clicked.connect(_on_exchange_item_clicked.bind(backpack), CONNECT_ONE_SHOT)
	#sender.call_deferred("set_modulate", Color(1, 1, 1))
	
	monologe.set_text(_npc_trade.get_response(sender))
	
	_evaluat_trade()

func animate(slot: EMC_Item_Slot, start_pos: Vector2) -> void:
	var end_pos := slot.get_global_position()
	
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(slot, "position", slot.position, 0.5).from(start_pos-(slot.get_global_position()-Vector2(48, 0)))
	#slot.set_position(Vector2(16, 16))

func _on_exchange_item_clicked(sender : EMC_Item, backpack : bool) -> void:
	monologe.set_text("")
	var to_current : HBoxContainer = sell if backpack else buy
	var to_current_items : Array[EMC_Item] = _sell_items if backpack else _buy_items
	#var _current_inventory : EMC_Inventory = _inventory if backpack else _npc_inventory
	var grid : EMC_Inventory_UI = inventory_grid if backpack else trader_grid
	
	for item_panel in to_current.get_children():
		if item_panel.name == "Arrow":
			continue
		var slot : EMC_Item_Slot = item_panel.get_child(0)
		if slot.get_item() == sender:
			slot.remove_item()
		
			to_current.remove_child(item_panel)
			item_panel.queue_free()
			to_current_items.erase(sender)
			grid.get_inventory().add_item(sender)
			
			break
	
	_evaluat_trade()

func _evaluat_trade() -> void:
	trade_score = _npc_trade.calculate_trade_score(_sell_items, _buy_items)
	
	if trade_score >= _npc_trade._top:
		overload.emitting = true
	else:
		overload.emitting = false
	
	mood.set_texture(_npc_trade.get_mood_texture(trade_score, mood_texture))
	
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(progress_deal, "value", trade_score, 0.2)
	deal.disabled = _npc_trade.will_deal(trade_score)
	
	var color := _npc_trade.get_deal_color(trade_score)
	tween.parallel().tween_property(progress_deal, "tint_progress", color, 0.2)
	
	#if deal.disabled:
		##progress_deal.tint_progress = Color(0.32, 0.54, 0.78, 1)
		#tween.parallel().tween_property(progress_deal, "tint_progress", Color(0.32, 0.54, 0.78, 1), 0.2)
	#else:
		##progress_deal.tint_progress = Color(0.3, 0.7, 0.39, 1)
		#tween.parallel().set_trans(Tween.TRANS_SINE).tween_property(progress_deal, "tint_progress", Color(0.3, 0.7, 0.39, 1), 0.2)

func _on_cancel_pressed() -> void:
	for item in _sell_items:
		_inventory.add_item(item)
	_sell_items = []
	
	for child : PanelContainer in sell.get_children().slice(0,-1):
		child.get_child(0).remove_item()
		sell.remove_child(child)
		child.queue_free()
	
	for item in _buy_items:
		_npc_inventory.add_item(item)
	_buy_items = []
	
	for child : PanelContainer in buy.get_children().slice(1):
		child.get_child(0).remove_item()
		buy.remove_child(child)
		child.queue_free()
	
	close()

func _on_deal_pressed() -> void:
	if trade_score <= 0.0:
		var answer : bool = await gui_mngr.request_gui("ConfirmationGUI", [_npc_descr.get_npc_name() + " ist nicht sehr zufrieden mit dem Handel
		\n Sicher das du ihn trotzdem eingehen willst.
		\nEs könnte negative Einflüsse auf eure Beziehung haben."])
		
		if not answer:
			return
			
	_npc_trade.deal(trade_score)
	
	for item in _buy_items:
		_inventory.add_item(item)
	_buy_items = []
	
	for child : PanelContainer in buy.get_children().slice(1):
		child.get_child(0).remove_item()
		buy.remove_child(child)
		child.queue_free()
		
	for item in _sell_items:
		_npc_inventory.add_item(item)
	_sell_items = []
	
	for child : PanelContainer in sell.get_children().slice(0,-1):
		child.get_child(0).remove_item()
		sell.remove_child(child)
		child.queue_free()
		
	inventory_grid.reload()
	trader_grid.reload()
		
		#if trade_fairness > 1.5:
			#left_dialoge.set_text("I feel ripped of.")
			#text_left.show()
		#elif trade_fairness >= 1.0:
			#right_dialoge.set_text("That was a good trade.")
			#text_right.show()
		#else:
			#right_dialoge.set_text("I accept this trade just beacuse its you.")
			#text_right.show()
		#
	#else:
		#right_dialoge.set_text("I dont like this Trade.")
		#text_right.show()

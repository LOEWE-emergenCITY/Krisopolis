extends Control

@onready var label_ecoins := $ColorRect/Margin/Margin/Coins/HBoxContainer/RichTextLabel

@onready var upgrades_display : GridContainer = $ColorRect/Margin/UpgradePanel/VBC/GridContainer

@onready var _buy_btn: Button = $ColorRect/Margin/UpgradePanel/VBC/CC/HBC/BuyBtn
@onready var _equip_btn: Button = $ColorRect/Margin/UpgradePanel/VBC/CC/HBC/EquipBtn
@onready var _un_equip_btn: Button = $ColorRect/Margin/UpgradePanel/VBC/CC/HBC/UnEquipBtn
@onready var _star_explosion_VFX := $StarExplosionVFX
@onready var info: Button = $ColorRect/Margin/UpgradePanel/VBC/CC/HBC/Info

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var upgrade_info_gui: EMC_UpgradeInfo = $CanvasLayer/UpgradeInfoGui
@onready var tutorial: Control = $CanvasLayer/Tutorial
@onready var main: Control = $ColorRect/Margin


const _upgrade_scene := preload("res://preparePhase/upgrade_slot.tscn")
const _number_of_equipment_slots : int = 3 # the upgrade array in Global needs to be changed accordingly
var _balance : int = Global.get_e_coins()
var _last_clicked_upgrade : EMC_Upgrade
var _clicked_slot: EMC_Upgrade_Slot
var _equipped_upgrades : Array[EMC_Upgrade]
var _equpped_id: Array[int]

func _ready() -> void:
	SoundMngr.play_slow_musik()
	
	_equpped_id.assign(Global.session["upgrades"].map(func (up: EMC_Upgrade) -> int: return up.get_id())) #OverworldStatesMngr.get_upgardes_id()
	
	_add_balance(0)
	
	upgrade_info_gui.closed.connect(hide_canvas)
	
	for id : int in EMC_Upgrade.IDs.values():
		if id == EMC_Upgrade.IDs.EMPTY_SLOT:
			continue
		
		var upgrade_slot: EMC_Upgrade_Slot = _upgrade_scene.instantiate()
		var upgrade: EMC_Upgrade = EMC_Upgrade.new().setup(id)
		upgrade_slot.set_upgrade(upgrade)
		upgrade_slot.clicked.connect(_on_upgrade_clicked)
		upgrade_slot.long_pressed.connect(_on_upgrade_long_pressed)
		
		if id not in Global.get_upgrade_ids_unlocked():
			upgrade_slot.lock()
		
		if id in _equpped_id:
			upgrade_slot.equippe()
			_equipped_upgrades.append(upgrade)
		
		upgrades_display.add_child(upgrade_slot)

func get_slot(upgrade: EMC_Upgrade) -> EMC_Upgrade_Slot:
	for slot: EMC_Upgrade_Slot in upgrades_display.get_children():
		if slot.get_upgrade() == upgrade:
			return slot
	return null

func _add_balance(value : int) -> void:
	_balance += value
	label_ecoins.clear()
	label_ecoins.append_text("[right][color=black]" + str(_balance) + "[/color][/right]")

func hide_canvas(args: Variant) -> void:
	canvas_modulate.hide()

func _on_info_pressed() -> void:
	_on_upgrade_long_pressed(_clicked_slot)

func _on_upgrade_long_pressed(p_slot: EMC_Upgrade_Slot) -> void:
	_last_clicked_upgrade = p_slot.get_upgrade()
	_clicked_slot = p_slot
	
	_buy_btn.hide()
	_equip_btn.hide()
	_un_equip_btn.hide()
	info.hide()
	
	var _info: Array[Dictionary]
	
	if p_slot.equipped:
		_info.append({"text": "Abrüsten", "callback": _on_un_equip_btn_pressed, "design": "CancelButton"})
	elif not p_slot.locked:
		_info.append({"text": "Ausrüsten", "callback": _on_equip_btn_pressed, "design": "ConfirmButton"})
	else:
		_info.append(
			{
				"text": "Freischalten",
				"callback": _on_buy_btn_pressed,
				"design": "ConfirmButton",
				"disable": not _balance >= _last_clicked_upgrade.get_price()
			})
	
	canvas_modulate.show()
	upgrade_info_gui.open(p_slot.get_upgrade(), _info)

func _on_upgrade_clicked(p_slot : EMC_Upgrade_Slot) -> void:
	_last_clicked_upgrade = p_slot.get_upgrade()
	_clicked_slot = p_slot
	
	info.show()
	
	# check if upgrade is already equipped
	if p_slot.equipped:
		_buy_btn.hide()
		_equip_btn.hide()
		_un_equip_btn.show()
		return
			
	# check if upgrade is already unlocked
	if not p_slot.locked:
		_buy_btn.hide()
		_equip_btn.show()
		_un_equip_btn.hide()
	else:
		#_buy_btn.show()
		_equip_btn.hide()
		_un_equip_btn.hide()


func _on_buy_btn_pressed() -> void:
	if _balance >= _last_clicked_upgrade.get_price():
		_add_balance(-_last_clicked_upgrade.get_price())
		Global.unlock_upgrade_id(_last_clicked_upgrade.get_id())
		Global.set_e_coins(_balance)
		_buy_btn.hide()
		_equip_btn.hide()
		info.hide()
		
		_clicked_slot.unlock()
		#Play VFX at position of unlocked upgrade
		#_star_explosion_VFX.position = _last_clicked_upgrade.global_position + _last_clicked_upgrade.size/2
		#_star_explosion_VFX.emitting = true
		
		_clicked_slot.reset_highlight()
		_last_clicked_upgrade = null
		_clicked_slot = null
	else:
		SoundMngr.play_sound("BasicItem", 0, 0.4)

func _on_equip_btn_pressed() -> void:
	# see if there is a mutually exclusive upgrade already equipped and remove it
	for i in range(len(_equipped_upgrades)):
		if _equipped_upgrades[i].get_spawn_pos() == _last_clicked_upgrade.get_spawn_pos():
			
			get_slot(_equipped_upgrades[i]).unequippe()
			_equpped_id.erase(_equipped_upgrades[i].get_id())
			_equipped_upgrades.remove_at(i)
			
			_equipped_upgrades.append(_last_clicked_upgrade)
			_equpped_id.append(_last_clicked_upgrade.get_id())
			_clicked_slot.equippe()
			
			_equip_btn.hide()
			info.hide()
			_clicked_slot.reset_highlight()
			_last_clicked_upgrade = null
			_clicked_slot = null
			return
			
	if _equipped_upgrades.size() < 3:
		_equipped_upgrades.append(_last_clicked_upgrade)
		_clicked_slot.equippe()
		_equip_btn.hide()
		info.hide()
		_clicked_slot.reset_highlight()
		_last_clicked_upgrade = null
		_clicked_slot = null
	else:
		SoundMngr.play_sound("clicked", 1, 0.4)

func _on_un_equip_btn_pressed() -> void:
	_clicked_slot.unequippe()
	_equipped_upgrades.erase(_last_clicked_upgrade)
	_equpped_id.erase(_last_clicked_upgrade.get_id())
	
	_un_equip_btn.hide()
	info.hide()
	_clicked_slot.reset_highlight()
	_last_clicked_upgrade = null
	_clicked_slot = null

func _notification(what : int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if upgrade_info_gui.visible:
			upgrade_info_gui.close()
		elif tutorial.visible:
			_on_tu_back_pressed()
		else:
			_on_main_menu_btn_pressed()

func _on_main_menu_btn_pressed() -> void:
	Global.session["upgrades"] = _equipped_upgrades
	#OverworldStatesMngr.set_upgrades(_equipped_upgrades)
	Global.goto_scene(Global.MAIN_MENU_SCENE)
	#Global.goto_scene(Global.SHOP_SCENE)
	
func _on_continue_btn_pressed() -> void:
	Global.session["upgrades"] = _equipped_upgrades
	#OverworldStatesMngr.set_upgrades(_equipped_upgrades)
	Global.goto_scene(Global.SHOP_SCENE)

func _on_help_pressed() -> void:
	canvas_modulate.show()
	tutorial.show()
	main.hide()

func _on_tu_back_pressed() -> void:
	canvas_modulate.hide()
	tutorial.hide()
	main.show()

extends EMC_GUI
##Die GUI für das Anzeigen eines [EMC_Inventory]s des Spielers.
##
##Ein Inventar hat immer mehrere Slots, welche jeweils von bis zu einem [EC_Item]s belegt sein
##können oder nicht.
##Über toggleVisibility, open() und close() kann die Sichtbarkeit eingestellt werden.
##
##@tutorial(Mehr Infos in der Doku): https://sharelatex.tu-darmstadt.de/project/655b70099f37cc035f7e5fa4
class_name EMC_InventoryGUI

@onready var _label: RichTextLabel = $Inventory/Margin/VBC/Margin/Panel/Label
@onready var _consume_btn : Button = $Inventory/Margin/VBC/VBC/HBC/CC/HBC/Consume
@onready var _info_btn : Button = $Inventory/Margin/VBC/VBC/HBC/CC/HBC/Info
@onready var _continue_btn : TextureButton = $Inventory/Margin/VBC/VBC/HBC/Continue
@onready var _back_btn : TextureButton = $Inventory/Margin/VBC/VBC/HBC/Back
@onready var _inventory_ui : EMC_Inventory_UI = $Inventory/Margin/VBC/VBC/Panel/InventoryUI

@export var _avatar : EMC_Avatar
@export var _gui_mngr : EMC_GUIMngr
@export var _scoreboard: EMC_Scoreboard

var _inventory: EMC_Inventory
var _clicked_item : EMC_Item
var _is_continue : bool #Distinguish between the modes of the normal inventory and the SEOD-version


########################################## PUBLIC METHODS ##########################################
## Konstruktror des Inventars
## Es können die Anzahl der Slots ([param p_slot_cnt]) sowie der initiale Titel
## ([param p_title]) gesetzt werden

func setup(p_inventory: EMC_Inventory, p_title: String = "Inventar") -> void:
	_inventory = p_inventory
	set_title(p_title)
	
	_inventory_ui.set_inventory(_inventory)
	_inventory_ui.item_clicked.connect(_on_item_clicked)
	_inventory_ui.item_long_pressed.connect(_on_item_long_pressed)
	_inventory_ui.reload()

## Set the title of inventory GUI
func set_title(p_new_text: String) -> void:
	_label.text = "[center]" + p_new_text + "[/center]"

#func set_grid_height(height : int = 400) -> void:
	#$Inventory/VBC/ScrollContainer.custom_minimum_size.y = height

## Open the GUI
func open(p_is_continue : bool = false) -> void:
	_clear_gui()
	
	_is_continue = p_is_continue
	if _is_continue:
		_back_btn.hide()
		_continue_btn.show()
	else:
		_back_btn.show()
		_continue_btn.hide()
	
	_clicked_item = null
	show()
	opened.emit()
	#_reload_items()

## Close the GUI
func close() -> void:
	hide()
	closed.emit(self)
	if _is_continue:
		_avatar.get_home()

########################################## PRIVATE METHODS #########################################
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	$SpoiledVFX_Template.emitting = false

func _clear_gui() -> void:
	_consume_btn.hide()
	_info_btn.hide()

## Display information of clicked [EMC_Item]
## Call with [param sender] == null to clear to default state.
func _on_item_clicked(sender: EMC_Item) -> void:
	_clear_gui()
	
	_clicked_item = sender
	sender.clicked_sound()
	
	#The activate the Buttons we need in the appropriate situation
	_info_btn.show()
	if _item_consumable(sender) or sender.get_id() == JsonMngr.item_name_to_id("CHLOR_TABLETS"):
		_consume_btn.show()
	
	#And set the custom text
	_consume_btn.text = _determine_consume_btn_text(sender)

func _on_item_long_pressed(sender: EMC_Item, blocked: bool = false) -> void:
	_clear_gui()
	
	var info: Array[Dictionary]
	
	if _item_consumable(sender) or sender.get_id() == JsonMngr.item_name_to_id("CHLOR_TABLETS"):
		var text: String = _determine_consume_btn_text(sender)
		var design: String = "BlueButton" if sender.get_id() == JsonMngr.item_name_to_id("CHLOR_TABLETS") else "ConfirmButton"
		info.append({"text": text, "callback": _on_consume_pressed, "design": design})
	
	if not _is_continue:
		info.append({"text": "Entsorgen", "callback": _on_discard_pressed, "design": "CancelButton"})
	
	_gui_mngr.overlay_gui("ItemInfoGui", [sender, info])

func _item_consumable(item : EMC_Item) -> bool:
	#Commented as it shouldn't be usable in SEOD:
	#if item.get_ID() == JsonMngr.item_name_to_id("CHLOR_TABLETS"): 
		#return true
	#else:
	return item.has_comp(EMC_IC_Drink) or item.has_comp(EMC_IC_Food)

## CAUTION: Don't rename without changing the deffered call in _reload_items()
## If this is not called deferred, the positions of the slots are not correct (godot bug #30113)!
#func _add_VFXs() -> void:
	##Reset VFX
	#for child in $VFX_Instances.get_children():
		#$VFX_Instances.remove_child(child)
	#
	##Has to be done in extra loop, as only now the positions of the items are known
	#for slot in _slot_grid.get_children():
		#var item: EMC_Item = slot.get_item()
		#if item != null:
			#var IC_unpalatable := item.get_comp(EMC_IC_Unpalatable)
			#if IC_unpalatable != null:
				##Spoiled VFX
				#var new_spoiled_VFX := $SpoiledVFX_Template.duplicate()
				#new_spoiled_VFX.emitting = true
				 ##Magic number, dirty fix, no idea why the offset is needed:
				#const WEIRD_OFFSET := Vector2(180, 270)
				#new_spoiled_VFX.global_position = slot.position - WEIRD_OFFSET
				#$VFX_Instances.add_child(new_spoiled_VFX)


func _on_consume_pressed(sender: EMC_Item = null) -> void:
	if sender != null:
		_clicked_item = sender
	if _clicked_item == null:
		return
	if _clicked_item.get_id() == JsonMngr.item_name_to_id("CHLOR_TABLETS"): 
		if !_inventory.has_item(JsonMngr.item_name_to_id("WATER_DIRTY")):
			self.set_modulate(Color(0.4, 0.4, 0.4))
			await _gui_mngr.request_gui("TooltipGUI", ["Dreckiges Wasser zum Filtern ist nicht verfügbar."])
			self.set_modulate(Color(1.0, 1.0, 1.0))
		else:
			##Improvement idea: use new _inventory.use_item() method
			var comp_uses : EMC_IC_Uses = _clicked_item.get_comp(EMC_IC_Uses)
			comp_uses.use_item(1)
			_clicked_item.consumed_sound()
			
			if comp_uses.no_uses_left():
				_inventory.remove_item(_clicked_item)
			
			_inventory.remove_item_by_id(JsonMngr.item_name_to_id("WATER_DIRTY"))
			_inventory.add_new_item(JsonMngr.item_name_to_id("WATER"))
			
			_scoreboard.add_score("chlor")
	else:
		_avatar.consume_item(_clicked_item)
		_inventory.remove_item(_clicked_item)
		#_clicked_item.free()
		
	_clear_gui()

func _on_discard_pressed(sender: EMC_Item = null) -> void:
	if sender == null:
		_inventory.remove_item(_clicked_item)
	else:
		_inventory.remove_item(sender)
	SoundMngr.play_sound("TrashBin")
	_clear_gui()

func _determine_consume_btn_text(p_item: EMC_Item) -> String:
	if p_item.get_id() == JsonMngr.item_name_to_id("CHLOR_TABLETS"):
		return "Filtern"
	
	if p_item.has_comp(EMC_IC_Food):
		return "Essen"
	
	if p_item.get_comp(EMC_IC_Drink):
		return "Trinken"
	
	return "Konsumieren"

func _on_info_pressed() -> void:
	if _clicked_item != null:
		_on_item_long_pressed(_clicked_item)
		
		_inventory_ui.reset_all_highlights()

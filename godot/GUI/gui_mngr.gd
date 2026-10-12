extends Control
class_name  EMC_GUIMngr
#GUIs Upper Section:
@onready var _status_bars := $CL/VBC/UpperSection/HBC/StatusBars
#GUIs Middle Section:
@onready var _backpack_GUI : EMC_InventoryGUI = $CL/VBC/MiddleSection/BackpackGUI
@onready var _cooking_GUI : EMC_Cooking_GUI = $CL/VBC/MiddleSection/CookingGUI
@onready var seodGUI : EMC_SummaryEndOfDayGUI = $CL/VBC/MiddleSection/SummaryEndOfDayGUI
@onready var item_question_gui : EMC_ItemQuestion= $CL/VBC/MiddleSection/ItemQuestionGUI
@onready var fridge_gui: EMC_Fridge_GUI = $CL/VBC/MiddleSection/FridgeGui
@onready var board_gui: EMC_Board_GUI = $CL/VBC/MiddleSection/BoardGui

#@onready var _dialogue_gui : EMC_Dialogue_GUI = $CL/VBC/MiddleSection/DialogueGui
#GUIs Lower Section:
#@onready var tooltip_GUI := $CL/VBC/LowerSection/TooltipGUI
#@onready var confirmation_GUI := $CL/VBC/LowerSection/ConfirmationGUI
@onready var _rainwater_barrel_gui := $CL/VBC/MiddleSection/RainwaterBarrelGUI
#@onready var two_choice: EMC_TwoChoice = $CL/VBC/LowerSection/TwoChoice
#@onready var default_action_gui: EMC_DefaultActionGUI = $CL/VBC/LowerSection/DefaultActionGUI
@onready var end_game_gui: EMC_EndGameGUI = $CL/VBC/MiddleSection/EndGameGUI

@onready var middle_section := $CL/VBC/MiddleSection
@onready var lower_section := $CL/VBC/LowerSection

#GUIs Complete Screen
@onready var _city_map : EMC_CityMap = $CL/CityMap
@onready var _day_period_transition : EMC_GUI = $CL/DayPeriodTransition
@onready var _rain_animation : EMC_GUI = $CL/RainAnimation
@onready var _trade_ui : EMC_TradeUI = $CL/Trade
#@onready var handy_gui : EMC_Handy = $CL/HandyGUI
@onready var phone_gui: EMC_Phone = $CL/Phone
@onready var npc_interaction : EMC_Interaction_GUI = $CL/NpcInteraction
@onready var action_animation: EMC_ActionAnimtion = $CL/ActionAnimation

@onready var pause_menu_btn: TextureButton = $ButtonList/VBC/PauseMenuBtn
@onready var backpack_btn: TextureButton = $ButtonList/VBC/BackpackBtn
@onready var phone_btn: TextureButton = $ButtonList/VBC/PhoneBtn
@onready var info_center_btn: TextureButton = $ButtonList/VBC/InfoCenterBtn

@onready var canvas_modulate: CanvasModulate = $CanvasModulate

#@onready var emc_gsi: EMC_GSI = $"../EMC_GSI"

signal all_guis_closed

var all_the_guis : Array[EMC_GUI]
#var _prev_gui : EMC_GUI
var _active_guis : Array[EMC_GUI]
var _gui_queue : Array[QueueEntry]

@export var _stage_mngr : EMC_StageMngr
@export var _avatar : EMC_Avatar

#@export var dialogue_test: VRV_Script

func _ready() -> void:
	for child in middle_section.get_children():
		all_the_guis.append(child)
		
	for child in lower_section.get_children():
		all_the_guis.append(child)
		
	all_the_guis.append(_city_map)
	all_the_guis.append(_rain_animation)
	all_the_guis.append(_day_period_transition)
	all_the_guis.append(_trade_ui)
	#all_the_guis.append(handy_gui)
	all_the_guis.append(phone_gui)
	all_the_guis.append(npc_interaction)
	all_the_guis.append(action_animation)
	
	_set_guis_process_mode(all_the_guis, PROCESS_MODE_DISABLED)
	
func _notification(what : int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if is_any_gui():
			close_current_gui()
		else:
			request_gui("PauseMenu", [])
	elif what == NOTIFICATION_APPLICATION_PAUSED:
		close_current_gui()
		request_gui("PauseMenu", [])
		
# Called when the node enters the scene tree for the first time.
func setup(p_backpack : EMC_Inventory, p_opt_event_mngr : EMC_OptionalEventMngr) -> void:
	_trade_ui.setup(p_backpack)
	
	end_game_gui.setup(p_backpack)
	
	_city_map.setup(p_opt_event_mngr)
	
	_backpack_GUI.setup(p_backpack, "Rucksack")
	
	item_question_gui.setup(p_backpack)
	
	fridge_gui.setup(p_backpack)
	board_gui.setup(p_backpack)
	
	_cooking_GUI.setup(p_backpack)
	if(OverworldStatesMngr.has_upgrade(EMC_Upgrade.IDs.RAINWATER_BARREL)):
		_rainwater_barrel_gui.setup(p_backpack)
		
	if (OverworldStatesMngr.get_difficulty() == OverworldStatesMngr.Difficulty.EASY or OverworldStatesMngr.get_difficulty() == OverworldStatesMngr.Difficulty.TUTORIAL):
		info_center_btn.show()
	else:
		info_center_btn.hide()

func is_any_gui() -> bool:
	return not (_active_guis.is_empty() and _gui_queue.is_empty())

func close_current_gui() -> void:
	if not _active_guis.is_empty():
		(_active_guis.back() as EMC_GUI).close()
		
func close_gui(index: int) -> void:
	if not _active_guis.is_empty():
		_active_guis[index].close()

func request_gui(gui_name : String, argv : Array = []) -> Variant:
	for gui in all_the_guis:
		if gui.name == gui_name:
			
			_hide_buttons()
			_status_bars.set_process_mode(PROCESS_MODE_DISABLED)
			_stage_mngr.set_process_mode(PROCESS_MODE_DISABLED)
			_avatar.set_process_mode(PROCESS_MODE_DISABLED)
			
			if gui_name == "ChangeStageGUI":
				argv.append(_active_guis.back())
				
			canvas_modulate.show()
			
			var result : Variant = gui.callv("open", argv)
			
			if not _active_guis.is_empty():
				(_active_guis.back() as EMC_GUI).set_process_mode(PROCESS_MODE_DISABLED)
			_active_guis.append(gui)
			gui.set_process_mode(PROCESS_MODE_INHERIT)
			
			if gui_name == "ConfirmationGUI":
				return result
			
			return gui.closed
	printerr("Gui with name: '" + gui_name + "' not found")
	return Signal()

func queue_gui(gui_name : String, argv : Array) -> Signal:
	if _active_guis.is_empty():
		return request_gui(gui_name, argv)
	else:
		for gui in all_the_guis:
			if gui.name == gui_name:
				_gui_queue.append(QueueEntry.new(gui, argv))
				return gui.closed
	printerr("Gui with name: '" + gui_name + "' not found")
	return Signal()

func overlay_gui(gui_name : String, argv : Array) -> void:
	(_active_guis.back() as EMC_GUI).hide()
	request_gui(gui_name, argv)

func gui_closed(gui : EMC_GUI) -> void:
	_active_guis.erase(gui)
	if not _active_guis.is_empty():
		(_active_guis.back() as EMC_GUI).show()
		(_active_guis.back() as EMC_GUI).set_process_mode(PROCESS_MODE_INHERIT)
	elif not _gui_queue.is_empty():
		var entry : QueueEntry = _gui_queue.pop_front()
		entry.gui.callv("open", entry.argv)
		entry.gui.set_process_mode(PROCESS_MODE_INHERIT)
		_active_guis.append(entry.gui)
	else:
		canvas_modulate.hide()
		_show_buttons()
		_status_bars.set_process_mode(PROCESS_MODE_INHERIT)
		_stage_mngr.set_process_mode(PROCESS_MODE_INHERIT)
		_avatar.set_process_mode(PROCESS_MODE_INHERIT)
		
		all_guis_closed.emit()

########################Signal Handlers############################

func _on_npc_interaction(npc: EMC_NPC) -> void:
	request_gui("NpcInteraction", [npc])
	
	#_dialogue_mngr._on_dialogue_initiated(_stage_mngr.get_curr_stage_name(), npc.name)

func _on_backpack_btn_pressed() -> void:
	request_gui("BackpackGUI", [])

func _on_pause_menu_btn_pressed() -> void:
	request_gui("PauseMenu", [])
	
func _on_phone_btn_pressed() -> void:
	request_gui("Phone", [])
	#request_gui("DialogueGui", [{"stage_name": "penthouse", "actor_name": "elias"}])
	#var info: Array[Dictionary]
	#info.assign([])
	#request_gui("ItemQuestionGUI", [EMC_Item.new().setup(1)])
	#dialogue_test.gsi = emc_gsi
	#request_gui("DialogueGui", [dialogue_test])

func _on_info_center_btn_pressed() -> void:
	request_gui("InfoCenterGui", [])

########################Helper Functions############################

func _set_guis_process_mode(guis : Array[EMC_GUI], mode : int) -> void:
	for gui in guis:
		gui.set_process_mode(mode)
		gui.closed.connect(gui_closed)
		
func _hide_buttons() -> void:
	pause_menu_btn.hide()
	phone_btn.hide()
	backpack_btn.hide()
	info_center_btn.hide()
	
func _show_buttons() -> void:
	pause_menu_btn.show()
	phone_btn.show()
	backpack_btn.show()
	
	if (OverworldStatesMngr.get_difficulty() == OverworldStatesMngr.Difficulty.EASY or OverworldStatesMngr.get_difficulty() == OverworldStatesMngr.Difficulty.TUTORIAL):
		info_center_btn.show()

######################Helper Classes##############################

class QueueEntry:
	var gui : EMC_GUI
	var argv : Array
	
	func _init(p_gui : EMC_GUI, p_argv : Array) -> void:
		gui = p_gui
		argv = p_argv

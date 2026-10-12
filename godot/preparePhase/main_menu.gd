extends Control

@onready var _settings := SettingsGUI
@onready var e_coins := $CanvasLayer_unaffectedByCM/MarginContainer/HBoxContainer/eCoins
#@onready var _shop_btn := $CanvasLayer_unaffectedByCM/CenterContainer/GameButtons/Shop
#@onready var _upgrade_center_btn := $CanvasLayer_unaffectedByCM/CenterContainer/GameButtons/UpgradeCenter
@onready var avatar_selection_gui : EMC_AvatarSelectionGUI = $CanvasLayer_unaffectedByCM/AvatarSelectionGUI
@onready var canvas_modulate : CanvasModulate = $CanvasModulate
@onready var canvas_layer_unaffected_by_cm : CanvasLayer = $CanvasLayer_unaffectedByCM


func open(irrelevant : EMC_GUI = null) -> void: 
	#get_tree().paused = true
	show()
	canvas_layer_unaffected_by_cm.show()
	canvas_modulate.show()
	
	#SettingsGUI.closed.connect(open, CONNECT_ONE_SHOT)
	
	#opened.emit()
	
#MRM: Added this, because there was a bug (see commit)
func close() -> void:
	#get_tree().paused = false
	hide()
	canvas_layer_unaffected_by_cm.hide()
	canvas_modulate.hide()
	#closed.emit()


func _ready() -> void:
	e_coins.text = str(Global.get_e_coins())
	_settings.closed.connect(open)
	if !Global._tutorial_done:
		$CanvasLayer_unaffectedByCM/MarginContainer/HBoxContainer.hide()
		$CanvasLayer_unaffectedByCM/MarginContainer2.hide()
		$CanvasLayer_unaffectedByCM/InformationButtons.hide()
		#_shop_btn.hide()
		#_upgrade_center_btn.hide()


func _on_start_round_pressed() -> void:
	if !Global._tutorial_done:
		#close()
		avatar_selection_gui.open(true)
	else: 
		#Global.goto_scene(Global.CRISIS_START_SCENE)
		Global.goto_scene(Global.UPGRADE_CENTER_SCENE)


func _on_shop_pressed() -> void:
	Global.goto_scene(Global.SHOP_SCENE)


func _on_upgrade_center_pressed() -> void:
	Global.goto_scene(Global.UPGRADE_CENTER_SCENE)


func _on_settings_pressed() -> void:
	#var new_setting = settings_scene.instantiate()
	#add_child(new_setting)
	#_settings.show()
	#MRM: Had a bug (see commit)
	close()
	SettingsGUI.open()
	#Global.goto_scene("res://global/settings_GUI.tscn")
	#MRM: Don't get why this is necessary, but it won't open up reliably without this:
	#for child: Node in _settings.get_children():
		#child.show()


func _on_reset_pressed() -> void:
	Global.reset_save()


func _on_information_pressed() -> void:
	Global.goto_scene(Global.INFORMATION_SCENE)


func _on_credit_screen_pressed() -> void:
	Global.goto_scene(Global.CREDIT_SCENE)


func _on_avatar_selection_gui_closed() -> void:
	Global.load_game()
	OverworldStatesMngr.set_crisis_difficulty(3, OverworldStatesMngr.Difficulty.TUTORIAL)
	#OverworldStatesMngr._set_all_states(EMC_OverworldStatesMngr.WaterState.CLEAN, EMC_OverworldStatesMngr.IsolationState.NONE,
										#EMC_OverworldStatesMngr.FoodContaminationState.NONE, EMC_OverworldStatesMngr.ElectricityState.NONE,)
	var start_scene_name : String = Global.CRISIS_PHASE_SCENE
	Global.goto_scene(start_scene_name)
	close()

func _on_ecoins_gui_input(event : InputEvent) -> void:
	if event is InputEventScreenTouch:
		if (event as InputEventScreenTouch).pressed:
			Global.add_e_coins(250)
			e_coins.text = str(Global.get_e_coins())

func _on_scenario_pressed() -> void:
	Global.goto_scene(Global.EDU_SCENE)

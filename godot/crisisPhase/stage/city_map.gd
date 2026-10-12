extends EMC_GUI
class_name EMC_CityMap

#signal opened
#signal closed

@onready var _curr_pos_pin := $CurrPosPin
@onready var _home_pin := $HomePin
@onready var _opt_event_pin_template := $OptEventPin_Template
@onready var _opt_event_pins := $OptEventPins

@export var _crisis_phase: EMC_CrisisPhase
@export var _stage_mngr: EMC_StageMngr
@export var _day_mngr: EMC_DayMngr
@export var _gui_mngr : EMC_GUIMngr

var _opt_event_mngr: EMC_OptionalEventMngr

@onready var _tween := get_tree().create_tween().set_loops()

########################################## PUBLIC METHODS ##########################################
func setup(p_opt_event_mngr: EMC_OptionalEventMngr) -> void:
	_opt_event_mngr = p_opt_event_mngr
	$DoorbellsGUI.setup(_stage_mngr)

func open() -> void:
	_home_pin.show()
	
	#Setup Current-Location-Pin
	var curr_stage_name := _stage_mngr.get_curr_stage_name()
	match curr_stage_name:
		EMC_StageMngr.STAGENAME_HOME:
			_curr_pos_pin.position = Vector2i(300, 460)
			_home_pin.hide()
		EMC_StageMngr.STAGENAME_MARKET:
			_curr_pos_pin.position = _determine_pin_position($MarketBtn)
		EMC_StageMngr.STAGENAME_TOWNHALL:
			_curr_pos_pin.position = _determine_pin_position($TownhallBtn)
		EMC_StageMngr.STAGENAME_PARK:
			_curr_pos_pin.position = _determine_pin_position($ParkBtn)
		EMC_StageMngr.STAGENAME_GARDENHOUSE:
			_curr_pos_pin.position = _determine_pin_position($GardenhouseBtn)
		EMC_StageMngr.STAGENAME_ROWHOUSE:
			_curr_pos_pin.position = _determine_pin_position($RowhouseBtn)
		EMC_StageMngr.STAGENAME_MANSION:
			_curr_pos_pin.position = _determine_pin_position($MansionBtn)
		EMC_StageMngr.STAGENAME_PENTHOUSE:
			_curr_pos_pin.position = _determine_pin_position($PenthouseBtn)
		_: #You have to be on an extended STAGE of the apartment complex
			_curr_pos_pin.position = _determine_pin_position($ComplexBtn)
	
	#Create an event pin for every stage in for every known event
	for known_event: EMC_OptionalEventMngr.Event in _opt_event_mngr.get_known_active_events():
		var new_event_pin := _opt_event_pin_template.duplicate()
		_opt_event_pins.add_child(new_event_pin)
		new_event_pin.get_node("AnimationPlayer").play("pin_animation")
		#Try to determine the button belonging to the stage
		var button_node: TextureButton
		if known_event.stage_name.contains("apartment_"):
			button_node = $ComplexBtn
		else:
			button_node = get_node(known_event.stage_name.capitalize() + "Btn")
		
		if button_node != null:
			new_event_pin.position = _determine_pin_position(button_node)
			new_event_pin.show()
	
	#_pin_pos_tween = get_tree().create_tween()
	#_pin_pos_tween.tween_property($Pin, "position", $Pin.position - Vector2(0, 15), 0.5).set_trans(Tween.TRANS_CUBIC)
	#_pin_pos_tween.set_loops() #no arguments = infinite
	_curr_pos_pin.get_node("AnimationPlayer").play("pin_animation")
	_home_pin.get_node("AnimationPlayer").play("pin_animation")
	show()
	opened.emit()


func close() -> void:
	_curr_pos_pin.get_node("AnimationPlayer").stop()
	_home_pin.get_node("AnimationPlayer").stop()
	hide()
	$DoorbellsGUI.hide()
	#Remove all opt event pins
	for prev_duplicated_pin in _opt_event_pins.get_children():
		_opt_event_pins.remove_child(prev_duplicated_pin)
	closed.emit(self)


########################################## PRIVATE METHODS #########################################
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	
	_setup_shader()

func _on_back_btn_pressed() -> void:
	close()
	
func handle_buttons(stage_name : String) -> void:
	if stage_name != EMC_StageMngr.STAGENAME_HOME:
		if not _is_not_evening_suggest_home_return():
			return
	
	if _stage_mngr.get_curr_stage_name() == stage_name:
		close()
	else:
		match stage_name:
			EMC_StageMngr.STAGENAME_HOME:
				_day_mngr.on_interacted_with_furniture(str(EMC_Action.IDs.SC_HOME))
			EMC_StageMngr.STAGENAME_MARKET:
				_day_mngr.on_interacted_with_furniture(str(EMC_Action.IDs.SC_MARKET))
			EMC_StageMngr.STAGENAME_PENTHOUSE:
				_day_mngr.on_interacted_with_furniture(str(EMC_Action.IDs.SC_PENTHOUSE))
			EMC_StageMngr.STAGENAME_TOWNHALL:
				_day_mngr.on_interacted_with_furniture(str(EMC_Action.IDs.SC_TOWNHALL))
			EMC_StageMngr.STAGENAME_ROWHOUSE:
				_day_mngr.on_interacted_with_furniture(str(EMC_Action.IDs.SC_ROWHOUSE))
			EMC_StageMngr.STAGENAME_APARTMENT_DEFAULT:
				$DoorbellsGUI.open()
			EMC_StageMngr.STAGENAME_GARDENHOUSE:
				_day_mngr.on_interacted_with_furniture(str(EMC_Action.IDs.SC_GARDENHOUSE))
			EMC_StageMngr.STAGENAME_MANSION:
				_day_mngr.on_interacted_with_furniture(str(EMC_Action.IDs.SC_MANSION))
			EMC_StageMngr.STAGENAME_PARK:
				_day_mngr.on_interacted_with_furniture(str(EMC_Action.IDs.SC_PARK))

func _on_home_btn_pressed() -> void:
	handle_buttons(EMC_StageMngr.STAGENAME_HOME)

func _on_marketplace_btn_pressed() -> void:
	handle_buttons(EMC_StageMngr.STAGENAME_MARKET)

func _on_elias_flat_btn_pressed() -> void:
	handle_buttons(EMC_StageMngr.STAGENAME_PENTHOUSE)

func _on_townhall_btn_pressed() -> void:
	handle_buttons(EMC_StageMngr.STAGENAME_TOWNHALL)

func _on_julias_house_btn_pressed() -> void:
	handle_buttons(EMC_StageMngr.STAGENAME_ROWHOUSE)

func _on_complex_btn_pressed() -> void:
	#handle_buttons(EMC_StageMngr.STAGENAME_APARTMENT_DEFAULT)
	$DoorbellsGUI.open()

func _on_gardenhouse_btn_pressed() -> void:
	handle_buttons(EMC_StageMngr.STAGENAME_GARDENHOUSE)

func _on_villa_btn_pressed() -> void:
	handle_buttons(EMC_StageMngr.STAGENAME_MANSION)

func _on_park_btn_pressed() -> void:
	handle_buttons(EMC_StageMngr.STAGENAME_PARK)


## Helper method to deduce the position of the pin on the basis of the Button
func _determine_pin_position(p_texture_button: TextureButton) -> Vector2:
	return p_texture_button.position + \
		Vector2(p_texture_button.texture_normal.get_width()/2,
				p_texture_button.texture_normal.get_height()/2 - 50)


## If you're home, it's ok to go somewhere because the time will only be progressed if you go
## back. If you're somewhere else and it's evening you have to go home
func _is_not_evening_suggest_home_return() -> bool:
	if _stage_mngr.get_curr_stage_name() == _stage_mngr.STAGENAME_HOME || \
	_day_mngr.get_current_day_period() != EMC_DayMngr.DayPeriod.EVENING:
		return true
	else:
		_gui_mngr.request_gui("TooltipGUI", ["Es ist schon spät, ich sollte nach Hause gehen."])
		return false

## Setup Shader stuff (see https://godotshaders.com/shader/2d-controlled-shine-highlight-with-angle-adjustment/)
## Can be used freely under CC0 license (see https://creativecommons.org/publicdomain/zero/1.0/)
func _setup_shader() -> void:
	const SHINE_TIME: float = 2.0
	
	_tween.tween_property($ClickableBuildings.material, "shader_parameter/shine_progress", 1.0,
		SHINE_TIME).from(0.0).set_delay(4.0)
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) #Play even though the scene is paused
	_tween.play()
	
func _on_back_button_pressed() -> void:
	close()

extends EMC_GUI
class_name EMC_DefaultActionGUI

@export var icon: Texture2D
@export var _day_mngr: EMC_DayMngr

@onready var confirm_btn : Button = $VBoxContainer/HBoxContainer/ConfirmBtn
@onready var back_btn : Button = $VBoxContainer/HBoxContainer/BackBtn
@onready var description : RichTextLabel = $VBoxContainer/PanelContainer/RichTextLabel

var action: EMC_Action
var sound: EMC_Action
var time: bool = false
var descr: String = ""


########################################## PUBLIC METHODS ##########################################

func open(text: String, p_action_id: String, p_sound_id: String, p_time: bool = false, p_descr: String = "") -> void:
	description.text = text
	
	action = JsonMngr.get_action(p_action_id)
	sound = JsonMngr.get_action(p_sound_id)
	time = p_time
	descr = p_descr
	
	if time:
		confirm_btn.set_button_icon(icon)
	else:
		confirm_btn.set_button_icon(null)
	show()
	opened.emit()

func close() -> void:
	hide()
	closed.emit(self)

########################################## PRIVATE METHODS #########################################
func _ready() -> void:
	hide()

func _on_confirm_btn_pressed() -> void:
	await SoundMngr.button_finished()
	var wait : AudioStreamPlayer = sound.execute()["current"]
	
	action.execute()
	if time:
		_day_mngr._advance_day_period(descr)
	close()

func _on_back_btn_pressed() -> void:
	close()

extends EMC_GUI
class_name EMC_PopUpGUI

@onready var desciption: Label = $PanelContainer/MarginContainer/VBoxContainer/TextBox/Desciption

@export var _day_mngr: EMC_DayMngr

var _action: EMC_Action
var _sound: EMC_Action

var _time: bool = false
var _descr: String

func open(text: String, action_id: String, sound_id: String, p_time: bool = false, p_descr: String = "") -> void:
	show()
	SoundMngr.vibrate(250, 2)
	opened.emit()
	desciption.set_text(text)

	_action = JsonMngr.get_action(action_id)
	_sound = JsonMngr.get_action(sound_id)

	_time = p_time
	_descr = p_descr

func close() -> void:
	hide()
	closed.emit(self)


func _on_confirm_pressed() -> void:
	await SoundMngr.button_finished()
	var wait : AudioStreamPlayer = _sound.execute()["current"]
	
	_action.execute()
	if _time:
		_day_mngr._advance_day_period(_descr)
	close()

func _on_cancel_pressed() -> void:
	close()

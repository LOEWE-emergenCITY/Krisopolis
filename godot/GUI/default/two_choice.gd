extends EMC_GUI
class_name EMC_TwoChoice

@export var option_1_dict: Dictionary
@export var option_2_dict: Dictionary
@export var icon: Texture2D
@export var _day_mngr: EMC_DayMngr

@onready var text : RichTextLabel = $VBoxContainer/PanelContainer/Text
@onready var option_1: Button = $VBoxContainer/HBoxContainer/Option1
@onready var option_2: Button = $VBoxContainer/HBoxContainer/Option2

########################################## PUBLIC METHODS ##########################################

func open(p_text: String, p_option_1: Dictionary, p_option_2: Dictionary) -> void:
	if not p_option_1.has_all(["text", "time", "action", "sound"]) and p_option_2.has_all(["text", "time", "action", "sound"]):
		printerr("TwoChoice: missing key in dict!")
	
	option_1_dict = p_option_1
	option_2_dict = p_option_2
	
	text.set_text(p_text)
	option_1.set_text(p_option_1["text"])
	option_2.set_text(p_option_2["text"])
	
	if p_option_1["time"]:
		option_1.set_button_icon(icon)
	else:
		option_1.set_button_icon(null)
		
	if p_option_2["time"]:
		option_2.set_button_icon(icon)
	else:
		option_2.set_button_icon(null)
	
	show()
	opened.emit()

func close() -> void:
	hide()
	closed.emit(self)

########################################## PRIVATE METHODS #########################################
func _ready() -> void:
	hide()

func _on_option_1_pressed() -> void:
	await SoundMngr.button_finished()
	JsonMngr.get_action(option_1_dict["sound"]).execute()
	JsonMngr.get_action(option_1_dict["action"]).execute()
	if option_1_dict["time"]:
		_day_mngr._advance_day_period(option_1_dict["descr"])
	close()

func _on_option_2_pressed() -> void:
	await SoundMngr.button_finished()
	JsonMngr.get_action(option_2_dict["sound"]).execute()
	JsonMngr.get_action(option_2_dict["action"]).execute()
	if option_2_dict["time"]:
		_day_mngr._advance_day_period(option_2_dict["descr"])
	close()

func _on_back_btn_pressed() -> void:
	close()

extends EMC_GUI
class_name EMC_AvatarSelectionGUI

const SPRITE_W01 = "W01"
const SPRITE_W02 = "W02"
const SPRITE_W03 = "W03"
const SPRITE_W04 = "W04"
const SPRITE_W05 = "W05"
const SPRITE_W06 = "W06"
const SPRITE_NB01 = "NB01"
const SPRITE_NB02 = "NB02"
const SPRITE_NB03 = "NB03"
const SPRITE_NB04 = "NB04"
const SPRITE_NB05 = "NB05"
const SPRITE_NB06 = "NB06"
const SPRITE_M01 = "M01"
const SPRITE_M02 = "M02"
const SPRITE_M03 = "M03"
const SPRITE_M04 = "M04"
const SPRITE_M05 = "M05"
const SPRITE_M06 = "M06"

@onready var _settingGUI: EMC_SettingsGUI = SettingsGUI
@onready var _chosen_avatar_frame := $VBoxContainer/CenterContainer/ScrollContainer/ChosenAvatarFrame

var _chosen_avatar_button: TextureButton

func open(p_show_continue_button: bool = false) -> void:
	$Continue.visible = p_show_continue_button
	_position_chosen_avatar_frame()
	show()
	opened.emit()

func close() -> void:
	hide()
	closed.emit()

func _ready() -> void:
	hide()

func _on_back_btn_pressed() -> void:
	close()

## Repositions frame around selected avatar skin
func _position_chosen_avatar_frame() -> void:
	match _settingGUI.get_avatar_sprite_suffix():
		SPRITE_W01:
			_chosen_avatar_button = $VBoxContainer/CenterContainer/ScrollContainer/GridContainer/W01
		SPRITE_W02:
			_chosen_avatar_button = $VBoxContainer/CenterContainer/ScrollContainer/GridContainer/W02
		SPRITE_W03:
			_chosen_avatar_button = $VBoxContainer/CenterContainer/ScrollContainer/GridContainer/W03
		SPRITE_W04:
			_chosen_avatar_button = $VBoxContainer/CenterContainer/ScrollContainer/GridContainer/W04
		SPRITE_W05:
			_chosen_avatar_button = $VBoxContainer/CenterContainer/ScrollContainer/GridContainer/W05
		SPRITE_W06:
			_chosen_avatar_button = $VBoxContainer/CenterContainer/ScrollContainer/GridContainer/W06
		SPRITE_NB01:
			_chosen_avatar_button = $VBoxContainer/CenterContainer/ScrollContainer/GridContainer/NB01
		SPRITE_NB02:
			_chosen_avatar_button = $VBoxContainer/CenterContainer/ScrollContainer/GridContainer/NB02
		SPRITE_NB03:
			_chosen_avatar_button = $VBoxContainer/CenterContainer/ScrollContainer/GridContainer/NB03
		SPRITE_NB04:
			_chosen_avatar_button = $VBoxContainer/CenterContainer/ScrollContainer/GridContainer/NB04
		SPRITE_NB05:
			_chosen_avatar_button = $VBoxContainer/CenterContainer/ScrollContainer/GridContainer/NB05
		SPRITE_NB06:
			_chosen_avatar_button = $VBoxContainer/CenterContainer/ScrollContainer/GridContainer/NB06
		SPRITE_M01:
			_chosen_avatar_button = $VBoxContainer/CenterContainer/ScrollContainer/GridContainer/M01
		SPRITE_M02:
			_chosen_avatar_button = $VBoxContainer/CenterContainer/ScrollContainer/GridContainer/M02
		SPRITE_M03:
			_chosen_avatar_button = $VBoxContainer/CenterContainer/ScrollContainer/GridContainer/M03
		SPRITE_M04:
			_chosen_avatar_button = $VBoxContainer/CenterContainer/ScrollContainer/GridContainer/M04
		SPRITE_M05:
			_chosen_avatar_button = $VBoxContainer/CenterContainer/ScrollContainer/GridContainer/M05
		SPRITE_M06:
			_chosen_avatar_button = $VBoxContainer/CenterContainer/ScrollContainer/GridContainer/M06
		_:
			printerr("Unknown chosen Avatar Button!")
			_chosen_avatar_frame.hide()
			return
	
	_chosen_avatar_button.grab_focus()

func _on_w_01_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_W01)

func _on_nb_01_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_NB01)

func _on_m_01_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_M01)

func _on_w_02_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_W02)

func _on_nb_02_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_NB02)

func _on_m_02_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_M02)

func _on_w_03_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_W03)

func _on_nb_03_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_NB03)

func _on_m_03_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_M03)

func _on_w_04_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_W04)

func _on_nb_04_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_NB04)

func _on_m_04_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_M04)

func _on_w_05_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_W05)

func _on_nb_05_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_NB05)

func _on_m_05_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_M05)

func _on_w_06_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_W06)

func _on_nb_06_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_NB06)

func _on_m_06_pressed() -> void:
	_settingGUI.set_avatar_sprite_suffix(SPRITE_M06)

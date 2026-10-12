extends EMC_GUI
class_name EMC_SettingsGUI

signal avatar_sprite_changed(p_avatar_sprite_suffix: String)

@onready var font_change : CheckButton = $CanvasLayer/VBoxContainer/CenterContainer2/Buttons/FontChange
@onready var canvas_layer : CanvasLayer = $CanvasLayer
@onready var canvas_modulate : CanvasModulate = $CanvasModulate
@onready var sounds : VBoxContainer = $CanvasLayer/VBoxContainer/CenterContainer2/Sounds
@onready var buttons : VBoxContainer = $CanvasLayer/VBoxContainer/CenterContainer2/Buttons
@onready var music : EMC_VolumeSlider = $CanvasLayer/VBoxContainer/CenterContainer2/Sounds/Music
@onready var sfx : EMC_VolumeSlider = $CanvasLayer/VBoxContainer/CenterContainer2/Sounds/SFX
@onready var reset : Button = $CanvasLayer/VBoxContainer/CenterContainer2/Buttons/Reset
@onready var _confirmGUI: EMC_ConfirmationGUI = $CanvasLayer/ConfirmationGUI
@onready var tooltip_gui : EMC_TooltipGUI = $CanvasLayer/TooltipGUI

@onready var vibrate_button : CheckButton = $CanvasLayer/VBoxContainer/CenterContainer2/Sounds/Vibrate
@onready var avatar_selection_gui : EMC_AvatarSelectionGUI = $CanvasLayer/AvatarSelectionGUI

const dyslexic_font := preload("res://assets/fonts/OpenDyslexic/OpenDyslexic-Regular.tres")
const dyslexic_i_font := preload("res://assets/fonts/OpenDyslexic/OpenDyslexic-Italic.tres")
const dyslexic_b_font := preload("res://assets/fonts/OpenDyslexic/OpenDyslexic-Bold.tres")
const dyslexic_bi_font := preload("res://assets/fonts/OpenDyslexic/OpenDyslexic-Bold-Italic.tres")
const normal_font := preload("res://assets/fonts/CMU Typewriter/cmuntt.ttf")
const normal_i_font := preload("res://assets/fonts/CMU Typewriter/cmunit.ttf")
const normal_b_font := preload("res://assets/fonts/CMU Typewriter/cmuntb.ttf")
const normal_bi_font := preload("res://assets/fonts/CMU Typewriter/cmuntx.ttf")


var _previous_pause_mode: bool
var _avatar_sprite_suffix: String = EMC_AvatarSelectionGUI.SPRITE_NB03
signal debug_mode
	
#------------------------------------------ PUBLIC METHODS -----------------------------------------

func open(p_during_crisis: bool = false) -> void:
	_previous_pause_mode = get_tree().paused
	get_tree().paused = true
	avatar_selection_gui.hide()
	canvas_layer.show()
	canvas_modulate.show()
	$CanvasLayer/VBoxContainer/CenterContainer2/Buttons/Reset.visible = !p_during_crisis
	show()
	opened.emit()


func close(without_signal : bool = false) -> void:
	get_tree().paused = _previous_pause_mode
	hide()
	canvas_layer.hide()
	canvas_modulate.hide()
	if not without_signal:
		closed.emit(self)

func set_avatar_sprite_suffix(p_avatar_sprite_suffix: String) -> void:
	_avatar_sprite_suffix = p_avatar_sprite_suffix
	avatar_sprite_changed.emit(_avatar_sprite_suffix)

func get_avatar_sprite_suffix() -> String:
	return _avatar_sprite_suffix

########################################## PRIVATE METHODS #########################################

func _ready() -> void:
	await Global.game_loaded
	change_default_font()
	font_change.set_pressed_no_signal(Global._is_dyslexic)
	vibrate_button.set_pressed_no_signal(Global.is_vibration_enabled())
	close()

func change_default_font() -> void:
	if (Global._is_dyslexic):
		theme.set_default_font(dyslexic_font)
		theme.set_font("normal_font", "RichTextLabel", dyslexic_font)
		theme.set_font("italics_font", "RichTextLabel", dyslexic_font)
		theme.set_font("bold_font", "RichTextLabel", dyslexic_font)
		theme.set_font("bols_italics_font", "RichTextLabel", dyslexic_font)
	else:
		theme.set_default_font(normal_font)
		theme.set_font("normal_font", "RichTextLabel", normal_font)
		theme.set_font("italics_font", "RichTextLabel", normal_i_font)
		theme.set_font("bold_font", "RichTextLabel", normal_b_font)
		theme.set_font("bols_italics_font", "RichTextLabel", normal_bi_font)
		

func _on_font_change_pressed() -> void:
	Global._is_dyslexic = !Global._is_dyslexic

	change_default_font()


func _on_reset_pressed() -> void:
	var confirmed := await _confirmGUI.open("Fortschritt & Einstellungen komplett zurücksetzen?")
	if !confirmed: return
	
	self.close(true)
	OverworldStatesMngr.reset()
	#Global.reset_state()
	#Global.reset_save()
	Global.reset_meta()
	Global.save_game(Global.State.START)
	Global.load_game()
	get_tree().paused = false
	Global.goto_scene(Global.MAIN_MENU_SCENE)


func _on_continue_pressed() -> void:
	close()


func _on_sound_pressed() -> void:
	buttons.hide()
	sounds.show()


func _on_back_pressed() -> void:
	buttons.show()
	sounds.hide()


func _on_select_avatar_pressed() -> void:
	#MRM: Can't call close() because the closed-Signal triggers the opening of the 
	#normal pause menue. Not a beautiful solution, but works for now, sorry:
	hide()
	avatar_selection_gui.open()


func _on_avatar_selection_gui_closed() -> void:
	if canvas_layer == null: return
	show()
	canvas_layer.show()


func _on_vibrate_pressed() -> void:
	Global.set_vibration_enabled(vibrate_button.button_pressed)


func _on_info_pressed() -> void:
	tooltip_gui.open("Godot version 4.5.1\nGame Version 1.1.0")

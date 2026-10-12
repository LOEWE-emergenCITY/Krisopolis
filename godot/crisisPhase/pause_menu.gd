extends EMC_GUI

@onready var save_and_quit: Button = $VBC/CenterContainer2/Buttons/SaveAndQuit
@onready var save: Button = $VBC/CenterContainer2/Buttons/Save

########################################## PUBLIC METHODS #########################################
func open(_irrelevant : EMC_GUI = null) -> void:
	if OS.has_feature("ios") or OS.has_feature("android"):
		save_and_quit.hide()
		save.show()
	else:
		save_and_quit.show()
		save.hide()

	show()
	opened.emit()


func close() -> void:
	hide()
	closed.emit(self)

########################################## PRIVATE METHODS #########################################
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	#SettingsGUI.close(true)
	#SettingsGUI.closed.connect(open)

func _exit_tree() -> void:
	if closed.is_connected(open):
		SettingsGUI.closed.disconnect(open)

func _on_resume_btn_pressed() -> void:
	close()


func _on_settings_pressed() -> void:
	hide()
	SettingsGUI.open(true)
	SettingsGUI.closed.connect(open, CONNECT_ONE_SHOT)

## TODO
func _on_cancel_curr_crisis_pressed() -> void:
	#Global.reset_state()
	#Global.reset_inventory()
	#Global.reset_upgrades_equipped()
	#Global.get_tree().paused = false
	Global.save_ani_canvas.show()
	Global.save_game(Global.State.START)
	await SoundMngr.play_slow_musik(0.5)
	Global.load_game()
	Global.save_ani_canvas.hide()
	Global.goto_scene(Global.MAIN_MENU_SCENE)


## TODO
func _on_save_and_quit_pressed() -> void:
	Global.save_ani_canvas.show()
	Global.save_game(Global.State.CRISIS)
	await SoundMngr.close_game()
	Global.get_tree().quit()


func _on_save_pressed() -> void:
	Global.save_ani_canvas.show()
	Global.save_game(Global.State.CRISIS)
	await get_tree().create_timer(0.3).timeout
	Global.save_ani_canvas.hide()
	#SoundMngr.play_sound("stinger")

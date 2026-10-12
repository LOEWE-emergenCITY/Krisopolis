extends Control


func _on_continue_pressed() -> void:
	Global.goto_scene(Global.CRISIS_PHASE_SCENE)

func _on_cancel_pressed() -> void:
	Global.save_game(Global.State.START)
	Global.save_ani_canvas.show()
	Global.load_game()
	await SoundMngr.play_slow_musik(0.5)
	Global.save_ani_canvas.hide()
	Global.goto_scene(Global.MAIN_MENU_SCENE)

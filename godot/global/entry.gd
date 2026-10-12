extends Node

@onready var into_video: VideoStreamPlayer = $IntoVideo
@onready var button: Button = $Button
@onready var boot_video: VideoStreamPlayer = $BootVideo
@onready var skip: RichTextLabel = $Margin/skip
@onready var data_gui: PanelContainer = $DataGui

var start_scene_name: String

var button_pressed_count: int = 0

func _ready() -> void:
	OS.request_permissions()
	
	Global.set_started_from_entry_scene()
	JsonMngr.load_items()
	JsonMngr.load_upgardes()
	JsonMngr.load_opt_events()
	JsonMngr.load_actions()
	JsonMngr.load_scenarios()
	JsonMngr.load_crisis()
	JsonMngr.load_dialogues()
	Global.load_game()
	start_scene_name = Global.load_scene_name()

	if not Global._data:
		data_gui.show()
	else:
		boot_video.play()

func _on_into_finished() -> void:
	SoundMngr.musik.play(into_video.get_stream_position())
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(into_video, "volume", 0, 1)#.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(into_video, "modulate", Color(1, 1, 1, 0), 1)
	tween.tween_callback(into_video.stop)
	await tween.finished
	
	Global.goto_scene(start_scene_name)

func _on_button_pressed() -> void:
	button_pressed_count += 1
	
	match button_pressed_count:
		1:
			boot_video.stop()
			boot_video.hide()
			into_video.play()
		2:
			skip.show()
		3:
			_on_into_finished()

func _on_confirmation_btn_pressed() -> void:
	data_gui.hide()
	boot_video.play()
	Global._data = true

func _on_cancel_pressed() -> void:
	if OS.has_feature("ios") or OS.has_feature("android"):
		return
	else:
		Global.get_tree().quit()


func _on_boot_finished() -> void:
	boot_video.stop()
	boot_video.hide()
	into_video.play()

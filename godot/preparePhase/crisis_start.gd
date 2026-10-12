extends Control
class_name EMC_CrisisStart

var _crisis_length : int
var _difficulty : EMC_OverworldStatesMngr.Difficulty
#Until beginning of length-day (so minus 1 quasi)
const LENGTH_LOWER_BOUND_EASY : int = 4
const LENGTH_UPPER_BOUND_EASY : int = 6
const LENGTH_LOWER_BOUND_NORMAL : int = 7
const LENGTH_UPPER_BOUND_NORMAL : int = 9
const LENGTH_LOWER_BOUND_HARD : int = 10
const LENGTH_UPPER_BOUND_HARD : int = 13

@export var crisis_button_group: ButtonGroup

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()


func _on_continue_pressed() -> void:
	var pressed_button := crisis_button_group.get_pressed_button()
	Global._game_state = Global.State.SCENARIO
	OverworldStatesMngr.set_crisis_difficulty(4)
	Global.session["changes"] = []
	match pressed_button.name:
		"Easy": 
			_crisis_length = _rng.randi_range(LENGTH_LOWER_BOUND_EASY, LENGTH_UPPER_BOUND_EASY)
			_difficulty = OverworldStatesMngr.Difficulty.EASY
		"Normal":
			_crisis_length = _rng.randi_range(LENGTH_LOWER_BOUND_NORMAL, LENGTH_UPPER_BOUND_NORMAL)
			_difficulty = OverworldStatesMngr.Difficulty.MEDIUM
		"Hard":
			_crisis_length = _rng.randi_range(LENGTH_LOWER_BOUND_HARD, LENGTH_UPPER_BOUND_HARD)
			_difficulty = OverworldStatesMngr.Difficulty.HARD
	
	if Global._tutorial_done: 
		OverworldStatesMngr.set_crisis_difficulty(_crisis_length, _difficulty)
	else:
		OverworldStatesMngr.set_crisis_difficulty(3, OverworldStatesMngr.Difficulty.TUTORIAL)
		
	Global.goto_scene(Global.CRISIS_PHASE_SCENE)

func _notification(what : int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_back_btn_pressed()

func _on_back_btn_pressed() -> void:
	#Global.goto_scene("res://preparePhase/main_menu.tscn")
		Global.goto_scene(Global.SHOP_SCENE)

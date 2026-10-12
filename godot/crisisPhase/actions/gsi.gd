extends VRV_GSI
class_name EMC_GSI

@export var _gui_mngr: EMC_GUIMngr
@export var _stage_mngr: EMC_StageMngr
@export var _day_mngr: EMC_DayMngr
@export var _score: EMC_Scoreboard
@export var _npc_mngr: EMC_NPC_Mngr
@export var _vervain_runtime: EMC_VervainExecuter
@export var _crisis_phase: EMC_CrisisPhase
@export var _avatar: EMC_Avatar

func request_trade_gui(npc_name: String) -> bool:
	var npc: EMC_NPC = _npc_mngr.get_NPC(npc_name)
	_gui_mngr.request_gui("Trade", [npc])
	return true
	
func get_avatar_portrait() -> Texture2D:
	return load("res://assets/characters/portrait_avatar_" + SettingsGUI.get_avatar_sprite_suffix() + ".png")
	
func get_npc_portrait(npc_name: String) -> Texture2D:
	return _npc_mngr.get_NPC(npc_name).npc_resource.get_comp(EMC_NPC_Descr).get_portrait()

func get_pitch(char_name: String) -> float:
	if char_name == "avatar":
		return EMC_Avatar.PITCH
	if char_name.to_lower() == "erzähler":
		return 1.0
	return _npc_mngr.get_NPC(char_name).npc_resource.get_comp(EMC_NPC_Conversation).get_pitch()

func get_period_count() -> int:
	return _day_mngr.get_period_count()

func set_tutorial(value: bool) -> bool:
	Global._tutorial_done = value
	return value
	
func request_gui(gui_name: String, args: Array) -> bool:
	_gui_mngr.request_gui(gui_name, args)
	return true

func add_score(log_name: String, context: Dictionary) -> bool:
	_score.add_score(log_name, context)
	return true

func get_talk_from_range(_max: int, last_talk: String, last_day: int) -> String:
	if last_talk != "talk-1":
		if last_day == _day_mngr.get_period_count():
			return last_talk
	
	return "talk" + str(randi_range(1, _max))
	
func run_script(script: VRV_Script) -> bool:
	_vervain_runtime.run(script)
	return true
	
func progress_day(message: String) -> bool:
	_day_mngr._advance_day_period(message)
	return true
	
# message for item_question
func gain_player_item(item_name: String, message: String) -> bool:
	var id: int = JsonMngr.item_name_to_id(item_name)
	var item : = EMC_Item.make_from_id(id)
	if _crisis_phase._backpack.add_item(item) == false:
		_gui_mngr.request_gui("TooltipGUI", ["Dein Inventar ist bereits voll und kann keine weiteren Items aufnehmen!"])
	else:
		_gui_mngr.queue_gui("ItemQuestionGUI", [item, {"question": message, "answere": ""}])
	
	return true

func arrive(npc_name: String) -> bool:
	return true

func leave(npc_name: String) -> bool:
	return true

func is_current_stage(stage_name: String) -> bool:
	return _stage_mngr.get_curr_stage_name() == stage_name.to_pascal_case()

func add_points_calories() -> bool:
	_avatar.modify_food_delta(1)
	return true
	
func add_points_water() -> bool:
	_avatar.modify_drink_delta(1)
	return true

func add_points_social(value: int = 1) -> bool:
	_avatar.modify_social_delta(value)
	return true

func npc_karma_higher_than(npc_name: String, value: float) -> bool:
	var karma: EMC_NPC_Karma = _npc_mngr.get_NPC(npc_name).npc_resource.get_comp(EMC_NPC_Karma)
	return karma.get_krama() > value

func npc_karma_less_than(npc_name: String, value: float) -> bool:
	var karma: EMC_NPC_Karma = _npc_mngr.get_NPC(npc_name).npc_resource.get_comp(EMC_NPC_Karma)
	return karma.get_krama() < value

func npc_friendship_higher_than(npc_name: String, value: int) -> bool:
	return true

func npc_is_happy(npc_name: String) -> bool:
	var karma: EMC_NPC_Karma = _npc_mngr.get_NPC(npc_name).npc_resource.get_comp(EMC_NPC_Karma)
	return karma.get_mood() > EMC_NPC_Karma.Mood.MID

func npc_is_sad(npc_name: String) -> bool:
	var karma: EMC_NPC_Karma = _npc_mngr.get_NPC(npc_name).npc_resource.get_comp(EMC_NPC_Karma)
	return karma.get_mood() < EMC_NPC_Karma.Mood.MID

func is_state_by_name_str(state_name_value: String) -> bool:
	return OverworldStatesMngr.is_effective_state_eq(state_name_value.get_basename(), state_name_value.get_extension())

# _t is the relative time step _t = 0 means right now, _t = 1 means next time period
func is_state_eq(state: String, value: String, _t: int = 0) -> bool:
	return OverworldStatesMngr.is_effective_state_eq(state, value, _t)

func is_state_neq(state: String, value: String, _t: int = 0) -> bool:
	return OverworldStatesMngr.is_effective_state_neq(state, value, _t)
	
func is_state_lt(state: String, value: String, _t: int = 0) -> bool:
	return OverworldStatesMngr.is_effective_state_lt(state, value, _t)
	
func is_state_gt(state: String, value: String, _t: int = 0) -> bool:
	return OverworldStatesMngr.is_effective_state_gt(state, value, _t)

func has_flag(state: String, flag: String, _t: int = 0) -> bool:
	return OverworldStatesMngr.has_flag(state, flag, _t)

func has_not_flag(state: String, flag: String, _t: int = 0) -> bool:
	return OverworldStatesMngr.has_not_flag(state, flag, _t)
	
func has_any_flag(p_state: String, p_flags: Array[String], _t: int = 0) -> bool:
	return OverworldStatesMngr.has_any_flag(p_state, p_flags, _t)
	
func has_all_flag(state: String, p_flags: Array[String], _t: int = 0) -> bool:
	return OverworldStatesMngr.has_all_flag(state, p_flags, _t)

func crisis_is(crisis_name: String) -> bool:
	return crisis_name in OverworldStatesMngr.get_scenario_names()

func time_is_midday() -> bool:
	return _day_mngr.get_current_day_period() == EMC_DayMngr.DayPeriod.MORNING

func time_is_morning() -> bool:
	return _day_mngr.get_current_day_period() == EMC_DayMngr.DayPeriod.NOON

func time_is_evening() -> bool:
	return _day_mngr.get_current_day_period() == EMC_DayMngr.DayPeriod.EVENING
	
func randomize(lower: int, higher: int) -> int:
	return randi_range(lower, higher)

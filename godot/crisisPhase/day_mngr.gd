extends Control
class_name EMC_DayMngr
## [EMC_DayMngr] manages all [EMC_Action]'s. 
## The [EMC_Action]'s a triggered via [method EMC_DayMngr.on_interacted_with_furniture].
## EMC_DayMngr checks [EMC_Action]'s [member EMC_Action.constraints_prior] before calling the apropriated
## [EMC_GUI] stroed in [member EMC_Action.type_ui].

signal period_increased(new_value : int)
signal animation_end

## Enum describing the periods of a Day.
enum DayPeriod {
	## Morning periode
	MORNING = 0,
	## Noon periode
	NOON = 1,
	## Evening periode 
	EVENING = 2
}

var _period_cnt : int = 0 #Keeps track of the current period (counted/summed up over all days)

const TIME_PRE_DAY: float = 96 
const ACTION_PER_DAY: int = 6

var _time: int = 0
var _day: int = 0

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

#References to other scenes:
@export var _gui_mngr : EMC_GUIMngr
@export var _avatar : EMC_Avatar
@export var _stage_mngr : EMC_StageMngr
var _crisis_mngr : EMC_CrisisMngr = EMC_CrisisMngr.new()
var _inventory : EMC_Inventory
@export var _action_constraints: EMC_ActionConstraints
@export var _action_consequences: EMC_ActionConsequences
var _opt_event_mngr: EMC_OptionalEventMngr
@export var _scoreboard: EMC_Scoreboard

########################################## PUBLIC METHODS ##########################################
func setup(
p_inventory: EMC_Inventory,
p_opt_event_mngr: EMC_OptionalEventMngr) -> void:
	_inventory = p_inventory

	_crisis_mngr.setup(_inventory, _gui_mngr)
	
	_opt_event_mngr = p_opt_event_mngr
	
	_opt_event_mngr.set_constraints(_action_constraints)
	_opt_event_mngr.set_consequences(_action_consequences)
	
	_rng.randomize()
	_update_HUD()
	
	# Called before once game starts
	_crisis_mngr.check_crisis_status(0)
	#_stage_mngr.let_npcs_act()
	_stage_mngr.reload_state()

func on_interacted_with_furniture(p_action_ID : String) -> void:
	JsonMngr.get_action(p_action_ID).execute({"result": {}})

func get_current_day_period() -> DayPeriod:
	return clamp(floor(self._time / (TIME_PRE_DAY / DayPeriod.size())), 0, 2) as DayPeriod
	#return self._period_cnt % DayPeriod.size() as DayPeriod

func get_current_day() -> int:
	#+1 because: Day 1 = period 0, 1, 2, Day 2 = period 3, 4, 5, ....
	return self._day + 1
	#return floor(self._period_cnt / float(3.0)) + 1

func get_period_count() -> int:
	return floori(self._time / 32) + self._day * 3
	#return self._period_cnt

func get_action_constraints() -> EMC_ActionConstraints:
	return _action_constraints

func get_action_consequences() -> EMC_ActionConsequences:
	return _action_consequences

########################################## PRIVATE METHODS #########################################

func _advance_time(delta: float) -> void:
	var tmp := get_current_day_period()
	self._time += int(delta)
	
	# per day update
	if self._time >= TIME_PRE_DAY:
		
		self._day += 1
		self._time = 0
		_update_HUD()
	
	# per time step update
	_avatar.advance_time(delta)
	if tmp == get_current_day_period():
		_gui_mngr.queue_gui("ActionAnimation", [animation_end])
	# per period update
	else:
		var closed : Signal = _gui_mngr.queue_gui("DayPeriodTransition", [get_current_day(), get_current_day_period(), false, _callback])
		
		#if get_current_day_period() == DayPeriod.MORNING:
			#await _gui_mngr.request_gui("SummaryEndOfDayGUI", [])
			#await _gui_mngr.request_gui("BackpackGUI", [true])
			#
			#if not closed.is_null():
				#await closed
		_update_HUD()
		
		_opt_event_mngr.check_for_new_event(get_current_day_period())
		_crisis_mngr.check_crisis_status(get_period_count())
		OverworldStatesMngr.next_day(get_period_count())
		
		# To time stage change with animation
		period_increased.emit(get_period_count())
		await Global.get_tree().create_timer(0.3).timeout
		animation_end.emit()


func _callback() -> void:
	if get_current_day_period() == DayPeriod.MORNING:
		await _gui_mngr.request_gui("SummaryEndOfDayGUI")
		await _gui_mngr.request_gui("BackpackGUI", [true])

## !!! Important function !!!
func _advance_day_period(description : String) -> void:
	_advance_time(TIME_PRE_DAY/ACTION_PER_DAY)

	#if _gui_mngr.is_any_gui():
		#await _gui_mngr.all_guis_closed
	#
	##Actually advance the time
	#self._period_cnt += 1
	#OverworldStatesMngr.next_day(_period_cnt)
	#
	### NOTICE: see callback: It opens SummaryEndOfDay and Backpack
	#var closed : Signal = _gui_mngr.queue_gui("DayPeriodTransition", [get_current_day(), get_current_day_period(), false, _callback])
	#_update_HUD()
	#
	#
	#await Global.get_tree().create_timer(0.3).timeout
	## let npcs act
	#_stage_mngr.let_npcs_act()
	#_stage_mngr.reload_stage()
	#period_increased.emit(_period_cnt)
	#
	#if get_current_day_period() == DayPeriod.MORNING:
		##if _stage_mngr.get_curr_stage_name() != EMC_StageMngr.STAGENAME_HOME:
			##_stage_mngr.change_stage(EMC_StageMngr.STAGENAME_HOME, {}, false)
			###_stage_mngr.deactivate_NPCs()
			##_avatar.set_global_position(Vector2i(250, 650))
			#
		#_inventory._on_day_mngr_day_ended(get_current_day())
	#
	#if not closed.is_null():
		#await closed
	#
	##Game over?
	#if _check_and_display_game_over(): return
	#
	##Events & Crises stuff
	#_opt_event_mngr.check_for_new_event(get_current_day_period())
	#
	## if OverworldStatesMngr.get_food_contamination_state() == OverworldStatesMngr.FoodContaminationState.FOOD_SPOILED:
	## 	_inventory.spoil_some_items()
	#
	#_crisis_mngr.check_crisis_status(get_period_count())


## Update the visual representation of the current daytime
func _update_HUD() -> void:
	$HBoxContainer/RichTextLabel.text = "Tag" + " " + str(get_current_day())
	$HBoxContainer/Container/DayPeriodIcon.frame = get_current_day_period()


func save() -> Dictionary:
	var data : Dictionary = {
		"node_path": get_path(),
		#"period_cnt": _period_cnt,
		"time": _time,
		"day": _day
	}
	return data

func load_state(data : Dictionary) -> void:
	#_period_cnt = data.get("period_cnt", 0)
	_time = data.get("time", 0)
	_day = data.get("day", 0)
	_update_HUD()

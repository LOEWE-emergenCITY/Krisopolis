extends Node
class_name EMC_OptionalEventMngr

signal rained

## Tuple class, you're welcome to access its public (!) members directly
class SpawnNPCs:
	var NPC_name: String
	var pos: Vector2


## Tuple class, you're welcome to access its public (!) members directly
class SpawnTiles:
	var tilemap_pos: Vector2i
	var atlas_coord: Vector2i
	var tiles_cols: int
	var tiles_rows: int
	var overwrite_existing_tiles: bool = true


## Tuple class, you're welcome to access its public (!) members directly
class Event:
	var name: String
	var probability: int #Weighted numbers, should be used between 1 and 10
	var descr: String
	var announce_only_on_radio: bool
	var active_periods: int
	var constraints: Dictionary
	var consequences: Dictionary
	var consequences_executed: bool = false
	var stage_name: String
	var spawn_NPCs_arr: Array[SpawnNPCs]
	var spawn_tiles_arr: Array[SpawnTiles]
	
	
	func _init(p_name: String, p_probability: int, p_descr: String, p_announce_only_on_radio: bool,
	p_active_periods: int, p_constraints: Dictionary, p_consequences: Dictionary, p_stage_name: String,
	p_spawn_NPCs_arr: Array[SpawnNPCs], p_spawn_tiles_arr: Array[SpawnTiles]) -> void:
		name = p_name
		probability = p_probability
		descr = p_descr
		announce_only_on_radio = p_announce_only_on_radio
		active_periods = p_active_periods
		constraints = p_constraints
		consequences = p_consequences
		stage_name = p_stage_name
		spawn_NPCs_arr = p_spawn_NPCs_arr
		spawn_tiles_arr = p_spawn_tiles_arr


#OEC = Optional Event Countdown
var _opt_event_countdown : int
const OEC_LOWER_BOUND : int = 2
const OEC_UPPER_BOUND : int = 4
#const OE_ACTIVE_PERIODS: int = 2 #Amount of periods that an event stays active

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()
var _gui_mngr : EMC_GUIMngr
var _crisis_phase: EMC_CrisisPhase

var _active_events: Array[Event]
var _known_active_events: Array[Event]
var _executable_constraints: EMC_ActionConstraints
var _executable_consequences: EMC_ActionConsequences

########################################## PUBLIC METHODS ##########################################
## Constructor
func _init(p_crisis_phase: EMC_CrisisPhase, p_gui_mngr: EMC_GUIMngr) -> void:
	_crisis_phase = p_crisis_phase
	_gui_mngr = p_gui_mngr
	_opt_event_countdown = _rng.randi_range(OEC_LOWER_BOUND, OEC_UPPER_BOUND)
	_rng.randomize()


func get_active_events() -> Array[Event]:
	return _active_events


func get_active_event(p_name: String) -> Event:
	for event in _active_events:
		if event.name == p_name:
			return event
	return null


func has_executed_consequences_of_event(p_name: String) -> bool:
	var active_event := get_active_event(p_name)
	if active_event == null: return true
	
	return active_event.consequences_executed


func set_event_as_known(p_name: String) -> void:
	var event := get_active_event(p_name)
	if event != null:
		_known_active_events.append(event)


func get_known_active_events() -> Array[Event]:
	return _known_active_events


func deactivate_event(p_name: String) -> bool:
	var removed_from_active_events := false
	for event in _active_events:
		if event.name == p_name:
			_active_events.erase(event)
			removed_from_active_events = true
	
	for event in _known_active_events:
		if event.name == p_name:
			_known_active_events.erase(event)
	
	return removed_from_active_events


func set_constraints(p_constraints: EMC_ActionConstraints) -> void:
	_executable_constraints = p_constraints


func set_consequences(p_consqeuences: EMC_ActionConsequences) -> void:
	_executable_consequences = p_consqeuences


func execute_consequences(p_active_event_name: String) -> void:
	var active_event := get_active_event(p_active_event_name)
	if active_event == null: return
	
	for key : String in active_event.consequences.keys():
		var params : Variant = active_event.consequences[key]
		Callable(_executable_consequences, key).call(params)
	
	active_event.consequences_executed = true


## As this doesn't flag know the active event it's operating on, you most likely want 
## to call flag_consequences_as_executed afterwards
func execute_extra_consequence(p_consequence: String, p_param: Variant) -> void:
	Callable(_executable_consequences, p_consequence).call(p_param)


func flag_consequences_as_executed(p_active_event_name: String) -> void:
	var active_event := get_active_event(p_active_event_name)
	if active_event == null: return
	active_event.consequences_executed = true


func check_for_new_event(p_new_period: EMC_DayMngr.DayPeriod) -> void:
	#See if event should end
	for event: Event in _active_events:
		event.active_periods -= 1
		if event.active_periods == 0:
			deactivate_event(event.name)
	
	#See if new event should be started
	_opt_event_countdown -= 1
	if _opt_event_countdown == 0:
		var new_event := _create_new_optional_event(p_new_period)
		_opt_event_countdown = _rng.randi_range(OEC_LOWER_BOUND, OEC_UPPER_BOUND)
		#print("Event started:" + new_event.name) ##Test
		
		if new_event.name == "RAIN":
			_gui_mngr.queue_gui("RainAnimation", [])
		elif !new_event.announce_only_on_radio && new_event.descr != "":
			_gui_mngr.request_gui("TooltipGUI", [new_event.descr])

func save() -> Dictionary:
	var data : Dictionary = {
		"count_down": _opt_event_countdown,
	}
	return data

func load_state(data : Dictionary) -> void:
	_opt_event_countdown = data.get("count_down", _opt_event_countdown)

########################################## PRIVATE METHODS #########################################
func _create_new_optional_event(p_new_period: EMC_DayMngr.DayPeriod) -> Event:
	var possible_opt_events := JsonMngr.get_possible_opt_events(_executable_constraints)
	
	#Dependend on the probability choose one to activate
	var indices: Array[int]
	
	for event_idx in possible_opt_events.size():
		var event: Event = possible_opt_events[event_idx]
		for i in event.probability:
			indices.append(event_idx)
	
	var rand_idx := indices[_rng.randi_range(0, indices.size() - 1)]
	var chosen_event: Event = possible_opt_events[rand_idx] #pick_random doesn't work properly seemingly
	
	#Activate the chosen event
	if chosen_event.active_periods > 0:
		_active_events.append(chosen_event)
	
	return chosen_event

extends Node
class_name EMC_OverworldStatesMngr

const SAVE_FILE = "user://OSM.res"

#region Enums
enum Difficulty{
	TUTORIAL = 3,
	EASY = 0,
	MEDIUM = 1,
	HARD = 2,
}

const state_to_icon: Dictionary = {
	"MobileNetState.ONLINE" : preload("res://assets/GUI/icons/online_icon.png"),
	"MobileNetState.OFFLINE" : preload("res://assets/GUI/icons/offline_icon.png"),
	"ElectricityState.NONE" : preload("res://assets/GUI/icons/no_power_icon.png"),
	"ElectricityState.UNLIMITED" : preload("res://assets/GUI/icons/power_icon.png"),
	"WaterState.NONE" : preload("res://assets/GUI/icons/no_water_icon.png"),
	"WaterState.DIRTY" : preload("res://assets/GUI/icons/dirty_water_icon.png"),
	"WaterState.CLEAN" : preload("res://assets/GUI/icons/water_icon.png"),
	"FoodContaminationState.NONE" : preload("res://assets/GUI/icons/food_icon.png"),
	"FoodContaminationState.FOOD_SPOILED" : preload("res://assets/GUI/icons/food_contaminated_icon.png"),
}

@export var state_to_descr: Dictionary = {
	"MobileNetState.ONLINE" : "Du hast eine Verbindung zum Internet",
	"MobileNetState.OFFLINE" : "Das Internet ist ausgefallen",
	"ElectricityState.NONE" : "Der Strom ist ausgefallen",
	"ElectricityState.UNLIMITED" : "Du hast Strom",
	"WaterState.NONE" : "Das Wasser ist ausgefallen",
	"WaterState.DIRTY" : "Das Wasser ist verdreckt",
	"WaterState.CLEAN" : "Du hast sauberes Wasser",
	"FoodContaminationState.NONE" : "",
	"FoodContaminationState.FOOD_SPOILED" : ""
}
#endregion

signal game_won

var _upgrades: Array[EMC_Upgrade]

var _difficulty_crisis : Difficulty
var _run_length : int


func _ready() -> void:
	add_to_group("Save", true)
	
func reset() -> void:
	#Scenario
	clear_crisis_description()
	crisis_end = 0
	
	#State
	facility_states.clear()
	facility_states[0] = FACILITY_STATES_DEFAULT.duplicate(true)
	facility_effective_states.clear()
	facility_effective_states[0]= {}
	for state: String in facility_states[0]:
		facility_effective_states[0][state] = facility_states[0][state]["default"]
	modifiers = BASE_MODIFIERS.duplicate(true)
	current_t = 0
	
	# Quest
	clear_quest()
	
	# NPC
	_npc_intention_back.clear()
	clear_npc_intention()
	
	# Dialoge
	clear_dialoge_states()

func set_crisis_difficulty(p_run_length : int = 3, p_difficulty_crisis : Difficulty = Difficulty.EASY) -> void:
	_difficulty_crisis = p_difficulty_crisis
	_run_length = p_run_length

func get_crisis_length() -> int:
	return _run_length

func get_difficulty() -> Difficulty:
	return _difficulty_crisis
	
func get_difficulty_str() -> String:
	return Difficulty.find_key(_difficulty_crisis)

############################################Scenario################################################
#region Scenario
var _crisis_description : Dictionary

func add_scenario(id: String, descr: String, _t : int) -> void:
	var t: int = current_t + _t
	if not _crisis_description.has(t):
		_crisis_description[t] = {}
	
	if not _crisis_description[t].has(id):
		_crisis_description[t][id] = []
	_crisis_description[t][id].append(descr)
	
func get_scenario(_t: int = 0) -> Dictionary:
	var t: int = current_t + _t
	return _crisis_description.get(t, {})
	
func get_scenario_names(_t: int = 0) -> Array[String]:
	var result: Array[String] = []
	for key: String in _crisis_description.get(current_t + _t, ""):
		result.append(key.get_basename().get_extension())
	return result

## Returns notification for radio
func get_notification() -> Array[String]:
	var result : Array[String]
	for descr : Array in _crisis_description[current_t].values():
		result.append_array(descr)
	return result
	
func clear_crisis_description() -> void:
	_crisis_description.clear()
#endregion

#############################################States#################################################

var crisis_end: int = 0

#region States

const STATE_TRANSLATOR: Dictionary = {
	"ElectricityState": {"NONE": 0, "UNLIMITED": 1},
	"WaterState": {"NONE": 0, "DIRTY": 1, "CLEAN": 2},
	"MobileNetState": {"OFFLINE": 0, "ONLINE": 1}
}

const FACILITY_STATES_DEFAULT: Dictionary = {
	"ElectricityState": {"default": 1},
	"WaterState": {"default": 2},
	"MobileNetState": {"default": 1}
}

var facility_states: Dictionary = {
	0: {
		"ElectricityState": {"default": 1},
		"WaterState": {"default": 2},
		"MobileNetState": {"default": 1}
	}
}

var facility_effective_states: Dictionary = {
	0: {
		"ElectricityState": 1,
		"WaterState": 2,
		"MobileNetState": 1
	}
}

var current_t: int = 0
var _batch_depth: int = 0

## TODO: Efficency
func begin_batch() -> void:
	_batch_depth = 1
	
func end_batch() -> void:
	_batch_depth = max(_batch_depth - 1, 0)
	if _batch_depth == 0 and not facility_states.is_empty():
		_calculate_all_effective_states(facility_states.keys().max())

func add_state_layer_int(state: String, id: String, value: int, _t: int = 0) -> void:
	var t: int = current_t + _t
	for i in range(current_t, t+1):
		if not facility_states.has(i):
			facility_states[i] = FACILITY_STATES_DEFAULT.duplicate(true)
	
	if not facility_states[t].has(state):
		facility_states[t][state] = {}
	facility_states[t][state][id] = value
	
	if _batch_depth > 0:
		return
		
	for i in range(current_t, t+1):
		if not facility_effective_states.has(i):
			facility_effective_states[i] = {}
		facility_effective_states[i][state] = _calculate_effective_state(state, i-current_t)

func add_state_layer_str(state: String, id: String, value: String, _t: int = 0) -> void:
	add_state_layer_int(state, id, STATE_TRANSLATOR[state][value], _t)

func add_state_layer_str_range(state: String, id: String, value: String, start: int = 0, end: int = 0) -> void:
	begin_batch()
	for _t in range(start, end):
		add_state_layer_int(state, id, STATE_TRANSLATOR[state][value], _t)
	end_batch()
	
func remove_state_layer(state: String, id: String, _t: int = 0) -> void:
	var t: int = current_t + _t
	if facility_states[t].has(state):
		facility_states[state].erase(id)
		
	if _batch_depth > 0:
		return
		
	facility_effective_states[t][state] = _calculate_effective_state(state, _t)

func _calculate_all_effective_states(_t: int = 0) -> void:
	var t: int = current_t + _t
	var values: Array[int]
	for state: String in FACILITY_STATES_DEFAULT.keys():
		for i in range(current_t, t+1):
			if not facility_states.has(i):
				facility_states[i] = FACILITY_STATES_DEFAULT.duplicate(true)
			
			values.assign(facility_states[i].get(state, {}).values())
			if not values.is_empty():
				if not facility_effective_states.has(i):
					facility_effective_states[i] = {}
				
				facility_effective_states[i][state] = values.min()

func _calculate_effective_state(state: String, _t: int = 0) -> int:
	var t: int = current_t + _t
	var values: Array[int]
	values.assign(facility_states[t].get(state, {}).values())
	if not values.is_empty():
		return values.min()
	return -1

func get_effective_state_int(state: String, _t: int = 0) -> int:
	var t: int = current_t + _t
	if not facility_effective_states.has(t):
		facility_states[t] = FACILITY_STATES_DEFAULT.duplicate(true)
		facility_effective_states[t] = {}
	facility_effective_states[t][state] = _calculate_effective_state(state, _t)
		
	return facility_effective_states[t].get(state, -1)

func get_effective_state_str(state: String, _t: int = 0) -> String:
	var t: int = current_t + _t
	if not facility_effective_states.has(t):
		facility_states[t] = FACILITY_STATES_DEFAULT.duplicate(true)
		facility_effective_states[t] = {}
	facility_effective_states[t][state] = _calculate_effective_state(state, _t)
	
	if facility_effective_states[t].has(state):
		return STATE_TRANSLATOR[state].find_key(facility_effective_states[t][state])
	return "NULL"
	
func is_effective_state_eq(state: String, value: String, _t: int = 0) -> bool:
	return get_effective_state_int(state, _t) == STATE_TRANSLATOR[state][value]

func is_effective_state_neq(state: String, value: String, _t: int = 0) -> bool:
	return get_effective_state_int(state, _t) != STATE_TRANSLATOR[state][value]
	
func is_effective_state_lt(state: String, value: String, _t: int = 0) -> bool:
	return get_effective_state_int(state, _t) < STATE_TRANSLATOR[state][value]
	
func is_effective_state_gt(state: String, value: String, _t: int = 0) -> bool:
	return get_effective_state_int(state, _t) > STATE_TRANSLATOR[state][value]

#endregion

#region flags
# Format: { 0: { "NoEntry" : { "market": 1 } } }
var flags: Dictionary[int, Dictionary] = {
}

func add_flag_layer(state: String, flag: String, _t: int = 0) -> void:
	var t: int = current_t + _t
	for i in range(current_t, t+1):
		if not flags.has(i):
			flags[i] = {}
	
	if not flags[t].has(state):
		flags[t][state] = {}
	if flags[t][state].has(flag):
		flags[t][state][flag] += 1
	else:
		flags[t][state][flag] = 1
	
func remove_flag_layer(state: String, flag: String, _t: int = 0) -> void:
	var t: int = current_t + _t
	if not flags.has(t):
		return
	
	if flags[t].has(state) and flags[t][state].has(flag):
		flags[t][state][flag] -= 1
		
		if flags[t][state][flag] <= 0:
			flags[t][state].erase(flag)

func get_flags(state: String, _t: int = 0) -> Array[String]:
	var t: int = current_t + _t
	if flags.has(t) and flags[t].has(state):
		var result : Array[String]
		result.assign(flags[t][state].keys())
		return result
	return []
	
func has_flag(state: String, flag: String, _t: int = 0) -> bool:
	var t: int = current_t + _t
	if flag.is_empty():
		return flags.get(t, {}).has(state)
	return flags.get(t, {}).get(state, {}).has(flag)

func has_not_flag(state: String, flag: String, _t: int = 0) -> bool:
	var t: int = current_t + _t
	if flag.is_empty():
		return not flags.get(t, {}).has(state)
	return not flags.get(t, {}).get(state, {}).has(flag)	
	
func has_any_flag(p_state: String, p_flags: Array[String], _t: int = 0) -> bool:
	var t: int = current_t + _t
	var state: Dictionary = flags.get(t, {}).get(p_state, {})
	if state.is_empty():
		return p_flags.is_empty()
	for flag in p_flags:
		if state.has(flag):
			return true
	return false
	
func has_all_flag(state: String, p_flags: Array[String], _t: int = 0) -> bool:
	var t: int = current_t + _t
	return flags.get(t, {}).get(state, {}).has_all(p_flags)

#endregion

#region modifiers

const BASE_MODIFIERS: Dictionary = {
	"food_decay_rate": 0.6
}

var modifiers: Dictionary = {
	"food_decay_rate": 0.6
}

func add_modifier(state: String, value: float) -> void:
	if modifiers.has(state):
		modifiers[state] += value
	else:
		modifiers[state] = BASE_MODIFIERS.get(state, 0) + value

func remove_modifier(state: String) -> void:
	modifiers.erase(state)

func get_modifier(state: String) -> float:
	return modifiers.get(state, BASE_MODIFIERS.get(state, INF))

#endregion

func next_day(t: int) -> void:
	#if not get_scenario(1).keys().is_empty() and get_scenario().keys() != get_scenario(1).keys():
		#SoundMngr.play_stinger()
	#
	#SoundMngr.next_day()
	
	current_t = t
	facility_effective_states.erase(t-1)
	facility_states.erase(t-1)
	flags.erase(t-1)
	_crisis_description.erase(t-1)
	
	if t > OverworldStatesMngr.get_crisis_length():
		game_won.emit()

func ask_OSM_api(dict: Dictionary) -> bool:
	if dict.has("state"):
		if dict.has("is"):
			var state: String = dict["state"]
			return STATE_TRANSLATOR[state][dict["is"]] == get_effective_state_int(state)
		elif dict.has("is_not"):
			var state: String = dict["state"]
			return STATE_TRANSLATOR[state][dict["is_not"]] !=  get_effective_state_int(state)
		elif dict.has("is_gt"):
			var state: String = dict["state"]
			return STATE_TRANSLATOR[state][dict["is_gt"]] < get_effective_state_int(state)
		elif dict.has("is_lt"):
			var state: String = dict["state"]
			return STATE_TRANSLATOR[state][dict["is_lt"]] > get_effective_state_int(state)
	elif dict.has("flag"):
		if dict.has("has"):
			return has_flag(dict["flag"], dict["has"])
		elif dict.has("has_not"):
			return has_not_flag(dict["flag"], dict["has_not"])
		elif dict.has("has_any"):
			return has_any_flag(dict["flag"], dict["has_any"])
		elif dict.has("has_all"):
			return has_all_flag(dict["flag"], dict["has_all"])
	
	return false

func apply_effect(data: Dictionary) -> void:
	if data.has_all(["state", "value", "layer"]):
		add_state_layer_str(data["state"], data["layer"], data["value"])
	elif data.has_all(["flag", "value"]):
		add_flag_layer(data["flag"], data["value"])
	elif data.has_all(["modifier", "value"]):
		add_modifier(data["modifier"], data["value"])

func remove_effect(data: Dictionary) -> void:
	if data.has_all(["state", "layer"]):
		remove_state_layer(data["state"], data["layer"])
	elif data.has_all(["flag", "value"]):
		remove_flag_layer(data["flag"], data["value"])
	elif data.has_all(["modifier", "value"]):
		add_modifier(data["modifier"], -data["value"])


func get_every_state_as_name() -> Array[String]:
	return [
		"WaterState." + get_effective_state_str("WaterState"),
		"ElectricityState." + get_effective_state_str("ElectricityState"),
		"MobileNetState." + get_effective_state_str("MobileNetState"),
		#"FoodContaminationState." + FoodContaminationState.find_key(_food_contamination_state),
		#"IsolationState." + IsolationState.find_key(_isolation_state)
	]

############################################Dialogue################################################
#region Dialogue
var _dialogue_states : Dictionary

func set_dialogue_state(state_name : String, value : Variant) -> void:
	_dialogue_states[state_name] = value
	
func is_dialogue_state(state_nane : String, value : Variant) -> bool:
	if _dialogue_states.has(state_nane):
		return typeof(_dialogue_states[state_nane]) == typeof(value) and _dialogue_states[state_nane] == value
	return false
	
func clear_dialoge_states() -> void:
	_dialogue_states.clear()
#endregion

############################################Furniture###############################################
#region Furniture

func set_upgrades(upgrades : Array[EMC_Upgrade]) -> void:
	_upgrades = upgrades

## TODO: more efficent version
func has_upgrade(id: EMC_Upgrade.IDs) -> bool:
	return id in _upgrades.map(func (up: EMC_Upgrade) -> int: return up.get_id())

func get_upgrades() -> Array[EMC_Upgrade]:
	return _upgrades

func get_upgardes_id() -> Array[int]:
	var result: Array[int]
	result.assign(_upgrades.map(func(upgrade: EMC_Upgrade) -> int: return upgrade.get_id()))
	return result

func get_upgrade_if_equipped(p_ID: EMC_Upgrade.IDs) -> EMC_Upgrade:
	for upgrade in _upgrades:
		if upgrade.get_id() == p_ID:
			return upgrade
	return null

func get_furniture_state(p_upgrade_id: EMC_Upgrade.IDs) -> int:
	for upgrade in _upgrades:
		if upgrade != null && upgrade.get_id() == p_upgrade_id: #MRM: Added null check
			return upgrade.get_state()
	push_error("Upgrade nicht ausgerüstet!")
	return -1

func set_furniture_state(p_upgrade_id: EMC_Upgrade.IDs, new_state: int) -> void:
	for upgrade in _upgrades:
		if upgrade != null && upgrade.get_id() == p_upgrade_id: #MRM: Added null check
			upgrade.set_state(new_state)
	push_error("Upgrade nicht ausgerüstet!")

func get_furniture_state_maximum(p_upgrade_id: EMC_Upgrade.IDs) -> int:
	for upgrade in _upgrades:
		if upgrade != null && upgrade.get_id() == p_upgrade_id: #MRM: Added null check
			return upgrade.get_state_maximum()
	push_error("Upgrade nicht ausgerüstet!")
	return -1
#endregion
	
#############################################Quest##################################################
#region Quest
var active_quests: Dictionary = {}

## Returns wether a quest is currently active
## Does not return the stage of the quest
func has_quest(id: String) -> bool:
	return id in active_quests

## Adds a new quest or overrides the stage
func add_quest(id: String, stage: int = 1) -> void:
	active_quests[id] = stage
	#print(active_quests)

func add_quest_str(id: String, stage: String = "1") -> void:
	active_quests[id] = int(stage)

## Returns the current stage of the quest
## Should only be called after confirming quest exists
## with has_quest
func get_quest_stage(id: String) -> int:
	return active_quests[id]
	
## Removes a quest
func remove_quest(id: String) -> void:
	active_quests.erase(id)
	
## Regulate number of cocurrent quest
func next_quest() -> bool:
	return active_quests.size() < 3

func clear_quest() -> void:
	active_quests.clear()
#endregion

##############################################NPC###################################################
#region NPC

# Format: {NPC: ACTION_ID}
var _npc_intention: Dictionary
var _npc_intention_back: Dictionary
var _npc_intention_changed: bool = false

func add_npc_intention(npc: String, action_id: String) -> void:
	_npc_intention_back[npc] = action_id
	if _npc_intention.get(npc) != action_id:
		_npc_intention_changed = true

func npc_intention_swap() -> void:
	_npc_intention = _npc_intention_back.duplicate()
	_npc_intention_back.clear()
	_npc_intention_changed = false

func clear_npc_intention() -> void:
	_npc_intention.clear()
	_npc_intention_changed = false
#endregion

############################################Save/Load###############################################

## Save function called to get all relevant information. This is used for Saving/loading
func save() -> Dictionary:
	var data: EMC_AllRes = EMC_AllRes.new()
	data.add_res("difficulty_crisis", _difficulty_crisis)
	data.add_res("run_length", _run_length)
	data.add_res("crisis_description", _crisis_description)
	data.add_res("facility_effective_states", facility_effective_states)
	data.add_res("facility_states", facility_states)
	data.add_res("flags", flags)
	data.add_res("modifiers", modifiers)
	data.add_res("upgrades", _upgrades)
	data.add_res("crisis_end", crisis_end)
	data.add_res("current_t", current_t)
	
	ResourceSaver.save(data, SAVE_FILE)
	
	return {"node_path": get_path()}

## Load all relevant information. This is used for Saving/loading
func load_state(p_data : Dictionary) -> void:
	var data : EMC_AllRes
	if p_data.has("override"):
		data = EMC_AllRes.load_res(p_data["override"])
	else:
		data = EMC_AllRes.load_res(SAVE_FILE)
	
	var p_difficulty_crisis : Difficulty = data.get_res("difficulty_crisis")
	var p_run_length : int = data.get_res("run_length")
	
	set_crisis_difficulty(p_run_length, p_difficulty_crisis)
	
	facility_effective_states = data.get_res("facility_effective_states")
	facility_states = data.get_res("facility_states")
	flags.assign(data.get_res("flags"))
	modifiers = data.get_res("modifiers")
	current_t = data.get_res("current_t", 0)
	
	var p_crisis_description : Dictionary = data.get_res("crisis_description")
	
	_crisis_description = p_crisis_description
	crisis_end = data.get_res("crisis_end", 0)
	
	var upgrades: Array[EMC_Upgrade]
	upgrades.assign(data.get_res("upgrades", []))
	set_upgrades(upgrades)

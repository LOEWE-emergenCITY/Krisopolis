extends Node

const MAX_ECOINS = 99999
const INITIAL_E_COINS = 300

# Reset induvidually
const SAVE_SETTINGS_FILE = "user://settings.res"
# Sound
# Vibration
# Font

# Reset with game reset
const SAVE_META_FILE = "user://metasave.res"
# E Coins
# Avatar Selections
# Upgrades Unlocked
# Apps Installed
# Game State
# Tutorial done

# reset every inner loop end
const SAVE_GAME_FILE = "user://savegame.tres" ## loaded in prepare phase
# Inventory
# Upgrades
# Difficulty

#const SAVE_STATE_FILE = "user://savestate.save" ## loaded in crisis phase
# OSM
# DayMngr
# Avatar
# Stage
# Handy
# Score
# Opt Event

const SAVE_SCENARIO_FILE = "user://scenariosave.res"


const MAIN_MENU_SCENE = "res://preparePhase/main_menu.tscn"
const CONTINUE_SCENE = "res://preparePhase/continue.tscn"
const CRISIS_PHASE_SCENE = "res://crisisPhase/crisis_phase.tscn"
#const FIRST_GAME_SCENE = "res://global/first_game.tscn"
const INFORMATION_SCENE = "res://preparePhase/information.tscn"
const CREDIT_SCENE = "res://preparePhase/credit_information.tscn"
const CRISIS_START_SCENE = "res://preparePhase/crisis_start.tscn"
const SHOP_SCENE = "res://preparePhase/shop.tscn"
const UPGRADE_CENTER_SCENE = "res://preparePhase/upgrade_center.tscn"
const EDU_SCENE = "res://preparePhase/edu/edu.tscn"

const SAVEFILE_AVATAR_SKIN := "avatar_skin"

signal game_loaded
signal game_saved
signal scene_changed

@onready var _root := get_tree().root
@onready var save_ani_canvas: CanvasLayer = $SaveAniCanvas

# Settings
var _vibration : bool = true
var _is_dyslexic: bool = false

# Once
var _data: bool = false

# Meta
var _e_coins : int = 500
var _tutorial_done : bool = false
var _upgrade_ids_unlocked : Array[EMC_Upgrade.IDs] = []
var _apps_installed : Array[String] = []
var _game_state: State

var _current_scene : Node = null
var _start_scene : String
var _in_crisis_phase: bool
var _started_from_entry_scene: bool = false


var session: Dictionary
#var _upgrades_equipped : Array[EMC_Upgrade] = [null, null, null]
#var _inventory : EMC_Inventory = null
#var _config: Array

enum State {
	CRISIS = 0,
	SCENARIO = 1,
	START = 2
}

func game_state_neq(value: int) -> bool:
	return _game_state != value

## This function and variable are there, so you can later distinguish if the project
## was started normally (F5) or only for a certain scene (F6)
func set_started_from_entry_scene(p_value: bool = true) -> void:
	_started_from_entry_scene = p_value

func _ready() -> void:
	var root := get_tree().root 
	_current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path: String) -> void:
	match path:
		MAIN_MENU_SCENE: _in_crisis_phase = false
		CONTINUE_SCENE: _in_crisis_phase = false
		CRISIS_PHASE_SCENE: _in_crisis_phase = true
		_: _in_crisis_phase = false
	
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path: String) -> void:
	get_tree().root.remove_child(_current_scene)
	_current_scene.queue_free()
	
	var scn : PackedScene = ResourceLoader.load(path)
	_current_scene = scn.instantiate()
	_root.add_child(_current_scene)
	scene_changed.emit()

func is_in_crisis_phase() -> bool:
	return _in_crisis_phase

func load_scene_name() -> String:
	return _start_scene

## MRM: For what is this?? Sometimes I randomly get a crash in save_game
func _notification(what : int) -> void:
	#should prevent saving problems when starting a stand-along scene (F6):
	if !_started_from_entry_scene: return 
	
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game(State.CRISIS if _current_scene.name == "CrisisPhase" else State.START)
		##This leads to the game crashing if you open the mobile-task manager and try to continue
		##the game:
		#get_tree().quit() 

func get_game_state() -> State:
	return _game_state

func save_settings() -> void:
	var data: EMC_AllRes = EMC_AllRes.new()
	data.add_res("master_volume", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))))
	data.add_res("sfx_volume", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))))
	data.add_res("musik_volume", db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Musik"))))
	data.add_res("vibration", _vibration)
	data.add_res("is_dyslexic", _is_dyslexic)
	data.add_res("data", _data)
	
	ResourceSaver.save(data, SAVE_SETTINGS_FILE)

func load_settings() -> void:
	var data: EMC_AllRes = EMC_AllRes.load_res(SAVE_SETTINGS_FILE, ResourceLoader.CacheMode.CACHE_MODE_REPLACE)
	
	_vibration = data.get_res("vibration", true)
	_is_dyslexic = data.get_res("is_dyslexic", false)
	_data = data.get_res("data", false)
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(data.get_res("master_volume", 1)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(data.get_res("sfx_volume", 1)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Musik"), linear_to_db(data.get_res("musik_volume", 1)))
	
	#if not SoundMngr.is_musik_playing():
		#SoundMngr.play_musik()
		
func reset_settings() -> void:
	var data: EMC_AllRes = EMC_AllRes.new()
	ResourceSaver.save(data, SAVE_SETTINGS_FILE)
	
	load_settings()

func save_meta() -> void:
	var data: EMC_AllRes = EMC_AllRes.new()
	
	data.add_res("e_coins", _e_coins)
	data.add_res("game_state", _game_state)
	data.add_res("upgrade_ids_unlocked", _upgrade_ids_unlocked)
	data.add_res(SAVEFILE_AVATAR_SKIN, SettingsGUI.get_avatar_sprite_suffix())
	data.add_res("tutorial_done", _tutorial_done)
	data.add_res("apps_installed", _apps_installed)
	
	ResourceSaver.save(data, SAVE_META_FILE)
	
func load_meta() -> void:
	var data: EMC_AllRes = EMC_AllRes.load_res(SAVE_META_FILE, ResourceLoader.CacheMode.CACHE_MODE_REPLACE)
	
	_vibration = data.get_res("vibration", true)
	_e_coins = data.get_res("e_coins", INITIAL_E_COINS)
	_game_state = data.get_res("game_state", State.START)
	_upgrade_ids_unlocked.assign(data.get_res("upgrade_ids_unlocked", []))
	_tutorial_done = data.get_res("tutorial_done", false)
	_apps_installed.assign(data.get_res("apps_installed", []))
	
	# TODO: test default
	var avatar_skin: String = data.get_res(SAVEFILE_AVATAR_SKIN, "M04")
	if Global._tutorial_done:
		SettingsGUI.set_avatar_sprite_suffix(avatar_skin)
	
func reset_meta() -> void:
	var data: EMC_AllRes = EMC_AllRes.new()
	ResourceSaver.save(data, SAVE_META_FILE)
	
	load_meta()

func save_crisis() -> void:
	var data: EMC_AllRes = EMC_AllRes.new()
	
	var save_nodes : Array[Node] = get_tree().get_nodes_in_group("Save")
	var state: Array[Dictionary]
	for node in save_nodes:
		# Check the node has a save function.
		if !node.has_method("save"):
			printerr("Save node '%s' is missing a save() function, skipped" % node.name)
			continue
			
		# Call the node's save function.
		state.append(node.call("save"))
	
	data.add_res("state", state)
		
	ResourceSaver.save(data, SAVE_GAME_FILE)

func load_crisis() -> void:
	var data: EMC_AllRes = EMC_AllRes.load_res(SAVE_GAME_FILE, ResourceLoader.CacheMode.CACHE_MODE_REPLACE)
	
	for node_data : Dictionary in data.get_res("state", []):
		var new_object : Variant = node_data.get("node_path")
		if new_object:
			get_node(new_object).load_state(node_data)

#func save_scenario() -> void:
	#pass
#
#func load_scenario() -> void:
	#var data: EMC_AllRes = EMC_AllRes.load_res(SAVE_SCENARIO_FILE, ResourceLoader.CacheMode.CACHE_MODE_REPLACE)
	#
	#session = {}
	##session["inventory"] = data.get_res("inventory", create_inventory_with_starting_items())
	##session["upgrades"] = data.get_res("upgrades", [])
	##session["difficulty"] = data.get_res("difficulty", OverworldStatesMngr.Difficulty.EASY)
	##session["state"] = data.get_res("state", [])
	#
	#session["changes"] = data.get_res("changes", [])

func save_start() -> void:
	var data: EMC_AllRes = EMC_AllRes.new()
	
	data.add_res("inventory", session.get("inventory", create_inventory_with_starting_items()))
	data.add_res("upgrades", session.get("upgrades", []))
	data.add_res("difficulty", session.get("difficulty", OverworldStatesMngr.Difficulty.EASY))
	
	ResourceSaver.save(data, SAVE_GAME_FILE)
	
func load_start() -> void:
	var data: EMC_AllRes = EMC_AllRes.load_res(SAVE_GAME_FILE, ResourceLoader.CacheMode.CACHE_MODE_REPLACE)
	
	session = {}
	session["inventory"] = data.get_res("inventory", create_inventory_with_starting_items())
	session["upgrades"] = data.get_res("upgrades", [])
	session["difficulty"] = data.get_res("difficulty", OverworldStatesMngr.Difficulty.EASY)

func save_game(p_game_state : State) -> void:
	save_settings()
	
	_game_state = p_game_state
	
	save_meta()
	
	match _game_state:
		State.CRISIS:
			save_crisis()
		State.START:
			save_start()
		#State.SCENARIO:
			#_game_state = State.CRISIS
			#save_crisis()
			##save_scenario()
	
	game_saved.emit()

func load_game() -> void:
	load_settings()
	load_meta()

	match _game_state:
		State.CRISIS:
			#load_crisis()
			_start_scene = CONTINUE_SCENE
		State.START:
			load_start()
			_start_scene = MAIN_MENU_SCENE
		#State.SCENARIO:
			#_start_scene = CONTINUE_SCENE
			##load_scenario()
	
	game_loaded.emit()

## A default inventory when the game save state is reset/a crisis ended
func create_inventory_with_starting_items() -> EMC_Inventory:
	var inventory := EMC_Inventory.new()
	inventory.add_new_item(EMC_Item.IDs.WATER)
	inventory.add_new_item(EMC_Item.IDs.WATER)
	inventory.add_new_item(EMC_Item.IDs.WATER)
	inventory.add_new_item(EMC_Item.IDs.WATER_DIRTY)
	inventory.add_new_item(EMC_Item.IDs.WATER_DIRTY)
	inventory.add_new_item(EMC_Item.IDs.RAVIOLI_TIN)
	inventory.add_new_item(EMC_Item.IDs.RAVIOLI_TIN)
	inventory.add_new_item(EMC_Item.IDs.UNCOOKED_PASTA)
	inventory.add_new_item(EMC_Item.IDs.SAUCE_JAR)
	inventory.add_new_item(EMC_Item.IDs.BREAD)
	inventory.add_new_item(EMC_Item.IDs.JAM)
	
	inventory.sort_custom(EMC_Inventory.sort_by_id)
	return inventory

func get_e_coins() -> int:
	return _e_coins
	
func set_e_coins(e_coins : int) -> bool:
	if e_coins < 0 or e_coins > MAX_ECOINS:
		return false
	_e_coins = e_coins
	return true

func add_e_coins(e_coins : int) -> void:
	if _e_coins + e_coins > MAX_ECOINS:
		_e_coins = MAX_ECOINS
	else:
		_e_coins += e_coins

func sub_e_coins(e_coins : int) -> bool:
	if _e_coins - e_coins < 0 or e_coins < 0:
		return false
	else:
		_e_coins -= e_coins
		return true

#func get_inventory() -> EMC_Inventory:
	#return _inventory
#
#func set_inventory(inventory : EMC_Inventory) -> void:
	#_inventory = inventory

func get_upgrade_ids_unlocked() -> Array[EMC_Upgrade.IDs]:
	return _upgrade_ids_unlocked

func unlock_upgrade_id(upgrade_id : EMC_Upgrade.IDs) -> void:
	_upgrade_ids_unlocked.append(upgrade_id)

func set_vibration_enabled(x : bool) -> void:
	_vibration = x

func is_vibration_enabled() -> bool:
	return _vibration

func tutorial_finished() -> bool:
	return _tutorial_done

################################################UTIL################################################

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()
## DEPRECATED
func pick_weighted_random(list : Array[Variant], weights : Array[float], count : int) -> Array[Variant]:
	var result : Array[Variant] = []
	assert(count <= list.size(), "Count cannot be greater than list size")
	assert(list.size() == weights.size(), "The size of list and weights must be equal")
	for i in range(count):
		var sum_of_weight : float = weights.reduce(func(a : float, b : float) -> float: return a + b)
		var random : float = _rng.randf_range(0.0, sum_of_weight)
		for index in range(list.size()):
			if random < weights[index]:
				result.append(list[index])
				list.remove_at(index)
				weights.remove_at(index)
				break
			random -= weights[index]
	return result

extends Node

const INVALID_INT_VALUE: int = 0
const INVALID_STRING_VALUE: String = "ERROR"
const INVALID_DICTIONARY_VALUE: Dictionary = {}

## RECIPTS
#const RECIPE_SCN: PackedScene = preload("res://GUI/cooking/recipe.tscn")
const RECIPT_SOURCE := "res://JSONs/recipe.json"
## ITEMS
const ITEM_SOURCE := "res://JSONs/item.json"
const ITEM_TRANSLATE_SOURCE := "res://JSONs/item_ids.json"
## OPT-EVENTS
const OPT_EVENTS_SOURCE := "res://JSONs/optional_events.json"
## NPCS
const NPC_SOURCE := "res://JSONs/npcs/"
## BOOKS
const BOOKS_SOURCE := "res://JSONs/books.json"
## ACTIONS
const ACTION_SOURCE := "res://JSONs/action.json"
## DOORBELL
const DOORBELL_SOURCE := "res://JSONs/doorbell.json"
## SCENARIOS
const SCENARIOS_SOURCE := "res://JSONs/scenarios.json"
## CRISIS
const CRISIS_SOURCE := "res://JSONs/crisis.json"
## UPGARDE
const UPGRADES_SOURCE := "res://JSONs/upgrades.json"
## DIALOGUES
const DIALOGUES_SOURCE := "res://JSONs/dialogues/"

########################################JSON RECIPES################################################

var _is_recipes_loaded : bool = false
var recipes: Array[EMC_Recipe]

func load_recipes() -> Array[EMC_Recipe]:
	if not FileAccess.file_exists(RECIPT_SOURCE):
		printerr("Could not load recipes from source: " + RECIPT_SOURCE)
		return []

	var recipe_source : FileAccess = FileAccess.open(RECIPT_SOURCE, FileAccess.READ)
	var json : JSON = JSON.new()
	
	var json_string : String = recipe_source.get_as_text()
	var parse_result : Error = json.parse(json_string)
	if not parse_result == OK:
		printerr("JSON-Recipe Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return []
	
	var data : Variant = json.get_data()
	if not typeof(data) == TYPE_ARRAY:
		printerr("Invalid format of recipe json (" + RECIPT_SOURCE + "). Make sure it is in form of an Array of Dictonaries.")
		
	var results : Array[EMC_Recipe]
	
	var i : int = 0
	for recipe_json : Dictionary in data:
		var input_item_IDs : Array[EMC_Item.IDs] 
		input_item_IDs.assign(recipe_json.get("input_item_IDs", []))
		var output_item_ID : EMC_Item.IDs = recipe_json.get("output_item_ID", EMC_Item.IDs.DUMMY) as EMC_Item.IDs
		
		var input_item_names : Array[String]
		input_item_names.assign(recipe_json.get("input_item_names", []))
		var output_item_name : String = (recipe_json.get("output_item_name", "DUMMY") as String).to_upper()
		
		if input_item_IDs.is_empty():
			input_item_IDs.assign(input_item_names.map(func(name : String) -> EMC_Item.IDs : return item_name_to_id(name.to_upper())))
		
		if input_item_IDs.is_empty():
			printerr("Recipe-JSON input_item not found in JSON. (Recipe Nr.: " + str(i) + ")")
			
		if output_item_ID == EMC_Item.IDs.DUMMY:
			if item_name_to_id(output_item_name) == null:
				printerr("Recip-JSON: no such item: " + output_item_name + " in Recipe Nr.: " + str(i))
			else:
				output_item_ID = item_name_to_id(output_item_name)
				
		if output_item_ID == EMC_Item.IDs.DUMMY:
			printerr("Recipe-JSON output_item not found in JSON. (Recipe Nr.: " + str(i) + ")")
		
		var needs_water : bool = recipe_json.get("needs_water", false) as bool
		var needs_heat : bool = recipe_json.get("needs_heat", false) as bool
		
		var new_recipe : EMC_Recipe = EMC_Recipe.new()#RECIPE_SCN.instantiate()
		new_recipe.setup(input_item_IDs, output_item_ID, needs_water, needs_heat)
		
		results.append(new_recipe)
		i += 1
	
	return results


#########################################JSON ITEMS#################################################
#region ITEM
var _is_items_loaded : bool = false
var _name_to_id : Dictionary = {}
var _id_to_name : Dictionary = {}
var _id_to_item_vars : Dictionary = {}

#...................................Conversion Functions............................................

func get_item_vars_from_id(ID : int) -> Dictionary:
	if not _is_items_loaded:
		printerr("Items are not yet loaded.")
		return {}
		
	if not _id_to_item_vars.has(str(ID)):
		printerr("Item with ID " + str(ID) + " cannot be found")
		return {}
		
	return _id_to_item_vars[str(ID)]

## Translates item name to its ID
## Better than using the enum, as it uses the actual JSON-translation file
func item_name_to_id(p_name : String) -> int:
	if not _is_items_loaded:
		printerr("Items are not yet loaded.")
		return 0
	
	if not _name_to_id.has(p_name):
		printerr("Item with name " + p_name + " cannot be found")
		return 0
	
	return _name_to_id[p_name]


func item_id_to_name(ID : int) -> String:
	if not _is_items_loaded:
		printerr("Items are not yet loaded.")
		return "DUMMY"
	
	if not _id_to_name.has(ID):
		printerr("Item with ID " + str(ID) + " cannot be found")
		return "DUMMY"
	
	return _id_to_name[ID]
	
func get_all_ids() -> Array[int]:
	var result : Array[int]
	result.assign(_name_to_id.values())
	return result
	
func get_all_names() -> Array[String]:
	var result : Array[String]
	result.assign(_name_to_id.keys())
	return result

#...................................JSON load Functions.............................................

func load_item_translator() -> void:
	if not FileAccess.file_exists(ITEM_TRANSLATE_SOURCE):
		printerr("Could not load item translatore from source: " + ITEM_TRANSLATE_SOURCE)
		return

	var recipe_source : FileAccess = FileAccess.open(ITEM_TRANSLATE_SOURCE, FileAccess.READ)
	var json : JSON = JSON.new()
	
	var json_string : String = recipe_source.get_as_text()
	var parse_result : Error = json.parse(json_string)
	if not parse_result == OK:
		printerr("Item-Translator-JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
		
	var data : Variant = json.get_data()
	if not typeof(data) == TYPE_DICTIONARY:
		printerr("Invalid format of Item-Translator-JSON (" + ITEM_TRANSLATE_SOURCE + "). Make sure it is in form of a Dictonarie.")
		
	_name_to_id = data
	
	for i in len(data.values()):
		_id_to_name[data.values()[i] as int] = data.keys()[i]


func load_items() -> void:
	load_item_translator()
	
	if not FileAccess.file_exists(ITEM_SOURCE):
		printerr("Could not load item from source: " + ITEM_SOURCE)
		return

	var recipe_source : FileAccess = FileAccess.open(ITEM_SOURCE, FileAccess.READ)
	var json : JSON = JSON.new()
	
	var json_string : String = recipe_source.get_as_text()
	var parse_result : Error = json.parse(json_string)
	if not parse_result == OK:
		printerr("Item-JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
	
	var data : Variant = json.get_data()
	if not typeof(data) == TYPE_ARRAY:
		printerr("Invalid format of Item-JSON (" + ITEM_SOURCE + "). Make sure it is in form of an Array of Dictonaries.")
		
	#_name_to_id = {}
	_id_to_item_vars = {}
	
	var item_index : int = 0
	
	for item : Dictionary in data:
		var item_data : Dictionary = {}
		
		var _id : Variant = item.get("ID", NAN)
		if typeof(_id) != TYPE_FLOAT or _id == NAN or _name_to_id.find_key(_id) == null:
			printerr("Item-JSON: item in position " + str(item_index) + " has an invalid item 'ID'.")
			item_index += 1
			continue
		
		var _name : Variant = item.get("name", INVALID_STRING_VALUE)
		if typeof(_name) != TYPE_STRING or _name == INVALID_STRING_VALUE:
			printerr("Item-JSON: item in position " + str(item_index) + " has an invalid item 'name'.")
			item_index += 1
			continue
		
		var _descr : String = item.get("descr", INVALID_STRING_VALUE)
		if typeof(_descr) != TYPE_STRING or _descr == INVALID_STRING_VALUE:
			printerr("Item-JSON: item in position " + str(item_index) + " has an invalid item 'descr'.")
			item_index += 1
			continue
			
		var _sound : Dictionary = item.get("sound", INVALID_DICTIONARY_VALUE)
		if typeof(_sound) != TYPE_DICTIONARY:
			printerr("Item-JSON: item in position " + str(item_index) + " has no or an invalid item 'sound'.")
		else:
			item_data["sound"] = _sound
			
		var _comp_dicts : Variant = item.get("comps", {})
		if typeof(_comp_dicts) != TYPE_DICTIONARY:
			printerr("Item-JSON: item in position " + str(item_index) + " has an invalid item 'comps'.")
			item_index += 1
			continue
		
		item_data = {
			"name": _name,
			"descr": _descr,
			"comps": _comp_dicts,
			#"sound": _sound,
		}
		
		_id_to_item_vars[str(int(_id))] = item_data
		
		item_index += 1
	
	_is_items_loaded = true
#endregion
######################################JSON OPT EVENTS#############################################
#region OP-EVENT
var _opt_events : Array[EMC_OptionalEventMngr.Event]
#var _pop_up_name_to_id : Dictionary
var _is_opt_events_loaded : bool = false

func load_opt_events() -> void:
	if not FileAccess.file_exists(OPT_EVENTS_SOURCE):
		printerr("Could not load PopUps from source: " + OPT_EVENTS_SOURCE)
		return

	var opt_events_source : FileAccess = FileAccess.open(OPT_EVENTS_SOURCE, FileAccess.READ)
	var json : JSON = JSON.new()
	
	var json_string : String = opt_events_source.get_as_text()
	var parse_result : Error = json.parse(json_string)
	if not parse_result == OK:
		printerr("Opt-Events JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return

	var data : Variant = json.get_data()
	if not typeof(data) == TYPE_ARRAY:
		printerr("Invalid format of Optional Events-JSON (" + OPT_EVENTS_SOURCE + "). Make sure it is in form of an Array of Dictonaries.")
	
	#General structure of JSON fine, let's loop over all the entries
	for opt_event_data : Dictionary in data:
		var _name: String = opt_event_data.get("name")
		var probability: int = opt_event_data.get("probability")
		var descr: String = opt_event_data.get("descr")
		var announce_only_on_radio: bool = opt_event_data.get("announce_only_on_radio")
		var active_periods: int = opt_event_data.get("active_periods")
		var constraints: Dictionary = opt_event_data.get("constraints")
		var consequences: Dictionary = opt_event_data.get("consequences")
		var stage_name: String = opt_event_data.get("stage_name", "error").to_lower()
		
		#Dynamic tiles spawns
		var dynamic_tiles_dict : Array[Dictionary]
		dynamic_tiles_dict.assign(opt_event_data.get("spawn_tiles", []))
		var spawn_tiles: Array[EMC_OptionalEventMngr.SpawnTiles] = []
		
		for entry in dynamic_tiles_dict:
			var new_dynamic_tiles := EMC_OptionalEventMngr.SpawnTiles.new()
			new_dynamic_tiles.tilemap_pos = Vector2i(entry.get("tilemap_x_pos", -1),
		 											 entry.get("tilemap_y_pos", -1))
			new_dynamic_tiles.atlas_coord = Vector2i(entry.get("atlas_x_coord", -1),
													 entry.get("atlas_y_coord", -1))
			new_dynamic_tiles.tiles_cols = entry.get("tiles_cols", -1)
			new_dynamic_tiles.tiles_rows = entry.get("tiles_rows", -1)
			new_dynamic_tiles.overwrite_existing_tiles = entry.get("overwrite_existing_tiles", false)
			
			spawn_tiles.append(new_dynamic_tiles)
		
		##Dynamic NPCs spawns
		var spawn_NPCs_dict : Array[Dictionary]
		spawn_NPCs_dict.assign(opt_event_data.get("spawn_NPCs", []))
		var spawn_NPCs: Array[EMC_OptionalEventMngr.SpawnNPCs] = []
		
		for spawn_NPC_dict_entry in spawn_NPCs_dict:
			var new_NPC_spawn := EMC_OptionalEventMngr.SpawnNPCs.new()
			new_NPC_spawn.NPC_name = spawn_NPC_dict_entry.get("NPC_name", "error") #NOT TO LOWER!
			new_NPC_spawn.pos = Vector2(spawn_NPC_dict_entry.get("x_pos", -1), \
										spawn_NPC_dict_entry.get("y_pos", -1))
			
			spawn_NPCs.append(new_NPC_spawn)
		
		
		## Create new optional event
		var opt_event: EMC_OptionalEventMngr.Event = \
			EMC_OptionalEventMngr.Event.new(_name, probability, descr, announce_only_on_radio, \
				active_periods, constraints, consequences, stage_name, spawn_NPCs, spawn_tiles)
		_opt_events.append(opt_event)
	
	_is_opt_events_loaded = true


## CAUTION: Because the same array is used there is a risk, that a reference is manipulated during runtime
## which could lead to unexpected behaviour! Ideally the filtered entry should be duplicated!!!
func get_possible_opt_events(p_action_constraint : EMC_ActionConstraints) -> Array[EMC_OptionalEventMngr.Event]:
	var filtered : Array[EMC_OptionalEventMngr.Event] = _opt_events.filter(func (opt_event: EMC_OptionalEventMngr.Event) -> bool: 
		for key : String in opt_event.constraints:
			var params : Variant = opt_event.constraints[key]
			
			## TODO: Handle non exisitend functions
			if not Callable(p_action_constraint, key).call(params) == EMC_ActionConstraints.NO_REJECTION:
				return false
		return true
		)
	
	##TODO: Also check, that the location at which NPCs are spawned isn't already used in a currently
	## active opt. event (otherhwise the events would collide!)
	
	return filtered
#endregion
########################################JSON ACTION#################################################
#region ACTION
var _actions : Dictionary
var _dict_actions : Dictionary
var _is_action_loaded : bool = false
var ACTION_SCNS : Dictionary = {} 

const DEFAULT_ACTION_STR = "action" 
const ACTION_SCN_PATH = "res://crisisPhase/actions/"

func get_action(id: String) -> EMC_Action:
	return _actions.get(id, null)

func load_actions() -> void:
	var data: Dictionary = load_file_check_type(ACTION_SOURCE, "Actions", TYPE_DICTIONARY)
	assert(data != null, "Failed to load Actions!")
	if data == null:
		printerr("Failed to load Actions!")
		return

	for key: String in data:
		_actions[key] = EMC_Action.load_action(data[key])

func set_action_comp(get_exe: Callable) -> void:
	if not _is_action_loaded:
		for action: EMC_Action in _actions.values():
			action.set_comp(get_exe)

		_is_action_loaded = true

#endregion
##########################################DOOR BELL#################################################
#region DOORBELL
func load_door_bell() -> Dictionary:
	if not FileAccess.file_exists(DOORBELL_SOURCE):
		printerr("Could not load doorbell from source: " + DOORBELL_SOURCE)
		return {}

	var bell_source : FileAccess = FileAccess.open(DOORBELL_SOURCE, FileAccess.READ)
	var json : JSON = JSON.new()
	
	var json_string : String = bell_source.get_as_text()
	var parse_result : Error = json.parse(json_string)
	if not parse_result == OK:
		printerr("DoorBell-JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return {}
		
	var data : Variant = json.get_data()
	if not typeof(data) == TYPE_DICTIONARY:
		printerr("Invalid format of DoorBell-JSON (" + DOORBELL_SOURCE + "). Make sure it is in form of a Dictonary.")
		
	return data as Dictionary
#endregion
##########################################JSON NPCS#################################################
#region NPC

func load_NPC() -> Array[EMC_NPC_Resource]:
	assert(_is_items_loaded, "NPS-JSON: Items must be loaded before NPCs")
		
	var result : Array[EMC_NPC_Resource]
	
	for file : String in DirAccess.get_files_at(NPC_SOURCE):
		var source := NPC_SOURCE + "/" + file

		var data : Dictionary = load_file_check_type(source, "NPC", TYPE_DICTIONARY)
		
		# assert(data.has_all(["comp"]))
		if not data.has("comp"):
			printerr("NPC has no comps!")
		
		var new_npc: EMC_NPC_Resource = EMC_NPC_Resource.new()

		for comp_name: String in data.get("comp", []):
			var comp : Resource = ResourceLoader.load("res://crisisPhase/npc/npc_" + comp_name + ".gd")
			if not comp:
				continue
			var new_comp: Resource = comp.new()
			new_comp.setup(data["comp"][comp_name])
			new_npc.add_comp(new_comp)
		
		result.append(new_npc)
					
	return result
		
#endregion
########################################JSON RECIPES################################################
#region RECIPES
func load_books() -> Array[EMC_BookGUI.Book]:
	if not FileAccess.file_exists(BOOKS_SOURCE):
		printerr("Could not load books from source: " + BOOKS_SOURCE)
		return []
	
	var books_src : FileAccess = FileAccess.open(BOOKS_SOURCE, FileAccess.READ)
	var json : JSON = JSON.new()
	var json_string : String = books_src.get_as_text()
	var parse_result : Error = json.parse(books_src.get_as_text())
	if not parse_result == OK:
		printerr("PopUp-JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return []
	
	var data : Variant = json.get_data()
	if not typeof(data) == TYPE_ARRAY:
		printerr("Invalid format of NPC-JSON (" + BOOKS_SOURCE + "). Make sure it is in form of an Array of Dictonaries.")
		
	var result : Array[EMC_BookGUI.Book]
	
	var i : int = 0 
	for dict_data : Dictionary in data:
		var ID : int = dict_data.get("ID", INVALID_INT_VALUE) 
		assert(ID != INVALID_INT_VALUE, "BOOK-JSON: BOOK in position: " + str(i) + \
			" has no ID or an invalid value(such as " + str(INVALID_INT_VALUE) + ").")
		var title: String = dict_data.get("title", INVALID_STRING_VALUE)
		assert(title != INVALID_STRING_VALUE, "BOOK-JSON: BOOK in position: " + str(i) + \
			 " has no title or an invalide value('" + INVALID_STRING_VALUE + "').")
		
		var content: Array[String]
		var content_dicts : Array[Dictionary]
		content.assign(dict_data.get("content", []))
		
		result.append(EMC_BookGUI.Book.new(ID, title, content))
		i += 1
	return result
#endregion
######################################JSON SCENARIOS################################################

var scenarios : Dictionary

func load_scenarios() -> void:
	var data : Dictionary = (load_file_check_type(SCENARIOS_SOURCE, "Scenarios", TYPE_DICTIONARY) as Dictionary)
	if data == null:
		return
	
	scenarios = data

#######################################JSON CIRISIS#################################################

var crisis: Dictionary[String, Dictionary]

func load_crisis() -> void:
	var data : Dictionary = (load_file_check_type(CRISIS_SOURCE, "Crisis", TYPE_DICTIONARY) as Dictionary)
	if data == null or data.is_empty():
		return
		
	assert(data.has_all(["TUTORIAL", "EASY", "following"])) 
	
	crisis.assign(data)

######################################JSON DIALOGUES################################################
#region DIALOGUES
var _dialogues : Dictionary

func get_dialogues() -> Dictionary:
	return _dialogues.duplicate(true)
 
func load_dialogues() -> void:
	var stage_names : Array[String] #= ["home", "market", "townhall", "park", "gardenhouse", "rowhouse",
	#"mansion", "penthouse", "apartment_default", "apartment_mert", "apartment_camper", "extra"]
	var actor_names : Array[String]
	
	var result : Dictionary
	
	#print("JSON: Loading Dialogues.")
	var dir := DirAccess.open(DIALOGUES_SOURCE)
	if dir:
		dir.list_dir_begin()
		var dir_name : String = dir.get_next()
		while dir_name != "":
			if dir.current_is_dir():
				#print("Found stage: " + dir_name)
				stage_names.append(dir_name)
				
				for file : String in DirAccess.get_files_at(dir.get_current_dir() + "/" + dir_name):
					#print("Found actor: " + file.get_basename())
					actor_names.append(file.get_basename())
					
					var source := dir.get_current_dir() + "/" + dir_name + "/" + file

					if not result.has(stage_names[-1]):
						result[stage_names[-1]] = {}
					result[stage_names[-1]][file.get_basename()] = load_file_check_type(source, "Dialogue", TYPE_DICTIONARY)
			
			dir_name = dir.get_next()
	else:
		print("An error occurred when trying to load the Dialogues.")
		
	_dialogues = result
#endregion
######################################JSON UPGRADES#################################################
#region UPGRADES
var _is_upgrades_loaded : bool = false
var _id_to_upgrade_data : Dictionary = {}

func id_to_upgrade_data(id : int) -> Dictionary:
	if _is_upgrades_loaded:
		return _id_to_upgrade_data.get(id, {})
	printerr("Upgrades not yet loaded!")
	return {}

func load_upgardes() -> void:
	var data : Array = load_file_check_type(UPGRADES_SOURCE, "Upgrade", TYPE_ARRAY)
	
	if data == null:
		return
	
	for dict : Dictionary in data:
		if not (dict.has("id") and dict.has("display_name") and dict.has("description") and dict.has("price")
						and dict.has("state") and dict.has("state_maximum") and dict.has("tilemap_position")):
			printerr("Upgrade-JSON: there is at least one missing entry.")
			continue
		
		var id : int = dict["id"]
		dict.erase("id")
		
		_id_to_upgrade_data[id] = dict
		
		_id_to_upgrade_data[id]["tilemap_position"] = dict_to_vector(dict["tilemap_position"], TYPE_VECTOR2I)
		if _id_to_upgrade_data[id]["tilemap_position"] == null:
			continue
		
		if _id_to_upgrade_data[id].has("spawn_pos"):
			_id_to_upgrade_data[id]["spawn_pos"] = dict_to_vector(dict["spawn_pos"], TYPE_VECTOR2I)
			if _id_to_upgrade_data[id]["spawn_pos"] == null:
				continue
				
		_id_to_upgrade_data[id]["atlas_coord"] = dict_to_vector(dict["atlas_coord"], TYPE_VECTOR2I)
			
	_is_upgrades_loaded = true
#endregion
#########################################JSON UTILS#################################################

func load_file_check_type(source : String, descr : String, type : Variant.Type) -> Variant:
	if not FileAccess.file_exists(source):
		push_error("Could not load " + descr + " from source: " + source)
		return null

	var recipe_source : FileAccess = FileAccess.open(source, FileAccess.READ)
	var json : JSON = JSON.new()
	
	var json_string : String = recipe_source.get_as_text()
	var parse_result : Error = json.parse(json_string)
	if not parse_result == OK:
		push_error(descr + "-JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return null

	var data : Variant = json.get_data()
	
	if not typeof(data) == type:
		push_error("Invalid format of " + descr + "-JSON (" + source + "). Make sure it is in the type of " + str(type))
		return null
	
	return data 

func dict_to_vector(data : Dictionary, type : Variant.Type) -> Variant:
	var x : Variant = data.get("x", NAN)
	var y : Variant = data.get("y", NAN)
	var z : Variant = data.get("z", NAN)
	var w : Variant = data.get("w", NAN)
	
	match type:
		TYPE_VECTOR2:
			if (x != NAN and y != NAN 
			and (typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT)
			and (typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT)):
				return Vector2(x as float, y as float)
		TYPE_VECTOR2I:
			if (x != NAN and y != NAN 
			and (typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT)
			and (typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT)):
				return Vector2i(x as int, y as int)
		TYPE_VECTOR3:
			if (x != NAN and y != NAN and z != NAN
			and (typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT)
			and (typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT)
			and (typeof(z) == TYPE_INT or typeof(z) == TYPE_FLOAT)):
				return Vector3(x as float, y as float, z as float)
		TYPE_VECTOR3I:
			if (x != NAN and y != NAN and z != NAN
			and (typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT)
			and (typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT)
			and (typeof(z) == TYPE_INT or typeof(z) == TYPE_FLOAT)):
				return Vector3i(x as int, y as int, z as int)
		TYPE_VECTOR4:
			if (x != NAN and y != NAN and z != NAN and w != NAN
			and (typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT)
			and (typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT)
			and (typeof(z) == TYPE_INT or typeof(z) == TYPE_FLOAT)
			and (typeof(w) == TYPE_INT or typeof(w) == TYPE_FLOAT)):
				return Vector4(x as float, y as float, z as float, w as float)
		TYPE_VECTOR4I:
			if (x != NAN and y != NAN and z != NAN and w != NAN
			and (typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT)
			and (typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT)
			and (typeof(z) == TYPE_INT or typeof(z) == TYPE_FLOAT)
			and (typeof(w) == TYPE_INT or typeof(w) == TYPE_FLOAT)):
				return Vector4i(x as int, y as int, z as int, w as int)
		_: 
			push_error(str(type) + " is not a Type.")
	push_error("Wrong Type!")
	return null

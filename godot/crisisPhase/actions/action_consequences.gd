extends Node
class_name EMC_ActionConsequences

const NO_PARAM: int = 0

var _rng : RandomNumberGenerator = RandomNumberGenerator.new()
@export var _avatar: EMC_Avatar
var _inventory: EMC_Inventory
@export var _stage_mngr : EMC_StageMngr
@export var _lower_gui_node : Node
@export var _day_mngr : EMC_DayMngr
@export var _gui_mngr: EMC_GUIMngr
@export var _scoreboard: EMC_Scoreboard
var _opt_event_mngr: EMC_OptionalEventMngr

########################################## PUBLIC METHODS ##########################################
func setup(p_inventory: EMC_Inventory, p_opt_event_mngr: EMC_OptionalEventMngr) -> void:
	_inventory = p_inventory
	_opt_event_mngr = p_opt_event_mngr
	_rng.randomize()

############################################ Avatar ################################################

func add_health(p_value: int) -> void:
	_avatar.modify_health_delta(p_value)

func add_hydration(p_value: int) -> void:
	_avatar.modify_drink_delta(p_value)

func add_happiness(p_value: int) -> void:
	_avatar.modify_social_delta(p_value)
	
func make_hungry() -> void:
	_avatar.modify_food_delta(_avatar._food_status*-0.8)
	
func make_thirsty() -> void:
	_avatar.modify_drink_delta(_avatar._drink_status*-0.8)
	
############################################ Action ################################################

func execute_action(action : String) -> void:
	JsonMngr.get_action(action).execute({"result": {}})
	
func progress_day(descr : String) -> void:
	_day_mngr._advance_day_period(descr)
	
############################################ Items #################################################

## Adds the [EMC_Item]
func add_item(p_ID: EMC_Item.IDs) -> void:
	if _inventory.add_new_item(p_ID) == false:
		_gui_mngr.request_gui("TooltipGUI", ["Dein Inventar ist bereits voll und kann keine weiteren Items aufnehmen!"])

func add_item_question(params : Array) -> void:
	var id : int = 0
	if typeof(params[0]) == TYPE_STRING:
		id = JsonMngr.item_name_to_id(params[0] as String)
	elif typeof(params[0]) == TYPE_INT:
		id = params[0] as int
	var item : = EMC_Item.make_from_id(id)
	if _inventory.add_item(item) == false:
		_gui_mngr.request_gui("TooltipGUI", ["Dein Inventar ist bereits voll und kann keine weiteren Items aufnehmen!"])
	else:
		if params.size() >= 1:
			_gui_mngr.queue_gui("ItemQuestionGUI", [item, params[1]])
		else:
			_gui_mngr.queue_gui("ItemQuestionGUI", [item])
	

## Allows multiple items, separated through a semicolon
func add_items_by_name(p_names : String) -> void:
	for item_name in p_names.split(";"):
		if _inventory.add_new_item(JsonMngr.item_name_to_id(item_name)) == false:
			_gui_mngr.request_gui("TooltipGUI", ["Dein Inventar ist bereits voll und kann keine weiteren Items aufnehmen!"])
			break


## Adds either Water depended on the Water-State
func add_tap_water(_dummy: int) -> void:
	match OverworldStatesMngr.get_effective_state_str("WaterState"):
		"CLEAN":
			_inventory.add_new_item(EMC_Item.IDs.WATER)
		"DIRTY":
			_inventory.add_new_item(EMC_Item.IDs.WATER_DIRTY)
		"NONE":
			printerr("Can't add water while there is no water available! \
				This should be checked in the constraints!")
		_: printerr("Unknown Water state!")


## Reduces the uses of the Uses-[EMC_ItemComponent] of the [EMC_Item]
## If it is completely used up, the item is removed from the [EMC_Inventory]
## NOTE: inventory has a method for that now!!
## NOTE: Improvement idea: change parameter type to string, and use JsonMngr.item_name_to_id
## This way, normal actions can be included in the JSON file
func use_item(p_ID: EMC_Item.IDs) -> void:
	_inventory.use_item(p_ID)


func use_item_by_name(p_name: String) -> void:
	_inventory.use_item(JsonMngr.item_name_to_id(p_name))


############################################ Other ################################################
func open_bbk_brochure(_dummy: int = NO_PARAM) -> void:
	EMC_Information.open_bbk_brochure()


func use_radio(_dummy: int = NO_PARAM) -> void:
	var radio_msg: String
	SoundMngr.play_sound("RadioTuning")
	var active_events := _opt_event_mngr.get_active_events()
	if !active_events.is_empty():
		var chosen_event: EMC_OptionalEventMngr.Event = active_events.pick_random()
		radio_msg = chosen_event.descr
		_opt_event_mngr.set_event_as_known(chosen_event.name)
	else:
		#30-70 zwischen unnützem Text und Szenario Name
		#if _rng.randi_range(0, 4) <= 3:
		var notification := OverworldStatesMngr.get_notification()
		print(notification)
		if not notification.is_empty():
			radio_msg = notification.pick_random()
		else:
			radio_msg = "Es läuft mal wieder viel zu laute Werbung..."
		#else:
			#radio_msg = "Es läuft mal wieder viel zu laute Werbung..."
	_gui_mngr.request_gui("TooltipGUI", [radio_msg])


func fill_rainbarrel(_dummy: int = NO_PARAM) -> void:
	var _added_water_quantity : int = _rng.randi_range(1, 6) # in units of 250ml
	OverworldStatesMngr.set_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL, 
		min(OverworldStatesMngr.get_furniture_state_maximum(EMC_Upgrade.IDs.RAINWATER_BARREL), 
		(OverworldStatesMngr.get_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL) + _added_water_quantity)))
		
func fill_reservoir(_dummy : Variant = NO_PARAM) -> void:
	var reservoir : EMC_Upgrade = OverworldStatesMngr.get_upgrade_if_equipped(EMC_Upgrade.IDs.WATER_RESERVOIR)
	reservoir.set_state(reservoir.get_state_maximum())

func remove_from_reservoir(amount : int) -> void:
	var reservoir : EMC_Upgrade = OverworldStatesMngr.get_upgrade_if_equipped(EMC_Upgrade.IDs.WATER_RESERVOIR)
	reservoir.set_state(reservoir.get_state() - amount)

func set_tutorial(value : bool) -> void:
	Global._tutorial_done = value

############################################ GUI ##################################################

func request_gui(args : Dictionary) -> void:
	if args.has("name"):
		if args.get("name") == "Trade":
			_gui_mngr.request_gui("Trade", [_stage_mngr.get_NPC(args.get("args", ""))])
		else:
			_gui_mngr.request_gui(args.get("name"), args.get("args", []))

func queue_gui(args : Dictionary) -> void:
	if args.has("name"):
		match args.get("name"):
			"Trade":
				_gui_mngr.queue_gui("Trade", [_stage_mngr.get_NPC(args.get("args", ""))])
			_:
				_gui_mngr.queue_gui(args.get("name"), args.get("args", []))
				
func overlay_gui(args : Dictionary) -> void:
	if args.has("name"):
		match args.get("name"):
			"Trade":
				_gui_mngr.overlay_gui("Trade", [_stage_mngr.get_NPC(args.get("args", ""))])
			_:
				_gui_mngr.overlay_gui(args.get("name"), args.get("args", []))

########################################## Dialogue ################################################

func trigger_dialogue(p_dialogue : Dictionary) -> void:
	_gui_mngr.request_gui("DialogueGui", [p_dialogue])
	
func set_dialogue_state(args : Dictionary) -> void:
	if args.has_all(["state_name", "value"]):
		OverworldStatesMngr.set_dialogue_state(args["state_name"], args["value"])
	else:
		printerr("Action-Consequence: wrong or missing Argumrnts for 'set_dialogue_state'")

############################################ Score #################################################

func add_score(args: Dictionary) -> void:
	if args.has("name"):
		_scoreboard.add_score(args["name"], args.get("context", {}))
	else:
		printerr("Action-Consequence: wrong or missing Argumrnts for 'add_score'")
		
############################################# NPC ##################################################

func friedel_weg() -> void:
	_stage_mngr.get_NPC("gerhard").get_comp(EMC_NPC_Conversation).run()

func npc_add_dialog_tag(args: Dictionary) -> void:
	if args.has_all(["npc", "tag"]):
		var conv: EMC_NPC_Conversation = _stage_mngr.get_NPC(args["npc"]).get_comp(EMC_NPC_Conversation)
		if conv != null:
			conv.add_tag(args["tag"])
	else:
		printerr("Action-Consequence: wrong or missing Argumrnts for 'npc_add_dialog_tag'")
		
func npc_remove_dialog_tag(args: Dictionary) -> void:
	if args.has_all(["npc", "tag"]):
		var conv: EMC_NPC_Conversation = _stage_mngr.get_NPC(args["npc"]).get_comp(EMC_NPC_Conversation)
		if conv != null:
			conv.remove_tag(args["tag"])
	else:
		printerr("Action-Consequence: wrong or missing Argumrnts for 'npc_remove_dialog_tag'")

func set_quest_stage(args: Dictionary) -> void:
	if args.has_all(["quest", "stage"]):
		OverworldStatesMngr.add_quest(args["quest"], args["stage"])
	else:
		printerr("Action-Consequence: wrong or missing Argumrnts for 'set_quest_stage'")

func remove_quest(args: Dictionary) -> void:
	if args.has("quest"):
		OverworldStatesMngr.remove_quest(args["quest"])
	else:
		printerr("Action-Consequence: wrong or missing Argumrnts for 'remove_quest'")

func npc_change_stage(args: Dictionary) -> void:
	if args.has_all(["npc", "stage", "spot"]):
		var npc: EMC_NPC = _stage_mngr.get_NPC(args["npc"])
		if npc != null:
			var spot: Node2D = _stage_mngr.request_spot(args["spot"])
			npc.change_stage(args["stage"], spot)
	else:
		printerr("Action-Consequence: wrong or missing Arguments for 'npc_change_stage'")

############################################ Stage #################################################

func change_stage(p_data : Dictionary) -> void:
	_stage_mngr.change_stage(p_data.get("stage_name"), p_data.get("wait", true))
	
	# Avatar is moved to early should be handeled in stage or stage_mngr
	if p_data.get("wait", true):
		await _day_mngr.animation_end
	var spot: Node2D = _stage_mngr.request_spot("start")
	_avatar.global_position = spot.global_position
	
func change_stage_by_dict(p_data : Dictionary) -> void:
	_stage_mngr.change_stage(p_data.get("stage_name"), p_data.get("wait", true))
	
	# Avatar is moved to early should be handeled in stage or stage_mngr
	if p_data.get("wait", true):
		await _day_mngr.animation_end
	var spot: Node2D = _stage_mngr.request_spot("start")
	_avatar.global_position = spot.global_position
	# _avatar.position = EMC_Util.dict_to_vector(p_data.get("avatar_pos"), TYPE_VECTOR2)

############################################ JSON ##################################################

## This function converts Dictionarys conatining consequnces with posible Vector or other json incompatible
## Datatypes in to Dictionary with json compatible Datatype
static func to_json(data : Dictionary) -> Dictionary:
	var result : Dictionary = {}
	if data.has("change_stage"):
		result["change_stage"] = {
			"avatar_pos" : {
				"x" : data["change_stage"]["avatar_pos"].x,
				"y" : data["change_stage"]["avatar_pos"].y
			}
		}
		
		result["change_stage"]["npc_pos"] = {}
		
		for npc : String in data["change_stage"]["npc_pos"]:
			result["change_stage"]["npc_pos"][npc] = {
				"x" : data["change_stage"]["npc_pos"][npc].x,
				"y" : data["change_stage"]["npc_pos"][npc].y,
			}
	
	result.merge(data)
	
	return result

## This function converts consequnces in to using more compact json incompatible Datatypes (Vectors)
static func from_json(data : Dictionary) -> Dictionary:
	if data.has("change_stage") and typeof(data["change_stage"]["avatar_pos"]) != TYPE_VECTOR2I:
		var avatar_pos : Dictionary = data["change_stage"].get("avatar_pos", {})
		var x : int = avatar_pos.get("x", NAN)
		var y : int = avatar_pos.get("y", NAN)
		
		var npc_pos : Dictionary = data["change_stage"].get("npc_pos", {})
		
		for npc : String in npc_pos:
			npc_pos[npc] = Vector2(npc_pos[npc]["x"], npc_pos[npc]["y"])
			
		var tmp_data := {
			"avatar_pos": Vector2i(x, y),
			"npc_pos" : npc_pos,
		}
		tmp_data.merge(data["change_stage"])
		data["change_stage"] = tmp_data
	
	return data
	

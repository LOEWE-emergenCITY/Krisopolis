extends Node
class_name EMC_ActionConstraints

const NO_PARAM: int = 0
const NO_REJECTION: String = ""

@export var _day_mngr: EMC_DayMngr
var _inventory: EMC_Inventory
@export var _stage_mngr : EMC_StageMngr


########################################## PUBLIC METHODS ##########################################
func setup(p_inventory: EMC_Inventory) -> void:
	_inventory = p_inventory

func has_quest_stage(args: Dictionary) -> String:
	if args.has_all(["quest", "stage"]):
		if OverworldStatesMngr.has_quest(args["quest"]) and OverworldStatesMngr.get_quest_stage(args["quest"]) == args["stage"]:
			return NO_REJECTION
	return "Rejected"
	
func quest_has_stage(quest: String, stage: String) -> bool:
	return OverworldStatesMngr.has_quest(quest) and OverworldStatesMngr.get_quest_stage(quest) == int(stage)
	
func has_quest(quest: String) -> bool:
	return OverworldStatesMngr.has_quest(quest)
	
func npc_mood_less_than(npc_name: String, mood: String) -> bool:
	var npc: EMC_NPC = _stage_mngr.get_NPC(npc_name.to_lower())
	var karma: EMC_NPC_Karma = npc.get_comp(EMC_NPC_Karma)
	if karma:
		return karma.mood_less_than(EMC_NPC_Karma.string_to_mood.get(mood, "MID"))
	return false

func npc_mood_higher_than(npc_name: String, mood: String) -> bool:
	var npc: EMC_NPC = _stage_mngr.get_NPC(npc_name.to_lower())
	var karma: EMC_NPC_Karma = npc.get_comp(EMC_NPC_Karma)
	if karma:
		return karma.mood_greater_than(EMC_NPC_Karma.string_to_mood.get(mood, "MID"))
	return false
	
func npc_mood_equal(npc_name: String, mood: String) -> bool:
	var npc: EMC_NPC = _stage_mngr.get_NPC(npc_name.to_lower())
	var karma: EMC_NPC_Karma = npc.get_comp(EMC_NPC_Karma)
	if karma:
		return karma.get_mood() == (EMC_NPC_Karma.string_to_mood.get(mood, "MID"))
	return false
	
func npc_karma_higher_than(npc_name: String, value: String) -> bool:
	var npc: EMC_NPC = _stage_mngr.get_NPC(npc_name.to_lower())
	var karma: EMC_NPC_Karma = npc.get_comp(EMC_NPC_Karma)
	if karma:
		return karma.get_krama() > float(value)
	return false
	
func npc_karma_less_than(npc_name: String, value: String) -> bool:
	var npc: EMC_NPC = _stage_mngr.get_NPC(npc_name.to_lower())
	var karma: EMC_NPC_Karma = npc.get_comp(EMC_NPC_Karma)
	if karma:
		return karma.get_krama() < float(value)
	return false
	
func npc_has_comp(args : Dictionary) -> String:
	if args.has_all(["npc", "comp"]):
		if _stage_mngr.get_NPC(args["npc"]).get_comp_by_name(args["comp"]) != null:
			return NO_REJECTION
	return "Rejected"

func npc_has_dialog_tag(args: Dictionary) -> String:
	if args.has_all(["npc", "tag"]):
		var conv: EMC_NPC_Conversation = _stage_mngr.get_NPC(args["npc"]).get_comp(EMC_NPC_Conversation)
		if conv != null and conv.has_tag(args["tag"]):
			return NO_REJECTION
	return "Rejected"

func is_dialogue_state(args : Dictionary) -> String:
	if args.has_all(["state_name", "value"]) and OverworldStatesMngr.is_dialogue_state(args["state_name"], args["value"]):
		return NO_REJECTION
	return "State not Set"

func has_water_reservoir_water(_dummy : Variant) -> String:
	if OverworldStatesMngr.get_furniture_state(EMC_Upgrade.IDs.WATER_RESERVOIR) <= 0:
		return "Das Wasser Reservoir is leer."
	return NO_REJECTION

func upgrade_state_greater(id: int, value: int) -> bool:
	return OverworldStatesMngr.get_furniture_state(id) > value
	
func upgrade_state_smaller(id: int, value: int) -> bool:
	return OverworldStatesMngr.get_furniture_state(id) < value
	
func upgrade_state_equal(id: int, value: int) -> bool:
	return OverworldStatesMngr.get_furniture_state(id) == value

func has_upgrade(args : Dictionary) -> bool:
	return args.has("id") and OverworldStatesMngr.has_upgrade(args["id"])

func constraint_rainwater_barrel(_dummy_param: Variant) -> String:
	if OverworldStatesMngr.get_furniture_state(EMC_Upgrade.IDs.RAINWATER_BARREL) == 0:
		return "Die Regentonne ist leer"
	else:
		return NO_REJECTION

func random_bool(prob: float) -> bool:
	return EMC_Util.pick_weighted_random([true, false], [prob, 1-prob], 1)[0]

func constraint_not_morning(p_reason: String = "") -> String:
	if _day_mngr.get_current_day_period() == EMC_DayMngr.DayPeriod.MORNING:
		var reason := "Man kann diese Aktion nicht morgens ausführen!" if p_reason == "" else p_reason 
		return reason 
	else:
		return NO_REJECTION


func constraint_not_noon(p_reason: String = "") -> String:
	if _day_mngr.get_current_day_period() == EMC_DayMngr.DayPeriod.NOON:
		var reason := "Man kann diese Aktion nicht mittags ausführen!" if p_reason == "" else p_reason 
		return reason 
	else:
		return NO_REJECTION


func constraint_not_evening(p_reason: String = "") -> String:
	if _day_mngr.get_current_day_period() == EMC_DayMngr.DayPeriod.EVENING:
		var reason := "Man kann diese Aktion nicht abends ausführen!" if p_reason == "" else p_reason 
		return reason 
	else:
		return NO_REJECTION
		
func not_evening() -> bool:
	return not _day_mngr.get_current_day_period() == EMC_DayMngr.DayPeriod.EVENING

func is_state_by_name(args: Dictionary) -> String:
	if args.has("state") and OverworldStatesMngr.is_effective_state_eq(args["state"].get_basename(), args["state"].get_extension()):
		return NO_REJECTION
	return "State Bad"

func is_state_by_name_str(state: String) -> bool:
	return OverworldStatesMngr.is_effective_state_eq(state.get_basename(), state.get_extension())

func constraint_no_limited_public_access(p_reason: String = "") -> String:
	if OverworldStatesMngr.has_all_flag("NoEntry", ["Market", "Townhall"]):
		var reason := "Es herrscht momentan ein Betretugsverbot öffentlicher Gelände!" if p_reason == "" else p_reason 
		return reason 
	else:
		return NO_REJECTION

func constraint_has_item(p_ID: EMC_Item.IDs) -> String:
	if _inventory.has_item(p_ID):
		return NO_REJECTION
	else:
		var item := EMC_Item.make_from_id(p_ID)
		return "Du brauchst " + item.get_item_name() + " dafür!"
		
func has_item(item_name: String) -> bool:
	return _inventory.has_item(JsonMngr.item_name_to_id(item_name))
	
func has_item_by_name(p_name : String) -> String:
	var id : int = JsonMngr.item_name_to_id(p_name)
	if _inventory.has_item(id):
		return NO_REJECTION
	else:
		var item := EMC_Item.make_from_id(id)
		return "Du brauchst " + item.get_item_name() + " dafür!"


func avatar_is_home(p_reason : String = "") -> String:
	if _stage_mngr.get_curr_stage_name() == "home":
		return NO_REJECTION
	else:
		return "Der Avatar ist moment nicht zu Hause" if p_reason == "" else p_reason


func avatar_is_on_stage(stage_name : String = "") -> String:
	if _stage_mngr.get_curr_stage_name() == stage_name:
		return NO_REJECTION
	else:
		return "Du bist nicht " + stage_name + "!"
		
func is_current_stage(stage_name: String) -> bool:
	return _stage_mngr.get_curr_stage_name() == stage_name


func is_scenario(p_scenario_names: String = "") -> String:
	for scenario_name in p_scenario_names.split(";"):
		if scenario_name in OverworldStatesMngr.cenario_names():
			return NO_REJECTION
	
	return "Nicht passendes Szenario!"


func is_not_scenario(p_scenario_names: String = "") -> String:
	for scenario_name in p_scenario_names.split(";"):
		if scenario_name in OverworldStatesMngr.get_scenario_names():
			return "Aktuelles Szenario nicht erlaubt!"
	
	return NO_REJECTION

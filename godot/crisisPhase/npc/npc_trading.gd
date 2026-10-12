extends EMC_NPC_Interaction
class_name EMC_NPC_Trading

const RED: Color = Color8(219, 6, 11)
const ORANGE: Color = Color8(232, 96, 28)
const YELLOW: Color = Color8(247, 240, 87)
const GREEN: Color = Color8(77, 178, 100)
const DARK_GREEN: Color = Color8(36, 111, 64)

@export var _inventory: EMC_Inventory = EMC_Inventory.new()
@export var _item_preference: Dictionary
#@export var _tips: Array[String]
#@export var _tip_ratio: int
@export var _response: Dictionary
@export var _bottom: float = -0.6
@export var _low: float = -0.3
@export var _mid: float = 0.0
@export var _high: float = 0.3
@export var _top: float = 0.6

@export var _karma_weight: float = 0.5
@export var _value_weight: float = 1.0
#@export var _decision_noise: float = 0.0

#var _resp_bottom: Array[String]
#var _resp_top: Array[String]
#var _resp_low: Array[String]
#var _resp_mid: Array[String]
#var _resp_high: Array[String]

func setup(dict: Dictionary) -> void:
	var _initial_inventory: Dictionary = dict.get("inventory", {})
	
	_inventory = EMC_Inventory.new(18)
	for item_name : String in _initial_inventory.keys():
		for i : int in range(_initial_inventory[item_name] as int):
			_inventory.add_new_item(JsonMngr.item_name_to_id(item_name))
	
	_item_preference = dict.get("preferences", {})
	
	_response = dict.get("response", {})
	#_resp_bottom.assign(_response.get("bottom", []))
	#_resp_top.assign(_response.get("top", []))
	#_resp_low.assign(_response.get("low", []))
	#_resp_mid.assign(_response.get("mid", []))
	#_resp_high.assign(_response.get("high", []))
	
	#_tips.assign(dict.get("tip", []))
	#_tip_ratio = (dict.get("tip_ratio", 5))
	
	_bottom = dict.get("bottom", _bottom)
	_low = dict.get("low", _low)
	_mid = dict.get("mid", _mid)
	_high = dict.get("high", _high)
	_top = dict.get("top", _top)
	
	_karma_weight = dict.get("karma_weight", _karma_weight)
	_value_weight = dict.get("value_weight", _value_weight)
	#_decision_noise = dict.get("noise", 0.0)

var owner: EMC_NPC = null

func set_owner(_owner: EMC_NPC) -> void:
	owner = _owner

func get_title() -> String:
	return "Handeln"
	
func get_style_name() -> String:
	return "BlueButton"

func run(gsi: EMC_GSI) -> void:
	gsi.request_gui("Trade", [owner])

func get_inventory() -> EMC_Inventory:
	return _inventory

func has_item(item_name: String, count: int = 1) -> bool:
	return _inventory.has_item(JsonMngr.item_name_to_id(item_name), count)
	
func remove_item(item_name: String, count: int = 1) -> int:
	return _inventory.remove_item_by_id(JsonMngr.item_name_to_id(item_name), count)

func add_item(item_name: String, count: int = 1) -> void:
	for i in range(count+1):
		_inventory.add_new_item(JsonMngr.item_name_to_id(item_name))

func calulate_item_score_generic(items : Array[EMC_Item]) -> float:
	return items.reduce(
		func (accum : int, item : EMC_Item) -> int:
			var value_comp := item.get_comp(EMC_IC_Cost)
			accum += _item_preference.get(JsonMngr.item_id_to_name(item.get_id()), 1) * (value_comp.get_cost() if value_comp != null else 1)
			return accum, 0)

func calculate_trade_score(sell_items : Array[EMC_Item], buy_items : Array[EMC_Item]) -> float:
	var _karma_comp: EMC_NPC_Karma = owner.npc_resource.get_comp(EMC_NPC_Karma)
	
	var sell_value := calulate_item_score_generic(sell_items)
	var buy_value := calulate_item_score_generic(buy_items)
	
	print(sell_value)
	print(buy_value)
	
	if sell_value == 0 and buy_value == 0:
		return -1.0
	
	var trade_score := (sell_value - buy_value) / maxf(sell_value, buy_value)
	#print("Without Karma: " + str(trade_score))
	trade_score = trade_score * _value_weight + _karma_comp.get_krama() * _karma_weight
	#print("With Karma: " + str(trade_score))
	return trade_score
	
func get_mood_texture(trade_score: float, mood_texture: AtlasTexture) -> Texture2D:
	var _karma_comp: EMC_NPC_Karma = owner.npc_resource.get_comp(EMC_NPC_Karma)
	trade_score = trade_score / _value_weight - _karma_comp.get_krama() * _karma_weight
	if trade_score < _bottom:
		mood_texture.set_region(Rect2(256, 0, 64, 64))
	elif trade_score < _low:
		mood_texture.set_region(Rect2(192, 0, 64, 64))
	elif trade_score < _mid:
		mood_texture.set_region(Rect2(128, 0, 64, 64))
	elif trade_score < _high:
		mood_texture.set_region(Rect2(64, 0, 64, 64))
	else:
		mood_texture.set_region(Rect2(0, 0, 64, 64))
		
	return mood_texture
	
func get_response(item: EMC_Item) -> String:
	var list: Array[String] = ["Interessant"]
	var base: Array[String]
	base.assign(_response.get("BASE", ["Hmm mal Schaun"]))
	var item_name: String = JsonMngr.item_id_to_name(item.get_id())
	
	if _item_preference.has(item_name):
		list.append("Oh das Items gefällt mir.")
		if _item_preference.get(item_name) >= 2:
			list.append("Ich mag " + item.name + " sehr.")
			
	if _response.has(item_name):
		list.append_array(_response[item_name])

	if item.get_comp(EMC_IC_Food):
		list.append_array(_response.get("FOOD", []))
		
	if item.get_comp(EMC_IC_Drink):
		list.append_array(_response.get("DRINK", []))
		
	if item.get_comp(EMC_IC_Unpalatable):
		list.append_array(_response.get("UNPALATABLE", []))
	
	#var value_comp := item.get_comp(EMC_IC_Value)
	#if (value_comp.get_value() if value_comp != null else 1) > 1:
		#list.append("Oh diese Item ist recht wertvoll")
		
	return [list, base].pick_random().pick_random()
		
func will_deal(trade_score: float) -> bool:
	if (trade_score >= _low):
		return false
	else:
		return true

func get_deal_color(trade_score: float) -> Color:
	if trade_score < _bottom:
		return RED
	elif trade_score < _low:
		return ORANGE
	elif trade_score < _mid:
		return YELLOW
	elif trade_score < _high:
		return GREEN
	return DARK_GREEN

func deal(trade_score: float) -> void:
	var _karma_comp: EMC_NPC_Karma = owner.npc_resource.get_comp(EMC_NPC_Karma)
	trade_score = trade_score / _value_weight - _karma_comp.get_krama() * _karma_weight
	if trade_score < _bottom:
		_karma_comp.add_karma(-0.6)
	elif trade_score < _low:
		_karma_comp.add_karma(-0.3)
	elif trade_score < _mid:
		_karma_comp.add_karma(-0.1)
	elif trade_score < _high:
		_karma_comp.add_karma(0.1)
	elif trade_score < _top:
		_karma_comp.add_karma(0.3)
	else:
		_karma_comp.add_karma(0.4)

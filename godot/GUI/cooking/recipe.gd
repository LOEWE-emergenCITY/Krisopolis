extends Resource
class_name EMC_Recipe

@export var _input_item_IDs: Array[EMC_Item.IDs]
@export var _output_item_ID: EMC_Item.IDs

@export var _needs_water : bool
@export var _needs_heat : bool

var _ingredient_available: Array[Dictionary]

enum Heat{
	available,
	needs_gas,
	unavailable
}

enum Result{
	cookable,
	missing_heat,
	missing_water,
	missing_ingredient
}

func setup(p_inputItemIDs : Array[EMC_Item.IDs], p_outputItemID: EMC_Item.IDs, p_needs_water : bool, \
p_needs_heat : bool) -> void:
	_input_item_IDs = p_inputItemIDs
	_output_item_ID = p_outputItemID
	_needs_water = p_needs_water
	_needs_heat = p_needs_heat

## WARNING: Very inefficent
func cook(_inventory: EMC_Inventory) -> EMC_Item:
	for entry in _ingredient_available:
		var filter := EMC_Util.combine_filters(EMC_Inventory.filter_id(entry.item_id), EMC_Inventory.filter_not_comp(EMC_IC_Unpalatable))
		var item: EMC_Item = _inventory.get_items_filterd(filter)[0]
		if item.has_comp(EMC_IC_Uses):
			_inventory.use_item(item.get_id())
		else:
			_inventory.remove_item(item)
	return EMC_Item.new().setup(_output_item_ID)
	
## check_cookable should be called before this
func get_ingredient_feasibility() -> Array[Dictionary]:
	return _ingredient_available

func check_cookable(_inventory: EMC_Inventory, water_state: bool, heat_state: Heat) -> Result:
	_ingredient_available.clear()
	
	var ingredient_count: Dictionary[int, int] = {}
	for item in _input_item_IDs:
		ingredient_count[item] = ingredient_count.get(item, 0) + 1
	
	var result: Result = Result.cookable
	
	for item_id: EMC_Item.IDs in ingredient_count.keys():
		var filter := EMC_Util.combine_filters(EMC_Inventory.filter_id(item_id), EMC_Inventory.filter_not_comp(EMC_IC_Unpalatable))
		var diff: int = _inventory.get_items_filterd(filter).size() - ingredient_count[item_id]
		for i in ingredient_count[item_id]:
			_ingredient_available.append({"item_id": item_id, "block": bool(diff-i < 0)})
		
		if diff < 0:
			result = Result.missing_ingredient
	
	if result != Result.cookable:
		return result
	
	if not water_state and needs_water():
		if _inventory.has_item(EMC_Item.IDs.WATER):
			_ingredient_available.append({"item_id": EMC_Item.IDs.WATER, "block": false})
		else:
			_ingredient_available.append({"item_id": EMC_Item.IDs.WATER, "block": true})
			return Result.missing_water
			
	if needs_heat():
		match heat_state:
			Heat.available:
				return Result.cookable
			Heat.needs_gas:
				if _inventory.has_item(EMC_Item.IDs.GAS_CARTRIDGE):
					_ingredient_available.append({"item_id": EMC_Item.IDs.GAS_CARTRIDGE, "block": false})
				else:
					_ingredient_available.append({"item_id": EMC_Item.IDs.GAS_CARTRIDGE, "block": true})
					return Result.missing_ingredient
			Heat.unavailable:
				return Result.missing_heat
	
	return Result.cookable

func get_input_item_IDs() -> Array[EMC_Item.IDs]:
	return _input_item_IDs

func get_output_item_ID() -> EMC_Item.IDs:
	return _output_item_ID

func needs_water() -> bool:
	return _needs_water

func needs_heat() -> bool:
	return _needs_heat

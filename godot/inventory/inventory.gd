@tool
extends Resource
## An Inventory (z.B. Backpack of the player, Shelf, etc..)
## To display an inventory you can use [EMC_InventoryGUI].
##
## You can manage the contents of this inventory through its public methods
class_name EMC_Inventory

## For the communication with its according GUI
signal item_added(p_item: EMC_Item, p_idx: int)
## For the communication with its according GUI
signal item_removed(p_item: EMC_Item, p_idx: int)

signal update

@export var num_slots : int = 30
@export var slots: Array[EMC_Item]

#var _num_items : int = 0

########################################## PUBLIC METHODS ##########################################
func _init(p_num_slots: int = 30) -> void:
	num_slots = p_num_slots

func get_free_num_slot() -> int:
	return num_slots - slots.size()

func is_empty() -> bool:
	return slots.is_empty()

## Returns if the inventory has any free slots left
func has_space() -> bool:
	return slots.size() < num_slots

## Returns total count of [EMC_Item]s in inventory
func get_num_item() -> int:
	return slots.size()

## Instantiates an new [EMC_Item] Scene and adds it to this inventory.
## Returns true, if the item was added, else false
func add_new_item(p_ID: EMC_Item.IDs) -> bool:
	var new_item: EMC_Item = EMC_Item.make_from_id(p_ID)
	return add_item(new_item)

## Add an already instantiated [EMC_Item] Scene to this inventory.
## This is used if a [EMC_Item] has additional components like durability,
## which should be remembered.
## Returns true, if the item was added, else false
func add_item(p_item: EMC_Item) -> bool:
	if p_item == null or slots.size() >= num_slots: return false
	slots.append(p_item)
	update.emit()
	sort()
	return true

func clear_items() -> void:
	slots.clear()

## Remove a concrete [EMC_Item] from this inventory
## Returns if the removal was successful
func remove_item(p_item: EMC_Item) -> bool:
	var idx := slots.find(p_item)
	if idx < 0: return false
	slots.remove_at(idx)
	update.emit()
	sort()
	return true

func remove_item_by_id(p_id: int, p_count : int = 1) -> int:
	var count : int = 0
	for item : EMC_Item in get_items_filterd(filter_id(p_id)).slice(0, p_count):
		if remove_item(item):
			count += 1
	return count

## Returns item at [p_slot_idx] if available,
## else returns null
## THIS METHOD SHOULD PRIMARILY BE USED BY [EMC_InventoryGUI]!
## Use get_item_of_ID() instead
## Code Review: Method necessary for EMC_InventoryGUI.setup()
func get_item_of_slot(idx: int) -> EMC_Item:
	if (idx < 0 || idx >= slots.size()):
		printerr("Accessing invalid index# inventory_v2.gd")
		return null
	return slots[idx]

func get_items_of_id(p_ID: EMC_Item.IDs, sorter : Callable = sort_by_id) -> Array[EMC_Item]:
	return get_items_filterd_sorted(filter_id(p_ID), sorter)

func get_items_filterd_sorted(filter : Callable, sorter : Callable) -> Array[EMC_Item]:
	var filterd := slots.filter(filter)
	filterd.sort_custom(sorter)
	return filterd

func get_items_filterd(filter : Callable) -> Array[EMC_Item]:
	var result: Array[EMC_Item]
	result.assign(slots.filter(filter))
	return result

## The inventory has at least one item of [p_ID]
func has_item(p_ID: EMC_Item.IDs, p_times: int = 1) -> bool:
	return get_num_item_id(p_ID) >= p_times

## Returns count of [EMC_Item]s of [p_ID]
func get_num_item_id(p_ID: EMC_Item.IDs) -> int:
	return slots.filter(func(item : EMC_Item) -> bool: return item.get_id() == p_ID).size()

func get_items() -> Array[EMC_Item]:
	return slots

func get_at_or_dummy(idx : int) -> EMC_Item:
	if idx >= slots.size():
		return EMC_Item.new()
	return slots[idx]

func get_items_or_dummy() -> Array[EMC_Item]:
	var result : Array[EMC_Item] = []
	for idx in range(num_slots):
		result.append(get_at_or_dummy(idx))
	return result

## Return all items as Array of [EMC_Item]s
func get_dup_items() -> Array[EMC_Item]:
	var result : Array[EMC_Item] = []
	for item: EMC_Item in slots:
		result.append(EMC_Item.make_from_id(item.get_id()))
	return result

func get_items_as_name() -> Array[String]:
	var items: Array[String] = []
	
	for item: EMC_Item in slots:
		if item != null:
			items.push_back(JsonMngr.item_id_to_name(item.get_id()))
	return items
	
func get_items_as_id() -> Array[int]:
	var items: Array[int] = []
	
	for item: EMC_Item in slots:
		if item != null:
			items.push_back(item.get_id())
	return items

func get_items_count() -> Dictionary:
	var result: Dictionary = {}
	for item: EMC_Item in slots:
		if item != null:
			var name: String = JsonMngr.item_id_to_name(item.get_id())
			if result.has(name):
				result[name] += 1
			else:
				result[name] = 1
	return result

## Spoil some items
func spoil_some_items() -> void:
	for item in get_items_filterd(filter_comp(EMC_IC_Shelflife)):
		if randi_range(0, 2) <= 0:
			item.remove_comp(EMC_IC_Shelflife)
			item.add_comp(EMC_IC_Unpalatable.new(2))

## Returns copy of all item IDs ([EMC_Item.IDs]) and empty spaces as [EMC_Item.IDs.DUMMY]
func get_slots_as_id() -> Array[int]:
	var items : Array[int] = []
	for item: EMC_Item in slots:
		items.push_back(item.get_id() if item != null else EMC_Item.IDs.DUMMY)
	return items


## Try to use a usable item = An item that has the [EMC_ItemComponent] [IC_uses]
## If it is used up, remove it
## If the usage was successful return true, otherwise false
func use_item(p_ID: EMC_Item.IDs) -> bool:
	var item : EMC_Item = get_items_filterd_sorted(filter_id(p_ID), sort_uses).front()
	
	var IC_uses := item.get_comp(EMC_IC_Uses)
	if IC_uses == null:
		return false
	
	IC_uses.use_item()
	if IC_uses.no_uses_left():
		remove_item(item)
	return true

func filter_items(f : Callable) -> Array[EMC_Item]:
	return slots.filter(f)
	
static func filter_ids(list : Array) -> Callable:
	return func (item : EMC_Item) -> bool:
		return item != null and item.get_id() in list

static func filter_id(id : int) -> Callable:
	return func (item : EMC_Item) -> bool:
		return item != null and item.get_id() == id
		
static func filter_comp(comp : Variant) -> Callable:
	return func (item : EMC_Item) -> bool:
		return item != null and item.has_comp(comp)
		
static func filter_not_comp(comp : Variant) -> Callable:
	return func (item : EMC_Item) -> bool:
		return item != null and not item.has_comp(comp)

static func sort_by_id_exclusive(items : Array[EMC_Item]) -> Callable:
	return func(a : EMC_Item, b : EMC_Item) -> bool:
		if a.get_id() == 0:
			return false
		if b.get_id() == 0:
			return true
		if a in items:
			if not b in items:
				return true
		elif b in items:
			return false
		return a.get_id() < b.get_id()

static func sort_unpatable(a : EMC_Item, b : EMC_Item) -> bool:
	if a == null:
		return false
	if b == null:
		return true
	if not a.has_comp(EMC_IC_Unpalatable):
		return true
	return false
	
static func sort_uses(a : EMC_Item, b : EMC_Item) -> bool:
	if a == null:
		return false
	if b == null:
		return true
	var comp_a := a.get_comp(EMC_IC_Uses)
	if comp_a == null:
		return false
	var comp_b := b.get_comp(EMC_IC_Uses)
	if comp_b == null:
		return true
	return comp_a.get_uses_left() < comp_b.get_uses_left()

static func sort_by_id(a : EMC_Item, b : EMC_Item) -> bool:
	if a == null:
		return false
	if b == null:
		return true
	return a.get_id() < b.get_id()
	
#static func inventory_from_dict(dict: Dictionary) -> EMC_Inventory:
	#var inventory := EMC_Inventory.new()
	#for item_dict : Dictionary in dict:
		#inventory.add_item(EMC_Item.from_save(item_dict))
	#
	#inventory.sort()
	#return inventory

########################################## PRIVATE METHODS #########################################
func sort_custom(f : Callable) -> void:
	slots.sort_custom(f)

##TODO
func sort() -> void: #Man könnte ein enum als Parameter ergänzen, nach was sortiert werden soll
	sort_custom(sort_by_id)

func _on_day_mngr_day_ended(p_curr_day: int) -> void:
	## Update shelflives:
	for item: EMC_Item in get_items_filterd(filter_comp(EMC_IC_Shelflife)):
		var IC_shelflife : EMC_IC_Shelflife = item.get_comp(EMC_IC_Shelflife)
		IC_shelflife.reduce_shelflife()
		# When an items spoils, replace the shelflive component with an unpalatable component
		if IC_shelflife.is_spoiled():
			item.remove_comp(EMC_IC_Shelflife)
			item.add_comp(EMC_IC_Unpalatable.new(1))

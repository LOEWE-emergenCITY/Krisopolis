@tool
extends Resource
class_name EMC_Item

##Better use: JsonMngr.item_name_to_id(<string from item_ids.json>)
enum IDs{
	DUMMY = 0,
	WATER = 1,
	WATER_DIRTY = 2,
	RAVIOLI_TIN = 3,
	GAS_CARTRIDGE = 4,
	RAVIOLI_MEAL = 5,
	UNCOOKED_PASTA = 6,
	COOKED_PASTA = 7,
	SAUCE_JAR = 8,
	PASTA_WITH_SAUCE = 9,
	BREAD = 10,
	JAM = 11,
	BREAD_WITH_JAM = 12,
	CHLOR_TABLETS = 13,
 	FLOUR = 14,
	SALT = 15,
	SUGAR = 16, 
	RICE = 17,
	PULSES = 18,
	FISH = 19,
	POTATOES = 20,
	VEGETABLES = 21,
	FRUITS = 22,
	CHOCOLATE = 23,
	MEAT = 24,
	TOFU = 25,
	NUTS = 26,
	CHEESE = 27,
	MILK = 28,
	BOLOGNESE = 29,
	JUICE = 30,
	SALTED_FISH = 31,
	PICKLED_VEGETABLES = 32,
	RICE_WITH_VEGETABLES = 33,
	CURRY_WITH_RICE = 34,
	HUMMUS_WITH_BREAD = 35,
	CHEESE_SANDWICH = 36,
	HOT_CHOCOLATE = 37,
	GOULASH = 38,
	MILK_RICE = 39,
	SOUP = 40,
	BATTERIES = 41,
	SOAP = 42,
}

const HIGHLIGHTED_COLOR := Color(0.4, 0.4, 0.4)
const DEFAULT_COLOR := Color(1, 1, 1)

#FYI: Inherits "name" property from Node
@export var id: int = 0
@export var name: String = "Dummy"
@export var descr: String = "No Descr"
@export var comps: Array[EMC_ItemComponent] = []
@export var sound_effect : Dictionary = { 
	"clicked" : "BasicItem",
	"consumed" : "",
	}
@export var texture: AtlasTexture = preload("res://resources/Items/item_atlas.tres")
@export var dimensions: Array[Array] = [[1, 1]]

########################################## PUBLIC METHODS ##########################################
func _init() -> void:
	texture = AtlasTexture.new()
	texture.set_atlas(load("res://assets/items.png"))
	load_texture()

##Initialize properties
func setup(p_id : int) -> EMC_Item:
	#await ready
	id = p_id
	var data : Dictionary = JsonMngr.get_item_vars_from_id(p_id)
	
	name = data.get("name", "Dummy")
	descr = data.get("descr", "Error: Someone tempered with the JsonMngr.")
	sound_effect = data.get("sound", sound_effect)
	var comps_data : Dictionary = data.get("comps", {})
	for comp_name: String in comps_data:
		var comp := EMC_ItemComponent.from_dict(comp_name, comps_data[comp_name])
		comps.append(comp)
	
	#comps.assign(tmp_comps.map(func (comp_data : Dictionary) -> EMC_ItemComponent : return  EMC_ItemComponent.from_dict(comp_data)))

	load_texture()
	return self

func load_texture() -> void:
	const ITEM_ICON_WIDTH := 64
	const ITEM_PNG_COLS = 10
	var x_offset: int = (id % ITEM_PNG_COLS) * ITEM_ICON_WIDTH
	var y_offset: int = (floor(id / ITEM_PNG_COLS)) * ITEM_ICON_WIDTH
	texture.set_region(Rect2(x_offset, y_offset, ITEM_ICON_WIDTH, ITEM_ICON_WIDTH))

func get_texture() -> AtlasTexture:
	load_texture()
	return texture

func get_item_name() -> String:
	return name

##Getter for _ID
func get_id() -> IDs:
	return id

func is_dummy() -> bool:
	return id == IDs.DUMMY
##Getter for _descr
func get_descr() -> String:
	return descr

##Getter for _comps
func get_comps() -> Array[EMC_ItemComponent]:
	return comps

## Getter for concrete [EMC_ItemComponent]
## If no component of that type could be found, null is returned instead.
func get_comp(p_classname: Variant) -> EMC_ItemComponent:
	for comp : EMC_ItemComponent in comps:
		if is_instance_of(comp, p_classname):
			return comp
	return null
	
func has_comp(p_classname: Variant) -> bool:
	for comp : EMC_ItemComponent in comps:
		if is_instance_of(comp, p_classname):
			return true
	return false

func get_all_comps_of(p_classname: Variant) -> Array[EMC_ItemComponent]:
	var result : Array[EMC_ItemComponent] = []
	for comp : EMC_ItemComponent in comps:
		if is_instance_of(comp, p_classname):
			result.append(comp)
	return result

## Ability to add components
func add_comp(p_comp: EMC_ItemComponent) -> void:
	comps.push_back(p_comp)

## Ability to remove components
func remove_comp(p_classname: Variant) -> void:
	var comp_to_be_removed := get_comp(p_classname)
	comps.erase(comp_to_be_removed)

## This Method returns all infomation the Item in form of a Dictionary
func to_dict() -> Dictionary:
	var dict_comps := []
	
	for comp in comps:
		dict_comps.append(comp.to_dict())
	
	var data : Dictionary = {
		"ID": id,
		"name" : name,
		"descr" : descr,
		"sound": sound_effect,
		"comps": dict_comps,
	}
	
	return data


## This Method returns relevant infomation of the Item in form of a Dictionary.
## Relevant information includes:
## - ID
## - comps
func to_save() -> Dictionary:
	var dict_comps := []
	
	for comp in comps:
		dict_comps.append(comp.to_dict())
	
	var data : Dictionary = {
		"ID": id,
		"comps": dict_comps,
	}
	
	return data


### Returns a new Item constructed out of a Dictionary containing all information of the Item
#static func from_dict(data : Dictionary) -> EMC_Item:
	#var item : EMC_Item = EMC_Item.new()
	#item.id = data.get("ID", 0)
	#item.name = data.get("name", "Dummy")
	#item.descr = data.get("descr", "Error")
	#item.sound_effect = data.get("sound", item.sound_effect)
	#var tmp_comps : Array = data.get("comps", [])
	#item.comps.assign(tmp_comps.map(func (data : Dictionary) -> EMC_ItemComponent : return  EMC_ItemComponent.from_dict(data)))
	#
	#return item
#
#
### Returns a new Item constructed out of a Dictionary containing relevant information of the Item.
### For this to work JsonMngr must already have loaded all Items.
### Relevant Infromation is:
### - ID
### - comps
#static func from_save(data : Dictionary) -> EMC_Item:
	#var item : EMC_Item = EMC_Item.new()
	#
	#item.id = data.get("ID", 0)
	#
	#var default_info : Dictionary = JsonMngr.get_item_vars_from_id(item.id)
	#
	#item.name = default_info.get("name", "Dummy")
	#item.descr = default_info.get("descr", "Error: Someone tempered with the JsonMngr.")
	#item.sound_effect = default_info.get("sound", item.sound_effect)
	#var tmp_comps : Array = data.get("comps", default_info.get("comps", []))
	#item.comps.assign(tmp_comps.map(func (data : Dictionary) -> EMC_ItemComponent : return EMC_ItemComponent.from_dict(data)))
	#
	#return item
	
static func make_from_id(item_id : int) -> EMC_Item:
	var item : EMC_Item = EMC_Item.new()
	item.setup(item_id)
	return item

func consumed_sound() -> void:
	SoundMngr.play_sound(sound_effect["consumed"])

func clicked_sound(pitch : float = 1) -> void:
	SoundMngr.play_sound(sound_effect["clicked"], 0, pitch)

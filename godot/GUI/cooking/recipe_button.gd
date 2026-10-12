
extends Button
class_name EMC_Recipe_Button

const ITEM_SLOT = preload("uid://cfk7h3ji5pkne")

signal recipe_pressed(recipe: EMC_Recipe)
signal recipe_disabled_pressed(recipe: EMC_Recipe)

@export var recipe: EMC_Recipe
@export var _gui_mngr: EMC_GUIMngr

@onready var ingredients: HBoxContainer = $Margin/Ingredients
@onready var output: EMC_Item_Slot = $Margin/HBC/Output
@onready var title: Label = $Margin/HBC/title
#@onready var title_2: Label = $Margin/HBC/title2

func _ready() -> void:
	show_ingredients()
	
## This loads and show ingredients adding them to the scene tree
## Should only be called when node is ready
func show_ingredients() -> void:
	for child in ingredients.get_children():
		ingredients.remove_child(child)
		child.queue_free()
	
	for item_id: int in recipe.get_input_item_IDs():
		var item_slot: EMC_Item_Slot = ITEM_SLOT.instantiate()
		ingredients.add_child(item_slot)
		item_slot.set_custom_minimum_size(Vector2(32.0, 32.0))
		item_slot.set_size(Vector2(32.0, 32.0))
		item_slot.set_item(EMC_Item.new().setup(item_id))
		item_slot.item_long_pressed.connect(_on_item_long_pressed)
	
	var item: EMC_Item = EMC_Item.new().setup(recipe.get_output_item_ID())
	output.set_item(item)
	title.set_text(item.get_item_name())
	#title_2.set_text(item.get_item_name())

func check_feasibility(_inventory: EMC_Inventory, water_state: bool, heat_state: EMC_Recipe.Heat) -> bool:
	self.set_disabled(false)
	
	for child in ingredients.get_children():
		ingredients.remove_child(child)
		child.queue_free()
	
	if recipe.check_cookable(_inventory, water_state, heat_state) == EMC_Recipe.Result.missing_heat:
		self.set_disabled(true)
		
	
	for feasi: Dictionary in recipe.get_ingredient_feasibility():
		var item_slot: EMC_Item_Slot = ITEM_SLOT.instantiate()
		ingredients.add_child(item_slot)
		item_slot.set_custom_minimum_size(Vector2(32.0, 32.0))
		item_slot.set_size(Vector2(32.0, 32.0))
		item_slot.set_item(EMC_Item.new().setup(feasi.item_id))
		if feasi.block:
			item_slot.block()
			self.set_disabled(true)
		item_slot.item_long_pressed.connect(_on_item_long_pressed)
				
	return not self.disabled

func _on_item_long_pressed(item: EMC_Item, blocked: bool) -> void:
	_gui_mngr.overlay_gui("ItemInfoGui", [item])

func _on_pressed() -> void:
	recipe_pressed.emit(recipe)

## TODO: should cancel when moved
func _gui_input(event: InputEvent) -> void:
	if (disabled
	and event is InputEventMouseButton 
	and not event.is_pressed()
	and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
	and not (event as InputEventMouseButton).is_canceled()):
		recipe_disabled_pressed.emit(recipe)

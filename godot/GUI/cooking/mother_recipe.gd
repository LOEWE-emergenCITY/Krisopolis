extends VBoxContainer
class_name EMC_MotherRecipe
#
###Tupe-Klasse (alles public und keine Methoden)
#
const MOTHER_RECIPE = preload("res://GUI/cooking/mother_recipe.tscn")

signal was_pressed(p_recipe : EMC_Recipe)

@onready var content : HBoxContainer = $Mother/Content
@onready var item_name : RichTextLabel = $Mother/Content/ItemName
@onready var mother_button :TextureButton = $Mother

var _output_item_ID: EMC_Item.IDs
var _child_recipe : Array[EMC_Recipe]

func _ready() -> void:
	var item : EMC_Item = EMC_Item.make_from_id(_output_item_ID)
	var sprite := TextureRect.new()
	sprite.set_texture(item.get_texture())
	content.add_child(sprite)
	item_name.set_text(item.get_item_name())
	
	for child in _child_recipe:
		#add_child(child)
		child.hide()

func hide_children(irrelevant : EMC_GUI = null) -> void:
	for child : EMC_Recipe in get_children().slice(1):
		child.hide()

func show_children() -> void:
	for child in get_children():
		child.show()
	
func get_child_recipes() -> Array[EMC_Recipe]:
	var casted_array : Array[EMC_Recipe]
	casted_array.assign(get_children().slice(1))
	return casted_array

func set_disabled(value : bool) -> void:
	mother_button.set_disabled(value)

func is_disabled() -> bool:
	return mother_button.is_disabled()

func _on_pressed() -> void:
	if get_child_count() > 1 and get_children()[1].visible:
		hide_children()
	else:
		show_children()

static func make(p_outputItemID: EMC_Item.IDs, p_child_recipe : Array[EMC_Recipe]) -> EMC_MotherRecipe:
	var mother : EMC_MotherRecipe = MOTHER_RECIPE.instantiate()
	mother._output_item_ID = p_outputItemID
	
	for child in p_child_recipe:
		child.set_h_size_flags(SIZE_SHRINK_END)
		child.get_node("HBoxContainer/RichTextLabel").set_custom_minimum_size(Vector2(410, 70))
	
	mother._child_recipe = p_child_recipe
	
	return mother

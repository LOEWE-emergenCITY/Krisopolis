extends FoldableContainer
class_name EMC_Foldable_Recipe

const ITEM_SLOT = preload("uid://cfk7h3ji5pkne")
const RECIPE_BUTTON = preload("uid://j5nyqj2o5l6f")
const MENU_BOX_GRAY = preload("uid://bwu0dssl63nbv")
const MENU_BOX_DARK_GRAY = preload("uid://dpomspib1gvl1")

const FOLD_BUTTON = preload("uid://dl20ba4rnn1qj")

signal recipe_pressed(recipe: EMC_Recipe)
signal recipe_disabled_pressed(recipe: EMC_Recipe)

#@export var item: EMC_Item
#@export var text: String = "Brot"
@export var _gui_mngr: EMC_GUIMngr
@export var recipes: Array[EMC_Recipe]
@export var feasible: bool = true: 
	get:
		return feasible
	set(v):
		feasible = v
		if feasible:
			add_theme_stylebox_override("title_collapsed_panel", MENU_BOX_GRAY)
			add_theme_stylebox_override("title_panel", MENU_BOX_GRAY)
			add_theme_stylebox_override("title_collapsed_hover_panel", MENU_BOX_GRAY)
			add_theme_stylebox_override("title_hover_panel", MENU_BOX_GRAY)
		else:
			add_theme_stylebox_override("title_collapsed_panel", MENU_BOX_DARK_GRAY)
			add_theme_stylebox_override("title_panel", MENU_BOX_DARK_GRAY)
			add_theme_stylebox_override("title_collapsed_hover_panel", MENU_BOX_DARK_GRAY)
			add_theme_stylebox_override("title_hover_panel", MENU_BOX_DARK_GRAY)

@onready var recipe: EMC_Recipe_Button = $Margin/VBC/Panel/Margin/Recipe
@onready var vbc: VBoxContainer = $Margin/VBC

func _ready() -> void:
	
	recipe.recipe = recipes[0]
	recipe.show_ingredients()
	recipe._gui_mngr = _gui_mngr
	var item := EMC_Item.new().setup(recipes[0].get_output_item_ID())
	var text := item.get_item_name()
	
	for rec: EMC_Recipe in recipes.slice(1):
		var recipe_button: EMC_Recipe_Button = RECIPE_BUTTON.instantiate()
		recipe_button.recipe = rec
		recipe_button.recipe_pressed.connect(_on_recipe_pressed)
		recipe_button.recipe_disabled_pressed.connect(_on_recipe_disabled_pressed)
		recipe_button._gui_mngr = _gui_mngr
		vbc.add_child(recipe_button)
	
	var button: EMC_FoldButton = FOLD_BUTTON.instantiate()
	button.item = item
	button.text = text
	button.pressed.connect(_on_fold_pressed)
	add_title_bar_control(button)
	
	#var hbox := HBoxContainer.new()
	#var pic: EMC_Item_Slot = ITEM_SLOT.instantiate()
	#pic.set_item(item)
	#pic.set_custom_minimum_size(Vector2(32.0, 32.0))
	##var pic := TextureRect.new()
	##pic.set_texture(icon)
	##pic.set_expand_mode(TextureRect.ExpandMode.EXPAND_FIT_WIDTH_PROPORTIONAL)
	##pic.set_size(Vector2(32, 32))
	#var button := Button.new()
	##button.flat = true
	#button.mouse_filter = Control.MOUSE_FILTER_PASS
	#button.pressed.connect(_on_fold_pressed)
	#
	#button.ready.connect(
		#func () -> void:
			#var parent_size := button.get_parent_control().get_rect()
			#button.set_size(parent_size.size))
	#
	#var label := Label.new()
	#label.set_text(text)
	#label.add_theme_font_size_override("font_size", 27)
	#label.add_theme_color_override("font_color", Color())
	#
	#hbox.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	#hbox.add_theme_constant_override("separation", 8)
	#
	#hbox.add_child(label)
	#hbox.add_child(pic)
	#
	#button.add_child(hbox)
	#add_title_bar_control(button)
	
func check_feasibility(_inventory: EMC_Inventory, water_state: bool, heat_state: EMC_Recipe.Heat) -> void:
	var feas: bool = recipe.check_feasibility(_inventory, water_state, heat_state)
	for rec: EMC_Recipe_Button in vbc.get_children().slice(1):
		feas = feas or rec.check_feasibility(_inventory, water_state, heat_state)

	feasible = feas

func _on_recipe_pressed(p_recipe: EMC_Recipe) -> void:
	recipe_pressed.emit(p_recipe)

func _on_recipe_disabled_pressed(p_recipe: EMC_Recipe) -> void:
	recipe_disabled_pressed.emit(p_recipe)

func _on_fold_pressed() -> void:
	if is_folded():
		expand()
	else:
		fold()

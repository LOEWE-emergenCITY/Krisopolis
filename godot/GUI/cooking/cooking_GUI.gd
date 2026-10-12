@tool
extends EMC_GUI
class_name EMC_Cooking_GUI

const RECIPE_BUTTON = preload("uid://j5nyqj2o5l6f")
const FOLDABLE_RECIPE = preload("uid://bg21twvowvkuc")

var _inventory: EMC_Inventory

@export var _gui_mngr : EMC_GUIMngr
@export var _day_mngr : EMC_DayMngr
@export var _scoreboard: EMC_Scoreboard

@onready var _recipe_list := $Panel/Margin/VBC/VBC/Panel/Scroll/RecipeList

@onready var no_selection: PanelContainer = $Panel/Margin/VBC/NoSelection
@onready var no_water: PanelContainer = $Panel/Margin/VBC/NoWater
@onready var no_items: PanelContainer = $Panel/Margin/VBC/NoItems
@onready var no_heat: PanelContainer = $Panel/Margin/VBC/NoHeat

@onready var selected_recipe: EMC_Recipe_Button = $Panel/Margin/VBC/Recipe
@onready var cook: Button = $Panel/Margin/VBC/VBC/HBC/CC/HBC/Cook

########################################## PUBLIC METHODS ##########################################

func setup(p_inventory: EMC_Inventory) -> void:
	_inventory = p_inventory
	
	var recipes_dict : Dictionary
	for recipe : EMC_Recipe in JsonMngr.load_recipes():
		#_recipe_list.add_child(recipe)
		#recipe.was_pressed.connect(_on_recipe_pressed)
		if recipes_dict.has(recipe.get_output_item_ID()):
			recipes_dict[recipe.get_output_item_ID()].append(recipe)
		else:
			recipes_dict[recipe.get_output_item_ID()] = [recipe]
			
	for mother : int in recipes_dict:
		if recipes_dict[mother].size() == 1:
			var recipe_button: EMC_Recipe_Button = RECIPE_BUTTON.instantiate()
			recipe_button.recipe_pressed.connect(_on_recipe_pressed)
			recipe_button.recipe_disabled_pressed.connect(_on_recipe_disabled_pressed)
			recipe_button.recipe = recipes_dict[mother][0]
			## HACK
			recipe_button._gui_mngr = _gui_mngr
			_recipe_list.add_child(recipe_button)
		else:
			var casted_array : Array[EMC_Recipe]
			casted_array.assign(recipes_dict.get(mother))
			var fold_recipe: EMC_Foldable_Recipe = FOLDABLE_RECIPE.instantiate()
			fold_recipe.recipes = casted_array
			fold_recipe.recipe_pressed.connect(_on_recipe_pressed)
			fold_recipe.recipe_disabled_pressed.connect(_on_recipe_disabled_pressed)
			fold_recipe._gui_mngr = _gui_mngr
			_recipe_list.add_child(fold_recipe)
			#closed.connect(mother_scn.hide_children)

func _ready() -> void:
	selected_recipe._gui_mngr = _gui_mngr	

func open() -> void:
	#for recipe : Variant in _recipe_list.get_children():
		#if recipe is EMC_MotherRecipe:
			#
			#var all_disabled : bool = true
			#for child in (recipe as EMC_MotherRecipe).get_child_recipes():
				#if not _recipe_cookable(child):
					#recipe.move_child(child, -1)
					#child.set_disabled(true) 
				#else:
					#child.set_disabled(false)
				#all_disabled = all_disabled and child.is_disabled()
			#if all_disabled:
				#_recipe_list.move_child(recipe, -1)
				#recipe.set_disabled(true)
			#else:
				#recipe.set_disabled(false)
		#else:
			#if not _recipe_cookable(recipe):
				#_recipe_list.move_child(recipe, -1)
				#recipe.set_disabled(true)
			#else:
				#recipe.set_disabled(false)
	
	cook.set_disabled(true)
	for node in get_tree().get_nodes_in_group("cook_feedback"):
		node.hide()
	no_selection.show()
	
	for recipe in _recipe_list.get_children():
		_check_recipe(recipe)
	
	# DEBUG: check whether recipes are correctly sorted
	#print(_recipe_list.get_children().map(func(recipe:Variant) -> bool: return recipe.is_disabled()))
	
	show()
	opened.emit()

func close() -> void:
	hide()
	closed.emit(self)
	
static func sort_recipe(a : Variant, b : Variant) -> bool:
	if a == null:
		return false
	if b == null:
		return true
	return (not a.is_disabled()) and b.is_disabled()

########################################## PRIVATE METHODS #########################################

func _on_cook_pressed() -> void:
	_cook_recipe()

func _on_cancel_pressed() -> void:
	close()

func _check_recipe(p_recipe: Node) -> void:
	var water_state := OverworldStatesMngr.is_effective_state_eq("WaterState", "CLEAN")
	var heat: EMC_Recipe.Heat
	if OverworldStatesMngr.is_effective_state_eq("ElectricityState", "UNLIMITED"):
		heat = EMC_Recipe.Heat.available
	elif OverworldStatesMngr.has_upgrade(EMC_Upgrade.IDs.GAS_COOKER):
		heat = EMC_Recipe.Heat.needs_gas
	else:
		heat = EMC_Recipe.Heat.unavailable
	p_recipe.check_feasibility(_inventory, bool(water_state), heat)


func _on_recipe_disabled_pressed(p_recipe: EMC_Recipe) -> void:
	for node in get_tree().get_nodes_in_group("cook_feedback"):
		node.hide()
	
	var water_state := OverworldStatesMngr.is_effective_state_eq("WaterState", "CLEAN")
	var heat: EMC_Recipe.Heat
	if OverworldStatesMngr.is_effective_state_eq("ElectricityState", "UNLIMITED"):
		heat = EMC_Recipe.Heat.available
	elif OverworldStatesMngr.has_upgrade(EMC_Upgrade.IDs.GAS_COOKER):
		heat = EMC_Recipe.Heat.needs_gas
	else:
		heat = EMC_Recipe.Heat.unavailable
	match p_recipe.check_cookable(_inventory, bool(water_state), heat):
		EMC_Recipe.Result.missing_heat:
			no_heat.show()
		EMC_Recipe.Result.missing_ingredient:
			no_items.show()
		EMC_Recipe.Result.missing_water:
			no_water.show()

func _on_recipe_pressed(p_recipe: EMC_Recipe) -> void:
	selected_recipe.recipe = p_recipe
	selected_recipe.show_ingredients()
	_check_recipe(selected_recipe)
	
	for node in get_tree().get_nodes_in_group("cook_feedback"):
		node.hide()
	selected_recipe.show()
	
	cook.set_disabled(false)
	
	#_last_clicked_recipe = p_recipe
	#for unwanted_child : TextureRect in _input_item_list.get_children():
		#_input_item_list.remove_child(unwanted_child)
		#unwanted_child.queue_free()
	#for input_item_ID : EMC_Item.IDs in _last_clicked_recipe.get_input_item_IDs():
		#var item : EMC_Item = EMC_Item.make_from_id(input_item_ID)
		#var sprite := TextureRect.new()
		#sprite.set_texture(item.get_texture())
		#_input_item_list.add_child(sprite)
		#
	#_needs_water_icon.visible = p_recipe.needs_water()
	#_needs_heat_icon.visible = p_recipe.needs_heat()
	#if (p_recipe.needs_water() and OverworldStatesMngr.is_effective_state_neq("WaterState", "CLEAN")): # REMOVE OverworldStatesMngr.get_water_state() != OverworldStatesMngr.WaterState.CLEAN):
		#if OverworldStatesMngr.has_upgrade(EMC_Upgrade.IDs.WATER_RESERVOIR) and OverworldStatesMngr.get_upgrade_if_equipped(EMC_Upgrade.IDs.WATER_RESERVOIR).get_state() > 0:
			#return
		#var water : EMC_Item = EMC_Item.make_from_id(EMC_Item.IDs.WATER)
		#var sprite := TextureRect.new()
		#sprite.set_texture(water.get_texture())
		#_input_item_list.add_child(sprite)


#func _recipe_cookable(p_recipe: EMC_Recipe) -> bool:
	#if p_recipe == null:
		#return false
	#var counting_dict: Dictionary = {}
	#for input_item_ID: EMC_Item.IDs in p_recipe.get_input_item_IDs():
		#if counting_dict.has(input_item_ID):
			#counting_dict[input_item_ID] += 1 
		#else:
			#counting_dict[input_item_ID] = 1 
	#for id: EMC_Item.IDs in counting_dict.keys():
		#var filter := EMC_Util.combine_filters(EMC_Inventory.filter_id(id), EMC_Inventory.filter_not_comp(EMC_IC_Unpalatable))
		#if _inventory.get_items_filterd(filter).size() < counting_dict[id]:
			#return false
	#return true


func _cook_recipe() -> void:
	var output_item : EMC_Item = selected_recipe.recipe.cook(_inventory)
	_inventory.add_item(output_item)
	
	await SoundMngr.button_finished()
	var wait : AudioStreamPlayer = SoundMngr.play_sound("Cooking")
	##Don't wait, because player has to wait too long otherwhise and there will be an 
	##animation playing simultatenously (Made SoundMngr process always)
	#if wait != null:
		#await wait.finished
	
	_gui_mngr.queue_gui("CookingAnimation", [selected_recipe.recipe])
	#wait.stop() #Bug on mobile: Doesn't work, and waits endlessly!
	
	close()
	
	if not _day_mngr.get_current_day_period() == EMC_DayMngr.DayPeriod.EVENING:
		await _gui_mngr.queue_gui("ItemQuestionGUI", [output_item])
	
	#_action.executed.emit(_action)
	_scoreboard.add_score("cook", {"input": selected_recipe.recipe.get_input_item_IDs(), "output": selected_recipe.recipe.get_output_item_ID()})
	_day_mngr._advance_day_period("Du hast %s gekocht" % output_item.name)
#
#func _try_cooking_with_heat_source() -> void:
	#if OverworldStatesMngr.has_upgrade(EMC_Upgrade.IDs.GAS_COOKER):
		#if _inventory.has_item(EMC_Item.IDs.GAS_CARTRIDGE):
			#if await _gui_mngr.request_gui("ConfirmationGUI", ["Willst eine Gaskartusche zum Kochen verwenden?"]):
				#_inventory.use_item(EMC_Item.IDs.GAS_CARTRIDGE)
				#_cook_recipe()
		#else:
			#_gui_mngr.request_gui("TooltipGUI", ["Du hast zwar einen Gaskocher, aber keine Gaskartusche um ihn zu betreiben!"])
	#else:
		#_gui_mngr.request_gui("TooltipGUI", ["Du hast weder Strom, noch einen Gaskocher zum Kochen!"])

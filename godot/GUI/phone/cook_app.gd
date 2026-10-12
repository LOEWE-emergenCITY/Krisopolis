extends EMC_App

@export var scenario_icons : Array[Texture2D]

@onready var item_list : EMC_Item_List = $Recipes/Margin/Scroll/VBC/ItemList
@onready var recipes : Control = $Recipes
@onready var description : Control = $Description
@onready var text : RichTextLabel = $Description/Infos/MarginContainer/Text
@onready var offline : Control = $Offline

func _ready() -> void:
	item_list.item_clicked.connect(_on_item_clicked)

func open() -> void:
	#description.hide()
	#recipes.show()
	offline.show()
	show()
	return

	for recipe in JsonMngr.load_recipes():
		var item: EMC_Item = EMC_Item.make_from_id(recipe.get_output_item_ID())
		item_list.add_item([item.get_item_name(), item], item.get_item_name())

	#var dict : Array[String]
	#dict.assign(OverworldStatesMngr.get_scenario().keys())
	#print(OverworldStatesMngr.get_scenario().keys())
	#for scenario_id : String in dict:
		#scenario_id = scenario_id.get_basename().get_extension()
		#
		##var textures : Array[Texture2D] = []
		##for key : String in description[scenario_name]:
			##if description[scenario_name][key] is Dictionary:
				##for state : String in description[scenario_name][key]["states"]:
					##var state_info : Array = OverworldStatesMngr.name_to_state[state.get_basename()]
					##var x : int = state_info[0].get(state.get_extension()) * 64
					##var y : int = state_info[1] * 64
					##textures.append(EMC_Util.Icon_Patcher.cut_out(warn_texture, Rect2(x, y, 64, 64)))
		#
		#var scenario: Dictionary = JsonMngr.scenarios.get(scenario_id)
		#var icon_id: int = scenario.get("icon_id")
		#var title: String = scenario.get("title", scenario_id)
		#item_list.add_item([title, scenario_icons[icon_id]], scenario_id)
	
	show()
	
func back() -> void:
	if description.visible:
		description.hide()
		recipes.show()
	else:
		close()
		
func close() -> void:
	self.hide()
	closed.emit()
	
func _on_item_clicked(id : String) -> void:
	print("Pressed on: '" + id + "'")
	
	if id != "Nothing":
		recipes.hide()
		description.show()
		text.set_text(JsonMngr.scenarios.get(id).get("description"))

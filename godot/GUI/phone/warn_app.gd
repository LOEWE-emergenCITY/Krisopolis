extends EMC_App

@export var scenario_icons : Array[Texture2D]

@onready var item_list : EMC_Item_List = $Notifications/Margin/VBC/ItemList
@onready var notifications : Control = $Notifications
@onready var description : Control = $Description
@onready var text : RichTextLabel = $Description/Infos/MarginContainer/Text
@onready var offline : Control = $Offline

func _ready() -> void:
	item_list.item_clicked.connect(_on_item_clicked)

func open() -> void:
	if OverworldStatesMngr.is_effective_state_eq("MobileNetState", "OFFLINE"):
		description.hide()
		notifications.hide()
		offline.show()
		show()
		return
	
	description.hide()
	notifications.show()
	offline.hide()
	
	item_list.clear()

	var dict : Array[String]
	dict.assign(OverworldStatesMngr.get_scenario().keys())
	print(OverworldStatesMngr.get_scenario().keys())
	for scenario_id : String in dict:
		scenario_id = scenario_id.get_basename().get_extension()
		
		#var textures : Array[Texture2D] = []
		#for key : String in description[scenario_name]:
			#if description[scenario_name][key] is Dictionary:
				#for state : String in description[scenario_name][key]["states"]:
					#var state_info : Array = OverworldStatesMngr.name_to_state[state.get_basename()]
					#var x : int = state_info[0].get(state.get_extension()) * 64
					#var y : int = state_info[1] * 64
					#textures.append(EMC_Util.Icon_Patcher.cut_out(warn_texture, Rect2(x, y, 64, 64)))
		
		var scenario: Dictionary = JsonMngr.scenarios.get(scenario_id)
		var icon_id: int = scenario.get("icon_id")
		var title: String = scenario.get("title", scenario_id)
		item_list.add_item([title, scenario_icons[icon_id]], scenario_id)
	
	if item_list.is_empty():
		item_list.add_item(["Aktuell gibt es\nkeine Warnhinweise", scenario_icons[0], false], "Nothing")
		
		#for desc : String in description[scenario_name]:
			#if description[scenario_name][desc] is Dictionary:
				#var child : TreeItem = tree.create_item(scenario)
				#for state : String in description[scenario_name][desc]["states"]:
					#var state_info : Array = OverworldStatesMngr.name_to_state[state.get_basename()]
					#var x : int = state_info[0].get(state.get_extension()) * 64
					#var y : int = state_info[1] * 64
					#child.set_icon(0, warn_texture)
					#child.set_icon_region(0, Rect2(x, y, 64, 64))
				#child.set_text(0, description[scenario_name][desc]["desc"])
			#else:
				#var child : TreeItem = tree.create_item(scenario, 0)
				#child.set_text(0, description[scenario_name][desc])
				#child.set_custom_color(0, Color(1, 1, 0, 1))
	
	show()
	
func back() -> void:
	if description.visible:
		description.hide()
		notifications.show()
		offline.hide()
	else:
		close()
		
func close() -> void:
	self.hide()
	closed.emit()
	
func _on_item_clicked(id : String) -> void:
	print("Pressed on: '" + id + "'")
	
	if id != "Nothing":
		notifications.hide()
		description.show()
		text.set_text(JsonMngr.scenarios.get(id).get("description"))
	
func _on_text_meta_clicked(meta : Variant) -> void:
	var url : String = meta as String
	if url == null:
		return
	
	# TODO Safety
	OS.shell_open(url)

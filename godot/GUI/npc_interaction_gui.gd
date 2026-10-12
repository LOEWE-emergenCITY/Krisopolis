extends EMC_GUI
class_name EMC_Interaction_GUI

const UX_BUTTON := preload("res://util/UX_button.tscn")

@onready var portrait : TextureRect = $Portrait
@onready var buttons : VBoxContainer = $Buttons
@onready var descr : RichTextLabel = $Panel/Descr

@export var gsi: EMC_GSI

func open(npc : EMC_NPC) -> void:
	var npc_descr: EMC_NPC_Descr = npc.npc_resource.get_comp(EMC_NPC_Descr)
	
	descr.set_text(npc_descr.get_desc())
	
	portrait.set_texture(npc_descr.get_portrait())
	
	for child in buttons.get_children():
		buttons.remove_child(child)
		
	var interaction: Array[EMC_NPC_Interaction]  = npc.get_interactions()
	
	for option : EMC_NPC_Interaction in interaction:
		var button : Button = UX_BUTTON.instantiate()
		button.set_text(option.get_title())
		button.set_theme_type_variation(option.get_style_name())
		button.pressed.connect(_on_option_pressed.bind(option))
		
		buttons.add_child(button)
	
	show()
	opened.emit()

func close() -> void:
	hide()
	closed.emit(self)

func _on_option_pressed(option : EMC_NPC_Interaction) -> void:
	close()
	option.run(gsi)

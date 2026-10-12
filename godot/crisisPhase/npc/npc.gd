extends CharacterBody2D
class_name EMC_NPC

signal clicked(p_NPC: EMC_NPC)

@onready var hitbox : CollisionShape2D = $CollisionCircle
@onready var prompt_button : TextureButton = $DialogueHitbox
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var npc_resource: EMC_NPC_Resource

var interactions: Array[EMC_NPC_Interaction]

func _ready() -> void:
	$AnimationPlayer.play("idle")
	
	var npc_descr: EMC_NPC_Descr = npc_resource.get_comp(EMC_NPC_Descr)
	
	sprite_2d.set_texture(npc_descr.get_sprite_texture())
	sprite_2d.offset = Vector2(0, -46)
	sprite_2d.hframes = 3
	
	set_name(npc_descr.get_npc_name())
	
	var convers: EMC_NPC_Conversation = npc_resource.get_comp(EMC_NPC_Conversation)
	if convers:
		convers.set_owner(self)
		insert_interaction(0, convers)
	
	var trading: EMC_NPC_Trading = npc_resource.get_comp(EMC_NPC_Trading)
	if trading:
		trading.set_owner(self)
		insert_interaction(1, trading)
	
	## HACK: workaround till we have new solution presistent state and version upgrade solution
	if name == "Raphael":
		trading._item_preference = {
			"WATER": 1,
			"POTATOES": 1,
			"VEGETABLES": 1,
			"SOAP": 1,
			"MEAT": 1,
			"BREAD": 1
		}
	
	prompt_button.pressed.connect(_on_button_pressed)
	
func change_stage(stage_name: String, spot: EMC_Stage_Spot) -> void:
	var npc_stage: EMC_NPC_Stage = npc_resource.get_comp(EMC_NPC_Stage)
	npc_stage.change_stage(stage_name, spot.name)
	global_position = spot.global_position

func get_current_stage_name() -> String:
	var npc_stage: EMC_NPC_Stage = npc_resource.get_comp(EMC_NPC_Stage)
	return npc_stage.stage_name
	
func get_current_spot() -> String:
	var npc_stage: EMC_NPC_Stage = npc_resource.get_comp(EMC_NPC_Stage)
	return npc_stage.spot

func add_interaction(interaction: EMC_NPC_Interaction) -> void:
	interactions.append(interaction)

func insert_interaction(idx: int, interaction: EMC_NPC_Interaction) -> void:
	interactions.insert(idx, interaction)

func get_interactions() -> Array[EMC_NPC_Interaction]:
	return interactions

func _on_button_pressed() -> void:
	clicked.emit(self)

func enable() -> void:
	show()
	hitbox.set_deferred("disabled", false)
	
func disable() -> void:
	hide()
	hitbox.set_deferred("disabled", true)

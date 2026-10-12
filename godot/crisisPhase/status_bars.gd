extends Control

@onready var food_cont: TextureProgressBar = $HBC/VBoxContainer/FoodCont
@onready var drink_cont: TextureProgressBar = $HBC/VBoxContainer/DrinkCont
@onready var health_cont: TextureProgressBar = $HBC/VBoxContainer2/HealthCont
@onready var social_cont: TextureProgressBar = $HBC/VBoxContainer2/SocialCont

@onready var food_vfx: GPUParticles2D = $HBC/VBoxContainer/FoodCont/FoodVFX
@onready var drink_vfx: GPUParticles2D = $HBC/VBoxContainer/DrinkCont/DrinkVFX
@onready var health_vfx: GPUParticles2D = $HBC/VBoxContainer2/HealthCont/HealthVFX
@onready var social_vfx: GPUParticles2D = $HBC/VBoxContainer2/SocialCont/SocialVFX

@export var _gui_mngr : EMC_GUIMngr
#@export var _avatar: EMC_Avatar

#func _ready() -> void:
	#_avatar.status_updated.connect(update_bars)

func update_bars(delta_food: float, new_food: float,
				delta_drink: float, new_drink: float,
				delta_health: float, new_health: float,
				delta_social: float, new_social: float,) -> void:
	#if delta_food != 0:
	if not is_node_ready():
		await ready
	food_cont.set_value((new_food / EMC_Avatar.MAX_STATUS) * 48.0)
	food_vfx.set_emitting(true)
	#if delta_drink != 0:
	drink_cont.set_value((new_drink / EMC_Avatar.MAX_STATUS) * 48.0)
	drink_vfx.set_emitting(true)
	#if delta_health != 0:
	health_cont.set_value((new_health / EMC_Avatar.MAX_STATUS) * 48.0)
	health_vfx.set_emitting(true)
	#if delta_social != 0:
	social_cont.set_value((new_social / EMC_Avatar.MAX_STATUS) * 48.0)
	social_vfx.set_emitting(true)

func _on_food_button_pressed() -> void:
	_gui_mngr.request_gui("TooltipGUI", ["Diese Leiste stellt deinen Hunger dar."])

func _on_drink_button_pressed() -> void:
	_gui_mngr.request_gui("TooltipGUI", ["Diese Leiste stellt deinen Durst dar."])
	
func _on_health_button_pressed() -> void:
	_gui_mngr.request_gui("TooltipGUI", ["Diese Leiste stellt deine Gesundheit & Hygiene dar."])

func _on_social_button_pressed() -> void:
	_gui_mngr.request_gui("TooltipGUI", ["Diese Leiste stellt deine Glücklichkeit & dein Wohlbefinden dar."])

@tool
extends Node
class_name EMC_Upgrade_Slot

const DRAG_THRESHOLD: float = 15

const HIGHLIGHTED_COLOR := Color(0.4, 0.4, 0.4, 1)
const DEFAULT_COLOR := Color(1, 1, 1, 1)
const LOCKED_COLOR := Color(0, 0, 0, 1)
const EQUIPPED_COLOR := Color(0.56, 0.78, 0.53, 1)

@export var upgrade: EMC_Upgrade
@export var locked: bool = false
@export var equipped: bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var button: TextureButton = $"."

#var current_modulate: Color = DEFAULT_COLOR

signal clicked(upgrade: EMC_Upgrade_Slot)
signal long_pressed(upgrade: EMC_Upgrade_Slot)

func _init() -> void:
	if Engine.is_editor_hint():
		upgrade = EMC_Upgrade.new()
	
func _ready() -> void:
	load_texture()
	if locked:
		sprite_2d.set_modulate(LOCKED_COLOR)
	elif equipped:
		button.set_self_modulate(EQUIPPED_COLOR)
		#current_modulate = EQUIPPED_COLOR
	else:
		#current_modulate = DEFAULT_COLOR
		sprite_2d.set_modulate(DEFAULT_COLOR)
		button.set_self_modulate(DEFAULT_COLOR)

func load_texture() -> void:
	if upgrade != null:
		sprite_2d.set_texture(upgrade.get_texture())

func get_upgrade() -> EMC_Upgrade:
	return upgrade

func set_upgrade(p_upgrade : EMC_Upgrade) -> void:
	upgrade = p_upgrade
	if is_node_ready():
		load_texture()

func has_upgrade() -> bool:
	return upgrade.get_id() != EMC_Upgrade.IDs.EMPTY_SLOT

func is_upgarde(p_upgrade: EMC_Upgrade) -> bool:
	return upgrade == p_upgrade
	
func remove_upgrade() -> void:
	upgrade = null
	if Engine.is_editor_hint():
		upgrade = EMC_Upgrade.new()
		
func free_upgrade() -> void:
	upgrade.free()
	if Engine.is_editor_hint():
		upgrade = EMC_Upgrade.new()

func lock() -> void:
	locked = true
	if is_node_ready():
		sprite_2d.set_modulate(LOCKED_COLOR)

func unlock() -> void:
	locked = false
	if is_node_ready():
		sprite_2d.set_modulate(DEFAULT_COLOR)
		
func equippe() -> void:
	equipped = true
	#current_modulate = EQUIPPED_COLOR
	if is_node_ready():
		button.set_self_modulate(EQUIPPED_COLOR)

func unequippe() -> void:
	equipped = false
	#current_modulate = DEFAULT_COLOR
	if is_node_ready():
		button.set_self_modulate(DEFAULT_COLOR)

func get_sprite() -> Sprite2D:
	return $Sprite2D

func set_modulation(p_color: Color) -> void:
	$Sprite2D.modulate = p_color

func _on_pressed() -> void:
	for slot: EMC_Upgrade_Slot in get_tree().get_nodes_in_group("up_slot"):
		slot.reset_highlight()
	
	var tween: Tween = get_tree().create_tween()
	
	var start_pos: Vector2 = get_viewport().get_mouse_position()
	
	tween.tween_property(button, "modulate", HIGHLIGHTED_COLOR, 0.4)
	await EMC_Util.Promise.new([get_tree().create_timer(0.5).timeout, button.button_up], EMC_Util.Promise.signal_or_name).complete
	if button.button_pressed:
		long_pressed.emit(self)
		button.set_modulate(DEFAULT_COLOR)
	else:
		var mouse_position: Vector2 = get_viewport().get_mouse_position()
		if mouse_position.distance_to(start_pos) < DRAG_THRESHOLD: #item_button.get_global_rect().has_point(mouse_position):
			tween.stop()
			button.set_modulate(HIGHLIGHTED_COLOR)
			clicked.emit(self)
		else:
			button.set_modulate(DEFAULT_COLOR)

func reset_highlight() -> void:
	button.set_modulate(DEFAULT_COLOR)

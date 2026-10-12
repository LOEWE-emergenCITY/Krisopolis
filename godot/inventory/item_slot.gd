@tool
extends Control
class_name EMC_Item_Slot

const HIGHLIGHTED_COLOR := Color(0.4, 0.4, 0.4, 1)
const BLOCKED_COLOR := Color(0.4, 0.4, 0.4, 0.365)
const DEFAULT_COLOR := Color(1, 1, 1, 1)

const DRAG_THRESHOLD: float = 15

@export var item: EMC_Item
@onready var item_button: TextureButton = $ItemButton
@onready var slot_bg: EMC_Item_Slot = $"."

var disabled: bool = false
var modulate_color: Color =  DEFAULT_COLOR

signal item_clicked(item : EMC_Item)
signal item_long_pressed(item: EMC_Item, blocked: bool)
signal item_swipe_left(item: EMC_Item)
signal item_swipe_right(item: EMC_Item)

@export var hold_time := 0.5

var _holding := false
var _hold_triggered := false
var _hold_timer: Timer

func _init() -> void:
	if Engine.is_editor_hint():
		item = EMC_Item.new()
		
	_hold_timer = Timer.new()
	_hold_timer.one_shot = true
	_hold_timer.wait_time = hold_time
	_hold_timer.timeout.connect(_on_hold_timer_timeout)
	add_child(_hold_timer)
	
func _ready() -> void:
	load_texture()
	item_button.set_modulate(modulate_color)

func load_texture() -> void:
	if item != null:
		item_button.set_texture_normal(item.get_texture())

func get_item() -> EMC_Item:
	return item

func set_item(p_item : EMC_Item) -> void:
	item = p_item
	if is_node_ready():
		load_texture()

func has_item() -> bool:
	return item != null and item.get_id() != EMC_Item.IDs.DUMMY

func is_item(p_item: EMC_Item) -> bool:
	return item == p_item
	
func remove_item() -> void:
	item = null
	if Engine.is_editor_hint():
		item = EMC_Item.new()
		
func free_item() -> void:
	item.free()
	if Engine.is_editor_hint():
		item = EMC_Item.new()

func disable() -> void:
	disabled = true

func block() -> void:
	disabled = true
	modulate_color = BLOCKED_COLOR
	if is_node_ready():
		item_button.set_modulate(modulate_color)

func unblock() -> void:
	disabled = false
	modulate_color = DEFAULT_COLOR
	if is_node_ready():
		item_button.set_modulate(modulate_color)
	
func is_blocked() -> bool:
	return disabled
	
var start_pos: Vector2

func _on_item_button_button_down() -> void:
	for slot: EMC_Item_Slot in get_tree().get_nodes_in_group("slot"):
		slot.reset_highlight()
		
	if item.get_id() == EMC_Item.IDs.DUMMY:
		return
	
	start_pos = get_viewport().get_mouse_position()
	
	_holding = true
	_hold_triggered = false
	_hold_timer.start()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(slot_bg, "modulate", HIGHLIGHTED_COLOR, 0.4)

func _on_item_button_button_up() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and get_viewport().get_mouse_position().distance_to(start_pos) < DRAG_THRESHOLD:
		return
	
	_trigger_input()
	
func _trigger_input() -> void:
	_hold_timer.stop()
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	if mouse_position.distance_to(start_pos) > DRAG_THRESHOLD:
		slot_bg.set_modulate(DEFAULT_COLOR)
		_holding = false
		return
	
	if _hold_triggered:
		item_long_pressed.emit(item, disabled)
		slot_bg.set_modulate(DEFAULT_COLOR)
	elif not disabled and _holding:
		slot_bg.set_modulate(HIGHLIGHTED_COLOR)
		item_clicked.emit(item)
		
	_holding = false

func _on_hold_timer_timeout() -> void:
	if _holding:
		_hold_triggered = true
		_trigger_input()

func reset_highlight() -> void:
	slot_bg.set_modulate(DEFAULT_COLOR)

func reset_all_highlights() -> void:
	for slot: EMC_Item_Slot in get_tree().get_nodes_in_group("slot"):
		slot.reset_highlight()

@tool
extends Control
class_name EMC_Multi_Color_Progress_Bar
		
@export var style_box_fill: StyleBox:
	set(value):
		style_box_fill = value
@export var style_box_back: StyleBox:
	set(value):
		style_box_back = value
@export var colors: Array[Color] = [
	
]:
	set(value):
		colors = value

func _ready() -> void:
	
	for child in get_children():
		remove_child(child)
	
	update_configuration_warnings()
	
	for i in range(len(colors)):
		await add_progressbar(i)
	
func add_progressbar(index: int) -> void:
	var offset := self.size.x / len(colors)
	var x: float = offset
	var y := self.size.y
	
	var p := ProgressBar.new()
	p.add_theme_stylebox_override("fill", style_box_fill)
	p.add_theme_stylebox_override("background", style_box_back)
	p.show_percentage = false
	p.modulate = colors[index]
	
	add_child.call_deferred(p)
	p.set_owner.call_deferred(get_tree().edited_scene_root)
	
	await p.ready
	p.set_size(Vector2(x, y))
	p.set_position(Vector2(index * offset, 0))
	p.set_value(100)
	
func set_progress_values(values: Array[float]) -> void:
	if len(values) != len(colors):
		return
	var total: float = values.reduce(func (acc: float, v: float) -> float: return acc+ v)
	var offset: float = 0
	
	for i in range(len(values)):
		var child: ProgressBar = get_child(i)
		child.size.x = (values[i]/total * self.size.x)
		print((values[i]/total * self.size.x))
		child.position.x = offset
		offset += child.size.x

func animate() -> void:
	for child in get_children():
		child.set_value(0)
	
	var tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
	for child in get_children():
		tween.tween_property(child, "value", 100, 0.1)

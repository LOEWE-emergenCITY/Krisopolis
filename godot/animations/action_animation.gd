extends EMC_GUI
class_name EMC_ActionAnimtion

@onready var bg: TextureRect = $BG

func open(end_animation: Signal) -> void:
	show()
	
	var tween: Tween  = create_tween()
	tween.tween_property(bg, "modulate", Color(0, 0, 0, 1.0), 1)
	tween.tween_callback(end_animation.emit)
	tween.tween_property(bg, "modulate", Color(0, 0, 0, 0), 1)
	await tween.finished
	close()

func close() -> void:
	self.hide()
	closed.emit(self)

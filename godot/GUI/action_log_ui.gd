@tool
extends HBoxContainer
class_name EMC_Action_Log_UI

@onready var score_cat: RichTextLabel = $ScoreCat
@onready var score_text: RichTextLabel = $Score
@onready var color_rect: ColorRect = $ColorRect

@export var cat_name: String = "NONAME"
#:
	#get:
		#return cat_name
	#set(value):
		#cat_name = value
		#await ready
		#score_cat.set_text(cat_name)

@export var score: int = 0
#:
	#get:
		#return score
	#set(value):
		#score = value
		#await ready
		#score_text.set_text("[right]" + str(value))

@export var color: Color = Color.WHITE
#:
	#get:
		#return color
	#set(value):
		#color = value
		#await ready
		#color_rect.set_color(value)

func _ready() -> void:
	score_cat.set_text(cat_name)
	score_text.set_text("[right]" + str(score))
	color_rect.set_color(color)
	
func set_score_text(p_score: int) -> void:
	score_text.set_text("[right]" + str(p_score))
	
func animate(p_tween: Tween = null, duration: float = 0.2, delay: float = 0.0) -> void:
	var tween: Tween
	if p_tween != null:
		tween = p_tween
	else:
		tween = get_tree().create_tween()
	
	tween.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_method(func (v: int) -> void: score_text.set_text("[right]" + str(v)), 0, score, duration).set_delay(delay)

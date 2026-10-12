extends EMC_GUI

@onready var input_item_1: Sprite2D = $PanelContainer/InputItem1
@onready var input_item_2: Sprite2D = $PanelContainer/InputItem2
@onready var input_item_3: Sprite2D = $PanelContainer/InputItem3
@onready var input_item_4: Sprite2D = $PanelContainer/InputItem4

@onready var output_item: Sprite2D = $PanelContainer/OutputItem

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	hide()

## The animation currently only supports up to 4 input items at fixed positions
func open(p_recipe: EMC_Recipe) -> void:
	var input_item_IDs := p_recipe.get_input_item_IDs()
	
	output_item.frame = p_recipe._output_item_ID
	input_item_1.frame = input_item_IDs[0]
	
	if input_item_IDs.size() > 1:
		input_item_2.frame = input_item_IDs[1]
		input_item_2.show()
	else:
		input_item_2.hide()
	
	if input_item_IDs.size() > 2:
		input_item_3.frame = input_item_IDs[2]
		input_item_3.show()
	else:
		input_item_3.hide()
	
	if input_item_IDs.size() > 3:
		input_item_4.frame = input_item_IDs[3]
		input_item_4.show()
	else:
		input_item_4.hide()
	
	show()
	animation_player.play("fusing")
	await animation_player.animation_finished
	await get_tree().create_timer(1).timeout
	close()

func close() -> void:
	hide()
	closed.emit(self)

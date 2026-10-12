extends EMC_GUI

const _DOORBELL_SCN: PackedScene = preload("res://GUI/doorbell/doorbell.tscn")

@onready var _doorbell_list := $PanelCont/MarginCont/VBC/ButtonBox/ScrollContainer/DoorbellList

func setup(p_stage_mngr: EMC_StageMngr) -> void:
	#await ready
	
	var data : Dictionary = JsonMngr.load_door_bell()
	
	for key : String in data:
		var doorbell : EMC_DoorBell = _DOORBELL_SCN.instantiate()
		doorbell.setup(key, data[key])
		doorbell.rang.connect(p_stage_mngr._on_doorbell_rang)
		_doorbell_list.add_child(doorbell)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

func open() -> void:
	show()
	#opened.emit()

func close() -> void:
	hide()
	#closed.emit()

func _on_back_btn_pressed() -> void:
	close()

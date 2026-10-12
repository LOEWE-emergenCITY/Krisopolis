extends Node

@export var s: VRV_Script

@onready var vrv_gsi: VRV_GSI = $VRV_GSI

func _ready() -> void:
	s.gsi = vrv_gsi


func _on_button_pressed() -> void:
	s.get_next(VRV_InstanceData.new())

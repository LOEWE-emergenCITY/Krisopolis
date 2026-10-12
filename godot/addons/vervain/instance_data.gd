extends Resource
class_name VRV_InstanceData

@export var context: Dictionary

var current_node: Dictionary = {}
var current_sequence: Array[Dictionary] = []
var current_entry: int = -1

var last_node: Dictionary = {}

func to_start() -> void:
	self.current_node = {}
	self.current_sequence = []
	self.current_entry = -1
	self.last_node = {}

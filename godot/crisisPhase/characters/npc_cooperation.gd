extends EMC_NPC_Idee
class_name EMC_NPC_Cooperation

# format: {NPC: {ACTION_ID: ACTION_ID}}
@export var reaction: Dictionary = {}

@onready var npc : EMC_NPC = $"../.." 

var _action: String = "idle"
var _stop: bool = false

func _init(data: Dictionary) -> void:
	reaction = data

func _ready() -> void:
	npc.add_comp(self)
	
func supply_actions() -> Array[String]:
	var result: Array[String] = []
	
	if _stop:
		return [_action]
	
	for npc: String in OverworldStatesMngr._npc_intention:
		var intention: String = OverworldStatesMngr._npc_intention[npc]
		if reaction.has(npc) and reaction[npc].has(intention):
			result.append(reaction[npc][intention])
			#result.append(reaction[npc][OverworldStatesMngr._npc_intention[npc]])
	#print(result)
	if result.is_empty():
		return [_action]
	
	return result
	
	#var tmp := _action.duplicate()
	#_action.clear()
	#return tmp

func add_intention(action_id: String) -> void:
	var desc: EMC_NPC_Descr = npc.get_comp(EMC_NPC_Descr)
	if desc:
		OverworldStatesMngr.add_npc_intention(desc.npc_name, action_id)
		_action = action_id
		_stop = false
	else:
		printerr("NPC with unknown name tried action: " + action_id)

func stop_intention(action_id: String) -> void:
	var desc: EMC_NPC_Descr = npc.get_comp(EMC_NPC_Descr)
	if desc:
		OverworldStatesMngr.add_npc_intention(desc.npc_name, action_id)
		_action = action_id
		_stop = true
	else:
		printerr("NPC with unknown name tried action: " + action_id)

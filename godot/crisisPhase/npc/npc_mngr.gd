extends Control
class_name EMC_NPC_Mngr

const _NPC_SCN: PackedScene = preload("res://crisisPhase/npc/npc.tscn")

@export var _stage_mngr: EMC_StageMngr

func setup() -> void:
	if get_child_count() == 0:
		_setup_NPCs(JsonMngr.load_NPC())

### Add NPCs to the scene
func _setup_NPCs(npc_resources: Array[EMC_NPC_Resource]) -> void:
	for npc_res: EMC_NPC_Resource in npc_resources:
		var new_npc: EMC_NPC = _NPC_SCN.instantiate()
		new_npc.npc_resource = npc_res
		new_npc.clicked.connect(_stage_mngr._on_NPC_clicked)
		
		add_child(new_npc)

func get_NPC(p_NPC_name: String) -> EMC_NPC:
	return get_node(p_NPC_name.to_pascal_case())

func _on_stage_changed(stage_name: String) -> void:
	for npc: EMC_NPC in get_children():
		if npc.get_current_stage_name() != stage_name:
			npc.disable()
			continue
		
		var spot_name: String = npc.get_current_spot()
		var spot := _stage_mngr.request_spot(spot_name)
		if spot == null:
			npc.disable()
			continue
		
		npc.global_position = spot.global_position
		npc.enable()

## Remove all NPCs that are currently spawned
func deactivate_NPCs() -> void:
	for NPC: EMC_NPC in get_children():
		NPC.hide()

func let_npcs_act() -> void:
	pass
	#var npcs := NPCs.get_children()
	#npcs.shuffle()
	#print("\n\nDay: " + str(_day_mngr.get_current_day()) + " Preiod: " + str(_day_mngr.get_current_day_period()))
	#for npc : EMC_NPC in npcs:
		#var brain : EMC_NPC_Brain = npc.get_comp(EMC_NPC_Brain)
		#if brain:
			#brain.act()
#
	#var i: int = 0
	#while true:
		#OverworldStatesMngr.npc_intention_swap()
		#print("\n" + str(OverworldStatesMngr._npc_intention))
		#print("\nIteration: " + str(i))
		##OverworldStatesMngr.npc_intention_unchanged()
		#for npc : EMC_NPC in npcs:
			#var brain : EMC_NPC_Brain = npc.get_comp(EMC_NPC_Brain)
			#if brain and npc.has_comp(EMC_NPC_Cooperation):
				#brain.coop_act()
		#
		## When resultion is found stop loop.
		#if not OverworldStatesMngr._npc_intention_changed:
			#break
		#
		## When no resultion is found after 7 steps, NPCS will act idle.
		#if i > 7:
			#for npc : EMC_NPC in npcs:
				#var coop : EMC_NPC_Cooperation = npc.get_comp(EMC_NPC_Cooperation)
				#if coop:
					#coop.add_intention("idle")
			#printerr("NPC act idle")
			#break
			#
		#i += 1
	#
	#OverworldStatesMngr.clear_npc_intention()
	
	#get_NPC("Gerhard").get_comp(EMC_NPC_Brain).act()
	
	#npc_act.emit()

func save() -> Dictionary:
	var data : Dictionary = {
		"node_path" : get_path(),
		"npcs" : get_children().map(func (npc: EMC_NPC) -> EMC_NPC_Resource: return npc.npc_resource), 
	}
	return data

func load_state(data : Dictionary) -> void:
	var npcs: Array[EMC_NPC_Resource]
	npcs.assign(data.get("npcs", JsonMngr.load_NPC()))
	_setup_NPCs(npcs)

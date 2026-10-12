extends Node
class_name EMC_NPC_Save

@export var res: EMC_AllRes
@onready var npc : EMC_NPC = $".."

func _ready() -> void:
	Global.game_saved.connect(save)
	npc.add_comp(self)
	load_res()

func add_res(p_name: String, p_data: Variant) -> void:
	res.add_res(p_name, p_data)

func get_res(p_name: String, type: Variant) -> Variant:
	var obj: Variant = res.get_res(p_name)
	if is_instance_of(obj, type):
		return obj
	return null

func save() -> void:
	var npc_name: String = npc.get_comp(EMC_NPC_Descr).get_npc_name()
	if not DirAccess.dir_exists_absolute("user://npc/"):
		DirAccess.make_dir_absolute("user://npc/")
	ResourceSaver.save(res, "user://npc/" + npc_name + ".res")

func load_res() -> void:
	var descr: EMC_NPC_Descr = npc.get_comp(EMC_NPC_Descr)
	if not descr.is_node_ready():
		await descr.ready
	var npc_name: String = descr.get_npc_name()
	if ResourceLoader.exists("user://npc/" + npc_name + ".res"):
		res = ResourceLoader.load("user://npc/" + npc_name + ".res")
	else:
		res = EMC_AllRes.new()

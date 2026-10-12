extends EMC_NPC_Interaction
class_name EMC_NPC_Conversation

@export var day_dialogue: VRV_Script
@export var day_dialogue_state: VRV_InstanceData
@export var small_talk: VRV_Script
#@export var context: Dictionary = {}
@export var npc_pitch: float = 1.0

var owner: EMC_NPC

func set_owner(_owner: EMC_NPC) -> void:
	owner = _owner

func setup(dict: Dictionary) -> void:
	npc_pitch = dict.get("pitch", npc_pitch)
	var dialogue_path: String = dict.get("day", "")
	if not dialogue_path.is_empty():
		day_dialogue = ResourceLoader.load(dialogue_path, "VRV_Script")#.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
		#day_dialogue.update.connect(set_context)
	#elif OS.is_debug_build():
		#printerr("EMC_NPC_Conversation: Invalid path.")
	day_dialogue_state = VRV_InstanceData.new()
	
	dialogue_path = dict.get("small_talk", "")
	if dialogue_path.is_empty():
		small_talk = ResourceLoader.load("res://resources/dialogues/small_talk/one.vrv", "VRV_Script", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		small_talk = ResourceLoader.load(dialogue_path, "VRV_Script")

func get_title() -> String:
	return "Reden"

func get_style_name() -> String:
	return "ConfirmButton"

func run(gsi: EMC_GSI) -> void:
	var script: VRV_Script = _choose_dialogue()
	
	#gsi.run_script(script)
	day_dialogue_state.to_start()
	gsi.request_gui("DialogueGui", [script, day_dialogue_state])

func _choose_dialogue() -> VRV_Script:
	if day_dialogue != null:
		return day_dialogue
	
	small_talk.context = {"@npc": owner.get_name()}
	return small_talk

func get_pitch() -> float:
	return npc_pitch
	
#func set_context(_context: Dictionary) -> void:
	#context = _context

#const FLAG_DAY_SEEN     = 1 << 0  # 01
#const FLAG_PURPOSE_SEEN = 1 << 1  # 10
#
#@export var tags: Array[String]
#@export var day: int = 0
#@export var dialogue_flags: int = 0
#
#var _small_talk: Array[VRV_Script]
#var _day_dialogues: Dictionary[String, Array]
#var _purpose: Dictionary[String, VRV_Script]
#var _event: Dictionary[String, VRV_Script]
#var _quest: Array[VRV_Script]
#
#func _init(dict: Dictionary) -> void:
	#npc_pitch = dict.get("pitch", 1.0)
	#var npc_paths: Dictionary[String, String]
	#npc_paths.assign(dict.get("paths", {}))
	#_load_dialoges(npc_paths)
#
#func _ready() -> void:
	#_gui_mngr = npc.get_gui_mngr()
	#_stage_mngr = npc.get_stage_mngr()
	#_checker = npc.get_act_cond()
	#
	#npc.get_day_mngr().period_increased.connect(reset)
	#
	#npc.add_comp(self)
	#load_save.call_deferred()
#
### TODO loading day dialogues
#func _load_dialoges(npc_paths: Dictionary[String, String]) -> void:
	#if npc_paths.has("day"):
		#_day_dialogues["0"] = _load_dir(npc_paths["day"]).values()
	#if  npc_paths.has("event"):
		#_event = _load_dir(npc_paths["purpose"])
	#if npc_paths.has("purpose"):
		#_purpose = _load_dir(npc_paths["purpose"])
	#if npc_paths.has("small_talk"):
		#_small_talk = _load_dir(npc_paths["small_talk"]).values()
	#if npc_paths.has("quest"):
		#_quest = _load_dir(npc_paths["quest"]).values()
	#else:
		#_small_talk = _load_dir("res://resources/dialogues/small_talk/").values()
#
#func _load_dir(path: String) -> Dictionary[String, VRV_Script]:
	#var result: Dictionary[String, VRV_Script]
	#for file_name in ResourceLoader.list_directory(path):
		#var raw_dialoge := ResourceLoader.load(path + file_name, "VRV_Script")
		#if raw_dialoge is VRV_Script:
			#result[file_name] = raw_dialoge
		#
	##var dir := DirAccess.open(path)
	##if dir:
		##dir.list_dir_begin()
		##var file_name : String = dir.get_next()
		##while file_name != "":
			##print(file_name)
			##if not dir.current_is_dir() and (file_name.ends_with(".vrv")):# or file_name.ends_with(".vrv.import")):
				###if file_name.ends_with(".import"):
				###	file_name = file_name.trim_suffix(".import")
				##var raw_dialoge := ResourceLoader.load(path + file_name, "VRV_Script")
				##if raw_dialoge is VRV_Script:
					##result[file_name] = raw_dialoge
			##file_name = dir.get_next()
	##else:
		##printerr("An error occurred when trying to access the path.")
	#return result
#
#func load_save() -> void:
	#_save = npc.get_comp(EMC_NPC_Save)
	#if not _save:
		#printerr("No Save comp")
		#return
	#
	#if Global.get_game_state() == Global.State.CRISIS:
		#var raw_day: Variant = _save.get_res("conv_day", TYPE_INT)
		#if raw_day is int and not is_nan(raw_day as int):
			#day = raw_day
		#else:
			#_save.add_res("conv_day", day)
			#
		#var raw_flags: Variant = _save.get_res("conv_flags", TYPE_INT)
		#if raw_flags is int and not is_nan(raw_flags as int):
			#dialogue_flags = raw_flags
		#else:
			#_save.add_res("conv_flags", dialogue_flags)
	#else:
		#_save.add_res("conv_day", day)
		#_save.add_res("conv_flags", dialogue_flags)
#
#func get_title() -> String:
	#return "Reden"
#
#func reset(_tmp: int) -> void:
	#dialogue_flags = 0
	#_save.add_res("conv_flags", dialogue_flags)
#
#func run() -> void:
	#pass
	##var npc_name : String = npc.get_comp(EMC_NPC_Descr).get_npc_name()
	###var stage_name: String = npc.get_comp(EMC_NPC_Stage).get_stage_name()
	##
	##var purpose: String = ""
	##
	##if not OverworldStatesMngr.active_quests.is_empty() and not _quest.is_empty():
		##var dialogues: Array[VRV_Script]
		##dialogues.assign(_quest)
		##var dialogue: VRV_Script = dialogues.filter(
			##func (dia: VRV_Script) -> bool: return dia.check_start(_checker)).pick_random()
		##
		##if dialogue != null:
			##dialogue._start_npc_name = npc_name
			##dialogue._start_npc = npc
			##_gui_mngr.request_gui("DialogueGui", [dialogue])
			##return
	##
	### Purpose not yet seen
	##if (dialogue_flags & FLAG_PURPOSE_SEEN == 0
		##and not purpose.is_empty()
		##and _purpose.has(purpose)):
		##
		##var dialogue: VRV_Script = _purpose.get(purpose)
		##dialogue._start_npc_name = npc_name
		##dialogue._start_npc = npc
		##_gui_mngr.request_gui("DialogueGui", [dialogue])
		##dialogue_flags |= FLAG_PURPOSE_SEEN
		##_save.add_res("conv_flags", dialogue_flags)
	##
	### Day Dialoge not yet seen
	##elif dialogue_flags & FLAG_DAY_SEEN == 0 and _day_dialogues.has("0"):
		##var dialogues: Array[VRV_Script]
		##if not _day_dialogues.has(str(day)):
			##day = 0
			##_save.add_res("conv_day", day)
		##dialogues.assign(_day_dialogues[str(day)])
		##var dialogue: VRV_Script = dialogues.filter(
			##func (dia: VRV_Script) -> bool: return dia.check_start(_checker)).pick_random()
		##
		##dialogue._start_npc_name = npc_name
		##dialogue._start_npc = npc
		##_gui_mngr.request_gui("DialogueGui", [dialogue])
		###dialogue_flags |= FLAG_DAY_SEEN
		##_save.add_res("conv_flags", dialogue_flags)
		##day += 1
		##_save.add_res("conv_day", day)
	##else:
		##var dialogue: VRV_Script = _small_talk.pick_random()
		##dialogue._start_npc_name = npc_name
		##dialogue._start_npc = npc
		##_gui_mngr.request_gui("DialogueGui", [dialogue])
#
#
### TODO: tag ramove functionality
#func add_tag(tag: String) -> void:
	#tags.append(tag)
#
### TODO: tag ramove functionality
#func has_tag(tag: String) -> bool:
	#if tag in tags:
		#tags.erase(tag)
		#return true
	#return false
#
#func remove_tag(tag: String) -> void:
	#tags.erase(tag)

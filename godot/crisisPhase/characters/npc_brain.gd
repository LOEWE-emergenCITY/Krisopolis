extends Node
class_name EMC_NPC_Brain

#@export var actions: Dictionary = {
	#"idle": "noop",
	#"stroll": "change_stage"
#}
#
#@export var sub_comps: Array[EMC_NPC_Idee]
#@export var priority_comps: Array[EMC_NPC_Idee]
#@export var decide: EMC_NPC_Decide
#
#@onready var npc : EMC_NPC = $".."
#
#var _stage_mngr: EMC_StageMngr
#
#func _init(data : Dictionary) -> void:
	#actions = data.get("actions", {})
	#for key : String in actions:
		##var res: Resource = Preloader.get_resource("res://util/action/" + actions[key]["type"] + "_action.gd")
		##actions[key] = res.new(actions[key])
		#actions[key] = EMC_Action.load_action(actions[key])
		##
		##if typeof(actions[key]) == TYPE_DICTIONARY:
			##if actions[key].has("0"):
				##actions[key] = MultiAction.new(actions[key])
			##else:
				##actions[key] = Callable(self, actions[key].get("method")).bindv(actions[key].get("params"))
				##Action.new(actions[key].get("method"), actions[key].get("params"))
			#
	#var sub_comps_data: Dictionary = data.get("comps", {})
	#var decide_data: Dictionary = data.get("decide", {})
	#
	#if decide_data.has("name"):
		#var decide_class: Resource = load("res://crisisPhase/characters/npc_" + decide_data["name"] + ".gd")
		#
		#decide = decide_class.new(decide_data)
	#else:
		#print_debug("Failed to contruct decide comp.")
		#decide = EMC_NPC_Decide.new()
	#
	#
	#for comp_name: String in sub_comps_data:
		#var comp_class: Resource = load("res://crisisPhase/characters/npc_" + comp_name + ".gd")
		#var new_comp: Variant = comp_class.new(sub_comps_data[comp_name])
		#if new_comp != null:
			#if sub_comps_data[comp_name].has("priority"):
				#priority_comps.append(new_comp)
			#else:
				#sub_comps.append(new_comp)
#
#func _get_comp_by_name(comp_name: String) -> Variant:
	#if comp_name == "self":
		#return self
	#elif comp_name == "gui_mngr":
		#return npc.get_gui_mngr()
	#elif comp_name == "OSM":
		#return OverworldStatesMngr
	#elif comp_name == "ActCond":
		#return npc.get_act_cond()
	#elif comp_name == "Score":
		#return npc.get_scoreboard()
	#elif comp_name == "Global":
		#return Global
	#return npc.get_comp_by_name(comp_name)
#
#func _ready() -> void:
	#npc.add_comp(self)
	#_stage_mngr = npc.get_stage_mngr()
	#_stage_mngr.npc_act.connect(act)
#
	#for sub: EMC_NPC_Idee in sub_comps:
		#self.add_child(sub)
	#
	#for sub: EMC_NPC_Idee in priority_comps:
		#self.add_child(sub)
		#
	#for action: EMC_Action in actions.values():
		#action.set_comp(self._get_comp_by_name)
#
### Executes the behaviour of an NPC
### First gathers possible actions based on suppliers
### Second chooses option
### Third executes option
#func act() -> void:
	## Action to be executed
	#var decision: String
	#
	## Actions mit priority
	#var priority: Array[String] = collect_priority()
	#
	## Execute pre-conditions
	#priority = priority.filter(func (option: String) -> bool:
		#if option.begins_with("!"):
			#return actions[option].pre_cond()
		#return true
		#)
	#
	## when there is no priority choose normal options
	#if priority.is_empty():
		#var options: Array[String] = collect_options()
		#options = options.filter(func (option: String) -> bool:
			#if option.begins_with("!"):
				#return actions[option].pre_cond()
			#return true
			#)
		##choose option
		#decision = decide.choose_option(options)
	#else:
		##choose priority option
		#decision = decide.choose_option(priority)
	 #
	#
	#print(npc.get_comp(EMC_NPC_Descr).get_npc_name() + ": " + decision)
	#
	#if decision.begins_with("!"):
		#actions[decision].execute_then({"result": {}})
	#else:
		#actions[decision].execute({"result": {}})
	##if len(decision) == 1:
		##var action : Variant  = actions.get(decision[0])
		##if has_method(action.method_name):
			##callv(action.method_name, action.params)
	##else :
		##if has_method(actions.get(decision[0])):
			##callv(actions.get(decision[0]), decision.slice(1))
#
#func coop_act() -> void:
	#if not OverworldStatesMngr._npc_intention.has(npc.get_comp(EMC_NPC_Descr).get_npc_name()):
		#return
	#
	## Action to be executed
	#var decision: String
	#
	#var options: Array[String] = []
	#
	#var coop: EMC_NPC_Cooperation = npc.get_comp(EMC_NPC_Cooperation)
	#if coop:
		#options.append_array(coop.supply_actions())
		#
		#options = options.filter(func (option: String) -> bool:
			#if option.begins_with("!"):
				#return actions[option].pre_cond()
			#return true
			#)
		##choose option
		#decision = decide.choose_option(options)
		 #
		#
		#print(npc.get_comp(EMC_NPC_Descr).get_npc_name() + ": " + decision)
		#
		#actions[decision].execute({"result": {}})
#
#func change_stage(stage_name: String, x: String = "", y: String = "") -> void:
	#var position: Vector2 = Vector2(x.to_float(), y.to_float())
	#if position == Vector2.ZERO:
		#position = Vector2.INF
	#
	#var stage: EMC_NPC_Stage = npc.get_comp(EMC_NPC_Stage)
	#stage.override_spawn(position)
	#stage.change_stage(stage_name)
#
##func coop(npc_name: String, action: String) -> void:
	##var cooperation: EMC_NPC_Cooperation = _stage_mngr.get_NPC(npc_name).get_comp(EMC_NPC_Cooperation)
	##
	##action = action.replace("@", "#")
	##
	##cooperation.request_cooperation(action)
#
##func check(param: String) -> bool:
	##return true
#
#func output(msg: String) -> void:
	#print(msg)
	#
#func noop(stuff: Variant = null) -> void:
	#pass
#
### Collect action options from the Idea suppilers 
#func collect_options() -> Array[String]:
	#var options: Array[String] = []
	#for sub: EMC_NPC_Idee in priority_comps:
		#if is_instance_of(sub, EMC_NPC_Cooperation):
			#continue
		#options.append_array(sub.supply_actions())
	#
	#if not options.is_empty():
		#return options
	#
	#for sub: EMC_NPC_Idee in sub_comps:
		#if is_instance_of(sub, EMC_NPC_Cooperation):
			#continue
		#options.append_array(sub.supply_actions())
	#
	#return options
#
### If the is a priority supplied it will be choosen
#func collect_priority() -> Array[String]:
	#var options: Array[String] = []
	#for sub: EMC_NPC_Idee in priority_comps:
		#if is_instance_of(sub, EMC_NPC_Cooperation):
			#continue
		#options.append_array(sub.supply_actions())
	#
	#return options

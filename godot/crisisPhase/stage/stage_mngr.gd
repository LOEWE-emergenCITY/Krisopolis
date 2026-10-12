@tool
extends Node2D
class_name EMC_StageMngr
## TODO
## TileSet = A Set of Tiles
## Tile = One tile of a Tileset
## Cell = An instanciated Tile of a Tileset on a Tilemap
## Tilemap = Many cells

const STAGENAME_HOME: String = "home"
#Public Locations:
const STAGENAME_MARKET: String = "market"
const STAGENAME_TOWNHALL: String = "townhall"
const STAGENAME_PARK: String = "park"
#Private Locations:
const STAGENAME_GARDENHOUSE: String = "gardenhouse"
const STAGENAME_ROWHOUSE: String = "rowhouse"
const STAGENAME_MANSION: String = "mansion"
const STAGENAME_PENTHOUSE: String = "penthouse"
#kann mehrfach verwendet werden in der Zukunft:
const STAGENAME_APARTMENT_DEFAULT: String = "apartment_default" 
const STAGENAME_APARTMENT_MERT: String = "apartment_mert"
const STAGENAME_APARTMENT_CAMPER: String = "apartment_camper"


signal npc_interaction(npc: EMC_NPC)
signal stage_changed(stage_name: String)
#signal npc_act

# Cache of Stages and default stages 
@export var _stages: Dictionary[String, PackedScene]
@export var editor_stage: String = "home"

@export var _avatar: EMC_Avatar
@export var _day_mngr: EMC_DayMngr
@export var _gui_mngr : EMC_GUIMngr

@onready var stage_offset: Node2D = $StageOffset

var _curr_stage: EMC_Stage

var _last_click_position: Vector2 = Vector2.INF
var _last_clicked_NPC: EMC_NPC = null

var _initial_stage_name : String = "home"
var _opt_event_mngr: EMC_OptionalEventMngr


########################################## PUBLIC METHODS ##########################################
## Konstruktor: Interne Avatar-Referenz setzen
func setup(p_opt_event_mngr: EMC_OptionalEventMngr) -> void:
	_avatar.arrived.connect(_on_avatar_arrived)
	_opt_event_mngr = p_opt_event_mngr

	change_stage(_initial_stage_name, false)
## if the stage change does not advance the day it should be set to false
func change_stage(p_stage_name: String, wait : bool = true) -> void:
	if wait:
		await _day_mngr.animation_end

## Change the stage to the one specified via [param p_stage_name]
## Wait: waits for the day transition to change_stage,
		
	unload_stage()
	load_stage(p_stage_name)
	_curr_stage.request_spot("start")
	stage_changed.emit(get_curr_stage_name())

func load_stage(stage_name: String) -> void:
	if _curr_stage != null:
		EMC_Util.print_warn("EMC_Stage_Mngr: fogot to unload stage!")
		unload_stage()
	
	var _stage_scn: PackedScene
	if not _stages.has(stage_name):
		_stage_scn = (load("res://crisisPhase/stage/" + stage_name + ".tscn") as PackedScene)
		_stages[stage_name] = _stage_scn
	else:
		_stage_scn = _stages[stage_name]
		
	_curr_stage = _stage_scn.instantiate()
	stage_offset.add_child(_curr_stage)
	if not Engine.is_editor_hint():
		_day_mngr.period_increased.connect(_curr_stage.show_electricity)
		_curr_stage.show_electricity()
	
func unload_stage() -> void:
	if _curr_stage == null:
		return
		
	stage_offset.remove_child(_curr_stage)
	# Current Stage will not be free as a Reference still remains in _stages
	_curr_stage = null

func reload_state() -> void:
	_curr_stage.show_electricity()

func get_curr_stage_name() -> String:
	return _curr_stage.name

func save() -> Dictionary:
	var data : Dictionary = {
		"node_path" : get_path(),
		"stage_name" : get_curr_stage_name(),
	}
	return data

func load_state(data : Dictionary) -> void:
	_initial_stage_name = data.get("stage_name", "home")

func request_spot(spot_name: String) -> EMC_Stage_Spot:
	return _curr_stage.request_spot(spot_name)

########################################## PRIVATE METHODS #########################################
func _ready() -> void:
	if Engine.is_editor_hint():
		load_stage("home")

## Handle Tap/Mouse-Input
## If necessary, set the [EMC_Avatar]s navigation target
## To see the consequences, once arrived, see func _on_avatar_arrived
func _unhandled_input(p_event: InputEvent) -> void:
	if ((p_event is InputEventMouseButton && (p_event as InputEventMouseButton).pressed == true)
	or (p_event is InputEventScreenTouch)):
		_last_clicked_NPC = null
		var click_position: Vector2 = p_event.position
		_last_click_position = click_position
		if not _curr_stage.get_viewport_rect().has_point(p_event.position): return
		
		var _target_pos := _curr_stage.get_avatar_target(click_position)
		if _target_pos.is_finite():
			_avatar.set_target(_target_pos)

func _on_NPC_clicked(p_NPC: EMC_NPC) -> void:
	_last_click_position = Vector2.INF
	_last_clicked_NPC = p_NPC
		
	var _target_pos := _curr_stage.get_avatar_target(p_NPC.position)
	if _target_pos.is_finite():
			_avatar.set_target(_target_pos)

## Is called when the [EMC_Avatar] stops navigation, aka arrives at some point
## See func _unhandled_input for where the navigation began
## (doesn't have to be the target position that was originally set)
func _on_avatar_arrived() -> void:
	
	if not _last_click_position.is_finite() and _last_clicked_NPC != null:
		#NPC
			npc_interaction.emit(_last_clicked_NPC)
	else: 
		#FURNITURE
		var raw_type_content : PackedStringArray = _curr_stage.get_tile_type(_last_click_position).split("\\")
		var type : String = raw_type_content[0]
		var content : String
		if raw_type_content.size() >= 2:
			content = raw_type_content[1]
		match type:
			"tooltip":
				_gui_mngr.request_gui("TooltipGUI", [content])
			"book":
				_gui_mngr.request_gui("BookGUI", [content.to_int()])
			"action":
				_day_mngr.on_interacted_with_furniture(content)


func _on_doorbell_rang(p_stage_change_ID: int) -> void:
	_day_mngr.on_interacted_with_furniture(str(p_stage_change_ID))

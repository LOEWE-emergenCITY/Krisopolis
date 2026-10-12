extends CharacterBody2D
class_name EMC_Avatar
##MRM: TODO: Either the sub_ / add_ methods should check that the values are always positive, or
## they should be merged into one "change_xxx_by" method

signal arrived

signal status_updated(
	delta_food: float, new_food: float,
	delta_drink: float, new_drink: float,
	delta_health: float, new_health: float,
	delta_social: float, new_social: float,
)

signal died

const MOVE_SPEED: float = 300.0 #real movespeed set in NavAgent Node under Avoidance (Max Speed)!
const PITCH: float = 1.0

@onready var _nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var _walking_SFX := $SFX/Walking

const MAX_STATUS: float = 8 #EMC_DayMngr.TIME_PRE_DAY/3*10*3

var INIT_FOOD: float = MAX_STATUS/2
var INIT_DRINK: float = MAX_STATUS/2
var INIT_HEALTH: float = MAX_STATUS/2
var INIT_SOCIAL: float = MAX_STATUS/2

var _food_status: float = 0
var _drink_status: float = 0
var _health_status: float = 0
var _social_status: float = 0

# equal to 3 per day
var _food_decay: float = 3/EMC_DayMngr.TIME_PRE_DAY
var _drink_decay: float = 3/EMC_DayMngr.TIME_PRE_DAY
var _health_decay: float = 3/EMC_DayMngr.TIME_PRE_DAY
var _social_decay: float = 3/EMC_DayMngr.TIME_PRE_DAY

enum Frame{
	FRONTSIDE = 0,
	BACKSIDE = 1
}

########################################## PUBLIC METHODS ##########################################
## Das Navigationsziel des Avatars setzen
##TODO: In TechDoku aufnehmen: _nav_agent.is_target_reachable(): #funzt net
func set_target(p_target_pos: Vector2) -> void:
	if (p_target_pos == position):
		return
	
	_nav_agent.target_position = p_target_pos
	if not _walking_SFX.playing:
		_walking_SFX.play()
	$AnimationPlayer.play("walking")

func cancel_navigation() -> void:
	_nav_agent.target_position = self.position

func consume_item(p_item : EMC_Item) -> void:
	var consumable_comps : Array[EMC_IC_Consumable]
	consumable_comps.assign(p_item.get_all_comps_of(EMC_IC_Consumable))
	
	begin_batch()
	for con : EMC_IC_Consumable in consumable_comps:
		con.consume(self)
	end_batch()

var _food_delta: float = 0
var _drink_delta: float = 0
var _health_delta: float = 0
var _social_delta: float = 0

var _batch_depth: int = 0

func begin_batch() -> void:
	_batch_depth = 1
	
func end_batch() -> void:
	_batch_depth = max(_batch_depth - 1, 0)
	if _batch_depth == 0:
		if _food_delta == 0 and _drink_delta == 0 and _health_delta == 0 and _social_delta == 0:
			return
		
		_apply_delta()

func modify_food_delta(delta: float) -> void:
	_food_delta = delta
	
	if _batch_depth == 0:
		_apply_delta()

func modify_drink_delta(delta: float) -> void:
	_drink_delta = delta
	
	if _batch_depth == 0:
		_apply_delta()

func modify_health_delta(delta: float) -> void:
	_health_delta = delta
	
	if _batch_depth == 0:
		_apply_delta()
		
func modify_social_delta(delta: float) -> void:
	_social_delta = delta
	
	if _batch_depth == 0:
		_apply_delta()

func _apply_delta() -> void:
	self._food_status += _food_delta 
	self._drink_status += _drink_delta 
	self._health_status += _health_delta 
	self._social_status += _social_delta 
	
	if self._food_status <= 0 || self._drink_status <= 0 || \
	self._health_status <= 0 :
		died.emit()
	
	status_updated.emit(
		_food_delta, self._food_status,
		_drink_delta, self._drink_status,
		_health_delta, self._health_status,
		_social_delta, self._social_status,
	)
	
	_food_delta = 0
	_drink_delta = 0
	_health_delta = 0
	_social_delta = 0

func advance_time(delta: float) -> void:
	begin_batch()
	modify_food_delta(-_food_decay*delta)
	modify_drink_delta(-_drink_decay*delta)
	modify_health_delta(-_health_decay*delta)
	modify_social_delta(-_social_decay*delta)
	end_batch()

## MRM: Naming idea: Could be renamed into "serialize()" as it's not really the saving itself,
## but "serializing" the object data into a format that can be saved in a file
func save() -> Dictionary:
	var some_position : Vector2 = get_global_position()

	var data : Dictionary = {
		"node_path": get_path(),
		"food_status": _food_status,
		"drink_status": _drink_status,
		"health_status": _health_status,
		"social_status": _social_status,
		"x-position": some_position.x,
		"y-position": some_position.y
	}
	return data

func load_state(data : Dictionary) -> void:
	_food_status = data.get("food_status", INIT_FOOD)
	_drink_status = data.get("drink_status", INIT_DRINK)
	_health_status = data.get("health_status", INIT_HEALTH)
	_social_status = data.get("social_status", INIT_SOCIAL)#
	_apply_delta()
	
	var some_position : Vector2 = Vector2(data.get("x-position", 277), data.get("y-position", 601))
	set_global_position(some_position)

func get_home() -> void:
	EMC_StageMngr
	set_global_position(Vector2i(250, 750))

########################################## PRIVATE METHODS #########################################
func _notification(what : int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		cancel_navigation()

func _ready() -> void:
	self._food_status = INIT_FOOD 
	self._drink_status = INIT_DRINK 
	self._health_status = INIT_HEALTH 
	self._social_status = INIT_SOCIAL 
	
	#_apply_delta()
	SettingsGUI.avatar_sprite_changed.connect(_on_new_avatar_sprite_changed)
	_on_new_avatar_sprite_changed(SettingsGUI.get_avatar_sprite_suffix()) #init
	$AnimationPlayer.play("idle")

func _process(p_delta: float) -> void:
	#Set frame to direction that character is currently walking in
	if !_nav_agent.is_navigation_finished():
		if to_local(_nav_agent.get_next_path_position()).y > 0:
			$Sprite2D.frame = Frame.FRONTSIDE
		else:
			$Sprite2D.frame = Frame.BACKSIDE

func _physics_process(_delta: float) -> void:
	var input_direction: Vector2

	#if (_nav_agent.is_navigation_finished()):
		##Keyboard-Input only relevant if no Pathfinding-Direction, so it's not mixed up
		## Get the input direction
		#input_direction = Vector2(
			#Input.get_action_strength("right") - Input.get_action_strength("left"),
			#Input.get_action_strength("down") - Input.get_action_strength("up")
		#)
	#else: #Navigation via Pathfinding
	input_direction = position.direction_to(_nav_agent.get_next_path_position()) #.normalized()
	
	# Update velocity
	var new_velocity := MOVE_SPEED * input_direction
	_nav_agent.set_velocity(new_velocity)

# NOTICE: target reched can only be emitted if path desired distance if lower or equal to Traget desired distance
func _on_navigation_target_reached() -> void:
	_walking_SFX.stop()
	$AnimationPlayer.stop()
	$AnimationPlayer.play("idle")
	scale = Vector2(1.0, 1.0)
	arrived.emit()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide() #uses the characters velocity to move them on the map

func _on_new_avatar_sprite_changed(p_avatar_sprite_suffix: String) -> void:
	$Sprite2D.texture = \
		load("res://assets/characters/sprite_avatar_" + p_avatar_sprite_suffix + ".png")

extends Node
class_name EMC_Scoreboard

@export var spawn_rect: Rect2i = Rect2i(100, 200, 100, 100)

@onready var canvas_layer: CanvasLayer = $CanvasLayer

enum ScoreCat{
	PREPAREDNESS,
	SELF_SUFFICIENCY,
	COMMUNITY,
	RESOURCE_EFFICIENCY,
	INFOMRATION
}

const score_cat_to_text: Dictionary = {
	ScoreCat.PREPAREDNESS: "Vorbereitung",
	ScoreCat.SELF_SUFFICIENCY: "Selbsterhaltung",
	ScoreCat.COMMUNITY: "Gesellschaft",
	ScoreCat.RESOURCE_EFFICIENCY: "Nachhaltigkeit",
	ScoreCat.INFOMRATION: "Wissen"
}

const score_cat_to_color: Dictionary = {
	ScoreCat.PREPAREDNESS: EMC_Palette.DARK_BLUE,
	ScoreCat.SELF_SUFFICIENCY: EMC_Palette.LIGHT_RED,
	ScoreCat.COMMUNITY: EMC_Palette.LIGHT_YELLOW,
	ScoreCat.RESOURCE_EFFICIENCY: EMC_Palette.LIGHT_GREEN,
	ScoreCat.INFOMRATION: EMC_Palette.LIGHT_BLUE
}

const score_cat_to_multiplier: Dictionary = {
	ScoreCat.PREPAREDNESS: 1,
	ScoreCat.SELF_SUFFICIENCY: 0.5,
	ScoreCat.COMMUNITY: 1,
	ScoreCat.RESOURCE_EFFICIENCY: 0.5,
	ScoreCat.INFOMRATION: 0.5
}

const win_lose_multiplier: Dictionary = {
	true: 1,
	false: 0.5
}

const difficulty_multiplier: Dictionary = {
	EMC_OverworldStatesMngr.Difficulty.TUTORIAL: 1.0,
	EMC_OverworldStatesMngr.Difficulty.EASY: 1.1,
	EMC_OverworldStatesMngr.Difficulty.MEDIUM: 1.2,
	EMC_OverworldStatesMngr.Difficulty.HARD: 1.3
}

class ActionLog extends Resource:
	@export var descr: String = "NONAME"
	@export var rule: Callable = ScoreRule.Default
	@export var context: Dictionary = {}
	# Format: {ScoreCat: VALUE, ScoreCat: VALUE, ...}
	@export var eval: Dictionary = {}
	
	func setup(_descr: String = "", _rule: Callable = ScoreRule.Default, _eval: Dictionary = {}) -> ActionLog:
		self.descr = _descr
		self.rule = _rule
		self.eval = _eval
		return self
	
	# Calulates the score and returns duplicate
	func dup_calculate() -> ActionLog:
		self.eval = self.rule.call(self)
		var result := ActionLog.new()
		result.context = self.context
		result.eval = self.eval
		return result

static var state: Dictionary = {
	"bbk": false,
	"help": false,
	"radio": false,
	"tip_source": {},
	"social_source": {}
}

class ScoreRule:
	static var Default: Callable = (func (_log: ActionLog) -> Dictionary: return {ScoreCat.SELF_SUFFICIENCY: 10})
	static var Social: Callable = (func (alog: ActionLog) -> Dictionary:
		var source: String = alog.context.get("source", "none")
		if EMC_Scoreboard.state["social_source"].has(source):
			return {}
		EMC_Scoreboard.state["social_source"][source] = ""
		return {ScoreCat.COMMUNITY: 5})
	# TODO: Make Score dependent on items used nd produced
	static var Cook: Callable = (func (_log: ActionLog) -> Dictionary: return {ScoreCat.SELF_SUFFICIENCY: 10})
	static var Shower: Callable = (func (alog: ActionLog) -> Dictionary: 
		return {
			ScoreCat.SELF_SUFFICIENCY: 10 + 10 * alog.context["water"],
			ScoreCat.RESOURCE_EFFICIENCY: 10 * alog.context["soap"]
		})
	static var BBK: Callable = (func (_log: ActionLog) -> Dictionary: 
		if not EMC_Scoreboard.state["bbk"]:
			EMC_Scoreboard.state["bbk"] = true
			return {ScoreCat.INFOMRATION: 10}
		return {}
		)
	static var Radio: Callable = (func (alog: ActionLog) -> Dictionary:
		if not EMC_Scoreboard.state["radio"]:
			EMC_Scoreboard.state["radio"] = true
			return {
				ScoreCat.INFOMRATION: 10,
				ScoreCat.RESOURCE_EFFICIENCY: 10 * alog.context["batteries"]
			}
		return {
			ScoreCat.INFOMRATION: 10 * alog.context["batteries"]
		})
	static var Reservoir: Callable = (func (alog: ActionLog) -> Dictionary: 
		return {
			ScoreCat.PREPAREDNESS: 10 * alog.context["fill"],
			ScoreCat.RESOURCE_EFFICIENCY: 10 - 10 * alog.context["fill"]
		})
	static var Item_Use: Callable = (func (_log: ActionLog) -> Dictionary: return {ScoreCat.RESOURCE_EFFICIENCY: 5})
	static var Quest: Callable = (func (alog: ActionLog) -> Dictionary: return {ScoreCat.COMMUNITY: alog.context.get("value", 10)})
	static var Tip: Callable = (func (alog: ActionLog) -> Dictionary:
		var source: String = alog.context.get("source", "none")
		if EMC_Scoreboard.state["tip_source"].has(source):
			return {}
		else:
			EMC_Scoreboard.state["tip_source"][source] = ""
			return {ScoreCat.INFOMRATION: 10, ScoreCat.COMMUNITY: 5})
	
## WARNING: returns reference to the same object
var name_to_log: Dictionary = {
	"cook": ActionLog.new().setup("Kochen", ScoreRule.Cook),
	"sleep": ActionLog.new().setup("Schlafen", ScoreRule.Default),
	"shower": ActionLog.new().setup("Duschen", ScoreRule.Shower),
	"bbk": ActionLog.new().setup("Broschüre", ScoreRule.BBK),
	"radio": ActionLog.new().setup("Radio", ScoreRule.Radio),
	"reservoir": ActionLog.new().setup("Reservoir", ScoreRule.Reservoir),
	"chlor": ActionLog.new().setup("Chlor", ScoreRule.Item_Use),
	"quest": ActionLog.new().setup("Quest", ScoreRule.Quest),
	"tip": ActionLog.new().setup("Tipp", ScoreRule.Tip),
	"social": ActionLog.new().setup("social", ScoreRule.Social)
}

## Prepare Phase Total
var num_run: int = 0
var prep_tot_items: Dictionary = {}
var tot_difficulty: Dictionary = {
	OverworldStatesMngr.Difficulty.TUTORIAL: 0,
	OverworldStatesMngr.Difficulty.EASY: 0,
	OverworldStatesMngr.Difficulty.MEDIUM: 0,
	OverworldStatesMngr.Difficulty.HARD: 0
}
var tot_upgrades_equipped: Dictionary = {}
## Prepare Phase Sequence
#var prep_seq_items: Array[Dictionary] = [{}]
#var seq_difficulty: Array = []
#var seq_upgrades_bougth: Dictionary = { 0: [] }
#var seq_upgrades_equipped: Array = [ [ ] ]

var current_difficulty: EMC_OverworldStatesMngr.Difficulty
# Format: { day: [ACTIONLOG, ACTIONLOG, ACTIONLOG], day: [...], ... }
var score_log: Dictionary

@export var _day_mngr: EMC_DayMngr

func _ready() -> void:
	_day_mngr.period_increased.connect(reset_radio)

func reset_radio(_tmp : int) -> void:
	state["radio"] = false
	state["tip_source"] = {}
	state["social_source"] = {}

func start_run(_inventory: EMC_Inventory, difficulty: EMC_OverworldStatesMngr.Difficulty, _upgrades: Array[int]) -> void:
	num_run += 1
	for item: EMC_Item in _inventory.get_items():
		if item != null:
			var item_name: String = JsonMngr.item_id_to_name(item.get_id())
			if prep_tot_items.has(item_name):
				prep_tot_items[item_name] += 1
			else:
				prep_tot_items[item_name] = 1
			
	tot_difficulty[difficulty] += 1
	current_difficulty = difficulty
	
	for id: int in _upgrades:
		if tot_upgrades_equipped.has(id):
			tot_upgrades_equipped[id] += 1
		else:
			tot_upgrades_equipped[id] = 1

func add_score(log_name: String, context: Dictionary = {}) -> void:
	var day: int = _day_mngr.get_current_day()
	var alog: ActionLog = name_to_log.get(log_name, ActionLog.new())
	alog.context = context
	alog = alog.dup_calculate()
	if score_log.has(day):
		if not alog.eval.is_empty():
			score_log[day].append(alog)
	else:
		if not alog.eval.is_empty():
			score_log[day] = [alog]
		
	for cat: ScoreCat in alog.eval:
		if alog.eval[cat] > 0:
			animate_score(alog.eval[cat], score_cat_to_color[cat])

func get_day_score() -> int:
	var score: int = 0
	if score_log.has(_day_mngr.get_current_day()-1):
		for alog: ActionLog in score_log[_day_mngr.get_current_day()-1]:
			score += alog.eval.values().reduce(func (acc: int, v: int) -> int: return acc + v)
			
		return score
	return 0

func get_day_summary() -> Dictionary:
	var result: Dictionary = {
		ScoreCat.PREPAREDNESS: 0,
		ScoreCat.SELF_SUFFICIENCY: 0,
		ScoreCat.COMMUNITY: 0,
		ScoreCat.RESOURCE_EFFICIENCY: 0,
		ScoreCat.INFOMRATION: 0
	}
	if score_log.has(_day_mngr.get_current_day()-1):
		for alog: ActionLog in score_log[_day_mngr.get_current_day()-1]:
			for cat: ScoreCat in alog.eval.keys():
				result[cat] += alog.eval[cat]
	
	return result

## TODO: Add infulence of StatusBars and rework Difficulty and stuff...
func get_game_score() -> int:
	var total_score: Array = []
	for day_score: Array in score_log.values():
		total_score.append_array(day_score)
	
	return total_score.reduce(
		func (p_acc: int, p_v: ActionLog) -> int:
			return p_acc + (p_v.eval.values().reduce(
				func(c_acc: int, c_v: int) -> int: 
					return c_acc + c_v)), 0)
	
func get_game_summary() -> Dictionary:
	var result: Dictionary = {
		ScoreCat.PREPAREDNESS: 0,
		ScoreCat.SELF_SUFFICIENCY: 0,
		ScoreCat.COMMUNITY: 0,
		ScoreCat.RESOURCE_EFFICIENCY: 0,
		ScoreCat.INFOMRATION: 0
	}
	
	var total_score: Array = []
	for day_score: Array in score_log.values():
		total_score.append_array(day_score)
	
	for alog: ActionLog in total_score:
		for cat: ScoreCat in alog.eval.keys():
			result[cat] += alog.eval[cat]
	
	return result
	
func calculate_e_coins(p_won: bool) -> int:
	var e_coins: float = 0
	var summary: = get_game_summary()
	for cat: ScoreCat in summary:
		e_coins += summary[cat] * score_cat_to_multiplier[cat]
	
	return int(e_coins * win_lose_multiplier[p_won] * difficulty_multiplier[current_difficulty])

func animate_score(value: int, color: Color) -> void:
	var number: Label = Label.new()
	var x: int = randi_range(spawn_rect.position.x, spawn_rect.position.x+spawn_rect.size.x)
	var y: int = randi_range(spawn_rect.position.y, spawn_rect.position.y+spawn_rect.size.y)
	number.global_position = Vector2(x, y)
	number.text = str(value)
	number.label_settings = LabelSettings.new()
	
	number.label_settings.font_color = color
	number.label_settings.font_size = 25
	number.label_settings.outline_color = Color.BLACK
	number.label_settings.outline_size = 1
	
	canvas_layer.add_child.call_deferred(number)
	
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	
	var tween: Tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel()
	tween.tween_property(
		number, "position:y", number.position.y - 24, 1.0
	)
	tween.tween_property(
		number, "label_settings:font_size", 50, 0.5
	)
	
	# TODO: Add Sound
	
	await tween.finished
	number.queue_free()
	
#var num_run: int = 0
#var prep_tot_items: Dictionary = {}
#var tot_difficulty: Dictionary = {
	#OverworldStatesMngr.Difficulty.TUTORIAL: 0,
	#OverworldStatesMngr.Difficulty.EASY: 0,
	#OverworldStatesMngr.Difficulty.MEDIUM: 0,
	#OverworldStatesMngr.Difficulty.HARD: 0
#}
#var tot_upgrades_equipped: Dictionary = {}
### Prepare Phase Sequence
##var prep_seq_items: Array[Dictionary] = [{}]
##var seq_difficulty: Array = []
##var seq_upgrades_bougth: Dictionary = { 0: [] }
##var seq_upgrades_equipped: Array = [ [ ] ]
#
#var current_difficulty: EMC_OverworldStatesMngr.Difficulty
## Format: { day: [ACTIONLOG, ACTIONLOG, ACTIONLOG], day: [...], ... }
#var score_log: Dictionary
	
func save() -> Dictionary:
	#Format: {day: [ ActionLog.eval, ActionLog.eval, ActionLog.eval ], [ {ScoreCat: Value, ...}, ...], ... }
	var json_log: Dictionary = {}
	for key: int in score_log:
		json_log[key] = (score_log[key] as Array).map(func (alog: ActionLog) -> Dictionary: return alog.eval)
	
	var data : Dictionary = {
		"node_path": get_path(),
		"current_difficulty": current_difficulty,
		"score_log": json_log
	}
	return data
	
func load_state(data : Dictionary) -> void:
	current_difficulty = (data.get("current_difficulty", EMC_OverworldStatesMngr.Difficulty.EASY)
	 as EMC_OverworldStatesMngr.Difficulty)
	
	var raw_log: Dictionary = data.get("score_log", {})
	score_log = {}
	for key: int in raw_log:
		score_log[key] = (raw_log[key] as Array).map(
			func(raw_eval: Dictionary) -> ActionLog:
				var eval: Dictionary = {}
				for cat: int in raw_eval:
					eval[cat as ScoreCat] = raw_eval[cat]
				return ActionLog.new().setup("", ScoreRule.Default, eval)
		)
			
		#score_log[key.to_int()] = raw_log[key].map(
			#func(eval: Dictionary) -> ActionLog: 
				#return ActionLog.new().setup("", ScoreRule.Default, eval))

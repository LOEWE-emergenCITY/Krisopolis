extends EMC_GUI
class_name EMC_EndGameGUI
## Improvement idea: Instead of having two almost identical copies "WinnerScreen" and "LoserScreen"
## just have one and change the contents... That's a lot better because with each copy there is, the
## amount of work you have to do when making changes doubles (and you might overlook/forget to make
## changes for both)

const LOSER_COIN_FACTOR : int = 40
const WON := "GEWONNEN"
const LOST := "VERLOREN"
const ACTION_LOG_UI = preload("res://GUI/action_log_ui.tscn")

@export var _scoreboard: EMC_Scoreboard
var _inventory: EMC_Inventory

@onready var title: RichTextLabel = $SummaryWindow/MarginContainer/VBC/TitleSpacing/Title
@onready var logs: VBoxContainer = $SummaryWindow/MarginContainer/VBC/SC/Logs
@onready var score: RichTextLabel = $SummaryWindow/MarginContainer/VBC/PCScore/Score
@onready var e_coins: RichTextLabel = $SummaryWindow/MarginContainer/VBC/TextBox/ECoins

@onready var pc_status: PanelContainer = $SummaryWindow/MarginContainer/VBC/PCStatus

@onready var water: TextureProgressBar = $SummaryWindow/MarginContainer/VBC/PCStatus/HBC/Water
@onready var food: TextureProgressBar = $SummaryWindow/MarginContainer/VBC/PCStatus/HBC/Food
@onready var heart: TextureProgressBar = $SummaryWindow/MarginContainer/VBC/PCStatus/HBC/Heart
@onready var smile: TextureProgressBar = $SummaryWindow/MarginContainer/VBC/PCStatus/HBC/Smile
@onready var water_cross: TextureRect = $SummaryWindow/MarginContainer/VBC/PCStatus/HBC/Water/Cross
@onready var food_cross: TextureRect = $SummaryWindow/MarginContainer/VBC/PCStatus/HBC/Food/Cross
@onready var heart_cross: TextureRect = $SummaryWindow/MarginContainer/VBC/PCStatus/HBC/Heart/Cross
@onready var smile_cross: TextureRect = $SummaryWindow/MarginContainer/VBC/PCStatus/HBC/Smile/Cross

@onready var main_menu: Button = $SummaryWindow/MarginContainer/VBC/MainMenu

func _ready() -> void:
	hide()
	
	water.max_value = EMC_Avatar.MAX_STATUS
	food.max_value = EMC_Avatar.MAX_STATUS
	heart.max_value = EMC_Avatar.MAX_STATUS
	smile.max_value = EMC_Avatar.MAX_STATUS
	
	
	## NOTICE: Code to debug animations when running current scene
	#await get_tree().create_timer(1).timeout
	#
	#_scoreboard = EMC_Scoreboard.new()
	#_scoreboard.current_difficulty = OverworldStatesMngr.Difficulty.EASY
	#_scoreboard.score_log[1] = [
		#_scoreboard.name_to_log["sleep"].dup_calculate(),
		#_scoreboard.name_to_log["sleep"].dup_calculate(),
		#_scoreboard.name_to_log["sleep"].dup_calculate()
	#]
	#_scoreboard.score_log[2] = [
		#_scoreboard.name_to_log["sleep"].dup_calculate(),
		#_scoreboard.name_to_log["sleep"].dup_calculate(),
		#_scoreboard.name_to_log["sleep"].dup_calculate()
	#]
	#_scoreboard.score_log[3] = [
		#_scoreboard.name_to_log["sleep"].dup_calculate(),
		#_scoreboard.name_to_log["sleep"].dup_calculate(),
		#_scoreboard.name_to_log["sleep"].dup_calculate()
	#]
	#_scoreboard.score_log[4] = [
		#_scoreboard.name_to_log["sleep"].dup_calculate(),
		#_scoreboard.name_to_log["sleep"].dup_calculate(),
		#_scoreboard.name_to_log["sleep"].dup_calculate()
	#]
	#var avatar: EMC_Avatar = EMC_Avatar.new()
	#avatar._nutrition_value = 0
	#open([], false, avatar)

func setup(p_inventory: EMC_Inventory) -> void:
	_inventory = p_inventory

## opens summary end of day GUI/makes visible
func open(p_won : bool, _avatar : EMC_Avatar) -> void:
	clear()
	main_menu.disabled = true
	
	if p_won:
		title.set_text(WON)
	else:
		title.set_text(LOST)
	
	show()
	opened.emit()
	
	var tween: Tween = get_tree().create_tween()
	var status_time: float = 1.5
	
	smile.value = 0
	water.value = 0
	food.value = 0
	heart.value = 0
	
	tween.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(smile, "value", _avatar._social_status, status_time)
	tween.parallel().tween_property(water, "value", _avatar._drink_status, status_time)
	tween.parallel().tween_property(food, "value", _avatar._food_status, status_time)
	tween.parallel().tween_property(heart, "value", _avatar._health_status, status_time)
	
	water_cross.modulate = Color(1, 1, 1, 0)
	food_cross.modulate = Color(1, 1, 1, 0)
	heart_cross.modulate = Color(1, 1, 1, 0)
	smile_cross.modulate = Color(1, 1, 1, 0)
	
	tween.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	if _avatar._drink_status == 0:
		tween.tween_property(water_cross, "modulate", Color(1, 1, 1, 1), 0.1)
	if _avatar._food_status == 0:
		tween.tween_property(food_cross, "modulate", Color(1, 1, 1, 1), 0.1)
	if _avatar._health_status == 0:
		tween.tween_property(heart_cross, "modulate", Color(1, 1, 1, 1), 0.1)
	if _avatar._social_status == 0:
		tween.tween_property(smile_cross, "modulate", Color(1, 1, 1, 1), 0.1)
	
	tween.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(func (v: int) -> void: score.set_text(str(v)), 0, _scoreboard.get_game_score(), 1.5).set_delay(0.2)
	
	var summary: Dictionary = _scoreboard.get_game_summary()
	var i: int = 0
	for cat: EMC_Scoreboard.ScoreCat in summary.keys():
		var new_log_ui: EMC_Action_Log_UI = ACTION_LOG_UI.instantiate()
		new_log_ui.cat_name = EMC_Scoreboard.score_cat_to_text[cat]
		new_log_ui.score = summary[cat]
		new_log_ui.color = EMC_Scoreboard.score_cat_to_color[cat]
		new_log_ui.modulate = Color(1, 1, 1, 0)
		logs.add_child(new_log_ui)
		new_log_ui.set_score_text(0)
		
		tween.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(new_log_ui, "modulate", Color(1, 1, 1, 1), 0.1).set_delay(i * 0.3)
		new_log_ui.animate(tween, 0.2, i * 0.3 + 0.1)
		i += 1
		
	var coins: int = _scoreboard.calculate_e_coins(p_won)
	var leftover_items := _inventory.filter_items(
		EMC_Inventory.filter_not_comp(EMC_IC_Unpalatable))
	if not leftover_items.is_empty():
		var add_coins: int = leftover_items.reduce(
			func (accum: int, item: EMC_Item) -> int:
				var cost: EMC_IC_Cost = item.get_comp(EMC_IC_Cost)
				return accum + cost.get_cost(), 0)
		coins += add_coins
				
	tween.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(
		func (v: int) -> void: e_coins.set_text("Du erhältst " + str(v) + " [img]res://assets/GUI/icons/icon_ecoins.png[/img]."),
		 0, coins, 1.0)
	#e_coins.set_text("Du hast " + str(coins) + " [img]res://assets/GUI/icons/icon_ecoins.png[/img] erhalten")
	
	Global.add_e_coins(coins)
	
	await tween.finished
	main_menu.disabled = false
	

func clear() -> void:
	for child: EMC_Action_Log_UI in logs.get_children():
		child.queue_free()

## closes summary end of day GUI/makes invisible
func close() -> void:
	_on_main_menu_pressed()
	
	#hide()
	#closed.emit(self)

func _on_main_menu_pressed() -> void:
	SoundMngr.play_slow_musik()
	#Global.reset_state()
	#Global.reset_inventory()
	#Global.reset_upgrades_equipped()
	Global.save_game(Global.State.START)
	Global.load_game()
	Global.goto_scene(Global.MAIN_MENU_SCENE)

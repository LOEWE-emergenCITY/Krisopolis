extends Control

@onready var buttons: VBoxContainer = $ColorRect/Margin/Main/CenterContainer/ScenarioPanel/VBC/Panel/VBC
@export var edu_button_group: ButtonGroup

func _on_continue_pressed() -> void:
	var pressed_button := edu_button_group.get_pressed_button()
	Global._game_state = Global.State.SCENARIO
	OverworldStatesMngr.set_crisis_difficulty(4)
	Global.session["changes"] = []
	match pressed_button.name:
		"one":
			var _inventory := EMC_Inventory.new()
	
			_inventory.add_new_item(EMC_Item.IDs.WATER)
			_inventory.add_new_item(EMC_Item.IDs.WATER)
			_inventory.add_new_item(EMC_Item.IDs.WATER)
			_inventory.add_new_item(EMC_Item.IDs.WATER_DIRTY)
			_inventory.add_new_item(EMC_Item.IDs.WATER_DIRTY)
			_inventory.add_new_item(EMC_Item.IDs.MEAT)
			Global.session["inventory"] = _inventory
			Global.session["changes"].append("SEN_ONE")
		"two":
			var _inventory := Global.create_inventory_with_starting_items()
			_inventory.add_new_item(41)
			_inventory.add_new_item(41)
			_inventory.add_new_item(41)
			Global.session["inventory"] = _inventory
			Global.session["upgrades"] = [EMC_Upgrade.new().setup(2)]
			Global.session["changes"].append("SEN_TWO")
		"three":
			var _inventory := Global.create_inventory_with_starting_items()
			_inventory.remove_item_by_id(EMC_Item.IDs.WATER, 3)
			Global.session["inventory"] = _inventory
			Global.session["upgrades"] = [EMC_Upgrade.new().setup(EMC_Upgrade.IDs.WATER_RESERVOIR)]
			Global.session["changes"].append("SEN_THREE")
		"four":
			var _inventory := Global.create_inventory_with_starting_items()
			_inventory.remove_item_by_id(10)
			_inventory.add_new_item(4)
			_inventory.add_new_item(4)
			Global.session["inventory"] = _inventory
			Global.session["upgrades"] = [EMC_Upgrade.new().setup(4)]
			Global.session["changes"].append("SEN_FOUR")
		"five":
			var _inventory := Global.create_inventory_with_starting_items()
			_inventory.add_new_item(4)
			_inventory.add_new_item(4)
			Global.session["inventory"] = _inventory
			Global.session["changes"].append("SEN_FIVE")
			
			
	Global.goto_scene(Global.CRISIS_PHASE_SCENE)

func _on_cancel_pressed() -> void:
	Global.goto_scene(Global.MAIN_MENU_SCENE)

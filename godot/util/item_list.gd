@tool
class_name EMC_Item_List
extends Control

signal item_clicked(id : String)

@onready var list : VBoxContainer = $List
@export var LIST_ITEM_SCN := preload("res://util/simple_list_item.tscn")
@export var separation : int = 0

@export var test_items: int = 0

func _ready() -> void:
	list.remove_theme_constant_override("separation")
	list.add_theme_constant_override("separation", separation)
	
	for i in range(test_items):
		add_item([], "")

func add_item(argv : Array = [], id : String = "") -> void:
	var list_item : Button = LIST_ITEM_SCN.instantiate()
	list_item.callv("setup", argv)
	
	var callback : Callable = Callable(self, "_on_item_clicked").bind(id)
	list_item.pressed.connect(callback)
	list.add_child(list_item)

func is_empty() -> bool:
	return list.get_child_count() == 0

func clear() -> void:
	for child in list.get_children():
		list.remove_child(child)
		child.call_deferred("queue_free")

func _on_item_clicked(id : String) -> void :
	item_clicked.emit(id)

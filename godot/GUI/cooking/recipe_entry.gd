extends Button

@onready var item_slot: EMC_Item_Slot = $Margin/HBox/ItemSlot
@onready var in_text : RichTextLabel= $Margin/HBox/Text
@onready var arrow : TextureRect = $Margin/HBox/Arrow

var _text : String
var _arrow : bool
var _item: EMC_Item

func setup(p_text : String, p_item : EMC_Item, p_arrow : bool = true) -> void:
	_text = p_text
	_arrow = p_arrow
	_item = p_item
	
func _ready() -> void:
	item_slot.set_item(_item)
	in_text.set_text(_text)
	arrow.set_visible(_arrow)

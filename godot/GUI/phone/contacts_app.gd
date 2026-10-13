extends EMC_App
class_name EMC_Contacts_App

const UX_BUTTON := preload("res://util/UX_button.tscn")

@export var gsi: EMC_GSI

@onready var _list: VBoxContainer = $Margin/VBC/Scroll/List


func open() -> void:
	_refresh_list()
	show()


func back() -> void:
	close()


func close() -> void:
	hide()
	closed.emit()


func _refresh_list() -> void:
	for child in _list.get_children():
		child.queue_free()
	
	if gsi == null or gsi._npc_mngr == null:
		return
	
	for npc: EMC_NPC in gsi._npc_mngr.get_children():
		_list.add_child(_make_contact_row(npc))


func _make_contact_row(npc: EMC_NPC) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 12)
	
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var name_label := Label.new()
	name_label.text = npc.name
	info.add_child(name_label)
	
	var stage_name: String = npc.get_current_stage_name()
	var location_label := RichTextLabel.new()
	location_label.fit_content = true
	location_label.bbcode_enabled = true
	location_label.text = EMC_NPC_Needs.stage_display_name(stage_name)
	
	var needs: EMC_NPC_Needs = npc.npc_resource.get_comp(EMC_NPC_Needs)
	if needs != null:
		location_label.text += "\n[color=gray]%s[/color]" % needs.get_dominant_need_label()
	
	info.add_child(location_label)
	row.add_child(info)
	
	var call_btn: Button = UX_BUTTON.instantiate()
	call_btn.text = "Anrufen"
	call_btn.set_theme_type_variation("BlueButton")
	call_btn.pressed.connect(_on_call_pressed.bind(npc))
	row.add_child(call_btn)
	
	return row


func _on_call_pressed(npc: EMC_NPC) -> void:
	close()
	gsi.call_npc(npc)

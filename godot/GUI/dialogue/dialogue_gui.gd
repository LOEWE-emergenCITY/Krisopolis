class_name EMC_Dialogue_GUI
extends EMC_GUI

#@export var stage_mngr : EMC_StageMngr
#@export var checker: EMC_ActionConstraints
#@export var score: EMC_Scoreboard

@export var gsi: EMC_GSI

@onready var portrait_box : HBoxContainer = $Portraits
@onready var dialogue_box : RichTextLabel = $Margin/VSplitContainer/TextPanel/Box
@onready var talk_sound : AudioStreamPlayer = $TalkSound
#@onready var skip : Button = $Margin/VSplitContainer/Margin/Skip
@onready var skip: TextureButton = $Margin/VSplitContainer/TextPanel/Box/Skip

@onready var next : Button = $Margin/VSplitContainer/Margin/Next
@onready var vbc : VBoxContainer = $Margin/VSplitContainer/VBC
@onready var margin : MarginContainer = $Margin/VSplitContainer/Margin

var regex := RegEx.new()

const _icon_list : Dictionary = {
	"happy" : preload("res://assets/GUI/icons/icon_statusbar_happiness.png"),
	"health" : preload("res://assets/GUI/icons/icon_statusbar_health.png"),
	"food" : preload("res://assets/GUI/icons/icon_statusbar_nutrition.png"),
	"water" : preload("res://assets/GUI/icons/icon_statusbar_hydration.png"),
}

func _init() -> void:
	regex.compile("\\[.*?\\]")

func set_actor_portraits(portraits: Array[Texture2D], names: Array[String], flip: Array[bool]) -> void:
	if portraits.size() > 3:
		printerr("To many actors in Dialogue")
		
	var i: int = 0
	while i < 3:
		var text_rect: TextureRect = portrait_box.get_child(i)
		if i < portraits.size():
			text_rect.set_texture(portraits[i])
			text_rect.show()
			text_rect.name = names[i].to_lower()
			text_rect.set_flip_h(flip[i])
			
		else:
			text_rect.hide()
			text_rect.name = "none"
		i += 1

func open(dialogue: VRV_Script, state: VRV_InstanceData = VRV_InstanceData.new()) -> void:
	if dialogue.is_empty():
		opened.emit()
		close.call_deferred()
		return
	
	dialogue_box.clear()
	self.show()
	
	opened.emit()
	#dialogue.set_api(stage_mngr, checker)
	dialogue.gsi = gsi
	start.call_deferred(dialogue, state)

func close() -> void:
	self.hide()
	closed.emit(self)

func start(dialogue : VRV_Script, state: VRV_InstanceData) -> void:
	vbc.hide()
	margin.show()
	
	while true:
		match dialogue.get_next(state):
			[VRV_Script.TEXT, var text, var eager]:
				var talk_effect := EMC_RichTextTalkEffect.new()
				#dialogue_box.install_effect(talk_effect)
				var promise := EMC_Util.Promise.new([talk_effect.finished, skip.pressed], EMC_Util.Promise.signal_or_name)
				
				var i: int = 0
				for entry: Dictionary in text:
					var speaker: String = entry.get("speaker")
					var line: String = entry.get("line")
					var pitch: float = entry.get("pitch")
					# highlight speaking actor
					for portrait : TextureRect in portrait_box.get_children():
						if portrait.name == speaker.to_lower():
							portrait.self_modulate = Color(1.0, 1.0, 1.0)
						else:
							portrait.self_modulate = Color(0.4, 0.4, 0.4)

					# show text
					next.hide()
					
					dialogue_box.clear()
					dialogue_box.append_text(speaker.capitalize() + ":")
					dialogue_box.newline()
					talk_effect.set_char_count(regex.sub(line, "", true).length())
					#if speaker == "avatar" or speaker == "erzähler":
						#dialogue_box.push_customfx(talk_effect, {"speed" : 32.0, "pitch" : 1.0})
					#else:
					dialogue_box.push_customfx(talk_effect, {"speed" : 32.0, "pitch" : pitch})
					dialogue_box.append_text(line)
					dialogue_box.pop()

					await promise.complete
					
					#dialogue_box.custom_effects.erase(talk_effect)
					dialogue_box.clear()
					dialogue_box.append_text(speaker.capitalize() + ":")
					dialogue_box.newline()
					dialogue_box.append_text(line)
					#dialogue_box.install_effect(talk_effect)
					
					next.show()
					
					# Wait until next is clicked, except next is a choice
					if (i < text.size()-1) or not eager:
						await next.pressed
					
					i += 1
					
			[VRV_Script.CHOICE, var choices]:
				var promise: EMC_Util.Promise
				var signals: Array[Signal]
				var i : int = 0
				vbc.show()
				margin.hide()
				_disconnect_buttons() # INFO: here we could improve performance
				for button : Button in vbc.get_children():
					if i < choices.size():
						button.pressed.connect(dialogue.choose.bind(choices[i].get("id"), state))
						signals.append(button.pressed)
						button.set_text(choices[i].get("prompt"))
						button.set_button_icon(_icon_list.get(choices[i].get("icon", "none"), null))
						button.show()
					else:
						button.hide()
					i += 1
				promise = EMC_Util.Promise.new(signals, EMC_Util.Promise.signal_or_name)
				
				await promise.complete
				vbc.hide()
				margin.show()
				
			[VRV_Script.ACTORS, var textures, var names, var flip]:
				set_actor_portraits(textures, names, flip)
				
			[VRV_Script.END, _]:
				break
			_:
				break
	
	#score.add_score("tip", {"source": dialogue._start_npc_name})
	close()

func _disconnect_buttons() -> void:
	for button: Button in vbc.get_children():
		for conn: Dictionary in button.pressed.get_connections():
			if (conn["callable"] as Callable).get_object() is VRV_Script:
				button.pressed.disconnect(conn["callable"])

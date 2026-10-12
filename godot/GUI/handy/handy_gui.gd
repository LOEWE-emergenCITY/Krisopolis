#extends EMC_GUI
#class_name EMC_Handy
#
#@onready var apps : GridContainer = $VBC/Menu/VBC/Margin/Apps
#@onready var VBC : VBoxContainer = $VBC
#@onready var menu : PanelContainer = $VBC/Menu
#@onready var store : EMC_App_Store = $VBC/Store
#@onready var off : PanelContainer = $VBC/Off
#
#var active_app : EMC_App
#
#var _energy : Range = Range.new()
#
#func _init() -> void:
	#if OverworldStatesMngr.has_upgrade(5):
		#_energy.set_max(300)
	#else:
		#_energy.set_max(100)
	#_energy.set_min(0)
	#_energy.set_value(_energy.get_max())
#
#func _ready() -> void:
	#for app : EMC_App_Icon in apps.get_children():
		#app.open_app.connect(_on_open_app)
	#
	#for app_name : String in Global._apps_installed:
		#store._on_app_clicked(app_name)
	#
	#for child in VBC.get_children():
		#child.hide()
		#
	#menu.show()
#
#func _on_period_increased(new_value : int) -> void:
	#if OverworldStatesMngr.is_effective_state_eq("ElectricityState", "UNLIMITED"):
		#_energy.set_value(_energy.get_max())
	#else:
		#_energy.set_value(_energy.value -  34)
#
	## REMOVE
	## match OverworldStatesMngr.get_electricity_state():
	## 	OverworldStatesMngr.ElectricityState.NONE:
	## 		_energy.set_value(_energy.value -  34)
	## 	OverworldStatesMngr.ElectricityState.UNLIMITED:
	## 		_energy.set_value(_energy.get_max())
#
#func open() -> void:
	#self.show()
	#if _energy.value <= 0:
		#for child in VBC.get_children():
			#child.hide()
			#
		#off.show()
		#active_app = null
	#else:
		#off.hide()
		#if active_app != null:
			#active_app.start()
		#else:
			#menu.show()
	#opened.emit()
	#
#func close() -> void:
	#if off.visible or active_app == null:
		#self.hide()
		#closed.emit(self)
		#return
	#
	#if active_app != null and active_app.back():
		#active_app.hide()
		#active_app = null
		#menu.show()
	#
#func restart() -> void:
	#if active_app != null:
		#active_app.start()
#
#func add_app_icon(app : EMC_App_Icon) -> void:
	#apps.add_child(app)
	#apps.move_child(app, -2)
	#app.open_app.connect(_on_open_app)
	#if not app.app in Global._apps_installed:
		#Global._apps_installed.append(app.app)
#
#func _on_open_app(app_name : String) -> void:
	#for child in VBC.get_children():
		#if child.name == app_name:
			#if active_app == null:
				#menu.hide()
			#else:
				#active_app.hide()
				#
			#active_app = (child as EMC_App)
			#active_app.start()
			#return
	#printerr("App '" + app_name + "' not found.")
			#
#
#func _on_back_button_pressed() -> void:
	#close()
#
############################################SAVE/LOAD################################################
#
#func save() -> Dictionary:
	#var data : Dictionary = {
		#"node_path": get_path(),
		#"energy": _energy.get_value(),
	#}
	#return data
#
#
#func load_state(data : Dictionary) -> void:
	#var p_energy : int = data.get("energy", 100)
	#
	#_energy.set_value(p_energy)
	#
#func _gui_input(event : InputEvent) -> void:
	##print(event)
	#pass

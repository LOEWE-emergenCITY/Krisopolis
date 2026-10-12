extends EMC_GUI
class_name EMC_Phone

@onready var time: RichTextLabel = $VBC/Control/Margin/Panel/Time

@onready var power: TextureProgressBar = $VBC/Control/Margin/HBC/Power

@onready var online: TextureRect = $VBC/Control/Margin/HBC/Online
@onready var offline: TextureRect = $VBC/Control/Margin/HBC/Offline

@onready var app_grid: GridContainer = $VBC/Menu/Margin/Grid
@onready var apps: Control = $Apps

@onready var off: PanelContainer = $Off

@export var _day_mngr: EMC_DayMngr

const TIME_NAME := {
	0: "8:00",
	1: "9:00",
	2: "11:00",
	3: "13:00",
	4: "15:00",
	5: "18:00"
}

var current_app: EMC_App

func _ready() -> void:
	if OverworldStatesMngr.has_upgrade(5):
		power.set_max(300)
	else:
		power.set_max(100)
	power.set_min(0)
	power.set_value(power.get_max())
	
	

func open() -> void:
	time.set_text(TIME_NAME[_day_mngr._time/16])
	
	self.show()
	if power.value <= 0:
		off.show()
	else:
		off.hide()
		current_app = null
	
	if OverworldStatesMngr.is_effective_state_eq("MobileNetState", "OFFLINE"):
		offline.show()
		online.hide()
	else:
		offline.hide()
		online.show()

	opened.emit()

func _on_period_increased(new_value : int) -> void:
	if OverworldStatesMngr.is_effective_state_eq("ElectricityState", "UNLIMITED"):
		power.set_value(power.get_max())
	else:
		power.set_value(power.value -  34)

func handle_app(app_name: String) -> void:
	var app := apps.get_node(app_name)
	app.open()
	current_app = app
	current_app.closed.connect(app_closed, CONNECT_ONE_SHOT)

func close() -> void:
	if current_app != null:
		current_app.back()
	else:
		hide()
		closed.emit(self)

func app_closed() -> void:
	current_app = null
	
func save() -> Dictionary:
	var data : Dictionary = {
		"node_path": get_path(),
		"power": power.get_value(),
	}
	return data


func load_state(data : Dictionary) -> void:
	var p_power : int = data.get("power", 100)
	
	power.set_value(p_power)

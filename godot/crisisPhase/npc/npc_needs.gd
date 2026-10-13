extends Resource
class_name EMC_NPC_Needs

const NEED_THRESHOLD: float = 55.0
const TICK_HUNGER: float = 18.0
const TICK_THIRST: float = 15.0
const TICK_SOCIAL: float = 12.0
const TICK_SAFETY_CRISIS: float = 25.0
const TICK_SAFETY_NORMAL: float = 5.0

@export var hunger: float = 30.0
@export var thirst: float = 25.0
@export var social: float = 20.0
@export var safety: float = 15.0

@export var default_stage: String = "home"
@export var default_spot: String = "default"

var _last_reason: String = ""


func setup(dict: Dictionary) -> void:
	hunger = dict.get("hunger", hunger)
	thirst = dict.get("thirst", thirst)
	social = dict.get("social", social)
	safety = dict.get("safety", safety)
	default_stage = dict.get("default_stage", default_stage)
	default_spot = dict.get("default_spot", default_spot)


func bind_home(npc_stage: EMC_NPC_Stage) -> void:
	if default_stage == "home" and npc_stage != null:
		default_stage = npc_stage.stage_name
		default_spot = npc_stage.spot


func tick_period(day_period: EMC_DayMngr.DayPeriod) -> void:
	hunger = clampf(hunger + TICK_HUNGER, 0.0, 100.0)
	thirst = clampf(thirst + TICK_THIRST, 0.0, 100.0)
	
	match day_period:
		EMC_DayMngr.DayPeriod.EVENING:
			social = clampf(social + TICK_SOCIAL * 1.5, 0.0, 100.0)
		_:
			social = clampf(social + TICK_SOCIAL, 0.0, 100.0)
	
	if _is_crisis_unsafe():
		safety = clampf(safety + TICK_SAFETY_CRISIS, 0.0, 100.0)
	else:
		safety = clampf(safety + TICK_SAFETY_NORMAL, 0.0, 100.0)
		safety = clampf(safety - 8.0, 0.0, 100.0)


func choose_target() -> Dictionary:
	var dominant := _dominant_need()
	
	match dominant:
		"hunger":
			_last_reason = "sucht Essen"
			return {"stage_name": EMC_StageMngr.STAGENAME_MARKET, "spot": "default"}
		"thirst":
			_last_reason = "sucht Wasser"
			if OverworldStatesMngr.is_effective_state_eq("WaterState", "CLEAN"):
				return {"stage_name": EMC_StageMngr.STAGENAME_HOME, "spot": "start"}
			return {"stage_name": EMC_StageMngr.STAGENAME_MARKET, "spot": "default"}
		"safety":
			_last_reason = "bleibt zu Hause"
			return {"stage_name": default_stage, "spot": default_spot}
		"social":
			_last_reason = "trifft Nachbarn"
			return {"stage_name": EMC_StageMngr.STAGENAME_PARK, "spot": "default"}
		_:
			_last_reason = "ist zu Hause"
			return {"stage_name": default_stage, "spot": default_spot}


func get_last_reason() -> String:
	return _last_reason


func get_dominant_need_label() -> String:
	return _last_reason if not _last_reason.is_empty() else "verfügbar"


static func stage_display_name(stage_name: String) -> String:
	match stage_name:
		EMC_StageMngr.STAGENAME_HOME: return "Zuhause"
		EMC_StageMngr.STAGENAME_MARKET: return "Markt"
		EMC_StageMngr.STAGENAME_TOWNHALL: return "Rathaus"
		EMC_StageMngr.STAGENAME_PARK: return "Park"
		EMC_StageMngr.STAGENAME_GARDENHOUSE: return "Gartenhaus"
		EMC_StageMngr.STAGENAME_ROWHOUSE: return "Reihenhaus"
		EMC_StageMngr.STAGENAME_MANSION: return "Villa"
		EMC_StageMngr.STAGENAME_PENTHOUSE: return "Penthouse"
		EMC_StageMngr.STAGENAME_APARTMENT_DEFAULT: return "Wohnung"
		EMC_StageMngr.STAGENAME_APARTMENT_MERT: return "Merts Wohnung"
		EMC_StageMngr.STAGENAME_APARTMENT_CAMPER: return "Camper"
		_: return stage_name.capitalize()


func _dominant_need() -> String:
	var needs := {
		"hunger": hunger,
		"thirst": thirst,
		"social": social,
		"safety": safety,
	}
	
	var best_name := ""
	var best_value := NEED_THRESHOLD
	
	for need_name: String in needs:
		var value: float = needs[need_name]
		if value >= best_value:
			best_value = value
			best_name = need_name
	
	return best_name


func _is_crisis_unsafe() -> bool:
	return (
		OverworldStatesMngr.is_effective_state_eq("ElectricityState", "NONE")
		or OverworldStatesMngr.is_effective_state_eq("WaterState", "NONE")
		or OverworldStatesMngr.is_effective_state_eq("MobileNetState", "OFFLINE")
	)

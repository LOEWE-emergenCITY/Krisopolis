extends Resource
class_name EMC_NPC_Karma

enum Mood{
	BAD = 0,
	SAD = 1,
	MID = 2,
	GOOD = 3,
	HAPPY = 4
}

const string_to_mood: Dictionary[String, Mood] = {
	"BAD": Mood.BAD,
	"SAD": Mood.SAD,
	"MID": Mood.MID,
	"GOOD": Mood.GOOD,
	"HAPPY": Mood.HAPPY
}

@export var karma: float = 0
@export var mood: float = Mood.MID

func setup(dict: Dictionary) -> void:
	karma = dict.get("karma", karma)
	mood = dict.get("mood", mood)

func set_mood(p_mood: float) -> void:
	mood = p_mood

func add_mood(p_mood: float) -> void:
	mood = clamp(mood + p_mood, 0, 4)
	
func sub_mood(p_mood: float) -> void:
	mood = clamp(mood - p_mood, 0, 4)

func get_mood() -> Mood:
	return ceili(mood) as Mood

func mood_less_than(p_mood: int) -> bool:
	return get_mood() < p_mood
	
func mood_greater_than(p_mood: int) -> bool:
	return get_mood() > p_mood

func get_krama() -> float:
	return karma

func add_karma(value: float) -> void:
	karma += value
	karma = clampf(karma, -1.0, 1.0)

extends Node
## Status satu run masa percobaan: hari aktif dan upah yang sudah terkumpul.

const DAYS: Array[String] = [
	"res://resources/days/day_01.tres",
]
## Placeholder. Nilai final ditentukan tim Writer Story.
const MEDICAL_COST := 500000

const INPUT_KEYS := {
	&"move_up": [KEY_W, KEY_UP],
	&"move_down": [KEY_S, KEY_DOWN],
	&"move_left": [KEY_A, KEY_LEFT],
	&"move_right": [KEY_D, KEY_RIGHT],
	&"pause": [KEY_ESCAPE, KEY_P],
}

var current_day_index := 0
## Upah terbaik per hari (key: nomor hari). Retry menimpa nilai lama.
var wages := {}


func _ready() -> void:
	_setup_input()


func reset_run() -> void:
	current_day_index = 0
	wages.clear()


func current_day() -> DayData:
	return load(DAYS[current_day_index]) as DayData


func has_next_day() -> bool:
	return current_day_index + 1 < DAYS.size()


func advance_day() -> bool:
	if not has_next_day():
		return false
	current_day_index += 1
	return true


func record_delivery(day: DayData, wage: int) -> void:
	wages[day.day] = wage


func total_savings() -> int:
	var total := 0
	for wage: int in wages.values():
		total += wage
	return total


func rupiah(amount: int) -> String:
	var digits := str(absi(amount))
	var grouped := ""
	while digits.length() > 3:
		grouped = "." + digits.right(3) + grouped
		digits = digits.left(digits.length() - 3)
	return ("-" if amount < 0 else "") + "Rp" + digits + grouped


func _setup_input() -> void:
	for action: StringName in INPUT_KEYS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for key: Key in INPUT_KEYS[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)

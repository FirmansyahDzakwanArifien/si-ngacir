extends Node
## Status satu run masa percobaan: hari aktif dan upah yang sudah terkumpul.

## Apa yang terjadi kalau tabungan belum cukup setelah Hari 5.
enum ShortfallRule {
	## Pemain boleh mengulang hari mana pun untuk memperbaiki upah.
	REPLAY_DAYS,
	## Masa percobaan langsung berakhir dengan ending gagal.
	BAD_ENDING,
}

const DAYS: Array[String] = [
	"res://resources/days/day_01.tres",
	"res://resources/days/day_02.tres",
	"res://resources/days/day_03.tres",
	"res://resources/days/day_04.tres",
	"res://resources/days/day_05.tres",
]
## Placeholder. Upah maksimal 5 hari = Rp480.000; nilai final ditentukan tim Writer Story.
const MEDICAL_COST := 350000
## Placeholder sampai tim Writer Story memutuskan.
const SHORTFALL_RULE := ShortfallRule.REPLAY_DAYS
const LEVEL_SCENE := "res://scenes/game/level.tscn"
const ENDING_SCENE := "res://scenes/ending.tscn"
const MENU_SCENE := "res://scenes/main.tscn"

const INPUT_KEYS := {
	&"move_up": [KEY_W, KEY_UP],
	&"move_down": [KEY_S, KEY_DOWN],
	&"move_left": [KEY_A, KEY_LEFT],
	&"move_right": [KEY_D, KEY_RIGHT],
	&"pause": [KEY_ESCAPE, KEY_P],
}

var current_day_index := 0
## true saat pemain mengulang satu hari dari layar rekap; selesai hari kembali ke rekap.
var is_replay := false
## Upah terbaik per hari (key: nomor hari). Hari yang gagal tercatat Rp0.
var wages := {}


func _ready() -> void:
	_setup_input()


func reset_run() -> void:
	current_day_index = 0
	is_replay = false
	wages.clear()


func current_day() -> DayData:
	return load(DAYS[current_day_index]) as DayData


func has_next_day() -> bool:
	return current_day_index + 1 < DAYS.size()


func advance_day() -> bool:
	if is_replay or not has_next_day():
		return false
	current_day_index += 1
	return true


func replay_day(index: int) -> void:
	current_day_index = index
	is_replay = true
	get_tree().change_scene_to_file(LEVEL_SCENE)


func record_delivery(day: DayData, wage: int) -> void:
	wages[day.day] = maxi(wage, wages.get(day.day, 0))


func total_savings() -> int:
	var total := 0
	for wage: int in wages.values():
		total += wage
	return total


func savings_enough() -> bool:
	return total_savings() >= MEDICAL_COST


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

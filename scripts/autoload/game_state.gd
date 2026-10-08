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
## Placeholder. Upah maksimal 5 hari = Rp505.000 (termasuk tip Pak Ojan); nilai final ditentukan tim Writer Story.
const MEDICAL_COST := 350000
## Placeholder sampai tim Writer Story memutuskan.
const SHORTFALL_RULE := ShortfallRule.REPLAY_DAYS
const LEVEL_SCENE := "res://scenes/game/level.tscn"
const ENDING_SCENE := "res://scenes/ending.tscn"
const MENU_SCENE := "res://scenes/main.tscn"
const CUTSCENE_SCENE := "res://scenes/cutscene.tscn"
const OPENING_STORY := "res://resources/story/opening.tres"
const ENDING_SUCCESS_STORY := "res://resources/story/ending_success.tres"
const ENDING_BAD_STORY := "res://resources/story/ending_bad.tres"
const SAVE_PATH := "user://save.cfg"

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
## true setelah Hari 5 selesai; "Lanjutkan" langsung membuka layar rekap.
var probation_done := false
## Cutscene yang akan diputar dan scene tujuan setelahnya (lihat play_story).
var pending_story: StoryData
var pending_scene := ""


func _ready() -> void:
	_setup_input()
	UiTheme.apply(get_tree().root)
	load_game()


func reset_run() -> void:
	current_day_index = 0
	is_replay = false
	probation_done = false
	wages.clear()


func current_day() -> DayData:
	return load(DAYS[current_day_index]) as DayData


func has_next_day() -> bool:
	return current_day_index + 1 < DAYS.size()


func advance_day() -> bool:
	if is_replay or not has_next_day():
		return false
	current_day_index += 1
	save_game()
	return true


func finish_probation() -> void:
	if is_replay:
		return
	probation_done = true
	save_game()


func replay_day(index: int) -> void:
	current_day_index = index
	is_replay = true
	get_tree().change_scene_to_file(LEVEL_SCENE)


func record_delivery(day: DayData, wage: int) -> void:
	wages[day.day] = maxi(wage, wages.get(day.day, 0))
	save_game()


func total_savings() -> int:
	var total := 0
	for wage: int in wages.values():
		total += wage
	return total


func savings_enough() -> bool:
	return total_savings() >= MEDICAL_COST


## Putar cutscene lalu pindah ke next_scene. Tanpa cerita, langsung pindah.
func play_story(story: StoryData, next_scene: String) -> void:
	if story == null or story.pages.is_empty():
		get_tree().change_scene_to_file(next_scene)
		return
	pending_story = story
	pending_scene = next_scene
	get_tree().change_scene_to_file(CUTSCENE_SCENE)


## Cutscene penutup sesuai hasil masa percobaan (null bila pemain masih boleh mengulang hari).
func ending_story() -> StoryData:
	if savings_enough():
		return load(ENDING_SUCCESS_STORY)
	if SHORTFALL_RULE == ShortfallRule.BAD_ENDING:
		return load(ENDING_BAD_STORY)
	return null


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game() -> void:
	var config := ConfigFile.new()
	config.set_value("run", "day_index", current_day_index)
	config.set_value("run", "probation_done", probation_done)
	config.set_value("run", "wages", wages)
	config.save(SAVE_PATH)


func load_game() -> bool:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return false
	current_day_index = clampi(config.get_value("run", "day_index", 0), 0, DAYS.size() - 1)
	probation_done = config.get_value("run", "probation_done", false)
	wages = config.get_value("run", "wages", {})
	is_replay = false
	return true


func delete_save() -> void:
	reset_run()
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


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

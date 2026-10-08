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
## Dompet koin dan koleksi aksesori; tidak terhapus oleh "Mulai Baru".
const PROFILE_PATH := "user://profile.cfg"
const SHOP_SCENE := "res://scenes/shop.tscn"

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
## Koin di dompet (dibelanjakan di toko).
var wallet := 0
## Id aksesori yang sudah dibeli.
var owned: Array[StringName] = []
## Aksesori yang dipakai, key: Cosmetics.Slot.
var equipped := {}
## Tips tutorial yang sudah pernah tampil, dan apakah tips ditampilkan.
var seen_tips: Array[StringName] = []
var tips_enabled := true
## Cutscene yang akan diputar dan scene tujuan setelahnya (lihat play_story).
var pending_story: StoryData
var pending_scene := ""
## Kondisi paket pada pengiriman terakhir cukup baik (memilih cutscene malam).
var last_day_good := true


func _ready() -> void:
	_setup_input()
	UiTheme.apply(get_tree().root)
	load_game()
	load_profile()


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
	Transition.change_scene(LEVEL_SCENE)


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
		Transition.change_scene(next_scene)
		return
	pending_story = story
	pending_scene = next_scene
	Transition.change_scene(CUTSCENE_SCENE)


## Teks cutscene yang sudah diterjemahkan, dengan token tabungan diganti angka.
func story_text(text: String) -> String:
	return tr(text).format({
		"saved": rupiah(total_savings()),
		"target": rupiah(MEDICAL_COST),
		"left": rupiah(maxi(0, MEDICAL_COST - total_savings())),
	})


## Cutscene penutup sesuai hasil masa percobaan (null bila pemain masih boleh mengulang hari).
func ending_story() -> StoryData:
	if savings_enough():
		return load(ENDING_SUCCESS_STORY)
	if SHORTFALL_RULE == ShortfallRule.BAD_ENDING:
		return load(ENDING_BAD_STORY)
	return null


func add_coins(amount: int) -> void:
	wallet += amount
	save_profile()


## Beli aksesori bila koin cukup. Mengembalikan true bila berhasil (atau sudah punya).
func buy(id: StringName) -> bool:
	if id in owned:
		return true
	var entry := Cosmetics.item(id)
	if entry.is_empty() or wallet < entry["price"]:
		return false
	wallet -= entry["price"]
	owned.append(id)
	save_profile()
	return true


## Pakai aksesori milik sendiri; memakai lagi yang sedang dipakai akan melepasnya.
func toggle_equip(id: StringName) -> void:
	var entry := Cosmetics.item(id)
	if entry.is_empty() or not id in owned:
		return
	var slot: int = entry["slot"]
	if equipped.get(slot) == id:
		equipped.erase(slot)
	else:
		equipped[slot] = id
	save_profile()


func equipped_ids() -> Array:
	return equipped.values()


func mark_tip_seen(id: StringName) -> void:
	if not id in seen_tips:
		seen_tips.append(id)
		save_profile()


## Hidupkan/matikan tips. Menghidupkan kembali akan menampilkan ulang semua tips.
func set_tips_enabled(value: bool) -> void:
	tips_enabled = value
	if value:
		seen_tips.clear()
	save_profile()


func save_profile() -> void:
	var config := ConfigFile.new()
	config.set_value("profile", "wallet", wallet)
	config.set_value("profile", "owned", owned)
	config.set_value("profile", "equipped", equipped)
	config.set_value("profile", "seen_tips", seen_tips)
	config.set_value("profile", "tips_enabled", tips_enabled)
	config.save(PROFILE_PATH)


func load_profile() -> void:
	var config := ConfigFile.new()
	if config.load(PROFILE_PATH) != OK:
		return
	wallet = config.get_value("profile", "wallet", 0)
	owned.assign(config.get_value("profile", "owned", []))
	equipped = config.get_value("profile", "equipped", {})
	seen_tips.assign(config.get_value("profile", "seen_tips", []))
	tips_enabled = config.get_value("profile", "tips_enabled", true)


func reset_profile() -> void:
	wallet = 0
	owned.clear()
	equipped.clear()
	seen_tips.clear()
	tips_enabled = true
	if FileAccess.file_exists(PROFILE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PROFILE_PATH))


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

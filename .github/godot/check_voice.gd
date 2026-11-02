extends SceneTree
## Tes logika suara NPC (NpcVoiceDirector) tanpa menjalankan game. Audio dan balon ucapan
## diganti pencatat, jadi tes ini cepat dan tidak butuh perangkat audio. Jalankan dari akar
## proyek (setelah proyek pernah diimpor):
##   godot --headless --path . --script .github/godot/check_voice.gd

## Data khusus tes (bukan data game): ukuran petak 10 px, jadi radius 2 petak = 20 px.
const PROFILES := {
	&"low": {"radius": 2.0, "cooldown": Vector2(5.0, 5.0), "priority": 1, "chance": 1.0, "pitch": 0.0,
			"lines": [["L1", &"vl1"], ["L2", &"vl2"], ["L3", &"vl3"]]},
	&"high": {"radius": 2.0, "cooldown": Vector2(5.0, 5.0), "priority": 3, "chance": 1.0, "pitch": 0.0,
			"lines": [["H1", &"vh1"]]},
	&"never": {"radius": 2.0, "cooldown": Vector2(5.0, 5.0), "priority": 1, "chance": 0.0, "pitch": 0.0,
			"lines": [["N1", &"vn1"]]},
}
const FAR := Vector2(500, 0)

var _errors := 0
## Teks balon yang ditampilkan, berurutan.
var _said: Array[String] = []
## Nama suara yang diputar, berurutan.
var _played: Array[StringName] = []
var _audio_free := true
var _enabled := true


func _initialize() -> void:
	seed(7)
	_test_triggers_once_per_entry()
	_test_cooldown_and_rearm()
	_test_hysteresis()
	_test_priority_and_global_gap()
	_test_audio_busy_blocks()
	_test_enabled_gate()
	_test_chance_zero()
	_test_freed_node_pruned()
	_test_line_variety()
	_test_unknown_kind()
	print("check_voice: %d gagal" % _errors)
	quit(1 if _errors > 0 else 0)


func _test_triggers_once_per_entry() -> void:
	var d := _director()
	d.track_point(&"low", Vector2.ZERO, _say.bind("a"))
	_run(d, 1.0, FAR)
	_check(_played.is_empty(), "jauh dari NPC: tidak bicara")
	_run(d, 0.5, Vector2(10, 0))
	_check(_played.size() == 1, "masuk radius: bicara satu kali (%d)" % _played.size())
	_check(_said.size() == 1, "balon ikut tampil satu kali")
	_run(d, 30.0, Vector2(10, 0))
	_check(_played.size() == 1, "tetap di dalam radius: tidak mengulang tiap frame/cooldown (%d)" % _played.size())
	d.free()


func _test_cooldown_and_rearm() -> void:
	var d := _director()
	d.track_point(&"low", Vector2.ZERO)
	_run(d, 0.5, Vector2(10, 0))
	_check(_played.size() == 1, "bicara saat masuk")
	_run(d, 0.5, FAR)
	_run(d, 0.5, Vector2(10, 0))
	_check(_played.size() == 1, "keluar-masuk saat cooldown (5 dtk): diam (%d)" % _played.size())
	_run(d, 10.0, Vector2(10, 0))
	_check(_played.size() == 1, "cooldown habis tapi tidak menjauh: tetap diam")
	_run(d, 0.5, FAR)
	_run(d, 0.5, Vector2(10, 0))
	_check(_played.size() == 2, "menjauh lalu kembali setelah cooldown: bicara lagi (%d)" % _played.size())
	d.free()


func _test_hysteresis() -> void:
	var d := _director()
	d.track_point(&"low", Vector2.ZERO)
	_run(d, 0.5, Vector2(15, 0))
	_run(d, 6.0, Vector2(15, 0))
	# 23 px: di luar radius (20) tapi belum melewati batas keluar (20 x 1,35 = 27).
	_run(d, 0.5, Vector2(23, 0))
	_run(d, 0.5, Vector2(15, 0))
	_check(_played.size() == 1, "goyang di tepi radius tidak memicu ulang (%d)" % _played.size())
	d.free()


func _test_priority_and_global_gap() -> void:
	var d := _director()
	d.track_point(&"low", Vector2.ZERO, _say.bind("low"))
	d.track_point(&"high", Vector2(5, 0), _say.bind("high"))
	_run(d, 0.5, Vector2(3, 0))
	_check(_said == ["high"], "dua NPC terpicu bersamaan: hanya prioritas tertinggi (%s)" % [_said])
	var late := _director()
	late.track_point(&"low", Vector2(100, 0), _say.bind("late"))
	late.track_point(&"high", Vector2(300, 0), _say.bind("first"))
	_run(late, 0.5, Vector2(300, 0))
	_run(late, 0.5, Vector2(100, 0))
	_check(_said == ["first"], "NPC lain 0,5 dtk kemudian: dicegah jeda global (%s)" % [_said])
	_run(late, 3.0, Vector2(100, 0))
	_check(_said == ["first"], "NPC yang terhalang tidak antre menyusul saat masih di dalam")
	d.free()
	late.free()


func _test_audio_busy_blocks() -> void:
	var d := _director()
	d.track_point(&"low", Vector2.ZERO, _say.bind("x"))
	_audio_free = false
	_run(d, 0.5, Vector2(10, 0))
	_check(_played.is_empty() and _said.is_empty(), "audio sibuk dengan suara lebih penting: NPC diam, balon tidak tampil")
	_audio_free = true
	d.free()


func _test_enabled_gate() -> void:
	var d := _director()
	d.track_point(&"low", Vector2.ZERO, Callable(), _is_enabled)
	_enabled = false
	_run(d, 0.5, Vector2(10, 0))
	_check(_played.is_empty(), "syarat 'enabled' salah: diam")
	_enabled = true
	_run(d, 0.5, FAR)
	_run(d, 0.5, Vector2(10, 0))
	_check(_played.size() == 1, "syarat terpenuhi saat masuk radius lagi: bicara (%d)" % _played.size())
	d.free()


func _test_chance_zero() -> void:
	var d := _director()
	d.track_point(&"never", Vector2.ZERO)
	for i in 5:
		_run(d, 0.5, Vector2(10, 0))
		_run(d, 0.5, FAR)
	_check(_played.is_empty(), "peluang 0: tidak pernah bicara")
	d.free()


func _test_freed_node_pruned() -> void:
	var d := _director()
	var npc := Node2D.new()
	d.track_node(&"low", npc, Vector2.ZERO)
	_check(d.speaker_count() == 1, "NPC terdaftar")
	npc.free()
	_run(d, 0.5, FAR)
	_check(d.speaker_count() == 0, "node yang sudah dibebaskan dibuang dari daftar")
	d.free()


func _test_line_variety() -> void:
	var d := _director()
	d.track_point(&"low", Vector2.ZERO, _say.bind("v"))
	for i in 30:
		_run(d, 0.5, Vector2(10, 0))
		_run(d, 0.5, FAR)
		_run(d, 6.0, FAR)
	var repeats := 0
	for i in range(1, _played.size()):
		if _played[i] == _played[i - 1]:
			repeats += 1
	_check(_played.size() == 30, "30 kunjungan: 30 ucapan (%d)" % _played.size())
	_check(repeats == 0, "dialog tidak mengulang kalimat yang sama berturut-turut (%d ulangan)" % repeats)
	_check(_played.has(&"vl1") and _played.has(&"vl2") and _played.has(&"vl3"), "semua variasi dialog muncul")
	d.free()


func _test_unknown_kind() -> void:
	var d := _director()
	d.track_point(&"tidak_ada", Vector2.ZERO)
	_check(d.speaker_count() == 0, "jenis NPC tak dikenal tidak didaftarkan")
	d.free()


## Direktur baru dengan data tes; pencatat dikosongkan.
func _director() -> NpcVoiceDirector:
	_said.clear()
	_played.clear()
	_audio_free = true
	_enabled = true
	var d := NpcVoiceDirector.new()
	d.tile = 10.0
	d.profiles = PROFILES
	d.can_speak = _can_speak
	d.speak_audio = _play
	return d


## Majukan waktu `seconds` dengan langkah 1/20 detik sambil Masbro berada di `listener`.
func _run(d: NpcVoiceDirector, seconds: float, listener: Vector2) -> void:
	for i in roundi(seconds * 20.0):
		d.tick(0.05, listener)


func _can_speak(_priority: int) -> bool:
	return _audio_free


func _play(voice: StringName, _pitch: float, _priority: int) -> bool:
	_played.append(voice)
	return true


func _say(text: String, label: String) -> void:
	_said.append(label)


func _is_enabled() -> bool:
	return _enabled


func _check(condition: bool, label: String) -> void:
	if not condition:
		_errors += 1
		printerr("GAGAL: " + label)

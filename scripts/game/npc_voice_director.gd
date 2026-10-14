class_name NpcVoiceDirector
extends Node
## Mengatur NPC yang "bicara" saat Masbro mendekat.
##
## Aturan:
##  - Picu SEKALI saat Masbro masuk radius NPC (bukan tiap frame).
##  - NPC baru boleh bicara lagi setelah Masbro keluar dari radius DAN cooldown selesai.
##  - Satu suara pada satu waktu: bila beberapa NPC terpicu bersamaan, hanya yang prioritasnya
##    tertinggi (lalu yang terdekat) bicara; ada jeda global antar dua suara mana pun.
##  - Dialog dipilih acak dan tidak mengulang kalimat yang sama berturut-turut.
##
## Kelas ini tidak memakai node tree maupun autoload: level menyambungkan `can_speak` dan
## `speak_audio` ke AudioManager, dan tiap NPC mendaftar dengan callback `say` untuk balon
## ucapannya. Itu membuatnya mudah diuji (lihat .github/godot/check_voice.gd).
## Tidak ada timer atau sinyal: semua hitung mundur memakai delta dari level, jadi ikut
## berhenti saat pause dan tidak ada yang tertinggal saat level ditutup.

## Seberapa sering jarak diperiksa (detik). Satu langkah Masbro ~0,12 detik dan radius
## minimal 2 petak, jadi 10 kali per detik cukup rapat.
const SCAN_INTERVAL := 0.1
## Jeda minimum antar dua suara NPC mana pun (detik).
const GLOBAL_GAP := 2.0
## NPC dianggap ditinggalkan setelah jarak melewati radius dikali nilai ini. Selisihnya
## mencegah bolak-balik di tepi radius memicu dialog berulang.
const EXIT_FACTOR := 1.35

## Ukuran petak (piksel); radius di NpcVoices dalam satuan petak.
var tile := 48.0
## Data per jenis NPC (bawaan: NpcVoices.PROFILES; tes boleh menggantinya).
var profiles: Dictionary = NpcVoices.PROFILES
## func(priority: int) -> bool: boleh bicara sekarang? (bawaan: selalu boleh)
var can_speak := Callable()
## func(voice: StringName, pitch_variation: float, priority: int) -> Variant: putar suaranya.
var speak_audio := Callable()

var _speakers: Array[Speaker] = []
var _since_scan := 0.0
var _gap_left := 0.0
var _last_line := {}


## Satu NPC yang bisa bicara.
class Speaker extends RefCounted:
	var kind: StringName
	var radius := 0.0
	## Node yang diikuti (NPC bergerak); null untuk titik tetap.
	var node: Node2D
	var tracks_node := false
	var offset := Vector2.ZERO
	var point := Vector2.ZERO
	## func(text: String) -> void: tampilkan balon ucapan (boleh kosong untuk NPC tanpa balon).
	var say := Callable()
	## func() -> bool: NPC ini boleh bicara sekarang? (boleh kosong = selalu boleh)
	var enabled := Callable()
	var inside := false
	var cooldown := 0.0

	func is_alive() -> bool:
		return not tracks_node or is_instance_valid(node)

	func is_enabled() -> bool:
		return not enabled.is_valid() or bool(enabled.call())

	func position() -> Vector2:
		return node.position + offset if tracks_node else point


## Daftarkan NPC yang bergerak (kucing, pejalan kaki) atau diam tapi punya node (pelanggan,
## kios). `offset` menggeser titik acuan dari pojok node ke tengahnya. Node yang sudah
## dibebaskan otomatis dibuang dari daftar.
func track_node(kind: StringName, node: Node2D, offset: Vector2, say := Callable(), enabled := Callable()) -> void:
	var speaker := _make_speaker(kind, say, enabled)
	if speaker == null:
		return
	speaker.node = node
	speaker.tracks_node = true
	speaker.offset = offset
	_speakers.append(speaker)


## Daftarkan NPC diam tanpa node sendiri (misalnya gerobak yang digambar langsung di papan).
func track_point(kind: StringName, point: Vector2, say := Callable(), enabled := Callable()) -> void:
	var speaker := _make_speaker(kind, say, enabled)
	if speaker == null:
		return
	speaker.point = point
	_speakers.append(speaker)


## Panggil tiap frame dari level (hanya saat bermain dan tidak pause). `listener` = titik
## tengah Masbro dalam koordinat papan.
func tick(delta: float, listener: Vector2) -> void:
	_since_scan += delta
	if _since_scan < SCAN_INTERVAL:
		return
	var step := _since_scan
	_since_scan = 0.0
	_gap_left = maxf(0.0, _gap_left - step)

	var entered: Array[Speaker] = []
	for i in range(_speakers.size() - 1, -1, -1):
		var speaker := _speakers[i]
		if not speaker.is_alive():
			_speakers.remove_at(i)
			continue
		speaker.cooldown = maxf(0.0, speaker.cooldown - step)
		var distance := listener.distance_to(speaker.position())
		if speaker.inside:
			if distance > speaker.radius * EXIT_FACTOR:
				speaker.inside = false
		elif distance <= speaker.radius:
			# Masuk radius: ini satu-satunya saat NPC boleh terpicu. Bila cooldown belum habis,
			# NPC tetap ditandai "di dalam" dan baru bisa terpicu lagi setelah Masbro menjauh.
			speaker.inside = true
			if speaker.cooldown <= 0.0 and speaker.is_enabled():
				entered.append(speaker)
	if not entered.is_empty():
		_speak(_best(entered, listener))


## Lupakan semua NPC (level ditutup).
func clear() -> void:
	_speakers.clear()


func speaker_count() -> int:
	return _speakers.size()


func _make_speaker(kind: StringName, say: Callable, enabled: Callable) -> Speaker:
	var profile: Dictionary = profiles.get(kind, {})
	if profile.is_empty():
		push_warning("NpcVoiceDirector: jenis NPC tidak dikenal: %s" % kind)
		return null
	var speaker := Speaker.new()
	speaker.kind = kind
	speaker.radius = float(profile.get("radius", 0.0)) * tile
	speaker.say = say
	speaker.enabled = enabled
	return speaker


## Yang prioritasnya tertinggi; bila sama, yang terdekat dengan Masbro.
func _best(candidates: Array[Speaker], listener: Vector2) -> Speaker:
	var best: Speaker = null
	var best_priority := -1
	var best_distance := INF
	for speaker in candidates:
		var priority := int(profiles[speaker.kind].get("priority", 0))
		var distance := listener.distance_to(speaker.position())
		if priority > best_priority or (priority == best_priority and distance < best_distance):
			best = speaker
			best_priority = priority
			best_distance = distance
	return best


func _speak(speaker: Speaker) -> void:
	# Kandidat yang kalah atau terhalang dianggap sudah "lewat": mereka baru bisa bicara lagi
	# setelah Masbro menjauh dan kembali. Itu mencegah antrean dialog yang menumpuk.
	if _gap_left > 0.0:
		return
	var profile: Dictionary = profiles[speaker.kind]
	if randf() > float(profile.get("chance", 1.0)):
		return
	var priority := int(profile.get("priority", 0))
	if can_speak.is_valid() and not can_speak.call(priority):
		return
	var lines: Array = profile.get("lines", [])
	if lines.is_empty():
		return
	var line: Array = lines[_next_line(speaker.kind, lines.size())]
	var cooldown: Vector2 = profile.get("cooldown", Vector2(15.0, 25.0))
	speaker.cooldown = randf_range(cooldown.x, cooldown.y)
	_gap_left = GLOBAL_GAP
	if speaker.say.is_valid():
		speaker.say.call(line[0])
	if speak_audio.is_valid():
		speak_audio.call(line[1], float(profile.get("pitch", 0.05)), priority)


## Indeks dialog acak yang berbeda dari yang terakhir diucapkan jenis NPC ini.
func _next_line(kind: StringName, count: int) -> int:
	var index := randi() % count
	if count > 1 and index == int(_last_line.get(kind, -1)):
		index = (index + 1 + randi() % (count - 1)) % count
	_last_line[kind] = index
	return index

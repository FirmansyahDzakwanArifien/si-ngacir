extends Node
## Musik dan efek suara. File dicari berdasarkan nama di assets/audio/{music,sfx}/
## dengan ekstensi .ogg, .wav, atau .mp3, jadi tim Audio cukup mengganti file
## dengan nama yang sama. Nama yang belum punya file akan diam saja.
##
## Suara NPC (celoteh saat Masbro mendekat) punya bus sendiri, Voice, dan hanya satu suara
## NPC yang berbunyi pada satu waktu. Selama NPC bicara, bus Music diturunkan sebentar (ducking).

## Mute dinyalakan/dimatikan (tombol M atau Pengaturan).
signal muted_changed(value: bool)

const MUSIC_DIR := "res://assets/audio/music/"
const SFX_DIR := "res://assets/audio/sfx/"
const EXTENSIONS: Array[String] = [".ogg", ".wav", ".mp3"]
const SETTINGS_PATH := "user://settings.cfg"
const SFX_VOICES := 8
## Lama fade saat berganti lagu (detik).
const MUSIC_FADE := 0.35
## Suara NPC dicari di sini dulu, lalu di folder SFX (supaya meow.wav dan horn.wav bisa dipakai).
const VOICE_DIR := "res://assets/audio/voice/"
## Saat NPC bicara, bus Music turun sebanyak ini (dB), naik lagi perlahan setelahnya.
const DUCK_DB := -8.0
const DUCK_ATTACK := 0.12
const DUCK_RELEASE := 0.6

var music_volume := 0.7
var sfx_volume := 0.8
var voice_volume := 0.9
## Semua suara dibisukan. Terpisah dari volume supaya pengaturan volume tidak hilang.
var muted := false
var fullscreen := false
## Kode bahasa: "id" (Indonesia) atau "en" (Inggris).
var language := ""
## Getar HP saat menabrak / paket rusak.
var vibration := true
## Tampilan 3D (beta) saat mengantar; hanya di build yang punya modul 3D.
var view_3d := false

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _next_voice := 0
var _streams := {}
var _current_music := &""
var _music_tween: Tween
var _voice_player: AudioStreamPlayer
## Prioritas suara NPC yang sedang berbunyi (suara berprioritas lebih tinggi boleh memotongnya).
var _voice_priority := 0
var _ducked := false
var _duck_db := 0.0
var _duck_tween: Tween
## Gestur pertama pemain sudah terjadi (membuka audio browser di build web).
var _gesture_seen := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus(&"Music")
	_ensure_bus(&"SFX")
	_ensure_bus(&"Voice")
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = &"Music"
	add_child(_music_player)
	for i in SFX_VOICES:
		var player := AudioStreamPlayer.new()
		player.bus = &"SFX"
		add_child(player)
		_sfx_players.append(player)
	_voice_player = AudioStreamPlayer.new()
	_voice_player.bus = &"Voice"
	add_child(_voice_player)
	# _process hanya dipakai saat ducking, untuk melepas ducking begitu suara NPC selesai.
	set_process(false)
	load_settings()
	get_tree().auto_accept_quit = false
	# Semua tombol di game otomatis berbunyi klik.
	get_tree().node_added.connect(_on_node_added)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		# Tab browser / aplikasi HP ditinggal: diamkan suara sampai kembali.
		if mutes_in_background():
			AudioServer.set_bus_mute(0, true)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_APPLICATION_RESUMED:
		AudioServer.set_bus_mute(0, false)


## Web dan HP: suara berhenti saat game tidak dilihat. Desktop tetap berbunyi.
func mutes_in_background() -> bool:
	return OS.has_feature("web") or OS.has_feature("mobile")


## Perangkat yang mungkin bisa bergetar (HP, atau browser di layar sentuh).
func can_vibrate() -> bool:
	return OS.has_feature("mobile") or (OS.has_feature("web") and DisplayServer.is_touchscreen_available())


## Getarkan HP selama duration_ms (diabaikan bila tidak didukung atau dimatikan).
func vibrate(duration_ms: int) -> void:
	if vibration and can_vibrate():
		Input.vibrate_handheld(duration_ms)


## Tutup game dengan rapi: hentikan semua suara dulu, beri waktu audio server
## melepas stream, baru keluar. Dipakai tombol Keluar dan tombol tutup jendela.
func quit_game() -> void:
	_music_player.stop()
	_music_player.stream = null
	_voice_player.stop()
	_voice_player.stream = null
	for player in _sfx_players:
		player.stop()
		player.stream = null
	_streams.clear()
	get_tree().create_timer(0.1).timeout.connect(get_tree().quit)


func play_sfx(sfx_name: StringName, pitch_variation := 0.0) -> void:
	var stream := _find_stream(SFX_DIR, sfx_name)
	if stream == null:
		return
	var player := _sfx_players[_next_voice]
	_next_voice = (_next_voice + 1) % _sfx_players.size()
	player.stream = stream
	player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	player.play()


## Putar lagu (di-loop). Bila lagu lain sedang diputar, yang lama di-fade out dulu.
## `fallback`: nama lagu cadangan bila file `music_name` belum ada.
func play_music(music_name: StringName, fallback := &"") -> void:
	if fallback != &"" and _find_stream(MUSIC_DIR, music_name) == null:
		music_name = fallback
	if music_name == _current_music and _music_player.playing:
		return
	_current_music = music_name
	var stream := _find_stream(MUSIC_DIR, music_name)
	if _music_tween:
		_music_tween.kill()
	if not _music_player.playing:
		_start_music(stream)
		return
	_music_tween = create_tween()
	_music_tween.tween_property(_music_player, "volume_db", -40.0, MUSIC_FADE)
	_music_tween.tween_callback(_start_music.bind(stream, -40.0))
	_music_tween.tween_property(_music_player, "volume_db", 0.0, MUSIC_FADE)


func current_music() -> StringName:
	return _current_music


## Apakah suara NPC dengan `priority` ini boleh berbunyi sekarang. Suara yang sedang berbunyi
## hanya bisa dipotong oleh suara berprioritas lebih tinggi, jadi NPC tidak saling tumpang tindih.
func can_play_voice(priority := 0) -> bool:
	if _voice_player == null:
		return false
	return not _voice_player.playing or priority > _voice_priority


## Putar suara NPC (celoteh/dialog) lewat bus Voice dan turunkan musik selama berbunyi.
## Mengembalikan true bila benar-benar diputar; false bila sedang ada suara yang lebih penting
## atau file-nya belum ada (game tetap jalan, NPC cukup menampilkan balon ucapan).
func play_voice(voice_name: StringName, pitch_variation := 0.05, priority := 0) -> bool:
	if not can_play_voice(priority):
		return false
	var stream := _find_voice_stream(voice_name)
	if stream == null:
		return false
	_voice_player.stop()
	_voice_player.stream = stream
	_voice_player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	_voice_priority = priority
	_voice_player.play()
	# Tidak ada gunanya menurunkan musik bila suara NPC sendiri tidak terdengar.
	if not muted and voice_volume > 0.001:
		_set_ducking(true)
	return true


func is_voice_playing() -> bool:
	return _voice_player != null and _voice_player.playing


## Hentikan suara NPC dan lepas ducking (dipakai saat level ditutup atau hari selesai).
func stop_voices() -> void:
	if _voice_player == null:
		return
	_voice_player.stop()
	_voice_priority = 0
	_set_ducking(false)


func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_apply_volume(&"Music", music_volume)


func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	_apply_volume(&"SFX", sfx_volume)


func set_voice_volume(value: float) -> void:
	voice_volume = clampf(value, 0.0, 1.0)
	_apply_volume(&"Voice", voice_volume)


## Bisukan / nyalakan semua suara. Musik tetap berjalan (hanya busnya yang dibisukan),
## jadi saat dinyalakan lagi lagunya langsung ada tanpa mulai dari awal.
func set_muted(value: bool) -> void:
	if value == muted:
		return
	muted = value
	_refresh_buses()
	muted_changed.emit(muted)


## Dipakai tombol M: ganti status mute dan simpan supaya diingat saat game dibuka lagi.
func toggle_mute() -> void:
	set_muted(not muted)
	save_settings()


func set_fullscreen(value: bool) -> void:
	fullscreen = value
	DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN if value else DisplayServer.WINDOW_MODE_WINDOWED)


func set_language(code: String) -> void:
	language = code
	TranslationServer.set_locale(code)


func save_settings() -> void:
	var config := ConfigFile.new()
	# Bagian lain (misalnya aksesibilitas) ikut disimpan di file yang sama.
	config.load(SETTINGS_PATH)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "voice_volume", voice_volume)
	config.set_value("audio", "muted", muted)
	config.set_value("display", "fullscreen", fullscreen)
	config.set_value("display", "language", language)
	config.set_value("display", "vibration", vibration)
	config.set_value("display", "view_3d", view_3d)
	config.save(SETTINGS_PATH)


func load_settings() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	muted = config.get_value("audio", "muted", false)
	set_music_volume(config.get_value("audio", "music_volume", music_volume))
	set_sfx_volume(config.get_value("audio", "sfx_volume", sfx_volume))
	set_voice_volume(config.get_value("audio", "voice_volume", voice_volume))
	# Bawaan: Indonesia bila perangkat berbahasa Indonesia, selain itu Inggris.
	var default_language := "id" if OS.get_locale_language() == "id" else "en"
	set_language(config.get_value("display", "language", default_language))
	vibration = config.get_value("display", "vibration", true)
	view_3d = config.get_value("display", "view_3d", false)
	if not OS.has_feature("web") and DisplayServer.get_name() != "headless":
		set_fullscreen(config.get_value("display", "fullscreen", fullscreen))


func _find_stream(directory: String, stream_name: StringName) -> AudioStream:
	var key := directory + stream_name
	if not _streams.has(key):
		_streams[key] = null
		for extension in EXTENSIONS:
			if ResourceLoader.exists(key + extension):
				_streams[key] = load(key + extension)
				break
	return _streams[key]


func _find_voice_stream(voice_name: StringName) -> AudioStream:
	var stream := _find_stream(VOICE_DIR, voice_name)
	if stream == null:
		stream = _find_stream(SFX_DIR, voice_name)
	return stream


func _start_music(stream: AudioStream, volume_db := 0.0) -> void:
	_music_player.volume_db = volume_db
	if stream == null:
		_music_player.stop()
		return
	_make_looping(stream)
	_music_player.stream = stream
	_music_player.play()


func _make_looping(stream: AudioStream) -> void:
	if stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = roundi(wav.get_length() * wav.mix_rate)
	elif stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true


func _apply_volume(bus_name: StringName, value: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index == -1:
		return
	var db := linear_to_db(maxf(value, 0.0001))
	if bus_name == &"Music":
		db += _duck_db
	AudioServer.set_bus_volume_db(index, db)
	# Mute pemain memakai flag bus Music/SFX/Voice, bukan bus Master: Master dipakai untuk
	# membisukan game saat tab/aplikasi ditinggal (lihat _notification) dan tidak boleh bentrok.
	AudioServer.set_bus_mute(index, muted or value <= 0.001)


func _refresh_buses() -> void:
	_apply_volume(&"Music", music_volume)
	_apply_volume(&"SFX", sfx_volume)
	_apply_volume(&"Voice", voice_volume)


## Turunkan (active) atau naikkan lagi volume musik secara halus.
func _set_ducking(active: bool) -> void:
	if active == _ducked:
		return
	_ducked = active
	set_process(active)
	if _duck_tween:
		_duck_tween.kill()
	_duck_tween = create_tween()
	_duck_tween.tween_method(_set_duck_db, _duck_db, DUCK_DB if active else 0.0,
			DUCK_ATTACK if active else DUCK_RELEASE)


func _set_duck_db(value: float) -> void:
	_duck_db = value
	_apply_volume(&"Music", music_volume)


## Lepas ducking begitu suara NPC selesai (stop() tidak memancarkan sinyal finished,
## jadi dicek tiap frame, hanya selama ducking aktif).
func _process(_delta: float) -> void:
	if _ducked and not _voice_player.playing:
		_voice_priority = 0
		_set_ducking(false)


func _input(event: InputEvent) -> void:
	if InputMap.has_action(&"mute") and event.is_action_pressed(&"mute"):
		toggle_mute()
		return
	# Browser baru membuka audio setelah gestur pertama. Bila lagu sudah diminta tapi belum
	# berbunyi saat itu, mulai ulang supaya tidak diam sampai pindah layar.
	if not _gesture_seen and event.is_pressed() \
			and (event is InputEventKey or event is InputEventMouseButton or event is InputEventScreenTouch):
		_gesture_seen = true
		_resume_music()


func _resume_music() -> void:
	if _current_music == &"" or _music_player.playing:
		return
	if _music_tween and _music_tween.is_running():
		return
	_start_music(_find_stream(MUSIC_DIR, _current_music))


## Bus Music dan SFX sudah didefinisikan di res://default_bus_layout.tres. Membuat bus saat
## game berjalan membuat audio web Godot 4.3 menyambung bus secara melingkar sehingga
## browser membisukan semua suara; fungsi ini hanya cadangan bila file layout hilang.
func _ensure_bus(bus_name: StringName) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	push_warning("Bus audio %s tidak ada di default_bus_layout.tres" % bus_name)
	AudioServer.add_bus()
	var index := AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, &"Master")


func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		(node as BaseButton).pressed.connect(play_sfx.bind(&"click"))

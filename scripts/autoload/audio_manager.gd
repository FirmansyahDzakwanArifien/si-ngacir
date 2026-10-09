extends Node
## Musik dan efek suara. File dicari berdasarkan nama di assets/audio/{music,sfx}/
## dengan ekstensi .ogg, .wav, atau .mp3, jadi tim Audio cukup mengganti file
## dengan nama yang sama. Nama yang belum punya file akan diam saja.

const MUSIC_DIR := "res://assets/audio/music/"
const SFX_DIR := "res://assets/audio/sfx/"
const EXTENSIONS: Array[String] = [".ogg", ".wav", ".mp3"]
const SETTINGS_PATH := "user://settings.cfg"
const SFX_VOICES := 8
## Lama fade saat berganti lagu (detik).
const MUSIC_FADE := 0.35

var music_volume := 0.7
var sfx_volume := 0.8
var fullscreen := false
## Kode bahasa: "id" (Indonesia) atau "en" (Inggris).
var language := ""
## Getar HP saat menabrak / paket rusak.
var vibration := true

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _next_voice := 0
var _streams := {}
var _current_music := &""
var _music_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus(&"Music")
	_ensure_bus(&"SFX")
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = &"Music"
	add_child(_music_player)
	for i in SFX_VOICES:
		var player := AudioStreamPlayer.new()
		player.bus = &"SFX"
		add_child(player)
		_sfx_players.append(player)
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
func play_music(music_name: StringName) -> void:
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


func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_apply_volume(&"Music", music_volume)


func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	_apply_volume(&"SFX", sfx_volume)


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
	config.set_value("display", "fullscreen", fullscreen)
	config.set_value("display", "language", language)
	config.set_value("display", "vibration", vibration)
	config.save(SETTINGS_PATH)


func load_settings() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	set_music_volume(config.get_value("audio", "music_volume", music_volume))
	set_sfx_volume(config.get_value("audio", "sfx_volume", sfx_volume))
	# Bawaan: Indonesia bila perangkat berbahasa Indonesia, selain itu Inggris.
	var default_language := "id" if OS.get_locale_language() == "id" else "en"
	set_language(config.get_value("display", "language", default_language))
	vibration = config.get_value("display", "vibration", true)
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
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(value, 0.0001)))
	AudioServer.set_bus_mute(index, value <= 0.001)


func _ensure_bus(bus_name: StringName) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	AudioServer.add_bus()
	var index := AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, &"Master")


func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		(node as BaseButton).pressed.connect(play_sfx.bind(&"click"))

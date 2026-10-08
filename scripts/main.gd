extends Control
## Layar judul Si Ngacir.

const PREMISE := "Adik Masbro jatuh sakit dan butuh biaya pengobatan dalam lima hari. " \
		+ "Satu-satunya jalan: lolos masa percobaan sebagai kurir Ngacir Express. " \
		+ "Kejar ETA, jaga paket, dan jangan sampai upah terpotong denda."

var _column: VBoxContainer
var _new_game_button: Button
var _confirming_new_game := false
var _first_button: Button


func _ready() -> void:
	get_tree().paused = false
	AudioManager.play_music(&"menu")
	# Kembali ke progres terakhir yang tersimpan (misalnya keluar dari tengah hari).
	if not GameState.load_game():
		GameState.reset_run()

	var background := ColorRect.new()
	background.color = GameHud.INK
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	_column = VBoxContainer.new()
	_column.custom_minimum_size = Vector2(520, 0)
	_column.add_theme_constant_override("separation", 14)
	center.add_child(_column)

	_column.add_child(_label("SI NGACIR", 64, GameHud.GOLD))
	_column.add_child(_label("Trobos Ajalah!", 24, Color.WHITE))
	var premise := _label(PREMISE, 16, Color(1, 1, 1, 0.75))
	premise.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_column.add_child(premise)

	var first: Button
	if GameState.has_save():
		var progress := "Rekap Masa Percobaan" if GameState.probation_done \
				else "Hari %d" % (GameState.current_day_index + 1)
		first = _button("Lanjutkan (%s)" % progress, _on_continue_pressed, 44)
		_new_game_button = _button("Mulai Baru", _on_new_game_pressed)
	else:
		first = _button("Mulai Hari 1", _start_new_game, 44)

	_button("Pengaturan", _on_settings_pressed)
	if not OS.has_feature("web"):
		_button("Keluar", get_tree().quit)

	_first_button = first
	first.grab_focus.call_deferred()


func _on_continue_pressed() -> void:
	var scene := GameState.ENDING_SCENE if GameState.probation_done else GameState.LEVEL_SCENE
	get_tree().change_scene_to_file(scene)


func _on_settings_pressed() -> void:
	var settings := SettingsPanel.new()
	settings.closed.connect(func() -> void: _first_button.grab_focus())
	add_child(settings)


func _on_new_game_pressed() -> void:
	# Tekan dua kali supaya progres tidak terhapus tanpa sengaja.
	if not _confirming_new_game:
		_confirming_new_game = true
		_new_game_button.text = "Yakin? Progres lama akan hilang. Tekan lagi"
		return
	_start_new_game()


func _start_new_game() -> void:
	GameState.delete_save()
	get_tree().change_scene_to_file(GameState.LEVEL_SCENE)


func _button(text: String, on_pressed: Callable, height := 36) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, height)
	button.pressed.connect(on_pressed)
	_column.add_child(button)
	return button


func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label

extends Control
## Layar judul Si Ngacir.

var _column: VBoxContainer
var _buttons: VBoxContainer
var _new_game_button: Button
var _confirming_new_game := false
var _first_button: Button


func _ready() -> void:
	get_tree().paused = false
	AudioManager.play_music(&"menu")
	# Kembali ke progres terakhir yang tersimpan (misalnya keluar dari tengah hari).
	if not GameState.load_game():
		GameState.reset_run()

	add_child(MenuBackdrop.new())

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.offset_bottom = -90
	add_child(center)

	_column = VBoxContainer.new()
	_column.custom_minimum_size = Vector2(360, 0)
	_column.add_theme_constant_override("separation", 12)
	center.add_child(_column)

	var logo := Label.new()
	logo.text = "SI NGACIR"
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logo.add_theme_font_override("font", UiTheme.font(700))
	logo.add_theme_font_size_override("font_size", 78)
	logo.add_theme_color_override("font_color", Palette.YELLOW)
	logo.add_theme_color_override("font_outline_color", Palette.OUTLINE)
	logo.add_theme_constant_override("outline_size", 16)
	logo.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.25))
	logo.add_theme_constant_override("shadow_offset_y", 6)
	_column.add_child(logo)
	_wobble(logo)

	var tagline := PanelContainer.new()
	tagline.add_theme_stylebox_override("panel", UiTheme.pill(Palette.CORAL))
	tagline.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var tagline_label := Label.new()
	tagline_label.text = "Trobos Ajalah!"
	tagline_label.add_theme_font_override("font", UiTheme.font(600))
	tagline_label.add_theme_font_size_override("font_size", 24)
	tagline_label.add_theme_color_override("font_color", Palette.WHITE)
	tagline.add_child(tagline_label)
	_column.add_child(tagline)

	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 6)
	_column.add_child(gap)

	var card := PanelContainer.new()
	_column.add_child(card)
	_buttons = VBoxContainer.new()
	_buttons.add_theme_constant_override("separation", 12)
	card.add_child(_buttons)

	var first: Button
	if GameState.has_save():
		var progress := "Rekap Masa Percobaan" if GameState.probation_done \
				else "Hari %d" % (GameState.current_day_index + 1)
		first = _button("Lanjutkan (%s)" % progress, _on_continue_pressed, 52)
		_new_game_button = _button("Mulai Baru", _on_new_game_pressed)
	else:
		first = _button("Mulai Hari 1", _start_new_game, 52)
	_button("Pengaturan", _on_settings_pressed)
	if not OS.has_feature("web"):
		_button("Keluar", AudioManager.quit_game)

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
		_new_game_button.text = "Yakin? Progres lama hilang. Tekan lagi"
		return
	_start_new_game()


func _start_new_game() -> void:
	GameState.delete_save()
	GameState.play_story(load(GameState.OPENING_STORY), GameState.LEVEL_SCENE)


func _button(text: String, on_pressed: Callable, height := 44) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, height)
	if height > 44:
		button.add_theme_font_size_override("font_size", 24)
	button.pressed.connect(on_pressed)
	_buttons.add_child(button)
	return button


func _wobble(node: Control) -> void:
	# Logo bergoyang pelan supaya layar judul terasa hidup.
	node.resized.connect(func() -> void: node.pivot_offset = node.size / 2.0)
	var tween := node.create_tween().set_loops()
	tween.tween_property(node, "rotation_degrees", 2.5, 1.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "rotation_degrees", -2.5, 1.2).set_trans(Tween.TRANS_SINE)

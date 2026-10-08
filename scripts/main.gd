extends Control
## Layar judul Si Ngacir.

## Tinggi jalan di bagian bawah latar (MenuBackdrop); menu tidak boleh menutupinya.
const STREET_HEIGHT := 144.0

var _column: VBoxContainer
var _new_game_button: Button
var _confirming_new_game := false
var _first_button: Button
var _logo: Label


func _ready() -> void:
	get_tree().paused = false
	AudioManager.play_music(&"menu")
	# Kembali ke progres terakhir yang tersimpan (misalnya keluar dari tengah hari).
	if not GameState.load_game():
		GameState.reset_run()

	add_child(MenuBackdrop.new())

	# Area di atas jalan; isi menu di tengahnya.
	var area := MarginContainer.new()
	area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	area.add_theme_constant_override("margin_bottom", int(STREET_HEIGHT) + 8)
	area.add_theme_constant_override("margin_top", 12)
	add_child(area)
	var center := CenterContainer.new()
	area.add_child(center)

	_column = VBoxContainer.new()
	_column.add_theme_constant_override("separation", 10)
	center.add_child(_column)

	_logo = Label.new()
	_logo.text = "SI NGACIR"
	_logo.set_meta(Accessibility.FIXED_SIZE_META, true)
	_logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_logo.add_theme_font_override("font", UiTheme.font(700))
	_logo.add_theme_color_override("font_color", Palette.YELLOW)
	_logo.add_theme_color_override("font_outline_color", Palette.OUTLINE)
	_logo.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.25))
	_logo.add_theme_constant_override("shadow_offset_y", 6)
	_column.add_child(_logo)
	_wobble(_logo)

	var tagline := PanelContainer.new()
	tagline.add_theme_stylebox_override("panel", UiTheme.pill(Palette.CORAL))
	tagline.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var tagline_label := Label.new()
	tagline_label.text = "Trobos Ajalah!"
	tagline_label.add_theme_font_override("font", UiTheme.font(600))
	tagline_label.add_theme_font_size_override("font_size", 22)
	tagline_label.add_theme_color_override("font_color", Palette.WHITE)
	tagline.add_child(tagline_label)
	_column.add_child(tagline)

	var card := PanelContainer.new()
	_column.add_child(card)
	var inside := VBoxContainer.new()
	inside.add_theme_constant_override("separation", 10)
	card.add_child(inside)
	inside.add_child(_wallet_row())

	var first: Button
	var secondary: Array[Button] = []
	if GameState.has_save():
		var progress := tr("Rekap Masa Percobaan") if GameState.probation_done \
				else tr("Hari %d") % (GameState.current_day_index + 1)
		first = _button(tr("Lanjutkan (%s)") % progress, _on_continue_pressed)
		_new_game_button = _button("Mulai Baru", _on_new_game_pressed)
		secondary.append(_new_game_button)
	else:
		first = _button("Mulai Hari 1", _start_new_game)
	UiTheme.make_primary(first)
	inside.add_child(first)
	secondary.append(_button("Toko Masbro", Transition.change_scene.bind(GameState.SHOP_SCENE)))
	secondary.append(_button("Pengaturan", _on_settings_pressed))
	if not OS.has_feature("web"):
		secondary.append(_button("Keluar", AudioManager.quit_game))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	for button in secondary:
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(button)
	inside.add_child(grid)

	var version := Label.new()
	version.text = "v%s" % ProjectSettings.get_setting("application/config/version", "")
	version.add_theme_font_size_override("font_size", 13)
	version.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	version.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	version.offset_left = -80
	version.offset_right = -10
	version.offset_top = 8
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(version)

	Screen.layout_changed.connect(_fit)
	_fit()
	_first_button = first
	first.grab_focus.call_deferred()


## Ukuran logo dan kartu mengikuti lebar & tinggi layar.
func _fit() -> void:
	var view := get_viewport().get_visible_rect().size
	_column.custom_minimum_size.x = Screen.card_width(380)
	var short := view.y - STREET_HEIGHT < 420.0
	var logo_size := 52 if short or Screen.is_compact() else 76
	if short and Accessibility.text_size > 0:
		# Teks menu diperbesar: logo mengalah supaya menu tetap di atas jalan.
		logo_size = 40
	_logo.add_theme_font_size_override("font_size", logo_size)
	_logo.add_theme_constant_override("outline_size", 12 if short else 16)


func _wallet_row() -> Control:
	var pill := PanelContainer.new()
	pill.add_theme_stylebox_override("panel", UiTheme.pill(Palette.CREAM_DARK))
	pill.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	pill.add_child(row)
	var coin := TextureRect.new()
	coin.texture = SpriteLibrary.hires("icon_coin", 1.0)
	coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin.custom_minimum_size = Vector2(22, 22)
	coin.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(coin)
	var label := Label.new()
	label.text = tr("%d koin") % GameState.wallet
	label.add_theme_font_override("font", UiTheme.font(600))
	label.add_theme_font_size_override("font_size", 16)
	row.add_child(label)
	return pill


func _on_continue_pressed() -> void:
	var scene := GameState.ENDING_SCENE if GameState.probation_done else GameState.LEVEL_SCENE
	Transition.change_scene(scene)


func _on_settings_pressed() -> void:
	var settings := SettingsPanel.new()
	settings.allow_language = true
	settings.closed.connect(func() -> void: _first_button.grab_focus())
	add_child(settings)


func _on_new_game_pressed() -> void:
	# Tekan dua kali supaya progres tidak terhapus tanpa sengaja.
	if not _confirming_new_game:
		_confirming_new_game = true
		_new_game_button.text = "Yakin? Tekan lagi"
		return
	_start_new_game()


func _start_new_game() -> void:
	GameState.delete_save()
	GameState.play_story(load(GameState.OPENING_STORY), GameState.LEVEL_SCENE)


func _button(text: String, on_pressed: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 44)
	button.pressed.connect(on_pressed)
	return button


func _wobble(node: Control) -> void:
	# Logo bergoyang pelan supaya layar judul terasa hidup.
	node.resized.connect(func() -> void: node.pivot_offset = node.size / 2.0)
	var tween := node.create_tween().set_loops()
	tween.tween_property(node, "rotation_degrees", 2.5, 1.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "rotation_degrees", -2.5, 1.2).set_trans(Tween.TRANS_SINE)

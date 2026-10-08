class_name SettingsPanel
extends ColorRect
## Panel pengaturan: suara, layar, bahasa, tips, dan aksesibilitas.
## Dipakai di menu utama dan menu pause.

signal closed

const LANGUAGES := [["id", "Bahasa Indonesia"], ["en", "English"]]

## Tampilkan pilihan bahasa (hanya dari menu utama; mengganti bahasa memuat ulang layar).
var allow_language := false

var _scroll: ScrollContainer


func _init() -> void:
	color = Color(0.1, 0.09, 0.2, 0.55)
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP


func _ready() -> void:
	UiTheme.attach(self)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(Screen.card_width(420), 0)
	center.add_child(panel)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 12)
	panel.add_child(outer)

	var title := Label.new()
	title.text = "PENGATURAN"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", UiTheme.font(600))
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Palette.YELLOW)
	title.add_theme_color_override("font_outline_color", Palette.OUTLINE)
	title.add_theme_constant_override("outline_size", 9)
	outer.add_child(title)

	# Isi panel bisa digulir bila layar pendek (HP mendatar).
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(_scroll)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 12)
	_scroll.add_child(column)

	var music := _slider_row(column, "Musik", AudioManager.music_volume, AudioManager.set_music_volume)
	_slider_row(column, "Efek Suara", AudioManager.sfx_volume, _on_sfx_changed)

	if not OS.has_feature("web"):
		var fullscreen := CheckButton.new()
		fullscreen.text = "Layar Penuh"
		fullscreen.button_pressed = AudioManager.fullscreen
		fullscreen.toggled.connect(AudioManager.set_fullscreen)
		column.add_child(fullscreen)

	if allow_language:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		var label := Label.new()
		label.text = "Bahasa"
		label.custom_minimum_size = Vector2(110, 0)
		row.add_child(label)
		var picker := OptionButton.new()
		picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for i in LANGUAGES.size():
			picker.add_item(LANGUAGES[i][1], i)
			if LANGUAGES[i][0] == AudioManager.language:
				picker.select(i)
		picker.item_selected.connect(_on_language_selected)
		row.add_child(picker)
		column.add_child(row)

	column.add_child(_section("Aksesibilitas"))
	_option_row(column, "Ukuran teks", Accessibility.TEXT_SCALE_NAMES, Accessibility.text_size,
			Accessibility.set_text_size)
	_option_row(column, "Buta warna", Accessibility.COLOR_MODE_NAMES, Accessibility.color_mode,
			Accessibility.set_color_mode)
	var motion := CheckButton.new()
	motion.text = "Kurangi efek gerak"
	motion.button_pressed = Accessibility.reduce_motion
	motion.toggled.connect(Accessibility.set_reduce_motion)
	column.add_child(motion)

	column.add_child(_section("Lainnya"))
	var tips := CheckButton.new()
	tips.text = "Tips tutorial (nyalakan untuk mengulang)"
	tips.button_pressed = GameState.tips_enabled
	tips.toggled.connect(GameState.set_tips_enabled)
	column.add_child(tips)

	var back := Button.new()
	back.text = "Kembali"
	back.custom_minimum_size = Vector2(0, 36)
	back.pressed.connect(close)
	outer.add_child(back)
	music.grab_focus.call_deferred()
	_fit_scroll.call_deferred(column)


## Tinggi area gulir: setinggi isinya, tapi tidak melebihi layar.
func _fit_scroll(column: Control) -> void:
	var available := get_viewport().get_visible_rect().size.y - 190.0
	_scroll.custom_minimum_size.y = minf(column.get_combined_minimum_size().y, maxf(120.0, available))


func close() -> void:
	AudioManager.save_settings()
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") or event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func _on_language_selected(index: int) -> void:
	AudioManager.set_language(LANGUAGES[index][0])
	AudioManager.save_settings()
	# Muat ulang layar supaya semua teks memakai bahasa baru.
	get_tree().reload_current_scene()


func _on_sfx_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)
	AudioManager.play_sfx(&"star")


func _section(caption: String) -> Label:
	var label := Label.new()
	label.text = caption
	label.add_theme_font_override("font", UiTheme.font(600))
	label.add_theme_color_override("font_color", Palette.TEAL_DARK)
	return label


func _option_row(parent: Control, caption: String, items: Array, selected: int, on_selected: Callable) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var label := Label.new()
	label.text = caption
	label.custom_minimum_size = Vector2(110, 0)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(label)
	var picker := OptionButton.new()
	picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	picker.clip_text = true
	for i in items.size():
		picker.add_item(tr(items[i]), i)
	picker.select(selected)
	picker.item_selected.connect(on_selected)
	row.add_child(picker)
	parent.add_child(row)


func _slider_row(parent: Control, caption: String, value: float, on_changed: Callable) -> HSlider:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var label := Label.new()
	label.text = caption
	label.custom_minimum_size = Vector2(110, 0)
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.value_changed.connect(on_changed)
	row.add_child(slider)
	parent.add_child(row)
	return slider

class_name SettingsPanel
extends ColorRect
## Panel pengaturan: volume musik, volume efek suara, dan layar penuh.
## Dipakai di menu utama dan menu pause.

signal closed


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
	panel.custom_minimum_size = Vector2(420, 0)
	center.add_child(panel)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	panel.add_child(column)

	var title := Label.new()
	title.text = "PENGATURAN"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", UiTheme.font(600))
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Palette.YELLOW)
	title.add_theme_color_override("font_outline_color", Palette.OUTLINE)
	title.add_theme_constant_override("outline_size", 9)
	column.add_child(title)

	var music := _slider_row(column, "Musik", AudioManager.music_volume, AudioManager.set_music_volume)
	_slider_row(column, "Efek Suara", AudioManager.sfx_volume, _on_sfx_changed)

	if not OS.has_feature("web"):
		var fullscreen := CheckButton.new()
		fullscreen.text = "Layar Penuh"
		fullscreen.button_pressed = AudioManager.fullscreen
		fullscreen.toggled.connect(AudioManager.set_fullscreen)
		column.add_child(fullscreen)

	var back := Button.new()
	back.text = "Kembali"
	back.custom_minimum_size = Vector2(0, 36)
	back.pressed.connect(close)
	column.add_child(back)
	music.grab_focus.call_deferred()


func close() -> void:
	AudioManager.save_settings()
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") or event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func _on_sfx_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)
	AudioManager.play_sfx(&"star")


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

extends Control
## Layar judul Si Ngacir.

const LEVEL_SCENE := "res://scenes/game/level.tscn"
const PREMISE := "Adik Masbro jatuh sakit dan butuh biaya pengobatan dalam lima hari. " \
		+ "Satu-satunya jalan: lolos masa percobaan sebagai kurir Ngacir Express. " \
		+ "Kejar ETA, jaga paket, dan jangan sampai upah terpotong denda."


func _ready() -> void:
	get_tree().paused = false
	GameState.reset_run()

	var background := ColorRect.new()
	background.color = GameHud.INK
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(520, 0)
	column.add_theme_constant_override("separation", 14)
	center.add_child(column)

	column.add_child(_label("SI NGACIR", 64, GameHud.GOLD))
	column.add_child(_label("Trobos Ajalah!", 24, Color.WHITE))
	var premise := _label(PREMISE, 16, Color(1, 1, 1, 0.75))
	premise.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(premise)

	var start := Button.new()
	start.text = "Mulai Hari 1"
	start.custom_minimum_size = Vector2(0, 44)
	start.pressed.connect(_on_start_pressed)
	column.add_child(start)

	if not OS.has_feature("web"):
		var quit := Button.new()
		quit.text = "Keluar"
		quit.custom_minimum_size = Vector2(0, 36)
		quit.pressed.connect(get_tree().quit)
		column.add_child(quit)

	start.grab_focus.call_deferred()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(LEVEL_SCENE)


func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label

extends Control
## Memutar GameState.pending_story halaman demi halaman, lalu pindah ke GameState.pending_scene.
## Halaman bisa berupa narasi atau dialog (potret + papan nama tokoh).
## Enter / Spasi / klik: tampilkan teks penuh atau lanjut halaman. Esc: lewati semua.

const IMAGE_DIR := "res://assets/story/"
const CHARS_PER_SECOND := 45.0

var _story: StoryData
var _page := -1
var _image: TextureRect
var _image_name := ""
var _text: Label
var _hint: Label
var _portrait_frame: PanelContainer
var _portrait: TextureRect
var _name_plate: PanelContainer
var _name_label: Label
var _speaker := ""
var _typing: Tween


func _ready() -> void:
	AudioManager.play_music(&"menu")
	_story = GameState.pending_story
	if _story == null or _story.pages.is_empty():
		_finish.call_deferred()
		return

	var background := ColorRect.new()
	background.color = Palette.SKY_DEEP.lerp(Palette.NIGHT, 0.35)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	column.offset_left = 16
	column.offset_right = -16
	column.offset_top = 56
	column.offset_bottom = -24
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 18)
	add_child(column)

	_image = TextureRect.new()
	var image_width := Screen.card_width(480, 40)
	_image.custom_minimum_size = Vector2(image_width, image_width * 270.0 / 480.0)
	_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_image.pivot_offset = _image.custom_minimum_size / 2.0
	column.add_child(_image)

	var card := PanelContainer.new()
	# Kotak teks tidak melebar berlebihan di layar lebar.
	card.custom_minimum_size.x = Screen.card_width(640, 16)
	card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var box := UiTheme.card()
	box.set_content_margin_all(16 if Screen.is_compact() else 20)
	card.add_theme_stylebox_override("panel", box)
	column.add_child(card)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	card.add_child(row)

	_portrait_frame = PanelContainer.new()
	_portrait_frame.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var portrait_size := 76.0 if Screen.is_compact() else 104.0
	_portrait_frame.custom_minimum_size = Vector2(portrait_size, portrait_size)
	_portrait_frame.pivot_offset = _portrait_frame.custom_minimum_size / 2.0
	row.add_child(_portrait_frame)
	_portrait = TextureRect.new()
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait_frame.add_child(_portrait)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 6)
	row.add_child(text_box)

	_name_plate = PanelContainer.new()
	_name_plate.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_name_label = Label.new()
	_name_label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_name_label.add_theme_font_override("font", UiTheme.font(600))
	_name_label.add_theme_font_size_override("font_size", 17)
	_name_label.add_theme_color_override("font_color", Palette.WHITE)
	_name_label.add_theme_color_override("font_outline_color", Palette.OUTLINE)
	_name_label.add_theme_constant_override("outline_size", 5)
	_name_plate.add_child(_name_label)
	text_box.add_child(_name_plate)

	_text = Label.new()
	_text.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_text.custom_minimum_size = Vector2(0, 84)
	_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_text.add_theme_font_size_override("font_size", 20 if Screen.is_compact() else 22)
	text_box.add_child(_text)

	_hint = Label.new()
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hint.add_theme_font_size_override("font_size", 14)
	_hint.add_theme_color_override("font_color", Palette.TEXT_SOFT)
	text_box.add_child(_hint)

	var skip := Button.new()
	skip.text = "Lewati (Esc)"
	skip.focus_mode = Control.FOCUS_NONE
	skip.add_theme_font_size_override("font_size", 16)
	skip.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	skip.offset_left = -150
	skip.offset_top = 12
	skip.offset_right = -12
	skip.offset_bottom = 52
	skip.pressed.connect(_finish)
	add_child(skip)

	_next_page()


func _unhandled_input(event: InputEvent) -> void:
	if _story == null:
		return
	if event.is_action_pressed(&"pause") or event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_finish()
	elif event.is_action_pressed(&"ui_accept") \
			or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		get_viewport().set_input_as_handled()
		advance()


## Selesaikan teks yang sedang diketik, atau pindah ke halaman berikutnya.
func advance() -> void:
	if _typing and _typing.is_running():
		_typing.kill()
		_text.visible_ratio = 1.0
		_update_hint()
	else:
		_next_page()


## Pembicara halaman yang sedang tampil ("" = narasi).
func current_speaker() -> String:
	return _speaker


func _next_page() -> void:
	_page += 1
	if _page >= _story.pages.size():
		_finish()
		return
	_show_image(_story.image_at(_page))
	_show_speaker(_story.speaker_at(_page))

	_text.text = GameState.story_text(_story.pages[_page])
	_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if _speaker == "" else HORIZONTAL_ALIGNMENT_LEFT
	_text.visible_ratio = 0.0
	_hint.text = ""
	_typing = create_tween()
	_typing.tween_property(_text, "visible_ratio", 1.0, _text.text.length() / CHARS_PER_SECOND)
	_typing.tween_callback(_update_hint)


func _show_image(image_name: String) -> void:
	if image_name == _image_name:
		return
	_image_name = image_name
	_image.texture = null
	if image_name != "":
		# PNG dari Illustrator diutamakan, SVG bawaan sebagai cadangan.
		for extension in [".png", ".svg"]:
			if ResourceLoader.exists(IMAGE_DIR + image_name + extension):
				_image.texture = load(IMAGE_DIR + image_name + extension)
				break
	_image.visible = _image.texture != null
	if _image.visible and _page > 0 and not AudioManager.reduce_motion:
		_image.modulate.a = 0.0
		create_tween().tween_property(_image, "modulate:a", 1.0, 0.25)


func _show_speaker(entry: String) -> void:
	var parsed := Speakers.parse(entry)
	var id := parsed[0]
	var changed := id != _speaker
	_speaker = id
	_name_plate.visible = id != ""
	_portrait_frame.visible = id != ""
	if id == "":
		return
	var color := Speakers.color(id)
	_name_label.text = tr(Speakers.display_name(id))
	_name_plate.add_theme_stylebox_override("panel", UiTheme.pill(color))
	var frame := UiTheme.pill(color.lerp(Palette.WHITE, 0.6))
	frame.set_corner_radius_all(64)
	frame.set_content_margin_all(4)
	_portrait_frame.add_theme_stylebox_override("panel", frame)
	_portrait.texture = Speakers.portrait(id, parsed[1])
	if changed and not AudioManager.reduce_motion:
		_portrait_frame.scale = Vector2(0.7, 0.7)
		create_tween().tween_property(_portrait_frame, "scale", Vector2.ONE, 0.25) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _update_hint() -> void:
	var last := _page == _story.pages.size() - 1
	_hint.text = tr("Enter / klik untuk mulai") if last else tr("Enter / klik untuk lanjut")


func _finish() -> void:
	if GameState.pending_scene == "":
		return
	var next_scene := GameState.pending_scene
	GameState.pending_scene = ""
	GameState.pending_story = null
	_story = null
	Transition.change_scene(next_scene)

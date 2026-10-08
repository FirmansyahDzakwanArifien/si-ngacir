extends Control
## Memutar GameState.pending_story halaman demi halaman, lalu pindah ke GameState.pending_scene.
## Enter / Spasi / klik: tampilkan teks penuh atau lanjut halaman. Esc: lewati semua.

const IMAGE_DIR := "res://assets/story/"
const CHARS_PER_SECOND := 45.0

var _story: StoryData
var _page := -1
var _image: TextureRect
var _text: Label
var _hint: Label
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
	column.offset_left = 60
	column.offset_right = -60
	column.offset_top = 48
	column.offset_bottom = -32
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 24)
	add_child(column)

	_image = TextureRect.new()
	var image_width := Screen.card_width(480, 70)
	_image.custom_minimum_size = Vector2(image_width, image_width * 270.0 / 480.0)
	_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	column.add_child(_image)

	var card := PanelContainer.new()
	# Kotak teks tidak melebar berlebihan di layar lebar.
	card.custom_minimum_size.x = Screen.card_width(640, 30)
	card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var text_box := VBoxContainer.new()
	text_box.add_theme_constant_override("separation", 10)
	card.add_child(text_box)
	column.add_child(card)

	_text = Label.new()
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text.custom_minimum_size = Vector2(0, 90)
	_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_text.add_theme_font_size_override("font_size", 22)
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


func _next_page() -> void:
	_page += 1
	if _page >= _story.pages.size():
		_finish()
		return
	var image_name := _story.images[_page] if _page < _story.images.size() else ""
	_image.texture = null
	if image_name != "":
		# PNG dari Illustrator diutamakan, SVG bawaan sebagai cadangan.
		for extension in [".png", ".svg"]:
			if ResourceLoader.exists(IMAGE_DIR + image_name + extension):
				_image.texture = load(IMAGE_DIR + image_name + extension)
				break
	_image.visible = _image.texture != null

	_text.text = _story.pages[_page]
	_text.visible_ratio = 0.0
	_hint.text = ""
	_typing = create_tween()
	_typing.tween_property(_text, "visible_ratio", 1.0, _text.text.length() / CHARS_PER_SECOND)
	_typing.tween_callback(_update_hint)


func _update_hint() -> void:
	var last := _page == _story.pages.size() - 1
	_hint.text = "Enter / klik untuk mulai" if last else "Enter / klik untuk lanjut"


func _finish() -> void:
	if GameState.pending_scene == "":
		return
	var next_scene := GameState.pending_scene
	GameState.pending_scene = ""
	GameState.pending_story = null
	_story = null
	Transition.change_scene(next_scene)

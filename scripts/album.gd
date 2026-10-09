extends Control
## Album Cerita: tonton ulang cutscene yang sudah pernah diputar. Yang belum terbuka tampil "???".

const IMAGE_DIR := "res://assets/story/"

var _scroll: ScrollContainer
var _first_button: Button


func _ready() -> void:
	AudioManager.play_music(&"menu")
	add_child(MenuBackdrop.new())

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var card := PanelContainer.new()
	center.add_child(card)
	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(Screen.card_width(600, 40), 0)
	column.add_theme_constant_override("separation", 10)
	card.add_child(column)

	var header := HBoxContainer.new()
	column.add_child(header)
	var title := Label.new()
	title.text = "ALBUM CERITA"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_override("font", UiTheme.font(600))
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Palette.YELLOW)
	title.add_theme_color_override("font_outline_color", Palette.OUTLINE)
	title.add_theme_constant_override("outline_size", 9)
	header.add_child(title)
	var counter := Label.new()
	counter.text = tr("%d/%d cerita terbuka") % [StoryAlbum.unlocked_count(), StoryAlbum.entries().size()]
	counter.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	counter.add_theme_font_size_override("font_size", 15)
	counter.add_theme_color_override("font_color", Palette.TEXT_SOFT)
	header.add_child(counter)

	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.follow_focus = true
	column.add_child(_scroll)
	var grid := GridContainer.new()
	grid.columns = 1 if Screen.is_compact() else 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	_scroll.add_child(grid)
	for entry in StoryAlbum.entries():
		var button := _story_button(entry)
		grid.add_child(button)
		if _first_button == null and not button.disabled:
			_first_button = button

	var note := Label.new()
	note.text = "Cerita terbuka setelah kamu memainkannya."
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 14)
	note.add_theme_color_override("font_color", Palette.TEXT_SOFT)
	column.add_child(note)

	var back := Button.new()
	back.text = "Kembali"
	back.custom_minimum_size = Vector2(0, 44)
	back.pressed.connect(Transition.change_scene.bind(GameState.MENU_SCENE))
	column.add_child(back)
	if _first_button == null:
		_first_button = back

	Screen.layout_changed.connect(_fit_scroll)
	_fit_scroll.call_deferred()
	_focus_first.call_deferred()


## Fokus ke cerita pertama setelah ukuran daftar final, supaya daftar mulai dari atas.
func _focus_first() -> void:
	await get_tree().process_frame
	_first_button.grab_focus()
	_scroll.scroll_vertical = 0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") or event.is_action_pressed(&"pause"):
		get_viewport().set_input_as_handled()
		Transition.change_scene(GameState.MENU_SCENE)


func _story_button(entry: Dictionary) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 64)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_constant_override("icon_max_width", 84)
	button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	var path: String = entry["path"]
	if not GameState.is_story_seen(path):
		button.text = "???"
		button.disabled = true
		return button
	button.text = entry["title"]
	var story := load(path) as StoryData
	if story:
		var image := story.image_at(0)
		if ResourceLoader.exists(IMAGE_DIR + image + ".png"):
			button.icon = load(IMAGE_DIR + image + ".png")
		elif ResourceLoader.exists(IMAGE_DIR + image + ".svg"):
			button.icon = load(IMAGE_DIR + image + ".svg")
	button.pressed.connect(GameState.play_story.bind(story, GameState.ALBUM_SCENE))
	return button


## Daftar cerita bisa digulir; tingginya mengikuti layar supaya tombol Kembali tetap terlihat.
func _fit_scroll() -> void:
	if not is_instance_valid(_scroll):
		return
	var grid := _scroll.get_child(0) as Control
	var available := get_viewport().get_visible_rect().size.y - 200.0
	_scroll.custom_minimum_size.y = clampf(grid.get_combined_minimum_size().y, 64.0, maxf(available, 64.0))

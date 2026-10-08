extends Control
## Toko Masbro: beli dan pakai aksesori dengan koin dari pengiriman.

var _slot := Cosmetics.Slot.HAT
var _wallet_label: Label
var _grid: GridContainer
var _tabs: Array[Button] = []
var _preview_holder: Node2D
var _preview_body: AnimatedSprite2D
var _preview_accessories: Node2D
var _message: Label


func _ready() -> void:
	AudioManager.play_music(&"menu")
	add_child(MenuBackdrop.new())

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var card := PanelContainer.new()
	center.add_child(card)
	var column := VBoxContainer.new()
	# Margin 40: menyisakan tepi layar + padding kartu.
	column.custom_minimum_size = Vector2(Screen.card_width(560, 40), 0)
	column.add_theme_constant_override("separation", 10)
	card.add_child(column)

	var header := HBoxContainer.new()
	column.add_child(header)
	var title := Label.new()
	title.text = "TOKO MASBRO"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_override("font", UiTheme.font(600))
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Palette.YELLOW)
	title.add_theme_color_override("font_outline_color", Palette.OUTLINE)
	title.add_theme_constant_override("outline_size", 9)
	header.add_child(title)
	header.add_child(_wallet_pill())

	var body: BoxContainer = VBoxContainer.new() if Screen.is_compact() else HBoxContainer.new()
	body.add_theme_constant_override("separation", 14)
	column.add_child(body)
	body.add_child(_build_preview())

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 8)
	body.add_child(right)
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 6)
	right.add_child(tabs)
	for slot: int in Cosmetics.SLOT_NAMES:
		var tab := Button.new()
		tab.text = Cosmetics.SLOT_NAMES[slot]
		tab.toggle_mode = true
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab.add_theme_font_size_override("font_size", 16)
		tab.pressed.connect(_select_slot.bind(slot))
		tabs.add_child(tab)
		_tabs.append(tab)
	_grid = GridContainer.new()
	_grid.columns = 2
	_grid.add_theme_constant_override("h_separation", 8)
	_grid.add_theme_constant_override("v_separation", 8)
	right.add_child(_grid)

	_message = Label.new()
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.add_theme_color_override("font_color", Palette.TEXT_SOFT)
	_message.add_theme_font_size_override("font_size", 15)
	_message.text = "Kumpulkan koin di jalan untuk belanja."
	column.add_child(_message)

	var back := Button.new()
	back.text = "Kembali"
	back.custom_minimum_size = Vector2(0, 44)
	back.pressed.connect(Transition.change_scene.bind(GameState.MENU_SCENE))
	column.add_child(back)

	_select_slot(Cosmetics.Slot.HAT)
	back.grab_focus.call_deferred()


func _wallet_pill() -> Control:
	var pill := PanelContainer.new()
	pill.add_theme_stylebox_override("panel", UiTheme.pill(Palette.CREAM_DARK))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	pill.add_child(row)
	var coin := TextureRect.new()
	coin.texture = SpriteLibrary.hires("icon_coin", 1.0)
	coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin.custom_minimum_size = Vector2(24, 24)
	coin.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(coin)
	_wallet_label = Label.new()
	_wallet_label.add_theme_font_override("font", UiTheme.font(600))
	_wallet_label.add_theme_font_size_override("font_size", 20)
	row.add_child(_wallet_label)
	return pill


## Masbro besar yang memakai aksesori terpilih.
func _build_preview() -> Control:
	var box := PanelContainer.new()
	box.add_theme_stylebox_override("panel", UiTheme.card(Palette.SKY, Palette.OUTLINE))
	box.custom_minimum_size = Vector2(200, 170 if Screen.is_compact() else 230)
	box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var anchor := Control.new()
	box.add_child(anchor)
	_preview_holder = Node2D.new()
	var zoom := 2.6 if Screen.is_compact() else 3.4
	_preview_holder.scale = Vector2(zoom, zoom)
	_preview_holder.position = Vector2(-4 + (3.4 - zoom) * 20.0, 10 - (3.4 - zoom) * 30.0)
	anchor.add_child(_preview_holder)
	var frames := SpriteLibrary.frames({&"idle": "masbro_idle", &"walk": "masbro_walk"}, Vector2i(48, 48), 6.0)
	if frames:
		_preview_body = SpriteLibrary.animated(frames)
		_preview_holder.add_child(_preview_body)
		_preview_body.play(&"idle")
		_preview_body.frame_changed.connect(func() -> void:
			if _preview_accessories:
				Cosmetics.sync_bob(_preview_accessories, _preview_body))
	_refresh_preview()
	return box


func _refresh_preview() -> void:
	if _preview_accessories:
		_preview_accessories.queue_free()
	_preview_accessories = Cosmetics.dress(_preview_holder, GameState.equipped_ids())


func _select_slot(slot: Cosmetics.Slot) -> void:
	_slot = slot
	for i in _tabs.size():
		_tabs[i].button_pressed = i == slot
	_refresh_items()


func _refresh_items() -> void:
	_wallet_label.text = str(GameState.wallet)
	for child in _grid.get_children():
		child.queue_free()
	for entry: Dictionary in Cosmetics.items_for(_slot):
		_grid.add_child(_item_button(entry))


func _item_button(entry: Dictionary) -> Button:
	var id: StringName = entry["id"]
	var owned: bool = id in GameState.owned
	var worn: bool = GameState.equipped.get(entry["slot"]) == id
	var button := Button.new()
	button.custom_minimum_size = Vector2(150, 64)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.icon = Cosmetics.icon(id)
	button.expand_icon = true
	button.add_theme_constant_override("icon_max_width", 44)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 15)
	var status := "Dipakai" if worn else ("Pakai" if owned else "%d koin" % entry["price"])
	button.text = "%s\n%s" % [entry["name"], status]
	if worn:
		button.add_theme_stylebox_override("normal", UiTheme.pill(Palette.TEAL))
		button.add_theme_color_override("font_color", Palette.WHITE)
	elif not owned and GameState.wallet < entry["price"]:
		button.modulate = Color(1, 1, 1, 0.6)
	button.pressed.connect(_on_item_pressed.bind(id))
	return button


func _on_item_pressed(id: StringName) -> void:
	var entry := Cosmetics.item(id)
	if not id in GameState.owned:
		if not GameState.buy(id):
			_message.text = "Koin belum cukup. Butuh %d koin lagi." % (entry["price"] - GameState.wallet)
			AudioManager.play_sfx(&"hit")
			return
		_message.text = "%s terbeli!" % entry["name"]
		AudioManager.play_sfx(&"delivery")
	GameState.toggle_equip(id)
	if GameState.equipped.get(entry["slot"]) != id:
		_message.text = "%s dilepas." % entry["name"]
	_refresh_preview()
	_refresh_items()

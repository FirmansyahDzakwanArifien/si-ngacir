extends Control
## Rekap masa percobaan setelah Hari 5: upah per hari, total tabungan, dan ending.

const SUCCESS_TEXT := "Paket VIP sampai di tangan Bu Direktur. Masbro resmi diangkat menjadi " \
		+ "kurir tetap Ngacir Express, dan tabungannya cukup untuk menyembuhkan adiknya. Trobos Ajalah!"
const SHORTFALL_TEXT := "Tabungan masih kurang %s. Ulangi hari mana pun untuk memperbaiki upah. " \
		+ "Upah terbaik tiap hari yang dihitung."
const BAD_ENDING_TEXT := "Masa percobaan berakhir, tapi tabungan Masbro belum cukup untuk biaya " \
		+ "pengobatan adiknya. Besok ia harus mencari jalan lain."


func _ready() -> void:
	get_tree().paused = false
	GameState.is_replay = false
	AudioManager.play_music(&"menu")

	add_child(MenuBackdrop.new())

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var card := PanelContainer.new()
	center.add_child(card)
	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(Screen.card_width(500, 40), 0)
	column.add_theme_constant_override("separation", 8)
	card.add_child(column)

	var enough := GameState.savings_enough()
	var can_replay := not enough and GameState.SHORTFALL_RULE == GameState.ShortfallRule.REPLAY_DAYS
	if enough:
		column.add_child(_label("MASA PERCOBAAN LULUS!", 32, Palette.TEAL, true))
		column.add_child(_label(SUCCESS_TEXT, 16, Palette.TEXT, true))
	elif can_replay:
		column.add_child(_label("TABUNGAN BELUM CUKUP", 32, Palette.YELLOW, true))
		var missing := GameState.MEDICAL_COST - GameState.total_savings()
		column.add_child(_label(tr(SHORTFALL_TEXT) % GameState.rupiah(missing), 16, Palette.TEXT, true))
	else:
		column.add_child(_label("MASA PERCOBAAN BERAKHIR", 32, Palette.CORAL, true))
		column.add_child(_label(BAD_ENDING_TEXT, 16, Palette.TEXT, true))

	column.add_child(HSeparator.new())
	var first_button: Button = null
	for i in GameState.DAYS.size():
		var day := load(GameState.DAYS[i]) as DayData
		var wage: int = GameState.wages.get(day.day, 0)
		var caption := tr("Hari %d: %s") % [day.day, tr(day.package.display_name)]
		if can_replay:
			var button := Button.new()
			button.text = tr("Ulangi %s   (%s)") % [caption, GameState.rupiah(wage)]
			button.pressed.connect(GameState.replay_day.bind(i))
			column.add_child(button)
			if first_button == null:
				first_button = button
		else:
			column.add_child(_money_row(caption, wage, Palette.TEXT))
	column.add_child(HSeparator.new())
	column.add_child(_money_row("Total tabungan", GameState.total_savings(),
			Palette.TEAL_DARK if enough else Palette.CORAL_DARK))
	column.add_child(_money_row("Biaya pengobatan", GameState.MEDICAL_COST, Palette.TEXT_SOFT))

	var menu := Button.new()
	menu.text = "Menu Utama"
	menu.custom_minimum_size = Vector2(0, 44)
	menu.pressed.connect(Transition.change_scene.bind(GameState.MENU_SCENE))
	column.add_child(menu)
	(first_button if first_button else menu).grab_focus.call_deferred()


func _label(text: String, size: int, color: Color, centered := false) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if centered:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if size >= 30:
		# Judul: tebal dengan outline gelap, seperti logo.
		label.add_theme_font_override("font", UiTheme.font(600))
		label.add_theme_color_override("font_outline_color", Palette.OUTLINE)
		label.add_theme_constant_override("outline_size", 9)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _money_row(caption: String, amount: int, color: Color) -> Control:
	var row := HBoxContainer.new()
	var left := _label(caption, 16, color)
	left.autowrap_mode = TextServer.AUTOWRAP_OFF
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var right := _label(GameState.rupiah(amount), 16, color)
	right.autowrap_mode = TextServer.AUTOWRAP_OFF
	row.add_child(left)
	row.add_child(right)
	return row

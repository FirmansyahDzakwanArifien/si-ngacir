class_name GameHud
extends CanvasLayer
## Bar atas in-game (hari, kondisi paket, ETA, tujuan) dan kartu dialog
## untuk intro hari, pause, hasil pengiriman, dan paket hancur.

signal start_requested
signal resume_requested
signal retry_requested
signal next_requested
signal menu_requested
## Lanjut dari Pos setelah paket hancur.
signal checkpoint_requested
## Tombol pause di layar sentuh.
signal pause_pressed
## Tip tutorial selesai ditampilkan.
signal tip_finished

const TIP_TIME := 4.5

const BAR_HEIGHT := 48.0
# Alias lama, dipakai beberapa layar lain.
const INK := Palette.NIGHT
const GOLD := Palette.YELLOW
const RED := Palette.CORAL
const GREEN := Palette.TEAL

var _day: DayData
var _time_label: Label
var _time_pill: PanelContainer
var _time_pulse: Tween
var _package_icons: Array[Control] = []
var _route: RouteMeter
var _tip: PanelContainer
var _tip_label: Label
var _tip_tween: Tween
var _overlay: ColorRect
var _panel: PanelContainer
var _panel_box: VBoxContainer


func _init() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS


func setup(day: DayData) -> void:
	_day = day
	_build_top_bar()
	_build_tip()
	_build_overlay()
	update_timer(day.eta_seconds)


func update_timer(seconds_left: float) -> void:
	var fill := Palette.TEAL
	var text_color := Palette.WHITE
	if seconds_left < 0.0:
		_time_label.text = "TELAT +%s" % format_time(-seconds_left)
		fill = Palette.CORAL
	else:
		_time_label.text = "ETA %s" % format_time(seconds_left)
		if seconds_left <= 10.0:
			fill = Palette.YELLOW
			text_color = Palette.TEXT
	_time_pill.add_theme_stylebox_override("panel", UiTheme.pill(fill))
	_time_label.add_theme_color_override("font_color", text_color)
	# Pil ETA berdenyut saat waktu menipis.
	var hurry := seconds_left <= 10.0 and seconds_left > -1.0
	if hurry and _time_pulse == null:
		_time_pill.pivot_offset = _time_pill.size / 2.0
		_time_pulse = _time_pill.create_tween().set_loops()
		_time_pulse.tween_property(_time_pill, "scale", Vector2(1.08, 1.08), 0.25)
		_time_pulse.tween_property(_time_pill, "scale", Vector2.ONE, 0.25)
	elif not hurry and _time_pulse:
		_time_pulse.kill()
		_time_pulse = null
		_time_pill.scale = Vector2.ONE


## Kartu tip kecil di bawah bar atas; tidak menghentikan permainan.
func show_tip(text: String) -> void:
	_tip_label.text = text
	_tip.visible = true
	_tip.modulate.a = 0.0
	_tip.position.y = BAR_HEIGHT - 10.0
	if _tip_tween:
		_tip_tween.kill()
	_tip_tween = _tip.create_tween()
	_tip_tween.set_parallel()
	_tip_tween.tween_property(_tip, "modulate:a", 1.0, 0.2)
	_tip_tween.tween_property(_tip, "position:y", BAR_HEIGHT + 8.0, 0.25).set_trans(Tween.TRANS_BACK)
	_tip_tween.chain().tween_interval(TIP_TIME)
	_tip_tween.chain().tween_property(_tip, "modulate:a", 0.0, 0.3)
	_tip_tween.chain().tween_callback(func() -> void:
		_tip.visible = false
		tip_finished.emit())


func _build_tip() -> void:
	_tip = PanelContainer.new()
	var style := UiTheme.card(Palette.WHITE, Palette.TEAL)
	style.set_content_margin_all(12)
	style.set_corner_radius_all(16)
	_tip.add_theme_stylebox_override("panel", style)
	_tip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tip.visible = false
	UiTheme.attach(_tip)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	_tip.add_child(row)
	var badge := _label("TIPS", 14, Palette.WHITE, false, 600)
	row.add_child(_pill(badge, Palette.TEAL))
	_tip_label = _label("", 16)
	_tip_label.custom_minimum_size = Vector2(420, 0)
	row.add_child(_tip_label)
	add_child(_tip)
	_tip.resized.connect(func() -> void:
		var view := get_viewport().get_visible_rect().size
		_tip.position.x = (view.x - _tip.size.x) / 2.0)


## Kemajuan perjalanan dari gudang (0) ke rumah pelanggan (1).
func update_progress(fraction: float) -> void:
	_route.value = clampf(fraction, 0.0, 1.0)


func update_package(damage: int) -> void:
	var remaining := _day.package.max_damage - damage
	for i in _package_icons.size():
		var icon := _package_icons[i]
		var lost := i >= remaining
		if lost and icon.modulate.a > 0.5:
			# Ikon yang baru hilang meletup kecil dulu.
			icon.pivot_offset = icon.size / 2.0
			var tween := icon.create_tween()
			tween.tween_property(icon, "scale", Vector2(1.5, 1.5), 0.08)
			tween.tween_property(icon, "scale", Vector2.ONE, 0.12)
		icon.modulate = Color(1, 1, 1, 0.25) if lost else Color.WHITE


func show_intro() -> void:
	var pkg := _day.package
	var rows: Array[Control] = [
		_package_picture(),
		_label("Paket: %s" % pkg.display_name, 20, Palette.TEXT, true, 600),
		_label(pkg.description, 16, Palette.TEXT_SOFT),
		_customer_row(),
		_label("Target ETA: %s   Upah dasar: %s" % [
				format_time(_day.eta_seconds), GameState.rupiah(_day.base_wage)], 17),
	]
	for warning in _day_warnings():
		rows.append(_label("! " + warning, 15, Palette.TEAL_DARK, true, 600))
	rows.append(_label("Gerak: WASD / panah / swipe   Pause: Esc / P", 14, Palette.TEXT_SOFT))
	_open("Hari %d: %s" % [_day.day, _day.title], Palette.YELLOW, rows, [["Trobos Ajalah!", start_requested.emit]])


func _day_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if _day.strict_customer:
		warnings.append("%s perfeksionis: denda kerusakan 2x. Paket sempurna dan tepat waktu dapat tip %s." % [
				_day.customer_name, GameState.rupiah(_day.perfect_tip)])
	if _day.rainy:
		warnings.append("Hujan deras: jarak pandang terbatas dan aspal licin.")
	if _day.cat_count > 0:
		warnings.append("Kucing jalanan suka menghalangi jalan. Cari jalur lain!")
	if _day.rival_interval > 0.0:
		warnings.append("Bang Kilat, kurir rival, suka ngebut tiba-tiba. Hati-hati!")
	return warnings


func show_pause() -> void:
	_open("PAUSE", Palette.YELLOW, [], [
		["Lanjut", resume_requested.emit],
		["Ulangi Hari", retry_requested.emit],
		["Pengaturan", _open_settings],
		["Menu Utama", menu_requested.emit],
	])


func _open_settings() -> void:
	_overlay.hide()
	var settings := SettingsPanel.new()
	settings.closed.connect(show_pause)
	add_child(settings)


func show_result(report: DeliveryReport, next_text: String) -> void:
	var rows: Array[Control] = [
		StarRow.new(report.stars),
		_quote(report.comment, report.customer),
		_label("Kondisi paket: %d%%   Tabrakan: %d" % [roundi(report.integrity * 100.0), report.collisions], 16),
		_label("Waktu: %s (ETA %s)" % [format_time(report.elapsed), format_time(_day.eta_seconds)], 16),
		HSeparator.new(),
		_money_row("Upah dasar", report.base_wage),
		_money_row("Bonus tepat waktu", report.eta_bonus),
		_money_row("Tip pelanggan", report.tip) if report.strict else null,
		_money_row("Bonus koin (%d, juga masuk dompet)" % report.coins, report.coin_bonus) if report.coins > 0 else null,
		_money_row("Denda kerusakan" + (" (2x)" if report.strict else ""), -report.damage_penalty),
		_money_row("Potongan telat", -report.late_penalty),
		_money_row("Ganti paket di Pos (%dx)" % report.checkpoint_uses, -report.checkpoint_penalty)
				if report.checkpoint_uses > 0 else null,
		HSeparator.new(),
		_counting_money_row("UPAH HARI INI", report.wage),
		_label("Tabungan pengobatan: %s / %s" % [
				GameState.rupiah(GameState.total_savings()), GameState.rupiah(GameState.MEDICAL_COST)],
				14, Palette.TEXT_SOFT),
	]
	_open("PAKET SAMPAI!", Palette.TEAL, rows, [
		[next_text, next_requested.emit],
		["Ulangi Hari", retry_requested.emit],
	])


## checkpoint_penalty > 0: tawarkan lanjut dari Pos dengan denda tersebut.
func show_failed(is_replay: bool, checkpoint_penalty := 0) -> void:
	var leave: Array = ["Kembali ke Rekap", next_requested.emit] if is_replay \
			else ["Menu Utama", menu_requested.emit]
	var buttons: Array = [["Ulangi Hari", retry_requested.emit], leave]
	var rows: Array[Control] = [
		_package_picture(true),
		_quote(DeliveryReport.FAILED_COMMENT, _day.customer_name),
	]
	if checkpoint_penalty > 0:
		rows.append(_label("Kamu sudah sampai di Pos. Ambil paket pengganti dan lanjutkan perjalanan?", 16))
		buttons.push_front(["Lanjut dari Pos (-%s)" % GameState.rupiah(checkpoint_penalty), checkpoint_requested.emit])
	else:
		rows.append(_label("Pengiriman gagal. Upah hari ini hangus untuk ganti rugi.", 16))
	_open("PAKET HANCUR!", Palette.CORAL, rows, buttons)


func hide_overlay() -> void:
	_overlay.hide()
	get_viewport().gui_release_focus()


static func format_time(seconds: float) -> String:
	var total := ceili(seconds)
	return "%02d:%02d" % [total / 60, total % 60]


func _build_top_bar() -> void:
	var bar := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Palette.CREAM
	style.border_color = Palette.OUTLINE
	style.border_width_bottom = 3
	style.content_margin_left = 10
	style.content_margin_right = 10
	bar.add_theme_stylebox_override("panel", style)
	bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	bar.offset_bottom = BAR_HEIGHT
	UiTheme.attach(bar)
	add_child(bar)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	bar.add_child(row)

	row.add_child(_pill(_label("HARI %d" % _day.day, 17, Palette.WHITE, false, 600), Palette.CORAL))
	var icons := HBoxContainer.new()
	icons.add_theme_constant_override("separation", 3)
	for i in _day.package.max_damage:
		var icon := _package_icon(Vector2(30, 22))
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icons.add_child(icon)
		_package_icons.append(icon)
	row.add_child(icons)

	_route = RouteMeter.new()
	_route.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_route)
	_time_label = _label("", 17, Palette.WHITE, false, 600)
	_time_pill = _pill(_time_label, Palette.TEAL)
	row.add_child(_time_pill)
	# Nama pelanggan panjang dipotong dengan "..." supaya bar tidak meluber.
	var customer := _label("ke %s" % _day.customer_name, 16, Palette.TEXT, false, 600)
	var natural := UiTheme.font(600).get_string_size(customer.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
	customer.clip_text = true
	customer.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	customer.custom_minimum_size.x = minf(150.0, natural + 2.0)
	row.add_child(customer)
	if DisplayServer.is_touchscreen_available():
		var pause := Button.new()
		pause.text = "II"
		pause.focus_mode = Control.FOCUS_NONE
		pause.custom_minimum_size = Vector2(40, 0)
		pause.add_theme_font_size_override("font_size", 16)
		pause.pressed.connect(pause_pressed.emit)
		row.add_child(pause)


func _build_overlay() -> void:
	_overlay = ColorRect.new()
	_overlay.color = Color(0.1, 0.09, 0.2, 0.5)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	UiTheme.attach(_overlay)
	add_child(_overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(460, 0)
	center.add_child(_panel)

	_panel_box = VBoxContainer.new()
	_panel_box.add_theme_constant_override("separation", 6)
	_panel.add_child(_panel_box)
	_overlay.hide()


func _open(title: String, title_color: Color, rows: Array, buttons: Array) -> void:
	for child in _panel_box.get_children():
		_panel_box.remove_child(child)
		child.queue_free()
	var heading := _label(title, 30, title_color, true, 600)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_color_override("font_outline_color", Palette.OUTLINE)
	heading.add_theme_constant_override("outline_size", 9)
	_panel_box.add_child(heading)
	for row: Control in rows:
		if row:
			_panel_box.add_child(row)

	var first_button: Button = null
	var buttons_box := VBoxContainer.new()
	buttons_box.add_theme_constant_override("separation", 10)
	for entry: Array in buttons:
		var button := Button.new()
		button.text = entry[0]
		button.custom_minimum_size = Vector2(0, 44)
		button.pressed.connect(entry[1])
		buttons_box.add_child(button)
		if first_button == null:
			first_button = button
	if buttons_box.get_child_count() > 0:
		var gap := Control.new()
		gap.custom_minimum_size = Vector2(0, 4)
		_panel_box.add_child(gap)
		_panel_box.add_child(buttons_box)
	_overlay.show()
	_pop_in.call_deferred()
	if first_button:
		first_button.grab_focus.call_deferred()


func _pop_in() -> void:
	# Kartu muncul memantul kecil.
	_panel.pivot_offset = _panel.size / 2.0
	_panel.scale = Vector2(0.85, 0.85)
	var tween := _panel.create_tween()
	tween.tween_property(_panel, "scale", Vector2.ONE, 0.25) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _label(text: String, size: int, color := Palette.TEXT, wrap := true, weight := 500) -> Label:
	var label := Label.new()
	label.text = text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if wrap:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if weight != 500:
		label.add_theme_font_override("font", UiTheme.font(weight))
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _quote(comment: String, customer: String) -> Control:
	var box := PanelContainer.new()
	var style := UiTheme.pill(Color.WHITE)
	style.set_corner_radius_all(16)
	style.set_content_margin_all(10)
	box.add_theme_stylebox_override("panel", style)
	var label := _label("\"%s\"\n- %s" % [comment, customer], 16, Palette.TEXT, true, 500)
	box.add_child(label)
	return box


func _pill(content: Control, fill: Color) -> PanelContainer:
	var pill := PanelContainer.new()
	pill.add_theme_stylebox_override("panel", UiTheme.pill(fill))
	pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pill.add_child(content)
	return pill


func _package_icon(size: Vector2) -> Control:
	var texture := SpriteLibrary.texture("package_%s" % _day.package.id)
	if texture == null:
		var box := ColorRect.new()
		box.color = _day.package.color
		box.custom_minimum_size = size * 0.6
		return box
	var icon := TextureRect.new()
	icon.texture = texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = size
	return icon


## "Antar ke: <nama>" dengan potret kecil pelanggan.
func _customer_row() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var portrait := SpriteLibrary.hires("customer_%s" % _day.customer_id, 1.0)
	if portrait:
		var picture := TextureRect.new()
		picture.texture = portrait
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.custom_minimum_size = Vector2(44, 44)
		row.add_child(picture)
	row.add_child(_label("Antar ke: %s" % _day.customer_name, 17))
	return row


func _package_picture(broken := false) -> Control:
	var icon := _package_icon(Vector2(96, 72))
	if icon is TextureRect:
		(icon as TextureRect).texture = SpriteLibrary.hires("package_%s" % _day.package.id, 2.5)
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if broken:
		icon.modulate = Color(1, 1, 1, 0.45)
		icon.rotation_degrees = -12.0
		icon.pivot_offset = Vector2(48, 36)
	return icon


## Baris upah yang angkanya menghitung naik dari Rp0.
func _counting_money_row(caption: String, amount: int) -> Control:
	var row := _money_row(caption, 0, Palette.TEAL_DARK, 600)
	var value := row.get_child(1) as Label
	var tween := value.create_tween()
	tween.tween_interval(0.5)
	tween.tween_method(func(v: float) -> void: value.text = GameState.rupiah(roundi(v)),
			0.0, float(amount), 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	return row


func _money_row(caption: String, amount: int, color := Palette.TEXT, weight := 500) -> Control:
	var row := HBoxContainer.new()
	var left := _label(caption, 16, color, false, weight)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(left)
	row.add_child(_label(GameState.rupiah(amount), 16, color, false, weight))
	return row


## Garis rute kecil di bar atas: titik Masbro bergerak menuju rumah pelanggan.
class RouteMeter extends Control:
	var value := 0.0:
		set(v):
			if not is_equal_approx(v, value):
				value = v
				queue_redraw()

	func _init() -> void:
		custom_minimum_size = Vector2(70, 26)

	func _draw() -> void:
		var y := size.y / 2.0
		var left := 10.0
		var right := size.x - 14.0
		draw_line(Vector2(left, y), Vector2(right, y), Palette.CREAM_DARK, 8.0, true)
		var x := lerpf(left, right, value)
		draw_line(Vector2(left, y), Vector2(x, y), Palette.TEAL, 8.0, true)
		# Rumah tujuan di ujung kanan.
		draw_colored_polygon(PackedVector2Array([Vector2(right - 7, y - 1), Vector2(right, y - 9),
				Vector2(right + 7, y - 1)]), Palette.CORAL)
		draw_rect(Rect2(right - 5, y - 1, 10, 8), Palette.CREAM)
		draw_rect(Rect2(right - 5, y - 1, 10, 8), Palette.OUTLINE, false, 2.0)
		# Masbro.
		draw_circle(Vector2(x, y), 7.0, Palette.OUTLINE)
		draw_circle(Vector2(x, y), 5.0, Palette.YELLOW)


## Bintang rating digambar manual supaya tidak bergantung pada font emoji.
class StarRow extends Control:
	var stars := 0

	var _shown := 0
	var _pop := 1.0

	func _init(p_stars: int) -> void:
		stars = p_stars
		custom_minimum_size = Vector2(0, 46)

	func _ready() -> void:
		# Bintang muncul satu per satu sambil memantul.
		var tween := create_tween()
		for i in stars:
			tween.tween_interval(0.16)
			tween.tween_callback(_show_next_star)
			tween.tween_method(_set_pop, 1.6, 1.0, 0.18).set_trans(Tween.TRANS_BACK)

	func _show_next_star() -> void:
		_shown += 1
		AudioManager.play_sfx(&"star")

	func _set_pop(value: float) -> void:
		_pop = value
		queue_redraw()

	func _draw() -> void:
		var spacing := 50.0
		var start_x := size.x / 2.0 - spacing * 2.0
		for i in 5:
			var lit := i < _shown
			var scale := _pop if i == _shown - 1 else 1.0
			var points := _star_points(Vector2(start_x + i * spacing, 23), 19.0 * scale, 8.5 * scale)
			draw_colored_polygon(points, Palette.YELLOW if lit else Palette.CREAM_DARK)
			points.append(points[0])
			draw_polyline(points, Palette.OUTLINE, 3.0, true)

	func _star_points(center: Vector2, outer: float, inner: float) -> PackedVector2Array:
		var points := PackedVector2Array()
		for i in 10:
			var radius := outer if i % 2 == 0 else inner
			var angle := -PI / 2.0 + i * PI / 5.0
			points.append(center + Vector2(cos(angle), sin(angle)) * radius)
		return points

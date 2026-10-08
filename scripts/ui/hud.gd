class_name GameHud
extends CanvasLayer
## Bar atas in-game (hari, kondisi paket, ETA, tujuan) dan panel overlay
## untuk intro hari, pause, hasil pengiriman, dan paket hancur.

signal start_requested
signal resume_requested
signal retry_requested
signal next_requested
signal menu_requested

const BAR_HEIGHT := 48.0
const INK := Color("2b2d42")
const GOLD := Color("ffd166")
const RED := Color("ef476f")
const GREEN := Color("06d6a0")

var _day: DayData
var _time_label: Label
var _package_boxes: Array[ColorRect] = []
var _overlay: ColorRect
var _panel_box: VBoxContainer


func _init() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS


func setup(day: DayData) -> void:
	_day = day
	_build_top_bar()
	_build_overlay()
	update_timer(day.eta_seconds)


func update_timer(seconds_left: float) -> void:
	if seconds_left >= 0.0:
		_time_label.text = "ETA %s" % format_time(seconds_left)
		_time_label.modulate = Color.WHITE if seconds_left > 10.0 else GOLD
	else:
		_time_label.text = "TELAT +%s" % format_time(-seconds_left)
		_time_label.modulate = RED


func update_package(damage: int) -> void:
	var remaining := _day.package.max_damage - damage
	for i in _package_boxes.size():
		_package_boxes[i].color = _day.package.color if i < remaining else Color(1, 1, 1, 0.15)


func show_intro() -> void:
	var pkg := _day.package
	_open("Hari %d: %s" % [_day.day, _day.title], GOLD, [
		_label("Paket: %s" % pkg.display_name, 18),
		_label(pkg.description, 16, Color(1, 1, 1, 0.8)),
		_label("Antar ke: %s" % _day.customer_name, 16),
		_label("Target ETA: %s   Upah dasar: %s" % [
				format_time(_day.eta_seconds), GameState.rupiah(_day.base_wage)], 16),
		_label("Gerak: WASD / panah   Pause: Esc / P", 14, Color(1, 1, 1, 0.6)),
	], [["Trobos Ajalah!", start_requested.emit]])


func show_pause() -> void:
	_open("PAUSE", GOLD, [], [
		["Lanjut", resume_requested.emit],
		["Ulangi Hari", retry_requested.emit],
		["Menu Utama", menu_requested.emit],
	])


func show_result(report: DeliveryReport, next_text: String) -> void:
	var rows: Array[Control] = [
		StarRow.new(report.stars),
		_label("\"%s\"\n- %s" % [report.comment, report.customer], 16, GOLD),
		_label("Kondisi paket: %d%%   Tabrakan: %d" % [roundi(report.integrity * 100.0), report.collisions], 16),
		_label("Waktu: %s (ETA %s)" % [format_time(report.elapsed), format_time(_day.eta_seconds)], 16),
		HSeparator.new(),
		_money_row("Upah dasar", report.base_wage),
		_money_row("Bonus tepat waktu", report.eta_bonus),
		_money_row("Denda kerusakan", -report.damage_penalty),
		_money_row("Potongan telat", -report.late_penalty),
		HSeparator.new(),
		_money_row("UPAH HARI INI", report.wage, GREEN),
		_label("Tabungan pengobatan: %s / %s" % [
				GameState.rupiah(GameState.total_savings()), GameState.rupiah(GameState.MEDICAL_COST)],
				14, Color(1, 1, 1, 0.7)),
	]
	_open("PAKET SAMPAI!", GREEN, rows, [
		[next_text, next_requested.emit],
		["Ulangi Hari", retry_requested.emit],
	])


func show_failed(is_replay: bool) -> void:
	var leave: Array = ["Kembali ke Rekap", next_requested.emit] if is_replay \
			else ["Menu Utama", menu_requested.emit]
	_open("PAKET HANCUR!", RED, [
		_label("\"%s\"\n- %s" % [DeliveryReport.FAILED_COMMENT, _day.customer_name], 16, GOLD),
		_label("Pengiriman gagal. Upah hari ini hangus untuk ganti rugi.", 16),
	], [
		["Ulangi Hari", retry_requested.emit],
		leave,
	])


func hide_overlay() -> void:
	_overlay.hide()
	get_viewport().gui_release_focus()


static func format_time(seconds: float) -> String:
	var total := ceili(seconds)
	return "%02d:%02d" % [total / 60, total % 60]


func _build_top_bar() -> void:
	var bar := ColorRect.new()
	bar.color = INK
	bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	bar.offset_bottom = BAR_HEIGHT
	add_child(bar)

	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 12
	row.offset_right = -12
	row.add_theme_constant_override("separation", 14)
	bar.add_child(row)

	row.add_child(_label("HARI %d" % _day.day, 18, GOLD, false))
	row.add_child(_label(_day.package.display_name.to_upper(), 16, Color.WHITE, false))
	var boxes := HBoxContainer.new()
	boxes.add_theme_constant_override("separation", 4)
	for i in _day.package.max_damage:
		var box := ColorRect.new()
		box.custom_minimum_size = Vector2(14, 14)
		box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		box.color = _day.package.color
		boxes.add_child(box)
		_package_boxes.append(box)
	row.add_child(boxes)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	_time_label = _label("", 18, Color.WHITE, false)
	row.add_child(_time_label)
	row.add_child(_label("ANTAR KE: %s" % _day.customer_name.to_upper(), 14, Color(1, 1, 1, 0.7), false))


func _build_overlay() -> void:
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.55)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)

	var style := StyleBoxFlat.new()
	style.bg_color = INK
	style.border_color = GOLD
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(24)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(440, 0)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	_panel_box = VBoxContainer.new()
	_panel_box.add_theme_constant_override("separation", 8)
	panel.add_child(_panel_box)
	_overlay.hide()


func _open(title: String, title_color: Color, rows: Array, buttons: Array) -> void:
	for child in _panel_box.get_children():
		_panel_box.remove_child(child)
		child.queue_free()
	var heading := _label(title, 26, title_color)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel_box.add_child(heading)
	for row: Control in rows:
		_panel_box.add_child(row)

	var first_button: Button = null
	for entry: Array in buttons:
		var button := Button.new()
		button.text = entry[0]
		button.custom_minimum_size = Vector2(0, 36)
		button.pressed.connect(entry[1])
		_panel_box.add_child(button)
		if first_button == null:
			first_button = button
	_overlay.show()
	if first_button:
		first_button.grab_focus.call_deferred()


func _label(text: String, size: int, color := Color.WHITE, wrap := true) -> Label:
	var label := Label.new()
	label.text = text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if wrap:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _money_row(caption: String, amount: int, color := Color.WHITE) -> Control:
	var row := HBoxContainer.new()
	var left := _label(caption, 16, color, false)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(left)
	row.add_child(_label(GameState.rupiah(amount), 16, color, false))
	return row


## Bintang rating digambar manual supaya tidak bergantung pada font emoji.
class StarRow extends Control:
	var stars := 0

	func _init(p_stars: int) -> void:
		stars = p_stars
		custom_minimum_size = Vector2(0, 40)

	func _draw() -> void:
		var spacing := 40.0
		var start_x := size.x / 2.0 - spacing * 2.0
		for i in 5:
			var color := GOLD if i < stars else Color(1, 1, 1, 0.2)
			draw_colored_polygon(_star_points(Vector2(start_x + i * spacing, 20), 16.0, 7.0), color)

	func _star_points(center: Vector2, outer: float, inner: float) -> PackedVector2Array:
		var points := PackedVector2Array()
		for i in 10:
			var radius := outer if i % 2 == 0 else inner
			var angle := -PI / 2.0 + i * PI / 5.0
			points.append(center + Vector2(cos(angle), sin(angle)) * radius)
		return points

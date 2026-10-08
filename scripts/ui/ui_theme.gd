class_name UiTheme
extends RefCounted
## Tema UI global: font Fredoka, tombol kuning bulat, kartu krem ber-outline.
## Dipasang sekali ke jendela utama oleh GameState.

const FONT_PATH := "res://assets/fonts/Fredoka.ttf"

static var _font: Font
## Tema aktif. Control di dalam CanvasLayer tidak mewarisi tema jendela,
## jadi HUD dan panel memasangnya sendiri lewat attach().
static var current: Theme


## Font Fredoka dengan ketebalan tertentu (400 = biasa, 600 = tebal).
static func font(weight := 500) -> Font:
	var base: Font = load(FONT_PATH)
	var variation := FontVariation.new()
	variation.base_font = base
	variation.variation_opentype = {"wght": weight}
	return variation


static func apply(window: Window) -> void:
	_font = font(500)
	# Dipakai juga oleh draw_string() di papan permainan.
	ThemeDB.fallback_font = _font
	current = build()
	window.theme = current


static func attach(control: Control) -> void:
	control.theme = current if current else build()


static func build() -> Theme:
	var theme := Theme.new()
	theme.default_font = _font if _font else font(500)
	theme.default_font_size = 18

	theme.set_color("font_color", "Label", Palette.TEXT)

	theme.set_stylebox("normal", "Button", _button_box(Palette.YELLOW, Palette.YELLOW_DARK))
	theme.set_stylebox("hover", "Button", _button_box(Color("ffe08f"), Palette.YELLOW_DARK))
	theme.set_stylebox("pressed", "Button", _button_box(Palette.YELLOW_DARK, Palette.YELLOW_DARK, true))
	theme.set_stylebox("disabled", "Button", _button_box(Color("e6ddd0"), Color("cfc4b4")))
	var focus := StyleBoxFlat.new()
	focus.draw_center = false
	focus.border_color = Palette.TEAL
	focus.set_border_width_all(4)
	focus.set_corner_radius_all(18)
	focus.set_expand_margin_all(4)
	theme.set_stylebox("focus", "Button", focus)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		theme.set_color(state, "Button", Palette.TEXT)
	theme.set_color("font_disabled_color", "Button", Palette.TEXT_SOFT)
	theme.set_font("font", "Button", font(600))
	theme.set_font_size("font_size", "Button", 20)

	theme.set_stylebox("panel", "PanelContainer", card())

	var separator := StyleBoxLine.new()
	separator.color = Palette.CREAM_DARK
	separator.thickness = 3
	theme.set_stylebox("separator", "HSeparator", separator)
	theme.set_constant("separation", "HSeparator", 6)

	var track := StyleBoxFlat.new()
	track.bg_color = Palette.CREAM_DARK
	track.set_corner_radius_all(8)
	track.set_content_margin_all(5)
	theme.set_stylebox("slider", "HSlider", track)
	var fill := track.duplicate() as StyleBoxFlat
	fill.bg_color = Palette.TEAL
	theme.set_stylebox("grabber_area", "HSlider", fill)
	theme.set_stylebox("grabber_area_highlight", "HSlider", fill)
	theme.set_icon("grabber", "HSlider", _knob(Palette.YELLOW))
	theme.set_icon("grabber_highlight", "HSlider", _knob(Color("ffe08f")))

	# Sakelar polos tanpa latar tombol.
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		theme.set_stylebox(state, "CheckButton", StyleBoxEmpty.new())
	theme.set_color("font_color", "CheckButton", Palette.TEXT)
	theme.set_color("font_hover_color", "CheckButton", Palette.TEXT)
	theme.set_color("font_pressed_color", "CheckButton", Palette.TEXT)
	theme.set_color("font_focus_color", "CheckButton", Palette.TEXT)
	theme.set_color("font_hover_pressed_color", "CheckButton", Palette.TEXT)
	return theme


## Kartu krem ber-outline dengan bayangan lembut, untuk panel dan dialog.
static func card(fill := Palette.CREAM, border := Palette.OUTLINE) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(4)
	box.set_corner_radius_all(22)
	box.set_content_margin_all(22)
	box.shadow_color = Color(0, 0, 0, 0.25)
	box.shadow_size = 2
	box.shadow_offset = Vector2(0, 7)
	return box


## Label "pil" berwarna, misalnya HARI 1 atau ETA di bar atas.
static func pill(fill: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = Palette.OUTLINE
	box.set_border_width_all(3)
	box.set_corner_radius_all(14)
	box.content_margin_left = 12
	box.content_margin_right = 12
	box.content_margin_top = 2
	box.content_margin_bottom = 2
	return box


static func _button_box(fill: Color, shade: Color, pressed := false) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = Palette.OUTLINE
	box.set_border_width_all(3)
	box.set_corner_radius_all(16)
	box.content_margin_left = 18
	box.content_margin_right = 18
	box.content_margin_top = 8 + (3 if pressed else 0)
	box.content_margin_bottom = 8 - (3 if pressed else 0)
	# "Bibir" bawah tombol supaya terlihat empuk dan bisa ditekan.
	box.shadow_color = shade if not pressed else Color.TRANSPARENT
	box.shadow_size = 1
	box.shadow_offset = Vector2(0, 5)
	return box


static func _knob(fill: Color) -> Texture2D:
	var size := 26
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center := Vector2.ONE * size / 2.0
	for y in size:
		for x in size:
			var d := Vector2(x + 0.5, y + 0.5).distance_to(center)
			if d <= 12.0:
				image.set_pixel(x, y, Palette.OUTLINE if d > 9.0 else fill)
	return ImageTexture.create_from_image(image)

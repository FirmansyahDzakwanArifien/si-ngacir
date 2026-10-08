class_name SpeechBubble
extends Node2D
## Balon ucapan kecil untuk NPC. Posisi node = ujung ekor balon (menunjuk ke pembicara).

enum Side { LEFT, RIGHT, ABOVE }

const FONT_SIZE := 14
const PADDING := Vector2(10, 6)
const TAIL := 8.0

## Arah balon relatif terhadap ujung ekornya.
var side := Side.ABOVE
var text := ""

var _hide_timer: SceneTreeTimer


func _init() -> void:
	z_index = 30
	visible = false


## Tampilkan teks selama duration detik (0 = terus tampil).
func say(message: String, duration := 2.5) -> void:
	text = message
	visible = true
	queue_redraw()
	scale = Vector2(0.6, 0.6)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if duration > 0.0:
		var timer := get_tree().create_timer(duration, false)
		_hide_timer = timer
		timer.timeout.connect(func() -> void:
			if _hide_timer == timer:
				visible = false)


func _draw() -> void:
	if text.is_empty():
		return
	var font := ThemeDB.fallback_font
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE)
	var box_size := text_size + PADDING * 2.0
	# Kotak di satu sisi ujung ekor; "out" = arah dari ujung ekor ke kotak.
	var origin: Vector2
	var out: Vector2
	match side:
		Side.LEFT:
			origin = Vector2(-TAIL - box_size.x, -box_size.y / 2.0)
			out = Vector2.LEFT
		Side.RIGHT:
			origin = Vector2(TAIL, -box_size.y / 2.0)
			out = Vector2.RIGHT
		_:
			origin = Vector2(-box_size.x / 2.0, -TAIL - box_size.y)
			out = Vector2.UP
	var box := StyleBoxFlat.new()
	box.bg_color = Color.WHITE
	box.border_color = Palette.OUTLINE
	box.set_border_width_all(3)
	box.set_corner_radius_all(10)
	draw_style_box(box, Rect2(origin, box_size))
	# Ekor putih menutupi garis kotak di pangkalnya, lalu dua sisi ekor diberi garis.
	var across := Vector2(-out.y, out.x) * 6.0
	var base := out * TAIL
	draw_colored_polygon(PackedVector2Array([Vector2.ZERO, base + out * 3.0 + across, base + out * 3.0 - across]),
			Color.WHITE)
	draw_line(Vector2.ZERO, base + across, Palette.OUTLINE, 3.0, true)
	draw_line(Vector2.ZERO, base - across, Palette.OUTLINE, 3.0, true)
	draw_string(font, origin + Vector2(PADDING.x, PADDING.y + font.get_ascent(FONT_SIZE)), text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, Palette.OUTLINE)

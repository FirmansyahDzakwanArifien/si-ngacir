class_name TouchControls
extends CanvasLayer
## Kontrol layar sentuh: swipe untuk bergerak, tap untuk maju, dan D-pad di layar.
## Hanya aktif di perangkat dengan layar sentuh.

const BUTTON_SIZE := 72
const SWIPE_MIN_DISTANCE := 24.0
## Ruang minimal di bawah/samping papan supaya D-pad tidak menutupi jalan.
const DPAD_SPACE := 228.0
const HUD_HEIGHT := 48.0

var player: Player
## Area papan permainan (ukuran saja; posisinya dihitung ulang mengikuti layar).
var board_rect := Rect2(0, 0, 720, 624)
## Tampilkan D-pad. Default: hanya bila perangkat punya layar sentuh.
var show_dpad := DisplayServer.is_touchscreen_available()

var _dpad: Node2D
var _dpad_area := Rect2()
## Posisi awal tiap sentuhan yang bisa jadi swipe (key: index jari).
var _touch_starts := {}


func _init() -> void:
	layer = 5


func _ready() -> void:
	if not show_dpad:
		return
	_dpad = Node2D.new()
	add_child(_dpad)
	for entry: Array in [
			[&"move_up", 0.0, Vector2(0, -1)],
			[&"move_down", PI, Vector2(0, 1)],
			[&"move_left", -PI / 2.0, Vector2(-1, 0)],
			[&"move_right", PI / 2.0, Vector2(1, 0)]]:
		var button := TouchScreenButton.new()
		button.action = entry[0]
		button.texture_normal = _arrow_texture(entry[1], 0.35)
		button.texture_pressed = _arrow_texture(entry[1], 0.7)
		button.position = Vector2(entry[2]) * BUTTON_SIZE - Vector2.ONE * BUTTON_SIZE / 2.0
		button.passby_press = true
		_dpad.add_child(button)
	_layout()
	get_viewport().size_changed.connect(_layout)


func _input(event: InputEvent) -> void:
	if player == null or not player.input_enabled or get_tree().paused:
		_touch_starts.clear()
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			if _accepts_swipe_at(touch.position):
				_touch_starts[touch.index] = touch.position
		elif _touch_starts.has(touch.index):
			_on_swipe(touch.position - _touch_starts[touch.index])
			_touch_starts.erase(touch.index)


func _accepts_swipe_at(point: Vector2) -> bool:
	return point.y > HUD_HEIGHT and not _dpad_area.has_point(point)


func _on_swipe(delta: Vector2) -> void:
	if delta.length() < SWIPE_MIN_DISTANCE:
		player.queue_move(Vector2i.UP)
	elif absf(delta.x) > absf(delta.y):
		player.queue_move(Vector2i.RIGHT if delta.x > 0.0 else Vector2i.LEFT)
	else:
		player.queue_move(Vector2i.DOWN if delta.y > 0.0 else Vector2i.UP)


func _layout() -> void:
	var view := get_viewport().get_visible_rect().size
	var board_left := floorf(maxf(0.0, view.x - board_rect.size.x) / 2.0)
	var board_bottom := HUD_HEIGHT + board_rect.size.y
	var space_below := view.y - board_bottom
	var space_right := view.x - (board_left + board_rect.size.x)
	var center: Vector2
	if space_below >= DPAD_SPACE:
		# Layar potret: D-pad di ruang kosong di bawah papan.
		center = Vector2(view.x / 2.0, board_bottom + space_below / 2.0)
		_dpad.modulate.a = 1.0
	elif space_right >= DPAD_SPACE:
		# Layar lanskap lebar: D-pad di samping kanan papan.
		center = Vector2(view.x - space_right / 2.0, board_bottom - DPAD_SPACE / 2.0)
		_dpad.modulate.a = 1.0
	else:
		# Tidak ada ruang: D-pad transparan di pojok kanan bawah.
		center = view - Vector2.ONE * (BUTTON_SIZE * 1.6)
		_dpad.modulate.a = 0.6
	_dpad.position = center
	_dpad_area = Rect2(center - Vector2.ONE * BUTTON_SIZE * 1.5, Vector2.ONE * BUTTON_SIZE * 3.0)


## Tombol bulat dengan panah. angle 0 = atas.
static func _arrow_texture(angle: float, alpha: float) -> Texture2D:
	var image := Image.create(BUTTON_SIZE, BUTTON_SIZE, false, Image.FORMAT_RGBA8)
	var center := Vector2.ONE * BUTTON_SIZE / 2.0
	var radius := BUTTON_SIZE / 2.0 - 2.0
	var arrow := PackedVector2Array([Vector2(0, -16), Vector2(14, 8), Vector2(-14, 8)])
	for i in arrow.size():
		arrow[i] = arrow[i].rotated(angle) + center
	for y in BUTTON_SIZE:
		for x in BUTTON_SIZE:
			var point := Vector2(x + 0.5, y + 0.5)
			if Geometry2D.is_point_in_polygon(point, arrow):
				image.set_pixel(x, y, Color(GameHud.INK, minf(1.0, alpha + 0.4)))
			elif point.distance_to(center) <= radius:
				image.set_pixel(x, y, Color(1, 1, 1, alpha))
	return ImageTexture.create_from_image(image)

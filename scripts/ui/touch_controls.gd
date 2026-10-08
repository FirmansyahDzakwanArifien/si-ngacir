class_name TouchControls
extends CanvasLayer
## Kontrol layar sentuh: swipe ke kiri, kanan, atau atas (maju), dan tap untuk maju.
## Swipe ke bawah untuk mundur selangkah.

const SWIPE_MIN_DISTANCE := 24.0
const HUD_HEIGHT := 48.0

var player: Player
## Posisi awal tiap sentuhan yang bisa jadi swipe (key: index jari).
var _touch_starts := {}


func _init() -> void:
	layer = 5


func _input(event: InputEvent) -> void:
	if player == null or not player.input_enabled or get_tree().paused:
		_touch_starts.clear()
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			# Sentuhan di bar atas (tombol pause) bukan swipe.
			if touch.position.y > HUD_HEIGHT:
				_touch_starts[touch.index] = touch.position
		elif _touch_starts.has(touch.index):
			_on_swipe(touch.position - _touch_starts[touch.index])
			_touch_starts.erase(touch.index)


func _on_swipe(delta: Vector2) -> void:
	if delta.length() < SWIPE_MIN_DISTANCE:
		player.queue_move(Vector2i.UP)
	elif absf(delta.x) > absf(delta.y):
		player.queue_move(Vector2i.RIGHT if delta.x > 0.0 else Vector2i.LEFT)
	else:
		player.queue_move(Vector2i.DOWN if delta.y > 0.0 else Vector2i.UP)

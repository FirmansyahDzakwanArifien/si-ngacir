class_name Player
extends Node2D
## Masbro, capybara kurir. Bergerak per petak (grid) sambil membawa paket.

signal moved(cell: Vector2i)

const DIRECTIONS := {
	&"move_up": Vector2i.UP,
	&"move_down": Vector2i.DOWN,
	&"move_left": Vector2i.LEFT,
	&"move_right": Vector2i.RIGHT,
}

var tile := 48.0
var grid_size := Vector2i(15, 13)
var cell := Vector2i.ZERO
var step_time := 0.12
var package_color := Color("efe6cf")
var input_enabled := false
var invulnerable := false:
	set(value):
		invulnerable = value
		_blink_time = 0.0
		modulate.a = 1.0

var _tween: Tween
var _facing := 1
var _blink_time := 0.0


func place(target: Vector2i) -> void:
	cell = target
	position = cell_to_position(target)


func cell_to_position(target: Vector2i) -> Vector2:
	return Vector2(target) * tile


func hitbox() -> Rect2:
	return Rect2(position + Vector2(10, 10), Vector2(tile - 20, tile - 20))


func is_moving() -> bool:
	return _tween != null and _tween.is_running()


func knock_back(target: Vector2i) -> void:
	_hop_to(target, 0.08)


func _process(delta: float) -> void:
	if invulnerable:
		_blink_time += delta
		modulate.a = 0.35 if fmod(_blink_time, 0.16) < 0.08 else 1.0
	if not input_enabled or is_moving():
		return
	for action: StringName in DIRECTIONS:
		if Input.is_action_pressed(action):
			_try_move(DIRECTIONS[action])
			break


func _try_move(direction: Vector2i) -> void:
	if direction.x != 0 and direction.x != _facing:
		_facing = direction.x
		queue_redraw()
	var target := Vector2i(
		clampi(cell.x + direction.x, 0, grid_size.x - 1),
		clampi(cell.y + direction.y, 0, grid_size.y - 1))
	if target != cell:
		_hop_to(target, step_time)


func _hop_to(target: Vector2i, duration: float) -> void:
	if _tween:
		_tween.kill()
	cell = target
	_tween = create_tween()
	_tween.tween_property(self, "position", cell_to_position(target), duration)
	_tween.tween_callback(func() -> void: moved.emit(cell))


func _draw() -> void:
	# Placeholder sampai sprite dari Illustrator siap.
	var fur := Color("9c6b3f")
	var dark := Color("6e4a2b")
	var head_x := 30.0 if _facing > 0 else 2.0
	draw_rect(Rect2(8, 18, 32, 22), fur)
	draw_rect(Rect2(head_x, 14, 16, 18), fur)
	draw_rect(Rect2(head_x + (9.0 if _facing > 0 else 4.0), 18, 3, 3), Color.BLACK)
	draw_rect(Rect2(head_x + (13.0 if _facing > 0 else 0.0), 24, 3, 4), dark)
	for x: float in [10.0, 18.0, 28.0, 35.0]:
		draw_rect(Rect2(x, 40, 4, 4), dark)
	draw_rect(Rect2(12, 4, 20, 15), package_color)
	draw_rect(Rect2(12, 4, 20, 15), dark, false, 2.0)

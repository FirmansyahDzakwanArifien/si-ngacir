class_name Player
extends Node2D
## Masbro, capybara kurir. Bergerak per petak (grid) sambil membawa paket.

signal moved(cell: Vector2i)
## Langkah ditolak karena petak tujuan terhalang (misalnya kucing).
signal blocked(cell: Vector2i)

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
var package_id: StringName = &""
var package_color := Color("efe6cf")
var input_enabled := false
## Opsional: func(cell: Vector2i) -> bool. Kalau false, Masbro tidak bisa masuk ke petak itu.
var can_enter: Callable
var last_direction := Vector2i.UP
## true kalau langkah terakhir adalah tergelincir (bukan input pemain).
var last_move_was_slide := false
var invulnerable := false:
	set(value):
		invulnerable = value
		_blink_time = 0.0
		modulate.a = 1.0
		if not value:
			_play(&"idle")

var _tween: Tween
var _facing := 1
var _blink_time := 0.0
## Sprite Masbro dari Illustrator; null berarti memakai gambar placeholder di _draw().
var _body: AnimatedSprite2D
var _package_icon: Sprite2D


func _ready() -> void:
	var frames := SpriteLibrary.frames({
		&"idle": "masbro_idle",
		&"walk": "masbro_walk",
		&"hit": "masbro_hit",
	}, Vector2i(48, 48))
	if frames:
		_body = AnimatedSprite2D.new()
		_body.centered = false
		_body.sprite_frames = frames
		add_child(_body)
		_play(&"idle")

	_package_icon = Sprite2D.new()
	_package_icon.centered = false
	_package_icon.texture = SpriteLibrary.texture("package_%s" % package_id)
	if _package_icon.texture == null:
		_package_icon.texture = SpriteLibrary.placeholder_box(Vector2i(20, 15), package_color, Color("6e4a2b"))
	add_child(_package_icon)
	_update_facing()


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
	last_move_was_slide = false
	_hop_to(target, 0.08, &"hit")


## Tergelincir satu petak ke arah langkah terakhir. Mengembalikan false kalau tidak bisa.
func slide() -> bool:
	var target := _clamp_cell(cell + last_direction)
	if target == cell or not _is_enterable(target):
		return false
	last_move_was_slide = true
	_hop_to(target, step_time * 1.2, &"hit")
	return true


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
		_update_facing()
	var target := _clamp_cell(cell + direction)
	if target == cell:
		return
	if not _is_enterable(target):
		blocked.emit(target)
		return
	last_direction = direction
	last_move_was_slide = false
	_hop_to(target, step_time)
	AudioManager.play_sfx(&"step", 0.08)


func _clamp_cell(target: Vector2i) -> Vector2i:
	return Vector2i(clampi(target.x, 0, grid_size.x - 1), clampi(target.y, 0, grid_size.y - 1))


func _is_enterable(target: Vector2i) -> bool:
	return not can_enter.is_valid() or can_enter.call(target)


func _hop_to(target: Vector2i, duration: float, animation := &"walk") -> void:
	if _tween:
		_tween.kill()
	cell = target
	_play(animation)
	_tween = create_tween()
	_tween.tween_property(self, "position", cell_to_position(target), duration)
	_tween.tween_callback(_on_hop_finished)


func _on_hop_finished() -> void:
	if not invulnerable:
		_play(&"idle")
	moved.emit(cell)


func _play(animation: StringName) -> void:
	if _body == null:
		return
	if not _body.sprite_frames.has_animation(animation):
		animation = &"idle"
	if _body.sprite_frames.has_animation(animation):
		_body.play(animation)


func _update_facing() -> void:
	# Sprite digambar menghadap kanan; dibalik saat Masbro menghadap kiri.
	if _body:
		_body.flip_h = _facing < 0
	if _package_icon:
		_package_icon.position = Vector2(12, 4) if _facing > 0 else Vector2(16, 4)
	queue_redraw()


func _draw() -> void:
	if _body:
		return
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

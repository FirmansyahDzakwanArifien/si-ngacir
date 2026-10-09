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

## Kemiringan badan saat melompat (derajat), ala pose lari di poster.
const LEAN_DEGREES := 8.0

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
## Pengali durasi langkah (power-up sepatu membuatnya < 1).
var speed_multiplier := 1.0
## Helm aktif: gelembung pelindung terlihat di sekitar Masbro.
var shielded := false:
	set(value):
		shielded = value
		if _shield:
			_shield.visible = value
var invulnerable := false:
	set(value):
		invulnerable = value
		_blink_time = 0.0
		modulate.a = 1.0
		if not value:
			_play(&"idle")

var _tween: Tween
## Arah dari swipe/tap layar sentuh, dijalankan begitu langkah sebelumnya selesai.
var _queued_direction := Vector2i.ZERO
var _facing := 1
var _blink_time := 0.0
## Sprite Masbro dari Illustrator; null berarti memakai gambar placeholder di _draw().
var _body: AnimatedSprite2D
var _package_icon: Sprite2D
## Titik kaki Masbro; lompatan dan squash/stretch berporos di sini.
var _visual: Node2D
var _hop_tween: Tween
var _shield: Node2D
var _accessories: Node2D


func _ready() -> void:
	var frames := SpriteLibrary.frames({
		&"idle": "masbro_idle",
		&"walk": "masbro_walk",
		&"hit": "masbro_hit",
	}, Vector2i(48, 48))
	_visual = Node2D.new()
	_visual.position = Vector2(tile / 2.0, tile)
	add_child(_visual)
	var rig := Node2D.new()
	rig.position = -_visual.position
	_visual.add_child(rig)
	if frames:
		_body = SpriteLibrary.animated(frames)
		rig.add_child(_body)
		_play(&"idle")

	if _body:
		_accessories = Cosmetics.dress(rig, GameState.equipped_ids())
		_body.frame_changed.connect(func() -> void: Cosmetics.sync_bob(_accessories, _body))
		_body.animation_changed.connect(func() -> void: Cosmetics.sync_bob(_accessories, _body))

	_package_icon = SpriteLibrary.sprite("package_%s" % package_id)
	if _package_icon == null:
		_package_icon = Sprite2D.new()
		_package_icon.centered = false
		_package_icon.texture = SpriteLibrary.placeholder_box(Vector2i(20, 15), package_color, Color("6e4a2b"))
	rig.add_child(_package_icon)
	_shield = Node2D.new()
	_shield.position = Vector2(0, -tile / 2.0)
	_shield.visible = shielded
	_shield.draw.connect(func() -> void:
		_shield.draw_circle(Vector2.ZERO, tile * 0.62, Color(Palette.TEAL, 0.18))
		_shield.draw_arc(Vector2.ZERO, tile * 0.62, 0.0, TAU, 40, Color(Palette.TEAL, 0.85), 3.0, true)
		_shield.draw_arc(Vector2.ZERO, tile * 0.5, -2.4, -1.6, 10, Color(1, 1, 1, 0.8), 3.0, true))
	_visual.add_child(_shield)
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


## Bergeser mengikuti rakit di sungai; kolom grid ikut diperbarui.
func ride(dx: float) -> void:
	position.x += dx
	cell.x = clampi(roundi(position.x / tile), 0, grid_size.x - 1)


## Antre satu langkah (dipakai kontrol sentuh).
func queue_move(direction: Vector2i) -> void:
	if input_enabled:
		_queued_direction = direction


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
	if _queued_direction != Vector2i.ZERO:
		var direction := _queued_direction
		_queued_direction = Vector2i.ZERO
		_try_move(direction)
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
	_hop_to(target, step_time * speed_multiplier)
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
	_tween.tween_callback(_on_hop_finished.bind(animation == &"walk"))
	if animation == &"walk":
		_bounce(duration)


## Lompatan kecil dengan squash & stretch, berporos di kaki.
func _bounce(duration: float, height := 7.0) -> void:
	if _hop_tween:
		_hop_tween.kill()
	_visual.position.y = tile
	_hop_tween = create_tween()
	_hop_tween.tween_property(_visual, "position:y", tile - height, duration * 0.5) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hop_tween.parallel().tween_property(_visual, "scale", Vector2(0.9, 1.12), duration * 0.5)
	# Condong ke depan (arah hadap) saat melompat, tegak lagi saat mendarat.
	_hop_tween.parallel().tween_property(_visual, "rotation_degrees", LEAN_DEGREES * _facing, duration * 0.5)
	_hop_tween.tween_property(_visual, "position:y", tile, duration * 0.5) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_hop_tween.parallel().tween_property(_visual, "scale", Vector2(1.15, 0.86), duration * 0.5)
	_hop_tween.parallel().tween_property(_visual, "rotation_degrees", 0.0, duration * 0.5)
	_hop_tween.tween_property(_visual, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK)


## Terpental berputar satu kali saat tertabrak (diam saja bila "Kurangi efek gerak").
func tumble() -> void:
	if Accessibility.reduce_motion:
		return
	if _hop_tween:
		_hop_tween.kill()
	_visual.position.y = tile
	_visual.scale = Vector2.ONE
	_visual.rotation = 0.0
	_hop_tween = create_tween()
	_hop_tween.tween_property(_visual, "rotation", TAU * -_facing, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hop_tween.parallel().tween_property(_visual, "position:y", tile - 12.0, 0.17).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hop_tween.parallel().tween_property(_visual, "position:y", tile, 0.18).set_delay(0.17).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_hop_tween.tween_callback(func() -> void: _visual.rotation = 0.0)


## Tercebur: badan gepeng masuk air sebentar lalu muncul lagi.
func plop() -> void:
	if _hop_tween:
		_hop_tween.kill()
	_visual.rotation = 0.0
	_hop_tween = create_tween()
	_hop_tween.tween_property(_visual, "scale", Vector2(1.35, 0.35), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_hop_tween.parallel().tween_property(_visual, "modulate", Color(0.7, 0.85, 1.0, 0.6), 0.12)
	_hop_tween.tween_property(_visual, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_hop_tween.parallel().tween_property(_visual, "modulate", Color.WHITE, 0.25)


## Lompat girang saat paket sampai.
func celebrate() -> void:
	if _hop_tween:
		_hop_tween.kill()
	_visual.rotation_degrees = 0.0
	_hop_tween = create_tween().set_loops(2)
	_hop_tween.tween_property(_visual, "position:y", tile - 16.0, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hop_tween.parallel().tween_property(_visual, "scale", Vector2(0.9, 1.15), 0.16)
	_hop_tween.tween_property(_visual, "position:y", tile, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_hop_tween.parallel().tween_property(_visual, "scale", Vector2(1.15, 0.85), 0.16)
	_hop_tween.tween_property(_visual, "scale", Vector2.ONE, 0.08)


func _on_hop_finished(walked: bool) -> void:
	if not invulnerable:
		_play(&"idle")
	if walked and get_parent():
		Effects.dust(get_parent(), position + Vector2(tile / 2.0, tile - 4.0))
		Effects.gravel(get_parent(), position + Vector2(tile / 2.0 - 6.0 * _facing, tile - 4.0), -_facing)
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
	if _accessories:
		Cosmetics.set_flip(_accessories, _facing < 0)
	if _package_icon:
		# Paket di punggung Masbro (di belakang kepala).
		_package_icon.position = Vector2(4, 6) if _facing > 0 else Vector2(24, 6)
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

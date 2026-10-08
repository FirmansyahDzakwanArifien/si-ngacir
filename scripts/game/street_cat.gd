class_name StreetCat
extends Node2D
## Kucing jalanan yang menyeberang pelan. Tidak merusak paket, tapi menghalangi petak
## sehingga Masbro harus mencari jalur lain. Kalau bersentuhan dengan Masbro, kucing
## duduk sebentar karena penasaran dengan tas kurirnya.

const SIT_TIME := 1.2
## Setelah duduk, kucing mengabaikan Masbro sebentar supaya tidak duduk terus-menerus.
const IGNORE_TIME := 2.0

var tile := 48.0
var direction := 1
var speed := 40.0
var board_width := 720.0

var _sit_left := 0.0
var _ignore_left := 0.0
var _body: AnimatedSprite2D


func _ready() -> void:
	var frames := SpriteLibrary.frames({&"walk": "cat_walk", &"sit": "cat_sit"}, Vector2i(48, 48))
	if frames:
		_body = AnimatedSprite2D.new()
		_body.centered = false
		_body.sprite_frames = frames
		_body.flip_h = direction < 0
		add_child(_body)
		_play(&"walk")


func hitbox() -> Rect2:
	return Rect2(position + Vector2(8, 16), Vector2(tile - 16, tile - 24))


func is_sitting() -> bool:
	return _sit_left > 0.0


## Dipanggil level saat kucing menyentuh Masbro. Mengembalikan true kalau kucing jadi duduk.
func notice_player() -> bool:
	if _sit_left > 0.0 or _ignore_left > 0.0:
		return false
	_sit_left = SIT_TIME
	_play(&"sit")
	queue_redraw()
	return true


func _process(delta: float) -> void:
	_ignore_left = maxf(0.0, _ignore_left - delta)
	if _sit_left > 0.0:
		_sit_left -= delta
		if _sit_left <= 0.0:
			_ignore_left = IGNORE_TIME
			_play(&"walk")
			queue_redraw()
		return
	position.x += speed * direction * delta
	if position.x > board_width + tile or position.x < -tile * 2.0:
		queue_free()


func _play(animation: StringName) -> void:
	if _body and _body.sprite_frames.has_animation(animation):
		_body.play(animation)


func _draw() -> void:
	if _body:
		return
	# Placeholder kucing oranye sampai sprite siap.
	var fur := Color("f4a259")
	var dark := Color("8c5a2b")
	var sitting := _sit_left > 0.0
	var head_x := 30.0 if direction > 0 else 4.0
	if sitting:
		draw_rect(Rect2(14, 22, 20, 20), fur)
		head_x = 17.0
		draw_rect(Rect2(head_x, 12, 14, 12), fur)
	else:
		draw_rect(Rect2(10, 24, 28, 12), fur)
		draw_rect(Rect2(head_x, 18, 14, 12), fur)
		for x: float in [12.0, 18.0, 28.0, 34.0]:
			draw_rect(Rect2(x, 36, 3, 4), dark)
	draw_colored_polygon(PackedVector2Array([
		Vector2(head_x, 18.0 if not sitting else 12.0),
		Vector2(head_x + 3, 13.0 if not sitting else 7.0),
		Vector2(head_x + 6, 18.0 if not sitting else 12.0)]), fur)
	draw_colored_polygon(PackedVector2Array([
		Vector2(head_x + 8, 18.0 if not sitting else 12.0),
		Vector2(head_x + 11, 13.0 if not sitting else 7.0),
		Vector2(head_x + 14, 18.0 if not sitting else 12.0)]), fur)
	var eye_y := 22.0 if not sitting else 16.0
	draw_rect(Rect2(head_x + 3, eye_y, 2, 2), Color.BLACK)
	draw_rect(Rect2(head_x + 9, eye_y, 2, 2), Color.BLACK)
	var tail_x := 6.0 if direction > 0 else 38.0
	if not sitting:
		draw_line(Vector2(tail_x + 4, 26), Vector2(tail_x, 16), dark, 3.0)

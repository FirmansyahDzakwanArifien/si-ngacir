class_name Vehicle
extends Node2D
## Kendaraan yang melaju di satu lane dan muncul lagi dari sisi seberang.

const TYPES := {
	&"motor": {"length": 1, "damage": 1, "color": Color("e04f5f")},
	&"mobil": {"length": 2, "damage": 1, "color": Color("4f8fe0")},
	&"truk": {"length": 3, "damage": 2, "color": Color("e0a84f")},
}

var damage := 1
var direction := 1
var speed := 60.0
var length_px := 96.0
var tile := 48.0
var color := Color.WHITE
var loop_start := 0.0
var loop_length := 1.0
var _sprite: Sprite2D


func setup(type: StringName, p_tile: float, p_speed: float, p_direction: int,
		p_loop_start: float, p_loop_length: float) -> void:
	var info: Dictionary = TYPES.get(type, TYPES[&"mobil"])
	tile = p_tile
	length_px = info["length"] * tile
	damage = info["damage"]
	color = info["color"]
	speed = p_speed
	direction = p_direction
	loop_start = p_loop_start
	loop_length = p_loop_length
	var texture := SpriteLibrary.texture("vehicle_%s" % type)
	if texture:
		_sprite = Sprite2D.new()
		_sprite.centered = false
		_sprite.texture = texture
		# Sprite kendaraan digambar menghadap kanan.
		_sprite.flip_h = direction < 0
		add_child(_sprite)
	queue_redraw()


func hitbox() -> Rect2:
	return Rect2(position + Vector2(4, 10), Vector2(length_px - 8, tile - 20))


func _process(delta: float) -> void:
	position.x = loop_start + fposmod(position.x + speed * direction * delta - loop_start, loop_length)


func _draw() -> void:
	if _sprite:
		return
	var tire := Color(0.12, 0.12, 0.14)
	draw_rect(Rect2(6, 6, 10, 4), tire)
	draw_rect(Rect2(length_px - 16, 6, 10, 4), tire)
	draw_rect(Rect2(6, tile - 10, 10, 4), tire)
	draw_rect(Rect2(length_px - 16, tile - 10, 10, 4), tire)
	var body := Rect2(2, 9, length_px - 4, tile - 18)
	draw_rect(body, color)
	var glass_width := minf(14.0, length_px * 0.3)
	var glass_x := body.end.x - glass_width - 4.0 if direction > 0 else body.position.x + 4.0
	draw_rect(Rect2(glass_x, 13, glass_width, tile - 26), color.darkened(0.45))

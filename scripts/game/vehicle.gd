class_name Vehicle
extends Node2D
## Kendaraan yang melaju di satu lane dan muncul lagi dari sisi seberang.

const TYPES := {
	&"motor": {"length": 1, "damage": 1, "color": Color("e04f5f")},
	&"mobil": {"length": 2, "damage": 1, "color": Color("4f8fe0")},
	&"truk": {"length": 3, "damage": 2, "color": Color("e0a84f")},
	# Bang Kilat, kurir rival: sekali lewat dengan sangat cepat.
	&"kilat": {"length": 1, "damage": 1, "color": Color("06d6a0")},
	# Rakit di sungai: bukan penabrak, tapi pijakan.
	&"rakit2": {"length": 2, "damage": 0, "color": Color("c98b52"), "platform": true},
	&"rakit3": {"length": 3, "damage": 0, "color": Color("c98b52"), "platform": true},
}
## Tinggi lampu depan pada sprite (bagian dari tinggi petak) dan panjang berkas cahayanya.
const HEADLIGHT_Y := 0.62
const BEAM_LENGTH := 76.0

var damage := 1
## true untuk rakit: dinaiki, bukan dihindari.
var is_platform := false
## true: lewat sekali lalu hilang (tidak berputar ke sisi seberang).
var one_shot := false
var type: StringName
var direction := 1
var speed := 60.0
var length_px := 96.0
var tile := 48.0
var color := Color.WHITE
var loop_start := 0.0
var loop_length := 1.0
## Lampu depan menyala (hari hujan): berkas cahaya menembus gelapnya hujan.
var headlights := false
var _sprite: Sprite2D
var _bob_time := randf() * TAU


func setup(type: StringName, p_tile: float, p_speed: float, p_direction: int,
		p_loop_start: float, p_loop_length: float) -> void:
	self.type = type
	var info: Dictionary = TYPES.get(type, TYPES[&"mobil"])
	tile = p_tile
	length_px = info["length"] * tile
	damage = info["damage"]
	is_platform = info.get("platform", false)
	color = info["color"]
	speed = p_speed
	direction = p_direction
	loop_start = p_loop_start
	loop_length = p_loop_length
	# Pilih varian warna secara acak supaya jalanan lebih ramai.
	var names := SpriteLibrary.variants("vehicle_%s" % type)
	_sprite = SpriteLibrary.sprite(names.pick_random()) if not names.is_empty() else null
	if _sprite:
		# Sprite kendaraan digambar menghadap kanan.
		_sprite.flip_h = direction < 0
		add_child(_sprite)
	queue_redraw()


func _ready() -> void:
	if headlights and not is_platform:
		_add_headlight_beam()


func _add_headlight_beam() -> void:
	var beam := Polygon2D.new()
	beam.name = "Headlights"
	var front := length_px - 4.0 if direction > 0 else 4.0
	var reach := BEAM_LENGTH * direction
	var y := tile * HEADLIGHT_Y
	beam.polygon = PackedVector2Array([
		Vector2(front, y - 3), Vector2(front + reach, y - 17),
		Vector2(front + reach, y + 17), Vector2(front, y + 3)])
	var light := Color(1.0, 0.92, 0.6, 0.55)
	beam.vertex_colors = PackedColorArray([light, Color(light, 0.0), Color(light, 0.0), light])
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	beam.material = material
	# Di atas lapisan gelap hujan (z 10) supaya mobil terlihat dari jauh.
	beam.z_index = 11
	add_child(beam)


func hitbox() -> Rect2:
	return Rect2(position + Vector2(4, 10), Vector2(length_px - 8, tile - 20))


func _process(delta: float) -> void:
	if one_shot:
		position.x += speed * direction * delta
		if position.x > loop_start + loop_length or position.x < loop_start - length_px:
			queue_free()
	else:
		position.x = loop_start + fposmod(position.x + speed * direction * delta - loop_start, loop_length)
	if _sprite and not is_platform:
		# Bodi bergoyang pelan seperti mesin hidup.
		_bob_time += delta * (6.0 + speed * 0.04)
		_sprite.position.y = roundf(sin(_bob_time) * 1.2)


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

class_name CloudShadows
extends Node2D
## Bayangan awan yang melintas pelan di atas papan: kesan langit berlapis di atas jalan.
## Diam saat "Kurangi efek gerak" aktif.

const COUNT := 4
const SPEED := 9.0
const OPACITY := 0.16

## Luas papan (piksel game).
var area := Vector2(720, 600)

var _blob: Texture2D
var _clouds: Array[Rect2] = []


func _ready() -> void:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.1, 0.12, 0.25, 1.0))
	gradient.set_color(1, Color(0.1, 0.12, 0.25, 0.0))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 128
	texture.height = 128
	_blob = texture
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in COUNT:
		var size := Vector2(rng.randf_range(260, 380), rng.randf_range(150, 220))
		var start := Vector2(rng.randf_range(-size.x, area.x), area.y * (i + rng.randf()) / COUNT - size.y / 2.0)
		_clouds.append(Rect2(start, size))
	modulate.a = OPACITY


func _process(delta: float) -> void:
	if Accessibility.reduce_motion:
		return
	for i in _clouds.size():
		var cloud := _clouds[i]
		cloud.position.x += SPEED * delta * (0.8 + 0.1 * i)
		if cloud.position.x > area.x:
			cloud.position.x = -cloud.size.x
		_clouds[i] = cloud
	queue_redraw()


func _draw() -> void:
	for cloud in _clouds:
		# Tiga gumpalan per awan supaya bentuknya tidak bulat sempurna.
		draw_texture_rect(_blob, cloud, false)
		draw_texture_rect(_blob, Rect2(cloud.position + cloud.size * Vector2(0.35, -0.2), cloud.size * 0.7), false)
		draw_texture_rect(_blob, Rect2(cloud.position + cloud.size * Vector2(-0.15, 0.25), cloud.size * 0.6), false)

class_name Effects
extends RefCounted
## Efek partikel kecil: debu dan kerikil langkah, letupan tabrakan, dan konfeti.

static var _dot: Texture2D


static func dust(parent: Node, at: Vector2) -> void:
	var particles := _make(parent, at, 6, 0.35)
	particles.direction = Vector2.UP
	particles.spread = 70.0
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 45.0
	particles.gravity = Vector2(0, 40)
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 0.9
	particles.color = Color(1, 0.97, 0.9, 0.85)
	particles.color_ramp = _fade()
	particles.emitting = true


## Kerikil kecil terpercik ke belakang (direction: -1 kiri, 1 kanan) saat Masbro mendarat.
static func gravel(parent: Node, at: Vector2, direction: int) -> void:
	var particles := _make(parent, at, 4, 0.4)
	particles.direction = Vector2(direction, -1.2).normalized()
	particles.spread = 30.0
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 90.0
	particles.gravity = Vector2(0, 380)
	particles.scale_amount_min = 0.35
	particles.scale_amount_max = 0.55
	particles.color = Color("6b5a4e")
	particles.color_ramp = _fade(0.7)
	particles.emitting = true


## Letupan saat tertabrak: bintang kuning dan serpihan paket.
static func burst(parent: Node, at: Vector2, package_color: Color) -> void:
	for colors: Array in [[Palette.YELLOW, 10], [package_color, 8]]:
		var particles := _make(parent, at, colors[1], 0.55)
		particles.spread = 180.0
		particles.initial_velocity_min = 90.0
		particles.initial_velocity_max = 170.0
		particles.gravity = Vector2(0, 260)
		particles.angular_velocity_min = -360.0
		particles.angular_velocity_max = 360.0
		particles.scale_amount_min = 0.7
		particles.scale_amount_max = 1.3
		particles.color = colors[0]
		particles.color_ramp = _fade()
		particles.emitting = true


## Hujan konfeti dari garis selebar width yang berpusat di at.
## Cipratan air saat tercebur ke sungai.
static func splash(parent: Node, at: Vector2) -> void:
	for color in [Color("5bc0eb"), Color("e6f7ff")]:
		var particles := _make(parent, at, 12, 0.6)
		particles.direction = Vector2.UP
		particles.spread = 50.0
		particles.initial_velocity_min = 90.0
		particles.initial_velocity_max = 170.0
		particles.gravity = Vector2(0, 420)
		particles.scale_amount_min = 0.8
		particles.scale_amount_max = 1.4
		particles.color = color
		particles.color_ramp = _fade()
		particles.emitting = true


static func confetti(parent: Node, at: Vector2, width: float) -> void:
	for color in [Palette.YELLOW, Palette.TEAL, Palette.CORAL, Palette.LAVENDER, Palette.PINK]:
		var particles := _make(parent, at, 14, 2.4)
		particles.explosiveness = 0.5
		particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		particles.emission_rect_extents = Vector2(width / 2.0, 4.0)
		particles.direction = Vector2.DOWN
		particles.spread = 25.0
		particles.initial_velocity_min = 60.0
		particles.initial_velocity_max = 150.0
		particles.gravity = Vector2(0, 160)
		particles.angular_velocity_min = -300.0
		particles.angular_velocity_max = 300.0
		particles.scale_amount_min = 0.9
		particles.scale_amount_max = 1.5
		particles.color = color
		particles.color_ramp = _fade(0.8)
		particles.emitting = true


static func _make(parent: Node, at: Vector2, amount: int, lifetime: float) -> CPUParticles2D:
	var particles := CPUParticles2D.new()
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = amount
	particles.lifetime = lifetime
	particles.texture = _dot_texture()
	particles.position = at
	particles.z_index = 15
	parent.add_child(particles)
	particles.finished.connect(particles.queue_free)
	return particles


static func _fade(hold := 0.5) -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color.WHITE)
	gradient.set_color(1, Color(1, 1, 1, 0))
	gradient.add_point(hold, Color.WHITE)
	return gradient


static func _dot_texture() -> Texture2D:
	if _dot == null:
		var size := 10
		var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
		var center := Vector2.ONE * size / 2.0
		for y in size:
			for x in size:
				var d := Vector2(x + 0.5, y + 0.5).distance_to(center)
				image.set_pixel(x, y, Color(1, 1, 1, clampf(size / 2.0 - d, 0.0, 1.0)))
		_dot = ImageTexture.create_from_image(image)
	return _dot

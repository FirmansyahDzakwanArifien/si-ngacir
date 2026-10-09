class_name Effects
extends RefCounted
## Efek kecil: debu dan kerikil langkah, letupan dan ledakan komik saat tabrakan,
## riak dan gelembung saat tercebur, asap, serpihan, cipratan, dan konfeti.

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


## Ledakan komik di titik benturan: bintang bergerigi dengan tulisan bunyi ("BRAK!", "BYUR!").
static func impact(parent: Node, at: Vector2, text: String, color: Color) -> Node2D:
	var holder := Node2D.new()
	holder.position = at
	holder.z_index = 16
	holder.rotation = randf_range(-0.25, 0.25)
	parent.add_child(holder)
	for layer: Array in [[36.0, 19.0, Palette.OUTLINE], [32.0, 17.0, color], [21.0, 11.0, Color.WHITE]]:
		var star := Polygon2D.new()
		star.polygon = _star_points(10, layer[0], layer[1])
		star.color = layer[2]
		holder.add_child(star)
	var label := Label.new()
	label.text = text
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	label.set_meta(Accessibility.FIXED_SIZE_META, true)
	label.add_theme_font_override("font", UiTheme.font(700))
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Palette.WHITE)
	label.add_theme_color_override("font_outline_color", Palette.OUTLINE)
	label.add_theme_constant_override("outline_size", 5)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(80, 24)
	label.position = Vector2(-40, -12)
	holder.add_child(label)
	holder.scale = Vector2(0.3, 0.3)
	var tween := holder.create_tween()
	tween.tween_property(holder, "scale", Vector2(1.15, 1.15), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.18)
	tween.tween_property(holder, "modulate:a", 0.0, 0.18)
	tween.tween_callback(holder.queue_free)
	return holder


## Riak air yang melebar dari titik tercebur.
static func ripples(parent: Node, at: Vector2) -> void:
	var holder := Node2D.new()
	holder.position = at
	holder.z_index = 14
	parent.add_child(holder)
	holder.draw.connect(func() -> void:
		var progress: float = holder.get_meta(&"progress", 0.0)
		for i in 2:
			var t := clampf(progress * 1.3 - i * 0.3, 0.0, 1.0)
			if t <= 0.0:
				continue
			holder.draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
			holder.draw_arc(Vector2.ZERO, 6.0 + t * 30.0, 0.0, TAU, 32, Color(1, 1, 1, 0.8 * (1.0 - t)), 2.5, true))
	var tween := holder.create_tween()
	tween.tween_method(func(value: float) -> void:
		holder.set_meta(&"progress", value)
		holder.queue_redraw(), 0.0, 1.0, 0.7)
	tween.tween_callback(holder.queue_free)


## Gelembung naik dari dalam air.
static func bubbles(parent: Node, at: Vector2) -> void:
	var particles := _make(parent, at, 8, 0.9)
	particles.explosiveness = 0.6
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(12, 3)
	particles.direction = Vector2.UP
	particles.spread = 15.0
	particles.initial_velocity_min = 15.0
	particles.initial_velocity_max = 35.0
	particles.gravity = Vector2(0, -30)
	particles.scale_amount_min = 0.4
	particles.scale_amount_max = 0.8
	particles.color = Color("e6f7ff")
	particles.color_ramp = _fade(0.6)
	particles.emitting = true


## Kepulan asap abu-abu (paket hancur).
static func smoke(parent: Node, at: Vector2) -> void:
	var particles := _make(parent, at, 10, 0.9)
	particles.direction = Vector2.UP
	particles.spread = 60.0
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 50.0
	particles.gravity = Vector2(0, -20)
	particles.scale_amount_min = 1.6
	particles.scale_amount_max = 2.6
	particles.color = Color(0.45, 0.42, 0.44, 0.7)
	particles.color_ramp = _fade(0.4)
	particles.emitting = true


## Serpihan berwarna yang terlempar ke segala arah (helm pecah).
static func shards(parent: Node, at: Vector2, color: Color) -> void:
	var particles := _make(parent, at, 12, 0.45)
	particles.spread = 180.0
	particles.initial_velocity_min = 110.0
	particles.initial_velocity_max = 190.0
	particles.gravity = Vector2(0, 200)
	particles.scale_amount_min = 0.4
	particles.scale_amount_max = 0.8
	particles.color = color
	particles.color_ramp = _fade(0.6)
	particles.emitting = true


## Cipratan air dari aspal basah saat tergelincir (direction: arah luncur).
static func spray(parent: Node, at: Vector2, direction: Vector2) -> void:
	var particles := _make(parent, at, 10, 0.45)
	particles.direction = (-direction + Vector2(0, -1)).normalized()
	particles.spread = 35.0
	particles.initial_velocity_min = 60.0
	particles.initial_velocity_max = 110.0
	particles.gravity = Vector2(0, 300)
	particles.scale_amount_min = 0.4
	particles.scale_amount_max = 0.8
	particles.color = Color("bfe6fb")
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


static func _star_points(spikes: int, outer: float, inner: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in spikes * 2:
		var radius := outer if i % 2 == 0 else inner
		points.append(Vector2.from_angle(TAU * i / (spikes * 2)) * radius)
	return points


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

class_name MenuBackdrop
extends Control
## Latar menu yang hidup: langit, awan berarak, jalan dengan kendaraan lewat,
## dan Masbro bersama kucing di trotoar. Dipakai layar judul dan rekap.

const TILE := 48.0
const CLOUDS := [Vector3(0.12, 70, 1.0), Vector3(0.55, 40, 0.8), Vector3(0.82, 110, 1.2), Vector3(0.35, 150, 0.7)]

## Tampilkan Masbro dan kucing di trotoar.
@export var show_characters := true

var _cloud_offset := 0.0
var _street: Node2D
var _masbro: Node2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_street = Node2D.new()
	add_child(_street)
	resized.connect(_build_street)
	_build_street.call_deferred()


func _process(delta: float) -> void:
	_cloud_offset += delta * 12.0
	queue_redraw()


func _draw() -> void:
	var view := size
	var sky_top := Palette.SKY_DEEP
	var sky_bottom := Palette.SKY.lerp(Palette.CREAM, 0.35)
	draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(view.x, 0), view, Vector2(0, view.y)]),
			PackedColorArray([sky_top, sky_top, sky_bottom, sky_bottom]))
	for cloud: Vector3 in CLOUDS:
		var x := fposmod(cloud.x * view.x + _cloud_offset * cloud.z, view.x + 200.0) - 100.0
		_draw_cloud(Vector2(x, cloud.y), cloud.z)


func _draw_cloud(center: Vector2, scale: float) -> void:
	for blob: Vector3 in [Vector3(-30, 6, 22), Vector3(0, -6, 30), Vector3(32, 4, 24), Vector3(10, 10, 24)]:
		draw_circle(center + Vector2(blob.x, blob.y) * scale, blob.z * scale + 3.0, Color(1, 1, 1, 0.35))
	for blob: Vector3 in [Vector3(-30, 6, 22), Vector3(0, -6, 30), Vector3(32, 4, 24), Vector3(10, 10, 24)]:
		draw_circle(center + Vector2(blob.x, blob.y) * scale, blob.z * scale, Color.WHITE)


func _build_street() -> void:
	for child in _street.get_children():
		child.queue_free()
	var view := size
	if view.x <= 0.0:
		return
	var sidewalk_y := view.y - TILE
	var road_top := sidewalk_y - TILE * 2.0
	var tiles := Node2D.new()
	tiles.draw.connect(func() -> void: _draw_street_tiles(tiles, view.x, road_top, sidewalk_y))
	_street.add_child(tiles)

	var loop := view.x + TILE * 4.0
	for lane in 2:
		var direction := 1 if lane == 0 else -1
		for i in 2:
			var vehicle := Vehicle.new()
			vehicle.setup([&"mobil", &"motor", &"truk"][(lane + i) % 3], TILE, 70.0 + lane * 25.0,
					direction, -TILE * 4.0, loop)
			vehicle.position = Vector2(-TILE * 4.0 + fposmod(i * loop / 2.0 + lane * 150.0, loop), road_top + lane * TILE)
			_street.add_child(vehicle)

	if not show_characters:
		return
	var frames := SpriteLibrary.frames({&"idle": "masbro_idle"}, Vector2i(48, 48), 6.0)
	if frames:
		_masbro = SpriteLibrary.animated(frames)
		_masbro.scale *= 2.0
		_masbro.position = Vector2(view.x * 0.12, sidewalk_y - TILE * 1.25)
		(_masbro as AnimatedSprite2D).play(&"idle")
		_street.add_child(_masbro)
	var cat_frames := SpriteLibrary.frames({&"sit": "cat_sit"}, Vector2i(48, 48), 3.0)
	if cat_frames:
		var cat := SpriteLibrary.animated(cat_frames)
		cat.scale *= 1.4
		cat.flip_h = true
		cat.position = Vector2(view.x * 0.82, sidewalk_y - TILE * 0.55)
		cat.play(&"sit")
		_street.add_child(cat)


func _draw_street_tiles(canvas: Node2D, width: float, road_top: float, sidewalk_y: float) -> void:
	var road := SpriteLibrary.texture("tile_road")
	var walk := SpriteLibrary.texture("tile_sidewalk")
	var x := 0.0
	while x < width:
		for lane in 2:
			var rect := Rect2(x, road_top + lane * TILE, TILE, TILE)
			if road:
				canvas.draw_texture_rect(road, rect, false)
			else:
				canvas.draw_rect(rect, Color("545978"))
		var walk_rect := Rect2(x, sidewalk_y, TILE, TILE)
		if walk:
			canvas.draw_texture_rect(walk, walk_rect, false)
		else:
			canvas.draw_rect(walk_rect, Palette.CREAM_DARK)
		canvas.draw_line(Vector2(x + 8, road_top + TILE), Vector2(x + 28, road_top + TILE),
				Color(1, 0.96, 0.86, 0.75), 3.0)
		x += TILE
	canvas.draw_line(Vector2(0, road_top), Vector2(width, road_top), Palette.OUTLINE, 3.0)

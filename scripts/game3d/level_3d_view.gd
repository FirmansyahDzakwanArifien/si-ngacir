extends Node3D
## Tampilan 3D (beta) satu hari pengiriman.
##
## Logika game tetap di Level (grid, tabrakan, ETA, ambil-antar paket, Pos). Node ini hanya membaca
## keadaan Level setiap frame lalu menggambarnya dalam 3D: papan 2D disembunyikan, HUD tetap sama.
## Pemetaan: 1 petak (48 px) = 1 meter; kolom → x, baris → z (baris 0 = rumah pelanggan, paling jauh).
##
## Hanya dimuat bila build punya modul 3D (lihat GameState.supports_3d).

const Props := preload("res://scripts/game3d/props_3d.gd")

const TILE := 48.0
## Lebar pemandangan di kiri/kanan papan (petak).
const SIDE := 8
const CAMERA_HEIGHT := 8.0
const CAMERA_BACK := 8.5
const CAMERA_LOOK_AHEAD := 3.0
const CAMERA_SMOOTHING := 5.0
## Kamera sedikit menyerong dari kanan (sudut 3/4) supaya bentuk karakter terlihat.
const CAMERA_SIDE := 2.6
## Ketinggian permukaan per jenis lane (trotoar dan median sedikit lebih tinggi dari aspal).
const SURFACE := {LaneData.Kind.ROAD: 0.0, LaneData.Kind.SIDEWALK: 0.08, LaneData.Kind.MEDIAN: 0.08, LaneData.Kind.RIVER: -0.05}
const LANE_COLORS := {
	LaneData.Kind.ROAD: Color("545978"),
	LaneData.Kind.SIDEWALK: Color("f3e0ba"),
	LaneData.Kind.MEDIAN: Color("8bd17c"),
	LaneData.Kind.RIVER: Color("5bc0eb"),
}

## Level yang digambar (diisi sebelum add_child).
var level: Node2D

var _camera: Camera3D
var _sun: DirectionalLight3D
var _player: Node3D
var _pose: Node3D
var _vehicles := {}
var _items := {}
var _cats := {}
## Teks dan balon 2D yang dicerminkan ke 3D: sumber → Label3D.
var _labels := {}
var _bubbles := {}
var _pickup_marker: Node3D
var _time := 0.0
var _yaw := 0.0


func _ready() -> void:
	_build_environment()
	_build_ground()
	_build_props()
	_build_player()
	_camera = Camera3D.new()
	_camera.fov = 50.0
	_camera.far = 120.0
	add_child(_camera)
	_camera.make_current()
	_snap_camera()
	get_tree().node_added.connect(_on_node_added)
	# Balon yang sudah ada sebelum tampilan 3D dibuat (misalnya pelanggan).
	for node in level._board.find_children("*", "", true, false):
		if node is SpeechBubble:
			_on_node_added(node)


func _exit_tree() -> void:
	if get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.disconnect(_on_node_added)


# ------------------------------------------------------------------ Dunia

static func _is_handheld() -> bool:
	return OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios")


func _build_environment() -> void:
	var rainy: bool = level.day.rainy
	var sky := ProceduralSkyMaterial.new()
	sky.sky_top_color = Color("3a8fe8") if not rainy else Color("4a5868")
	sky.sky_horizon_color = Color("bfe9ff") if not rainy else Color("8a96a3")
	sky.ground_horizon_color = sky.sky_horizon_color
	sky.ground_bottom_color = Color("5fae55")
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = Sky.new()
	environment.sky.sky_material = sky
	# Ambient warna tetap (bukan dari langit) supaya warna kawaii tidak pucat.
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("c9d8ff") if not rainy else Color("9aa8b8")
	environment.ambient_light_energy = 0.45 if not rainy else 0.3
	environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	if rainy:
		environment.fog_enabled = true
		environment.fog_light_color = Color("7d8a99")
		environment.fog_density = 0.035
	var world := WorldEnvironment.new()
	world.environment = environment
	add_child(world)

	# Matahari dari kanan atas, hangat seperti poster (redup kebiruan saat hujan).
	_sun = DirectionalLight3D.new()
	_sun.rotation_degrees = Vector3(-52, -38, 0)
	_sun.light_color = Color("ffe2b0") if not rainy else Color("b8c6d6")
	_sun.light_energy = 1.0 if not rainy else 0.35
	# Bayangan real-time hanya di desktop; HP (APK atau browser HP) lebih ringan tanpa bayangan.
	_sun.shadow_enabled = not _is_handheld()
	_sun.directional_shadow_max_distance = 40.0
	add_child(_sun)

	if rainy:
		var rain := CPUParticles3D.new()
		rain.name = "Rain"
		rain.amount = 500
		rain.lifetime = 0.8
		rain.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
		rain.emission_box_extents = Vector3(12, 0.5, 12)
		rain.direction = Vector3(0.15, -1, 0)
		rain.spread = 3.0
		rain.initial_velocity_min = 14.0
		rain.initial_velocity_max = 18.0
		rain.gravity = Vector3(0, -10, 0)
		var drop := BoxMesh.new()
		drop.size = Vector3(0.015, 0.35, 0.015)
		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.albedo_color = Color(0.85, 0.92, 1.0, 0.55)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		drop.material = mat
		rain.mesh = drop
		add_child(rain)


func _build_ground() -> void:
	var lanes: Array = level.day.lanes
	var columns: int = level.COLUMNS
	var width := columns + SIDE * 2
	var dashes: Array[Transform3D] = []
	for row in lanes.size():
		var lane: LaneData = lanes[row]
		var top: float = SURFACE[lane.kind]
		var color: Color = LANE_COLORS[lane.kind]
		var thickness := 0.3
		# Bagian papan permainan, lalu pemandangan kiri/kanan sedikit lebih gelap.
		var slab := Props.box(Vector3(columns, thickness, 1.0), color, Vector3(columns / 2.0, top - thickness / 2.0, row + 0.5), false)
		add_child(slab)
		for side in [-1, 1]:
			var side_color := color.darkened(0.12)
			if lane.kind != LaneData.Kind.ROAD and lane.kind != LaneData.Kind.RIVER:
				side_color = Color("8bd17c").darkened(0.08)
			var x: float = columns / 2.0 + side * (columns / 2.0 + SIDE / 2.0)
			add_child(Props.box(Vector3(SIDE, thickness, 1.0), side_color, Vector3(x, top - thickness / 2.0 - 0.01, row + 0.5), false))
		if lane.kind == LaneData.Kind.RIVER:
			# Dasar sungai lebih dalam supaya air terlihat cekung.
			slab.position.y -= 0.12
		elif lane.kind != LaneData.Kind.ROAD:
			# Pinggiran trotoar/median.
			for edge in [0.04, 0.96]:
				add_child(Props.box(Vector3(width, 0.12, 0.08), Color("eadbb8"), Vector3(columns / 2.0, top + 0.02, row + edge), false))
			_add_side_trees(row)
		if lane.kind == LaneData.Kind.ROAD and row + 1 < lanes.size() and (lanes[row + 1] as LaneData).kind == LaneData.Kind.ROAD:
			var x := -SIDE + 0.4
			while x < columns + SIDE:
				dashes.append(Transform3D(Basis(), Vector3(x, 0.011, row + 1.0)))
				x += 0.85
	if not dashes.is_empty():
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		var dash := BoxMesh.new()
		dash.size = Vector3(0.42, 0.02, 0.07)
		multimesh.mesh = dash
		multimesh.instance_count = dashes.size()
		for i in dashes.size():
			multimesh.set_instance_transform(i, dashes[i])
		var marks := MultiMeshInstance3D.new()
		marks.multimesh = multimesh
		marks.material_override = Props.material(Color(1, 0.96, 0.86), false)
		add_child(marks)
	# Rumput luas di luar ujung map (di belakang gudang dan di balik rumah pelanggan).
	for z in [-12.0, lanes.size() + 12.0]:
		add_child(Props.box(Vector3(width + 30, 0.2, 24.0), Color("7cc46d"), Vector3(columns / 2.0, -0.12, z), false))
	# Garis batas papan permainan.
	for x in [0.0, float(columns)]:
		add_child(Props.box(Vector3(0.06, 0.04, lanes.size()), Color(Props.OUTLINE, 0.6), Vector3(x, 0.1, lanes.size() / 2.0), false))


func _add_side_trees(row: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = row * 7919 + 13
	for side in [-1, 1]:
		if rng.randf() < 0.55:
			var x: float = -rng.randf_range(1.5, SIDE - 1.0) if side < 0 else level.COLUMNS + rng.randf_range(1.5, SIDE - 1.0)
			var tree := Props.tree(rng.randf_range(0.8, 1.2))
			tree.position = Vector3(x, 0.08, row + 0.5)
			add_child(tree)


func _build_props() -> void:
	var lanes: Array = level.day.lanes
	var columns: int = level.COLUMNS
	for row in lanes.size():
		var lane: LaneData = lanes[row]
		var top: float = SURFACE[lane.kind]
		for col: int in lane.obstacles:
			var node := Props.obstacle(lane.obstacles[col])
			node.position = Vector3(col, top, row)
			add_child(node)
		for col: int in lane.items:
			var item := Props.item(lane.items[col])
			item.position = Vector3(col + 0.5, top + 0.45, row + 0.5)
			add_child(item)
			_items[Vector2i(col, row)] = item
		if lane.checkpoint:
			for col in [0, columns - 1]:
				var flag := Props.flag(Props.TEAL)
				flag.position = Vector3(col + 0.5, top, row + 0.5)
				add_child(flag)
	# Tiang listrik dan kabel di tepi papan.
	var poles: Array = level._decor.poles
	var tops: Array[Vector3] = []
	for base: Vector2 in poles:
		var x := base.x / TILE + 0.15
		if x > columns / 2.0:
			x = columns - 0.15
		var pole := Props.pole()
		pole.position = Vector3(x, 0.08, base.y / TILE - 0.5)
		add_child(pole)
		tops.append(pole.position + Vector3(0, 3.12, 0))
	for i in range(0, tops.size() - 2):
		_wire(tops[i], tops[i + 2])
	for i in range(0, tops.size() - 1, 2):
		_wire(tops[i], tops[i + 1])

	# Rumah pelanggan, papan LEVEL NEXT, gudang dan billboard.
	var last := lanes.size() - 1
	var house := Props.house(2.0)
	house.position = Vector3(columns - 2.17, 0.08, 0.35)
	add_child(house)
	var sign := Props.box(Vector3(1.8, 0.6, 0.08), Color("1e8a4e"), Vector3(level.GOAL_SIGN_X / TILE + 1.0, 1.25, 0.3))
	add_child(sign)
	for x in [0.3, 1.7]:
		add_child(Props.cylinder(0.04, 0.04, 1.0, Color("9aa0aa"), Vector3(level.GOAL_SIGN_X / TILE + x, 0.5, 0.3)))
	var sign_text := Props.label("LEVEL NEXT  →", Color.WHITE, 0.008)
	sign_text.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	sign_text.no_depth_test = false
	sign_text.position = Vector3(level.GOAL_SIGN_X / TILE + 1.0, 1.25, 0.36)
	add_child(sign_text)
	var warehouse := Props.warehouse(2.0)
	warehouse.position = Vector3(columns - 2.17, 0.08, last + 0.4)
	add_child(warehouse)
	add_child(Props.box(Vector3(3.1, 0.9, 0.1), Color("1b2422"), Vector3(1.7, 1.6, last + 0.3)))
	for x in [0.6, 2.8]:
		add_child(Props.cylinder(0.05, 0.05, 1.2, Color("8d8a84"), Vector3(x, 0.6, last + 0.3)))
	var board_text := Props.label("NGACIR EXPRESS\n%s :)" % tr("Dari Jalan Untuk Hidup"), level.LED_COLOR, 0.007)
	board_text.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	board_text.no_depth_test = false
	board_text.position = Vector3(1.7, 1.6, last + 0.37)
	add_child(board_text)

	var customer := Props.customer(Color("d19a66"), Color("ffb3c1"))
	customer.position = Vector3(level._customer.position.x / TILE + 0.5, 0.08, 0.6)
	customer.name = "Customer"
	add_child(customer)

	if level.pickup_cell.x >= 0:
		var stall := Props.stall()
		stall.position = Vector3(level.pickup_cell.x, SURFACE[(lanes[level.pickup_cell.y] as LaneData).kind], level.pickup_cell.y)
		add_child(stall)
		_pickup_marker = Node3D.new()
		var box := Props.box(Vector3(0.4, 0.3, 0.32), level.day.package.color, Vector3.ZERO)
		_pickup_marker.add_child(box)
		var text := Props.label(tr("AMBIL"), Color.WHITE, 0.01)
		text.outline_modulate = Palette.CORAL
		text.position = Vector3(0, 0.45, 0)
		_pickup_marker.add_child(text)
		_pickup_marker.position = Vector3(level.pickup_cell.x + 0.5, 2.0, level.pickup_cell.y + 0.5)
		add_child(_pickup_marker)


func _wire(a: Vector3, b: Vector3) -> void:
	var length := a.distance_to(b)
	if length < 0.1:
		return
	var wire := Props.cylinder(0.012, 0.012, length, Props.OUTLINE, (a + b) / 2.0 - Vector3(0, 0.15, 0), false)
	wire.look_at_from_position(wire.position, b - Vector3(0, 0.15, 0), Vector3.UP if absf((b - a).normalized().y) < 0.99 else Vector3.RIGHT)
	wire.rotate_object_local(Vector3.RIGHT, PI / 2.0)
	add_child(wire)


func _build_player() -> void:
	_player = Node3D.new()
	_pose = Props.masbro()
	_player.add_child(_pose)
	add_child(_player)
	var package := _pose.get_node("Package") as MeshInstance3D
	package.material_override = Props.material(level.day.package.color)


# ------------------------------------------------------------------ Sinkronisasi per frame

func _process(delta: float) -> void:
	_time += delta
	_sync_player(delta)
	_sync_vehicles()
	_sync_items()
	_sync_cats()
	_sync_labels()
	_sync_camera(delta)
	if _pickup_marker:
		_pickup_marker.visible = not level.has_package
		_pickup_marker.position.y = 2.0 + sin(_time * 3.0) * 0.12
		_pickup_marker.rotation.y = _time * 1.5
	var rain := get_node_or_null("Rain") as Node3D
	if rain:
		rain.position = _player.position + Vector3(0, 9, -3)


func _surface(row: int) -> float:
	var lanes: Array = level.day.lanes
	return SURFACE[(lanes[clampi(row, 0, lanes.size() - 1)] as LaneData).kind]


func _sync_player(delta: float) -> void:
	var p: Player = level._player
	var center := p.position + Vector2(TILE / 2.0, TILE / 2.0)
	var row := int(center.y / TILE)
	var ground := _surface(row)
	if (level.day.lanes[row] as LaneData).kind == LaneData.Kind.RIVER:
		ground = 0.06
	var hop := (TILE - p._visual.position.y) / TILE
	_player.position = Vector3(center.x / TILE, ground + hop * 1.2, center.y / TILE)
	# Menghadap arah langkah terakhir (-Z = maju ke rumah pelanggan).
	var yaw := 0.0
	match p.last_direction:
		Vector2i.DOWN:
			yaw = PI
		Vector2i.LEFT:
			yaw = PI / 2.0
		Vector2i.RIGHT:
			yaw = -PI / 2.0
	_yaw = lerp_angle(_yaw, yaw, 1.0 - exp(-14.0 * delta))
	_player.rotation.y = _yaw
	# Condong maju saat melompat, salto saat tertabrak (rotasi 2D jadi pitch).
	_pose.rotation.x = -absf(p._visual.rotation) if absf(p._visual.rotation) < 0.5 else -p._visual.rotation * p._facing
	_pose.scale = Vector3(p._visual.scale.x, p._visual.scale.y, p._visual.scale.x)
	_pose.visible = p.modulate.a > 0.5
	_pose.get_node("Package").visible = p.carrying
	_pose.get_node("Shield").visible = p.shielded
	_pose.get_node("Head/Shades").visible = GameState.equipped.has(Cosmetics.Slot.GLASSES)


func _sync_vehicles() -> void:
	# Kunci tanpa tipe: kendaraan yang sudah dihapus tidak boleh masuk variabel bertipe.
	for key in _vehicles.keys():
		if not is_instance_valid(key) or not (key as Node).is_inside_tree():
			_vehicles[key].queue_free()
			_vehicles.erase(key)
	for vehicle: Vehicle in level._vehicles:
		if not is_instance_valid(vehicle):
			continue
		var node: Node3D = _vehicles.get(vehicle)
		if node == null:
			node = _make_vehicle(vehicle)
			_vehicles[vehicle] = node
		var length := vehicle.length_px / TILE
		var row := vehicle.position.y / TILE
		if vehicle.direction > 0:
			node.position = Vector3(vehicle.position.x / TILE, 0.0, row)
		else:
			node.position = Vector3(vehicle.position.x / TILE + length, 0.0, row + 1.0)
		if vehicle.is_platform:
			node.position.y = 0.02 + sin(_time * 2.0 + row) * 0.03
		else:
			for wheel in node.find_children("Wheel", "", false, false):
				wheel.rotate_object_local(Vector3.UP, -vehicle.speed / TILE * get_process_delta_time() * 4.0)


func _make_vehicle(vehicle: Vehicle) -> Node3D:
	var length := vehicle.length_px / TILE
	var node: Node3D
	var sprite_name := ""
	if vehicle._sprite and vehicle._sprite.texture:
		sprite_name = vehicle._sprite.texture.resource_path.get_file().get_basename()
	var color: Color = Props.VEHICLE_COLORS.get(sprite_name, vehicle.color)
	if vehicle.is_platform:
		node = Props.raft(length, vehicle.type, color)
	else:
		node = Props.vehicle(vehicle.type, length, color)
		if vehicle.headlights:
			_add_headlight(node, length)
	if vehicle.direction < 0:
		node.rotation_degrees.y = 180.0
	add_child(node)
	return node


## Lampu menyala saat hujan: bola terang + kerucut cahaya tembus pandang.
func _add_headlight(node: Node3D, length: float) -> void:
	var lamp := node.get_node("Lamp") as MeshInstance3D
	lamp.material_override = Props.material(Color("fff6b0"), false, 4.0)
	var beam := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.05
	cone.bottom_radius = 0.45
	cone.height = 1.8
	beam.mesh = cone
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(1.0, 0.93, 0.6, 0.12)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	beam.material_override = mat
	beam.rotation_degrees.z = 90.0
	beam.position = Vector3(length + 0.9, 0.4, 0.5)
	node.add_child(beam)


func _sync_items() -> void:
	for cell: Vector2i in _items.keys():
		var node: Node3D = _items[cell]
		if level._collected.has(cell):
			node.queue_free()
			_items.erase(cell)
		else:
			node.rotation.y = _time * 2.5
			node.position.y = _surface(cell.y) + 0.45 + sin(_time * 3.0 + cell.x) * 0.06


func _sync_cats() -> void:
	for key in _cats.keys():
		if not is_instance_valid(key):
			_cats[key].queue_free()
			_cats.erase(key)
	for cat: StreetCat in level._cats:
		if not is_instance_valid(cat):
			continue
		var node: Node3D = _cats.get(cat)
		if node == null:
			node = Props.cat() if cat.kind == &"cat" else Props.pedestrian()
			add_child(node)
			_cats[cat] = node
		var center := cat.position + Vector2(TILE / 2.0, TILE / 2.0)
		node.position = Vector3(center.x / TILE, _surface(int(center.y / TILE)), center.y / TILE)
		node.rotation.y = 0.0 if cat.direction > 0 else PI
		if cat.kind != &"cat":
			node.rotation.y += -PI / 2.0


# ------------------------------------------------------------------ Teks, balon, dan partikel dari Level

func _on_node_added(node: Node) -> void:
	if not is_instance_valid(level) or not level._board.is_ancestor_of(node):
		return
	if node is SpeechBubble:
		var label := Props.label("", Props.OUTLINE, 0.009, 40)
		label.outline_modulate = Color.WHITE
		label.outline_size = 22
		add_child(label)
		_bubbles[node] = label
	elif node is Label:
		var label := Props.label("", Color.WHITE, 0.012)
		add_child(label)
		_labels[node] = {"label": label, "start": Vector2.INF}
	elif node is CPUParticles2D:
		_mirror_particles.call_deferred(node)


func _board_point(item: CanvasItem) -> Vector2:
	var board: Node2D = level._board
	var point := (board.get_global_transform().affine_inverse() * item.get_global_transform()).origin
	if item is Control:
		point += (item as Control).size / 2.0
	return point


func _sync_labels() -> void:
	for key in _labels.keys():
		var entry: Dictionary = _labels[key]
		var label: Label3D = entry["label"]
		if not is_instance_valid(key):
			label.queue_free()
			_labels.erase(key)
			continue
		var source := key as Label
		var point := _board_point(source)
		if entry["start"] == Vector2.INF:
			entry["start"] = point
		var start: Vector2 = entry["start"]
		label.text = source.text
		label.modulate = source.get_theme_color(&"font_color")
		var alpha := 1.0
		var node: CanvasItem = source
		while node and node != level._board:
			alpha *= node.modulate.a
			node = node.get_parent() as CanvasItem
		label.modulate.a = alpha
		label.position = Vector3(start.x / TILE, 1.7 + (start.y - point.y) / TILE, start.y / TILE)
	for key in _bubbles.keys():
		var label: Label3D = _bubbles[key]
		if not is_instance_valid(key):
			label.queue_free()
			_bubbles.erase(key)
			continue
		var bubble := key as SpeechBubble
		label.visible = bubble.visible and not bubble.text.is_empty()
		label.text = bubble.text
		var point := _board_point(bubble)
		label.position = Vector3(point.x / TILE, 2.3, point.y / TILE + 0.3)


## Partikel 2D (debu, letupan, cipratan, asap) dicerminkan sebagai semburan 3D di titik yang sama.
func _mirror_particles(source: CPUParticles2D) -> void:
	if not is_instance_valid(source):
		return
	var point := _board_point(source)
	var particles := CPUParticles3D.new()
	particles.one_shot = true
	particles.explosiveness = source.explosiveness
	particles.amount = source.amount
	particles.lifetime = source.lifetime
	var dir := source.direction
	particles.direction = Vector3(dir.x, -dir.y, 0.0)
	particles.spread = source.spread
	particles.initial_velocity_min = source.initial_velocity_min / TILE * 1.5
	particles.initial_velocity_max = source.initial_velocity_max / TILE * 1.5
	particles.gravity = Vector3(source.gravity.x, -source.gravity.y, 0.0) / TILE * 1.5
	var dot := SphereMesh.new()
	dot.radius = 0.06
	dot.height = 0.12
	dot.radial_segments = 6
	dot.rings = 3
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dot.material = mat
	particles.mesh = dot
	particles.scale_amount_min = source.scale_amount_min
	particles.scale_amount_max = source.scale_amount_max
	particles.color = source.color
	particles.color_ramp = source.color_ramp
	particles.position = Vector3(point.x / TILE, 0.5, point.y / TILE)
	add_child(particles)
	particles.emitting = true
	particles.finished.connect(particles.queue_free)


# ------------------------------------------------------------------ Kamera

func _camera_target() -> Transform3D:
	var focus := _player.position
	var rows: int = level.day.lanes.size()
	var focus_z := clampf(focus.z - CAMERA_LOOK_AHEAD, 3.0, rows - 3.0)
	var shake: Vector2 = level._shake_offset
	var x: float = lerpf(level.COLUMNS / 2.0, focus.x, 0.55) + shake.x / TILE
	var eye := Vector3(x + CAMERA_SIDE, CAMERA_HEIGHT, focus_z + CAMERA_BACK + shake.y / TILE)
	return Transform3D(Basis(), eye).looking_at(Vector3(x, 0.0, focus_z), Vector3.UP)


func _snap_camera() -> void:
	_camera.global_transform = _camera_target()


func _sync_camera(delta: float) -> void:
	var target := _camera_target()
	var weight := 1.0 - exp(-CAMERA_SMOOTHING * delta)
	_camera.global_transform = _camera.global_transform.interpolate_with(target, weight)

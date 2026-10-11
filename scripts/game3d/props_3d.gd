extends RefCounted
## Model 3D sederhana dari bentuk dasar (kapsul, bola, kotak, silinder) untuk Tampilan 3D (beta).
## Gaya: toon + garis luar gelap supaya tetap kawaii. Satuan: 1 petak = 1 meter.
## Tim 3D bisa mengganti fungsi di sini dengan model .glb tanpa mengubah logika game.
## Skrip ini hanya dimuat bila build punya modul 3D, jadi tanpa class_name.

const OUTLINE_SHADER := """
shader_type spatial;
render_mode unshaded, cull_front;

uniform float grow = 0.035;
uniform vec4 color : source_color = vec4(0.24, 0.17, 0.18, 1.0);

void vertex() {
	VERTEX += NORMAL * grow;
}

void fragment() {
	ALBEDO = color.rgb;
}
"""

const FUR := Color("d19a66")
const FUR_DARK := Color("a8723f")
const CAP := Color("ffd166")
const TEAL := Color("2ec4b6")
const BAG := Color("34364a")
const OUTLINE := Color("3d2c2e")

static var _materials := {}
static var _outline: ShaderMaterial


## Bahan toon berwarna; outline = tambah garis luar (dipakai untuk benda, bukan tanah).
static func material(color: Color, outline := true, emission := 0.0) -> StandardMaterial3D:
	var key := "%s|%s|%s" % [color.to_html(), outline, emission]
	if not _materials.has(key):
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = 0.85
		mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
		mat.specular_mode = BaseMaterial3D.SPECULAR_TOON
		mat.rim_enabled = true
		mat.rim = 0.2
		mat.rim_tint = 0.7
		if color.a < 1.0:
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		if emission > 0.0:
			mat.emission_enabled = true
			mat.emission = color
			mat.emission_energy_multiplier = emission
		if outline:
			mat.next_pass = _outline_material()
		_materials[key] = mat
	return _materials[key]


static func _outline_material() -> ShaderMaterial:
	if _outline == null:
		_outline = ShaderMaterial.new()
		_outline.shader = Shader.new()
		_outline.shader.code = OUTLINE_SHADER
	return _outline


static func box(size: Vector3, color: Color, at := Vector3.ZERO, outline := true) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _instance(mesh, color, at, outline)


static func sphere(radius: float, color: Color, at := Vector3.ZERO, outline := true) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 16
	mesh.rings = 8
	return _instance(mesh, color, at, outline)


static func cylinder(top: float, bottom: float, height: float, color: Color, at := Vector3.ZERO, outline := true) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = top
	mesh.bottom_radius = bottom
	mesh.height = height
	mesh.radial_segments = 14
	return _instance(mesh, color, at, outline)


static func capsule(radius: float, height: float, color: Color, at := Vector3.ZERO, outline := true) -> MeshInstance3D:
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 16
	mesh.rings = 6
	return _instance(mesh, color, at, outline)


static func prism(size: Vector3, color: Color, at := Vector3.ZERO) -> MeshInstance3D:
	var mesh := PrismMesh.new()
	mesh.size = size
	return _instance(mesh, color, at, true)


static func label(text: String, color: Color, pixel_size := 0.012, font_size := 48) -> Label3D:
	var node := Label3D.new()
	node.text = text
	node.font = UiTheme.font(700)
	node.font_size = font_size
	node.pixel_size = pixel_size
	node.modulate = color
	node.outline_modulate = OUTLINE
	node.outline_size = 12
	node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	node.no_depth_test = true
	node.render_priority = 10
	node.outline_render_priority = 9
	return node


static func _instance(mesh: Mesh, color: Color, at: Vector3, outline: bool) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = material(color, outline)
	node.position = at
	return node


# ------------------------------------------------------------------ Karakter

## Capybara gaya kawaii (menghadap -Z). Bagian yang bisa diubah diberi nama.
static func capybara(fur: Color, fur_dark: Color, outfit := Color.TRANSPARENT) -> Node3D:
	var root := Node3D.new()
	var body := capsule(0.3, 0.95, fur, Vector3(0, 0.42, 0.05))
	body.rotation_degrees.x = 90.0
	root.add_child(body)
	if outfit.a > 0.0:
		var shirt := capsule(0.31, 0.5, outfit, Vector3(0, 0.42, -0.08))
		shirt.rotation_degrees.x = 90.0
		root.add_child(shirt)
	for x in [-0.17, 0.17]:
		for z in [-0.25, 0.3]:
			root.add_child(cylinder(0.07, 0.07, 0.24, fur_dark, Vector3(x, 0.12, z)))
	var head := Node3D.new()
	head.name = "Head"
	head.position = Vector3(0, 0.66, -0.42)
	root.add_child(head)
	var skull := sphere(0.25, fur)
	skull.scale = Vector3(1.0, 0.95, 1.15)
	head.add_child(skull)
	var snout := sphere(0.15, fur_dark, Vector3(0, -0.07, -0.22))
	snout.scale = Vector3(1.15, 0.85, 0.9)
	head.add_child(snout)
	for x in [-0.12, 0.12]:
		head.add_child(sphere(0.045, OUTLINE, Vector3(x, 0.06, -0.24), false))
		head.add_child(sphere(0.016, Color.WHITE, Vector3(x + 0.015, 0.085, -0.28), false))
		head.add_child(sphere(0.07, fur_dark, Vector3(x * 1.4, 0.2, 0.05)))
		head.add_child(sphere(0.05, Color("ff8fa3"), Vector3(x * 1.55, -0.03, -0.17), false))
	return root


## Masbro: capybara kurir dengan topi kuning, ransel hitam bergaris teal.
static func masbro() -> Node3D:
	var root := capybara(FUR, FUR_DARK)
	root.name = "Masbro"
	var head := root.get_node("Head")
	var cap := sphere(0.26, CAP, Vector3(0, 0.1, 0.02))
	cap.scale = Vector3(1.02, 0.62, 1.08)
	head.add_child(cap)
	head.add_child(box(Vector3(0.36, 0.04, 0.2), Color("f4a93b"), Vector3(0, 0.1, -0.3)))
	head.add_child(sphere(0.06, TEAL, Vector3(0, 0.22, -0.18)))
	var shades := Node3D.new()
	shades.name = "Shades"
	shades.add_child(box(Vector3(0.42, 0.09, 0.04), Color("111111"), Vector3(0, 0.07, -0.29), false))
	shades.add_child(box(Vector3(0.05, 0.03, 0.045), Color.WHITE, Vector3(-0.15, 0.09, -0.31), false))
	shades.add_child(box(Vector3(0.05, 0.03, 0.045), Color.WHITE, Vector3(0.07, 0.09, -0.31), false))
	head.add_child(shades)
	var bag := box(Vector3(0.42, 0.36, 0.34), BAG, Vector3(0, 0.78, 0.22))
	bag.name = "Bag"
	root.add_child(bag)
	root.add_child(box(Vector3(0.44, 0.07, 0.36), TEAL, Vector3(0, 0.8, 0.22), false))
	var package := box(Vector3(0.36, 0.26, 0.3), Color("efe6cf"), Vector3(0, 1.1, 0.22))
	package.name = "Package"
	root.add_child(package)
	var shield := sphere(0.62, Color(TEAL, 0.22), Vector3(0, 0.55, 0), false)
	shield.name = "Shield"
	root.add_child(shield)
	return root


static func customer(fur: Color, outfit: Color) -> Node3D:
	var root := capybara(fur, fur.darkened(0.2), outfit)
	# Berdiri menghadap jalan (ke arah kamera).
	root.rotation_degrees.y = 180.0
	return root


static func cat() -> Node3D:
	var root := Node3D.new()
	var body := capsule(0.16, 0.55, Color("ffaa5c"), Vector3(0, 0.22, 0))
	body.rotation_degrees.z = 90.0
	root.add_child(body)
	var head := sphere(0.15, Color("ffaa5c"), Vector3(0.3, 0.36, 0))
	root.add_child(head)
	for z in [-0.08, 0.08]:
		root.add_child(prism(Vector3(0.08, 0.1, 0.06), Color("e07b24"), Vector3(0.3, 0.52, z)))
	var tail := cylinder(0.03, 0.03, 0.35, Color("e07b24"), Vector3(-0.32, 0.38, 0))
	tail.rotation_degrees.z = -30.0
	root.add_child(tail)
	return root


static func pedestrian() -> Node3D:
	var root := capybara(Color("e2b07e"), Color("b9834f"), Color("ffd6e0"))
	root.scale = Vector3.ONE * 0.85
	return root


# ------------------------------------------------------------------ Kendaraan

## Warna kendaraan mengikuti varian sprite 2D supaya kedua tampilan sama.
const VEHICLE_COLORS := {
	"vehicle_mobil": Color("2ec4b6"), "vehicle_mobil_2": Color("b39dff"), "vehicle_mobil_3": Color("ffd166"),
	"vehicle_motor": Color("ff6b6b"), "vehicle_motor_2": Color("2ec4b6"), "vehicle_truk": Color("ff9f1c"),
	"vehicle_kilat": Color("06d6a0"),
	"vehicle_bajaj": Color("ff9f1c"), "vehicle_bajaj_2": Color("3d9970"),
	"vehicle_angkot": Color("3bb273"), "vehicle_angkot_2": Color("4f8fe0"),
	"vehicle_bus": Color("ff6b6b"), "vehicle_bus_2": Color("b39dff"),
	"vehicle_perahu2": Color("2ec4b6"), "vehicle_perahu2_2": Color("ff6b6b"),
	"vehicle_perahu3": Color("4f8fe0"), "vehicle_perahu3_2": Color("ffd166"),
}


## Kendaraan menghadap +X, panjang length (meter), titik asal di sisi belakang kiri jalur.
static func vehicle(type: StringName, length: float, color: Color) -> Node3D:
	var root := Node3D.new()
	var wheels: Array[Node3D] = []
	match type:
		&"truk":
			var cargo_length := length * 0.68
			root.add_child(box(Vector3(cargo_length, 0.78, 0.82), Color("fff4dc"), Vector3(cargo_length / 2.0 + 0.05, 0.62, 0.5)))
			root.add_child(box(Vector3(cargo_length + 0.02, 0.16, 0.84), color, Vector3(cargo_length / 2.0 + 0.05, 0.6, 0.5), false))
			var cab_x := cargo_length + 0.12 + (length - cargo_length - 0.2) / 2.0
			root.add_child(box(Vector3(length - cargo_length - 0.2, 0.7, 0.8), color, Vector3(cab_x, 0.55, 0.5)))
			root.add_child(box(Vector3(0.1, 0.3, 0.7), Color("a8e3fa"), Vector3(length - 0.12, 0.72, 0.5), false))
			for x in [0.5, 1.6, length - 0.45]:
				wheels.append(_wheel(Vector3(x, 0.2, 0.5)))
		&"bus", &"angkot":
			# Badan tinggi sepanjang kendaraan dengan deretan jendela.
			var height := 0.95 if type == &"bus" else 0.75
			root.add_child(box(Vector3(length - 0.1, height, 0.84), color, Vector3(length / 2.0, 0.22 + height / 2.0, 0.5)))
			root.add_child(box(Vector3(length - 0.3, 0.24, 0.86), Color("a8e3fa"), Vector3(length / 2.0, 0.22 + height * 0.72, 0.5), false))
			root.add_child(box(Vector3(length - 0.08, 0.08, 0.86), Color.WHITE, Vector3(length / 2.0, 0.22 + height * 0.38, 0.5), false))
			for x in ([0.55, 1.1, length - 0.6] if type == &"bus" else [0.45, length - 0.45]):
				wheels.append(_wheel(Vector3(x, 0.2, 0.5)))
		&"bajaj":
			root.add_child(box(Vector3(0.82, 0.62, 0.72), color, Vector3(0.48, 0.55, 0.5)))
			root.add_child(box(Vector3(0.3, 0.26, 0.6), Color("a8e3fa"), Vector3(0.74, 0.72, 0.5), false))
			wheels.append(_wheel(Vector3(0.2, 0.17, 0.5), 0.16))
			wheels.append(_wheel(Vector3(0.8, 0.17, 0.5), 0.16))
		&"motor", &"kilat":
			root.add_child(box(Vector3(0.75, 0.3, 0.3), color, Vector3(0.5, 0.38, 0.5)))
			wheels.append(_wheel(Vector3(0.2, 0.18, 0.5), 0.17))
			wheels.append(_wheel(Vector3(0.8, 0.18, 0.5), 0.17))
			var rider := capsule(0.15, 0.5, Color("ff9f1c") if type == &"motor" else Color("2b2d42"), Vector3(0.45, 0.75, 0.5))
			root.add_child(rider)
			root.add_child(sphere(0.15, CAP if type == &"motor" else Color("06d6a0"), Vector3(0.48, 1.08, 0.5)))
		_:
			root.add_child(box(Vector3(length * 0.94, 0.42, 0.8), color, Vector3(length / 2.0, 0.4, 0.5)))
			root.add_child(box(Vector3(length * 0.5, 0.34, 0.68), color.lightened(0.1), Vector3(length * 0.55, 0.78, 0.5)))
			root.add_child(box(Vector3(length * 0.46, 0.24, 0.7), Color("a8e3fa"), Vector3(length * 0.55, 0.8, 0.5), false))
			wheels.append(_wheel(Vector3(length * 0.22, 0.2, 0.5)))
			wheels.append(_wheel(Vector3(length * 0.78, 0.2, 0.5)))
	for wheel in wheels:
		root.add_child(wheel)
	# Lampu depan (menyala terang saat hujan, diatur Level3DView).
	var lamp := sphere(0.07, Color("fff6b0"), Vector3(length - 0.04, 0.42, 0.5), false)
	lamp.name = "Lamp"
	root.add_child(lamp)
	return root


static func _wheel(at: Vector3, radius := 0.2) -> Node3D:
	var wheel := cylinder(radius, radius, 0.86, OUTLINE, at, false)
	wheel.rotation_degrees.x = 90.0
	wheel.name = "Wheel"
	return wheel


## Rakit: satu panel geladak per petak, dipisah ikatan tali, supaya panjangnya mudah dihitung.
## Perahu: lambung berwarna dengan satu bangku per petak.
static func raft(length: float, type := &"rakit", color := Color("c98b52")) -> Node3D:
	var root := Node3D.new()
	var tiles := roundi(length)
	if String(type).begins_with("perahu"):
		root.add_child(box(Vector3(length - 0.06, 0.3, 0.86), color, Vector3(length / 2.0, -0.02, 0.5)))
		root.add_child(box(Vector3(length - 0.04, 0.06, 0.9), Color("c98b52"), Vector3(length / 2.0, 0.14, 0.5)))
		for i in tiles:
			root.add_child(box(Vector3(0.6, 0.05, 0.7), Color("e7b58a"), Vector3(i + 0.5, 0.2, 0.5), false))
		for i in range(1, tiles):
			root.add_child(box(Vector3(0.05, 0.08, 0.92), OUTLINE, Vector3(i, 0.17, 0.5), false))
		return root
	root.add_child(box(Vector3(length - 0.06, 0.12, 0.84), Color("8e5a2b"), Vector3(length / 2.0, 0.0, 0.5)))
	for i in tiles:
		root.add_child(box(Vector3(0.84, 0.08, 0.72), Color("c98b52"), Vector3(i + 0.5, 0.09, 0.5)))
	for i in range(1, tiles):
		root.add_child(box(Vector3(0.1, 0.14, 0.86), Color("f3ddae"), Vector3(i, 0.09, 0.5)))
	return root


# ------------------------------------------------------------------ Benda di jalan

static func obstacle(kind: StringName) -> Node3D:
	var root := Node3D.new()
	match kind:
		&"cone":
			root.add_child(cylinder(0.02, 0.2, 0.55, Color("ff9f1c"), Vector3(0.5, 0.3, 0.5)))
			root.add_child(cylinder(0.11, 0.14, 0.08, Color.WHITE, Vector3(0.5, 0.32, 0.5), false))
			root.add_child(box(Vector3(0.5, 0.06, 0.5), Color("ff9f1c"), Vector3(0.5, 0.03, 0.5)))
		&"barrier":
			root.add_child(box(Vector3(0.85, 0.28, 0.12), Color("ff6b6b"), Vector3(0.5, 0.45, 0.5)))
			root.add_child(box(Vector3(0.3, 0.29, 0.13), Color.WHITE, Vector3(0.5, 0.45, 0.5), false))
			for x in [0.15, 0.85]:
				root.add_child(cylinder(0.04, 0.04, 0.45, Color("9aa0aa"), Vector3(x, 0.22, 0.5)))
		&"hole":
			root.add_child(cylinder(0.36, 0.36, 0.02, Color("1d1a24"), Vector3(0.5, 0.11, 0.5), false))
			root.add_child(cylinder(0.4, 0.4, 0.015, Color("6b5a4e"), Vector3(0.5, 0.105, 0.5), false))
		&"gerobak":
			root.add_child(box(Vector3(0.8, 0.45, 0.55), Color("e8b77a"), Vector3(0.5, 0.45, 0.5)))
			for x in [0.25, 0.75]:
				root.add_child(_wheel(Vector3(x, 0.17, 0.5), 0.15))
			root.add_child(cylinder(0.02, 0.02, 0.7, Color("9aa0aa"), Vector3(0.5, 0.95, 0.5), false))
			root.add_child(cylinder(0.02, 0.5, 0.2, Color("ff6b6b"), Vector3(0.5, 1.3, 0.5)))
		_:
			root.add_child(box(Vector3(0.6, 0.4, 0.6), Color("ff9f1c"), Vector3(0.5, 0.3, 0.5)))
	return root


static func item(kind: StringName) -> Node3D:
	var root := Node3D.new()
	match kind:
		&"coin":
			var coin := cylinder(0.24, 0.24, 0.06, CAP, Vector3(0, 0, 0))
			coin.rotation_degrees.x = 90.0
			root.add_child(coin)
			var inner := cylinder(0.15, 0.15, 0.065, Color("f4a93b"), Vector3.ZERO, false)
			inner.rotation_degrees.x = 90.0
			root.add_child(inner)
		&"helmet":
			var dome := sphere(0.25, TEAL)
			dome.scale = Vector3(1, 0.7, 1)
			root.add_child(dome)
			root.add_child(box(Vector3(0.5, 0.05, 0.12), Color("1f9e92"), Vector3(0, -0.05, -0.24)))
		_:
			root.add_child(box(Vector3(0.22, 0.18, 0.4), Color("ff6b6b"), Vector3(-0.13, 0, 0)))
			root.add_child(box(Vector3(0.22, 0.18, 0.4), Color("ff6b6b"), Vector3(0.13, 0, 0)))
			root.add_child(box(Vector3(0.24, 0.05, 0.42), Color.WHITE, Vector3(-0.13, -0.1, 0), false))
			root.add_child(box(Vector3(0.24, 0.05, 0.42), Color.WHITE, Vector3(0.13, -0.1, 0), false))
	return root


static func flag(color: Color) -> Node3D:
	var root := Node3D.new()
	root.add_child(cylinder(0.04, 0.04, 1.4, Color("9aa0aa"), Vector3(0, 0.7, 0)))
	root.add_child(box(Vector3(0.5, 0.32, 0.04), color, Vector3(0.27, 1.22, 0)))
	return root


static func pole() -> Node3D:
	var root := Node3D.new()
	root.add_child(cylinder(0.07, 0.09, 3.2, Color("8d8a84"), Vector3(0, 1.6, 0)))
	root.add_child(box(Vector3(0.9, 0.1, 0.1), Color("6f6a62"), Vector3(0, 3.0, 0)))
	for x in [-0.38, 0.38]:
		root.add_child(cylinder(0.04, 0.04, 0.14, Color("e9f1f7"), Vector3(x, 3.12, 0), false))
	return root


static func tree(size := 1.0) -> Node3D:
	var root := Node3D.new()
	root.add_child(cylinder(0.1 * size, 0.14 * size, 0.9 * size, Color("8e5a2b"), Vector3(0, 0.45 * size, 0)))
	root.add_child(sphere(0.55 * size, Color("5fae55"), Vector3(0, 1.2 * size, 0)))
	root.add_child(sphere(0.38 * size, Color("8bd17c"), Vector3(0.25 * size, 1.5 * size, -0.1 * size)))
	return root


static func house(width: float) -> Node3D:
	var root := Node3D.new()
	root.add_child(box(Vector3(width, 1.2, 1.2), Color("fff4dc"), Vector3(width / 2.0, 0.6, 0.0)))
	var roof := prism(Vector3(width + 0.3, 0.8, 1.5), Color("ff6b6b"), Vector3(width / 2.0, 1.6, 0.0))
	root.add_child(roof)
	root.add_child(box(Vector3(0.45, 0.75, 0.05), Color("c97b4a"), Vector3(width / 2.0, 0.38, 0.61)))
	for x in [0.35, width - 0.35]:
		root.add_child(box(Vector3(0.4, 0.35, 0.05), Color("a8e3fa"), Vector3(x, 0.75, 0.61), false))
	return root


static func warehouse(width: float) -> Node3D:
	var root := Node3D.new()
	root.add_child(box(Vector3(width, 1.4, 1.4), TEAL, Vector3(width / 2.0, 0.7, 0.0)))
	root.add_child(box(Vector3(width + 0.2, 0.2, 1.6), Color("1f9e92"), Vector3(width / 2.0, 1.5, 0.0)))
	root.add_child(box(Vector3(width * 0.4, 1.0, 0.05), Color("eaf6f5"), Vector3(width / 2.0, 0.5, 0.71), false))
	return root


## Kios pengirim: meja, penjual, tenda bergaris.
static func stall() -> Node3D:
	var root := Node3D.new()
	var seller := capybara(Color("c99a6e"), Color("9e7046"), CAP)
	seller.rotation_degrees.y = 180.0
	# Kios ramping di sisi belakang petak, supaya Masbro yang mengambil paket tetap terlihat di depannya.
	seller.position = Vector3(0.5, 0.0, -0.1)
	seller.scale = Vector3.ONE * 0.6
	root.add_child(seller)
	root.add_child(box(Vector3(0.95, 0.4, 0.26), Color("c98b52"), Vector3(0.5, 0.2, 0.2)))
	for x in [0.06, 0.94]:
		root.add_child(cylinder(0.03, 0.03, 1.7, Color("9aa0aa"), Vector3(x, 0.85, 0.06)))
	for i in 5:
		root.add_child(box(Vector3(0.2, 0.06, 0.5), TEAL if i % 2 == 0 else Color.WHITE, Vector3(0.1 + i * 0.2, 1.72, 0.12)))
	return root

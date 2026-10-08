class_name RainOverlay
extends Node2D
## Efek hujan: rintik hujan dan gelap di luar jarak pandang Masbro.

const SHADER_CODE := """
shader_type canvas_item;

uniform vec2 rect_size;
uniform vec2 center;
uniform float radius;
uniform float softness = 60.0;
uniform vec4 shade : source_color = vec4(0.03, 0.05, 0.12, 0.88);

void fragment() {
	float dist = distance(UV * rect_size, center);
	float darkness = smoothstep(radius - softness, radius, dist);
	COLOR = vec4(shade.rgb, shade.a * darkness);
}
"""
const DROP_COUNT := 140

var area := Vector2(720, 624)
var visibility_radius := 216.0
## Node yang diikuti titik terangnya (Masbro).
var target: Node2D

var _darkness: ColorRect
var _material: ShaderMaterial
var _drops: Array[Vector3] = []


func _ready() -> void:
	var shader := Shader.new()
	shader.code = SHADER_CODE
	_material = ShaderMaterial.new()
	_material.shader = shader
	_material.set_shader_parameter("rect_size", area)
	_material.set_shader_parameter("radius", visibility_radius)
	_darkness = ColorRect.new()
	_darkness.size = area
	_darkness.material = _material
	_darkness.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Lapisan gelap di belakang, rintik hujan (_draw) di depannya.
	_darkness.show_behind_parent = true
	add_child(_darkness)
	for i in DROP_COUNT:
		_drops.append(Vector3(randf() * area.x, randf() * area.y, randf_range(420.0, 640.0)))
	_follow_target()


## Ubah ukuran area hujan (saat layar berubah ukuran).
func resize(new_area: Vector2) -> void:
	area = new_area
	if _darkness:
		_darkness.size = area
		_material.set_shader_parameter("rect_size", area)


func _process(delta: float) -> void:
	for i in _drops.size():
		var drop := _drops[i]
		drop.y += drop.z * delta
		drop.x -= drop.z * 0.15 * delta
		if drop.y > area.y:
			drop = Vector3(randf() * (area.x + 100.0), -10.0, drop.z)
		_drops[i] = drop
	_follow_target()
	queue_redraw()


func _follow_target() -> void:
	if target and _material:
		# Overlay ikut kamera, jadi posisi Masbro dihitung relatif terhadap overlay.
		_material.set_shader_parameter("center", target.position + Vector2(24, 24) - position)


func _draw() -> void:
	var color := Color(0.75, 0.85, 1.0, 0.35)
	for drop in _drops:
		draw_line(Vector2(drop.x, drop.y), Vector2(drop.x + 3.0, drop.y - 12.0), color, 1.0)

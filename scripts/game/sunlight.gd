class_name Sunlight
extends CanvasLayer
## Filter cahaya dan warna ala poster di atas papan permainan (di bawah HUD): warna hangat,
## kontras, sinar matahari dari pojok kanan atas, dan sudut layar sedikit gelap.
## Hari hujan memakai warna lebih dingin tanpa matahari. Bisa dimatikan di Pengaturan.

const SHADER_CODE := """
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float warmth = 0.07;
uniform float contrast = 1.08;
uniform float saturation = 1.15;
uniform float vignette = 0.38;
uniform vec2 sun_pos = vec2(0.92, 0.02);
uniform vec3 sun_color : source_color = vec3(1.0, 0.86, 0.55);
uniform float sun_strength = 0.5;
uniform float ray_speed = 0.25;

void fragment() {
	vec3 c = texture(screen_texture, SCREEN_UV).rgb;
	float luma = dot(c, vec3(0.299, 0.587, 0.114));
	c = mix(vec3(luma), c, saturation);
	c = (c - 0.5) * contrast + 0.5;
	c += vec3(warmth, warmth * 0.35, -warmth * 0.7) * luma;

	// Sinar matahari: cahaya lembut dengan berkas yang bergeser pelan.
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 p = SCREEN_UV - sun_pos;
	p.x *= aspect;
	float glow = exp(-dot(p, p) * 1.6) * sun_strength;
	float angle = atan(p.y, p.x);
	glow *= 0.65 + 0.35 * sin(angle * 14.0 + TIME * ray_speed) * sin(angle * 9.0 - TIME * ray_speed * 0.7);
	c = 1.0 - (1.0 - c) * (1.0 - sun_color * glow);

	vec2 v = (SCREEN_UV - 0.5) * vec2(aspect, 1.0) / max(aspect, 1.0);
	c *= 1.0 - vignette * smoothstep(0.35, 0.95, length(v) * 1.25);
	COLOR = vec4(clamp(c, 0.0, 1.0), 1.0);
}
"""

## Hari hujan: dingin dan redup, tanpa sinar matahari.
var rainy := false

var _material: ShaderMaterial


func _ready() -> void:
	# Di atas papan permainan, di bawah kontrol sentuh (5) dan HUD (10).
	layer = 1
	_material = ShaderMaterial.new()
	_material.shader = Shader.new()
	_material.shader.code = SHADER_CODE
	var rect := ColorRect.new()
	rect.material = _material
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(rect)
	if rainy:
		_material.set_shader_parameter("warmth", -0.03)
		_material.set_shader_parameter("saturation", 0.95)
		_material.set_shader_parameter("sun_strength", 0.0)
		_material.set_shader_parameter("vignette", 0.4)
	if Accessibility.reduce_motion:
		_material.set_shader_parameter("ray_speed", 0.0)
	visible = Accessibility.lighting
	Accessibility.lighting_changed.connect(_on_lighting_changed)


## Nilai parameter shader yang berlaku (nilai bawaan shader bila belum diubah).
func shader_parameter(parameter: StringName) -> Variant:
	var value: Variant = _material.get_shader_parameter(parameter)
	if value == null:
		value = RenderingServer.shader_get_parameter_default(_material.shader.get_rid(), parameter)
	return value


func _on_lighting_changed(enabled: bool) -> void:
	visible = enabled

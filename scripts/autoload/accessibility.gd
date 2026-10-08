extends CanvasLayer
## Opsi aksesibilitas: ukuran teks, filter buta warna, dan kurangi efek gerak.
## Disimpan di user://settings.cfg bagian [accessibility].

enum ColorMode { OFF, PROTANOPIA, DEUTERANOPIA, TRITANOPIA }

const TEXT_SCALES := [1.0, 1.15, 1.3]
const TEXT_SCALE_NAMES := ["Normal", "Besar", "Sangat Besar"]
const COLOR_MODE_NAMES := ["Mati", "Protanopia (merah)", "Deuteranopia (hijau)", "Tritanopia (biru)"]
const BASE_SIZE_META := &"a11y_base_font_size"
## Pasang meta ini pada teks dekoratif (logo) yang ukurannya diatur sendiri.
const FIXED_SIZE_META := &"a11y_fixed"

## Koreksi warna (daltonization): warna yang sulit dibedakan digeser ke kanal yang masih terlihat.
const SHADER_CODE := """
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform int mode = 0;

void fragment() {
	vec3 c = texture(screen_texture, SCREEN_UV).rgb;
	float L = 17.8824 * c.r + 43.5161 * c.g + 4.11935 * c.b;
	float M = 3.45565 * c.r + 27.1554 * c.g + 3.86714 * c.b;
	float S = 0.0299566 * c.r + 0.184309 * c.g + 1.46709 * c.b;
	float l = L;
	float m = M;
	float s = S;
	if (mode == 1) {
		l = 2.02344 * M - 2.52581 * S;
	} else if (mode == 2) {
		m = 0.494207 * L + 1.24827 * S;
	} else {
		s = -0.395913 * L + 0.801109 * M;
	}
	vec3 seen = vec3(
		0.0809444479 * l - 0.130504409 * m + 0.116721066 * s,
		-0.0102485335 * l + 0.0540193266 * m - 0.113614708 * s,
		-0.000365296938 * l - 0.00412161469 * m + 0.693511405 * s);
	vec3 lost = c - seen;
	vec3 shift = vec3(0.0, 0.7 * lost.r + lost.g, 0.7 * lost.r + lost.b);
	COLOR = vec4(clamp(c + shift, 0.0, 1.0), 1.0);
}
"""

## Indeks TEXT_SCALES.
var text_size := 0
var color_mode := ColorMode.OFF
## Matikan goyangan layar, konfeti, animasi pop, dan transisi lingkaran.
var reduce_motion := false

var _filter: ColorRect


func _ready() -> void:
	# Di atas semua layar, termasuk transisi.
	layer = 120
	process_mode = Node.PROCESS_MODE_ALWAYS
	var material := ShaderMaterial.new()
	material.shader = Shader.new()
	material.shader.code = SHADER_CODE
	_filter = ColorRect.new()
	_filter.material = material
	_filter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_filter.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_filter)
	_load()
	_apply_color_mode()
	get_tree().node_added.connect(_on_node_added)


func text_scale() -> float:
	return TEXT_SCALES[clampi(text_size, 0, TEXT_SCALES.size() - 1)]


func set_text_size(index: int) -> void:
	text_size = clampi(index, 0, TEXT_SCALES.size() - 1)
	for node in get_tree().root.find_children("*", "Control", true, false):
		_scale_text(node)
	save()


func set_color_mode(mode: int) -> void:
	color_mode = mode as ColorMode
	_apply_color_mode()
	save()


func set_reduce_motion(value: bool) -> void:
	reduce_motion = value
	save()


func save() -> void:
	var config := ConfigFile.new()
	config.load(AudioManager.SETTINGS_PATH)
	config.set_value("accessibility", "text_size", text_size)
	config.set_value("accessibility", "color_mode", color_mode)
	config.set_value("accessibility", "reduce_motion", reduce_motion)
	config.save(AudioManager.SETTINGS_PATH)


func _load() -> void:
	var config := ConfigFile.new()
	config.load(AudioManager.SETTINGS_PATH)
	text_size = clampi(config.get_value("accessibility", "text_size", 0), 0, TEXT_SCALES.size() - 1)
	color_mode = clampi(config.get_value("accessibility", "color_mode", 0), 0, ColorMode.size() - 1) as ColorMode
	reduce_motion = config.get_value("accessibility", "reduce_motion", false)


func _apply_color_mode() -> void:
	_filter.visible = color_mode != ColorMode.OFF
	(_filter.material as ShaderMaterial).set_shader_parameter("mode", int(color_mode))


func _on_node_added(node: Node) -> void:
	if node is Label or node is Button or node is RichTextLabel:
		# Tunggu sampai pemanggil selesai mengatur ukuran font-nya sendiri.
		_scale_text.call_deferred(node)


## Simpan ukuran font asli node sekali, lalu terapkan skala teks sekarang.
func _scale_text(node: Node) -> void:
	if not is_instance_valid(node) or not (node is Label or node is Button or node is RichTextLabel):
		return
	var control := node as Control
	if control.has_meta(FIXED_SIZE_META):
		return
	var property := &"normal_font_size" if control is RichTextLabel else &"font_size"
	if not control.has_meta(BASE_SIZE_META):
		if text_size == 0:
			return
		control.set_meta(BASE_SIZE_META, control.get_theme_font_size(property))
	var base: int = control.get_meta(BASE_SIZE_META)
	control.add_theme_font_size_override(property, roundi(base * text_scale()))

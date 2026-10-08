extends CanvasLayer
## Transisi antar layar: lingkaran menutup, ganti scene, lalu lingkaran membuka.

const SHADER_CODE := """
shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec2 screen_size = vec2(720.0, 672.0);
uniform vec4 fill : source_color = vec4(0.169, 0.176, 0.259, 1.0);

void fragment() {
	vec2 pos = UV * screen_size;
	float radius = (1.0 - progress) * length(screen_size) * 0.55;
	float inside = step(distance(pos, screen_size * 0.5), radius);
	COLOR = vec4(fill.rgb, (1.0 - inside) * fill.a);
}
"""
const DURATION := 0.28

## true: ganti scene langsung tanpa animasi (dipakai tes otomatis).
var instant := false

var _cover: ColorRect
var _material: ShaderMaterial
var _busy := false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	var shader := Shader.new()
	shader.code = SHADER_CODE
	_material = ShaderMaterial.new()
	_material.shader = shader
	_cover = ColorRect.new()
	_cover.material = _material
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cover.visible = false
	add_child(_cover)
	_cover.resized.connect(func() -> void: _material.set_shader_parameter("screen_size", _cover.size))


## Pindah ke scene lain dengan transisi.
func change_scene(path: String) -> void:
	_run(func() -> void: get_tree().change_scene_to_file(path))


## Muat ulang scene sekarang dengan transisi.
func reload() -> void:
	_run(func() -> void: get_tree().reload_current_scene())


func _run(swap: Callable) -> void:
	if instant:
		swap.call()
		return
	if _busy:
		return
	_busy = true
	_cover.visible = true
	_cover.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_method(_set_progress, 0.0, 1.0, DURATION).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(swap)
	tween.tween_interval(0.05)
	tween.tween_method(_set_progress, 1.0, 0.0, DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(_finish)


func _set_progress(value: float) -> void:
	_material.set_shader_parameter("progress", value)


func _finish() -> void:
	_cover.visible = false
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false

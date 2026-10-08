extends Node
## Menyesuaikan skala tampilan dengan bentuk layar.
##
## Basis desain 720 x 672 dengan stretch "expand". Di layar potret (HP) dan layar
## lanskap kecil, seluruh tampilan diperbesar supaya teks dan tombol tetap nyaman
## dibaca dan disentuh; papan permainan lalu digulir ke samping mengikuti Masbro.

## Lebar logis yang dituju di layar potret.
const PORTRAIT_WIDTH := 480.0
## Skala untuk layar lanskap yang kecil (misalnya HP dimiringkan).
const SMALL_LANDSCAPE_FACTOR := 1.25

signal layout_changed


func _ready() -> void:
	get_tree().root.size_changed.connect(_update)
	_update()


## Lebar layar logis (unit game) saat ini.
func width() -> float:
	return get_viewport().get_visible_rect().size.x


## true bila layar lebih sempit dari papan permainan (layout ringkas).
func is_compact() -> bool:
	return width() < 600.0


## Lebar maksimal kartu/panel: tidak lebih dari preferred, dan menyisakan tepi layar.
func card_width(preferred: float, margin := 24.0) -> float:
	return minf(preferred, width() - margin * 2.0)


func _update() -> void:
	var window := get_tree().root
	var size := Vector2(window.size)
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var base := window.content_scale_size
	var fit := minf(size.x / base.x, size.y / base.y)
	var factor := 1.0
	if size.y > size.x * 1.15:
		# Potret: logis selebar PORTRAIT_WIDTH.
		factor = (size.x / fit) / PORTRAIT_WIDTH
	elif fit < 0.8:
		factor = SMALL_LANDSCAPE_FACTOR
	if not is_equal_approx(window.content_scale_factor, factor):
		window.content_scale_factor = factor
	layout_changed.emit()

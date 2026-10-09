class_name StreetDecor
extends Node2D
## Dekorasi jalan ala poster (tidak menghalangi langkah): tiang listrik di tepi papan,
## kabel yang menjuntai di antara tiang, dan kabel melintang di atas jalan.

## Jarak minimal antar-tiang (baris).
const POLE_GAP := 3
const POLE_SPRITE := "deco_pole"
const WIRE_COLOR := Color(0.16, 0.12, 0.13, 0.55)
## Posisi isolator di palang tiang (piksel game dari kiri sprite tiang).
const INSULATORS := [2.5, 11.5]

var tile := 48.0
var columns := 15
var lanes: Array[LaneData] = []

## Posisi dasar tiang (piksel game), untuk tes.
var poles: Array[Vector2] = []
var _pole_texture: Texture2D
var _pole_size := Vector2.ZERO


func _ready() -> void:
	_pole_texture = SpriteLibrary.texture(POLE_SPRITE)
	if _pole_texture:
		_pole_size = _pole_texture.get_size() / SpriteLibrary.density(POLE_SPRITE)
	var last := -POLE_GAP
	# Tiang hanya di trotoar/median, tidak di baris pertama/terakhir (rumah & gudang).
	for row in range(lanes.size() - 2, 0, -1):
		var lane := lanes[row]
		if lane.kind != LaneData.Kind.SIDEWALK and lane.kind != LaneData.Kind.MEDIAN:
			continue
		if lane.checkpoint or absi(row - last) < POLE_GAP:
			continue
		if lane.obstacles.has(0) or lane.obstacles.has(columns - 1):
			continue
		last = row
		var base_y := row * tile + tile - 2.0
		poles.append(Vector2(2.0, base_y))
		poles.append(Vector2(columns * tile - _pole_size.x - 2.0, base_y))


func _draw() -> void:
	if _pole_texture == null:
		return
	# Kabel di sisi kiri dan kanan, dari tiang ke tiang berikutnya.
	for side in 2:
		var previous := Vector2.INF
		for i in range(side, poles.size(), 2):
			var top := _top(poles[i])
			if previous != Vector2.INF:
				for offset: float in INSULATORS:
					_wire(previous + Vector2(offset, 0), top + Vector2(offset, 0), 10.0)
			previous = top
	# Kabel melintang di atas jalan antara pasangan tiang.
	for i in range(0, poles.size(), 2):
		var left := _top(poles[i]) + Vector2(INSULATORS[1], 0)
		var right := _top(poles[i + 1]) + Vector2(INSULATORS[0], 0)
		_wire(left, right, 18.0)
	for base in poles:
		draw_texture_rect(_pole_texture, Rect2(base - Vector2(0, _pole_size.y), _pole_size), false)


func _top(base: Vector2) -> Vector2:
	return base - Vector2(0, _pole_size.y - 6.0)


## Kabel menjuntai (kurva parabola) dari a ke b.
func _wire(a: Vector2, b: Vector2, sag: float) -> void:
	var points := PackedVector2Array()
	for i in 17:
		var t := i / 16.0
		points.append(a.lerp(b, t) + Vector2(0, sag * 4.0 * t * (1.0 - t)))
	draw_polyline(points, WIRE_COLOR, 1.5, true)

class_name MapGenerator
extends RefCounted
## Merakit lane map dari MapParams. Hasil diurutkan dari ATAS (rumah pelanggan)
## ke BAWAH (gudang), sama seperti DayData.lanes.

const COLUMNS := 15
## Panjang putaran kendaraan dalam petak (lebar papan + margin di luar layar).
const LOOP_TILES := 19
## Celah minimal antar kendaraan dalam satu lane, dalam petak.
const MIN_GAP_TILES := 3


static func generate(params: MapParams, rng: RandomNumberGenerator) -> Array[LaneData]:
	var rows: Array[LaneData] = [_safe(LaneData.Kind.SIDEWALK)]  # gudang
	for block in params.road_blocks:
		var progress := float(block) / maxf(1.0, params.road_blocks - 1.0)
		var speed_scale := lerpf(1.0, params.speed_ramp, progress)
		var direction := 1 if rng.randf() < 0.5 else -1
		for i in rng.randi_range(params.lanes_per_block.x, params.lanes_per_block.y):
			rows.append(_road(params, rng, direction, speed_scale))
			# Lane bersebelahan berlawanan arah, seperti jalan dua arah.
			direction = -direction
		if block < params.road_blocks - 1:
			for i in rng.randi_range(params.safe_rows_between.x, params.safe_rows_between.y):
				rows.append(_safe(LaneData.Kind.MEDIAN))
	rows.append(_safe(LaneData.Kind.SIDEWALK))  # rumah pelanggan
	rows.reverse()
	_decorate(rows, params, rng)
	return rows


## Taruh rintangan statis dan item. Baris gudang dan rumah dibiarkan kosong.
static func _decorate(rows: Array[LaneData], params: MapParams, rng: RandomNumberGenerator) -> void:
	var road_rows: Array[int] = []
	for row in range(1, rows.size() - 1):
		var lane := rows[row]
		if lane.kind == LaneData.Kind.MEDIAN:
			var count := rng.randi_range(params.blockers_per_safe_row.x, params.blockers_per_safe_row.y)
			for col in _distinct_columns(rng, count):
				lane.obstacles[col] = [&"cone", &"barrier"][rng.randi() % 2]
		elif lane.kind == LaneData.Kind.ROAD:
			road_rows.append(row)
			if rng.randf() < params.hole_chance:
				lane.obstacles[rng.randi_range(0, COLUMNS - 1)] = &"hole"
		if rng.randf() < params.coin_chance:
			var start := rng.randi_range(0, COLUMNS - 3)
			for col in range(start, start + rng.randi_range(1, 3)):
				if not lane.obstacles.has(col):
					lane.items[col] = &"coin"
	for block in params.road_blocks:
		if road_rows.is_empty() or rng.randf() >= params.powerup_chance:
			continue
		var lane := rows[road_rows[rng.randi() % road_rows.size()]]
		var col := rng.randi_range(0, COLUMNS - 1)
		if not lane.obstacles.has(col):
			lane.items[col] = [&"helmet", &"shoes"][rng.randi() % 2]


static func _distinct_columns(rng: RandomNumberGenerator, count: int) -> Array[int]:
	var columns: Array[int] = []
	for col in COLUMNS:
		columns.append(col)
	for i in range(columns.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp := columns[i]
		columns[i] = columns[j]
		columns[j] = tmp
	return columns.slice(0, count)


static func _safe(kind: LaneData.Kind) -> LaneData:
	var lane := LaneData.new()
	lane.kind = kind
	lane.vehicle_count = 0
	return lane


static func _road(params: MapParams, rng: RandomNumberGenerator, direction: int, speed_scale: float) -> LaneData:
	var lane := LaneData.new()
	lane.kind = LaneData.Kind.ROAD
	lane.direction = direction
	lane.vehicle = _pick_vehicle(params.vehicle_weights, rng)
	var length: int = Vehicle.TYPES[lane.vehicle]["length"]
	var max_count := maxi(1, floori(float(LOOP_TILES) / (length + MIN_GAP_TILES)))
	lane.vehicle_count = clampi(rng.randi_range(params.vehicles_per_lane.x, params.vehicles_per_lane.y), 1, max_count)
	# Truk berat lebih lambat, motor lebih gesit.
	var type_speed := {&"motor": 1.2, &"mobil": 1.0, &"truk": 0.7}
	lane.speed = rng.randf_range(params.speed_range.x, params.speed_range.y) * speed_scale * type_speed[lane.vehicle]
	lane.offset = rng.randf_range(0.0, LOOP_TILES * 48.0)
	return lane


static func _pick_vehicle(weights: Dictionary, rng: RandomNumberGenerator) -> StringName:
	var total := 0.0
	for weight: float in weights.values():
		total += weight
	var roll := rng.randf() * total
	for type: StringName in weights:
		roll -= weights[type]
		if roll <= 0.0:
			return type
	return &"mobil"

class_name MapGenerator
extends RefCounted
## Merakit lane map dari MapParams. Hasil diurutkan dari ATAS (rumah pelanggan)
## ke BAWAH (gudang), sama seperti DayData.lanes.

const COLUMNS := 15
## Panjang putaran kendaraan dalam petak (lebar papan + margin di luar layar).
const LOOP_TILES := 19
## Celah minimal antar kendaraan dalam satu lane, dalam petak.
const MIN_GAP_TILES := 3
## Rentang baris titik jemput (bagian dari tinggi map, 0 = rumah pelanggan, 1 = gudang).
const PICKUP_RANGE := Vector2(0.35, 0.65)
## Pijakan di sungai.
const PLATFORMS: Array[StringName] = [&"rakit2", &"rakit3", &"perahu2", &"perahu3"]
## Pengali kecepatan per jenis kendaraan: truk dan bus berat lebih lambat, motor lebih gesit.
const TYPE_SPEED := {&"motor": 1.2, &"bajaj": 1.05, &"mobil": 1.0, &"angkot": 0.95, &"truk": 0.7, &"bus": 0.65}


static func generate(params: MapParams, rng: RandomNumberGenerator) -> Array[LaneData]:
	var rows: Array[LaneData] = [_safe(LaneData.Kind.SIDEWALK)]  # gudang
	# Blok yang dipaksa menjadi sungai (blok pertama selalu jalan).
	var forced_rivers: Array[int] = []
	var candidates := range(1, params.road_blocks)
	while forced_rivers.size() < mini(params.min_rivers, candidates.size()):
		var pick: int = candidates[rng.randi() % candidates.size()]
		if not pick in forced_rivers:
			forced_rivers.append(pick)
	for block in params.road_blocks:
		var progress := float(block) / maxf(1.0, params.road_blocks - 1.0)
		var speed_scale := lerpf(1.0, params.speed_ramp, progress)
		var direction := 1 if rng.randf() < 0.5 else -1
		if block in forced_rivers or (block > 0 and rng.randf() < params.river_chance):
			for i in rng.randi_range(params.river_lanes.x, params.river_lanes.y):
				rows.append(_river(params, rng, direction))
				direction = -direction
		else:
			_append_roads(rows, params, rng, direction, speed_scale)
		if block < params.road_blocks - 1:
			var is_checkpoint := params.checkpoint_every > 0 and (block + 1) % params.checkpoint_every == 0
			for i in rng.randi_range(params.safe_rows_between.x, params.safe_rows_between.y):
				var median := _safe(LaneData.Kind.MEDIAN)
				median.checkpoint = is_checkpoint and i == 0
				rows.append(median)
	rows.append(_safe(LaneData.Kind.SIDEWALK))  # rumah pelanggan
	rows.reverse()
	_decorate(rows, params, rng)
	return rows


static func _append_roads(rows: Array[LaneData], params: MapParams, rng: RandomNumberGenerator,
		direction: int, speed_scale: float) -> void:
	for i in rng.randi_range(params.lanes_per_block.x, params.lanes_per_block.y):
		rows.append(_road(params, rng, direction, speed_scale))
		# Lane bersebelahan berlawanan arah, seperti jalan dua arah.
		direction = -direction


## Lane air dengan rakit yang rapat (celah < 1 petak) supaya selalu bisa diseberangi.
static func _river(params: MapParams, rng: RandomNumberGenerator, direction: int) -> LaneData:
	var lane := LaneData.new()
	lane.kind = LaneData.Kind.RIVER
	lane.direction = direction
	lane.vehicle = PLATFORMS[rng.randi() % PLATFORMS.size()]
	var length: int = Vehicle.TYPES[lane.vehicle]["length"]
	lane.vehicle_count = ceili(float(LOOP_TILES) / (length + 1.5))
	lane.speed = rng.randf_range(params.raft_speed.x, params.raft_speed.y)
	lane.offset = rng.randf_range(0.0, LOOP_TILES * 48.0)
	return lane


## Taruh rintangan statis dan item. Baris gudang dan rumah dibiarkan kosong.
static func _decorate(rows: Array[LaneData], params: MapParams, rng: RandomNumberGenerator) -> void:
	var road_rows: Array[int] = []
	for row in range(1, rows.size() - 1):
		var lane := rows[row]
		# Sungai dan pos dibiarkan bersih (pos = tempat istirahat).
		if lane.kind == LaneData.Kind.RIVER or lane.checkpoint:
			continue
		if lane.kind == LaneData.Kind.MEDIAN:
			var count := rng.randi_range(params.blockers_per_safe_row.x, params.blockers_per_safe_row.y)
			var columns := _distinct_columns(rng, count + 1)
			for i in count:
				lane.obstacles[columns[i]] = [&"cone", &"barrier"][rng.randi() % 2]
			if rng.randf() < params.vendor_chance:
				lane.obstacles[columns[count]] = &"gerobak"
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


## Titik jemput paket: petak aman (trotoar/median, bukan pos) di sekitar tengah map, di kolom
## yang tidak terhalang. Item di petak itu dibuang. Vector2i(-1, -1) bila tidak ada tempat.
static func pick_pickup(rows: Array[LaneData], rng: RandomNumberGenerator, start_column: int) -> Vector2i:
	var last := rows.size() - 1
	var candidates: Array[int] = []
	# Baris 0 = rumah pelanggan (atas), baris terakhir = gudang (bawah).
	for row in range(roundi(last * PICKUP_RANGE.x), roundi(last * PICKUP_RANGE.y) + 1):
		var lane := rows[row]
		if row > 0 and row < last and not lane.checkpoint \
				and (lane.kind == LaneData.Kind.MEDIAN or lane.kind == LaneData.Kind.SIDEWALK):
			candidates.append(row)
	if candidates.is_empty():
		return Vector2i(-1, -1)
	var row := candidates[rng.randi() % candidates.size()]
	var lane := rows[row]
	var columns: Array[int] = []
	for col in range(1, COLUMNS - 1):
		# Kios jangan tepat di jalur lurus dari gudang, dan petak kiri-kanannya tetap bisa dilewati.
		if absi(col - start_column) >= 2 and not lane.obstacles.has(col):
			columns.append(col)
	if columns.is_empty():
		return Vector2i(-1, -1)
	var col := columns[rng.randi() % columns.size()]
	lane.items.erase(col)
	return Vector2i(col, row)


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
	lane.speed = rng.randf_range(params.speed_range.x, params.speed_range.y) * speed_scale \
			* TYPE_SPEED.get(lane.vehicle, 1.0)
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

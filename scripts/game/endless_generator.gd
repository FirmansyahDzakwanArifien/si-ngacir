class_name EndlessGenerator
extends RefCounted
## Generator segmen jalanan & order tanpa batas untuk Mode Endless (jalan menyambung terus ke atas).
## Setiap order menghasilkan paket baru, pelanggan baru, tema kota, segmen lane prosedural,
## posisi kios penjemputan, dan tambahan waktu ETA.

const PACKAGES: Array[String] = [
	"res://resources/packages/gorengan.tres",
	"res://resources/packages/es_krim.tres",
	"res://resources/packages/kue_ultah.tres",
	"res://resources/packages/laptop.tres",
	"res://resources/packages/kristal.tres",
]

const CITIES: Array[String] = [
	"res://resources/cities/pasar.tres",
	"res://resources/cities/sekolah.tres",
	"res://resources/cities/perumahan.tres",
	"res://resources/cities/kota.tres",
	"res://resources/cities/bisnis.tres",
]

const CUSTOMERS: Array[Dictionary] = [
	{
		"id": &"nana",
		"name": "Nana",
		"greeting": "Cepetan ya, Masbro! Pesanan ekspres!",
		"hurry": "Waktunya mepet, Masbro!",
		"late": "Telat! Bintang satu!",
	},
	{
		"id": &"bu_sri",
		"name": "Bu Sri",
		"greeting": "Ditunggu ya, Masbro!",
		"hurry": "Hati-hati, waktunya sedikit lagi!",
		"late": "Yah, kelamaan nih...",
	},
	{
		"id": &"pak_budi",
		"name": "Pak Budi",
		"greeting": "Siap ditunggu di depan rumah, Masbro!",
		"hurry": "Ayo sedikit lagi, Masbro!",
		"late": "Wah, waktunya hampir habis...",
	},
	{
		"id": &"walikota",
		"name": "Pak Wali Kota",
		"greeting": "Pengantaran VIP! Jangan sampai lecet.",
		"hurry": "Rapat hampir mulai, Masbro!",
		"late": "Sangat disayangkan, terlambat!",
	},
]

const SENDERS: Array[Array] = [
	["Warung Mak Ijah", "Hati-hati di jalan, Masbro!"],
	["Toko Serba Ada", "Titip ya, Masbro!"],
	["Kedai Cepat Saji", "Masih panas nih, langsung antar!"],
	["Galeri Kota Ngacir", "Barang penting, jangan lecet!"],
	["Depot Ngacir Timur", "Gas terus, Masbro!"],
]

## Bonus skor khusus untuk paket yang lebih sulit (rapuh / berat).
const PACKAGE_BONUS := {
	&"gorengan": 0,
	&"es_krim": 25,
	&"kue_ultah": 50,
	&"laptop": 50,
	&"kristal": 100,
}


## Buat DayData & MapParams untuk order ke-`order_num` (mulai dari 1).
static func generate(order_num: int, last_package: StringName = &"", last_city: StringName = &"") -> DayData:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var tier := maxi(0, order_num - 1)
	var day := DayData.new()
	day.day = order_num
	day.title = "Shift Lembur"

	var pkg := _pick_package(order_num, last_package, rng)
	day.package = pkg
	day.city = _pick_city(last_city, rng)

	var customer: Dictionary = CUSTOMERS[rng.randi() % CUSTOMERS.size()]
	day.customer_id = customer["id"]
	day.customer_name = customer["name"]
	day.customer_greeting = customer["greeting"]
	day.customer_hurry_line = customer["hurry"]
	day.customer_late_line = customer["late"]

	var sender: Array = SENDERS[rng.randi() % SENDERS.size()]
	day.sender_name = sender[0]
	day.sender_line = sender[1]

	# Segmen per order dibuat padat & gesit (3..7 blok) supaya ritme ambil-antar terasa non-stop!
	var params := MapParams.new()
	params.road_blocks = clampi(3 + int(tier / 2), 3, 7)
	if order_num <= 2:
		params.lanes_per_block = Vector2i(2, 3)
		params.safe_rows_between = Vector2i(1, 2)
		params.vehicles_per_lane = Vector2i(1, 2)
		params.blockers_per_safe_row = Vector2i(0, 2)
	elif order_num <= 5:
		params.lanes_per_block = Vector2i(2, 4)
		params.safe_rows_between = Vector2i(1, 2)
		params.vehicles_per_lane = Vector2i(2, 3)
		params.blockers_per_safe_row = Vector2i(1, 2)
	else:
		params.lanes_per_block = Vector2i(3, 4)
		params.safe_rows_between = Vector2i(1, 1)
		params.vehicles_per_lane = Vector2i(2, 3)
		params.blockers_per_safe_row = Vector2i(1, 3)

	var min_speed := 55.0 + minf(tier * 6.0, 48.0)
	var max_speed := 95.0 + minf(tier * 8.0, 70.0)
	params.speed_range = Vector2(min_speed, max_speed)
	params.speed_ramp = minf(1.18 + tier * 0.04, 1.45)

	if order_num == 1:
		params.vehicle_weights = {&"motor": 2.5, &"mobil": 3.0, &"bajaj": 1.5, &"angkot": 1.5}
	else:
		params.vehicle_weights = {
			&"motor": 2.8,
			&"mobil": 2.5,
			&"truk": 1.0 + minf(tier * 0.12, 1.0),
			&"bajaj": 1.2,
			&"angkot": 1.2,
			&"bus": 0.6 + minf(tier * 0.1, 0.9),
		}

	var heavy_grace := 0.22 if pkg.step_time > 0.14 else 0.0
	params.eta_per_row = maxf(0.95, 1.45 - tier * 0.04) + heavy_grace
	params.fixed_seed = 0

	# Sungai mulai muncul dari Order #2.
	if order_num == 1:
		params.river_chance = 0.0
		params.min_rivers = 0
	elif order_num == 2:
		params.river_chance = 0.22
		params.min_rivers = 1
	else:
		params.river_chance = minf(0.20 + (tier - 1) * 0.03, 0.38)
		params.min_rivers = 0
	params.river_lanes = Vector2i(2, 3)
	params.raft_speed = Vector2(36.0 + minf(tier * 3.0, 26.0), 60.0 + minf(tier * 4.0, 34.0))

	# Tidak ada Pos di Mode Endless.
	params.checkpoint_every = 0
	params.checkpoint_penalty = 0

	params.vendor_chance = minf(0.22 + tier * 0.025, 0.35)
	params.hole_chance = 0.0 if order_num == 1 else minf(0.08 + (tier - 1) * 0.025, 0.26)
	params.coin_chance = 0.42
	params.powerup_chance = 0.38
	day.map = params

	# Side conflicts: bertambah seiring nomor order.
	day.cat_count = 0 if order_num == 1 else (1 if order_num <= 4 else 2)
	day.pedestrian_count = 1 if order_num <= 3 else 2
	if order_num >= 3:
		day.rival_interval = maxf(7.5, 15.0 - (order_num - 3) * 0.85)
		day.peel_chance = minf(0.30 + (order_num - 3) * 0.05, 0.65)
	if order_num >= 4:
		day.buldog_count = 1 if order_num <= 6 else 2
		day.rainy = rng.randf() < 0.35
		day.slip_chance = 0.14
		day.visibility_tiles = 5.5

	return day


## Rakit satu segmen jalanan ke arah ATAS (baris negatif) menyambung dari `start_row`.
## Mengembalikan dictionary berisi: day, rows (dict row_int -> LaneData), pickup_cell,
## dropoff_row, time_budget.
static func build_chunk(order_num: int, start_row: int, start_col: int,
		last_package: StringName = &"", last_city: StringName = &"") -> Dictionary:
	var day := generate(order_num, last_package, last_city)
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var raw_lanes := MapGenerator.generate(day.map, rng)
	# raw_lanes[0] = trotoar pelanggan (atas), raw_lanes[-1] = trotoar bawah (sudah ada di start_row).
	# Buang baris paling bawah agar langsung menyambung mulus di atas start_row!
	var count := raw_lanes.size() - 1
	var row_map := {}
	var median_rows: Array[int] = []
	for offset in range(1, count + 1):
		var world_row := start_row - offset
		var lane := raw_lanes[count - offset]
		row_map[world_row] = lane
		if offset > 1 and offset < count and lane.kind == LaneData.Kind.MEDIAN:
			median_rows.append(world_row)

	var dropoff_row := start_row - count

	# Pilih baris titik jemput (di sekitar 30%..60% perjalanan segmen ini).
	var pickup_cell := Vector2i(-1, -1)
	if not median_rows.is_empty():
		var target_row := start_row - int(round(count * 0.42))
		var best_row := median_rows[0]
		var best_dist := absi(best_row - target_row)
		for r in median_rows:
			var d := absi(r - target_row)
			if d < best_dist:
				best_dist = d
				best_row = r
		var cols: Array[int] = []
		for col in range(1, MapGenerator.COLUMNS - 1):
			if absi(col - start_col) >= 2:
				cols.append(col)
		var chosen_col: int = cols[rng.randi() % cols.size()] if not cols.is_empty() else 3
		var pickup_lane: LaneData = row_map[best_row]
		pickup_lane.obstacles.clear()
		pickup_lane.items.erase(chosen_col)
		pickup_cell = Vector2i(chosen_col, best_row)

	# Hitung jatah waktu ETA untuk segmen ini (dipakai sebagai waktu awal Order #1 dan
	# tambahan waktu / time extension saat menyelesaikan order).
	var time_budget := roundf(count * day.map.eta_per_row)
	if pickup_cell.x >= 0:
		time_budget += roundf(4.0 + absi(pickup_cell.x - start_col) * 0.5)
	day.eta_seconds = time_budget

	return {
		"order_num": order_num,
		"day": day,
		"rows": row_map,
		"start_row": start_row,
		"dropoff_row": dropoff_row,
		"pickup_cell": pickup_cell,
		"row_count": count,
		"time_budget": time_budget,
	}


static func package_bonus(pkg: PackageData) -> int:
	if pkg == null:
		return 0
	return int(PACKAGE_BONUS.get(pkg.id, 0))


## Hitung skor satu order Endless (termasuk bonus paket rapuh/berat & pengali streak).
static func evaluate_order(order_num: int, pkg: PackageData, integrity: float,
		time_left: float, coins_in_order: int) -> Dictionary:
	var base := 100
	var pkg_bonus := package_bonus(pkg)
	var time_bonus := maxi(0, roundi(minf(time_left, 35.0) * 6.0))
	var integrity_bonus := roundi(clampf(integrity, 0.0, 1.0) * 100.0)
	var coin_bonus := coins_in_order * 15
	var multiplier := 1.0 + (maxi(1, order_num) - 1) * 0.25
	var subtotal := base + pkg_bonus + time_bonus + integrity_bonus + coin_bonus
	var total := roundi(subtotal * multiplier)
	var streak_coins := 2 + mini(order_num, 5)
	return {
		"base": base,
		"package_bonus": pkg_bonus,
		"time_bonus": time_bonus,
		"integrity_bonus": integrity_bonus,
		"coin_bonus": coin_bonus,
		"multiplier": multiplier,
		"total": total,
		"streak_coins": streak_coins,
	}


static func _pick_package(order_num: int, last_package: StringName, rng: RandomNumberGenerator) -> PackageData:
	var max_idx := 1 if order_num == 1 else (3 if order_num <= 3 else PACKAGES.size())
	var pool: Array[PackageData] = []
	for i in max_idx:
		var pkg := load(PACKAGES[i]) as PackageData
		if pkg:
			pool.append(pkg)
	if pool.size() > 1 and last_package != &"":
		var filtered := pool.filter(func(p: PackageData) -> bool: return p.id != last_package)
		if not filtered.is_empty():
			pool = filtered
	return pool[rng.randi() % pool.size()]


static func _pick_city(last_city: StringName, rng: RandomNumberGenerator) -> CityTheme:
	var pool: Array[CityTheme] = []
	for path in CITIES:
		var city := load(path) as CityTheme
		if city:
			pool.append(city)
	if pool.size() > 1 and last_city != &"":
		var filtered := pool.filter(func(c: CityTheme) -> bool: return StringName(c.display_name) != last_city)
		if not filtered.is_empty():
			pool = filtered
	return pool[rng.randi() % pool.size()]

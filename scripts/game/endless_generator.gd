class_name EndlessGenerator
extends RefCounted
## Generator order tanpa batas untuk Mode Endless (Shift Lembur).
## Setiap order menghasilkan DayData & MapParams prosedural baru dengan kesulitan
## yang meningkat bertahap, kompatibel penuh dengan tampilan 2D maupun 3D.

const PACKAGES: Array[String] = [
	"res://resources/packages/gorengan.tres",
	"res://resources/packages/kue_ultah.tres",
	"res://resources/packages/es_krim.tres",
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


## Buat satu order prosedural untuk nomor order ke-`order_num` (mulai dari 1).
static func generate(order_num: int, last_package: StringName = &"", last_city: StringName = &"") -> DayData:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var tier := maxi(0, order_num - 1)
	var day := DayData.new()
	day.day = order_num
	day.title = "Shift Lembur"

	# Pilih paket sesuai progres order: awal ramah, makin tinggi makin beragam & rapuh.
	var pkg := _pick_package(order_num, last_package, rng)
	day.package = pkg

	# Pilih tema kota secara acak (hindari sama persis dengan order sebelumnya).
	var city := _pick_city(last_city, rng)
	day.city = city

	# Pilih pelanggan dan kios pengirim.
	var customer: Dictionary = CUSTOMERS[rng.randi() % CUSTOMERS.size()]
	day.customer_id = customer["id"]
	day.customer_name = customer["name"]
	day.customer_greeting = customer["greeting"]
	day.customer_hurry_line = customer["hurry"]
	day.customer_late_line = customer["late"]

	var sender: Array = SENDERS[rng.randi() % SENDERS.size()]
	day.sender_name = sender[0]
	day.sender_line = sender[1]

	# Aturan peta prosedural dengan eskalasi bertahap.
	var params := MapParams.new()
	params.road_blocks = clampi(4 + tier, 4, 14)
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
		params.lanes_per_block = Vector2i(3, 5)
		params.safe_rows_between = Vector2i(1, 1)
		params.vehicles_per_lane = Vector2i(2, 3)
		params.blockers_per_safe_row = Vector2i(1, 3)

	var min_speed := 55.0 + minf(tier * 6.0, 45.0)
	var max_speed := 95.0 + minf(tier * 8.0, 65.0)
	params.speed_range = Vector2(min_speed, max_speed)
	params.speed_ramp = minf(1.20 + tier * 0.04, 1.50)

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

	# ETA makin ketat tiap order, tapi beri sedikit kelonggaran untuk paket berat (kue ultah).
	var heavy_grace := 0.20 if pkg.step_time > 0.14 else 0.0
	params.eta_per_row = maxf(1.05, 1.55 - tier * 0.045) + heavy_grace
	params.fixed_seed = 0

	# Sungai mulai muncul dari Order #2.
	if order_num == 1:
		params.river_chance = 0.0
		params.min_rivers = 0
	elif order_num == 2:
		params.river_chance = 0.2
		params.min_rivers = 1
	else:
		params.river_chance = minf(0.18 + (tier - 1) * 0.035, 0.38)
		params.min_rivers = 0
	params.river_lanes = Vector2i(2, 3)
	params.raft_speed = Vector2(35.0 + minf(tier * 3.0, 25.0), 58.0 + minf(tier * 4.0, 32.0))

	# Mode Endless tidak memakai Pos (paket hancur atau waktu habis = Game Over).
	params.checkpoint_every = 0
	params.checkpoint_penalty = 0

	params.vendor_chance = minf(0.20 + tier * 0.025, 0.35)
	params.hole_chance = 0.0 if order_num == 1 else minf(0.08 + (tier - 1) * 0.025, 0.28)
	params.coin_chance = 0.40
	params.powerup_chance = 0.35
	day.map = params

	# Side conflicts: bertambah bertahap sesuai nomor order.
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


## Hitung rincian skor satu order Endless dan bonus koin streak.
static func evaluate_order(order_num: int, integrity: float, time_left: float, coins_in_order: int) -> Dictionary:
	var base := 100
	var time_bonus := maxi(0, roundi(time_left * 10.0))
	var integrity_bonus := roundi(clampf(integrity, 0.0, 1.0) * 100.0)
	var coin_bonus := coins_in_order * 15
	var multiplier := 1.0 + (maxi(1, order_num) - 1) * 0.25
	var subtotal := base + time_bonus + integrity_bonus + coin_bonus
	var total := roundi(subtotal * multiplier)
	var streak_coins := 2 + mini(order_num, 5)
	return {
		"base": base,
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

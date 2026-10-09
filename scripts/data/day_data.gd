class_name DayData
extends Resource
## Satu hari masa percobaan di Ngacir Express (= satu level).

@export var day: int = 1
@export var title: String = ""
@export var package: PackageData
@export var customer_name: String = "Bu Sri"
## Nama sprite pelanggan: assets/sprites/customer_<id>.
@export var customer_id: StringName = &"bu_sri"
## Sapaan pelanggan saat pengiriman dimulai (balon ucapan di depan rumah).
@export_multiline var customer_greeting: String = "Ditunggu ya, Masbro!"
## Target waktu antar (Timer ETA) dalam detik.
@export var eta_seconds: float = 30.0

@export_group("Penjemputan")
## Pengirim paket: kios di titik jemput tengah map. Masbro berangkat dari gudang tanpa paket,
## mengambil paket di sini, lalu mengantarnya ke pelanggan.
@export var sender_name: String = "Toko Serba Ada"
## Pesan pengirim saat paket diambil.
@export var sender_line: String = "Titip ya, Masbro!"

@export_group("Upah")
@export var base_wage: int = 50000
@export var eta_bonus: int = 20000
## Denda ganti rugi per poin damage paket.
@export var damage_penalty: int = 10000
@export var late_penalty_per_second: int = 500

@export_group("Peta")
## Lokasi pengiriman (tile, warna, pemandangan). Kosong = tampilan bawaan.
@export var city: CityTheme
## Aturan map prosedural. Bila diisi, map dibuat acak setiap kali hari dimulai
## dan `lanes` di bawah diabaikan.
@export var map: MapParams
## Map tetap (dipakai bila `map` kosong). Lane dari ATAS (rumah pelanggan) ke
## BAWAH (gudang); baris pertama dan terakhir harus SIDEWALK.
@export var lanes: Array[LaneData] = []

@export_group("Side Conflict")
## Jumlah maksimal kucing jalanan yang muncul bersamaan (0 = tidak ada).
@export_range(0, 5) var cat_count: int = 0
## Jumlah maksimal pejalan kaki di median yang muncul bersamaan.
@export_range(0, 5) var pedestrian_count: int = 0
## Bang Kilat (kurir rival) melesat setiap sekian detik (0 = tidak muncul).
@export_range(0.0, 60.0, 1.0) var rival_interval: float = 0.0
## Hujan: jarak pandang terbatas dan jalan aspal licin.
@export var rainy: bool = false
## Peluang Masbro tergelincir satu petak tambahan saat melangkah di aspal basah.
@export_range(0.0, 1.0, 0.05) var slip_chance: float = 0.25
## Jari-jari jarak pandang saat hujan, dalam petak.
@export_range(2.0, 10.0, 0.5) var visibility_tiles: float = 4.5
## Pelanggan perfeksionis (Pak Ojan): denda kerusakan 2x, rating maksimal 3 bintang bila paket rusak.
@export var strict_customer: bool = false
## Tip dari pelanggan perfeksionis bila paket utuh dan tepat waktu.
@export var perfect_tip: int = 0

@export_group("Cerita")
## Cutscene sebelum hari ini dimulai (dari hari sebelumnya). Kosongkan bila tidak ada.
@export var story: StoryData
## Cutscene malam setelah hari ini selesai: paket terjaga baik, atau banyak rusak.
@export var evening_good: StoryData
@export var evening_rough: StoryData

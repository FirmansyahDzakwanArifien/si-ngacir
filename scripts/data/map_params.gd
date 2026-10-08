class_name MapParams
extends Resource
## Aturan pembuatan map prosedural untuk satu hari. Map dirakit dari blok jalan
## yang dipisah zona aman (median); makin jauh dari gudang, makin cepat kendaraannya.

## Jumlah blok jalan antara gudang dan rumah pelanggan.
@export_range(1, 20) var road_blocks: int = 4
## Jumlah lane jalan per blok (min, max).
@export var lanes_per_block := Vector2i(2, 3)
## Jumlah baris aman di antara dua blok jalan (min, max).
@export var safe_rows_between := Vector2i(1, 2)
## Kecepatan kendaraan dasar dalam px/detik (min, max).
@export var speed_range := Vector2(50, 90)
## Pengali kecepatan di blok terakhir (blok pertama selalu 1x).
@export_range(1.0, 2.0, 0.05) var speed_ramp: float = 1.25
## Jumlah kendaraan per lane (min, max). Dibatasi otomatis supaya selalu ada celah.
@export var vehicles_per_lane := Vector2i(1, 2)
## Peluang relatif tiap jenis kendaraan muncul.
@export var vehicle_weights := {&"motor": 2.0, &"mobil": 3.0, &"truk": 1.0}
## Target waktu (ETA) per baris map, dalam detik.
@export_range(0.5, 3.0, 0.05) var eta_per_row: float = 1.4
## 0 = map acak setiap kali dimainkan. Isi angka lain untuk map yang selalu sama.
@export var fixed_seed: int = 0

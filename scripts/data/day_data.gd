class_name DayData
extends Resource
## Satu hari masa percobaan di Ngacir Express (= satu level).

@export var day: int = 1
@export var title: String = ""
@export var package: PackageData
@export var customer_name: String = "Bu Sri"
## Target waktu antar (Timer ETA) dalam detik.
@export var eta_seconds: float = 30.0

@export_group("Upah")
@export var base_wage: int = 50000
@export var eta_bonus: int = 20000
## Denda ganti rugi per poin damage paket.
@export var damage_penalty: int = 10000
@export var late_penalty_per_second: int = 500

@export_group("Peta")
## Lane dari ATAS (rumah pelanggan) ke BAWAH (gudang). Baris pertama dan terakhir harus SIDEWALK.
@export var lanes: Array[LaneData] = []

class_name PackageData
extends Resource
## Jenis paket yang dibawa Masbro. Paket menggantikan sistem nyawa:
## kalau damage mencapai max_damage, paket hancur dan pengiriman gagal.

@export var id: StringName
@export var display_name: String = "Paket"
@export_multiline var description: String = ""
## Jumlah poin damage sampai paket hancur.
@export_range(1, 10) var max_damage: int = 3
## Pengali damage dari setiap tabrakan (contoh: telur = 2).
@export_range(1, 5) var fragility: int = 1
## Durasi satu langkah Masbro dalam detik. Makin besar, makin lambat (contoh: galon).
@export_range(0.05, 0.5, 0.01) var step_time: float = 0.12
@export var color: Color = Color("efe6cf")

class_name LaneData
extends Resource
## Satu baris di peta. Baris ROAD berisi kendaraan yang melaju terus.

enum Kind { SIDEWALK, ROAD, MEDIAN }

@export var kind: Kind = Kind.ROAD
## Jenis kendaraan: motor / mobil / truk (lihat Vehicle.TYPES).
@export var vehicle: StringName = &"mobil"
## 1 = ke kanan, -1 = ke kiri.
@export_range(-1, 1, 2) var direction: int = 1
@export_range(0.0, 400.0) var speed: float = 80.0
@export_range(0, 8) var vehicle_count: int = 2
## Geser posisi awal kendaraan (px) supaya lane tidak seragam.
@export var offset: float = 0.0

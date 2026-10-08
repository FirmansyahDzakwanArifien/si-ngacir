class_name CityTheme
extends Resource
## Suasana lokasi pengiriman satu hari: nama lokasi, tile, dan pemandangan sisi layar.

## Nama lokasi yang tampil di kartu intro, misalnya "Pasar Ngacir".
@export var display_name: String = "Kota Ngacir"
## Sprite tile untuk median (zona aman) dan trotoar gudang/rumah.
@export var median_tile: String = "tile_median"
@export var sidewalk_tile: String = "tile_sidewalk"
## Pewarnaan aspal (putih = warna asli).
@export var road_tint: Color = Color.WHITE
## Pemandangan di kiri-kanan papan pada layar lebar, dan pewarnaannya.
@export var side_tile: String = "tile_median"
@export var side_tint: Color = Color(0.72, 0.8, 0.72)

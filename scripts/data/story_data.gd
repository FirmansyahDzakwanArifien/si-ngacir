class_name StoryData
extends Resource
## Satu cutscene: beberapa halaman teks, masing-masing boleh punya gambar.

## Teks per halaman. Ditampilkan berurutan dengan efek mesin ketik.
@export_multiline var pages: PackedStringArray = []
## Nama gambar per halaman di assets/story/ (tanpa .png). Boleh kosong atau lebih pendek dari pages.
@export var images: PackedStringArray = []

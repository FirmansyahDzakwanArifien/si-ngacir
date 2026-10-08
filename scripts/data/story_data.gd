class_name StoryData
extends Resource
## Satu cutscene: beberapa halaman teks, masing-masing boleh punya gambar dan pembicara.
##
## Teks boleh memuat token {saved}, {target}, dan {left} (tabungan saat ini, biaya
## pengobatan, dan kekurangannya); token diganti saat cutscene diputar.

## Teks per halaman. Ditampilkan berurutan dengan efek mesin ketik.
@export_multiline var pages: PackedStringArray = []
## Nama gambar per halaman di assets/story/ (tanpa ekstensi). Kosong = pakai gambar halaman sebelumnya.
@export var images: PackedStringArray = []
## Pembicara per halaman, format "tokoh:ekspresi" (lihat Speakers), misalnya "nana:senang".
## Kosong = narasi.
@export var speakers: PackedStringArray = []


func image_at(index: int) -> String:
	for i in range(mini(index, images.size() - 1), -1, -1):
		if images[i] != "":
			return images[i]
	return ""


func speaker_at(index: int) -> String:
	return speakers[index] if index < speakers.size() else ""


## Gabungkan beberapa cutscene menjadi satu (yang null atau kosong dilewati).
static func combine(stories: Array) -> StoryData:
	var result := StoryData.new()
	for story: StoryData in stories:
		if story == null:
			continue
		for i in story.pages.size():
			result.pages.append(story.pages[i])
			result.images.append(story.image_at(i))
			result.speakers.append(story.speaker_at(i))
	return result

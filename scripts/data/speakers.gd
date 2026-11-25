class_name Speakers
extends RefCounted
## Daftar tokoh yang bisa bicara di cutscene: nama tampilan dan warna papan nama.
## Potret ada di assets/portraits/<id>_<ekspresi>.svg (atau .png dari tim ilustrator).

const PORTRAIT_DIR := "res://assets/portraits/"

const CAST := {
	"masbro": {"name": "Masbro", "color": Color("2ec4b6")},
	"koko": {"name": "Bos Koko", "color": Color("e8b923")},
	"nana": {"name": "Nana", "color": Color("ff6b6b")},
	"kuro": {"name": "Kuro", "color": Color("5b5f7a")},
	"buldog": {"name": "Pak Buldog", "color": Color("b07d48")},
	"pemilik": {"name": "Pemilik Lahan", "color": Color("8c74e0")},
	"walikota": {"name": "Pak Wali Kota", "color": Color("d4a017")},
}

## Musik cutscene: tema sedih, tema tegang (Kuro, Pemilik Lahan, Pak Buldog), malam di kedai,
## perayaan ending, dan musik santai bawaan.
const SAD_MUSIC := &"sedih"
const TENSE_MUSIC := &"tegang"
const NIGHT_MUSIC := &"gameplay_malam"
const ENDING_MUSIC := &"ending"
const CALM_MUSIC := &"menu"
## Suasana per "tokoh:ekspresi". Tokoh yang tidak ada di sini memakai CALM_MUSIC,
## kecuali Masbro dan narasi yang meneruskan musik sebelumnya.
const MOOD_MUSIC := {
	"masbro:sedih": SAD_MUSIC,
	"kuro:sombong": TENSE_MUSIC,
	"kuro:kaget": TENSE_MUSIC,
	"kuro:sedih": &"",
	"pemilik:marah": TENSE_MUSIC,
	"buldog:marah": TENSE_MUSIC,
}
## Latar yang otomatis bernuansa sedih, kecuali suasananya ditentukan MOOD_MUSIC.
const SAD_IMAGES: Array[String] = ["sunset"]
const NIGHT_IMAGES: Array[String] = ["kedai_night"]
const ENDING_IMAGES: Array[String] = ["celebrate"]


## Pecah "tokoh:ekspresi" menjadi [tokoh, ekspresi]. Ekspresi bawaan "normal".
static func parse(entry: String) -> PackedStringArray:
	var parts := entry.split(":", false)
	if parts.is_empty():
		return PackedStringArray(["", ""])
	return PackedStringArray([parts[0], parts[1] if parts.size() > 1 else "normal"])


static func display_name(id: String) -> String:
	return CAST[id]["name"] if CAST.has(id) else id.capitalize()


static func color(id: String) -> Color:
	return CAST[id]["color"] if CAST.has(id) else Palette.CORAL


## Potret tokoh dengan ekspresi tertentu; jatuh ke ekspresi lain yang tersedia bila tidak ada.
static func portrait(id: String, mood: String) -> Texture2D:
	for candidate in [mood, "normal", "senang", "sombong"]:
		for extension in [".png", ".svg"]:
			var path: String = PORTRAIT_DIR + id + "_" + candidate + extension
			if ResourceLoader.exists(path):
				return load(path)
	return null


## Musik untuk satu halaman cutscene. &"" berarti meneruskan musik yang sedang diputar.
static func music_for(entry: String, image: String) -> StringName:
	var parsed := parse(entry)
	var key := parsed[0] + ":" + parsed[1]
	if MOOD_MUSIC.has(key):
		return MOOD_MUSIC[key]
	if image in SAD_IMAGES and not key.ends_with(":senang"):
		return SAD_MUSIC
	if image in ENDING_IMAGES:
		return ENDING_MUSIC
	if image in NIGHT_IMAGES:
		return NIGHT_MUSIC
	if parsed[0] == "" or parsed[0] == "masbro":
		return &""
	return CALM_MUSIC

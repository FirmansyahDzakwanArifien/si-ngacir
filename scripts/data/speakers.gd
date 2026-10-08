class_name Speakers
extends RefCounted
## Daftar tokoh yang bisa bicara di cutscene: nama tampilan dan warna papan nama.
## Potret ada di assets/portraits/<id>_<ekspresi>.svg (atau .png dari tim ilustrator).

const PORTRAIT_DIR := "res://assets/portraits/"

const CAST := {
	"masbro": {"name": "Masbro", "color": Color("2ec4b6")},
	"nana": {"name": "Nana", "color": Color("ff8fa3")},
	"kilat": {"name": "Bang Kilat", "color": Color("06d6a0")},
	"dokter": {"name": "Bu Dokter", "color": Color("6cb4e8")},
	"direktur": {"name": "Bu Direktur", "color": Color("8c74e0")},
	"ojan": {"name": "Pak Ojan", "color": Color("5e9b82")},
}


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

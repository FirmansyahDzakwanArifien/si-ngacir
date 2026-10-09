class_name Cosmetics
extends RefCounted
## Katalog aksesori Masbro di toko, dan cara memasangnya di sprite Masbro.
## Sprite aksesori: assets/sprites/acc_<id>, frame 96 x 96 sejajar sprite Masbro menghadap kanan.

enum Slot { HAT, GLASSES, BAG }

const SLOT_NAMES := {Slot.HAT: "Topi", Slot.GLASSES: "Kacamata", Slot.BAG: "Tas"}
## Bagian sprite aksesori yang dipakai sebagai ikon di toko (koordinat 2x).
const ICON_REGIONS := {
	Slot.HAT: Rect2(36, 0, 60, 40),
	Slot.GLASSES: Rect2(52, 28, 34, 24),
	Slot.BAG: Rect2(40, 54, 32, 34),
}
## Urutan gambar dari belakang ke depan.
const DRAW_ORDER := [Slot.BAG, Slot.GLASSES, Slot.HAT]
## Naik-turun tubuh Masbro per frame animasi (piksel 2x), supaya aksesori ikut bergerak.
const BOB := {
	&"idle": [0, 0, 1, 1, 1, 0, 0, 0],
	&"walk": [0, -3, 0, -3],
	&"hit": [2, 1],
}

const ITEMS := [
	{"id": &"caping", "slot": Slot.HAT, "name": "Caping", "price": 15},
	{"id": &"beanie", "slot": Slot.HAT, "name": "Beanie", "price": 20},
	{"id": &"koki", "slot": Slot.HAT, "name": "Topi Koki", "price": 25},
	{"id": &"mahkota", "slot": Slot.HAT, "name": "Mahkota", "price": 60},
	# Bawaan ala poster: dimiliki dan dipakai sejak awal (lihat GameState.STARTER_ITEM).
	{"id": &"kacamata_piksel", "slot": Slot.GLASSES, "name": "Kacamata Piksel", "price": 0},
	{"id": &"kacamata_bulat", "slot": Slot.GLASSES, "name": "Kacamata Bulat", "price": 10},
	{"id": &"kacamata_hitam", "slot": Slot.GLASSES, "name": "Kacamata Hitam", "price": 15},
	{"id": &"kacamata_bintang", "slot": Slot.GLASSES, "name": "Kacamata Bintang", "price": 30},
	{"id": &"tas_pink", "slot": Slot.BAG, "name": "Tas Pink", "price": 10},
	{"id": &"tas_oranye", "slot": Slot.BAG, "name": "Tas Oranye", "price": 10},
	{"id": &"tas_kucing", "slot": Slot.BAG, "name": "Tas Kucing", "price": 35},
]


static func item(id: StringName) -> Dictionary:
	for entry: Dictionary in ITEMS:
		if entry["id"] == id:
			return entry
	return {}


static func items_for(slot: Slot) -> Array:
	return ITEMS.filter(func(entry: Dictionary) -> bool: return entry["slot"] == slot)


## Ikon kecil aksesori untuk tombol toko.
static func icon(id: StringName) -> Texture2D:
	var entry := item(id)
	var sheet := SpriteLibrary.hires("acc_%s" % id, 2.0)
	if entry.is_empty() or sheet == null:
		return null
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	var region: Rect2 = ICON_REGIONS[entry["slot"]]
	var scale := sheet.get_width() / 96.0
	atlas.region = Rect2(region.position * scale, region.size * scale)
	return atlas


## Pasang aksesori di atas sprite Masbro. Mengembalikan node penampung aksesori.
static func dress(parent: Node2D, ids: Array, flip := false) -> Node2D:
	var holder := Node2D.new()
	parent.add_child(holder)
	var by_slot := {}
	for id: StringName in ids:
		var entry := item(id)
		if not entry.is_empty():
			by_slot[entry["slot"]] = id
	for slot in DRAW_ORDER:
		if not by_slot.has(slot):
			continue
		var sprite := SpriteLibrary.sprite("acc_%s" % by_slot[slot])
		if sprite:
			sprite.flip_h = flip
			holder.add_child(sprite)
	return holder


## Ikuti naik-turun tubuh Masbro (density 2 untuk SVG bawaan).
static func sync_bob(holder: Node2D, body: AnimatedSprite2D) -> void:
	var offsets: Array = BOB.get(body.animation, [0])
	var density := 1.0 / maxf(body.scale.y, 0.001)
	holder.position.y = offsets[body.frame % offsets.size()] / density


static func set_flip(holder: Node2D, flip: bool) -> void:
	for sprite in holder.get_children():
		(sprite as Sprite2D).flip_h = flip

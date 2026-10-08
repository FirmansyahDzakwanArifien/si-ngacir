class_name SpriteLibrary
extends RefCounted
## Mengambil sprite dari assets/sprites/ berdasarkan nama file (lihat docs/ASSET_SPEC.md).
## PNG dianggap resolusi 1x (1 petak = 48 px), SVG resolusi 2x (1 petak = 96 px) supaya
## tetap tajam di layar HP. PNG diutamakan, jadi gambar dari Illustrator selalu menang.
## Kalau file belum ada, fungsi mengembalikan null dan game memakai gambar placeholder.

const DIR := "res://assets/sprites/"
const FORMATS := {".png": 1.0, ".svg": 2.0}

## nama -> [Texture2D atau null, density]
static var _cache := {}


static func texture(sprite_name: String) -> Texture2D:
	return _lookup(sprite_name)[0]


## Jumlah piksel gambar per piksel game (1 untuk PNG, 2 untuk SVG).
static func density(sprite_name: String) -> float:
	return _lookup(sprite_name)[1]


static func _lookup(sprite_name: String) -> Array:
	if not _cache.has(sprite_name):
		_cache[sprite_name] = [null, 1.0]
		for extension: String in FORMATS:
			var path := DIR + sprite_name + extension
			if ResourceLoader.exists(path):
				_cache[sprite_name] = [load(path), FORMATS[extension]]
				break
	return _cache[sprite_name]


## Nama sprite beserta varian warnanya: nama, nama_2, nama_3, ... yang filenya ada.
static func variants(sprite_name: String) -> Array[String]:
	var names: Array[String] = []
	if texture(sprite_name):
		names.append(sprite_name)
		var index := 2
		while texture("%s_%d" % [sprite_name, index]):
			names.append("%s_%d" % [sprite_name, index])
			index += 1
	return names


## Sprite2D siap pakai dengan skala sesuai density. null bila file belum ada.
static func sprite(sprite_name: String) -> Sprite2D:
	var tex := texture(sprite_name)
	if tex == null:
		return null
	var node := Sprite2D.new()
	node.centered = false
	node.texture = tex
	node.scale = Vector2.ONE / density(sprite_name)
	return node


## Membuat SpriteFrames dari sprite strip horizontal (frame berjajar ke kanan).
## animations: {nama_animasi: nama_file}. frame_size dalam piksel game (1x).
## Mengembalikan null kalau tidak ada file sama sekali. Density tersimpan di meta "density".
static func frames(animations: Dictionary, frame_size: Vector2i, fps := 8.0) -> SpriteFrames:
	var result: SpriteFrames = null
	for animation: StringName in animations:
		var sheet := texture(animations[animation])
		if sheet == null:
			continue
		var scale := density(animations[animation])
		if result == null:
			result = SpriteFrames.new()
			result.remove_animation(&"default")
			result.set_meta(&"density", scale)
		var frame := Vector2(frame_size) * scale
		result.add_animation(animation)
		result.set_animation_speed(animation, fps)
		var count := maxi(1, floori(sheet.get_width() / frame.x))
		for i in count:
			var atlas := AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = Rect2(i * frame.x, 0, frame.x, frame.y)
			result.add_frame(animation, atlas)
	return result


## AnimatedSprite2D siap pakai dari frames(); skala mengikuti density.
static func animated(frames_resource: SpriteFrames) -> AnimatedSprite2D:
	var node := AnimatedSprite2D.new()
	node.centered = false
	node.sprite_frames = frames_resource
	node.scale = Vector2.ONE / float(frames_resource.get_meta(&"density", 1.0))
	return node


## Kotak warna sederhana sebagai pengganti ikon yang belum ada.
static func placeholder_box(size: Vector2i, fill: Color, border: Color) -> Texture2D:
	var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(border)
	image.fill_rect(Rect2i(2, 2, size.x - 4, size.y - 4), fill)
	return ImageTexture.create_from_image(image)

class_name SpriteLibrary
extends RefCounted
## Mengambil sprite dari assets/sprites/ berdasarkan nama file (lihat docs/ASSET_SPEC.md).
## Kalau file belum ada, fungsi mengembalikan null dan game memakai gambar placeholder.

const DIR := "res://assets/sprites/"

static var _cache := {}


static func texture(sprite_name: String) -> Texture2D:
	if not _cache.has(sprite_name):
		var path := DIR + sprite_name + ".png"
		_cache[sprite_name] = load(path) if ResourceLoader.exists(path) else null
	return _cache[sprite_name]


## Membuat SpriteFrames dari sprite strip horizontal (frame berjajar ke kanan).
## animations: {nama_animasi: nama_file}. Mengembalikan null kalau tidak ada file sama sekali.
static func frames(animations: Dictionary, frame_size: Vector2i, fps := 8.0) -> SpriteFrames:
	var result: SpriteFrames = null
	for animation: StringName in animations:
		var sheet := texture(animations[animation])
		if sheet == null:
			continue
		if result == null:
			result = SpriteFrames.new()
			result.remove_animation(&"default")
		result.add_animation(animation)
		result.set_animation_speed(animation, fps)
		var count := maxi(1, sheet.get_width() / frame_size.x)
		for i in count:
			var atlas := AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = Rect2(i * frame_size.x, 0, frame_size.x, frame_size.y)
			result.add_frame(animation, atlas)
	return result


## Kotak warna sederhana sebagai pengganti ikon yang belum ada.
static func placeholder_box(size: Vector2i, fill: Color, border: Color) -> Texture2D:
	var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(border)
	image.fill_rect(Rect2i(2, 2, size.x - 4, size.y - 4), fill)
	return ImageTexture.create_from_image(image)

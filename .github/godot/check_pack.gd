extends SceneTree
## Cek isi build hasil export (bukan proyek editor): cutscene, potret, dan musik
## harus ikut terbawa. Jalankan dengan:
##   godot --headless --main-pack build/web/index.pck --script .github/godot/check_pack.gd

const STORY_DIR := "res://resources/story/"
const DAY_DIR := "res://resources/days/"
const MUSIC: Array[String] = ["menu", "gameplay", "nana", "kilat"]

var _errors := 0


func _initialize() -> void:
	var stories := 0
	for file in _resources(STORY_DIR):
		var story: StoryData = load(STORY_DIR + file)
		stories += 1
		_check(story != null and not story.pages.is_empty(), "%s punya halaman" % file)
		if story == null:
			continue
		_check(story.speakers.size() == story.pages.size(), "%s: pembicara per halaman" % file)
		for entry in story.speakers:
			if entry != "":
				var parsed := Speakers.parse(entry)
				_check(Speakers.portrait(parsed[0], parsed[1]) != null, "%s: potret %s" % [file, entry])
	_check(stories >= 10, "%d cutscene ditemukan" % stories)

	var opening: StoryData = load(STORY_DIR + "opening.tres")
	_check(opening != null and opening.pages.size() > 3, "cutscene pembuka utuh")
	for file in _resources(DAY_DIR):
		var day: DayData = load(DAY_DIR + file)
		_check(day != null and day.package != null, "%s punya paket" % file)
		if day and file != "day_05.tres":
			_check(day.evening_good != null and not day.evening_good.pages.is_empty(), "%s: malam (baik)" % file)
			_check(day.evening_rough != null and not day.evening_rough.pages.is_empty(), "%s: malam (berat)" % file)

	for music in MUSIC:
		_check(ResourceLoader.exists("res://assets/audio/music/%s.wav" % music), "musik %s" % music)
	# Bus Music & SFX harus sudah ada dari layout: membuatnya saat berjalan membisukan
	# semua suara di build web Godot 4.3.
	var layout: AudioBusLayout = load("res://default_bus_layout.tres")
	_check(layout != null, "layout bus audio ikut")
	var buses := [AudioServer.get_bus_index(&"Music"), AudioServer.get_bus_index(&"SFX")]
	_check(buses[0] > 0 and buses[1] > 0, "bus Music & SFX ada sejak awal (%s)" % [buses])

	print("check_pack: %d gagal" % _errors)
	quit(1 if _errors > 0 else 0)


## Nama file resource di folder build (export bisa menambah akhiran .remap).
func _resources(directory: String) -> PackedStringArray:
	var result := PackedStringArray()
	for file in DirAccess.get_files_at(directory):
		file = file.trim_suffix(".remap")
		if file.ends_with(".tres") and not result.has(file):
			result.append(file)
	return result


func _check(condition: bool, label: String) -> void:
	if not condition:
		_errors += 1
		printerr("GAGAL: " + label)

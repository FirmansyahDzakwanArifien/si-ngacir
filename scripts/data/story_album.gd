class_name StoryAlbum
extends RefCounted
## Daftar cutscene di Album Cerita, urut sesuai alur. Cutscene terbuka setelah pernah diputar
## (GameState.seen_stories).

const STORY_DIR := "res://resources/story/"


## Tiap entri: {"path": resource cutscene, "title": judul yang sudah diterjemahkan}.
static func entries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	result.append(_entry("opening", tr_text("Awal Cerita")))
	for day in range(1, 5):
		result.append(_entry("evening_%02d_good" % day, tr_text("Malam Hari %d · lancar") % day))
		result.append(_entry("evening_%02d_rough" % day, tr_text("Malam Hari %d · berat") % day))
		result.append(_entry("day_%02d" % (day + 1), tr_text("Pagi Hari %d") % (day + 1)))
	result.append(_entry("ending_success", tr_text("Ending: Lolos")))
	result.append(_entry("ending_bad", tr_text("Ending: Belum Cukup")))
	return result


static func unlocked_count() -> int:
	var count := 0
	for entry in entries():
		if GameState.is_story_seen(entry["path"]):
			count += 1
	return count


static func tr_text(text: String) -> String:
	return TranslationServer.translate(text)


static func _entry(file: String, title: String) -> Dictionary:
	return {"path": STORY_DIR + file + ".tres", "title": title}

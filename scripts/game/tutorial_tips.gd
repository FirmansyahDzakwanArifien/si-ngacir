class_name TutorialTips
extends RefCounted
## Petunjuk singkat yang muncul sekali, saat pemain pertama kali menemui sesuatu.
## Tips yang sudah tampil dicatat di profil (GameState.seen_tips).

const TIPS := {
	&"move": "Tekan W / panah atas (atau tap layar) untuk maju. Hindari kendaraan!",
	&"pickup": "Ambil paket dulu di kios penjemputan (ikon paket melayang), baru antar ke rumah pelanggan di ujung atas.",
	&"hit": "Aduh! Tiap tabrakan merusak paket. Kalau ikon paket di kiri atas habis, pengiriman gagal.",
	&"coin": "Ambil koin! +Rp1.000 untuk upah, dan masuk dompet untuk belanja di Toko Masbro.",
	&"powerup": "Power-up! Helm menahan 1 benturan, sepatu bikin langkah lebih cepat.",
	&"hole": "Ada lubang di aspal. Terperosok bikin paket rusak, jadi lewati saja.",
	&"river": "Sungai! Lompat ke atas rakit dan ikut arusnya. Jangan sampai tercebur.",
	&"checkpoint": "Ini Pos. Kalau paket hancur setelah ini, kamu bisa lanjut dari sini.",
	&"eta": "ETA hampir habis! Terlambat membuat upah dipotong per detik.",
	&"walker": "Kucing dan pejalan kaki tidak merusak paket, tapi menghalangi. Cari jalur lain.",
	&"rival": "Itu Bang Kilat, kurir rival! Dia ngebut, jangan berdiri di lane-nya.",
}

var _hud: GameHud
var _queue: Array[StringName] = []
var _showing := false


func _init(hud: GameHud) -> void:
	_hud = hud
	_hud.tip_finished.connect(_show_next)


## Minta tip ditampilkan (diabaikan bila sudah pernah tampil atau tips dimatikan).
func trigger(id: StringName) -> void:
	if not GameState.tips_enabled or id in GameState.seen_tips or id in _queue:
		return
	GameState.mark_tip_seen(id)
	_queue.append(id)
	if not _showing:
		_show_next()


func _show_next() -> void:
	_showing = not _queue.is_empty()
	if _showing:
		_hud.show_tip(TIPS[_queue.pop_front()])

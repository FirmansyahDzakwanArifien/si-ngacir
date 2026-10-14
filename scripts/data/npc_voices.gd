class_name NpcVoices
extends RefCounted
## Data suara NPC saat Masbro mendekat (dibaca NpcVoiceDirector).
##
## Satu entri per jenis NPC:
##   radius    jarak picu dalam PETAK (dikali ukuran petak oleh NpcVoiceDirector)
##   cooldown  jeda (detik, acak antara x dan y) sebelum NPC itu boleh bicara lagi;
##             NPC juga baru bicara lagi setelah Masbro menjauh keluar radius
##   priority  suara berprioritas lebih tinggi boleh memotong yang lebih rendah
##   chance    peluang bicara saat Masbro masuk radius (1.0 = selalu)
##   pitch     variasi nada acak per ucapan (0.05 = plus minus 5 persen)
##   lines     daftar [teks, nama_suara]. Teks memakai kunci terjemahan (teks Indonesia persis,
##             tambahkan padanan Inggrisnya di translations/strings.csv).
##             nama_suara = file di assets/audio/voice/ (atau assets/audio/sfx/); bila filenya
##             belum ada, NPC tetap menampilkan balon ucapan tanpa suara.
const PROFILES := {
	# Pelanggan di depan rumah. Hanya bicara selama Masbro membawa paket dan belum telat.
	&"customer": {
		"radius": 5.0,
		"cooldown": Vector2(20.0, 30.0),
		"priority": 3,
		"chance": 1.0,
		"pitch": 0.05,
		"lines": [
			["Sedikit lagi, Masbro!", &"customer_1"],
			["Itu dia kurirnya!", &"customer_2"],
			["Hati-hati, jangan sampai lecet ya!", &"customer_3"],
			["Yeay, paketku datang!", &"customer_1"],
		],
	},
	# Penjual di kios jemput. Hanya bicara sebelum Masbro mengambil paket.
	&"sender": {
		"radius": 4.0,
		"cooldown": Vector2(15.0, 25.0),
		"priority": 3,
		"chance": 1.0,
		"pitch": 0.04,
		"lines": [
			["Paketnya sudah siap, Mas!", &"sender_1"],
			["Sini, Mas! Jangan sampai lecet ya!", &"sender_2"],
			["Kurir baru, ya? Semangat!", &"sender_1"],
		],
	},
	# Pedagang bakso (gerobak di median).
	&"vendor": {
		"radius": 2.5,
		"cooldown": Vector2(10.0, 16.0),
		"priority": 2,
		"chance": 0.85,
		"pitch": 0.06,
		"lines": [
			["Bakso! Bakso!", &"vendor_1"],
			["Bakso panas, Mas! Mampir dulu!", &"vendor_2"],
			["Bakso urat, bakso telur!", &"vendor_3"],
		],
	},
	# Pejalan kaki di median.
	&"pedestrian": {
		"radius": 2.5,
		"cooldown": Vector2(12.0, 20.0),
		"priority": 1,
		"chance": 0.7,
		"pitch": 0.07,
		"lines": [
			["Eh, ada kurir lewat!", &"pedestrian_1"],
			["Semangat, Mas Kurir!", &"pedestrian_2"],
			["Wah, capybara jadi kurir?", &"pedestrian_3"],
			["Hati-hati di jalan, ya!", &"pedestrian_2"],
		],
	},
	# Kucing jalanan: hanya mengeong (meow.wav sudah ada di folder SFX).
	&"cat": {
		"radius": 2.0,
		"cooldown": Vector2(10.0, 16.0),
		"priority": 0,
		"chance": 0.6,
		"pitch": 0.12,
		"lines": [
			["Meong~", &"meow"],
			["Miaw!", &"meow"],
			["Prrr...", &"meow"],
		],
	},
}


## Pengaturan satu jenis NPC (kosong bila jenisnya tidak dikenal).
static func profile(kind: StringName) -> Dictionary:
	return PROFILES.get(kind, {})


## Semua nama suara yang dipakai data ini (dipakai pemeriksaan CI supaya tidak ada nama yatim).
static func voice_names() -> Array[StringName]:
	var names: Array[StringName] = []
	for kind: StringName in PROFILES:
		for line: Array in PROFILES[kind]["lines"]:
			if not line[1] in names:
				names.append(line[1])
	return names

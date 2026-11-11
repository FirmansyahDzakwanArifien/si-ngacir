# SI NGACIR — "Trobos Ajalah!"

Game arcade 2D tentang Masbro, capybara pemilik Kedai Chill yang harus melunasi tunggakan sewa kedainya dengan lolos masa percobaan lima hari sebagai kurir jalan kaki Ngacir Express. Seberangi lalu lintas, kejar Timer ETA, dan jaga paket supaya upah tidak terpotong denda.

📖 **Manual pemain** (storyline, cara main, kontrol, tips): [`docs/MANUAL.md`](docs/MANUAL.md)

🌐 **Wiki publik** (Indonesia & English): https://wiki-si-ngacir.cyphera.my.id — sumbernya di folder [`wiki/`](wiki/), lihat bagian [Wiki](#wiki).

## Teknologi

* Godot Engine 4.3 Stable (GDScript)
* Renderer: Compatibility (siap export Web/HTML5)

## Menjalankan

1. Buka Godot 4.3 → **Import** → pilih `project.godot` di folder ini.
2. Tekan **F5**.

| Tombol | Fungsi |
| --- | --- |
| W A S D / panah | Gerak |
| Esc / P | Pause |
| M | Bisukan / nyalakan semua suara |
| Enter | Pilih tombol di panel |
| Layar sentuh | Swipe kiri / kanan / atas (maju), tap = maju, swipe bawah = mundur, tombol II = pause |

## Status (v0.15)

* [x] Gerak grid, lane jalan/trotoar/median, kendaraan (motor, mobil, truk)
* [x] Kondisi paket menggantikan nyawa (tabrakan → damage → paket hancur)
* [x] Timer ETA, rating bintang, komentar pelanggan
* [x] Upah harian: upah dasar + bonus ETA − denda kerusakan − potongan telat
* [x] 5 hari masa percobaan: Gorengan Hangat, Kue Ultah & Akuarium Cupang, Es Krim, Laptop VIP, Patung Kristal Jeruk
* [x] Map prosedural yang panjang & scroll vertikal: rute berbeda setiap main, makin jauh makin sulit
* [x] Rintangan statis (cone, pembatas, lubang), koin, power-up helm & sepatu
* [x] Sungai & rakit (mulai Hari 2)
* [x] Pos (checkpoint): lanjut dari Pos dengan denda bila paket hancur
* [x] NPC pelanggan dengan balon ucapan dan reaksi (sapaan diatur di `customer_greeting`)
* [x] NPC jalanan: pengemudi berklakson, pejalan kaki, pedagang bakso, Kuro (kurir rival CepatKilat Corp)
* [x] Toko Masbro: dompet koin permanen, aksesori topi/kacamata/tas (`scripts/data/cosmetics.gd`)
* [x] Bahasa Indonesia & Inggris (`translations/strings.csv`, pilih di Pengaturan menu utama)
* [x] Lokasi berbeda tiap hari: perumahan, pasar, sekolah, pusat kota, kawasan bisnis (`resources/cities/`)
* [x] Tips tutorial kontekstual (teks di `scripts/game/tutorial_tips.gd`), Hari 2 selalu ada sungai
* [x] Tabungan antar hari (upah terbaik per hari) dan layar rekap/ending
* [x] Save system: progres hari & tabungan tersimpan otomatis, menu Lanjutkan / Mulai Baru
* [x] Target cerita dan aturan ending: tunggakan sewa Kedai Chill (`RENT_DUE`) dan `SHORTFALL_RULE` (lihat di bawah)
* [x] Side conflict: kucing jalanan, hujan (jarak pandang & licin), Kuro dan kulit pisang, Pak Buldog (mode panik), Nana (pelanggan tidak sabaran), Pak Wali Kota (pelanggan teliti)
* [x] Sistem audio (BGM + SFX, suara placeholder) dan menu Pengaturan (volume, layar penuh)
* [x] Siap sprite: game otomatis memakai gambar di `assets/sprites/` (spesifikasi di `docs/ASSET_SPEC.md`)
* [x] Cutscene cerita bergaya dialog (potret tokoh): pembuka, malam setelah Hari 1–4, pagi sebelum Hari 2–5, dan ending (naskah draf)
* [x] Export Web (HTML5, template ramping + layar loading bertema), Windows, dan Android (APK)
* [x] Aksesibilitas: ukuran teks, filter buta warna, kurangi efek gerak
* [x] Pause otomatis saat tab/aplikasi ditinggal, getar HP saat menabrak
* [x] Press kit itch.io: cover, screenshot ID/EN, GIF (`docs/press/`)
* [x] Kontrol sentuh swipe (kiri/kanan/maju, tap = maju) dan layar responsif: HP potret (UI diperbesar, kamera geser samping), lanskap, layar lebar (`scripts/autoload/screen.gd`)
* [x] Tampilan flat kawaii: sprite, ilustrasi cutscene, UI, animasi & efek (bawaan, bisa diganti tim Illustrator)
* [x] Gaya ala poster (v0.9): shading gradasi di semua sprite, filter cahaya `Sunlight`, bayangan awan, tiang listrik dan kabel, papan "LEVEL NEXT", billboard depot, lampu kendaraan saat hujan, Masbro dengan ransel dan kacamata piksel. Rencana 3D: `docs/KONSEP_3D.md`
* [x] Tampilan 3D (beta) di web, Windows, dan Android (Pengaturan → Tampilan 3D): lapisan tampilan `scripts/game3d/` di atas logika 2D yang sama. Skema, skenario, dan pengembangan: `docs/KONSEP_3D.md` bagian 11
* [x] Ambil paket dulu: Masbro berangkat tanpa paket, mengambil paket di kios pengirim (titik jemput acak di tengah map, `MapGenerator.pick_pickup`), lalu mengantarnya. Map panjang: 12–16 blok jalan (±45–90 baris), dengan Pos setiap 3–4 blok
* [x] Efek benturan ala komik (`scripts/game/effects.gd`): BRAK! + Masbro berputar + hit-stop + kilat putih saat tertabrak, BYUR! + riak + gelembung saat tercebur, GEDEBUK! di lubang, TENG! saat helm pecah, KRAK! + asap saat paket hancur, cipratan saat tergelincir
* [x] Album Cerita (tonton ulang cutscene), ringkasan "Sebelumnya…" saat Lanjutkan, mode Auto di cutscene
* [x] Perbaikan playtest (v0.13): cutscene bisa diketuk di mana saja di HP, satu tekan = satu langkah di keyboard, koin langsung masuk dompet (penghitung di bar atas), batas lane di sungai, Main Lagi setelah lulus, dan suara di build web
* [x] Rakit per panel petak, perahu kayu, bajaj, angkot, dan bus kota (v0.14)
* [x] Cerita baru "Kedai Chill" (v0.15): tokoh dan potret baru (Bos Koko, Nana, Kuro, Pak Buldog, Pemilik Lahan, Pak Wali Kota), paket baru, earpiece Bos Koko, kulit pisang Kuro, mode panik Pak Buldog, aksesori bawaan Jeruk Kepala
* [x] Naskah final dari tim Writer Story, diadaptasi ke cara main menyeberang jalan: [`docs/STORY.md`](docs/STORY.md)

## Struktur

```text
scenes/main.tscn            Layar judul
scenes/ending.tscn          Rekap masa percobaan dan ending
scenes/cutscene.tscn        Pemutar cutscene cerita
scenes/album.tscn           Album Cerita (tonton ulang cutscene)
scenes/game/level.tscn      Satu hari pengiriman
scripts/autoload/game_state.gd   Hari aktif, tabungan, input map, format rupiah
scripts/data/                PackageData, LaneData, DayData (Resource)
scripts/game/                Level, Player (Masbro), Vehicle, DeliveryReport, MapGenerator
scripts/ui/hud.gd            HUD dan panel intro/pause/hasil/gagal
resources/packages/*.tres    Data paket (daya tahan, kerapuhan, kecepatan langkah)
resources/story/*.tres       Naskah cutscene (StoryData)
resources/days/day_0N.tres   Data hari 1–5: paket, pelanggan, ETA, upah, susunan lane
```

## Map prosedural

Setiap hari punya **MapParams** (grup *Peta* → `map` di `day_0N.tres`). Map dirakit ulang setiap kali hari dimulai: gudang di bawah, beberapa **blok jalan** dipisah median aman, rumah pelanggan di atas. Kamera mengikuti Masbro dan bar atas menampilkan kemajuan rute.

| Properti | Arti |
| --- | --- |
| `road_blocks` | Jumlah blok jalan (makin banyak = rute makin panjang) |
| `lanes_per_block` | Jumlah lane per blok (min, max) |
| `safe_rows_between` | Baris median di antara blok (min, max) |
| `speed_range`, `speed_ramp` | Kecepatan kendaraan; blok terakhir dikali `speed_ramp` |
| `vehicles_per_lane`, `vehicle_weights` | Kepadatan dan campuran motor/mobil/truk (celah minimal 3 petak dijamin) |
| `eta_per_row` | Target waktu per baris; ETA = jumlah baris × nilai ini |
| `fixed_seed` | 0 = acak setiap main; angka lain = map selalu sama (berguna untuk playtest) |
| `blockers_per_safe_row` | Cone/pembatas per baris median (min, max) |
| `checkpoint_every`, `checkpoint_penalty` | Pos setiap N blok (0 = tanpa pos) dan denda ganti paket |
| `min_rivers` | Jumlah blok sungai yang dijamin ada |
| `river_chance`, `river_lanes`, `raft_speed` | Peluang blok menjadi sungai, jumlah lane air, kecepatan arus |
| `hole_chance`, `coin_chance`, `powerup_chance` | Peluang lubang per lane, deretan koin per baris, dan power-up per blok |

Untuk map tetap buatan tangan, kosongkan `map` dan isi `lanes` (urut dari atas/rumah ke bawah/gudang).

## Menambah hari baru

1. Duplikat salah satu `resources/days/day_0N.tres`, lalu edit di Inspector: `day`, `package`, `customer_name`, pengirim (`sender_name`, `sender_line` di grup **Penjemputan**), upah, dan `map`. Hari dengan `map` otomatis punya titik jemput; ETA ditambah waktu mampir ke kios.
2. Tambahkan path-nya ke `DAYS` di `scripts/autoload/game_state.gd`.
3. Untuk mengetes satu hari langsung, buka `level.tscn`, isi properti `day`, lalu **F6**.

## Audio

`AudioManager` mencari file berdasarkan nama di `assets/audio/music/` dan `assets/audio/sfx/`. Semua file saat ini adalah suara placeholder sintetis — tim Audio cukup mengganti file dengan **nama yang sama**, tanpa mengubah kode. Musik otomatis di-loop dan berganti lagu dengan fade singkat.

Bus **Music**, **SFX**, dan **Voice** (suara NPC) didefinisikan di `default_bus_layout.tres`. Jangan membuat bus lewat kode saat game berjalan: di build web Godot 4.3 hal itu menyambung bus secara melingkar sehingga browser membisukan semua suara (CI memeriksa layout ini).

Pakai format **`.wav`**. Musik dikompres QOA saat import (`compress/mode=2` di file `.import`), jadi tetap kecil. Build web ramping tidak menyertakan dekoder `.ogg` dan `.mp3`, jadi kedua format itu tidak berbunyi di browser.

| Nama | Kapan diputar |
| --- | --- |
| `music/menu` | Menu utama, Toko Masbro, Album Cerita, dan cutscene santai |
| `music/gameplay_ceria` | Selama hari pengiriman siang (Hari 1–3). Bila file ini tidak ada, game memakai `music/gameplay` |
| `music/gameplay_malam` | Selama pengiriman hujan/malam (Hari 4–5) dan cutscene malam di Kedai Chill (`kedai_night`) |
| `music/ending` | Layar Rekap / Ending dan adegan perayaan di `ending_success` |
| `music/endless` | Saat bermain ulang di mode Shift Malam (Main Lagi setelah lulus masa percobaan) |
| `music/sedih` | Cutscene sedih: Masbro sedih, latar senja (`sunset`) di ending |
| `music/tegang` | Cutscene tegang: Kuro menyombong atau kaget, Pemilik Lahan marah, Pak Buldog marah |
| `music/gameplay` | Cadangan musik hari pengiriman bila `gameplay_ceria` tidak ada |
| `sfx/step` | Masbro melangkah |
| `sfx/pickup` | Mulai hari (ambil paket) |
| `sfx/hit` | Tertabrak |
| `sfx/package_damage` | Paket rusak (boleh lebay/lucu) |
| `sfx/fail` | Paket hancur |
| `sfx/delivery` | Paket diambil di kios & paket sampai ke pelanggan |
| `sfx/coin` | Memungut koin di jalan |
| `sfx/powerup` | Memungut power-up helm atau sepatu |
| `sfx/star` | Tiap bintang rating muncul |
| `sfx/meow` | Jalan terhalang kucing |
| `sfx/slip` | Masbro tergelincir (aspal basah, mode panik, atau kulit pisang) |
| `sfx/splash` | Tercebur ke sungai |
| `sfx/horn` | Klakson pengemudi & Kuro |
| `sfx/bark` | Gonggongan Pak Buldog |
| `sfx/click` | Semua tombol |
| `sfx/chime_sad` | Saat cutscene masuk ke tema sedih |
| `sfx/sting_tegang` | Saat cutscene masuk ke tema tegang |

### Suara NPC saat Masbro mendekat

`NpcVoiceDirector` (`scripts/game/npc_voice_director.gd`) memicu dialog NPC **sekali saat Masbro masuk radius** (dalam petak), lalu NPC itu baru bicara lagi setelah Masbro menjauh dan cooldown selesai. Hanya satu suara NPC berbunyi pada satu waktu (prioritas: pelanggan dan kios jemput > pedagang bakso > pejalan kaki > kucing, ditambah jeda 2 detik antar suara). Selama NPC bicara, bus **Music** turun 8 dB lalu naik perlahan (*ducking*).

Semua dialog, radius, cooldown, prioritas, dan peluang ada di satu tempat: `scripts/data/npc_voices.gd`. Menambah kalimat = menambah satu baris `["teks", &"nama_suara"]` dan padanan Inggrisnya di `translations/strings.csv`. Bila file suaranya belum ada, NPC tetap menampilkan balon ucapan tanpa suara.

| Nama (`assets/audio/voice/`) | Dipakai oleh |
| --- | --- |
| `customer_1`, `customer_2`, `customer_3` | Pelanggan di depan rumah (saat Masbro membawa paket) |
| `sender_1`, `sender_2` | Penjual di kios jemput (sebelum paket diambil) |
| `vendor_1`, `vendor_2`, `vendor_3` | Pedagang bakso |
| `pedestrian_1`, `pedestrian_2`, `pedestrian_3` | Pejalan kaki |
| `sfx/meow` | Kucing (memakai ulang SFX yang sudah ada) |

File di folder `voice/` saat ini adalah **celoteh placeholder** buatan skrip (`python3 tools/generate_audio.py`, tanpa sampel pihak ketiga), bukan dialog nyata. Untuk rekaman asli, ganti file dengan nama yang sama (durasi ideal 0,4–1,5 detik; satu file per baris dialog bila ingin tiap kalimat punya suara sendiri, lalu ubah nama suaranya di `npc_voices.gd`).

Pengaturan pemain: slider **Suara NPC** dan kotak **Bisukan semua suara** di Pengaturan, atau tombol **M** kapan saja. Status mute dan volume tersimpan di `user://settings.cfg`.

Tes: `godot --headless --path . --script .github/godot/check_voice.gd` menguji logika radius, cooldown, prioritas, dan batas bicara serentak. `python3 tools/generate_audio.py --check` memeriksa level, durasi, dan sambungan loop aset buatan skrip.

## Side conflict per hari

Diatur di grup **Side Conflict** pada tiap `day_0N.tres`:

| Properti | Efek |
| --- | --- |
| `cat_count` | Jumlah kucing jalanan bersamaan. Kucing tidak merusak paket, tapi menghalangi petak |
| `pedestrian_count` | Jumlah pejalan kaki di median bersamaan |
| `rival_interval` | Kuro (kurir rival) melesat di lane jalan setiap sekian detik (0 = tidak muncul) |
| `peel_chance` | Peluang Kuro membuang kulit pisang di lane yang ia lewati. Menginjaknya membuat Masbro tergelincir satu petak |
| `buldog_count` | Jumlah Pak Buldog di median. Bila Masbro lewat dalam jarak 1 petak, ia menggonggong: layar bergetar dan Masbro panik (langkah lebih cepat selama 3 detik, tapi 30% peluang tergelincir di aspal) |
| `rainy`, `slip_chance`, `visibility_tiles` | Hujan: gelap di luar jarak pandang, peluang tergelincir di aspal |
| `strict_customer` | Pelanggan teliti (Pak Wali Kota): denda kerusakan 2x, maks 3 bintang bila paket rusak |
| `impatient_customer` | Pelanggan tidak sabaran (Nana): potongan telat 2x, maks 3 bintang bila telat |
| `perfect_tip` | Tip dari pelanggan teliti / tidak sabaran bila paket utuh dan tepat waktu |
| `customer_hurry_line`, `customer_late_line` | Balon ucapan pelanggan saat sisa ETA tinggal 10 detik, dan saat Masbro sudah telat |

| Hari | Kucing | Hujan | Kuro | Pak Buldog | Pelanggan khusus |
| --- | --- | --- | --- | --- | --- |
| 1 | – | – | – | – | Nana, tidak sabaran (tip Rp10.000) |
| 2 | 1 | – | Ya, + kulit pisang | – | – |
| 3 | 1 | – | Ya, + kulit pisang | 1 | – |
| 4 | 1 | Ya | Ya, + kulit pisang | 1 | Nana, tidak sabaran (tip Rp15.000) |
| 5 | 2 | Ya (lebih ringan) | Ya, paling sering | 1 | Pak Wali Kota, teliti (tip Rp25.000) |

Bos Koko berteriak lewat **earpiece** (banner di bawah bar atas) saat kondisi paket ≤ 34% atau sisa ETA ≤ 15 detik, masing-masing sekali per hari. Kalimatnya ada di konstanta `KOKO_*` di `scripts/game/level.gd`.

## Cerita (untuk Writer Story)

Naskah cutscene ada di `resources/story/` dan bisa diedit langsung di Inspector Godot. Naskah saat ini diadaptasi dari dokumen cerita tim Writer Story: Masbro harus melunasi tunggakan sewa Kedai Chill dalam lima hari sebagai kurir masa percobaan, dibimbing Bos Koko, diganggu Kuro dari CepatKilat Corp, dan menutup setiap hari dengan malam di Kedai Chill. Ringkasan cerita, tokoh, tabel per hari, dan penyesuaian dari dokumen asli ada di [`docs/STORY.md`](docs/STORY.md).

Setiap cutscene punya tiga daftar dengan urutan sama (satu elemen per halaman):

| Properti | Isi |
| --- | --- |
| `pages` | Teks halaman. Token `{saved}`, `{target}`, `{left}` diganti tabungan, tunggakan sewa, dan kekurangannya |
| `speakers` | `tokoh:ekspresi` (misalnya `koko:marah`), atau kosong untuk narasi. Tokoh: `masbro`, `koko`, `nana`, `kuro`, `buldog`, `pemilik`, `walikota` (`scripts/data/speakers.gd`) |
| `images` | Ilustrasi di `assets/story/`. Kosong = tetap memakai gambar halaman sebelumnya |

| File | Kapan diputar |
| --- | --- |
| `opening.tres` | Setelah "Mulai Baru", sebelum Hari 1 |
| `evening_0N_good.tres` / `evening_0N_rough.tres` | Malam di Kedai Chill setelah Hari N (1–4): versi *good* bila kondisi paket ≥ 70%, *rough* bila lebih rendah. Dihubungkan lewat `evening_good` / `evening_rough` di `day_0N.tres` |
| `day_02.tres` … `day_05.tres` | Pagi sebelum hari tersebut (properti `story` di `day_0N.tres`), diputar langsung setelah cutscene malam |
| `ending_success.tres` | Setelah Hari 5 bila tabungan cukup: sewa lunas, Masbro jadi kurir tetap, Kedai Chill jadi tempat istirahat para kurir kota |
| `ending_bad.tres` | Setelah Hari 5 bila tabungan kurang dan `SHORTFALL_RULE = BAD_ENDING`: Kedai Chill disegel sampai sisa sewa lunas |

Ilustrasi dan potret bisa diganti tim Illustrator, lihat `docs/ASSET_SPEC.md`. Setiap mengubah teks naskah, perbarui juga kuncinya di `translations/strings.csv`.

Musik cutscene dipilih otomatis per halaman dari `speakers` dan `images` (aturannya di `MOOD_MUSIC` dan `SAD_IMAGES`, `scripts/data/speakers.gd`): Masbro sedih atau latar senja memutar tema sedih (`music/sedih`); Kuro yang sombong atau kaget, Pemilik Lahan marah, dan Pak Buldog marah memutar tema tegang (`music/tegang`); tokoh lain kembali ke musik santai. Narasi dan dialog Masbro meneruskan musik sebelumnya.

Kontrol cutscene: Enter / klik untuk lanjut, Esc atau tombol **Lewati** untuk melewati, tombol **Auto** untuk maju sendiri setelah teks selesai (pilihan tersimpan di profil).

**Album Cerita** (`scripts/data/story_album.gd`) mendaftar cutscene sesuai urutan cerita; tiap cutscene terbuka setelah pernah diputar (`GameState.seen_stories`, disimpan di profil sehingga tidak hilang saat Mulai Baru). Menambah cutscene baru: daftarkan juga di `StoryAlbum.entries()`.

Ringkasan **Sebelumnya…** diputar saat menekan Lanjutkan: satu kalimat per hari (`GameState.RECAPS`), tabungan saat ini, lalu ajakan Masbro.

## Bahasa (terjemahan)

Teks game ditulis dalam bahasa Indonesia; terjemahan Inggris ada di **`translations/strings.csv`** (kolom `keys` = teks Indonesia persis, kolom `en` = Inggris). Bisa diedit dengan Excel / Google Sheets / teks biasa.

* Mengubah teks Indonesia (di kode atau `.tres`) → ubah juga kunci yang sama di CSV, kalau tidak teks itu tampil dalam bahasa Indonesia saat mode Inggris.
* Teks dengan `%s` / `%d` harus mempertahankan penanda yang sama di terjemahannya.
* Menambah bahasa lain: tambahkan kolom baru (misalnya `ja`), lalu daftarkan file `.translation`-nya di Project Settings → Localization.

Bahasa bawaan mengikuti bahasa perangkat (Indonesia bila perangkat berbahasa Indonesia, selain itu Inggris) dan bisa diganti di **Pengaturan** dari menu utama.

## Placeholder untuk Writer Story

Di `scripts/autoload/game_state.gd`:

* `RENT_DUE` (dulu `MEDICAL_COST`): tunggakan sewa Kedai Chill, sekarang Rp350.000. Upah maksimal 5 hari Rp530.000 (upah dasar + bonus tepat waktu + tip Nana dan Pak Wali Kota, belum termasuk koin)
* `SHORTFALL_RULE` — kalau tabungan kurang setelah Hari 5:
  * `REPLAY_DAYS` (aktif): Pemilik Lahan masih memberi waktu; pemain boleh mengulang hari mana pun dari layar rekap
  * `BAD_ENDING`: masa percobaan langsung berakhir dengan ending gagal (Kedai Chill disegel)

Teks ending ada di `scripts/ending.gd`.

## Build

Preset export sudah disiapkan di `export_presets.cfg`. Pertama kali, install export template: **Editor → Manage Export Templates → Download and Install** (Godot 4.3).

| Target | Cara | Hasil |
| --- | --- | --- |
| Web (itch.io) | Project → Export → **Web** → Export Project | `builds/web/index.html` (+ .js, .wasm, .pck) |
| Windows | Project → Export → **Windows Desktop** → Export Project | `builds/windows/SiNgacir.exe` (satu file, PCK tertanam) |

Lewat terminal:

```bash
godot --headless --export-release "Web" builds/web/index.html
godot --headless --export-release "Windows Desktop" builds/windows/SiNgacir.exe
```

**Upload ke itch.io:** zip isi folder `builds/web/` (dengan `index.html` di root zip), upload sebagai *HTML*, centang "This file will be played in the browser", ukuran viewport 720 × 672. Build web memakai mode tanpa thread, jadi tidak perlu pengaturan SharedArrayBuffer.

Catatan: di browser, suara baru berbunyi setelah klik/tombol pertama (aturan browser). Mencoba build web secara lokal harus lewat server (misal `python -m http.server` di folder `builds/web`), tidak bisa dibuka langsung dari file.

## Build otomatis (GitHub Actions)

Workflow `.github/workflows/build.yml`:

| Pemicu | Yang terjadi |
| --- | --- |
| Pull Request ke `dev` / `main` | Import + export + cek isi build; build bisa diunduh di tab **Actions → Artifacts** (disimpan 5 hari). Push baru ke PR yang sama membatalkan run yang lama |
| Push tag `v*` (contoh `v0.2.0`) | **GitHub Release** otomatis berisi `SiNgacir-web.zip`, `SiNgacir-windows.zip`, `SiNgacir-android.apk`, dan manual, lalu upload ke itch.io (+ GitHub Pages bila diaktifkan) |
| Tombol **Run workflow** di tab Actions | Build manual kapan saja; centang input `itch` untuk mengunggah tag yang dipilih ke itch.io |

Push ke `main` tidak membangun ulang game: isinya sama dengan PR yang sudah lolos cek, dan rilis dibuat lewat tag. Yang jalan hanya job **warm-cache** (beberapa detik bila cache ada): memastikan Godot, export template, dan template web ramping tersimpan di cache scope `main`, karena cache dari PR atau tag tidak bisa dipakai ref lain. Tanpa ini setiap PR dan tag membangun ulang template web (±30 menit). Perubahan yang hanya menyentuh dokumen (`wiki/**`, `docs/**` kecuali `docs/MANUAL.md`, `*.md` di root, `uts/**`) tidak memicu build. Setiap job punya batas waktu (`timeout-minutes`) supaya run yang macet tidak menghabiskan menit Actions.

Build Web memakai **template Godot ramping** (modul yang tidak dipakai dibuang, inti 3D tetap ada untuk Tampilan 3D, lihat `.github/godot/web_template.py`). Template dibangun sekali (sekitar 30 menit) lalu disimpan di cache Actions; mengubah file profil itu akan membangunnya ulang. Ukuran file web tercatat di ringkasan setiap run.

Setelah export, CI membuka build hasilnya (`.github/godot/check_pack.gd`) dan gagal bila ada cutscene kosong, potret hilang, atau musik tidak ikut. Resource teks (`.tres`) diekspor apa adanya (`editor/export/convert_text_resources_to_binary=false`): konversi ke biner di Godot 4.3 mengosongkan teks cutscene (`PackedStringArray` di `StoryData`).

Membuat rilis baru (setelah `dev` digabung ke `main`):

```bash
git checkout main && git pull
git tag v0.2.0
git push origin v0.2.0
```

Deploy opsional (Settings → Secrets and variables → Actions):

| Tujuan | Atur | Catatan |
| --- | --- | --- |
| **itch.io** (link main di browser) | Variable `ITCH_GAME` = `namauser/si-ngacir`, Secret `BUTLER_API_KEY` | API key dari itch.io → Settings → API keys. Jalan saat push tag; channel `html5`, `windows`, `android` |
| **GitHub Pages** | Variable `DEPLOY_PAGES` = `true`, Settings → Pages → Source: *GitHub Actions* | Repo private butuh GitHub Pro/Team; repo public gratis |
| **Keystore Android permanen** | Secret `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` | Lihat di bawah. Tanpa ini APK ditandatangani keystore sementara |

Upload ulang rilis yang sudah ada ke itch.io (misalnya setelah secret baru diisi): `gh workflow run build.yml --ref v0.5.0 -f itch=true`, atau tombol **Run workflow** dengan tag tersebut dan centang `itch`.

### Keystore Android

Tanpa keystore permanen, setiap rilis APK ditandatangani kunci yang berbeda, jadi pemain harus menghapus versi lama sebelum memasang versi baru. Untuk update yang mulus, buat keystore sekali (butuh Java / Android Studio) lalu simpan sebagai secret:

```bash
keytool -genkeypair -v -keystore singacir.keystore -alias singacir -keyalg RSA -keysize 2048 -validity 10000
base64 -w0 singacir.keystore > keystore.txt   # Windows PowerShell: [Convert]::ToBase64String([IO.File]::ReadAllBytes("singacir.keystore")) > keystore.txt
```

Isi di GitHub → Settings → Secrets and variables → Actions: `ANDROID_KEYSTORE_BASE64` = isi `keystore.txt`, `ANDROID_KEYSTORE_PASSWORD` = password keystore, `ANDROID_KEY_ALIAS` = `singacir`. **Simpan file keystore dan password-nya baik-baik**: kalau hilang, update APK berikutnya tidak bisa menimpa versi lama.

## Wiki

Wiki publik dibangun dengan [Astro Starlight](https://starlight.astro.build) dari folder `wiki/` dan di-hosting di **Cloudflare Pages**, jadi repo ini tetap private. Hanya isi `wiki/` yang dipublikasikan.

| Isi | Lokasi |
| --- | --- |
| Halaman Indonesia | `wiki/src/content/docs/` |
| Halaman Inggris | `wiki/src/content/docs/en/` (nama file sama dengan versi Indonesia) |
| Menu samping | `sidebar` di `wiki/astro.config.mjs` |
| Gambar | `wiki/public/img/` (salinan dari `assets/`) dan `wiki/src/assets/press/` |

```bash
cd wiki
npm install
npm run dev      # pratinjau di http://localhost:4321
npm run build    # hasil di wiki/dist
```

Setiap merge ke `main` otomatis tayang; Pull Request ke `dev` mendapat link pratinjau dari Cloudflare. `wiki/.gdignore` membuat Godot mengabaikan folder ini, dan perubahan yang hanya menyentuh `wiki/` tidak memicu build game.

Pengaturan proyek Cloudflare Pages: *Framework preset* Astro, *Root directory* `wiki`, *Build command* `npm run build`, *Build output* `dist`, *Production branch* `main`, *Build watch paths* include `wiki/*`. Custom domain: `wiki-si-ngacir.cyphera.my.id`.

Saat menambah fitur game, perbarui juga halaman wiki yang terkait (minimal **Riwayat Versi**).

## Workflow Git

| Branch | Fungsi |
| --- | --- |
| `main` | Versi stabil / rilis. Hanya menerima merge dari `dev`. |
| `dev` | Integrasi. Semua fitur digabung di sini lewat Pull Request. |
| `feat/<nama>` | Satu fitur per branch, dibuat dari `dev`. |
| `fix/<nama>` | Perbaikan bug, dibuat dari `dev`. |

```bash
git checkout dev && git pull
git checkout -b feat/nama-fitur
# ... kerjakan, lalu:
git add -A
git commit -m "feat(scope): deskripsi singkat"
git push -u origin feat/nama-fitur
# Buka Pull Request ke dev, minimal 1 reviewer, lalu merge.
```

Grafis saat ini masih placeholder. Tim Illustrator cukup menaruh PNG sesuai `docs/ASSET_SPEC.md` di `assets/sprites/`; game otomatis memakainya.

# SI NGACIR — "Trobos Ajalah!"

Game arcade 2D tentang Masbro, capybara yang harus lolos masa percobaan lima hari sebagai kurir Ngacir Express demi biaya pengobatan adiknya. Seberangi lalu lintas, kejar Timer ETA, dan jaga paket supaya upah tidak terpotong denda.

📖 **Manual pemain** (storyline, cara main, kontrol, tips): [`docs/MANUAL.md`](docs/MANUAL.md)

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
| Enter | Pilih tombol di panel |
| Layar sentuh | Swipe kiri / kanan / atas (maju), tap = maju, swipe bawah = mundur, tombol II = pause |

## Status (v0.6)

* [x] Gerak grid, lane jalan/trotoar/median, kendaraan (motor, mobil, truk)
* [x] Kondisi paket menggantikan nyawa (tabrakan → damage → paket hancur)
* [x] Timer ETA, rating bintang, komentar pelanggan
* [x] Upah harian: upah dasar + bonus ETA − denda kerusakan − potongan telat
* [x] 5 hari masa percobaan: Bantal, Galon Air, Telur, Barang Sensitif, Paket VIP
* [x] Map prosedural yang panjang & scroll vertikal: rute berbeda setiap main, makin jauh makin sulit
* [x] Rintangan statis (cone, pembatas, lubang), koin, power-up helm & sepatu
* [x] Sungai & rakit (mulai Hari 2)
* [x] Pos (checkpoint): lanjut dari Pos dengan denda bila paket hancur
* [x] NPC pelanggan dengan balon ucapan dan reaksi (sapaan diatur di `customer_greeting`)
* [x] NPC jalanan: pengemudi berklakson, pejalan kaki, pedagang bakso, Bang Kilat (kurir rival)
* [x] Toko Masbro: dompet koin permanen, aksesori topi/kacamata/tas (`scripts/data/cosmetics.gd`)
* [x] Tips tutorial kontekstual (teks di `scripts/game/tutorial_tips.gd`), Hari 2 selalu ada sungai
* [x] Tabungan antar hari (upah terbaik per hari) dan layar rekap/ending
* [x] Save system: progres hari & tabungan tersimpan otomatis, menu Lanjutkan / Mulai Baru
* [ ] Keputusan final Writer Story: biaya pengobatan & aturan ending (lihat di bawah)
* [x] Side conflict: kucing jalanan, hujan (jarak pandang & licin), Pak Ojan (pelanggan perfeksionis)
* [x] Sistem audio (BGM + SFX, suara placeholder) dan menu Pengaturan (volume, layar penuh)
* [x] Siap sprite: game otomatis memakai gambar di `assets/sprites/` (spesifikasi di `docs/ASSET_SPEC.md`)
* [x] Cutscene cerita: pembuka, sebelum Hari 2–5, dan ending (naskah draf)
* [x] Export Web (HTML5) dan Windows
* [x] Kontrol sentuh swipe (kiri/kanan/maju, tap = maju) dan layar responsif: HP potret (UI diperbesar, kamera geser samping), lanskap, layar lebar (`scripts/autoload/screen.gd`)
* [x] Tampilan flat kawaii: sprite, ilustrasi cutscene, UI, animasi & efek (bawaan, bisa diganti tim Illustrator)
* [ ] Naskah final dari tim Writer Story

## Struktur

```text
scenes/main.tscn            Layar judul
scenes/ending.tscn          Rekap masa percobaan dan ending
scenes/cutscene.tscn        Pemutar cutscene cerita
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

1. Duplikat salah satu `resources/days/day_0N.tres`, lalu edit di Inspector: `day`, `package`, `customer_name`, upah, dan `map`.
2. Tambahkan path-nya ke `DAYS` di `scripts/autoload/game_state.gd`.
3. Untuk mengetes satu hari langsung, buka `level.tscn`, isi properti `day`, lalu **F6**.

## Audio

`AudioManager` mencari file berdasarkan nama di `assets/audio/music/` dan `assets/audio/sfx/` (`.ogg`, `.wav`, atau `.mp3`). Semua file saat ini adalah suara placeholder sintetis — tim Audio cukup mengganti file dengan **nama yang sama**, tanpa mengubah kode. Musik otomatis di-loop.

| Nama | Kapan diputar |
| --- | --- |
| `music/menu` | Menu utama dan rekap |
| `music/gameplay` | Selama hari pengiriman |
| `sfx/step` | Masbro melangkah |
| `sfx/pickup` | Mulai hari (ambil paket) |
| `sfx/hit` | Tertabrak |
| `sfx/package_damage` | Paket rusak (boleh lebay/lucu) |
| `sfx/fail` | Paket hancur |
| `sfx/delivery` | Paket sampai |
| `sfx/star` | Tiap bintang rating muncul |
| `sfx/meow` | Jalan terhalang kucing |
| `sfx/slip` | Masbro tergelincir saat hujan |
| `sfx/splash` | Tercebur ke sungai |
| `sfx/horn` | Klakson pengemudi & Bang Kilat |
| `sfx/click` | Semua tombol |

## Side conflict per hari

Diatur di grup **Side Conflict** pada tiap `day_0N.tres`:

| Properti | Efek |
| --- | --- |
| `cat_count` | Jumlah kucing jalanan bersamaan. Kucing tidak merusak paket, tapi menghalangi petak |
| `rainy`, `slip_chance`, `visibility_tiles` | Hujan: gelap di luar jarak pandang, peluang tergelincir di aspal |
| `strict_customer`, `perfect_tip` | Pelanggan perfeksionis: denda kerusakan 2x, maks 3 bintang bila paket rusak, tip bila sempurna |

| Hari | Kucing | Hujan | Pelanggan perfeksionis |
| --- | --- | --- | --- |
| 1 | – | – | – |
| 2 | 1 | – | – |
| 3 | 1 | – | Pak Ojan (tip Rp25.000) |
| 4 | 1 | Ya | – |
| 5 | 2 | Ya (lebih ringan) | – |

## Cerita (untuk Writer Story)

Naskah cutscene ada di `resources/story/` dan bisa diedit langsung di Inspector Godot (properti `pages`, satu halaman per elemen). Naskah saat ini adalah **draf** yang disusun dari storyline Pixar Method.

| File | Kapan diputar |
| --- | --- |
| `opening.tres` | Setelah "Mulai Baru", sebelum Hari 1 |
| `day_02.tres` … `day_05.tres` | Sebelum hari tersebut (dihubungkan lewat properti `story` di `day_0N.tres`) |
| `ending_success.tres` | Setelah Hari 5 bila tabungan cukup |
| `ending_bad.tres` | Setelah Hari 5 bila tabungan kurang dan `SHORTFALL_RULE = BAD_ENDING` |

Ilustrasi per halaman ada di `assets/story/` (SVG bawaan: `home`, `sick`, `office`, `road`, `galon`, `eggs`, `rain`, `vip`, `celebrate`, `sunset`) dan dipilih lewat properti `images` dengan urutan yang sama seperti `pages`. Untuk mengganti, edit SVG-nya atau taruh PNG 480 × 270 dengan nama sama (PNG diutamakan).

Kontrol cutscene: Enter / klik untuk lanjut, Esc untuk lewati.

## Placeholder untuk Writer Story

Di `scripts/autoload/game_state.gd`:

* `MEDICAL_COST` (sekarang Rp350.000; upah maksimal 5 hari Rp505.000 termasuk tip Pak Ojan)
* `SHORTFALL_RULE` — kalau tabungan kurang setelah Hari 5:
  * `REPLAY_DAYS` (aktif): pemain boleh mengulang hari mana pun dari layar rekap
  * `BAD_ENDING`: masa percobaan langsung berakhir dengan ending gagal

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
| Pull Request ke `dev` / `main` | Import + export dicek; build bisa diunduh di tab **Actions → Artifacts** |
| Push ke `main` | Build Web + Windows (artifact) |
| Push tag `v*` (contoh `v0.2.0`) | **GitHub Release** otomatis berisi `SiNgacir-web.zip`, `SiNgacir-windows.zip`, dan manual |
| Tombol **Run workflow** di tab Actions | Build manual kapan saja |

Membuat rilis baru (setelah `dev` digabung ke `main`):

```bash
git checkout main && git pull
git tag v0.2.0
git push origin v0.2.0
```

Deploy opsional (Settings → Secrets and variables → Actions):

| Tujuan | Atur | Catatan |
| --- | --- | --- |
| **itch.io** (link main di browser) | Variable `ITCH_GAME` = `namauser/si-ngacir`, Secret `BUTLER_API_KEY` | API key dari itch.io → Settings → API keys. Jalan saat push tag |

Upload ulang rilis yang sudah ada ke itch.io (misalnya setelah secret baru diisi): `gh workflow run build.yml --ref v0.5.0`.
| **GitHub Pages** | Variable `DEPLOY_PAGES` = `true`, Settings → Pages → Source: *GitHub Actions* | Repo private butuh GitHub Pro/Team; repo public gratis |

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

# SI NGACIR — "Trobos Ajalah!"

Game arcade 2D tentang Masbro, capybara yang harus lolos masa percobaan lima hari sebagai kurir Ngacir Express demi biaya pengobatan adiknya. Seberangi lalu lintas, kejar Timer ETA, dan jaga paket supaya upah tidak terpotong denda.

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

## Status (core loop)

* [x] Gerak grid, lane jalan/trotoar/median, kendaraan (motor, mobil, truk)
* [x] Kondisi paket menggantikan nyawa (tabrakan → damage → paket hancur)
* [x] Timer ETA, rating bintang, komentar pelanggan
* [x] Upah harian: upah dasar + bonus ETA − denda kerusakan − potongan telat
* [x] 5 hari masa percobaan: Bantal, Galon Air, Telur, Barang Sensitif, Paket VIP
* [x] Tabungan antar hari (upah terbaik per hari) dan layar rekap/ending
* [x] Save system: progres hari & tabungan tersimpan otomatis, menu Lanjutkan / Mulai Baru
* [ ] Keputusan final Writer Story: biaya pengobatan & aturan ending (lihat di bawah)
* [x] Side conflict: kucing jalanan, hujan (jarak pandang & licin), Pak Ojan (pelanggan perfeksionis)
* [x] Sistem audio (BGM + SFX, suara placeholder) dan menu Pengaturan (volume, layar penuh)
* [x] Siap sprite: game otomatis memakai gambar di `assets/sprites/` (spesifikasi di `docs/ASSET_SPEC.md`)
* [x] Cutscene cerita: pembuka, sebelum Hari 2–5, dan ending (naskah draf)
* [ ] Gambar final dari tim Illustrator
* [ ] Naskah final dari tim Writer Story

## Struktur

```text
scenes/main.tscn            Layar judul
scenes/ending.tscn          Rekap masa percobaan dan ending
scenes/cutscene.tscn        Pemutar cutscene cerita
scenes/game/level.tscn      Satu hari pengiriman
scripts/autoload/game_state.gd   Hari aktif, tabungan, input map, format rupiah
scripts/data/                PackageData, LaneData, DayData (Resource)
scripts/game/                Level, Player (Masbro), Vehicle, DeliveryReport
scripts/ui/hud.gd            HUD dan panel intro/pause/hasil/gagal
resources/packages/*.tres    Data paket (daya tahan, kerapuhan, kecepatan langkah)
resources/story/*.tres       Naskah cutscene (StoryData)
resources/days/day_0N.tres   Data hari 1–5: paket, pelanggan, ETA, upah, susunan lane
```

## Menambah hari baru

1. Duplikat salah satu `resources/days/day_0N.tres`, lalu edit di Inspector: `day`, `package`, `customer_name`, `eta_seconds`, upah, dan `lanes` (urut dari atas/rumah ke bawah/gudang, 13 baris, baris pertama & terakhir `SIDEWALK`).
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

Gambar ilustrasi per halaman (opsional): taruh PNG 480 × 270 di `assets/story/`, lalu isi nama filenya (tanpa `.png`) di properti `images` dengan urutan yang sama seperti `pages`.

Kontrol cutscene: Enter / klik untuk lanjut, Esc untuk lewati.

## Placeholder untuk Writer Story

Di `scripts/autoload/game_state.gd`:

* `MEDICAL_COST` (sekarang Rp350.000; upah maksimal 5 hari Rp505.000 termasuk tip Pak Ojan)
* `SHORTFALL_RULE` — kalau tabungan kurang setelah Hari 5:
  * `REPLAY_DAYS` (aktif): pemain boleh mengulang hari mana pun dari layar rekap
  * `BAD_ENDING`: masa percobaan langsung berakhir dengan ending gagal

Teks ending ada di `scripts/ending.gd`.

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

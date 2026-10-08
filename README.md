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
* [ ] Save system
* [ ] Keputusan final Writer Story: biaya pengobatan & aturan ending (lihat di bawah)
* [ ] Kucing jalanan, hujan, Pak Ojan
* [ ] Sprite, audio, menu settings

## Struktur

```text
scenes/main.tscn            Layar judul
scenes/ending.tscn          Rekap masa percobaan dan ending
scenes/game/level.tscn      Satu hari pengiriman
scripts/autoload/game_state.gd   Hari aktif, tabungan, input map, format rupiah
scripts/data/                PackageData, LaneData, DayData (Resource)
scripts/game/                Level, Player (Masbro), Vehicle, DeliveryReport
scripts/ui/hud.gd            HUD dan panel intro/pause/hasil/gagal
resources/packages/*.tres    Data paket (daya tahan, kerapuhan, kecepatan langkah)
resources/days/day_0N.tres   Data hari 1–5: paket, pelanggan, ETA, upah, susunan lane
```

## Menambah hari baru

1. Duplikat salah satu `resources/days/day_0N.tres`, lalu edit di Inspector: `day`, `package`, `customer_name`, `eta_seconds`, upah, dan `lanes` (urut dari atas/rumah ke bawah/gudang, 13 baris, baris pertama & terakhir `SIDEWALK`).
2. Tambahkan path-nya ke `DAYS` di `scripts/autoload/game_state.gd`.
3. Untuk mengetes satu hari langsung, buka `level.tscn`, isi properti `day`, lalu **F6**.

## Placeholder untuk Writer Story

Di `scripts/autoload/game_state.gd`:

* `MEDICAL_COST` (sekarang Rp350.000; upah maksimal 5 hari Rp480.000)
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

Grafis saat ini masih placeholder (digambar lewat `_draw()`); ganti dengan sprite dari tim Illustrator.

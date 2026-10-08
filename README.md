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
* [x] Hari 1 (Bantal) bisa dimainkan
* [ ] Hari 2–5 (Galon, Telur, Barang Sensitif, Paket VIP)
* [ ] Save system, ending (target biaya pengobatan masih placeholder)
* [ ] Kucing jalanan, hujan, Pak Ojan
* [ ] Sprite, audio, menu settings

## Struktur

```text
scenes/main.tscn            Layar judul
scenes/game/level.tscn      Satu hari pengiriman
scripts/autoload/game_state.gd   Hari aktif, tabungan, input map, format rupiah
scripts/data/                PackageData, LaneData, DayData (Resource)
scripts/game/                Level, Player (Masbro), Vehicle, DeliveryReport
scripts/ui/hud.gd            HUD dan panel intro/pause/hasil/gagal
resources/packages/*.tres    Data paket (daya tahan, kerapuhan, kecepatan langkah)
resources/days/day_01.tres   Data hari: paket, pelanggan, ETA, upah, susunan lane
```

## Menambah hari baru

1. Duplikat `resources/days/day_01.tres` → `day_02.tres`, lalu edit di Inspector: `day`, `package`, `customer_name`, `eta_seconds`, upah, dan `lanes` (urut dari atas/rumah ke bawah/gudang, 13 baris, baris pertama & terakhir `SIDEWALK`).
2. Tambahkan path-nya ke `DAYS` di `scripts/autoload/game_state.gd`.
3. Untuk mengetes satu hari langsung, buka `level.tscn`, isi properti `day`, lalu **F6**.

Grafis saat ini masih placeholder (digambar lewat `_draw()`); ganti dengan sprite dari tim Illustrator.

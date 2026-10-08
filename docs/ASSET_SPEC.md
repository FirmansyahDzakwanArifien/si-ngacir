# Spesifikasi Aset — Si Ngacir

Panduan untuk tim Illustrator & Audio. Simpan file di folder yang disebut dengan **nama persis** seperti tabel di bawah. Game otomatis memakai file yang ada; yang belum ada tetap tampil sebagai placeholder, jadi aset bisa dicicil satu per satu.

## Aturan umum sprite

* Format **PNG** dengan latar transparan.
* Ukuran 1 petak (tile) = **48 × 48 px**. Layar game = 15 × 13 petak (720 × 672 px, termasuk bar atas 48 px).
* Semua karakter dan kendaraan digambar **menghadap ke kanan**. Game membalik otomatis saat bergerak ke kiri.
* Animasi = **sprite strip horizontal**: frame berjajar ke kanan, tanpa jarak. Jumlah frame dihitung otomatis dari lebar gambar (lebar ÷ 48).
* Gaya: 2D casual, colorful, kontras tinggi. Pemain harus langsung bisa membedakan Masbro, paket, kendaraan, dan jalan.
* Jika gaya pixel art, ubah filter tekstur jadi *Nearest* di Project Settings → Rendering → Textures → Default Texture Filter.

Lokasi: `assets/sprites/`

## Masbro (karakter utama)

| File | Ukuran frame | Frame | Keterangan |
| --- | --- | --- | --- |
| `masbro_idle.png` | 48 × 48 | 2–4 | Diam, santai (napas pelan / kedip) |
| `masbro_walk.png` | 48 × 48 | 4–6 | Melangkah satu petak. Diputar 8 fps |
| `masbro_hit.png` | 48 × 48 | 2–4 | Kaget / terpental saat tertabrak |

Catatan: paket digambar **terpisah** (lihat di bawah) dan diletakkan di punggung Masbro pada posisi x=12, y=4. Sisakan ruang di area punggung.

## Paket

Ikon paket di punggung Masbro, **20 × 15 px**.

| File | Paket |
| --- | --- |
| `package_bantal.png` | Bantal (Hari 1) |
| `package_galon.png` | Galon Air (Hari 2) |
| `package_telur.png` | Telur (Hari 3) |
| `package_sensitif.png` | Barang Sensitif (Hari 4) |
| `package_vip.png` | Paket VIP (Hari 5) |

## Kendaraan

| File | Ukuran | Damage ke paket |
| --- | --- | --- |
| `vehicle_motor.png` | 48 × 48 | 1 |
| `vehicle_mobil.png` | 96 × 48 | 1 |
| `vehicle_truk.png` | 144 × 48 | 2 |

Pandangan dari atas (top-down) atau samping, menghadap kanan. Kendaraan sebaiknya mengisi tinggi ±30 px di tengah petak supaya area tabrakan terasa adil.

## Latar (tile)

Diulang (tile) memanjang sepanjang baris, jadi sisi kiri dan kanan harus menyambung mulus.

| File | Ukuran | Dipakai untuk |
| --- | --- | --- |
| `tile_sidewalk.png` | 48 × 48 | Trotoar (gudang di bawah, rumah pelanggan di atas) |
| `tile_road.png` | 48 × 48 | Jalan aspal, termasuk marka jalan |
| `tile_median.png` | 48 × 48 | Taman pembatas di tengah (zona aman) |
| `house.png` | bebas, tinggi ≤ 48 | Rumah pelanggan, digambar di pojok kanan baris atas |
| `warehouse.png` | bebas, tinggi ≤ 48 | Gudang Ngacir Express, pojok kanan baris bawah |

## Audio

Lokasi: `assets/audio/music/` dan `assets/audio/sfx/`. Format `.ogg` (disarankan), `.wav`, atau `.mp3`. Daftar nama file ada di README bagian **Audio**. Musik otomatis di-loop, jadi buat ujung dan awal lagu menyambung.

## Checklist sebelum push aset

* Nama file sesuai tabel (huruf kecil, pakai garis bawah)
* Latar transparan, ukuran frame tepat kelipatan 48 px
* Jalankan game (F5) dan cek tampilan di Hari 1
* Catat sumber & lisensi aset pihak ketiga di `assets/CREDITS.md`

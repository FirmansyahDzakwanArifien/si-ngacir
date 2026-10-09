# Spesifikasi Aset — Si Ngacir

Panduan untuk tim Illustrator & Audio. Simpan file di folder yang disebut dengan **nama persis** seperti tabel di bawah. Game otomatis memakai file yang ada; yang belum ada tetap tampil sebagai placeholder, jadi aset bisa dicicil satu per satu.

## Sprite bawaan (SVG)

Game sudah punya sprite bawaan bergaya **kawaii painted-lite** dalam format SVG di `assets/sprites/` (dibuat 2x lebih besar: 1 petak = 96 px, supaya tajam di HP). Arah gayanya mengikuti poster key art: outline tebal kawaii, bentuk diberi gradasi cahaya dari kiri atas (terang → warna dasar → gelap), kilau lembut di bagian bulat, dan bayangan tanah yang tegas. Di dalam game, filter cahaya `Sunlight` menambah warna hangat dan sinar matahari dari kanan atas, jadi sprite **jangan** diberi cahaya matahari sendiri. Ada dua cara mengganti:

1. **Edit SVG-nya** di Inkscape / Figma / Illustrator (ukuran kanvas jangan diubah), atau
2. **Taruh PNG** dengan nama yang sama sesuai tabel di bawah. PNG selalu diutamakan daripada SVG.

Palet: outline `#3D2C2E` (tebal 3–4 px pada skala 2x), bulu Masbro `#D19A66`, kuning `#FFD166`, toska `#2EC4B6`, coral `#FF6B6B`, oranye `#FF9F1C`, krem `#FFF4DC`, pipi `#FF8FA3`, ransel kurir `#34364A`.

Rencana gaya berikutnya (model 3D yang dirender jadi sprite, atau 3D penuh) ada di `docs/KONSEP_3D.md`.

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

Catatan: paket digambar **terpisah** (lihat di bawah) dan diletakkan di punggung Masbro pada posisi x=4, y=6 (dalam frame 48 × 48). Sisakan ruang di area punggung.

## NPC pelanggan

Tampak depan, 48 × 48, berdiri di samping rumah tujuan.

| File | Tokoh |
| --- | --- |
| `customer_bu_sri.png` | Bu Sri (Hari 1) |
| `customer_pak_budi.png` | Pak Budi (Hari 2) |
| `customer_pak_ojan.png` | Pak Ojan (Hari 3) |
| `customer_pak_joko.png` | Pak Joko (Hari 4) |
| `customer_bu_direktur.png` | Bu Direktur Ngacir (Hari 5) |

## Kucing jalanan

| File | Ukuran frame | Frame | Keterangan |
| --- | --- | --- | --- |
| `cat_walk.png` | 48 × 48 | 4 | Berjalan menyeberang, menghadap kanan |
| `cat_sit.png` | 48 × 48 | 2 | Duduk penasaran (saat menyentuh Masbro) |

## Lokasi (tema kota)

Tiap hari memakai satu `CityTheme` (`resources/cities/*.tres`) yang menentukan tile median, tile trotoar, warna aspal, dan pemandangan di sisi layar lebar.

| File | Keterangan |
| --- | --- |
| `tile_median_pasar`, `tile_median_sekolah`, `tile_median_kota`, `tile_median_bisnis` | Median per lokasi (48 × 48, bertepi trotoar atas-bawah) |
| `tile_sidewalk_pasar`, `tile_sidewalk_kota` | Trotoar per lokasi |
| `side_perumahan`, `side_pasar`, `side_sekolah`, `side_kota`, `side_bisnis` | Pemandangan sisi layar lebar, diulang ke bawah (48 × 48) |

## Sungai

| File | Ukuran | Keterangan |
| --- | --- | --- |
| `tile_water.png` | 48 × 48 | Air sungai, sisi kiri-kanan menyambung |
| `vehicle_rakit2.png` | 96 × 48 | Rakit 2 petak (tampak atas/samping) |
| `vehicle_rakit3.png` | 144 × 48 | Rakit 3 petak |

## Pos (checkpoint)

| File | Ukuran | Keterangan |
| --- | --- | --- |
| `checkpoint_flag.png` | 48 × 48 | Bendera Pos belum dicapai |
| `checkpoint_flag_on.png` | 48 × 48 | Bendera Pos sudah dicapai |

## Rintangan & item

Semua 48 × 48 (1 petak), tampak samping/depan, berdiri di tengah petak.

| File | Keterangan |
| --- | --- |
| `obstacle_cone.png` | Cone lalu lintas (menghalangi) |
| `obstacle_barrier.png` | Pembatas jalan (menghalangi) |
| `obstacle_hole.png` | Lubang di aspal, tampak atas |
| `item_coin.png` | Koin bonus |
| `item_helmet.png` | Power-up helm |
| `item_shoes.png` | Power-up sepatu |

## NPC jalanan

| File | Ukuran frame | Frame | Keterangan |
| --- | --- | --- | --- |
| `pejalan_ibu_walk.png` / `_idle.png` | 48 × 48 | 4 / 1 | Ibu-ibu membawa belanjaan |
| `pejalan_anak_walk.png` / `_idle.png` | 48 × 48 | 4 / 1 | Anak membawa balon |
| `obstacle_gerobak.png` | 48 × 48 | 1 | Gerobak bakso + pedagang |
| `vehicle_kilat.png` | 48 × 48 | 1 | Bang Kilat, kurir rival bermotor |

Pengemudi mobil/truk digambar di jendela depan sprite kendaraan.

## Aksesori toko

Frame **48 × 48 sejajar sprite Masbro** (menghadap kanan): gambar hanya aksesorinya di posisi kepala/badan Masbro, sisanya transparan. Game menggeser aksesori naik-turun mengikuti animasi.

| File | Slot |
| --- | --- |
| `acc_caping.png`, `acc_beanie.png`, `acc_koki.png`, `acc_mahkota.png` | Topi |
| `acc_kacamata_piksel.png`, `acc_kacamata_bulat.png`, `acc_kacamata_hitam.png`, `acc_kacamata_bintang.png` | Kacamata (`kacamata_piksel` bawaan ala poster, gratis dan langsung dipakai) |
| `acc_tas_pink.png`, `acc_tas_oranye.png`, `acc_tas_kucing.png` | Tas |
| `icon_coin.png` (20 × 20) | Ikon koin di toko |

Daftar barang dan harga ada di `scripts/data/cosmetics.gd`.

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

Tampak samping, menghadap kanan. **Varian warna** opsional: tambahkan `vehicle_mobil_2.png`, `vehicle_mobil_3.png`, dst. Game memilih varian secara acak. Kendaraan sebaiknya mengisi tinggi ±30 px di tengah petak supaya area tabrakan terasa adil.

## Latar (tile)

Diulang (tile) memanjang sepanjang baris, jadi sisi kiri dan kanan harus menyambung mulus.

| File | Ukuran | Dipakai untuk |
| --- | --- | --- |
| `tile_sidewalk.png` | 48 × 48 | Trotoar (gudang di bawah, rumah pelanggan di atas) |
| `tile_road.png` | 48 × 48 | Jalan aspal, termasuk marka jalan |
| `tile_median.png` | 48 × 48 | Taman pembatas di tengah (zona aman) |
| `house.png` | bebas, tinggi ≤ 48 | Rumah pelanggan, digambar di pojok kanan baris atas |
| `warehouse.png` | bebas, tinggi ≤ 48 | Gudang Ngacir Express, pojok kanan baris bawah |

## Dekorasi jalan (ala poster)

Hanya hiasan, tidak menghalangi langkah. Teks di papan digambar oleh game (bisa diterjemahkan), jadi gambar papannya **tanpa tulisan**.

| File | Ukuran | Dipakai untuk |
| --- | --- | --- |
| `deco_pole.png` | 14 × 88 | Tiang listrik di tepi kiri/kanan trotoar dan median; kabel digambar game di antara palang |
| `deco_sign_next.png` | 96 × 48 | Papan hijau "LEVEL NEXT" di baris rumah pelanggan; panah di kanan, area teks 70 px di kiri |
| `deco_billboard.png` | 150 × 42 | Billboard LED depot (baris gudang) berisi "NGACIR EXPRESS / Dari Jalan Untuk Hidup" |

## Ilustrasi cutscene

Lokasi: `assets/story/`. Ukuran **480 × 270 px** (PNG) atau 960 × 540 (SVG bawaan, 2x). Bingkai bulat dengan outline gelap.

| File | Adegan |
| --- | --- |
| `home` | Masbro dan adiknya di rumah |
| `sick` | Adik sakit di tempat tidur |
| `office` | Masbro melamar di Ngacir Express |
| `road` | Jalan raya Kota Ngacir |
| `galon` | Galon untuk Pak Budi (Hari 2) |
| `eggs` | Pak Ojan memeriksa telur (Hari 3) |
| `rain` | Hujan di jam sibuk (Hari 4) |
| `vip` | Paket VIP (Hari 5) |
| `celebrate` | Lulus, adik sembuh |
| `sunset` | Ending gagal |
| `home_night` | Malam di rumah, toples tabungan (setelah Hari 1–4) |
| `hospital` | Nana dirawat, Bu Dokter memeriksa |
| `depot` | Gudang Ngacir Express pagi hari, Bang Kilat dengan motornya |

## Potret dialog

Lokasi: `assets/portraits/`. Nama file `<tokoh>_<ekspresi>`, ukuran **96 × 96 px** (PNG) atau 192 × 192 (SVG bawaan, 2x). Kepala dan bahu tampak depan, latar transparan (bingkai bulat berwarna digambar oleh game).

| Tokoh | Ekspresi yang dipakai naskah |
| --- | --- |
| `masbro` | `normal`, `senang`, `sedih`, `kaget`, `mantap` |
| `nana` (adik) | `normal`, `senang`, `sedih`, `sakit` |
| `kilat` (Bang Kilat) | `sombong`, `kaget`, `sedih`, `senang` |
| `dokter` | `normal`, `senang` |
| `direktur` | `normal`, `senang` |
| `ojan` | `normal`, `senang`, `kaget` |

Ekspresi yang belum ada otomatis memakai `normal`. Nama tampilan dan warna papan nama diatur di `scripts/data/speakers.gd`.

## Audio

Lokasi: `assets/audio/music/` dan `assets/audio/sfx/`. Format **`.wav`** (16-bit, mono atau stereo); musik dikompres otomatis saat import. Jangan pakai `.ogg` / `.mp3`: build web tidak bisa memutarnya. Daftar nama file ada di README bagian **Audio**. Musik otomatis di-loop, jadi buat ujung dan awal lagu menyambung.

## Checklist sebelum push aset

* Nama file sesuai tabel (huruf kecil, pakai garis bawah)
* Latar transparan, ukuran frame tepat kelipatan 48 px
* Jalankan game (F5) dan cek tampilan di Hari 1
* Catat sumber & lisensi aset pihak ketiga di `assets/CREDITS.md`

---
title: Aturan & Upah
description: Alur ambil-antar paket, kondisi paket sebagai pengganti nyawa, Timer ETA, rumus upah, dan rating pelanggan.
---

## Alur satu hari

1. Masbro berangkat dari **Gudang Ngacir Express** (bawah layar) **tanpa paket**.
2. **Ambil paket** di **kios pengirim**, kira-kira di tengah rute. Cari ikon paket melayang bertuliskan **AMBIL**, lalu injak petak kiosnya. <img class="sprite" src="/img/sprites/pickup_stall.svg" alt="Kios pengirim" />
3. **Antar paket** ke **rumah pelanggan** di ujung atas rute.
4. Pelanggan memberi **rating**, lalu upah hari itu masuk ke tabungan.

Sebelum paket diambil, tabrakan dan tercebur hanya membuat Masbro terpental; paket belum bisa rusak. Sampai di rumah pelanggan tanpa paket belum dihitung selesai.

Rute jauh lebih panjang dari satu layar dan layar ikut bergerak naik. **Susunan jalan dibuat ulang secara acak setiap hari dimulai**, dan makin dekat ke rumah pelanggan, kendaraan makin cepat.

## Paket = nyawa

Masbro tidak punya nyawa. Yang dijaga adalah **paket**. Setiap tabrakan merusak paket, Masbro terpental satu langkah ke belakang, lalu kebal sebentar (berkedip). Jika paket hancur, pengiriman gagal dan upah hari itu hangus untuk ganti rugi.

| Kendaraan | Kecepatan | Kerusakan paket |
| --- | --- | --- |
| <img class="sprite" src="/img/sprites/vehicle_motor.svg" alt="" /> Motor | Cepat | 1 |
| <img class="sprite" src="/img/sprites/vehicle_mobil.svg" alt="" /> Mobil | Sedang | 1 |
| <img class="sprite" src="/img/sprites/vehicle_bajaj.svg" alt="" /> Bajaj | Cukup cepat, 1 petak | 1 |
| <img class="sprite" src="/img/sprites/vehicle_angkot.svg" alt="" /> Angkot | Sedang, 2 petak | 1 |
| <img class="sprite" src="/img/sprites/vehicle_truk.svg" alt="" /> Truk | Lambat, panjang | 2 |
| <img class="sprite" src="/img/sprites/vehicle_bus.svg" alt="" /> Bus kota | Paling lambat, 4 petak | 2 |

Paket rapuh seperti telur menerima kerusakan dua kali lipat.

## Layar permainan

| Elemen | Arti |
| --- | --- |
| **HARI** | Hari ke berapa dari masa percobaan |
| **Kotak paket ■■■** | Kondisi paket. Satu kotak hilang setiap kali paket rusak. Semua hilang berarti paket hancur |
| **Garis rute** | Titik kuning = Masbro, kotak cokelat = kios jemput, rumah merah = tujuan |
| **ETA** | Sisa waktu target. Kuning saat ≤10 detik, merah "TELAT" bila lewat |
| **AMBIL DI / KE** | Tujuan sekarang: kios pengirim sebelum paket diambil, lalu nama pelanggan |

## Timer ETA

Sampai sebelum ETA habis untuk mendapat **bonus tepat waktu**. Terlambat tidak membuat gagal, tetapi upah dipotong per detik keterlambatan. ETA sudah memperhitungkan waktu mampir ke kios.

## Upah harian

```text
Upah = Upah dasar + Bonus tepat waktu (+ Tip) (+ Bonus koin)
       − Denda kerusakan − Potongan telat
```

Upah setiap hari ditambahkan ke **tabungan pengobatan**. Bila mengulang hari, yang dihitung adalah upah **terbaik** hari itu. Target tabungan: **Rp350.000**.

| Hari | Upah dasar | Bonus tepat waktu | Denda per kerusakan | Potongan telat per detik |
| --- | --- | --- | --- | --- |
| 1 | Rp50.000 | Rp20.000 | Rp10.000 | Rp500 |
| 2 | Rp60.000 | Rp20.000 | Rp15.000 | Rp750 |
| 3 | Rp70.000 | Rp25.000 | Rp20.000 (2x untuk Pak Ojan) | Rp1.000 |
| 4 | Rp80.000 | Rp25.000 | Rp20.000 | Rp1.000 |
| 5 | Rp100.000 | Rp30.000 | Rp30.000 | Rp1.500 |

## Rating pelanggan

Setelah paket sampai, pelanggan memberi 1–5 bintang dan komentar berdasarkan kondisi paket dan ketepatan waktu.

| Bintang | Contoh komentar |
| --- | --- |
| ★★★★★ | "Paketnya utuh, kurirnya santai. Recommended!" |
| ★★★★ | "Paket agak penyok, tapi masih aman." |
| ★★★ | "Hati-hati kalau antar paket, Masbro." |
| ★★ | "Masbro... paketnya rusak, tapi masih bisa diterima." |
| ★ | "Mas... ini paket apa habis perang?" |

## Menang dan kalah

- **Berhasil:** sampai di rumah pelanggan sebelum paket hancur. Alurnya: Delivery Complete → Rating → Upah → hari berikutnya.
- **Gagal:** paket hancur. Pilih **Ulangi Hari**, kembali ke menu, atau **Lanjut dari Pos** bila sudah melewati Pos (lihat [Rintangan & Item](/bermain/rintangan/#pos-checkpoint)).

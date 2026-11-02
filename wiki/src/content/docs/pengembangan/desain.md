---
title: Desain Game
description: Ringkasan Game Design Document Si Ngacir. Konsep, keunikan, core loop, sistem paket, rating, dan desain level.
---

Halaman ini merangkum **Game Design Document (GDD)** Si Ngacir yang disusun Varmintz KW Studio.

## Ringkasan

| | |
| --- | --- |
| **Nama** | Si Ngacir — *"Trobos Ajalah"* |
| **Genre** | 2D Arcade / Casual |
| **Elemen** | Delivery, road crossing, obstacle avoidance, package management, time challenge, customer rating, level progression |
| **Pemain** | Single player |
| **Platform** | Web, Windows, Android |
| **Target pemain** | Pemain kasual yang menyukai permainan sederhana, cepat dipahami, dengan tantangan berbasis refleks dan pengambilan keputusan |
| **Inspirasi** | *Varmintz Deluxe* (GameHouse), game road-crossing dan obstacle avoidance era 2000-an, dipadukan dengan konsep game kurir |

## Keunikan

> Si Ngacir mengubah sistem nyawa menjadi **kondisi paket**. Pemain bukan hanya berusaha mencapai tujuan, tetapi harus memastikan barang yang dibawanya tetap dalam kondisi baik. Setiap level membawa jenis paket yang berbeda, dan karakteristik paket itu mengubah cara pemain bermain.

Capybara adalah *visual hook*; **paket sebagai resource utama** adalah inti gameplay-nya.

## Core gameplay loop

```text
Ambil Paket → Menyeberang → Hindari Kendaraan/Rintangan
     → Jaga Kondisi Paket → Sampai Tujuan → Dapat Rating
```

```text
MAIN MENU → TERIMA ORDER → AMBIL PAKET → PENGANTARAN
                                            │
                                     Tabrakan? ── tidak ──┐
                                            │ ya          │
                                     Paket rusak          │
                                            │             │
                                  Hancur? ── tidak ───────┤
                                            │ ya          │
                                  PENGIRIMAN GAGAL        ▼
                                                  SAMPAI TUJUAN
                                                        │
                                              RATING PELANGGAN
                                                        │
                                                 UPAH / HASIL
                                                        │
                                              HARI BERIKUTNYA
```

## Sistem paket & kerusakan

Paket menggantikan konsep health. Tabrakan tidak membunuh karakter; dampak utamanya adalah berkurangnya kondisi paket.

| Kerusakan | Kondisi paket | Status |
| --- | --- | --- |
| 0 | Paket aman | Good |
| 1 | Kerusakan kecil | Minor Damage |
| 2 | Kerusakan sedang | Damaged |
| 3 | Paket hancur | Failed Delivery |

Sumber kerusakan: menabrak kendaraan, masuk lubang, tercebur sungai, dan hazard lain di level. Nilai akhirnya disesuaikan lewat playtesting: gorengan tahan 4 kerusakan, Patung Kristal Jeruk hanya 2, dan kue ultah & akuarium cupang yang berat memperlambat langkah.

## Sistem rating

Setelah sampai, pemain tidak sekadar melihat tulisan *LEVEL COMPLETED*, tetapi menerima **Customer Rating** berdasarkan kondisi paket, waktu pengantaran, dan jumlah tabrakan, lengkap dengan komentar pelanggan yang lucu.

| Rating | Kondisi | Contoh komentar |
| --- | --- | --- |
| ★★★★★ | Utuh dan cepat | "Mukanya santai, tapi paketnya mulus tanpa lecet. Mantap!" |
| ★★★★ | Sedikit rusak | "Paket agak penyok, tapi masih aman." |
| ★★★ | Beberapa kerusakan | "Lain kali lebih hati-hati, Masbro." |
| ★★ | Cukup parah | "Paketnya agak hancur, tapi isinya masih bisa dipakai." |
| ★ | Hampir rusak total | "Ini paket atau hasil bongkar muatan kapal karam?!" |
| 💥 | Hancur | "Masbro... paket saya mana?" |

## Desain level

| Level | Nama | Paket | Fokus |
| --- | --- | --- | --- |
| 1 | Introduction | Gorengan Hangat | Mengenalkan gerak, menyeberang, tabrakan, dan pengantaran; pelanggan tidak sabaran |
| 2 | Heavy Delivery | Kue Ultah & Akuarium Cupang | Menyesuaikan timing dengan langkah yang lebih lambat |
| 3 | Time Pressure | Es Krim | ETA paling ketat di gang penuh galian |
| 4 | Traffic Challenge | Laptop VIP | Kendaraan lebih banyak dan cepat di tengah badai, rintangan dikombinasikan |
| 5 | Final Delivery | Patung Kristal Jeruk | Menggabungkan gerak, timing, menghindar, manajemen paket, dan pemilihan rute |

Paket dan judul hari mengikuti naskah cerita Kedai Chill dari tim Writer Story (lihat [Lima Hari](/bermain/hari/)).

## Audio & visual

- **Visual:** 2D casual arcade yang sederhana, berwarna, dan mudah dikenali. Pemain harus cepat membedakan Masbro, paket, kendaraan, rintangan, tujuan, dan status kerusakan.
- **Musik:** ringan dan playful, dengan tema khusus untuk momen sedih dan tegang di cutscene.
- **Efek suara:** langkah, ambil paket, kendaraan, tabrakan, paket rusak, sampai tujuan, bintang rating, dan hadiah. Suara paket rusak dan rating sengaja dibuat sedikit lebay untuk memperkuat humor.

## Dari GDD ke game

Beberapa ide GDD yang sudah diwujudkan dan dikembangkan lebih jauh:

| Ide di GDD | Di dalam game |
| --- | --- |
| Customization capybara bila scope memungkinkan | [Toko Masbro](/fitur/toko/) dengan 12 aksesori, termasuk Jeruk Kepala bawaan |
| Side character selain Masbro | Bos Koko, Nana, Kuro, Pak Buldog, Pemilik Lahan, Pak Wali Kota, dan warga jalanan |
| Musuh dan hazard | Kuro dan kulit pisangnya, Pak Buldog, kucing jalanan, hujan, lubang, sungai |
| Pilihan Retry / Return to Menu | Ditambah **Lanjut dari Pos** (checkpoint) |

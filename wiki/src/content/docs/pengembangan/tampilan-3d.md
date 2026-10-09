---
title: Tampilan 3D
description: Bagaimana Tampilan 3D (beta) dibangun di atas logika 2D yang sama, skenario uji, dan tahap pengembangan berikutnya.
---

Tampilan 3D adalah opsi **beta** sejak v0.11 (Windows, Android) dan v0.12 (browser). Versi 2D tetap menjadi tampilan utama.

## Prinsip: satu logika, dua tampilan

Logika game (grid, tabrakan, ETA, ambil-antar, efek) tetap satu. Tampilan 3D hanyalah **lapisan tampilan** yang membaca keadaan level setiap frame.

```text
MapGenerator ─┐
Player ───────┼──▶ Level (logika) ──dibaca tiap frame──▶ Level3DView
Vehicle × n ──┘          │                                   │
                         ├──▶ HUD, kontrol sentuh            ▼
                         └──▶ Papan 2D (disembunyikan)   Model 3D
```

| Bagian | Isi |
| --- | --- |
| Aktivasi | Opsi di Pengaturan, dan hanya bila build punya modul 3D. Build tanpa 3D tidak pernah memuat skrip 3D |
| Pemetaan | 1 petak = 1 meter; kolom → sumbu x, baris → sumbu z |
| Model | Dibentuk dari bentuk dasar: Masbro (topi, ransel, kacamata, paket, helm), kendaraan, rakit, rintangan, item, kios, rumah, gudang, tiang, pohon. Bahan toon dengan rim light dan garis luar |
| Efek | Tulisan efek dan balon ucapan menjadi teks 3D; partikel 2D menjadi semburan partikel 3D dengan warna dan arah yang sama |
| Dunia | Langit prosedural dan matahari dengan bayangan; saat hujan ada kabut, partikel hujan, dan lampu kendaraan |
| Kamera | Perspektif 50°, tinggi 8 m, 8,5 m di belakang, menyerong ke kanan (sudut 3/4) |

## Skenario pemain

| # | Skenario | Yang terjadi |
| --- | --- | --- |
| S1 | Menyalakan Tampilan 3D lalu memulai hari | Papan 2D diganti dunia 3D; HUD dan kontrol tetap sama |
| S2 | Berangkat tanpa paket | Paket melayang berputar dengan tulisan AMBIL di atas kios |
| S3 | Mengambil paket | Paket muncul di atas ransel Masbro |
| S4 | Tertabrak | "BRAK!", partikel, Masbro salto, kamera bergoyang |
| S5 | Tercebur | "BYUR!", semburan air, kembali ke tepian |
| S6 | Hari hujan | Kabut, hujan, lampu kendaraan menyala |
| S7 | Sampai tujuan | Kartu hasil dan konfeti seperti versi 2D |
| S8 | Mematikan opsi | Hari berikutnya kembali ke 2D |

## Performa

Di desktop uji, Tampilan 3D berjalan sekitar 55–60 FPS. Di HP dan browser HP, bayangan real-time dimatikan.

## Tahap berikutnya

| Tahap | Pekerjaan |
| --- | --- |
| 3D-1 | Uji di HP acuan (FPS, panas, baterai) dan optimasi |
| 3D-2 | Ganti model bentuk dasar dengan model `.glb` buatan tim 3D |
| 3D-3 | Animasi rig Masbro: idle, lompat, salto, tercebur, merayakan |
| 3D-4 | Pisahkan model data papan dari tampilan supaya kode lebih bersih |
| 3D-5 | Opsi kamera dan uji keterbacaan dengan pemain baru |
| 3D-6 | Cutscene dan toko dalam 3D |
| 3D-7 | ✅ Build web dengan 3D (selesai di v0.12) |

Bila 3D tidak lolos uji di HP acuan, versi 2D tetap menjadi tampilan utama dan 3D tetap opsi beta di desktop.

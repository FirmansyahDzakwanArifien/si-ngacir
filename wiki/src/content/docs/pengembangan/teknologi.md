---
title: Teknologi
description: Engine, arsitektur kode, map prosedural, sistem audio, terjemahan, dan alur build otomatis Si Ngacir.
---

## Engine

- **Godot Engine 4.3 Stable** dengan GDScript.
- Renderer **Compatibility** (OpenGL ES 3 / WebGL 2) supaya jalan di browser dan HP kelas menengah.
- Grafis vektor (SVG) yang dirender tajam di semua ukuran layar.

## Susunan kode

```text
scenes/main.tscn          Layar judul
scenes/cutscene.tscn      Pemutar cutscene
scenes/album.tscn         Album Cerita
scenes/ending.tscn        Rekap dan ending
scenes/game/level.tscn    Satu hari pengiriman

scripts/autoload/         GameState, AudioManager, Accessibility, Transition, Screen
scripts/game/             Level, Player (Masbro), Vehicle, MapGenerator, efek
scripts/game3d/           Lapisan Tampilan 3D (beta)
scripts/data/             PackageData, LaneData, DayData, StoryData, kosmetik
scripts/ui/               HUD, panel, pengaturan

resources/days/           Data Hari 1–5: paket, pelanggan, ETA, upah, parameter peta
resources/packages/       Daya tahan, kerapuhan, dan kecepatan langkah tiap paket
resources/story/          Naskah cutscene
resources/cities/         Tema lokasi tiap hari
translations/strings.csv  Terjemahan Indonesia–Inggris
```

Data game (hari, paket, cerita) disimpan sebagai *Resource* yang bisa diedit di Inspector Godot, jadi tim desain dan penulis bisa mengubah isi tanpa menyentuh kode.

## Map prosedural

Setiap hari punya parameter peta. Map dirakit ulang setiap kali hari dimulai:

1. **Gudang** di bawah, **rumah pelanggan** di atas.
2. Di antaranya, sejumlah **blok jalan** (beberapa lane dua arah) atau **blok sungai** (lane rakit), dipisah **median aman**.
3. Setiap beberapa blok, satu median dijadikan **Pos** (checkpoint).
4. Median diisi cone, pembatas, dan gerobak; aspal kadang berlubang; koin dan power-up disebar.
5. **Kios jemput** ditaruh di petak aman sekitar 35–65% panjang rute, tidak lurus dengan titik start.

Aturan penting: celah antar kendaraan minimal 3 petak dan rakit selalu cukup rapat, sehingga setiap peta **pasti bisa diselesaikan**. Kecepatan kendaraan naik bertahap menuju rumah pelanggan.

## Audio

Musik dan efek suara dicari berdasarkan nama file, jadi tim audio cukup mengganti file tanpa mengubah kode. Format **WAV** dikompres QOA saat import, karena build web ramping tidak menyertakan dekoder OGG/MP3.

## Bahasa

Teks ditulis dalam bahasa Indonesia; terjemahan Inggris ada di `translations/strings.csv`. Menambah bahasa lain cukup dengan menambah kolom baru.

## Build & rilis otomatis

```text
feat/<nama> ──PR──▶ dev ──PR──▶ main ──tag v*──▶ GitHub Actions
                                                    │
                     ┌──────────────┬───────────────┼──────────────┐
                     ▼              ▼               ▼              ▼
                Web (HTML5)     Windows         Android      Cek build
                     └──────────────┴───────┬───────┘
                                            ▼
                            GitHub Release + itch.io
```

- Setiap Pull Request diuji: proyek diimpor dan diekspor ulang.
- Sebelum merge, tim menjalankan rangkaian **tes otomatis** Godot (23 skenario: gerak, tabrakan, ambil-antar, sungai, Pos, cutscene, album, efek, Tampilan 3D, dan lainnya).
- Setelah export, CI membuka build hasilnya dan gagal bila ada cutscene kosong, potret hilang, atau musik tidak ikut.
- Build web memakai **template Godot ramping**: modul yang tidak dipakai dibuang supaya unduhan kecil (±8 MB terkompresi), tetapi inti 3D tetap ada untuk Tampilan 3D.
- Push tag `v*` otomatis membuat **GitHub Release** dan mengunggah ke **itch.io** (channel web, Windows, Android).

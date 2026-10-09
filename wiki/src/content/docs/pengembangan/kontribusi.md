---
title: Panduan Kontribusi
description: Alur kerja Git tim, cara mengganti gambar dan suara, menulis naskah cutscene, dan menambah terjemahan.
---

Panduan ini untuk anggota tim Varmintz KW Studio. Kode sumber berada di repositori privat tim.

## Alur Git

| Branch | Fungsi |
| --- | --- |
| `main` | Versi stabil / rilis. Hanya menerima merge dari `dev` |
| `dev` | Integrasi. Semua fitur digabung di sini lewat Pull Request |
| `feat/<nama>` | Satu fitur per branch, dibuat dari `dev` |
| `fix/<nama>` | Perbaikan bug, dibuat dari `dev` |

```bash
git checkout dev && git pull
git checkout -b feat/nama-fitur
# kerjakan, lalu:
git add -A
git commit -m "feat(scope): deskripsi singkat"
git push -u origin feat/nama-fitur
# Buka Pull Request ke dev, minimal 1 reviewer, lalu merge.
```

Rilis baru: gabungkan `dev` ke `main`, lalu buat tag `vX.Y.Z`. Build dan unggahan berjalan otomatis.

## Illustrator: gambar

- Sprite ada di `assets/sprites/`, potret dialog di `assets/portraits/`, ilustrasi cutscene di `assets/story/`.
- Ganti file dengan **nama yang sama**; game otomatis memakainya. Spesifikasi ukuran dan nama lengkap ada di `docs/ASSET_SPEC.md`.
- Sprite menghadap kanan, latar transparan, dan teks di dalam SVG harus diubah menjadi *path*.

## Audio

File di `assets/audio/music/` dan `assets/audio/sfx/`, format **WAV**. Ganti file dengan nama yang sama.

| Nama | Kapan diputar |
| --- | --- |
| `music/menu` | Menu utama, rekap, dan cutscene santai |
| `music/nana` | Cutscene sedih (Nana sakit, rumah sakit) |
| `music/kilat` | Cutscene tegang (Bang Kilat) |
| `music/gameplay` | Selama hari pengiriman |
| `sfx/step`, `sfx/pickup`, `sfx/hit`, `sfx/package_damage`, `sfx/fail`, `sfx/delivery`, `sfx/star` | Langkah, ambil paket, tabrakan, paket rusak, paket hancur, sampai, bintang rating |
| `sfx/meow`, `sfx/slip`, `sfx/splash`, `sfx/horn`, `sfx/click` | Kucing, tergelincir, tercebur, klakson, tombol |
| `sfx/chime_sad`, `sfx/sting_kilat` | Aksen saat musik cutscene berganti suasana |

## Writer Story: naskah

Naskah cutscene ada di `resources/story/` dan bisa diedit di Inspector Godot. Setiap cutscene punya tiga daftar dengan urutan sama (satu elemen per halaman):

| Properti | Isi |
| --- | --- |
| `pages` | Teks halaman. Token `{saved}`, `{target}`, `{left}` diganti tabungan, biaya pengobatan, dan kekurangannya |
| `speakers` | `tokoh:ekspresi` (misalnya `nana:senang`), atau kosong untuk narasi |
| `images` | Ilustrasi dari `assets/story/`. Kosong = tetap memakai gambar sebelumnya |

Setiap mengubah teks naskah, perbarui juga kuncinya di `translations/strings.csv`.

## Terjemahan

`translations/strings.csv` bisa diedit dengan Excel, Google Sheets, atau editor teks. Kolom `keys` berisi teks Indonesia persis, kolom `en` berisi terjemahan Inggris. Teks dengan `%s` / `%d` harus mempertahankan penanda yang sama.

## Wiki ini

Isi wiki ada di folder `wiki/` dalam repositori, ditulis dalam Markdown. Halaman Indonesia di `wiki/src/content/docs/`, versi Inggris di `wiki/src/content/docs/en/` dengan nama file yang sama. Perubahan yang digabung ke `main` otomatis tayang.

```bash
cd wiki
npm install
npm run dev     # pratinjau di http://localhost:4321
```

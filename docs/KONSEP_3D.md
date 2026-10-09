# Konsep 3D Si Ngacir

Dokumen ini menimbang langkah setelah gaya **2D painted-lite** (v0.9): apakah, kapan, dan bagaimana Si Ngacir naik ke tampilan 3D yang mendekati poster key art. Isinya pertimbangan, skema teknis, konsep visual, anggaran aset, dan tahapan kerja. Semua angka adalah **perkiraan awal** yang harus diukur ulang lewat prototipe.

## 1. Kondisi sekarang

| Aspek | Nilai saat ini |
| --- | --- |
| Engine | Godot 4.3, renderer **Compatibility** (OpenGL ES 3 / WebGL 2) |
| Gameplay | Grid 15 kolom × 48 px, kamera dari atas, kendaraan per lane |
| Grafis | Sprite SVG flat-kawaii + shading gradasi, filter cahaya `Sunlight` |
| Build web | Template ramping **tanpa 3D**: wasm ±29 MB (gzip ±6,7 MB), pck ±1,9 MB |
| Target | Browser desktop, HP kelas menengah (web dan APK), Windows |

Gameplay ala Frogger menuntut **keterbacaan**: pemain harus selalu bisa melihat jarak ke kendaraan. Itu batas utama setiap keputusan visual di bawah.

## 2. Pertimbangan

| Pertimbangan | 2D sekarang | Dampak bila ke 3D real-time |
| --- | --- | --- |
| Ukuran unduhan web | Kecil | Modul 3D harus diaktifkan lagi di template web: wasm naik beberapa MB, ditambah model dan tekstur |
| Performa HP | Ringan | Butuh anggaran poligon, draw call, dan bayangan yang ketat; uji di HP acuan wajib |
| Produksi aset | Generator SVG + Illustrator | Butuh modeler, rigger, dan animator 3D; aset jauh lebih mahal per karakter |
| Keterbacaan | Sangat jelas (tampak atas) | Kamera miring bisa menutupi lane di belakang kendaraan tinggi (truk) |
| Konsistensi gaya | Sudah seragam | Semua aset harus naik bersamaan; campuran 2D/3D terlihat setengah jadi |
| Aksesibilitas | Opsi teks, warna, gerak | Tetap wajib: mode tanpa efek cahaya, kurangi gerak kamera |
| Risiko jadwal | Rendah | Tinggi untuk proyek mata kuliah; harus bertahap dan bisa dibatalkan |

## 3. Tiga jalur

| | A. 2D painted (v0.9) | B. 2.5D pre-render | C. 3D real-time |
| --- | --- | --- | --- |
| Cara | Sprite 2D dengan shading, filter cahaya | Model 3D di Blender, **dirender jadi sprite sheet**; game tetap 2D | Model 3D langsung di Godot, kamera 3D |
| Kesan poster | ±60% | ±75% (cahaya dan volume konsisten) | ±85–90% |
| Ukuran web | Tidak berubah | Naik sedikit (PNG sprite) | Naik signifikan |
| Performa | Ringan | Ringan | Sedang–berat |
| Upaya | Selesai | Sedang: 1 model per karakter, render otomatis | Tinggi: model, rig, animasi, level 3D, shader |
| Kode game | Tetap | Tetap (`SpriteLibrary` sudah memprioritaskan PNG) | Lapisan tampilan baru (lihat skema) |

**Rekomendasi:** jalur **B dulu**, lalu putuskan C berdasarkan hasil prototipe. Model 3D yang dibuat untuk B (Masbro, kendaraan) bisa dipakai lagi di C, jadi tidak ada kerja yang terbuang.

## 4. Skema teknis

### 4.1 Pisahkan logika dari tampilan

Saat ini `Level` mengurus logika (grid, tabrakan, timer) sekaligus menggambar papan. Untuk 3D, logika dipisah supaya tampilan 2D dan 3D memakai aturan yang sama persis.

```mermaid
flowchart LR
    subgraph Logika
        DD[DayData + MapGenerator] --> BM[BoardModel<br/>lane, sel, tabrakan, ETA]
        IN[Input / sentuh] --> PL[PlayerModel<br/>sel, langkah, status]
        PL <--> BM
    end
    BM --> V2[BoardView2D<br/>sprite, Sunlight]
    BM --> V3[BoardView3D<br/>mesh, kamera, cahaya]
    PL --> V2
    PL --> V3
    BM --> HUD[GameHud]
```

* `BoardModel` dan `PlayerModel` bekerja dalam **satuan sel**, bukan piksel.
* Tampilan 2D dan 3D hanya membaca keadaan model dan memutar animasi.
* Tes otomatis yang sekarang (tabrakan, ETA, rakit, pos) dipindah ke model, jadi berlaku untuk kedua tampilan.

### 4.2 Pemetaan koordinat

| 2D sekarang | 3D |
| --- | --- |
| 1 sel = 48 px | 1 sel = 1 m |
| Kolom → x | x (kiri–kanan) |
| Baris → y (turun) | z (menjauh dari kamera = maju) |
| Kecepatan px/detik | Sama, dibagi 48 → m/detik |
| `TILE` di level | Konstanta skala di `BoardView3D` |

### 4.3 Susunan scene 3D

```text
Level3D (Node3D)
├── WorldEnvironment        langit gradasi, ambient hangat
├── Sun (DirectionalLight3D) dari kanan atas, sesuai filter Sunlight
├── CameraRig (Node3D)       mengikuti Masbro di sumbu z, sedikit lag
│   └── Camera3D             perspektif miring 50–55°, FOV 35–40°
├── Lanes (Node3D)           tile jalan/trotoar/sungai modular per baris
├── Vehicles (Node3D)        MultiMesh per jenis kendaraan bila banyak
├── Decor (Node3D)           tiang listrik, kabel, papan, billboard
├── Masbro (Node3D)          model + AnimationTree + aksesori di BoneAttachment3D
└── HUD (CanvasLayer)        GameHud yang sama dengan versi 2D
```

### 4.4 Kamera

* Perspektif miring 50–55° dari horizontal: cukup tinggi supaya lane di belakang truk tetap terlihat.
* Opsi **orthographic** di Pengaturan bila uji keterbacaan menunjukkan perspektif menyulitkan.
* Goyangan kamera mengikuti opsi "Kurangi efek gerak".

## 5. Konsep visual 3D

Arah gaya: **stylized**, bukan realistis. Bulu, cahaya hangat, dan pose dinamis dari poster diterjemahkan ke bentuk yang ringan.

| Elemen | Konsep |
| --- | --- |
| Shading | Toon 2–3 tingkat + rim light hangat di tepi; garis luar (inverted hull) supaya tetap kawaii |
| Bulu | Tekstur hand-painted dengan arah bulu; shell fur hanya untuk cutscene close-up, tidak di gameplay |
| Cahaya | Satu matahari dari kanan atas, ambient biru langit; bayangan bulat (blob) di bawah karakter dan kendaraan |
| Warna | Palet poster: langit biru pekat, matahari keemasan, aspal ungu-abu, aksen teal Ngacir Express |
| Efek | Debu dan kerikil saat melompat, garis kecepatan Bang Kilat, lampu kendaraan saat hujan |
| Masbro | Topi kurir kuning, ransel hitam bergaris teal, kacamata piksel (bisa dilepas), **tanpa rokok** |
| Lingkungan | Tiang listrik dan kabel, papan hijau "LEVEL NEXT", billboard "Dari Jalan Untuk Hidup" |

Efek pasca-proses di renderer Compatibility terbatas. Gunakan pendekatan seperti `Sunlight` (satu shader layar) daripada bergantung pada glow atau SSAO bawaan, lalu uji di web dan HP.

## 6. Anggaran aset (awal)

| Aset | Segitiga | Tekstur | Rig / animasi |
| --- | --- | --- | --- |
| Masbro | 3.000–5.000 | 1 × 1024 (512 untuk HP) | ±25 tulang: idle, hop, hit, celebrate, slide, tercebur |
| NPC (Nana, Kilat, pelanggan) | 2.000–4.000 | 1 × 512 | Pakai ulang rig Masbro bila proporsi sama |
| Kendaraan | 1.000–3.000 | Atlas bersama 1024 | Tanpa rig; roda berputar lewat kode |
| Tile lane | 100–800 | Atlas lingkungan 1024 | – |
| Dekorasi | 100–600 | Atlas lingkungan | – |

Batas per layar (perkiraan untuk HP menengah): ±100.000 segitiga, ±150 draw call, ±60 MB memori tekstur. Format: **glTF 2.0 (.glb)** dari Blender. Nama file mengikuti pola `docs/ASSET_SPEC.md` (`masbro.glb`, `vehicle_mobil.glb`, …) di folder `assets/3d/`.

## 7. Alur produksi

```mermaid
flowchart LR
    C[Konsep & turnaround<br/>dari poster] --> M[Model Blender<br/>low-poly + sculpt detail]
    M --> T[Tekstur hand-painted]
    T --> R[Rig + animasi]
    R --> B1[Jalur B:<br/>render sprite sheet otomatis]
    R --> B2[Jalur C:<br/>ekspor .glb ke Godot]
    B1 --> G2[Game 2D<br/>SpriteLibrary memakai PNG]
    B2 --> G3[Level3D]
```

Untuk jalur B, render sprite memakai kamera orthographic samping yang sama untuk semua frame, ukuran frame mengikuti `ASSET_SPEC.md` (96 × 96 per petak untuk resolusi 2x). Karena `SpriteLibrary` memprioritaskan PNG, sprite baru langsung dipakai tanpa mengubah kode.

## 8. Tahapan

| Fase | Isi | Kriteria selesai |
| --- | --- | --- |
| 0 (v0.9) | 2D painted-lite: shading, cahaya, dekorasi poster | Sudah dirilis; tes layout dan keterbacaan lolos |
| 1 | Model 3D Masbro + render sprite (jalur B) | Sprite PNG baru lolos tes layout; ukuran pck tetap wajar |
| 2 | Kendaraan dan NPC 3D → sprite | Semua sprite karakter dan kendaraan seragam gayanya |
| 3 | Prototipe 3D satu hari (desktop dulu) | Uji: FPS, ukuran web, keterbacaan oleh 5 pemain baru |
| 4 | Keputusan lanjut / berhenti di jalur B | Lihat ambang di bawah |
| 5 | Produksi 3D penuh (bila lanjut) | Semua hari, cutscene, toko, dan aksesibilitas berfungsi di 3D |

**Ambang untuk lanjut ke 3D penuh (fase 4):**

* Minimal 50 FPS stabil di HP acuan tim (kelas menengah, 2–3 tahun terakhir), baik di browser maupun APK.
* Unduhan web terkompresi tidak lebih dari ±15 MB.
* Pemain baru sama cepatnya membaca jarak kendaraan seperti di versi 2D (uji A/B singkat).
* Tim punya minimal satu orang untuk model dan rig, serta satu orang untuk animasi.

Bila salah satu tidak tercapai, tetap di jalur B. Hasilnya tetap jauh lebih dekat ke poster daripada sekarang.

## 9. Risiko dan mitigasi

| Risiko | Mitigasi |
| --- | --- |
| Aset 3D tidak selesai tepat waktu | Jalur B lebih dulu; tiap fase bisa dirilis sendiri |
| Web terlalu berat | Template web 3D terpisah hanya bila fase 3 lolos; tetap sediakan build 2D |
| Kamera miring mengganggu gameplay | Opsi orthographic, uji keterbacaan sebelum produksi |
| Gaya campur 2D/3D | Satu kategori aset diganti bersamaan (semua karakter, lalu semua kendaraan) |
| HP lambat | Opsi "Efek cahaya" dan kualitas rendah; tekstur 512 untuk HP |
| Key art AI dan konten | Tandai aset buatan AI di itch, tanpa rokok di versi game |

## 10. Keputusan yang dibutuhkan dari tim

1. Siapa yang memegang model, rig, dan animasi 3D (atau tetap 2D painted)?
2. HP acuan untuk uji performa (merek dan tipe).
3. Kamera 3D: perspektif miring atau orthographic sebagai bawaan.
4. Apakah poster dipakai sebagai key art resmi (cover itch, layar judul, layar loading)?

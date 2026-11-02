# SI NGACIR — "Trobos Ajalah!"

### Manual Pemain

---

## 1. Storyline

> *Masbro, capybara paling santai sekota, harus melunasi tunggakan sewa Kedai Chill sebesar Rp350.000 dalam lima hari. Satu-satunya kerja yang dibayar harian adalah kurir masa percobaan di Ngacir Express. Namun, tekanan waktu, lalu lintas, rintangan, dan risiko kerusakan paket dapat memotong upahnya dan mengancam kedai kesayangannya.*

**Suatu hari**, di tengah Kota Ngacir yang padat dan serba buru-buru, hiduplah Masbro, capybara pemilik **Kedai Chill**: kedai minum dan kolam air hangat tempat warga kota melepas penat. Ke mana-mana ia selalu membawa jeruk di kepala.

**Setiap hari**, Masbro menjaga kedainya dengan santai, tanpa pernah terburu-buru.

**Suatu ketika**, Pemilik Lahan datang membawa SP3: tunggakan sewa Kedai Chill harus lunas dalam lima hari, atau kedai disegel.

**Karena itu**, Masbro mendaftar sebagai kurir jalan kaki masa percobaan di Ngacir Express, ekspedisi dengan moto *"Kalo gak kilat, gak selamat!"*. Kepala kurirnya, Bos Koko, memberinya rentetan paket berisiko: gorengan yang harus tetap garing, kue ulang tahun berikut akuarium cupang, es krim yang cepat cair, laptop VIP di tengah badai, sampai patung kristal untuk Pak Wali Kota.

**Karena itu**, dengan memegang prinsip *"Trobos Ajalah!"*, Masbro harus bermanuver cerdas di antara kendaraan demi mengejar Timer ETA, menjaga paket dari benturan, sambil menghadapi Kuro si kurir rival yang suka membuang kulit pisang dan Pak Buldog yang galak.

**Sampai akhirnya**, kalau semua berjalan lancar, Masbro mengantar Patung Kristal Jeruk di hari kelima, resmi diangkat menjadi kurir tetap, melunasi sewa, dan Kedai Chill menjadi tempat istirahat para kurir kota.

Nasib Masbro ada di tanganmu.

### Tokoh

| Tokoh | Siapa |
| --- | --- |
| **Masbro** | Capybara pemilik Kedai Chill. Ultra santai, ekspresi datar, selalu membawa jeruk di kepala |
| **Bos Koko** | Kakatua, kepala kurir Ngacir Express. Memberi briefing pagi, menilai di malam hari, dan berteriak lewat **earpiece** saat paket hampir hancur atau waktu tipis |
| **Nana** | Bebek pelanggan VIP yang tidak sabaran, selalu membawa stopwatch (Hari 1 dan 4) |
| **Kuro "El Gato"** | Kucing hitam, kurir senior CepatKilat Corp yang naik motor bebek balap. Rival Masbro mulai Hari 2 |
| **Pak Buldog** | Buldog satpam komplek. Tidak suka orang lari-lari di komplek (Hari 3–5) |
| **Pemilik Lahan** | Kambing berjas, pemilik tanah Kedai Chill yang menagih sewa |
| **Pak Wali Kota** | Singa berbatik, pelanggan paling teliti sekota (Hari 5) |

Setelah tiap pengiriman, cerita berlanjut dengan **malam di Kedai Chill**. Kalau paket terjaga dengan baik, malamnya lebih ceria.

---

## 2. Cara Memainkan

### Versi Web (browser)

1. Buka link game atau file `index.html` dari paket **SiNgacir-web** yang sudah di-upload ke server/itch.io.
2. Tunggu loading selesai, lalu klik/tap layar sekali (browser baru mengizinkan suara setelah interaksi pertama).
3. Bisa dimainkan di laptop maupun HP. Di HP cukup **swipe**: kiri, kanan, atau atas (tap juga untuk maju). Posisi tegak (potret) paling nyaman: petak lebih besar dan jalan di depan lebih banyak terlihat.

> File `index.html` tidak bisa dibuka langsung dengan klik dua kali; harus lewat web server (itch.io, GitHub Pages, atau `python -m http.server`).

### Versi Desktop (Windows)

1. Ekstrak **SiNgacir-windows.zip**.
2. Jalankan `SiNgacir.exe`. Tidak perlu instalasi.
3. Jika muncul peringatan Windows SmartScreen, pilih **More info → Run anyway** (game belum memiliki tanda tangan digital).

Kebutuhan minimal: Windows 10 64-bit, kartu grafis yang mendukung OpenGL 3.3.

---

## 3. Kontrol

| Aksi | Keyboard | Layar sentuh |
| --- | --- | --- |
| Maju | W / ↑ | Tap layar atau swipe ke atas |
| Mundur | S / ↓ | Swipe ke bawah |
| Kiri / kanan | A / ← , D / → | Swipe ke kiri/kanan |
| Pause | Esc / P | Tombol **II** di pojok kanan atas |
| Bisukan / nyalakan suara | M | Pengaturan → **Bisukan semua suara** |
| Pilih tombol menu | Enter / klik | Tap |
| Lanjut cutscene | Enter / klik | Tap |
| Lewati cutscene | Esc | Tombol **Lewati** |
| Mode Auto (halaman maju sendiri) | Tombol **Auto** | Tombol **Auto** |

Satu kali tekan = satu langkah. Tahan tombol arah sebentar untuk melangkah terus-menerus.

Di cutscene, ketuk atau klik di mana saja (termasuk kotak teks dan gambar) untuk lanjut.

**Tips tutorial** muncul sekali di atas layar saat kamu pertama kali bertemu sesuatu yang baru (koin, power-up, lubang, sungai, Pos, dan lainnya). Tips bisa dimatikan, atau dinyalakan lagi untuk mengulang semuanya, di **Pengaturan**.

---

## 4. Tujuan Permainan

Masbro berangkat dari **Gudang Ngacir Express** (bawah) **tanpa paket**:

1. **Ambil paket** di **kios penjemputan** milik pengirim, kira-kira di tengah rute (cari ikon paket melayang bertuliskan **AMBIL**). Injak petak kiosnya.
2. **Antar paket** ke **rumah pelanggan** (atas).

Sebelum paket diambil, tabrakan dan tercebur hanya membuat Masbro terpental, paket belum bisa rusak. Setelah diambil, paket bisa rusak dan paket berat (kue ultah & akuarium cupang) membuat langkah lebih lambat. Sampai di rumah pelanggan tanpa paket belum dihitung selesai.

Rute bisa jauh lebih panjang dari satu layar; layar ikut bergerak naik mengikuti Masbro. ETA sudah menghitung waktu mampir ke kios.

Setiap kali hari dimulai, **susunan jalan dibuat ulang secara acak**, jadi tidak ada dua pengiriman yang persis sama. Makin dekat ke rumah pelanggan, kendaraan makin cepat.

Kumpulkan upah dari 5 hari masa percobaan. Jika total tabungan mencukupi tunggakan sewa (Rp350.000), Masbro lulus dan Kedai Chill selamat.

---

## 5. Layar Permainan

```
┌──────────────────────────────────────────────────────────┐
│ HARI 1   GORENGAN ■■■■          ETA 00:24   ANTAR KE: ... │  ← bar informasi
├──────────────────────────────────────────────────────────┤
│ Rumah pelanggan (tujuan)                                 │
│ ════ jalan ════  🚗      🛵                               │
│ ──── median (aman) ────            [Kios: AMBIL paket]   │
│ ════ jalan ════      🚚                                  │
│ Gudang Ngacir Express (mulai)          Masbro            │
└──────────────────────────────────────────────────────────┘
```

| Elemen | Arti |
| --- | --- |
| **HARI** | Hari ke berapa dari masa percobaan |
| **Kotak paket ■■■** | Kondisi paket. Satu kotak hilang setiap kali paket rusak. Semua hilang = paket hancur |
| **Garis rute** | Titik kuning = Masbro, kotak cokelat = kios penjemputan (hilang setelah paket diambil), rumah merah = tujuan |
| **ETA** | Sisa waktu target pengantaran (makin panjang rute, makin lama). Kuning saat ≤10 detik, merah "TELAT" bila lewat |
| **AMBIL DI / KE** | Tujuan sekarang: kios pengirim sebelum paket diambil, lalu nama pelanggan |

---

## 6. Sistem Permainan

### Paket = nyawa

Masbro tidak punya nyawa. Yang harus dijaga adalah **paket**. Setiap tabrakan mengurangi kondisi paket, Masbro terpental satu langkah ke belakang, lalu kebal sebentar (berkedip). Jika paket hancur, pengiriman gagal dan upah hari itu hangus untuk ganti rugi.

| Kendaraan | Kecepatan | Kerusakan paket |
| --- | --- | --- |
| Motor | Cepat | 1 |
| Mobil | Sedang | 1 |
| Bajaj | Cukup cepat, 1 petak | 1 |
| Angkot | Sedang, 2 petak | 1 |
| Truk | Lambat, panjang | 2 |
| Bus kota | Paling lambat, 4 petak | 2 |

### Timer ETA

Sampai sebelum ETA habis untuk mendapat **bonus tepat waktu**. Terlambat tidak membuat gagal, tetapi upah dipotong per detik keterlambatan.

### Upah harian

```
Upah = Upah dasar + Bonus tepat waktu (+ Tip) (+ Bonus koin) − Denda kerusakan − Potongan telat
```

Upah setiap hari ditambahkan ke **tabungan sewa**. Jika mengulang hari, yang dihitung adalah upah **terbaik** hari itu.

### Pelanggan menunggu

Pelanggan berdiri di depan rumahnya dan bereaksi lewat balon ucapan: menyapa saat paket diambil, menyemangati saat Masbro sudah dekat, mulai gelisah saat ETA hampir habis, dan girang (atau kecewa) saat paket tiba.

### Rating pelanggan

Setelah paket sampai, pelanggan memberi 1–5 bintang dan komentar, berdasarkan kondisi paket dan ketepatan waktu.

| Bintang | Contoh komentar |
| --- | --- |
| ★★★★★ | "Mukanya santai, tapi paketnya mulus tanpa lecet. Mantap!" |
| ★★★★ | "Paket agak penyok, tapi masih aman." |
| ★★★ | "Lain kali lebih hati-hati, Masbro." |
| ★★ | "Paketnya agak hancur, tapi isinya masih bisa dipakai." |
| ★ | "Ini paket atau hasil bongkar muatan kapal karam?!" |

Nana dan Pak Wali Kota punya komentar sendiri. Jika paket hancur, Bos Koko ikut mengomel.

---

## 7. Lima Hari Masa Percobaan

| Hari | Paket | Pelanggan | Tantangan |
| --- | --- | --- | --- |
| 1 "Gorengan Pantang Melempem" (Pasar) | Gorengan Hangat | Nana (tidak sabaran) | Pengenalan. Paket tahan 4 benturan; kejar ETA supaya gorengan masih garing |
| 2 "Jangan Goyah, Barang Pecah Belah" (Sekolah) | Kue Ultah & Akuarium Cupang | Bu Sri | Paket berat: langkah Masbro lebih lambat. Sungai pertama, kucing jalanan, Kuro dan kulit pisang |
| 3 "Labirin Gang Sempit" (Perumahan) | Es Krim | Pak Budi | ETA paling ketat (potongan telat Rp1.500/detik), lebih banyak galian pipa (lubang), Pak Buldog |
| 4 "Badai di Jam Sibuk" (Pusat Kota) | Laptop VIP | Nana (tidak sabaran) | Hujan badai: pandangan terbatas, jalan licin, sungai lebih sering |
| 5 "Ujian Akhir: Kristal Jeruk" (Kawasan Bisnis) | Patung Kristal Jeruk | Pak Wali Kota (teliti) | Semua tantangan sekaligus. Paket hancur hanya dengan 2 kerusakan |

### Rintangan di jalan

| Rintangan | Efek |
| --- | --- |
| **Cone & pembatas jalan** (di median) | Menghalangi langkah. Geser ke kiri/kanan lalu lanjut |
| **Lubang** (di aspal) | Masbro terperosok: paket rusak 1 dan Masbro kembali ke petak sebelumnya |

### Sungai

Mulai Hari 2, sebagian blok jalan bisa berupa **sungai**. Lompat ke atas **rakit** yang hanyut; selama berdiri di rakit, Masbro ikut terbawa arus.

* Melompat ke air tanpa rakit, rakit menjauh, atau terbawa sampai keluar layar → **paket basah** (rusak 1) dan Masbro kembali ke tepian terakhir.
* Pijakan di sungai: **rakit** (2 atau 3 petak) dan **perahu kayu** (2 atau 3 petak). Setiap petak pijakan terlihat sebagai satu panel kayu (rakit) atau satu bangku (perahu), dipisah ikatan tali, jadi panjangnya mudah dihitung.
* Lane sungai yang bersebelahan mengalir berlawanan arah dan dipisah garis busa putus-putus. Perhatikan rakit di lane berikutnya sebelum melompat.
* Mendarat sedikit di luar ujung rakit masih dihitung naik; Masbro otomatis bergeser ke atas rakit.
* Helm juga melindungi dari air.

### Warga Kota Ngacir

| NPC | Perilaku |
| --- | --- |
| **Pengemudi** | Membunyikan klakson "Tin tin!" bila Masbro berdiri tepat di depan kendaraannya. Tanda untuk segera menyingkir! |
| **Pejalan kaki** | Ibu-ibu belanja dan anak berbalon berjalan pelan di median. Tidak merusak paket, tapi menghalangi ("Permisi, Mas!") |
| **Pedagang bakso** | Gerobak diam di median, menghalangi langkah dan berteriak "Bakso! Bakso!" |
| **Kuro** | Kurir rival yang tiba-tiba melesat sangat cepat dengan motor balapnya di salah satu lane ("Minggir, kapibara!"), mulai Hari 2. Menabraknya tetap merusak paket, dan kadang ia membuang **kulit pisang** di lane yang ia lewati |
| **Pak Buldog** | Duduk di median mulai Hari 3. Bila Masbro lewat dalam jarak 1 petak, ia menggonggong ("GUK! GUK!") |

### Pos (checkpoint)

Mulai Hari 2, rute panjang punya **Pos** setiap beberapa blok: median bersih bertanda bendera di kedua sisinya. Begitu Masbro menginjak Pos, benderanya berubah kuning.

Jika paket hancur **setelah** melewati Pos, kamu bisa memilih **Lanjut dari Pos**: paket pengganti diambil dan perjalanan dilanjutkan dari Pos. Konsekuensinya:

* Denda ganti paket (Rp15.000; Rp20.000 untuk Patung Kristal Jeruk) dipotong dari upah.
* Rating maksimal 3 bintang.
* Waktu tetap berjalan.

### Koin & power-up

| Item | Efek |
| --- | --- |
| **Koin** | Langsung masuk dompet (angka koin di bar atas), dan +Rp1.000 per koin ke upah sebagai *Bonus koin* saat paket sampai |
| **Helm** | Gelembung pelindung: menahan 1 tabrakan atau lubang tanpa merusak paket |
| **Sepatu** | Langkah 40% lebih cepat selama 8 detik |

### Rintangan khusus

**Kucing jalanan** — tidak merusak paket, tetapi menghalangi langkah ("Meong!"). Cari jalur memutar. Kucing yang menyentuh Masbro akan duduk sebentar karena penasaran dengan tas kurirnya.

**Hujan** — hanya area di sekitar Masbro yang terlihat jelas. Di aspal basah, Masbro bisa **tergelincir** satu langkah tambahan ("Licin!"). Median dan trotoar tidak licin.

**Kulit pisang** — dibuang Kuro di lane yang ia lewati. Menginjaknya membuat Masbro tergelincir satu petak ("Kulit pisang!").

**Pak Buldog, mode panik** — gonggongannya membuat layar bergetar dan Masbro panik: langkah lebih cepat selama 3 detik, tetapi bisa tergelincir di aspal. Jangan lewat terlalu dekat kalau di depan ada lane ramai.

**Earpiece Bos Koko** — saat kondisi paket tinggal sedikit atau sisa ETA ≤ 15 detik, Bos Koko berteriak lewat banner di bawah bar atas (masing-masing sekali per hari). Tanda untuk lebih hati-hati atau bergegas.

**Nana, pelanggan tidak sabaran** (Hari 1 dan 4) — potongan telat 2x lipat dan rating maksimal 3 bintang bila telat. Jika paket sempurna dan tepat waktu, Nana memberi **tip**.

**Pak Wali Kota, pelanggan teliti** (Hari 5) — denda kerusakan 2x lipat dan rating maksimal 3 bintang bila paket lecet sedikit pun. Jika paket sempurna dan tepat waktu, Pak Wali Kota memberi **tip**.

---

## 8. Toko Masbro

Koin yang dipungut di jalan **langsung masuk dompet** (angkanya terlihat di bar atas, sama dengan di toko) dan tetap tersimpan walau paket hancur atau hari diulang. Saat paket sampai, koin juga menambah upah (*Bonus koin*). Belanjakan di **Toko Masbro** (menu utama):

| Slot | Pilihan |
| --- | --- |
| Topi | Jeruk Kepala (gratis), Caping, Beanie, Topi Koki, Mahkota |
| Kacamata | Piksel (gratis), Bulat, Hitam, Bintang |
| Tas | Pink, Oranye, Kucing |

Klik barang untuk membeli; klik barang milikmu untuk memakai atau melepasnya. Aksesori langsung terlihat saat mengantar paket. Dompet dan koleksi **tidak hilang** saat memilih Mulai Baru.

## 9. Akhir Cerita

Setelah Hari 5, total tabungan dibandingkan dengan tunggakan sewa Kedai Chill.

* **Tabungan cukup** — Masbro lulus masa percobaan, diangkat menjadi kurir tetap, dan sewa lunas. Kedai Chill menjadi tempat istirahat para kurir kota.
* **Tabungan kurang** — Pemilik Lahan masih memberi waktu. Layar rekap menampilkan upah tiap hari; pilih hari mana pun untuk diulang dan perbaiki upahnya.

Setelah lulus, layar rekap (menu utama → **Lanjutkan**) membuka **Shift Malam**: tombol **Main Lagi** untuk setiap hari. Kedai Chill tetap butuh biaya operasional, jadi mainkan lagi untuk mengumpulkan koin tanpa Mulai Baru; upah terbaik tiap hari tetap tersimpan.

---

## 10. Menu dan Penyimpanan

| Menu | Fungsi |
| --- | --- |
| **Lanjutkan** | Melanjutkan dari hari terakhir yang belum selesai, diawali ringkasan singkat **Sebelumnya…** (bisa dilewati) |
| **Mulai Baru** | Memulai dari awal (tekan dua kali; progres lama terhapus) |
| **Toko Masbro** | Belanja aksesori dengan koin dari dompet |
| **Album Cerita** | Menonton ulang cutscene yang sudah pernah diputar. Cerita yang belum terbuka tampil **???**; tetap terbuka walau memilih Mulai Baru |
| **Pengaturan** | Volume musik, volume efek suara, volume suara NPC, bisukan semua suara, layar penuh (desktop), tips tutorial, bahasa (Indonesia / English, dari menu utama), aksesibilitas |
| **Keluar** | Menutup game (desktop) |

Game **otomatis pause** saat tab browser ditinggal, jendela kehilangan fokus, atau aplikasi HP diminimalkan. Di HP, layar bergetar saat menabrak atau paket rusak (bisa dimatikan di **Pengaturan → Getar saat menabrak**).

Progres tersimpan **otomatis** setiap kali satu hari selesai. Keluar di tengah hari berarti mengulang hari itu dari awal.

Saat pause: **Lanjut**, **Ulangi Hari**, **Pengaturan**, **Menu Utama**.

### Aksesibilitas

Di **Pengaturan → Aksesibilitas**:

| Opsi | Fungsi |
| --- | --- |
| **Ukuran teks** | Normal, Besar, atau Sangat Besar. Berlaku langsung di semua layar |
| **Buta warna** | Filter koreksi warna untuk Protanopia (merah), Deuteranopia (hijau), atau Tritanopia (biru) |
| **Kurangi efek gerak** | Mematikan goyangan layar, kilat putih dan putaran Masbro saat tertabrak, konfeti, animasi pop, denyut timer, gerak bayangan awan, dan gerak sinar matahari; transisi layar menjadi pudar biasa |
| **Tampilan 3D (beta)** | (Pengaturan → Lainnya; browser, Windows, dan Android) Jalanan digambar dalam 3D dengan kamera menyerong. Aturan main sama persis. Lebih berat, jadi matikan bila HP terasa lambat. Berlaku saat hari dimulai |
| **Efek cahaya** | Filter warna hangat, sinar matahari, dan sudut layar gelap di jalanan. Matikan bila HP terasa lambat atau gambar kurang jelas |

Masbro memakai **Jeruk Kepala** dan **Kacamata Piksel** sejak awal. Lepas atau ganti di **Toko Masbro** (slot Topi dan Kacamata).

---

## 11. Tips

1. **Median hijau adalah zona aman.** Berhenti di sana untuk membaca pola lalu lintas berikutnya.
2. **Truk lambat tapi panjang** dan merusak paket 2x. Jangan memotong tepat di depannya.
3. **Perhatikan arah lane.** Setiap lane bisa melaju ke arah berbeda.
4. **Hari 1 dan 4 (Nana):** telat dipotong dua kali lipat. Kejar ETA, tapi jangan nekat menerobos truk.
5. **Hari 2 (kue & akuarium):** langkah lebih lambat, jadi mulai menyeberang lebih awal. Perhatikan kulit pisang di lane yang baru dilewati Kuro.
6. **Hari 3 (es krim):** ETA paling ketat. Lihat galian di aspal sebelum melangkah, dan jaga jarak dari Pak Buldog bila lane di depan ramai.
7. **Saat hujan:** melangkah di aspal basah bisa tergelincir. Hindari berhenti tepat di depan lane berbahaya.
8. **Hari 5 (Pak Wali Kota):** patung kristal hancur dengan 2 benturan dan dendanya 2x. Lebih baik telat sedikit daripada patung pecah.
9. **Kucing menghalangi?** Geser ke kiri/kanan satu petak lalu lanjut maju.
10. **Bonus ETA vs. keamanan:** denda kerusakan biasanya lebih mahal daripada bonus tepat waktu.

---

## 12. Masalah Umum

| Masalah | Solusi |
| --- | --- |
| Web tidak ada suara | Klik/tap layar sekali, lalu cek volume di Pengaturan |
| Web hanya layar hitam / loading terus | Gunakan browser terbaru (Chrome, Edge, Firefox) dengan WebGL 2 aktif |
| Windows memblokir `SiNgacir.exe` | SmartScreen: **More info → Run anyway** |
| Ingin mengulang dari awal | Menu utama → **Mulai Baru** (tekan dua kali) |
| Tampilan terlalu kecil/besar | Game menyesuaikan sendiri dengan bentuk layar; di HP, putar ke posisi tegak (potret) untuk melihat lebih banyak jalan |

---

## 13. Tim Pengembang

**Varmintz KW Studio** — Pemrograman Game (7TI02), Program Studi Teknik Informatika, Depok, 2026

| Nama | Peran |
| --- | --- |
| Diah Ayu Puspasari | Project Manager |
| Ilyas Abdul Aziz | Game Developer |
| Firmansyah Dzakwan Arifien | Game Developer |
| Muhammad Afif Naufal | Writer Story |
| Luthfiyah Syaharani | Writer Story |
| Abdul Fattah Kamil | Illustrator & Audio |

Dosen: Jemiro Kasih, S.T., M.M.S.I. — Asisten: Fadhilah Neza, S.Kom.

Dibuat dengan Godot Engine 4.3.

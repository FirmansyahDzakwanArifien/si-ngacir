# SI NGACIR — "Trobos Ajalah!"

### Manual Pemain

---

## 1. Storyline

> *Masbro, seekor capybara yang membutuhkan biaya pengobatan untuk adiknya, harus menyelesaikan masa percobaan lima hari sebagai kurir Ngacir Express. Namun, tekanan waktu, lalu lintas, rintangan, dan risiko kerusakan paket dapat mengurangi upahnya dan mengancam kesempatan Masbro untuk mengumpulkan biaya pengobatan adiknya.*

**Suatu hari**, hiduplah Masbro, seekor capybara santai yang tinggal berdua bersama adiknya di Kota Ngacir.

**Setiap hari**, Masbro mencari rezeki dengan mengandalkan ketenangannya, demi memenuhi kebutuhan mereka berdua.

**Suatu ketika**, adiknya jatuh sakit parah dan membutuhkan biaya pengobatan rumah sakit yang sangat besar dalam waktu lima hari.

**Karena itu**, Masbro terdesak melamar di ekspedisi Ngacir Express. Ia harus lolos masa percobaan lima hari dengan mengantar rentetan paket berisiko: dari galon air yang berat, telur yang rapuh, hingga barang sensitif di tengah lalu lintas kota yang liar.

**Karena itu**, dengan memegang prinsip *"Trobos Ajalah!"*, Masbro harus bermanuver cerdas di antara kendaraan demi mengejar Timer ETA, sambil menjaga paket dari benturan agar upah hariannya tidak terpotong denda ganti rugi.

**Sampai akhirnya**, kalau semua berjalan lancar, Masbro menyelesaikan pengiriman Paket VIP di hari kelima, resmi diangkat menjadi kurir tetap, dan berhasil mengumpulkan biaya untuk menyembuhkan adiknya.

Nasib Masbro ada di tanganmu.

### Tokoh

| Tokoh | Siapa |
| --- | --- |
| **Masbro** | Capybara paling santai sekampung. Prinsipnya: cepat boleh, asal paket selamat |
| **Nana** | Adik Masbro yang sedang dirawat. Selalu menunggu Masbro pulang |
| **Bang Kilat** | Kurir rival yang suka ngebut demi rating. Lambat laun belajar bahwa cepat tidak selalu menang |
| **Bu Direktur** | Pemilik Ngacir Express yang menilai masa percobaan Masbro |
| **Bu Dokter** | Dokter yang merawat Nana |
| **Pak Ojan** | Pelanggan paling teliti sekota |

Setelah tiap pengiriman, cerita berlanjut dengan **malam di rumah** bersama Nana. Kalau paket terjaga dengan baik, malamnya lebih ceria.

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

Sebelum paket diambil, tabrakan dan tercebur hanya membuat Masbro terpental, paket belum bisa rusak. Setelah diambil, paket bisa rusak dan paket berat (galon) membuat langkah lebih lambat. Sampai di rumah pelanggan tanpa paket belum dihitung selesai.

Rute bisa jauh lebih panjang dari satu layar; layar ikut bergerak naik mengikuti Masbro. ETA sudah menghitung waktu mampir ke kios.

Setiap kali hari dimulai, **susunan jalan dibuat ulang secara acak**, jadi tidak ada dua pengiriman yang persis sama. Makin dekat ke rumah pelanggan, kendaraan makin cepat.

Kumpulkan upah dari 5 hari masa percobaan. Jika total tabungan mencukupi biaya pengobatan, Masbro lulus dan adiknya bisa berobat.

---

## 5. Layar Permainan

```
┌──────────────────────────────────────────────────────────┐
│ HARI 1   BANTAL ■■■■            ETA 00:24   ANTAR KE: ... │  ← bar informasi
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

Upah setiap hari ditambahkan ke **tabungan pengobatan**. Jika mengulang hari, yang dihitung adalah upah **terbaik** hari itu.

### Pelanggan menunggu

Pelanggan berdiri di depan rumahnya dan bereaksi lewat balon ucapan: menyapa saat paket diambil, menyemangati saat Masbro sudah dekat, mulai gelisah saat ETA hampir habis, dan girang (atau kecewa) saat paket tiba.

### Rating pelanggan

Setelah paket sampai, pelanggan memberi 1–5 bintang dan komentar, berdasarkan kondisi paket dan ketepatan waktu.

| Bintang | Contoh komentar |
| --- | --- |
| ★★★★★ | "Paketnya utuh, kurirnya santai. Recommended!" |
| ★★★★ | "Paket agak penyok, tapi masih aman." |
| ★★★ | "Hati-hati kalau antar paket, Masbro." |
| ★★ | "Masbro... paketnya rusak, tapi masih bisa diterima." |
| ★ | "Mas... ini paket apa habis perang?" |

---

## 7. Lima Hari Masa Percobaan

| Hari | Paket | Pelanggan | Tantangan |
| --- | --- | --- | --- |
| 1 (Kompleks Perumahan) | Bantal | Bu Sri | Pengenalan. Paket tahan beberapa benturan, lalu lintas ringan |
| 2 (Pasar Ngacir) | Galon Air | Pak Budi | Paket berat: langkah Masbro lebih lambat. Kucing jalanan mulai muncul |
| 3 (Sekitar Sekolah) | Telur | Pak Ojan | Paket rapuh (kerusakan 2x lipat) dan pelanggan perfeksionis |
| 4 (Pusat Kota) | Barang Sensitif | Pak Joko | Hujan deras di jam sibuk: pandangan terbatas, jalan licin |
| 5 (Kawasan Bisnis) | Paket VIP | Bu Direktur | Semua tantangan sekaligus. Paket hancur hanya dengan 2 kerusakan |

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
| **Bang Kilat** | Kurir rival yang tiba-tiba melesat sangat cepat di salah satu lane ("Minggir, Masbro!"), mulai Hari 3. Menabraknya tetap merusak paket |

### Pos (checkpoint)

Mulai Hari 2, rute panjang punya **Pos** setiap beberapa blok: median bersih bertanda bendera di kedua sisinya. Begitu Masbro menginjak Pos, benderanya berubah kuning.

Jika paket hancur **setelah** melewati Pos, kamu bisa memilih **Lanjut dari Pos**: paket pengganti diambil dan perjalanan dilanjutkan dari Pos. Konsekuensinya:

* Denda ganti paket (Rp15.000; Rp20.000 untuk Paket VIP) dipotong dari upah.
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

**Pak Ojan, pelanggan perfeksionis** — denda kerusakan 2x lipat dan rating maksimal 3 bintang bila paket lecet sedikit pun. Tetapi jika paket sempurna dan tepat waktu, Pak Ojan memberi **tip**.

---

## 8. Toko Masbro

Koin yang dipungut di jalan **langsung masuk dompet** (angkanya terlihat di bar atas, sama dengan di toko) dan tetap tersimpan walau paket hancur atau hari diulang. Saat paket sampai, koin juga menambah upah (*Bonus koin*). Belanjakan di **Toko Masbro** (menu utama):

| Slot | Pilihan |
| --- | --- |
| Topi | Caping, Beanie, Topi Koki, Mahkota |
| Kacamata | Bulat, Hitam, Bintang |
| Tas | Pink, Oranye, Kucing |

Klik barang untuk membeli; klik barang milikmu untuk memakai atau melepasnya. Aksesori langsung terlihat saat mengantar paket. Dompet dan koleksi **tidak hilang** saat memilih Mulai Baru.

## 9. Akhir Cerita

Setelah Hari 5, total tabungan dibandingkan dengan biaya pengobatan.

* **Tabungan cukup** — Masbro lulus masa percobaan dan diangkat menjadi kurir tetap.
* **Tabungan kurang** — layar rekap menampilkan upah tiap hari. Pilih hari mana pun untuk diulang dan perbaiki upahnya.

Setelah lulus, layar rekap (menu utama → **Lanjutkan**) tetap menyediakan tombol **Main Lagi** untuk setiap hari. Mainkan lagi untuk mengumpulkan koin tanpa Mulai Baru; upah terbaik tiap hari tetap tersimpan.

---

## 10. Menu dan Penyimpanan

| Menu | Fungsi |
| --- | --- |
| **Lanjutkan** | Melanjutkan dari hari terakhir yang belum selesai, diawali ringkasan singkat **Sebelumnya…** (bisa dilewati) |
| **Mulai Baru** | Memulai dari awal (tekan dua kali; progres lama terhapus) |
| **Toko Masbro** | Belanja aksesori dengan koin dari dompet |
| **Album Cerita** | Menonton ulang cutscene yang sudah pernah diputar. Cerita yang belum terbuka tampil **???**; tetap terbuka walau memilih Mulai Baru |
| **Pengaturan** | Volume musik, volume efek suara, layar penuh (desktop), tips tutorial, bahasa (Indonesia / English, dari menu utama), aksesibilitas |
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

Masbro memakai **Kacamata Piksel** sejak awal. Lepas atau ganti di **Toko Masbro → Kacamata**.

---

## 11. Tips

1. **Median hijau adalah zona aman.** Berhenti di sana untuk membaca pola lalu lintas berikutnya.
2. **Truk lambat tapi panjang** dan merusak paket 2x. Jangan memotong tepat di depannya.
3. **Perhatikan arah lane.** Setiap lane bisa melaju ke arah berbeda.
4. **Hari 2 (galon):** langkah lebih lambat, jadi mulai menyeberang lebih awal.
5. **Hari 3 (telur):** satu tabrakan motor sudah merusak 2 kotak. Lebih baik telat sedikit daripada telur pecah.
6. **Saat hujan:** melangkah di aspal basah bisa tergelincir. Hindari berhenti tepat di depan lane berbahaya.
7. **Kucing menghalangi?** Geser ke kiri/kanan satu petak lalu lanjut maju.
8. **Bonus ETA vs. keamanan:** denda kerusakan biasanya lebih mahal daripada bonus tepat waktu.

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

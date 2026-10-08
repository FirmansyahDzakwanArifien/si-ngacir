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

---

## 2. Cara Memainkan

### Versi Web (browser)

1. Buka link game atau file `index.html` dari paket **SiNgacir-web** yang sudah di-upload ke server/itch.io.
2. Tunggu loading selesai, lalu klik/tap layar sekali (browser baru mengizinkan suara setelah interaksi pertama).
3. Bisa dimainkan di laptop maupun HP. Di HP, gunakan kontrol sentuh.

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
| Maju | W / ↑ | Tap layar, swipe ke atas, atau D-pad ▲ |
| Mundur | S / ↓ | Swipe ke bawah atau D-pad ▼ |
| Kiri / kanan | A / ← , D / → | Swipe ke kiri/kanan atau D-pad ◀ ▶ |
| Pause | Esc / P | Tombol **II** di pojok kanan atas |
| Pilih tombol menu | Enter / klik | Tap |
| Lanjut cutscene | Enter / klik | Tap |
| Lewati cutscene | Esc | Tombol **Lewati** |

Tahan tombol arah untuk melangkah terus-menerus.

---

## 4. Tujuan Permainan

Bawa paket dari **Gudang Ngacir Express** (bawah layar) ke **rumah pelanggan** (atas layar), menyeberangi jalan yang penuh kendaraan.

Kumpulkan upah dari 5 hari masa percobaan. Jika total tabungan mencukupi biaya pengobatan, Masbro lulus dan adiknya bisa berobat.

---

## 5. Layar Permainan

```
┌──────────────────────────────────────────────────────────┐
│ HARI 1   BANTAL ■■■■            ETA 00:24   ANTAR KE: ... │  ← bar informasi
├──────────────────────────────────────────────────────────┤
│ Rumah pelanggan (tujuan)                                 │
│ ════ jalan ════  🚗      🛵                               │
│ ──── median (aman) ────                                  │
│ ════ jalan ════      🚚                                  │
│ Gudang Ngacir Express (mulai)          Masbro            │
└──────────────────────────────────────────────────────────┘
```

| Elemen | Arti |
| --- | --- |
| **HARI** | Hari ke berapa dari masa percobaan |
| **Kotak paket ■■■** | Kondisi paket. Satu kotak hilang setiap kali paket rusak. Semua hilang = paket hancur |
| **ETA** | Sisa waktu target pengantaran. Berubah merah "TELAT" bila lewat |
| **ANTAR KE** | Nama pelanggan tujuan |

---

## 6. Sistem Permainan

### Paket = nyawa

Masbro tidak punya nyawa. Yang harus dijaga adalah **paket**. Setiap tabrakan mengurangi kondisi paket, Masbro terpental satu langkah ke belakang, lalu kebal sebentar (berkedip). Jika paket hancur, pengiriman gagal dan upah hari itu hangus untuk ganti rugi.

| Kendaraan | Kecepatan | Kerusakan paket |
| --- | --- | --- |
| Motor | Cepat | 1 |
| Mobil | Sedang | 1 |
| Truk | Lambat, panjang | 2 |

### Timer ETA

Sampai sebelum ETA habis untuk mendapat **bonus tepat waktu**. Terlambat tidak membuat gagal, tetapi upah dipotong per detik keterlambatan.

### Upah harian

```
Upah = Upah dasar + Bonus tepat waktu (+ Tip) − Denda kerusakan − Potongan telat
```

Upah setiap hari ditambahkan ke **tabungan pengobatan**. Jika mengulang hari, yang dihitung adalah upah **terbaik** hari itu.

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
| 1 | Bantal | Bu Sri | Pengenalan. Paket tahan beberapa benturan, lalu lintas ringan |
| 2 | Galon Air | Pak Budi | Paket berat: langkah Masbro lebih lambat. Kucing jalanan mulai muncul |
| 3 | Telur | Pak Ojan | Paket rapuh (kerusakan 2x lipat) dan pelanggan perfeksionis |
| 4 | Barang Sensitif | Pak Joko | Hujan deras di jam sibuk: pandangan terbatas, jalan licin |
| 5 | Paket VIP | Bu Direktur | Semua tantangan sekaligus. Paket hancur hanya dengan 2 kerusakan |

### Rintangan khusus

**Kucing jalanan** — tidak merusak paket, tetapi menghalangi langkah ("Meong!"). Cari jalur memutar. Kucing yang menyentuh Masbro akan duduk sebentar karena penasaran dengan tas kurirnya.

**Hujan** — hanya area di sekitar Masbro yang terlihat jelas. Di aspal basah, Masbro bisa **tergelincir** satu langkah tambahan ("Licin!"). Median dan trotoar tidak licin.

**Pak Ojan, pelanggan perfeksionis** — denda kerusakan 2x lipat dan rating maksimal 3 bintang bila paket lecet sedikit pun. Tetapi jika paket sempurna dan tepat waktu, Pak Ojan memberi **tip**.

---

## 8. Akhir Cerita

Setelah Hari 5, total tabungan dibandingkan dengan biaya pengobatan.

* **Tabungan cukup** — Masbro lulus masa percobaan dan diangkat menjadi kurir tetap.
* **Tabungan kurang** — layar rekap menampilkan upah tiap hari. Pilih hari mana pun untuk diulang dan perbaiki upahnya.

---

## 9. Menu dan Penyimpanan

| Menu | Fungsi |
| --- | --- |
| **Lanjutkan** | Melanjutkan dari hari terakhir yang belum selesai |
| **Mulai Baru** | Memulai dari awal (tekan dua kali; progres lama terhapus) |
| **Pengaturan** | Volume musik, volume efek suara, layar penuh (desktop) |
| **Keluar** | Menutup game (desktop) |

Progres tersimpan **otomatis** setiap kali satu hari selesai. Keluar di tengah hari berarti mengulang hari itu dari awal.

Saat pause: **Lanjut**, **Ulangi Hari**, **Pengaturan**, **Menu Utama**.

---

## 10. Tips

1. **Median hijau adalah zona aman.** Berhenti di sana untuk membaca pola lalu lintas berikutnya.
2. **Truk lambat tapi panjang** dan merusak paket 2x. Jangan memotong tepat di depannya.
3. **Perhatikan arah lane.** Setiap lane bisa melaju ke arah berbeda.
4. **Hari 2 (galon):** langkah lebih lambat, jadi mulai menyeberang lebih awal.
5. **Hari 3 (telur):** satu tabrakan motor sudah merusak 2 kotak. Lebih baik telat sedikit daripada telur pecah.
6. **Saat hujan:** melangkah di aspal basah bisa tergelincir. Hindari berhenti tepat di depan lane berbahaya.
7. **Kucing menghalangi?** Geser ke kiri/kanan satu petak lalu lanjut maju.
8. **Bonus ETA vs. keamanan:** denda kerusakan biasanya lebih mahal daripada bonus tepat waktu.

---

## 11. Masalah Umum

| Masalah | Solusi |
| --- | --- |
| Web tidak ada suara | Klik/tap layar sekali, lalu cek volume di Pengaturan |
| Web hanya layar hitam / loading terus | Gunakan browser terbaru (Chrome, Edge, Firefox) dengan WebGL 2 aktif |
| Windows memblokir `SiNgacir.exe` | SmartScreen: **More info → Run anyway** |
| Ingin mengulang dari awal | Menu utama → **Mulai Baru** (tekan dua kali) |
| Kontrol sentuh tidak muncul di laptop layar sentuh | Gunakan keyboard; D-pad hanya muncul bila browser melaporkan layar sentuh |

---

## 12. Tim Pengembang

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

# Story Si Ngacir — "Trobos Ajalah"

Naskah cerita versi game, diadaptasi dari dokumen **Story Game Varmintz KW Studio (07 Oktober 2026)** oleh tim Writer Story. Dokumen asli menggambarkan game balap skuter; Si Ngacir adalah game **menyeberang jalan berbasis petak** (Masbro berjalan kaki). Karena itu beberapa poin disesuaikan supaya cerita masuk akal dengan cara main, dan semua yang tertulis di sini benar-benar ada di game.

Naskah yang diputar ada di `resources/story/*.tres` (teks Indonesia) dan `translations/strings.csv` (Inggris). Dokumen ini adalah ringkasannya.

## 1. Dunia

Kota Ngacir: kota metropolitan hewan yang padat, bising, dan serba buru-buru. Semua orang ngebut, semua orang dikejar rating.

Di tengahnya ada **Kedai Chill**, kedai minum dan kolam air hangat milik Masbro, tempat warga kota melepas penat sepulang kerja.

**Ngacir Express** adalah jasa kurir terbesar di kota, dengan moto *"Kalo gak kilat, gak selamat!"*. Kurirnya **jalan kaki**: di kota semacet ini, kurir yang berani menyeberang lebih cepat sampai daripada motor yang terjebak macet. Upah dibayar harian, dipotong bila telat atau paket rusak.

Nada: komedi absurd dan satir jalanan sehari-hari (angkot, bajaj, galian pipa, pelanggan yang menghitung detik), dengan Masbro yang tetap datar di tengah kekacauan.

## 2. Tokoh

| Tokoh | Siapa | Di game |
| --- | --- | --- |
| **Masbro** (Broderick Capybarov) | Capybara pemilik Kedai Chill. Ultra santai, ekspresi datar, selalu membawa jeruk di kepala | Tokoh yang dimainkan. Jeruk di kepala adalah aksesori bawaan (bisa dilepas di Toko) |
| **Bos Koko** | Kakatua, kepala kurir Ngacir Express. Kemeja kebesaran, dasi merah, clipboard raksasa. Jambulnya berdiri kalau marah | Memberi briefing di cutscene pagi, menilai di malam hari, dan berteriak lewat **earpiece** saat paket hampir hancur atau waktu tipis |
| **Nana** | Bebek pelanggan VIP yang tidak sabaran, membawa stopwatch | Pelanggan Hari 1 dan Hari 4. **Pelanggan tidak sabaran**: potongan telat 2x, maks 3 bintang bila telat, tip bila sempurna |
| **Kuro "El Gato"** | Kucing hitam, kurir senior CepatKilat Corp. Kacamata hitam kecil, jaket balap, motor bebek balap | Rival dari Hari 2: melesat di lane jalan dan kadang **membuang kulit pisang** (menginjaknya bikin tergelincir satu petak) |
| **Pak Buldog** | Buldog satpam komplek, sarung di leher, topi ronda. Tidak suka orang lari-lari di komplek | Muncul Hari 3–5 di median. Kalau Masbro lewat dekat, ia **menggonggong**: Masbro panik dan ngacir (langkah lebih cepat beberapa detik, tapi gampang tergelincir di aspal) |
| **Pemilik Lahan** | Kambing berjas, pemilik tanah Kedai Chill | Membuka konflik (SP3) dan menutupnya di ending |
| **Pak Wali Kota** | Singa berbatik dengan selempang | Pelanggan Hari 5. **Pelanggan teliti**: denda kerusakan 2x, maks 3 bintang bila paket lecet, tip bila sempurna |

Pelanggan lain: **Bu Sri** (Hari 2, kue ulang tahun cucunya) dan **Pak Budi** (Hari 3, es krim di Gang Tiga).

## 3. Alur besar

**Premis.** Masbro, capybara paling santai sekota, harus melunasi tunggakan sewa Kedai Chill dalam lima hari. Satu-satunya kerja yang dibayar harian adalah kurir masa percobaan di Ngacir Express.

**Target.** Tunggakan sewa **Rp350.000** (`GameState.RENT_DUE`). Upah maksimal lima hari Rp530.000 (upah dasar + bonus tepat waktu + tip, belum termasuk koin), jadi pemain tidak harus sempurna, tapi tidak boleh asal-asalan.

| Bagian | Cutscene | Isi |
| --- | --- | --- |
| Pembuka | `opening` | Kedai Chill yang damai → Pemilik Lahan menyerahkan SP3 → Masbro mendaftar di Ngacir Express → Bos Koko menjelaskan aturan → Kuro meremehkan |
| Hari 1 | (tanpa cutscene pagi) | Gorengan untuk Nana |
| Malam 1 | `evening_01_*` | Reaksi Nana, Bos Koko mengumumkan paket besok |
| Hari 2 | `day_02` | Kue ulang tahun + akuarium cupang. Kuro mulai muncul dan membuang kulit pisang |
| Malam 2 | `evening_02_*` | Kuro mengabarkan jalan utama ditutup galian pipa |
| Hari 3 | `day_03` | Es krim lewat gang perumahan, galian di aspal, Pak Buldog |
| Malam 3 | `evening_03_*` | Ramalan badai, pesanan VIP Nana |
| Hari 4 | `day_04` | Laptop VIP Nana di tengah badai |
| Malam 4 | `evening_04_*` | Nana terkesan (atau kesal), Bos Koko mengumumkan ujian akhir |
| Hari 5 | `day_05` | Patung Kristal Jeruk untuk Pak Wali Kota. Semua rintangan bergabung |
| Ending | `ending_success` / `ending_bad` | Sewa lunas dan Masbro jadi kurir tetap, atau tabungan belum cukup |

Versi malam *good* diputar bila kondisi paket ≥ 70%, *rough* bila lebih rendah.

### Ending

* **Lulus** (tabungan ≥ sewa): Pak Wali Kota menerima patungnya, Bos Koko mengangkat Masbro jadi kurir tetap, Kuro mengakui kalah dan minta izin nongkrong di Kedai Chill, sewa lunas. Kedai Chill jadi tempat istirahat para kurir kota.
* **Tabungan kurang** (aturan bawaan `REPLAY_DAYS`): Pemilik Lahan masih memberi waktu. Pemain boleh mengulang hari mana pun; upah terbaik tiap hari yang dihitung.
* **Ending gagal** (hanya bila `SHORTFALL_RULE = BAD_ENDING`): Kedai Chill disegel sampai sisa sewa lunas. Masbro tetap datar: "Belum selesai."

### Setelah lulus: Shift Malam

Konsep *Endless Mode* dari dokumen diwujudkan sebagai **Shift Malam**: setelah lulus, semua hari bisa dimainkan lagi untuk mengumpulkan koin (biaya operasional kedai dan aksesori di Toko). Mode tanpa batas dengan rute acak, leaderboard global, dan paket absurd (durian, balon helium, telur burung unta) dicatat sebagai rencana berikutnya, belum ada di build ini.

## 4. Per hari

| Hari | Judul | Paket | Pelanggan | Lokasi | Tantangan |
| --- | --- | --- | --- | --- | --- |
| 1 | Gorengan Pantang Melempem | Gorengan Hangat (tahan 4 benturan) | Nana (tidak sabaran) | Pasar | Dasar gerak dan lalu lintas, kejar ETA supaya gorengan masih garing |
| 2 | Jangan Goyah, Barang Pecah Belah | Kue Ultah & Akuarium Cupang (berat: langkah lebih lambat) | Bu Sri | Sekolah | Sungai pertama, Kuro dan kulit pisang, kucing jalanan |
| 3 | Labirin Gang Sempit | Es Krim (ETA paling ketat) | Pak Budi | Perumahan (Gang Tiga) | Galian pipa (lubang) lebih banyak, Pak Buldog, pejalan kaki |
| 4 | Badai di Jam Sibuk | Laptop VIP (tidak boleh basah) | Nana (tidak sabaran) | Pusat kota | Hujan badai: jarak pandang pendek, aspal licin, sungai lebih sering (banjir) |
| 5 | Ujian Akhir: Kristal Jeruk | Patung Kristal Jeruk (tahan 2 benturan) | Pak Wali Kota (teliti) | Kawasan bisnis (Balai Kota) | Rute terpanjang, Kuro paling sering, Pak Buldog, dua kucing, sisa hujan |

## 5. Earpiece Bos Koko dan pemicu cerita di jalan

| Pemicu | Kondisi | Yang terjadi |
| --- | --- | --- |
| Paket kritis | Kondisi paket ≤ 34% (sekali per hari) | Bos Koko: "WOI MASBRO! Isinya remuk tuh! Pelan-pelan dikit!" |
| Waktu tipis | Sisa ETA ≤ 15 detik (sekali per hari) | Bos Koko: "Waktu tipis, Masbro! Jangan ngelamun!" |
| Pelanggan menunggu | Sisa ETA ≤ 10 detik / telat | Balon ucapan pelanggan (Nana punya kalimat sendiri) |
| Mendekati rumah | Masbro dekat rumah pelanggan sambil membawa paket | Sapaan pelanggan (suara NPC) |
| Pak Buldog | Masbro lewat dalam jarak 1 petak | "GUK! GUK!", layar bergetar, mode panik |
| Kulit pisang | Masbro menginjak kulit pisang | "Licin!", tergelincir satu petak |

## 6. Penyesuaian dari dokumen asli

| Di dokumen | Di game | Alasan |
| --- | --- | --- |
| Masbro naik skuter dengan pendorong tabung LPG, drift, nitro | Masbro kurir **jalan kaki**; "ngacir" = sepatu (power-up) dan mode panik Pak Buldog | Game ini menyeberang jalan per petak, tidak ada kendaraan yang dikendarai. Tabung LPG di skuter juga tidak pantas dijadikan lelucon keselamatan |
| Jeruk di kepala sebagai meter keseimbangan | Jeruk sebagai ciri khas dan aksesori bawaan | Fungsi "nyawa" sudah dipegang kondisi paket; dua meter sekaligus membingungkan |
| Rating 3 bintang, tapi di bagian lain "bintang 4" dan "bintang 5" | Rating **1–5 bintang** | Dokumen tidak konsisten; game sudah memakai 1–5 |
| Target per misi dalam detik (< 90 detik), "darah skuter", *melt meter*, *water ingestion meter* | Timer **ETA** dan **kondisi paket** | Satu sistem penilaian untuk semua hari. Es krim = ETA paling ketat, laptop = tercebur ke sungai merusak paket |
| Day 4: tiga lokasi berturut-turut | Satu pelanggan, rute panjang dengan Pos | Satu hari = satu pengantaran di game ini |
| Day 5: mengalahkan Kuro di final sprint | Kuro paling sering muncul di Hari 5 | Tidak ada sistem balapan |
| Pak Buldog terpicu knalpot blong | Terpicu kalau Masbro lewat dekat pos rondanya | Masbro tidak naik kendaraan |
| Bad ending: paket kristal lebur, Masbro jadi pemutar roda hamster seumur hidup | Kedai Chill disegel sampai sisa sewa lunas | Taruhan yang masuk akal dan tetap ringan |
| Stakes: denda ganti rugi seumur hidup | Upah harian dipotong denda | Sudah jadi mekanik upah |
| "Lounge Istirahat Kurir Kapibara Pertama" | Tempat istirahat para kurir kota | Lebih natural |
| Ending: diserahkan tepat di detik 00:01 | Tidak disebut detiknya | Hasil tiap pemain berbeda |
| Dialog "Alhamdulillah. Kuncinya cuma satu: pasrah tapi tetep ngerem" | "Kuncinya satu: pasrah, tapi tetap ngerem." | Netral untuk semua pemain |
| "Kuro, kualimat lu..." | Dihapus | Salah ketik dan tidak jelas maksudnya |
| "sarung dastermu" | "Daster Ibu" (tips) | Sarung dan daster dua benda berbeda |
| Endless Mode, leaderboard global, garage | Shift Malam (Main Lagi) + Toko Masbro | Lihat bagian 3 |
| Variabel `{Nama_Penerima}`, `{Sisa_Waktu}`, dst. | Token `{saved}`, `{target}`, `{left}` di naskah, data per hari di `day_0N.tres` | Sudah ada sistemnya |

## 7. Untuk tim Writer Story

* Mengubah teks: edit `resources/story/*.tres` (Inspector Godot) **dan** kunci yang sama di `translations/strings.csv`.
* Kalimat pelanggan per hari ada di `day_0N.tres`: `customer_greeting`, `customer_hurry_line`, `customer_late_line`, `sender_line`.
* Komentar rating ada di `scripts/game/delivery_report.gd`, kalimat earpiece Bos Koko di `scripts/game/level.gd` (`KOKO_*`).
* Tokoh dan potret: `scripts/data/speakers.gd`, `assets/portraits/<tokoh>_<ekspresi>.svg`.

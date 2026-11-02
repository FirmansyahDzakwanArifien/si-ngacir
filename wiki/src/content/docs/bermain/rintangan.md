---
title: Rintangan & Item
description: Rintangan di jalan, sungai dan rakit, Pos checkpoint, koin, power-up, serta tantangan khusus seperti kucing, hujan, Kuro, Pak Buldog, dan pelanggan khusus.
---

## Rintangan di jalan

| Rintangan | Efek |
| --- | --- |
| <img class="sprite" src="/img/sprites/obstacle_cone.svg" alt="" /> **Cone** dan <img class="sprite" src="/img/sprites/obstacle_barrier.svg" alt="" /> **pembatas jalan** | Ada di median. Menghalangi langkah; geser ke kiri/kanan lalu lanjut |
| <img class="sprite" src="/img/sprites/obstacle_hole.svg" alt="" /> **Lubang** | Ada di aspal. Masbro terperosok ("GEDEBUK!"): paket rusak 1 dan Masbro kembali ke petak sebelumnya |
| <img class="sprite" src="/img/sprites/obstacle_gerobak.svg" alt="" /> **Gerobak bakso** | Diam di median dan menghalangi langkah |

## Sungai

Mulai Hari 2, sebagian blok jalan bisa berupa **sungai**. Lompat ke atas **rakit** atau **perahu kayu** yang hanyut; selama berdiri di atasnya, Masbro ikut terbawa arus.

| Pijakan | Panjang |
| --- | --- |
| <img class="sprite" src="/img/sprites/vehicle_rakit3.svg" alt="" /> Rakit | 2 atau 3 petak: satu panel kayu per petak, dipisah ikatan tali |
| <img class="sprite" src="/img/sprites/vehicle_perahu3.svg" alt="" /> Perahu kayu | 2 atau 3 petak: satu bangku per petak |

- Melompat ke air tanpa rakit, rakit menjauh, atau terbawa sampai keluar layar membuat Masbro tercebur ("BYUR!"): **paket basah** (rusak 1) dan Masbro kembali ke tepian terakhir.
- Lane sungai yang bersebelahan mengalir berlawanan arah dan dipisah garis busa putus-putus. Perhatikan rakit di lane berikutnya sebelum melompat.
- Mendarat sedikit di luar ujung rakit masih dihitung naik; Masbro otomatis bergeser ke atas rakit.
- Helm juga melindungi dari air.

## Pos (checkpoint)

Mulai Hari 2, rute panjang punya **Pos** setiap beberapa blok: median bersih bertanda bendera di kedua sisinya. <img class="sprite" src="/img/sprites/checkpoint_flag_on.svg" alt="" /> Begitu Masbro menginjak Pos, benderanya berubah kuning.

Jika paket hancur **setelah** melewati Pos, kamu bisa memilih **Lanjut dari Pos**: paket pengganti diambil dan perjalanan dilanjutkan dari Pos. Konsekuensinya:

- Denda ganti paket Rp15.000 (Rp20.000 untuk Patung Kristal Jeruk) dipotong dari upah.
- Rating maksimal 3 bintang.
- Waktu tetap berjalan.

## Koin & power-up

| Item | Efek |
| --- | --- |
| <img class="sprite" src="/img/sprites/item_coin.svg" alt="" /> **Koin** | Langsung masuk dompet (angka koin di bar atas) untuk belanja di [Toko Masbro](/fitur/toko/), dan +Rp1.000 per koin ke upah sebagai *Bonus koin* |
| <img class="sprite" src="/img/sprites/item_helmet.svg" alt="" /> **Helm** | Gelembung pelindung: menahan 1 tabrakan, lubang, atau tercebur tanpa merusak paket ("TENG!") |
| <img class="sprite" src="/img/sprites/item_shoes.svg" alt="" /> **Sepatu** | Langkah 40% lebih cepat selama 8 detik |

## Tantangan khusus

| Tantangan | Hari | Efek |
| --- | --- | --- |
| <img class="sprite" src="/img/sprites/cat_sit.svg" alt="" /> **Kucing jalanan** | 2–5 | Tidak merusak paket, tetapi menghalangi langkah. Kucing yang menyentuh Masbro duduk sebentar karena penasaran dengan tas kurirnya |
| **Hujan** | 4–5 | Hanya area sekitar Masbro yang terlihat jelas. Di aspal basah, Masbro bisa tergelincir satu langkah tambahan ("Licin!"). Median dan trotoar tidak licin |
| <img class="sprite" src="/img/sprites/vehicle_kuro.svg" alt="" /> **Kuro** | 2–5 | Kurir rival yang tiba-tiba melesat sangat cepat di satu lane ("Minggir, kapibara!"). Menabraknya tetap merusak paket |
| <img class="sprite" src="/img/sprites/item_kulit_pisang.svg" alt="" /> **Kulit pisang** | 2–5 | Kadang dibuang Kuro di lane yang ia lewati. Menginjaknya membuat Masbro tergelincir satu petak ("Kulit pisang!") |
| <img class="sprite" src="/img/sprites/buldog_sit.svg" alt="" /> **Pak Buldog** | 3–5 | Duduk di median. Bila Masbro lewat dalam jarak 1 petak, ia menggonggong ("GUK! GUK!"): layar bergetar dan Masbro **panik**, langkah lebih cepat selama 3 detik tetapi 30% peluang tergelincir di aspal |
| **Pelanggan tidak sabaran** | 1, 4 | Nana: potongan telat 2x lipat dan rating maksimal 3 bintang bila telat, tetapi memberi tip bila paket sempurna dan tepat waktu |
| **Pelanggan teliti** | 5 | Pak Wali Kota: denda kerusakan 2x lipat dan rating maksimal 3 bintang bila paket lecet, tetapi memberi tip bila paket sempurna dan tepat waktu |

## Earpiece Bos Koko

Selama pengiriman, Bos Koko memantau lewat **earpiece**. Teriakannya muncul sebagai banner di bawah bar atas, masing-masing sekali per hari:

| Pemicu | Teriakan |
| --- | --- |
| Kondisi paket ≤ 34% | "WOI MASBRO! Isinya remuk tuh! Pelan-pelan dikit!" |
| Sisa ETA ≤ 15 detik | "Waktu tipis, Masbro! Jangan ngelamun!" |

## Efek benturan

Setiap kejadian punya efek ala komik supaya jelas apa yang terjadi:

| Kejadian | Efek |
| --- | --- |
| Tertabrak | **BRAK!**, Masbro berputar, layar berhenti sejenak dan berkilat |
| Tercebur | **BYUR!**, riak dan gelembung air |
| Masuk lubang | **GEDEBUK!** dan debu |
| Helm pecah | **TENG!** dan serpihan |
| Paket hancur | **KRAK!** dan asap |

Efek kilat dan putaran bisa dimatikan lewat **Kurangi efek gerak** di [Pengaturan](/fitur/pengaturan/).

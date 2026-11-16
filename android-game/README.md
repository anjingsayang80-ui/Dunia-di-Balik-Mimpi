# Dunia di Balik Mimpi — Anime RPG 3D

Prototipe RPG 3D offline untuk Android, dibuat dengan Godot 4.3. Seluruh pekerjaan game berada di folder `android-game/`; folder komik dan berkas lain di luar folder ini tidak diubah.

## Menjalankan proyek
1. Instal Godot Engine 4.3 dan buka Project Manager.
2. Pilih **Import**, lalu pilih `android-game/project.godot`.
3. Jalankan proyek dengan **F6/F5**.
4. Pada Android, game menggunakan orientasi horizontal (landscape).

## Fitur yang sudah dibuat
- Arena 3D dengan pencahayaan, lantai, dan pilar.
- MC 3D sederhana dengan rambut, mata, pakaian, lengan dan kaki beranimasi prosedural saat berjalan, serta pedang dengan animasi ayunan.
- Slime dan Bos Mimpi dapat mengejar serta menyerang pemain; keduanya memberi efek kilat merah, perubahan bentuk singkat, dan angka kerusakan melayang saat terkena serangan. Bos memberi tanda cahaya kuning selama sekitar setengah detik sebelum pukulan jarak dekat.
- Kontrol Android: analog bulat di kiri, tombol SERANG dan KAGE BUNSHIN di kanan, serta swipe pada area kosong untuk memutar kamera mengelilingi pemain.
- Arah gerak analog mengikuti arah kamera.
- Kage Bunshin memunculkan tepat 3 bayangan biru selama 8 detik. Tidak ada cooldown; tombol dapat digunakan lagi kapan saja. Bayangan mengikuti MC, menyamakan gerakan lengan dan kaki dengan MC, dan otomatis menyerang Slime atau Bos yang berada dalam jangkauan.
- Quest berantai: kalahkan Slime, kumpulkan 3 Kristal Mimpi, lalu kalahkan Bos Mimpi.
- Hadiah monster biasa: Level +1 dan Kekuatan +0,2 (seperlima). Hadiah Bos: Level +5 dan Kekuatan +3.
- Inventaris dengan 2 Ramuan Kecil awal; satu ramuan memulihkan 30 HP hingga maksimum 100.
- Simpan otomatis untuk inventaris, level, kekuatan, quest, status bos, HP, dan posisi pemain.
- Saat HP habis, pemain kembali ke titik awal dengan HP penuh tanpa menghapus progres.

## Membuat dan mengambil APK
GitHub Actions menjalankan workflow **Build Android APK** setiap ada perubahan pada `android-game/`. Buka tab **Actions**, pilih build terbaru yang berstatus sukses, lalu unduh artefak `DuniaDiBalikMimpi-Android-debug`. APK debug ditujukan untuk pengujian, bukan rilis Play Store.

## Pengujian yang perlu dilakukan pada perangkat
1. Instal APK dan pastikan game terbuka dalam orientasi landscape.
2. Gerakkan analog ke semua arah, lepaskan jari, lalu pastikan knop analog kembali tepat ke tengah.
3. Geser area kosong untuk memutar kamera sambil tetap menggerakkan pemain.
4. Gunakan Kage Bunshin berulang kali; pastikan selalu muncul tepat tiga bayangan dan mereka menyerang musuh selama durasi jurus.
5. Selesaikan quest, gunakan ramuan, tutup game, lalu buka kembali untuk memeriksa penyimpanan progres.

## Batasan prototipe
Model karakter dan musuh saat ini masih dirakit dari mesh geometri dasar Godot, bukan model anime 3D profesional dengan rig dan animasi skeletal. Arena masih kecil dan jenis monster biasa baru Slime. Belum tersedia voice acting, musik/efek suara, dunia terbuka, toko, beragam monster, atau pengujian pada berbagai perangkat Android. APK yang berhasil diekspor oleh CI belum berarti semua perilaku sudah teruji di perangkat fisik.

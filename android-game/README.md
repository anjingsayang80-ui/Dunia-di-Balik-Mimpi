# Dunia di Balik Mimpi — Anime RPG 3D

Prototipe RPG 3D offline untuk Android, dibuat dengan Godot 4.3. Seluruh pekerjaan game berada di folder `android-game/`; folder komik dan berkas lain di luar folder ini tidak diubah.

## Menjalankan dan menguji di Godot
1. Instal Godot Engine 4.3, buka Project Manager, lalu pilih **Import** dan arahkan ke `android-game/project.godot`.
2. Pilih proyek dan tekan **F6/F5** untuk menjalankan arena.
3. Di komputer, gunakan tombol panah untuk bergerak dan seret mouse pada area kosong untuk memutar kamera. Di Android, gunakan analog kiri; tombol SERANG, HINDAR, KAGE BUNSHIN, dan TAS berada di layar.
4. Uji alur quest: kalahkan Slime, ambil 3 Kristal Mimpi yang muncul, lalu kalahkan Bos Mimpi.
5. Buka TAS: pastikan Lendir Slime, Kristal Mimpi, Koin, dan Ramuan terlihat. Kurangi HP dengan mendekati musuh, gunakan ramuan, lalu pastikan HP dan stok ramuan berubah.
6. Tutup lalu jalankan kembali game. Pastikan level, kekuatan, quest, inventaris, HP, dan posisi terakhir dimuat kembali.
7. Uji pemulihan save: salin/backup `user://savegame.cfg` sebelum pengujian; bila file hilang atau tidak terbaca, game harus mulai dengan 2 Ramuan Kecil. Data inventaris yang jumlahnya negatif atau bukan angka diabaikan saat dimuat.
8. Uji analog dengan beberapa sentuhan: lepaskan jari yang menggerakkan analog dan pastikan hanya sentuhan itu yang menghentikan gerakan; geser area kosong untuk memutar kamera.

## Ekspor Android APK secara lokal
1. Instal **JDK 17**, Android SDK (platform 34 dan build-tools 34.0.0), serta export templates Godot 4.3 yang versinya cocok dengan editor.
2. Di Godot, buka **Editor Settings → Export → Android** dan isi lokasi Android SDK serta Java SDK. Pastikan debug keystore tersedia.
3. Buka **Project → Export**, pilih preset **Android**, lalu ekspor sebagai `build/DuniaDiBalikMimpi-debug.apk`.
4. Alternatif melalui terminal dari folder repository:
   ```bash
   cd android-game
   mkdir -p build
   godot --headless --editor --path . --quit
   godot --headless --path . --export-debug "Android" build/DuniaDiBalikMimpi-debug.apk
   ```
5. Pastikan file APK benar-benar terbentuk sebelum dipindahkan ke ponsel. APK debug untuk pengujian; jangan gunakan sebagai rilis Play Store.

## Fitur yang sudah dibuat
- Arena 3D dengan pencahayaan, lantai, dan pilar.
- Batas arena menjaga pemain tetap di atas platform dan menghentikan gerakan saat mencapai tepi, agar tidak jatuh keluar dari area permainan.
- MC 3D bergaya anime dengan rambut runcing, mata, syal merah, mantel pendek, pelindung bahu emas, lengan dan kaki beranimasi prosedural saat berjalan, serta pedang dengan animasi ayunan dan efek busur cahaya biru setiap menyerang. Model masih berupa mesh geometri Godot, bukan aset karakter anime profesional.
- Slime dan Bos Mimpi dapat mengejar serta menyerang pemain; keduanya memberi efek kilat merah, perubahan bentuk singkat, dan angka kerusakan melayang saat terkena serangan, ditambah bar HP visual yang berkurang secara langsung untuk Slime dan Bos. Tombol HINDAR memberi dash singkat untuk mengelak dengan jeda pemulihan 2 detik, disertai indikator HUD yang menampilkan status siap atau hitung mundur pemulihannya. Bos memberi tanda cahaya kuning selama sekitar setengah detik sebelum pukulan jarak dekat.
- Kontrol Android: analog bulat di kiri, tombol SERANG dan KAGE BUNSHIN di kanan, serta swipe pada area kosong untuk memutar kamera mengelilingi pemain.
- Arah gerak analog mengikuti arah kamera.
- Kage Bunshin memunculkan tepat 3 bayangan biru selama 8 detik. Tidak ada cooldown; tombol dapat digunakan lagi kapan saja. Bayangan mengikuti MC, menyamakan gerakan lengan dan kaki dengan MC, dan otomatis menyerang Slime atau Bos yang berada dalam jangkauan.
- Quest berantai: kalahkan Slime, kumpulkan 3 Kristal Mimpi, lalu kalahkan Bos Mimpi.
- Hadiah monster biasa: Level +1 dan Kekuatan +0,2 (seperlima). Hadiah Bos: Level +5 dan Kekuatan +3.
- Inventaris dengan 2 Ramuan Kecil awal (+30 HP) dan Ramuan Besar (+60 HP) sebagai hadiah saat mengumpulkan 3 Kristal Mimpi. Tombol ramuan menampilkan jumlah barang dan nonaktif saat stok habis atau HP penuh; jumlah Koin ditampilkan terpisah.
- Simpan otomatis untuk inventaris, level, kekuatan, quest, status bos, HP, dan posisi pemain setiap 5 detik, serta saat aplikasi Android dijeda/ditutup. Loader save menormalisasi jumlah item dan memastikan urutan progres quest tetap valid saat memuat data lama/rusak.
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

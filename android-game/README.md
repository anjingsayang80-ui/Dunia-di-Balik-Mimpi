# Dunia di Balik Mimpi — Anime RPG 3D (Godot)

Prototipe game RPG 3D offline untuk Android. Folder ini terpisah dari komik di root repository.

## Membuka dan menguji di Godot
1. Instal Godot Engine 4.x.
2. Dari Godot Project Manager pilih **Import**.
3. Pilih file `android-game/project.godot`.
4. Buka proyek lalu tekan **F5**.
5. Di PC gunakan tombol panah / WASD untuk bergerak; tombol SERANG di layar untuk menyerang. Di Android gunakan layar horizontal (landscape), analog bulat di kiri, tombol SERANG di kanan, dan geser area kosong layar untuk memutar kamera.

## Fitur prototipe saat ini
- Arena 3D, pencahayaan, dan pilar dekoratif.
- Karakter bergaya anime sederhana dengan detail rambut, mata, kerah, dan pedang; seluruhnya masih dibuat dari mesh dasar Godot.
- Animasi ayunan pedang menggunakan Tween.
- Slime mengejar dan menyerang pemain.
- HP pemain dan HP monster.
- **Quest berantai:** kalahkan Slime untuk memperoleh Lendir Slime dan 10 Koin, lalu kumpulkan 3 Kristal Mimpi untuk bonus 20 Koin. Setelah itu Bos Mimpi muncul sebagai misi ketiga.
- Kristal Mimpi memiliki efek cahaya dan dikumpulkan dengan menyentuhnya.
- **Inventaris:** mulai dengan 2 Ramuan Kecil; ramuan memulihkan 30 HP (maksimum 100).
- **Level dan kekuatan MC:** setiap monster biasa yang dikalahkan memberi Level +1 dan Kekuatan +0,2 (1/5). Mengalahkan Bos Mimpi memberi Level +5 dan Kekuatan +3. Kekuatan meningkatkan damage pedang.
- **Bos Mimpi:** bos ber-HP 350, mengejar dan menyerang pemain, memberi Inti Bos dan 100 Koin. Hadiah bos hanya bisa diterima satu kali.
- **Simpan otomatis:** inventaris, level, kekuatan, progres quest, status hadiah bos, HP, dan posisi pemain disimpan ke `user://savegame.cfg`; progres dimuat kembali saat game dibuka. Posisi dan HP disimpan berkala setiap 5 detik serta saat progres penting berubah.
- **Sistem tumbang dan kembali:** jika HP pemain habis, karakter kembali ke titik awal dengan HP penuh tanpa menghapus progres quest atau inventaris.
- **Kontrol Android horizontal:** orientasi layar landscape, analog virtual berbentuk bulat di kiri, tombol SERANG di kanan, dan swipe pada area permainan untuk memutar kamera. UI mengikuti ukuran layar yang melebar.
- **Kage Bunshin:** tombol jurus memunculkan tepat 3 bayangan biru selama 8 detik; waktu pemulihan/cooldown jurus adalah 6 detik sebelum dapat digunakan kembali.
- Tombol TAS membuka inventaris.

## Pengujian fitur simpan
1. Jalankan game dan buka tombol TAS untuk melihat dua Ramuan Kecil.
2. Gunakan satu ramuan saat HP tidak penuh; jumlah ramuan harus berkurang.
3. Kalahkan Slime; pastikan Level naik 1 dan Kekuatan naik 0,2.
4. Sentuh tiga Kristal Mimpi; pastikan Bos Mimpi muncul.
5. Kalahkan Bos Mimpi; pastikan Level naik 5, Kekuatan naik 3, dan hadiah bos diterima satu kali.
6. Tutup lalu jalankan ulang game pada perangkat/profil Godot yang sama.
7. Pastikan level, kekuatan, status bos, quest, inventaris, HP, dan posisi terakhir tetap tersimpan. File save berada di direktori data pengguna Godot, bukan di folder proyek.
8. Biarkan karakter berjalan beberapa detik, tutup game, lalu buka lagi untuk memastikan posisi terakhir dipulihkan.
9. Biarkan monster mengurangi HP hingga habis; karakter harus kembali ke titik awal dengan HP penuh.

## Membuat APK Android
APK belum disertakan atau dikompilasi oleh perubahan kode ini. Untuk mengekspor:
1. Pasang **Export Templates** yang cocok dengan versi Godot.
2. Siapkan Android SDK dan Java JDK mengikuti dokumentasi ekspor Android Godot.
3. Buka **Project > Export**, lalu pilih **Add... > Android**.
4. Atur package name unik, misalnya `com.duniamimpi.rpg3d`.
5. Atur keystore untuk rilis; untuk uji coba gunakan ekspor debug.
6. Tekan **Export Project**, pilih lokasi `.apk`, lalu instal APK pada perangkat untuk menguji.

## Batasan yang masih ada
Tampilan anime dan Bos Mimpi masih berupa mesh geometri sederhana, bukan model 3D karakter profesional. Belum ada rig/skeletal animation, suara, dunia terbuka, sistem EXP, atau APK terkompilasi. Saat ini monster biasa yang tersedia di arena baru Slime. Model karakter dan musuh masih berupa mesh geometri sederhana; animasi skeletal, efek suara, peta dunia luas, beberapa jenis monster, toko, dan pengujian perangkat fisik masih perlu dikerjakan. Penyimpanan posisi/HP dan kontrol sentuh landscape sudah ditambahkan, tetapi perlu diuji pada perangkat Android dengan berbagai rasio layar. Pengujian runtime Godot tetap perlu dilakukan setelah perubahan ini.

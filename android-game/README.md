# Dunia di Balik Mimpi — Anime RPG 3D (Godot)

Prototipe game RPG 3D offline untuk Android. Folder ini terpisah dari komik di root repository.

## Membuka dan menguji di Godot
1. Instal Godot Engine 4.x.
2. Dari Godot Project Manager pilih **Import**.
3. Pilih file `android-game/project.godot`.
4. Buka proyek lalu tekan **F5**.
5. Di PC gunakan tombol panah / WASD untuk bergerak; tombol SERANG di layar untuk menyerang. Di Android gunakan joystick kiri dan tombol SERANG.

## Fitur prototipe saat ini
- Arena 3D, pencahayaan, dan pilar dekoratif.
- Karakter bergaya anime sederhana dengan detail rambut, mata, kerah, dan pedang; seluruhnya masih dibuat dari mesh dasar Godot.
- Animasi ayunan pedang menggunakan Tween.
- Slime mengejar dan menyerang pemain.
- HP pemain dan HP monster.
- **Quest berantai:** kalahkan Slime untuk memperoleh Lendir Slime dan 10 Koin, lalu kumpulkan 3 Kristal Mimpi yang muncul di arena untuk bonus 20 Koin.
- Kristal Mimpi memiliki efek cahaya dan dikumpulkan dengan menyentuhnya.
- **Inventaris:** mulai dengan 2 Ramuan Kecil; ramuan memulihkan 30 HP (maksimum 100).
- **Simpan otomatis:** inventaris, progres kedua quest, dan hadiah disimpan ke `user://savegame.cfg`; progres dimuat kembali saat game dibuka.
- Tombol TAS membuka inventaris dan joystick layar sentuh tersedia untuk Android.

## Pengujian fitur simpan
1. Jalankan game dan buka tombol TAS untuk melihat dua Ramuan Kecil.
2. Gunakan satu ramuan saat HP tidak penuh; jumlah ramuan harus berkurang.
3. Kalahkan Slime sampai quest pertama selesai dan hadiah muncul di inventaris.
4. Sentuh tiga Kristal Mimpi yang muncul di arena; pastikan quest kedua selesai dan bonus Koin diterima.
5. Tutup lalu jalankan ulang game pada perangkat/profil Godot yang sama.
6. Pastikan progres kedua quest dan barang tetap tersimpan. File save berada di direktori data pengguna Godot, bukan di folder proyek.

## Membuat APK Android
APK belum disertakan atau dikompilasi oleh perubahan kode ini. Untuk mengekspor:
1. Pasang **Export Templates** yang cocok dengan versi Godot.
2. Siapkan Android SDK dan Java JDK mengikuti dokumentasi ekspor Android Godot.
3. Buka **Project > Export**, lalu pilih **Add... > Android**.
4. Atur package name unik, misalnya `com.duniamimpi.rpg3d`.
5. Atur keystore untuk rilis; untuk uji coba gunakan ekspor debug.
6. Tekan **Export Project**, pilih lokasi `.apk`, lalu instal APK pada perangkat untuk menguji.

## Batasan yang masih ada
Tampilan anime masih berupa mesh geometri sederhana, bukan model 3D karakter profesional. Belum ada rig/skeletal animation, suara, dunia terbuka, quest lanjutan setelah dua misi awal, sistem level/EXP, atau APK terkompilasi. Fitur save menyimpan inventaris dan progres quest, tetapi belum menyimpan posisi pemain atau HP. Pengujian runtime Godot tetap perlu dilakukan setelah perubahan ini.

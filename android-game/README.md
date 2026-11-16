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
- Karakter pemain, pedang, dan Slime yang mengejar serta menyerang.
- HP pemain dan HP monster.
- **Quest:** kalahkan Slime (1/1); penyelesaian quest memberi hadiah.
- **Inventaris:** mulai dengan 2 Ramuan Kecil; Slime menjatuhkan Lendir Slime dan 10 Koin.
- Tombol TAS membuka inventaris; tombol Gunakan Ramuan memulihkan 30 HP (maksimum 100).
- Joystick layar sentuh untuk Android.

## Membuat APK Android
APK belum disertakan atau dikompilasi oleh perubahan kode ini. Untuk mengekspor:
1. Pasang **Export Templates** yang cocok dengan versi Godot.
2. Siapkan Android SDK dan Java JDK mengikuti dokumentasi ekspor Android Godot.
3. Buka **Project > Export**, lalu pilih **Add... > Android**.
4. Atur package name unik, misalnya `com.duniamimpi.rpg3d`.
5. Atur keystore untuk rilis; untuk uji coba gunakan ekspor debug.
6. Tekan **Export Project**, pilih lokasi `.apk`, lalu instal APK pada perangkat untuk menguji.

## Batasan yang masih ada
Model karakter dan monster masih berupa bentuk geometri placeholder, bukan model anime detail. Quest saat ini satu misi tutorial dan inventaris belum disimpan antar-sesi. Belum ada animasi skeletal, audio, dunia terbuka, sistem level/EXP, atau APK terkompilasi.

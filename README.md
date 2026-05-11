# FreshTrack: Food Expiry Tracker 🍎🥦

**FreshTrack** adalah aplikasi asisten pintar yang dirancang untuk membantu Anda mengelola stok makanan dan melacak masa kadaluarsa secara efisien. Dengan desain yang modern dan premium, FreshTrack memastikan tidak ada makanan yang terbuang sia-sia di rumah Anda.

---

## 🏛️ Blue Print Aplikasi

Aplikasi ini dibangun dengan arsitektur modern untuk memastikan performa yang cepat dan pengalaman pengguna yang mulus:

- **Framework**: [Flutter](https://flutter.dev/) - UI Toolkit dari Google untuk aplikasi multi-platform.
- **State Management**: [Riverpod](https://riverpod.dev/) - Manajemen state yang reaktif dan aman untuk sinkronisasi data antar layar.
- **Local Storage**: [SQFlite](https://pub.dev/packages/sqflite) - Database lokal untuk penyimpanan data makanan dan riwayat secara permanen di perangkat.
- **Design System**:
  - **Material 3**: Standar desain terbaru dari Google.
  - **Typography**: [Google Fonts (Plus Jakarta Sans)](https://fonts.google.com/specimen/Plus+Jakarta+Sans).
  - **Icons**: [Lucide Icons](https://lucide.dev/).
  - **Animations**: [Flutter Animate](https://pub.dev/packages/flutter_animate).

---

## ⚙️ Cara Kerja Aplikasi

FreshTrack bekerja dengan alur yang intuitif bagi pengguna:

1. **Dashboard Ringkasan**: Saat membuka aplikasi, pengguna disuguhkan dengan "Ringkasan" status stok makanan yang terbagi menjadi tiga kategori: **Aman**, **Hampir Kadaluarsa** (dalam 7 hari), dan **Expired**.
2. **Pencatatan Makanan**: Pengguna dapat menambahkan item makanan baru dengan memasukkan nama, kategori (Daging, Sayur, Susu, dll), dan tanggal kadaluarsa. Pengguna juga dapat mengambil foto makanan menggunakan kamera.
3. **Logika Cerdas**: Aplikasi secara otomatis menghitung selisih hari dari tanggal hari ini ke tanggal kadaluarsa untuk menentukan status urgensi makanan secara real-time.
4. **Notifikasi Visual**: Badge pada ikon lonceng akan memberi tahu pengguna jika ada item yang membutuhkan perhatian segera tanpa harus membuka daftar satu per satu.
5. **Riwayat Aktivitas**: Setiap perubahan (tambah, edit, hapus) dicatat dalam sistem riwayat (History) untuk memantau penggunaan aplikasi dari waktu ke waktu.
6. **Manajemen Profil**: Pengguna dapat mempersonalisasi aplikasi dengan mengedit profil sesuai keinginan.

---

## ✨ Daftar Fitur Unggulan

### 1. Pelacakan Makanan (Food Tracker)

- Tambah, Edit, dan Hapus item makanan.
- Input tanggal kadaluarsa dengan kalender intuitif.
- Lampirkan foto produk menggunakan Kamera atau Galeri.
- Tambahkan catatan khusus untuk setiap item.

### 2. Kategorisasi Cerdas

- Klasifikasi makanan berdasarkan jenis (Sayuran, Buah, Daging, Minuman, dll).
- Filter daftar makanan berdasarkan kategori tertentu untuk pencarian lebih cepat.

### 3. Sistem Status & Urgensi

- **Safe (Hijau)**: Makanan masih segar dan lama masanya.
- **Warning (Oranye)**: Makanan akan kadaluarsa dalam ≤ 7 hari.
- **Expired (Merah)**: Makanan sudah melewati masa kadaluarsa.

### 4. Pencarian Cepat (Smart Search)

- Temukan makanan dengan cepat melalui kolom pencarian di halaman utama.

### 5. Riwayat Aktivitas (Activity Log)

- Mencatat setiap interaksi yang dilakukan dalam aplikasi sebagai referensi pengguna.

### 6. Profil & Personalisasi

- Ubah foto profil dan informasi pengguna.
- Tampilan UI yang bersih dengan dukungan animasi micro-interactions.
- Privasi data sepenuhnya tersimpan secara lokal di perangkat.

## 📸 Tampilan Antarmuka (UI)

Berikut adalah representasi visual dari antarmuka pengguna FreshTrack:

|                                                                      Splash Screen                                                                       |                                                                 Dashboard Utama                                                                  |                                                                 Detail & Tambah                                                                 |
| :------------------------------------------------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------------------------: |
| ![Splash Screen](file:///C:/Users/ASUS/.gemini/antigravity/brain/e500d2da-5493-4fed-bdfd-8b08ae31d738/freshtrack_splash_screen_mockup_1778497405735.png) | ![Dashboard](file:///C:/Users/ASUS/.gemini/antigravity/brain/e500d2da-5493-4fed-bdfd-8b08ae31d738/freshtrack_dashboard_mockup_1778497389560.png) | ![Detail](file:///C:/Users/ASUS/.gemini/antigravity/brain/e500d2da-5493-4fed-bdfd-8b08ae31d738/freshtrack_food_detail_mockup_1778497491990.png) |

---

## 🚀 Instalasi & Pengembangan

Untuk menjalankan proyek ini secara lokal:

1. Pastikan Flutter SDK sudah terinstal.
2. Jalankan perintah:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi di perangkat atau emulator:
   ```bash
   flutter run
   ```

---

_Dibuat dengan ❤️ untuk mengurangi Food Waste di dunia._

## Pengembang

Nama : (sherly putriyati)  
Mata Kuliah : Pemrograman Mobile  
Universitas : (universitas islam madura)

# Leviosa - Katalog & Ulasan Laptop Interaktif

**Leviosa** adalah aplikasi mobile berbasis Flutter yang dirancang untuk memudahkan pengguna dalam menjelajahi katalog laptop, melihat spesifikasi detail, menyimpan produk impian, serta berinteraksi melalui ulasan pengguna secara *real-time*.

Proyek ini dikembangkan sebagai syarat penyelesaian mata kuliah **Teknologi Open Source** dan bertujuan untuk menyediakan referensi implementasi aplikasi *Fullstack* menggunakan Flutter dan Supabase.

## 🚀 Fitur Utama

* **Katalog Laptop Komprehensif**: Menampilkan daftar laptop terbaru lengkap dengan spesifikasi teknis (Prosesor, RAM, Storage, GPU) dan harga.
* **Pencarian Pintar**: Memungkinkan pengguna mencari laptop berdasarkan nama merek atau model tertentu dengan cepat.
* **Wishlist (Favorit)**: Fitur personalisasi untuk menyimpan laptop impian ke dalam daftar favorit (memerlukan login).
* **Ulasan Real-time**: Pengguna dapat memberikan rating dan komentar pada produk. Ulasan dari pengguna lain akan muncul secara langsung tanpa perlu *refresh* halaman (didukung oleh Supabase Realtime).
* **Statistik Brand**: Visualisasi data tren merek laptop menggunakan grafik interaktif (*Interactive Charts*).
* **Autentikasi Pengguna**: Sistem registrasi dan login yang aman, termasuk pembuatan profil pengguna otomatis.

## 🛠️ Teknologi yang Digunakan

* **Frontend**: [Flutter](https://flutter.dev/) (Dart) - Framework UI lintas platform.
* **Backend**: [Supabase](https://supabase.com/) - Backend-as-a-Service (BaaS) yang mencakup Database (PostgreSQL), Auth, dan Realtime.
* **Visualisasi Data**: `fl_chart` untuk grafik statistik.
* **Manajemen Aset**: Google Fonts & Unsplash (untuk gambar dummy).

## ⚙️ Cara Menjalankan Proyek

Ikuti langkah-langkah berikut untuk menjalankan aplikasi di lingkungan lokal Anda:

### 1. Prasyarat
Pastikan Anda telah menginstal:
* Flutter SDK (Versi Stable terbaru)
* Git
* Visual Studio Code / Android Studio

### 2. Instalasi
1.  **Kloning Repositori**
    ```bash
    git clone [https://github.com/ishlah/leviosa-project.git](https://github.com/ishlah/leviosa-project.git)
    cd leviosa
    ```

2.  **Instalasi Dependensi**
    Unduh paket-paket Dart yang dibutuhkan:
    ```bash
    flutter pub get
    ```

3.  **Konfigurasi Supabase**
    * Buat proyek baru di [Supabase Dashboard](https://app.supabase.com).
    * Buka **SQL Editor** di dashboard Supabase, lalu salin dan jalankan isi file `leviosa_schema.sql` yang ada di repositori ini. Ini akan membuat tabel dan aturan keamanan (*RLS Policies*) secara otomatis.
    * Buat file `.env` di folder root proyek (lihat `.env.example`), lalu isi dengan kredensial Anda:
        ```env
        SUPABASE_URL=[https://project-id-anda.supabase.co](https://project-id-anda.supabase.co)
        SUPABASE_ANON_KEY=kunci-anon-anda-disini
        ```

4.  **Jalankan Aplikasi**
    Hubungkan perangkat (HP) atau Emulator, lalu jalankan:
    ```bash
    flutter run
    ```

## 🤝 Cara Berkontribusi

Saya sangat terbuka bagi siapa saja yang ingin membantu mengembangkan proyek ini. Karena proyek ini bersifat *Open Source*, setiap kontribusi—sekecil apa pun—sangat dihargai.

Berikut adalah langkah-langkah untuk berkontribusi:

1.  **Fork Repositori**: Klik tombol **Fork** di pojok kanan atas halaman GitHub ini.
2.  **Klon ke Lokal**:
    ```bash
    git clone [https://github.com/username-anda/leviosa-project.git](https://github.com/username-anda/leviosa-project.git)
    ```
3.  **Buat Branch Baru**: Gunakan nama yang deskriptif untuk fitur yang Anda buat.
    ```bash
    git checkout -b fitur/tambah-mode-gelap
    ```
4.  **Lakukan Perubahan**: Silakan modifikasi kode, perbaiki bug, atau tambah fitur.
5.  **Commit dan Push**:
    ```bash
    git commit -m "Menambahkan fitur Dark Mode"
    git push origin fitur/tambah-mode-gelap
    ```
6.  **Buat Pull Request**: Kembali ke repositori asli dan ajukan *Pull Request* agar saya dapat meninjau kode Anda.

### 💡 Ide Kontribusi yang Disarankan
* **Fitur Komparasi**: Menambahkan halaman untuk membandingkan spesifikasi 2 laptop secara berdampingan.
* **Dark Mode**: Implementasi tema gelap untuk kenyamanan mata.
* **Payment Gateway**: Integrasi dummy payment (Midtrans/Xendit) untuk simulasi pembelian.
* **Versi Web/Desktop**: Mengoptimalkan tampilan agar responsif saat dijalankan di Browser atau Windows.

## 📄 Hak Cipta dan Lisensi

Proyek ini dilisensikan di bawah **MIT License**. Anda bebas menggunakan, memodifikasi, dan mendistribusikan kode ini untuk keperluan pribadi maupun komersial.

---
*Dibuat dengan ❤️ menggunakan Flutter & Supabase.*

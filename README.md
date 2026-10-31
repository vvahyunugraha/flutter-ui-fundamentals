---

## WO 7 — Tahap 16: Mini Project Integrasi — Course Data Manager

### 1. Arsitektur Aplikasi

Aplikasi menggunakan pemisahan tanggung jawab untuk mengelola data mata kuliah (*course*).

| Komponen | Fungsi |
|---|---|
| `CourseDataSource` | Mendefinisikan kontrak operasi CRUD |
| `CourseSupabaseService` | Menghubungkan aplikasi dengan Supabase |
| `CourseApiService` | Menyediakan implementasi sumber data REST API |
| `CourseRepository` | Menjadi penghubung antara provider dan sumber data |
| `CourseProvider` | Mengelola state, data course, loading, dan error |
| `Course` | Model data mata kuliah |

Supabase digunakan sebagai sumber data aktif melalui `CourseSupabaseService` yang dipilih di `main.dart`.

### 2. Pengujian CRUD

| Operasi | Hasil |
|---|---|
| Create | Berhasil menambahkan course baru |
| Read | Berhasil memuat ulang data dari Supabase |
| Update | Berhasil memperbarui course dan mempertahankan perubahan setelah pemuatan ulang |
| Delete | Berhasil menghapus course dan memastikan data tidak muncul kembali setelah pemuatan ulang |

### 3. Pengujian Error State

Pengujian dilakukan menggunakan URL Supabase yang tidak valid untuk sementara. Aplikasi berhasil menampilkan `ErrorView` beserta tombol coba lagi.

Setelah pengujian, URL Supabase dipulihkan ke konfigurasi asli. Verifikasi akhir dilakukan dengan memastikan aplikasi kembali dapat memuat daftar course tanpa error.

### 4. Identitas Mahasiswa

- **Nama:** I Gusti Made Wahyu Nugraha
- **NIM:** 2455011005

### 5. Bukti dan Git Checkpoint

- Screenshot kode dan hasil aplikasi: [tambahkan setelah screenshot diambil]
- Commit Git Tahap 16: [tambahkan hash setelah commit berhasil dibuat]

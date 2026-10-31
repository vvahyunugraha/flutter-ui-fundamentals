# WO 7 — Course Data Manager

## 1. Ringkasan Tahap 0–17

WO 7 berfokus pada pengembangan aplikasi **Course Data Manager** menggunakan Flutter. Pembelajaran dimulai dari persiapan project dan pemahaman REST API, dilanjutkan dengan operasi CRUD, penggunaan Supabase, integrasi arsitektur aplikasi, serta penanganan error dan pemeriksaan keamanan dasar.

| Tahap | Materi | Ringkasan |
|---|---|---|
| 0 | Persiapan Project dan Git | Memeriksa project Flutter, konfigurasi environment, struktur folder, serta status repository Git. |
| 1 | Membaca REST Endpoint dan JSON | Memahami endpoint REST API, metode HTTP, status respons, dan struktur data JSON. |
| 2 | HTTP GET | Mengambil data dari REST API untuk memahami proses membaca data. |
| 3 | Model Data Course | Membuat model `Course` untuk merepresentasikan data mata kuliah. |
| 4 | Service dan HTTP Request | Memisahkan proses komunikasi dengan API ke dalam service. |
| 5 | Loading, Error, dan Tampilan Data | Mengelola proses pemuatan data dan menampilkan status aplikasi kepada pengguna. |
| 6 | HTTP POST | Menambahkan data course baru melalui form dan mengirimkannya ke sumber data. |
| 7 | HTTP PUT | Mempelajari proses memperbarui keseluruhan data resource. |
| 8 | HTTP PATCH | Mempelajari proses memperbarui sebagian data resource. |
| 9 | HTTP DELETE dan Repository | Menghapus data dan menggunakan repository sebagai penghubung antara provider dengan sumber data. |
| 10 | Pengenalan Supabase | Menyiapkan koneksi dan memahami penggunaan Supabase sebagai sumber data. |
| 11 | Integrasi Supabase | Menghubungkan aplikasi Flutter dengan layanan Supabase. |
| 12 | Membaca Data dari Supabase | Mengambil dan menampilkan data course dari database Supabase. |
| 13 | Menambahkan Data ke Supabase | Mengimplementasikan operasi Create untuk menyimpan course baru. |
| 14 | Memperbarui Data Supabase | Mengimplementasikan operasi Update pada data course. |
| 15 | Menghapus Data Supabase | Mengimplementasikan operasi Delete dan memeriksa perubahan data setelah pemuatan ulang. |
| 16 | Mini Project Integrasi — Course Data Manager | Mengintegrasikan model, data source, service, repository, dan provider untuk menjalankan aplikasi pengelolaan course. |
| 17 | Debugging, Network Failure, dan Security Check | Menguji penanganan kegagalan koneksi dan error, serta memeriksa keamanan konfigurasi dan data sensitif. |

*Catatan: Ringkasan di atas merupakan ikhtisar materi berdasarkan alur pengerjaan WO 7. Nama atau urutan submateri perlu dicocokkan kembali dengan lembar kerja asli jika diperlukan kesesuaian secara persis.*

## 2. Arsitektur Aplikasi

Aplikasi menerapkan pemisahan tanggung jawab (*separation of concerns*) untuk mempermudah pengelolaan data mata kuliah.

| Komponen | Fungsi |
|---|---|
| `CourseDataSource` | Mendefinisikan kontrak operasi CRUD. |
| `CourseSupabaseService` | Menghubungkan aplikasi dengan Supabase sebagai sumber data aktif. |
| `CourseApiService` | Menyediakan implementasi sumber data melalui REST API. |
| `CourseRepository` | Menjadi penghubung antara provider dan sumber data. |
| `CourseProvider` | Mengelola state, data course, status loading, dan error. |
| `Course` | Merepresentasikan data mata kuliah dalam bentuk model. |

Supabase digunakan sebagai sumber data aktif melalui `CourseSupabaseService` yang dikonfigurasi di `main.dart`.

## 3. Pengujian Operasi CRUD

| Operasi | Hasil Pengujian |
|---|---|
| Create | Berhasil menambahkan course baru ke Supabase. |
| Read | Berhasil memuat data course dari Supabase. |
| Update | Berhasil memperbarui data dan mempertahankan perubahan setelah pemuatan ulang. |
| Delete | Berhasil menghapus data dan memastikan data tidak muncul kembali setelah pemuatan ulang. |

## 4. Pengujian Error State dan Keamanan

Pengujian error state dilakukan dengan menggunakan URL Supabase yang tidak valid untuk sementara waktu. Aplikasi berhasil menampilkan `ErrorView` beserta tombol coba lagi (*Retry*).

Pada tahap pengujian koneksi, aplikasi juga diperiksa agar tidak mengalami crash ketika koneksi internet terputus. Setelah pengujian selesai, konfigurasi Supabase dipulihkan dan aplikasi diverifikasi kembali.

Pemeriksaan keamanan dasar meliputi:

- Memastikan kunci `service_role` tidak ditanamkan dalam kode aplikasi.
- Memastikan password dan token rahasia tidak disimpan dalam repository.
- Memastikan file `.env` yang berisi rahasia tidak ikut di-commit.
- Memeriksa kebijakan Row Level Security (RLS) dan validasi pada sisi backend.
- Memastikan screenshot dokumentasi tidak menampilkan informasi rahasia.

## 5. Identitas Mahasiswa

- **Nama:** I Gusti Made Wahyu Nugraha
- **NIM:** 2455011005
- **Program Studi:** Teknologi Rekayasa Perangkat Lunak
- **Universitas:** Universitas Pendidikan Ganesha

## 6. Bukti Pengujian

- **Screenshot kode:** [Tambahkan screenshot kode yang relevan]
- **Screenshot hasil aplikasi:** [Tambahkan screenshot pengujian CRUD dan error state]

## 7. Git Checkpoint

- **Commit message:** `Selesaikan mini project Course Data Manager`
- **Commit hash:** [Tambahkan hash commit yang sebenarnya]

Untuk Tahap 17, commit yang direncanakan sesuai checkpoint sebelumnya adalah:

`Tambahkan error handling dan security hardening dasar`

# Course Data Manager

Aplikasi **Course Data Manager** merupakan aplikasi mobile berbasis Flutter untuk mengelola data mata kuliah (*course*). Aplikasi ini dikembangkan dari project Course Explorer v2 pada praktikum Pemrograman Mobile Pertemuan 7.

Aplikasi mendukung operasi CRUD (*Create, Read, Update, Delete*) dengan Supabase sebagai backend dan database. Pengelolaan data dilakukan melalui pemisahan model, service, repository, provider, dan UI agar kode lebih terstruktur dan mudah dikembangkan.

## Identitas Mahasiswa

- **Nama:** I Gusti Made Wahyu Nugraha
- **NIM:** 2455011005
- **Program Studi:** Teknologi Rekayasa Perangkat Lunak
- **Universitas:** Universitas Pendidikan Ganesha

## Fitur Aplikasi

- Menampilkan daftar mata kuliah dari database Supabase.
- Menambahkan data mata kuliah.
- Mengedit data mata kuliah.
- Menghapus data mata kuliah.
- Memuat ulang data dari backend.
- Menampilkan status loading, empty, dan error.
- Menyediakan tombol coba lagi (*Retry*) ketika terjadi kesalahan.
- Mempertahankan navigasi responsif, halaman detail, dan fitur favorites dari pengembangan sebelumnya.

## Teknologi yang Digunakan

- **Flutter** — pengembangan aplikasi mobile.
- **Dart** — bahasa pemrograman.
- **Supabase** — backend dan database.
- **Provider** — pengelolaan state aplikasi.
- **HTTP** — komunikasi dengan REST API pada implementasi service API.
- **Git dan GitHub** — version control dan penyimpanan repository.

## Cara Menjalankan Aplikasi

### 1. Persiapan

Pastikan perangkat sudah memiliki Flutter SDK, Dart SDK, dan Android Studio atau perangkat untuk menjalankan aplikasi Flutter.

### 2. Clone Repository

```bash
git clone https://github.com/vvahyunugraha/flutter-ui-fundamentals.git
```

### 3. Masuk ke Folder Project

```bash
cd flutter-ui-fundamentals
```

### 4. Instal Dependency

```bash
flutter pub get
```

### 5. Konfigurasi Supabase

Pastikan konfigurasi URL Supabase dan anon/publishable key tersedia sesuai konfigurasi project. Gunakan konfigurasi yang aman dan jangan memasukkan `service_role` key atau credential rahasia ke dalam source code maupun repository publik.

Pastikan tabel `courses` dan kebijakan akses database sudah dikonfigurasi sesuai kebutuhan aplikasi.

### 6. Jalankan Aplikasi

Pastikan emulator atau perangkat sudah terhubung, kemudian jalankan:

```bash
flutter run
```

## Arsitektur Aplikasi

Aplikasi menggunakan pemisahan tanggung jawab (*separation of concerns*) dengan alur pengelolaan data sebagai berikut:

```text
UI / Screens
     |
     v
CourseProvider
     |
     v
CourseRepository
     |
     v
CourseDataSource
     |
     +------------------------+
     |                        |
     v                        v
CourseSupabaseService    CourseApiService
     |                        |
     v                        v
Supabase Database         REST API
```

### Komponen Utama

| Komponen | Tanggung Jawab |
|---|---|
| `Course` | Model data mata kuliah dan konversi JSON. |
| `CourseDataSource` | Kontrak operasi untuk sumber data. |
| `CourseSupabaseService` | Mengakses data melalui Supabase. |
| `CourseApiService` | Menyediakan akses data melalui REST API. |
| `CourseRepository` | Menghubungkan provider dengan sumber data. |
| `CourseProvider` | Mengelola data, loading, error, dan perubahan state. |
| UI / Screens | Menampilkan data dan menyediakan interaksi pengguna. |

`CourseSupabaseService` digunakan sebagai sumber data aktif, sedangkan `CourseApiService` merupakan implementasi alternatif untuk komunikasi REST API.

## Backend dan Database

Backend aktif aplikasi menggunakan **Supabase**. Database menyimpan data mata kuliah pada tabel `courses`.

Operasi database yang didukung meliputi:

- **SELECT:** membaca daftar mata kuliah.
- **INSERT:** menambahkan mata kuliah.
- **UPDATE:** memperbarui data mata kuliah.
- **DELETE:** menghapus mata kuliah.

Akses data harus mengikuti konfigurasi autentikasi dan kebijakan Row Level Security (RLS) yang sesuai.

## Error Handling

Aplikasi menangani kegagalan pengambilan data dengan menampilkan status error dan tombol *Retry*. Pengujian juga dilakukan terhadap kondisi koneksi bermasalah agar aplikasi dapat memberikan umpan balik tanpa harus berhenti secara tidak terduga.

## Pengujian CRUD

| Operasi | Hasil yang Diharapkan |
|---|---|
| Create | Data baru tersimpan di Supabase. |
| Read | Data course berhasil ditampilkan dari database. |
| Update | Perubahan data tersimpan dan tetap ada setelah pemuatan ulang. |
| Delete | Data terhapus dari database dan tidak muncul kembali setelah pemuatan ulang. |

## Repository

GitHub: https://github.com/vvahyunugraha/flutter-ui-fundamentals

## Catatan

README ini merupakan dokumentasi praktikum WO 7 — RESTful API, Backend Services & Database Integration. Konfigurasi aplikasi, nama file, dan fitur yang dijelaskan perlu disesuaikan jika terdapat perbedaan dengan implementasi aktual project.

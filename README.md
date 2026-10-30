# Flutter UI Fundamentals

Project Flutter untuk pembelajaran Workshop Pengembangan Aplikasi Mobile.

## WO 7 — Tahap 1: Membaca REST Endpoint dan JSON

### 1. Informasi Endpoint

- **URL:** https://jsonplaceholder.typicode.com/posts/1
- **HTTP Method:** GET
- **Status Code:** 200 OK (jika request berhasil)
- **Resource:** posts
- **Response Format:** JSON

### 2. Contoh Response JSON

```json
{
  "userId": 1,
  "id": 1,
  "title": "sunt aut facere repellat provident occaecati",
  "body": "quia et suscipit suscipit recusandae"
}
```

### 3. Struktur JSON

| Field | Keterangan |
|---|---|
| `userId` | ID pengguna yang membuat post |
| `id` | ID post |
| `title` | Judul post |
| `body` | Isi atau konten post |

### 4. Catatan Praktikum

HTTP method GET digunakan untuk meminta data dari REST endpoint. Response yang diterima berbentuk JSON dan memiliki empat field, yaitu `userId`, `id`, `title`, dan `body`. Status code digunakan untuk mengetahui hasil request, sedangkan response body berisi data yang dikirim oleh server.

JSONPlaceholder merupakan API dummy untuk latihan. Operasi penulisan data pada layanan ini tidak tersimpan secara permanen.
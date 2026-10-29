import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';

const String studentName = 'I Gusti Made Wahyu Nugraha';
const String studentId = '2455011005';

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    String statusText;

    if (course.status == 'done') {
      statusText = 'Selesai';
    } else if (course.status == 'active') {
      statusText = 'Aktif';
    } else {
      statusText = 'Rencana';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Detail'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '$studentId - $studentName',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Detail Course',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Kode: ${course.code}'),
                    const SizedBox(height: 8),
                    Text('SKS: ${course.credits}'),
                    const SizedBox(height: 8),
                    Text('Status: $statusText'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Consumer<CourseState>(
              builder: (context, courseState, child) {
                final isFavorite =
                    courseState.isFavorite(course.code);

                return Card(
                  child: ListTile(
                    leading: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    title: Text(
                      isFavorite
                          ? 'Mata kuliah favorit'
                          : 'Belum menjadi favorit',
                    ),
                    trailing: IconButton(
                      tooltip: isFavorite
                          ? 'Hapus favorit'
                          : 'Tambah favorit',
                      onPressed: () {
                        courseState.toggleFavorite(course.code);
                      },
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Informasi Mahasiswa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text('Nama: $studentName'),
            const SizedBox(height: 8),
            const Text('NIM: $studentId'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Kembali'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
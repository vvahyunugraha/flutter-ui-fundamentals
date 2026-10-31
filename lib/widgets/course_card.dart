
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../screens/course_detail_page.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final bool isFavorite;

  const CourseCard({
    super.key,
    required this.course,
    required this.isFavorite,
  });

  // Menampilkan konfirmasi sebelum menghapus course.
  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Course?'),
          content: Text(
            'Apakah kamu yakin ingin menghapus '
            '"${course.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      // Menghapus course melalui CourseProvider.
      await context.read<CourseProvider>().deleteCourse(
            course.id!,
          );

      if (!context.mounted) return;

      // Menghapus course dari daftar favorit.
      context.read<CourseState>().removeFavorite(course.code);

      // Menampilkan pemberitahuan setelah berhasil.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Course "${course.title}" berhasil dihapus',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus course: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = course.title;
    final code = course.code;
    final credits = course.credits;
    final status = course.status;

    IconData statusIcon;
    Color statusColor;
    String statusText;

    if (status == 'done') {
      statusIcon = Icons.check_circle;
      statusColor = Colors.green;
      statusText = 'Selesai';
    } else if (status == 'active') {
      statusIcon = Icons.play_circle;
      statusColor = Colors.blue;
      statusText = 'Aktif';
    } else {
      statusIcon = Icons.schedule;
      statusColor = Colors.orange;
      statusText = 'Rencana';
    }

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailPage(course: course),
            ),
          );
        },
        onLongPress: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Course: $title\nKode: $code'),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(statusIcon, color: statusColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text('Kode: $code'),
                    Text('SKS: $credits'),
                    const SizedBox(height: 5),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      context
                          .read<CourseState>()
                          .toggleFavorite(code);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite
                                ? 'Course dihapus dari favorit'
                                : 'Course ditambahkan ke favorit',
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),
                    color: isFavorite ? Colors.red : null,
                    tooltip: isFavorite
                        ? 'Hapus favorit'
                        : 'Tambah favorit',
                  ),
                  IconButton(
                    onPressed: course.id == null
                        ? null
                        : () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    tooltip: 'Hapus course',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

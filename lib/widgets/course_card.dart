import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../screens/course_detail_page.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final bool isFavorite;

  const CourseCard({super.key, required this.course, required this.isFavorite});

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
        onTap: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => CourseDetailPage(course: course)),
          );

          if (!context.mounted) return;

          if (result == true) {
            context.read<CourseState>().addFavorite(code);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Course berhasil dipilih')),
            );
          }
        },
        onLongPress: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Course: $title\nKode: $code')),
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
              IconButton(
                onPressed: () {
                  final wasFavorite = isFavorite;

                  context.read<CourseState>().toggleFavorite(code);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        wasFavorite
                            ? 'Course dihapus dari favorite'
                            : 'Course ditambahkan ke favorite',
                      ),
                    ),
                  );
                },
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                color: isFavorite ? Colors.red : null,
                tooltip: isFavorite ? 'Hapus favorite' : 'Tambah favorite',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';
import '../widgets/course_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) {
          if (courseProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (courseProvider.error != null) {
            return Center(
              child: Text(
                'Gagal memuat mata kuliah: ${courseProvider.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          return Consumer<CourseState>(
            builder: (context, courseState, child) {
              final favoriteCourses = courseProvider.courses
                  .where(
                    (course) =>
                        courseState.isFavorite(course.code),
                  )
                  .toList();

              if (favoriteCourses.isEmpty) {
                return const Center(
                  child: Text('Belum ada mata kuliah favorit.'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteCourses.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final course = favoriteCourses[index];

                  return CourseCard(
                    key: ValueKey(course.code),
                    course: course,
                    isFavorite:
                        courseState.isFavorite(course.code),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
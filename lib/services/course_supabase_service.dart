
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

// Nama: I Gusti Made Wahyu Nugraha
// NIM: 2455011005
// WO Pertemuan 9 - Praktik 5

class CourseSupabaseService implements CourseDataSource {
  final supabase = Supabase.instance.client;

  @override
  Future<List<Course>> getCourses() async {
    final data = await supabase
        .from('courses')
        .select()
        .order('id');

    return (data as List)
        .map(
          (e) => Course.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  @override
  Future<Course> createCourse(Course course) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    final courseData = course.toJson();

    // Owner ID diambil dari akun yang sedang login.
    courseData['owner_id'] = user.id;

    final row = await supabase
        .from('courses')
        .insert(courseData)
        .select()
        .single();

    return Course.fromJson(
      Map<String, dynamic>.from(row),
    );
  }

  @override
  Future<void> updateCourse(
    int id,
    Course course,
  ) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    final courseData = course.toJson();

    // Jangan izinkan perubahan kepemilikan course.
    courseData.remove('owner_id');

    final result = await supabase
        .from('courses')
        .update(courseData)
        .eq('id', id)
        .eq('owner_id', user.id)
        .select('id');

    if (result.isEmpty) {
      throw Exception(
        'Course tidak dapat diubah. '
        'Pastikan kamu adalah pemilik course.',
      );
    }
  }

  @override
  Future<void> deleteCourse(int id) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    final result = await supabase
        .from('courses')
        .delete()
        .eq('id', id)
        .eq('owner_id', user.id)
        .select('id');

    if (result.isEmpty) {
      throw Exception(
        'Course tidak dapat dihapus. '
        'Pastikan kamu adalah pemilik course.',
      );
    }
  }
}

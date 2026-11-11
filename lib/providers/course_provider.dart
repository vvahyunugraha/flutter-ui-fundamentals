
import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

// Nama: I Gusti Made Wahyu Nugraha
// NIM: 2455011005
// WO Pertemuan 7 Tahap 9

class CourseState extends ChangeNotifier {
  final Set<String> favorites = <String>{};

  bool isFavorite(String code) {
    return favorites.contains(code);
  }

  void addFavorite(String code) {
    favorites.add(code);
    notifyListeners();
  }

  void toggleFavorite(String code) {
    if (favorites.contains(code)) {
      favorites.remove(code);
    } else {
      favorites.add(code);
    }

    notifyListeners();
  }

  void removeFavorite(String code) {
    if (favorites.remove(code)) {
      notifyListeners();
    }
  }
}

class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;

  CourseProvider(this.repository);

  List<Course> courses = [];

  bool isLoading = false;
  bool isSaving = false;
  String? error;

  Future<void> loadCourses() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      courses = await repository.getCourses();

    debugPrint(
      'BERHASIL MEMUAT COURSE: ${courses.length} data',
    );
  } catch (e, stackTrace) {
    error = e.toString();

    debugPrint('GAGAL MEMUAT COURSE: $e');
    debugPrint('STACK TRACE: $stackTrace');
  } finally {
    isLoading = false;
      notifyListeners();
    }
  }

  Future<Course> createCourse(Course course) async {
    if (isSaving) {
      throw Exception(
        'Penyimpanan course sedang berlangsung.',
      );
    }

    isSaving = true;
    error = null;
    notifyListeners();

    try {
      final createdCourse =
          await repository.createCourse(course);

      if (createdCourse.id != null) {
        final index = courses.indexWhere(
          (item) => item.id == createdCourse.id,
        );

        if (index == -1) {
          courses = [...courses, createdCourse];
        } else {
          courses[index] = createdCourse;
          courses = List<Course>.from(courses);
        }
      }

      return createdCourse;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateCourse(
    int id,
    Course course,
  ) async {
    if (isSaving) {
      throw Exception(
        'Penyimpanan course sedang berlangsung.',
      );
    }

    isSaving = true;
    error = null;
    notifyListeners();

    try {
      await repository.updateCourse(id, course);

      // Perbarui daftar lokal setelah request berhasil.
      final index = courses.indexWhere(
        (item) => item.id == id,
      );

      if (index != -1) {
        courses[index] = course;
        courses = List<Course>.from(courses);
      }
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteCourse(int id) async {
    if (isSaving) {
      throw Exception(
        'Proses penyimpanan atau penghapusan course '
        'sedang berlangsung.',
      );
    }

    isSaving = true;
    error = null;
    notifyListeners();

    try {
      await repository.deleteCourse(id);

      courses = courses
          .where((course) => course.id != id)
          .toList();
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}

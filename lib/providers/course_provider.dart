
import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

// Nama: I Gusti Made Wahyu Nugraha
// NIM: 2455011005
// WO Pertemuan 7 Tahap 8: HTTP DELETE

// State untuk mata kuliah favorit.
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

  // Menghapus course dari daftar favorit.
  void removeFavorite(String code) {
    if (favorites.remove(code)) {
      notifyListeners();
    }
  }
}

// State loading, success, error, dan penyimpanan course.
class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;

  CourseProvider(this.repository);

  List<Course> courses = [];

  bool isLoading = false;
  bool isSaving = false;
  String? error;

  // GET: Memuat daftar course.
  Future<void> loadCourses() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      courses = await repository.getCourses();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // POST: Membuat course baru.
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
        }

        notifyListeners();
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

  // PUT: Memperbarui course yang sudah ada.
  Future<Course> updateCourse(
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
      final updatedCourse =
          await repository.updateCourse(id, course);

      final index = courses.indexWhere(
        (item) => item.id == id,
      );

      if (index != -1) {
        courses[index] = updatedCourse;
        courses = List<Course>.from(courses);
      }

      notifyListeners();

      return updatedCourse;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // DELETE: Menghapus course dari API dan daftar lokal.
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
      // Hapus melalui API terlebih dahulu.
      await repository.deleteCourse(id);

      // Hapus dari daftar lokal setelah API berhasil.
      courses = courses
          .where((course) => course.id != id)
          .toList();

      notifyListeners();
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}

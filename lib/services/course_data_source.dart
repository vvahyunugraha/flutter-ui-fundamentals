
import '../models/course.dart';

// Nama: I Gusti Made Wahyu Nugraha
// NIM: 2455011005
// WO Pertemuan 7 Tahap 9

abstract class CourseDataSource {
  Future<List<Course>> getCourses();

  Future<Course> createCourse(Course course);

  Future<void> updateCourse(int id, Course course);

  Future<void> deleteCourse(int id);
}

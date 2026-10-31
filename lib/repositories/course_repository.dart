
import '../models/course.dart';
import '../services/course_data_source.dart';

// Nama: I Gusti Made Wahyu Nugraha
// NIM: 2455011005
// WO Pertemuan 7 Tahap 9

class CourseRepository {
  CourseRepository(this.dataSource);

  final CourseDataSource dataSource;

  Future<List<Course>> getCourses() {
    return dataSource.getCourses();
  }

  Future<Course> createCourse(Course course) {
    return dataSource.createCourse(course);
  }

  Future<void> updateCourse(
    int id,
    Course course,
  ) {
    return dataSource.updateCourse(id, course);
  }

  Future<void> deleteCourse(int id) {
    return dataSource.deleteCourse(id);
  }
}

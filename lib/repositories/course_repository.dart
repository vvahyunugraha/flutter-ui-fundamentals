
import '../models/course.dart';
import '../services/course_api_service.dart';

// Nama: I Gusti Made Wahyu Nugraha
// NIM: 2455011005
// WO Pertemuan 7 Tahap 6: Repository Pattern

class CourseRepository {
  final CourseApiService service;

  CourseRepository(this.service);

  Future<List<Course>> getCourses() {
    return service.getCourses();
  }

  Future<Course> createCourse(Course course) {
    return service.createCourse(course);
  }
}

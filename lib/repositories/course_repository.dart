import '../models/course.dart';
import '../services/course_service.dart';

// Nama: I Gusti Made Wahyu Nugraha
// NIM: 2455011005
// Tahap 10: Repository Pattern

class CourseRepository {
  final CourseService service;

  CourseRepository(this.service);

  Future<List<Course>> getCourses() {
    return service.loadCourses();
  }
}

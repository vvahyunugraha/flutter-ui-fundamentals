
import '../models/course.dart';
import '../services/course_api_service.dart';

// Nama: I Gusti Made Wahyu Nugraha
// NIM: 2455011005
// WO Pertemuan 7 Tahap 7: Repository Pattern

class CourseRepository {
  final CourseApiService service;

  CourseRepository(this.service);

  // GET: Mengambil daftar course.
  Future<List<Course>> getCourses() {
    return service.getCourses();
  }

  // POST: Membuat course baru.
  Future<Course> createCourse(Course course) {
    return service.createCourse(course);
  }

  // PUT: Memperbarui course.
  Future<Course> updateCourse(
    int id,
    Course course,
  ) {
    return service.updateCourse(id, course);
  }
}


import 'course.dart';

const List<Map<String, dynamic>> sampleCourseJson = [
  {
    'id': 1,
    'code': 'MOB01',
    'title': 'Git & GitHub',
    'credits': 2,
    'status': 'active',
  },
  {
    'id': 2,
    'code': 'MOB02',
    'title': 'Flutter UI Fundamentals',
    'credits': 3,
    'status': 'planned',
  },
  {
    'id': 3,
    'code': 'MOB03',
    'title': 'REST API',
    'credits': 3,
  },
];

List<Course> loadSampleCourses() {
  return sampleCourseJson
      .map((json) => Course.fromJson(json))
      .toList();
}

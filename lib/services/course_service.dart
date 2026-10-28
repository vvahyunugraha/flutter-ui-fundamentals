
import 'dart:convert';

import 'package:flutter/services.dart';
import '../models/course.dart';

// Nama: I Gusti Made Wahyu Nugraha
// NIM: 2455011005
// Tahap 9: Service / Data Source

class CourseService {
  Future<List<Course>> loadCourses() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/student_data.json',
    );

    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final list = data['courses'] as List<dynamic>;

    return list
        .map(
          (e) => Course.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }
}

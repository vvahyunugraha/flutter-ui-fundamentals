
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/course.dart';
import 'course_data_source.dart';

// Nama: I Gusti Made Wahyu Nugraha
// NIM: 2455011005
// WO Pertemuan 7 Tahap 9

class CourseApiService implements CourseDataSource {
  CourseApiService({
    this.baseUrl = 'https://jsonplaceholder.typicode.com',
  });

  final String baseUrl;

  @override
  Future<List<Course>> getCourses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil data course. '
        'HTTP ${response.statusCode}',
      );
    }

    final List<dynamic> data =
        jsonDecode(response.body) as List<dynamic>;

    debugPrint('GET berhasil');
    debugPrint('Jumlah item API: ${data.length}');

    return data.map((item) {
      final json = Map<String, dynamic>.from(item as Map);

      return Course(
        id: json['id'] as int?,
        code: 'POST${json['id']}',
        title: json['title'] as String,
        credits: 3,
        status: 'planned',
      );
    }).toList();
  }

  @override
  Future<Course> createCourse(Course course) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      debugPrint('POST berhasil');

      return Course.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Gagal membuat course. '
      'HTTP ${response.statusCode}',
    );
  }

  @override
  Future<void> updateCourse(
    int id,
    Course course,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/posts/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Gagal memperbarui course. '
        'HTTP ${response.statusCode}',
      );
    }

    debugPrint('PUT berhasil');
    debugPrint('Course ID: $id');
  }

  @override
  Future<void> deleteCourse(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$id'),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Gagal menghapus course. '
        'HTTP ${response.statusCode}',
      );
    }

    debugPrint('DELETE berhasil');
    debugPrint('Course ID: $id');
  }
}


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'models/course.dart';
import 'models/course_test_data.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/home_page.dart';
import 'services/course_service.dart';

// Endpoint latihan untuk mengambil daftar data melalui HTTP GET.
const String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

// Fungsi sementara untuk pengujian HTTP GET pada WO 7 Tahap 2.
Future<List<dynamic>> fetchCourses() async {
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List<dynamic>;

    debugPrint('GET berhasil');
    debugPrint('Jumlah item: ${data.length}');

    return data;
  }

  throw Exception('HTTP ${response.statusCode}');
}

// Pengujian JSON mapping untuk WO 7 Tahap 3.
void testCourseJsonMapping() {
  final courses = sampleCourseJson
      .map((json) => Course.fromJson(json))
      .toList();

  debugPrint('Jumlah mata kuliah hasil mapping: ${courses.length}');

  for (final course in courses) {
    debugPrint(
      '${course.code} | ${course.title} | ${course.status}',
    );
  }

  debugPrint('Hasil toJson: ${courses.first.toJson()}');
}

void main() {
  // Pengujian JSON mapping Tahap 3.
  testCourseJsonMapping();

  // Pengujian GET dari Tahap 2 tetap dipertahankan.
  fetchCourses().catchError((Object error) {
    debugPrint('GET gagal: $error');
    return <dynamic>[];
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourseState()),
        ChangeNotifierProvider(
          create: (_) => CourseProvider(CourseRepository(CourseService())),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learning Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

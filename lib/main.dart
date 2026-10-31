
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'models/course.dart';
import 'models/course_test_data.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/home_page.dart';
import 'services/course_api_service.dart';

// Nama: I Gusti Made Wahyu Nugraha
// NIM: 2455011005

// Pengujian JSON mapping untuk WO 7 Tahap 3.
void testCourseJsonMapping() {
  final courses = sampleCourseJson
      .map((json) => Course.fromJson(json))
      .toList();

  debugPrint(
    'Jumlah mata kuliah hasil mapping: ${courses.length}',
  );

  for (final course in courses) {
    debugPrint(
      '${course.code} | ${course.title} | ${course.status}',
    );
  }

  if (courses.isNotEmpty) {
    debugPrint(
      'Hasil toJson: ${courses.first.toJson()}',
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase untuk WO 7 Tahap 10.
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.supabaseAnonKey,
  );

  // Pengujian JSON mapping untuk WO 7 Tahap 3.
  testCourseJsonMapping();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CourseState(),
        ),
        ChangeNotifierProvider(
          create: (_) => CourseProvider(
            CourseRepository(
              CourseApiService(),
            ),
          ),
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

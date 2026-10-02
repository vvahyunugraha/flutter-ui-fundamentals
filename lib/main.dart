
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

const String studentName = 'I Gusti Made Wahyu Nugraha';
const String studentId = '2455011005';

Future<Map<String, dynamic>> loadStudentData() async {
  final jsonString = await rootBundle.loadString(
    'assets/data/student_data.json',
  );

  return jsonDecode(jsonString) as Map<String, dynamic>;
}

void main() {
  runApp(const MyApp());
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
      // Halaman sementara untuk menguji Kasus A.
      home: const DashboardPage(),
    );
  }
}



// HALAMAN LEARNING DASHBOARD
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> studentFuture;

  @override
  void initState() {
    super.initState();
    studentFuture = loadStudentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learning Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: studentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Gagal memuat data:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text('Data tidak tersedia.'),
              );
            }

            final data = snapshot.data!;
            final student = Map<String, dynamic>.from(
              data['student'] as Map,
            );

            final courses = (data['courses'] as List)
                .map(
                  (course) => Map<String, dynamic>.from(
                    course as Map,
                  ),
                )
                .toList();

            final totalCredits = courses.fold<int>(
              0,
              (sum, course) =>
                  sum + (course['credits'] as int? ?? 0),
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileCard(student: student),
                  const SizedBox(height: 20),
                  const GreetingCard(),
                  const SizedBox(height: 20),
                  const Text(
                    'Ringkasan Pembelajaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Total Mata Kuliah',
                          value: courses.length.toString(),
                          icon: Icons.menu_book,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          title: 'Total SKS',
                          value: totalCredits.toString(),
                          icon: Icons.school,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Daftar Mata Kuliah',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    itemCount: courses.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return CourseCard(
                        course: courses[index],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final Map<String, dynamic> student;

  const ProfileCard({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    final name = student['name']?.toString() ?? studentName;
    final nim = student['nim']?.toString() ?? studentId;
    final semester =
        student['semester']?.toString() ?? 'Semester 5';

    return Card(
      elevation: 3,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text('NIM: $nim'),
                  const SizedBox(height: 5),
                  Text(
                    semester,
                    style: TextStyle(
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseCard({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final title = course['title']?.toString() ?? '-';
    final code = course['code']?.toString() ?? '-';
    final credits = course['credits']?.toString() ?? '0';
    final status = course['status']?.toString() ?? 'planned';

    IconData statusIcon;
    Color statusColor;
    String statusText;

    if (status == 'done') {
      statusIcon = Icons.check_circle;
      statusColor = Colors.green;
      statusText = 'Selesai';
    } else if (status == 'active') {
      statusIcon = Icons.play_circle;
      statusColor = Colors.blue;
      statusText = 'Aktif';
    } else {
      statusIcon = Icons.schedule;
      statusColor = Colors.orange;
      statusText = 'Rencana';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              statusIcon,
              color: statusColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text('Kode: $code'),
                  Text('SKS: $credits'),
                  const SizedBox(height: 5),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GreetingCard extends StatefulWidget {
  const GreetingCard({super.key});

  @override
  State<GreetingCard> createState() => _GreetingCardState();
}

class _GreetingCardState extends State<GreetingCard> {
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(
              Icons.waving_hand,
              color: Colors.orange,
              size: 30,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isVisible
                    ? 'Halo, Wahyu! Selamat belajar Flutter.'
                    : 'Tetap semangat belajar!',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  isVisible = !isVisible;
                });
              },
              icon: const Icon(Icons.refresh),
              tooltip: 'Ubah sapaan',
            ),
          ],
        ),
      ),
    );
  }
}
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

// =====================================================
// TAHAP 5 - GRIDVIEW RESPONSIF
// =====================================================

int columnsFor(double width) {
  if (width < 600) return 1;
  if (width < 840) return 2;
  return 3;
}

void main() {
  runApp(const MyApp());
}

// =====================================================
// MY APP
// =====================================================

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

// =====================================================
// TAHAP 10 & 11 - NAVIGATION SHELL
// =====================================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> studentFuture;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    studentFuture = loadStudentData();
  }

  // ===================================================
  // TAHAP 11: NAVIGATION BAR
  // ===================================================

  Widget buildNavigationBar() {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.school),
          label: 'Courses',
        ),
        NavigationDestination(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  // ===================================================
  // TAHAP 11: NAVIGATION RAIL
  // ===================================================

  Widget buildNavigationRail() {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.school),
          label: Text('Courses'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learning Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: studentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
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
                child: Text(
                  'Data tidak tersedia.',
                ),
              );
            }

            final data = snapshot.data!;

            final student =
                Map<String, dynamic>.from(
              data['student'] as Map,
            );

            final courses =
                (data['courses'] as List)
                    .map(
                      (course) =>
                          Map<String, dynamic>.from(
                        course as Map,
                      ),
                    )
                    .toList();

            Widget currentPage;

            if (currentIndex == 0) {
              currentPage = _buildHomePage(
                student: student,
                courses: courses,
              );
            } else if (currentIndex == 1) {
              currentPage = _buildCoursesPage(
                courses: courses,
              );
            } else {
              currentPage = _buildProfilePage(
                student: student,
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 840) {
                  return currentPage;
                }

                return Row(
                  children: [
                    buildNavigationRail(),
                    const VerticalDivider(
                      width: 1,
                    ),
                    Expanded(
                      child: currentPage,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),

      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 840) {
            return buildNavigationBar();
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // =====================================================
  // HOME
  // =====================================================

  Widget _buildHomePage({
    required Map<String, dynamic> student,
    required List<Map<String, dynamic>> courses,
  }) {
    final totalCredits = courses.fold<int>(
      0,
      (sum, course) =>
          sum + (course['credits'] as int? ?? 0),
    );

    final size = MediaQuery.of(context).size;
    final orientation =
        MediaQuery.of(context).orientation;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          ProfileCard(
            student: student,
          ),

          const SizedBox(height: 20),

          // =================================================
          // TAHAP 1
          // =================================================

          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.all(16),
                  color: Colors.blue.shade100,
                  child: const Text(
                    '$studentId - $studentName',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // =================================================
          // TAHAP 2
          // =================================================

          Text(
            'Width: '
            '${size.width.toStringAsFixed(0)}',
          ),

          Text(
            'Height: '
            '${size.height.toStringAsFixed(0)}',
          ),

          Text(
            'Orientation: $orientation',
          ),

          Text(
            'Nama: $studentName',
          ),

          Text(
            'NIM: $studentId',
          ),

          Text(
            size.width < 600
                ? 'Compact'
                : 'Wide',
          ),

          const SizedBox(height: 20),

          // =================================================
          // TAHAP 3
          // =================================================

          const Text(
            'Tahap 3 - Layout Responsif',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return const CompactLayout();
              } else if (constraints.maxWidth < 840) {
                return const MediumLayout();
              } else {
                return const ExpandedLayout();
              }
            },
          ),

          const SizedBox(height: 20),

          const GreetingCard(),

          const SizedBox(height: 20),

          // =================================================
          // TAHAP 4
          // =================================================

          const Text(
            'Tahap 4 - Expanded, Flexible, dan Wrap',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Row(
            children: [
              Expanded(
                flex: 2,
                child: PanelBox(
                  title: 'Panel A',
                  description: 'Flex 2',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: PanelBox(
                  title: 'Panel B',
                  description: 'Flex 1',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            'Skill',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text('Flutter'),
              ),
              Chip(
                label: Text('Dart'),
              ),
              Chip(
                label: Text('Laravel'),
              ),
              Chip(
                label: Text('React'),
              ),
              Chip(
                label: Text('Figma'),
              ),
              Chip(
                label: Text('UI/UX'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            'Perbandingan Row dan Wrap',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Wrap akan memindahkan item ke baris '
            'berikutnya ketika ruang tidak cukup.',
          ),

          const SizedBox(height: 20),

          // =================================================
          // RINGKASAN
          // =================================================

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

          // =================================================
          // TAHAP 5
          // =================================================

          const Text(
            'Tahap 5 - GridView Responsif',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      columnsFor(
                    constraints.maxWidth,
                  ),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: courses.length,
                itemBuilder:
                    (context, index) =>
                        CourseCard(
                  course: courses[index],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // =================================================
          // TAHAP 6
          // =================================================

          const Text(
            'Tahap 6 - Scrollable Content',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Menguji halaman profil dan form '
            'yang lebih tinggi dari layar.',
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ProfileFormPage(),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text(
                'Buka Form Tahap 6',
              ),
            ),
          ),

          const SizedBox(height: 24),

          // =================================================
          // TAHAP 7
          // =================================================

          const Text(
            'Tahap 7 - Navigation Dasar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Menguji Navigator.push() dan Navigator.pop().',
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const HomePage(),
                  ),
                );
              },
              icon: const Icon(Icons.navigation),
              label: const Text(
                'Buka Home Page',
              ),
            ),
          ),

          const SizedBox(height: 24),

          // =================================================
          // TAHAP 8
          // =================================================

          const Text(
            'Tahap 8 - Passing Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Tekan salah satu course untuk membuka '
            'detail dan melihat data yang dikirim.',
          ),

          const SizedBox(height: 24),

          // =================================================
          // TAHAP 9
          // =================================================

          const Text(
            'Tahap 9 - Returning Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Pilih course pada detail untuk mengirim '
            'hasil kembali ke halaman sebelumnya.',
          ),

          const SizedBox(height: 24),

          // =================================================
          // TAHAP 10
          // =================================================

          const Text(
            'Tahap 10 - NavigationBar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Gunakan navigasi utama untuk berpindah '
            'antara Home, Courses, dan Profile.',
          ),

          const SizedBox(height: 24),

          // =================================================
          // TAHAP 11
          // =================================================

          const Text(
            'Tahap 11 - Adaptive Navigation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'NavigationBar digunakan pada layar '
            'compact/medium dan NavigationRail '
            'digunakan pada layar expanded.',
          ),

          const SizedBox(height: 24),

          // =================================================
          // TAHAP 12
          // =================================================

          const Text(
            'Tahap 12 - Interaction',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Tap course untuk membuka detail, '
            'gunakan icon favorite untuk mengubah '
            'status favorite, dan tekan lama course '
            'untuk melihat informasi.',
          ),

          const SizedBox(height: 24),

          // =================================================
          // TAHAP 13
          // =================================================

          const Text(
            'Tahap 13 - Form & Validation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Form profil menggunakan validasi '
            'untuk memastikan data yang dimasukkan '
            'sudah sesuai.',
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ProfileFormPage(),
                  ),
                );
              },
              icon: const Icon(Icons.assignment),
              label: const Text(
                'Buka Form Tahap 13',
              ),
            ),
          ),

          const SizedBox(height: 24),

          // =================================================
          // TAHAP 14
          // =================================================

          const Text(
            'Tahap 14 - Feedback',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Menggunakan SnackBar, Dialog, dan '
            'CircularProgressIndicator sebagai feedback '
            'kepada pengguna.',
          ),

          const SizedBox(height: 10),

          const Text(
            'SnackBar digunakan untuk informasi singkat, '
            'sedangkan Dialog digunakan untuk konfirmasi '
            'sebelum aksi penting.',
          ),

          // =================================================
          // TAHAP 16 - DEBUGGING CHALLENGE
          // =================================================

          const SizedBox(height: 24),

          const Text(
            'Tahap 16 - Debugging Challenge',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Pengujian dilakukan untuk mengatasi '
            'RenderFlex overflow, unbounded viewport, '
            'keyboard overflow, dan navigasi ganda.',
          ),

          const SizedBox(height: 20),

          // =================================================
          // KASUS A
          // =================================================

          const Text(
            'Kasus A - RenderFlex Overflow',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Menggunakan Expanded pada Text agar teks '
            'panjang menyesuaikan ruang yang tersedia.',
          ),

          const SizedBox(height: 12),

          const DebuggingRow(),

          const SizedBox(height: 20),

          // =================================================
          // KASUS B
          // =================================================

          const Text(
            'Kasus B - Unbounded Height',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'GridView menggunakan shrinkWrap dan '
            'NeverScrollableScrollPhysics agar aman '
            'di dalam SingleChildScrollView.',
          ),

          const SizedBox(height: 20),

          // =================================================
          // KASUS C
          // =================================================

          const Text(
            'Kasus C - Keyboard Overflow',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Form menggunakan SingleChildScrollView '
            'agar tetap dapat diakses ketika keyboard muncul.',
          ),

          const SizedBox(height: 20),

          // =================================================
          // KASUS D
          // =================================================

          const Text(
            'Kasus D - Navigasi Ganda',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Gunakan tombol berikut untuk menguji '
            'pencegahan navigasi ganda.',
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const HomePage(),
                  ),
                );
              },
              icon: const Icon(Icons.bug_report),
              label: const Text(
                'Uji Kasus D - Navigasi',
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Catatan/Temuan: Pada tahap debugging, '
            'masalah layout dapat terjadi karena ruang '
            'yang tidak cukup atau constraint yang tidak jelas. '
            'Penggunaan Expanded, shrinkWrap, dan '
            'SingleChildScrollView membantu menyesuaikan '
            'widget dengan ruang yang tersedia. Pada navigasi, '
            'state isNavigating mencegah tombol ditekan '
            'berulang kali sehingga tidak terjadi navigasi ganda.',
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // =====================================================
  // COURSES
  // =====================================================

  Widget _buildCoursesPage({
    required List<Map<String, dynamic>> courses,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Courses',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Daftar mata kuliah yang tersedia.',
          ),

          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      columnsFor(
                    constraints.maxWidth,
                  ),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: courses.length,
                itemBuilder:
                    (context, index) =>
                        CourseCard(
                  course: courses[index],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          const Text(
            'Nama: I Gusti Made Wahyu Nugraha',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'NIM: 2455011005',
          ),

          const SizedBox(height: 20),

          const Text(
            'Tahap 11 - Adaptive Navigation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Halaman Courses tetap aktif ketika '
            'navigasi berpindah antara NavigationBar '
            'dan NavigationRail.',
          ),

          const SizedBox(height: 20),

          const Text(
            'Tahap 12 - Interaction',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Course dapat ditekan, diberi favorite, '
            'dan ditekan lama untuk menampilkan informasi.',
          ),

          const SizedBox(height: 20),

          const Text(
            'Tahap 13 - Form & Validation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Form validasi dapat dibuka melalui '
            'halaman Profile.',
          ),

          const SizedBox(height: 20),

          const Text(
            'Tahap 14 - Feedback',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Feedback pengguna menggunakan SnackBar, '
            'Dialog, dan loading indicator.',
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PROFILE
  // =====================================================

  Widget _buildProfilePage({
    required Map<String, dynamic> student,
  }) {
    final name =
        student['name']?.toString() ??
            studentName;

    final nim =
        student['nim']?.toString() ??
            studentId;

    final semester =
        student['semester']?.toString() ??
            'Semester 5';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          ProfileCard(
            student: student,
          ),

          const SizedBox(height: 24),

          const Text(
            'Informasi Mahasiswa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Nama: $name',
          ),

          const SizedBox(height: 8),

          Text(
            'NIM: $nim',
          ),

          const SizedBox(height: 8),

          Text(
            'Semester: $semester',
          ),

          const SizedBox(height: 8),

          const Text(
            'Program Studi: '
            'Teknologi Rekayasa Perangkat Lunak',
          ),

          const SizedBox(height: 8),

          const Text(
            'Universitas Pendidikan Ganesha',
          ),

          const SizedBox(height: 24),

          const Text(
            'Tahap 10 - Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Halaman Profile menjadi salah satu '
            'tujuan utama pada NavigationBar '
            'dan NavigationRail.',
          ),

          const SizedBox(height: 20),

          const Text(
            'Tahap 11 - Adaptive Navigation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Nama dan NIM tetap tersedia pada '
            'halaman Profile.',
          ),

          const SizedBox(height: 24),

          const Text(
            'Tahap 13 - Form & Validation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Gunakan form berikut untuk mengisi '
            'data dengan validasi.',
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ProfileFormPage(),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text(
                'Buka Form Profil',
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Tahap 14 - Feedback',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Form menggunakan Dialog untuk konfirmasi, '
            'CircularProgressIndicator untuk loading, '
            'dan SnackBar setelah proses selesai.',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// TAHAP 3 - COMPACT LAYOUT
// =====================================================

class CompactLayout extends StatelessWidget {
  const CompactLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Compact Layout',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Nama: I Gusti Made Wahyu Nugraha',
          ),
          Text(
            'NIM: 2455011005',
          ),
          SizedBox(height: 8),
          Text(
            'Tampilan sederhana untuk layar kecil.',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// TAHAP 3 - MEDIUM LAYOUT
// =====================================================

class MediumLayout extends StatelessWidget {
  const MediumLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.green.shade50,
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Medium Layout',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Nama: I Gusti Made Wahyu Nugraha',
          ),
          Text(
            'NIM: 2455011005',
          ),
          SizedBox(height: 8),
          Text(
            'Tampilan menengah untuk ruang yang lebih luas.',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// TAHAP 3 - EXPANDED LAYOUT
// =====================================================

class ExpandedLayout extends StatelessWidget {
  const ExpandedLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.orange.shade50,
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Expanded Layout',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Nama: I Gusti Made Wahyu Nugraha',
          ),
          Text(
            'NIM: 2455011005',
          ),
          SizedBox(height: 8),
          Text(
            'Tampilan untuk layar lebar seperti tablet atau desktop.',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// TAHAP 4 - PANEL BOX
// =====================================================

class PanelBox extends StatelessWidget {
  final String title;
  final String description;

  const PanelBox({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue,
        ),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(description),
        ],
      ),
    );
  }
}

// =====================================================
// PROFILE CARD
// =====================================================

class ProfileCard extends StatelessWidget {
  final Map<String, dynamic> student;

  const ProfileCard({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        student['name']?.toString() ??
            studentName;

    final nim =
        student['nim']?.toString() ??
            studentId;

    final semester =
        student['semester']?.toString() ??
            'Semester 5';

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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'NIM: $nim',
                  ),

                  const SizedBox(height: 5),

                  Text(
                    semester,
                    style: TextStyle(
                      color:
                          Colors.blue.shade800,
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

// =====================================================
// SUMMARY CARD
// =====================================================

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
        padding:
            const EdgeInsets.symmetric(
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
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// TAHAP 12 - COURSE CARD
// =====================================================

class CourseCard extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseCard({
    super.key,
    required this.course,
  });

  @override
  State<CourseCard> createState() =>
      _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final title =
        widget.course['title']?.toString() ?? '-';

    final code =
        widget.course['code']?.toString() ?? '-';

    final credits =
        widget.course['credits']?.toString() ?? '0';

    final status =
        widget.course['status']?.toString() ??
            'planned';

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
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(12),

        onTap: () async {
          final result =
              await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CourseDetailPage(
                course: widget.course,
              ),
            ),
          );

          if (result == true &&
              context.mounted) {
            setState(() {
              isFavorite = true;
            });

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              const SnackBar(
                content: Text(
                  'Course berhasil dipilih',
                ),
              ),
            );
          }
        },

        onLongPress: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                'Course: $title\nKode: $code',
              ),
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: 28,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Kode: $code',
                    ),

                    Text(
                      'SKS: $credits',
                    ),

                    const SizedBox(height: 5),

                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFavorite
                            ? 'Course ditambahkan ke favorite'
                            : 'Course dihapus dari favorite',
                      ),
                    ),
                  );
                },
                icon: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                color: isFavorite
                    ? Colors.red
                    : null,
                tooltip: isFavorite
                    ? 'Hapus favorite'
                    : 'Tambah favorite',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// TAHAP 8 & 9 - COURSE DETAIL PAGE
// =====================================================

class CourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailPage({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        course['title']?.toString() ?? '-';

    final code =
        course['code']?.toString() ?? '-';

    final credits =
        course['credits']?.toString() ?? '0';

    final status =
        course['status']?.toString() ??
            'planned';

    String statusText;

    if (status == 'done') {
      statusText = 'Selesai';
    } else if (status == 'active') {
      statusText = 'Aktif';
    } else {
      statusText = 'Rencana';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Course Detail',
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              '$studentId - $studentName',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Detail Course',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 2,
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Kode: $code',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'SKS: $credits',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Status: $statusText',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Informasi Mahasiswa',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Nama: $studentName',
            ),

            const SizedBox(height: 8),

            const Text(
              'NIM: $studentId',
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    true,
                  );
                },
                child: const Text(
                  'Pilih/Favorite',
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                child: const Text(
                  'Kembali',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// GREETING CARD
// =====================================================

class GreetingCard extends StatefulWidget {
  const GreetingCard({super.key});

  @override
  State<GreetingCard> createState() =>
      _GreetingCardState();
}

class _GreetingCardState
    extends State<GreetingCard> {
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding:
            const EdgeInsets.all(12),
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
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),

            IconButton(
              onPressed: () {
                setState(() {
                  isVisible =
                      !isVisible;
                });
              },
              icon: const Icon(
                Icons.refresh,
              ),
              tooltip: 'Ubah sapaan',
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// TAHAP 6, 13 & 14 - PROFILE / FORM
// =====================================================

class ProfileFormPage extends StatefulWidget {
  const ProfileFormPage({super.key});

  @override
  State<ProfileFormPage> createState() =>
      _ProfileFormPageState();
}

class _ProfileFormPageState
    extends State<ProfileFormPage> {
  final _formKey =
      GlobalKey<FormState>();

  final nameController =
      TextEditingController(
    text: studentName,
  );

  final emailController =
      TextEditingController();

  final addressController =
      TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  String? validateName(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }

    final emailPattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailPattern.hasMatch(
      value.trim(),
    )) {
      return 'Masukkan email yang valid';
    }

    return null;
  }

  String? validateAddress(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Alamat tidak boleh kosong';
    }

    return null;
  }

  // ===================================================
  // TAHAP 14 - DIALOG
  // ===================================================

  Future<bool> showSaveConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi',
          ),
          content: const Text(
            'Apakah data profil ingin disimpan?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Batal',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Simpan',
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // ===================================================
  // TAHAP 14 - LOADING
  // ===================================================

  Future<void> processSave() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'Data berhasil disimpan',
        ),
      ),
    );
  }

  Future<void> saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final confirmed =
        await showSaveConfirmation();

    if (!confirmed || !mounted) {
      return;
    }

    await processSave();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil Mahasiswa',
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      // =================================================
      // TAHAP 6 & KASUS C
      // =================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                '$studentId - $studentName',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Form Profil Mahasiswa',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Nama',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller:
                    nameController,
                decoration:
                    const InputDecoration(
                  labelText: 'Nama',
                  hintText:
                      'Masukkan nama',
                  border:
                      OutlineInputBorder(),
                ),
                validator:
                    validateName,
              ),

              const SizedBox(height: 16),

              const Text(
                'Email',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller:
                    emailController,
                keyboardType:
                    TextInputType.emailAddress,
                decoration:
                    const InputDecoration(
                  labelText: 'Email',
                  hintText:
                      'Masukkan email',
                  border:
                      OutlineInputBorder(),
                ),
                validator:
                    validateEmail,
              ),

              const SizedBox(height: 16),

              const Text(
                'Alamat',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller:
                    addressController,
                maxLines: 4,
                decoration:
                    const InputDecoration(
                  labelText: 'Alamat',
                  hintText:
                      'Masukkan alamat',
                  border:
                      OutlineInputBorder(),
                ),
                validator:
                    validateAddress,
              ),

              const SizedBox(height: 20),

              const Text(
                'Informasi Tambahan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Program Studi: '
                'Teknologi Rekayasa Perangkat Lunak',
              ),

              const SizedBox(height: 12),

              const Text(
                'Universitas Pendidikan Ganesha',
              ),

              const SizedBox(height: 12),

              const Text(
                'Semester: 5',
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(16),
                decoration:
                    BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    8,
                  ),
                ),
                child: const Text(
                  'Konten ini dibuat lebih tinggi '
                  'dari layar untuk menguji '
                  'kemampuan scroll.',
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Catatan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const TextField(
                maxLines: 5,
                decoration:
                    InputDecoration(
                  hintText:
                      'Tulis catatan pembelajaran...',
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // =================================================
              // TAHAP 14
              // =================================================

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : saveForm,
                  child: isLoading
                      ? const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Menyimpan...',
                            ),
                          ],
                        )
                      : const Text(
                          'Simpan Profil',
                        ),
                ),
              ),

              const SizedBox(height: 300),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// TAHAP 16 - KASUS A
// RENDERFLEX OVERFLOW
// =====================================================

class DebuggingRow extends StatelessWidget {
  const DebuggingRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.info),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            '$studentId - $studentName - '
            'teks sangat panjang untuk menguji '
            'RenderFlex overflow pada Row.',
          ),
        ),
      ],
    );
  }
}

// =====================================================
// TAHAP 7 & 16 - HOME PAGE
// KASUS D: NAVIGASI GANDA
// =====================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState
    extends State<HomePage> {
  bool isNavigating = false;

  // ===================================================
  // KASUS D
  // MENCEGAH NAVIGASI GANDA
  // ===================================================

  Future<void> openDetail() async {
    if (isNavigating) {
      return;
    }

    setState(() {
      isNavigating = true;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const DetailPage(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isNavigating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Page',
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              '$studentId - $studentName',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Tahap 7 - Navigation Dasar',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Halaman Home dibuat untuk menguji '
              'Navigator.push() dan Navigator.pop().',
            ),

            const SizedBox(height: 24),

            // =================================================
            // TAHAP 16
            // =================================================

            const Text(
              'Tahap 16 - Kasus D',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Tombol dibuat nonaktif ketika proses '
              'navigasi sedang berlangsung untuk '
              'mencegah navigasi ganda.',
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isNavigating
                        ? null
                        : openDetail,
                child: isNavigating
                    ? const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Membuka halaman...',
                          ),
                        ],
                      )
                    : const Text(
                        'Buka Detail',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// TAHAP 7 - DETAIL PAGE
// =====================================================

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Page',
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              '$studentId - $studentName',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Detail Page',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Halaman ini dibuka menggunakan '
              'Navigator.push().',
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                child: const Text(
                  'Kembali',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
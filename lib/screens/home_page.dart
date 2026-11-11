
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../widgets/course_card.dart';
import '../widgets/error_view.dart';
import '../widgets/role_guard.dart';
import '../pages/course_form_page.dart';
import 'favorites_page.dart';

const String studentName = 'I Gusti Made Wahyu Nugraha';
const String studentId = '2455011005';

Future<Map<String, dynamic>> loadStudentData() async {
  final jsonString = await rootBundle.loadString(
    'assets/data/student_data.json',
  );

  return jsonDecode(jsonString) as Map<String, dynamic>;
}

int columnsFor(double width) {
  if (width < 600) return 1;
  if (width < 840) return 2;
  return 3;
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> studentFuture;
  late Future<UserProfile?> profileFuture;

  String? currentUserRole;
  bool isRoleLoading = true;
  String? roleError;

  int currentIndex = 0;

  final ValueNotifier<int> counter = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();

    studentFuture = loadStudentData();
    profileFuture = ProfileService.instance.getMyProfile();

    _loadUserRole();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CourseProvider>().loadCourses();
      }
    });
  }

  Future<void> _loadUserRole() async {
    try {
      setState(() {
        isRoleLoading = true;
        roleError = null;
      });

      final profile = await ProfileService.instance.getMyProfile();

      if (!mounted) return;

      setState(() {
        currentUserRole = profile?.role.trim().toLowerCase();
        isRoleLoading = false;

        if (currentUserRole == null ||
            currentUserRole!.isEmpty) {
          roleError = 'Role pengguna tidak ditemukan.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        currentUserRole = null;
        isRoleLoading = false;
        roleError = 'Gagal mengambil role pengguna: $e';
      });

      debugPrint('Gagal mengambil role pengguna: $e');
    }
  }

  @override
  void dispose() {
    counter.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    try {
      await AuthService.instance.logout();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal logout: $e'),
        ),
      );
    }
  }

  // Hanya owner dan admin yang boleh mengelola Course.
  bool get _canManageCourses {
    return currentUserRole == 'owner' ||
        currentUserRole == 'admin';
  }

  Future<void> _openCourseForm() async {
    // Pemeriksaan role dilakukan sebelum membuka halaman form.
    if (!_canManageCourses) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Akses ditolak. Hanya Owner dan Admin '
            'yang dapat menambahkan Course.',
          ),
        ),
      );
      return;
    }

    final provider = context.read<CourseProvider>();

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CourseFormPage(
          provider: provider,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await provider.loadCourses();
    }
  }

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
          icon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        NavigationDestination(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

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
          icon: Icon(Icons.favorite),
          label: Text('Favorites'),
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: isRoleLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : roleError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 48,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            roleError!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _loadUserRole,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                : FutureBuilder<Map<String, dynamic>>(
                    future: studentFuture,
                    builder: (context, studentSnapshot) {
                      if (studentSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (studentSnapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  studentName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text('NIM: $studentId'),
                                const SizedBox(height: 12),
                                const Text(
                                  'Gagal memuat data mahasiswa.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${studentSnapshot.error}',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      studentFuture =
                                          loadStudentData();
                                    });
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (!studentSnapshot.hasData) {
                        return const Center(
                          child: Text(
                            'Data mahasiswa tidak tersedia.',
                          ),
                        );
                      }

                      final data = studentSnapshot.data!;
                      final student =
                          Map<String, dynamic>.from(
                        data['student'] as Map,
                      );

                      return Consumer<CourseProvider>(
                        builder: (context, courseProvider, child) {
                          if (courseProvider.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (courseProvider.error != null) {
                            return ErrorView(
                              message: courseProvider.error!,
                              onRetry: () {
                                context
                                    .read<CourseProvider>()
                                    .loadCourses();
                              },
                            );
                          }

                          final courses = courseProvider.courses;
                          final userRole = currentUserRole!;

                          late Widget currentPage;

                          if (currentIndex == 0) {
                            currentPage = _buildHomePage(
                              student: student,
                              courses: courses,
                              userRole: userRole,
                            );
                          } else if (currentIndex == 1) {
                            currentPage = _buildCoursesPage(
                              courses: courses,
                              userRole: userRole,
                            );
                          } else if (currentIndex == 2) {
                            currentPage = FavoritesPage(
                              userRole: userRole,
                            );
                          } else {
                            currentPage = _buildProfilePage(
                              student: student,
                            );
                          }

                          if (courses.isEmpty &&
                              currentIndex == 1) {
                            currentPage = _buildEmptyCoursesPage();
                          }

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 840) {
                                return currentPage;
                              }

                              return Row(
                                children: [
                                  buildNavigationRail(),
                                  const VerticalDivider(width: 1),
                                  Expanded(child: currentPage),
                                ],
                              );
                            },
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

  Widget _buildEmptyCoursesPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text('Data course belum tersedia.'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CourseProvider>().loadCourses();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Muat Ulang'),
            ),
            const SizedBox(height: 8),
            if (_canManageCourses)
              OutlinedButton.icon(
                onPressed: _openCourseForm,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Course'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage({
    required Map<String, dynamic> student,
    required List<Course> courses,
    required String userRole,
  }) {
    final totalCredits = courses.fold<int>(
      0,
      (sum, course) => sum + course.credits,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileCard(student: student),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Demo ValueNotifier',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ubah nilai counter tanpa memanggil setState '
                    'pada DashboardPage.',
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<int>(
                    valueListenable: counter,
                    builder: (context, value, child) {
                      return Text(
                        'Nilai counter: $value',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          if (counter.value > 0) {
                            counter.value--;
                          }
                        },
                        child: const Icon(Icons.remove),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          counter.value++;
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Consumer<CourseState>(
            builder: (context, courseState, child) {
              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                  title: const Text('Mata Kuliah Favorit'),
                  subtitle: const Text(
                    'Jumlah mata kuliah yang ditandai favorit',
                  ),
                  trailing: Text(
                    '${courseState.favorites.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      currentIndex = 2;
                    });
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Ringkasan Pembelajaran',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Mata Kuliah',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mata Kuliah',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    currentIndex = 1;
                  });
                },
                child: const Text('Lihat semua'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCourseGrid(courses, 'home', userRole),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileFormPage(),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Profil'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesPage({
    required List<Course> courses,
    required String userRole,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mata Kuliah',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Lihat detail dan tandai mata kuliah favorit.',
          ),
          Consumer<CourseState>(
            builder: (context, courseState, child) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Jumlah favorit: ${courseState.favorites.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Tombol tambah hanya untuk Owner dan Admin.
          if (_canManageCourses)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openCourseForm,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Course'),
              ),
            ),

          const SizedBox(height: 16),
          _buildCourseGrid(courses, 'courses', userRole),
        ],
      ),
    );
  }

  Widget _buildCourseGrid(
    List<Course> courses,
    String prefix,
    String userRole,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnsFor(constraints.maxWidth),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio:
                constraints.maxWidth < 600 ? 1.55 : 1.35,
          ),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];

            final isFavorite = context
                .watch<CourseState>()
                .isFavorite(course.code);

            return CourseCard(
              key: ValueKey('${prefix}_${course.code}'),
              course: course,
              isFavorite: isFavorite,
              userRole: userRole,
            );
          },
        );
      },
    );
  }

  Widget _buildProfilePage({
    required Map<String, dynamic> student,
  }) {
    final name = student['name']?.toString() ?? studentName;
    final nim = student['nim']?.toString() ?? studentId;
    final semester =
        student['semester']?.toString() ?? 'Semester 5';

    return FutureBuilder<UserProfile?>(
      future: profileFuture,
      builder: (context, profileSnapshot) {
        String accountName = 'Belum tersedia';
        String accountEmail = 'Belum tersedia';
        String accountRole = 'Belum tersedia';

        if (profileSnapshot.hasData &&
            profileSnapshot.data != null) {
          final profile = profileSnapshot.data!;

          accountName = profile.name.isNotEmpty
              ? profile.name
              : 'Belum diisi';

          accountEmail = profile.email.isNotEmpty
              ? profile.email
              : 'Belum tersedia';

          accountRole = profile.role.isNotEmpty
              ? profile.role[0].toUpperCase() +
                  profile.role.substring(1)
              : 'Belum tersedia';
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profil Mahasiswa',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ProfileCard(student: student),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Mahasiswa',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _profileInfoRow(
                        Icons.badge_outlined,
                        'Nama',
                        name,
                      ),
                      _profileInfoRow(
                        Icons.numbers,
                        'NIM',
                        nim,
                      ),
                      _profileInfoRow(
                        Icons.school_outlined,
                        'Semester',
                        semester,
                      ),
                      _profileInfoRow(
                        Icons.account_balance_outlined,
                        'Program Studi',
                        'Teknologi Rekayasa Perangkat Lunak',
                      ),
                      _profileInfoRow(
                        Icons.location_city_outlined,
                        'Universitas',
                        'Universitas Pendidikan Ganesha',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Akun',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (profileSnapshot.connectionState ==
                          ConnectionState.waiting)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (profileSnapshot.hasError)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gagal memuat profil dari Supabase.',
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${profileSnapshot.error}',
                              style: const TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    profileFuture = ProfileService
                                        .instance
                                        .getMyProfile();
                                  });
                                  _loadUserRole();
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Coba Lagi'),
                              ),
                            ),
                          ],
                        )
                      else if (profileSnapshot.data == null)
                        const Text(
                          'Data profil belum ditemukan pada tabel profiles.',
                        )
                      else ...[
                        _profileInfoRow(
                          Icons.person_outline,
                          'Nama',
                          accountName,
                        ),
                        _profileInfoRow(
                          Icons.email_outlined,
                          'Email',
                          accountEmail,
                        ),
                        _profileInfoRow(
                          Icons.admin_panel_settings_outlined,
                          'Role',
                          accountRole,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileFormPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profil'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _profileInfoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
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
            Icon(icon, size: 30, color: color),
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

class ProfileFormPage extends StatefulWidget {
  const ProfileFormPage({super.key});

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController =
      TextEditingController(text: studentName);
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }

    final emailPattern =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(value.trim())) {
      return 'Masukkan email yang valid';
    }

    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Alamat tidak boleh kosong';
    }

    return null;
  }

  Future<bool> showSaveConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
            'Apakah data profil ingin disimpan?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> processSave() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil disimpan'),
      ),
    );
  }

  Future<void> saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final confirmed = await showSaveConfirmation();

    if (!confirmed || !mounted) {
      return;
    }

    await processSave();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '$studentId - $studentName',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Form Profil Mahasiswa',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Nama',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  hintText: 'Masukkan nama',
                  border: OutlineInputBorder(),
                ),
                validator: validateName,
              ),
              const SizedBox(height: 16),
              const Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Masukkan email',
                  border: OutlineInputBorder(),
                ),
                validator: validateEmail,
              ),
              const SizedBox(height: 16),
              const Text(
                'Alamat',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: addressController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  hintText: 'Masukkan alamat',
                  border: OutlineInputBorder(),
                ),
                validator: validateAddress,
              ),
              const SizedBox(height: 20),
              const Text(
                'Informasi Tambahan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
              const Text('Semester: 5'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveForm,
                  child: isLoading
                      ? const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Menyimpan...'),
                          ],
                        )
                      : const Text('Simpan Profil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';

const String studentName = 'I Gusti Made Wahyu Nugraha';
const String studentId = '2455011005';

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({
    super.key,
    required this.course,
  });

  String getStatusText(String status) {
    if (status == 'done') return 'Selesai';
    if (status == 'active') return 'Aktif';
    return 'Rencana';
  }

  Future<void> _openEditForm(BuildContext context) async {
    if (course.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course tidak memiliki ID untuk diperbarui.'),
        ),
      );
      return;
    }

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CourseEditPage(course: course),
      ),
    );

    if (!context.mounted) return;

    if (updated == true) {
      // Kembali ke daftar agar perubahan terlihat.
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = getStatusText(course.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Detail'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 24),
            const Text(
              'Detail Course',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Kode: ${course.code}'),
                    const SizedBox(height: 8),
                    Text('SKS: ${course.credits}'),
                    const SizedBox(height: 8),
                    Text('Status: $statusText'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tombol Edit untuk membuka form pembaruan.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openEditForm(context),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Course'),
              ),
            ),

            const SizedBox(height: 24),
            Consumer<CourseState>(
              builder: (context, courseState, child) {
                final isFavorite =
                    courseState.isFavorite(course.code);

                return Card(
                  child: ListTile(
                    leading: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    title: Text(
                      isFavorite
                          ? 'Mata kuliah favorit'
                          : 'Belum menjadi favorit',
                    ),
                    trailing: IconButton(
                      tooltip: isFavorite
                          ? 'Hapus favorit'
                          : 'Tambah favorit',
                      onPressed: () {
                        courseState.toggleFavorite(course.code);
                      },
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                    ),
                  ),
                );
              },
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
            const Text('Nama: $studentName'),
            const SizedBox(height: 8),
            const Text('NIM: $studentId'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Form untuk memperbarui course menggunakan HTTP PUT.
class CourseEditPage extends StatefulWidget {
  final Course course;

  const CourseEditPage({
    super.key,
    required this.course,
  });

  @override
  State<CourseEditPage> createState() => _CourseEditPageState();
}

class _CourseEditPageState extends State<CourseEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _titleController;
  late final TextEditingController _creditsController;

  late String _status;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Mengisi form dengan data course yang lama.
    _codeController = TextEditingController(
      text: widget.course.code,
    );
    _titleController = TextEditingController(
      text: widget.course.title,
    );
    _creditsController = TextEditingController(
      text: widget.course.credits.toString(),
    );
    _status = widget.course.status;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    final id = widget.course.id;

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID course tidak tersedia.'),
        ),
      );
      return;
    }

    final updatedCourse = Course(
      id: id,
      code: widget.course.code,
      title: _titleController.text.trim(),
      credits: int.parse(_creditsController.text.trim()),
      status: _status,
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      await context.read<CourseProvider>().updateCourse(
        id,
        updatedCourse,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course berhasil diperbarui.'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui course: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Course'),
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
              const SizedBox(height: 24),
              const Text(
                'Form Edit Course',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Kode tidak boleh diubah karena digunakan
              // sebagai identitas course pada Favorites.
              TextFormField(
                controller: _codeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Kode Course',
                  border: OutlineInputBorder(),
                  helperText: 'Kode course tidak dapat diubah.',
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Nama Course',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama course tidak boleh kosong.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _creditsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah SKS',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final credits = int.tryParse(value ?? '');

                  if (credits == null || credits <= 0) {
                    return 'Masukkan jumlah SKS yang valid.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status Course',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'planned',
                    child: Text('Rencana'),
                  ),
                  DropdownMenuItem(
                    value: 'active',
                    child: Text('Aktif'),
                  ),
                  DropdownMenuItem(
                    value: 'done',
                    child: Text('Selesai'),
                  ),
                ],
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _status = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      _isSubmitting ? null : _saveChanges,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSubmitting
                        ? 'Menyimpan...'
                        : 'Simpan Perubahan',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

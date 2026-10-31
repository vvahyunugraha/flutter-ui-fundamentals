
import 'package:flutter/material.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';

// Nama: I Gusti Made Wahyu Nugraha
// NIM: 2455011005
// WO Pertemuan 7 Tahap 6: Form HTTP POST

class CourseFormPage extends StatefulWidget {
  final CourseProvider provider;

  const CourseFormPage({
    super.key,
    required this.provider,
  });

  @override
  State<CourseFormPage> createState() =>
      _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _titleController = TextEditingController();
  final _creditsController = TextEditingController();

  String _status = 'planned';

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final course = Course(
      code: _codeController.text.trim(),
      title: _titleController.text.trim(),
      credits: int.parse(_creditsController.text.trim()),
      status: _status,
    );

    try {
      await widget.provider.createCourse(course);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course berhasil dikirim.'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan course: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, child) {
        final isSaving = widget.provider.isSaving;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tambah Course'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Kode Mata Kuliah',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Kode wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Mata Kuliah',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama mata kuliah wajib diisi';
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
                      if (value == null || value.trim().isEmpty) {
                        return 'Jumlah SKS wajib diisi';
                      }

                      if (int.tryParse(value.trim()) == null) {
                        return 'Jumlah SKS harus berupa angka';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'planned',
                        child: Text('Planned'),
                      ),
                      DropdownMenuItem(
                        value: 'active',
                        child: Text('Active'),
                      ),
                      DropdownMenuItem(
                        value: 'done',
                        child: Text('Done'),
                      ),
                    ],
                    onChanged: isSaving
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
                  ElevatedButton(
                    onPressed: isSaving ? null : _saveCourse,
                    child: isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Simpan'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

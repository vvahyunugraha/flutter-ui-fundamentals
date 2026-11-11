
import 'package:flutter/material.dart';

// Nama: I Gusti Made Wahyu Nugraha
// NIM: 2455011005
// WO Pertemuan 9 - Praktik 4

class RoleGuard extends StatelessWidget {
  const RoleGuard({
    super.key,
    required this.role,
    required this.allowed,
    required this.child,
  });

  final String role;
  final List<String> allowed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Membersihkan role agar konsisten.
    final normalizedRole = role.trim().toLowerCase();

    // Membersihkan daftar role yang diizinkan.
    final normalizedAllowed = allowed
        .map((item) => item.trim().toLowerCase())
        .toList();

    // Jika role kosong atau tidak diizinkan,
    // widget tidak akan ditampilkan.
    if (normalizedRole.isEmpty ||
        !normalizedAllowed.contains(normalizedRole)) {
      return const SizedBox.shrink();
    }

    return child;
  }
}


import 'package:flutter/material.dart';

// Nama: I Gusti Made Wahyu Nugraha
// NIM: 2455011005
// Tahap 5: ChangeNotifier dan notifyListeners()

class CourseState extends ChangeNotifier {
  // Menyimpan kode mata kuliah yang menjadi favorit.
  final Set<String> favorites = <String>{};

  // Mengubah status favorite mata kuliah.
  void toggleFavorite(String id) {
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }

    // Memberi tahu listener bahwa state telah berubah.
    notifyListeners();
  }
}

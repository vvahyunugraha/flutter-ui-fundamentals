import 'package:flutter/material.dart';

// Nama: I Gusti Made Wahyu Nugraha
// NIM: 2455011005
// Tahap 5: ChangeNotifier dan notifyListeners()

class CourseState extends ChangeNotifier {
  final Set<String> favorites = <String>{};

  void toggleFavorite(String code) {
    if (favorites.contains(code)) {
      favorites.remove(code);
    } else {
      favorites.add(code);
    }

    notifyListeners();
  }

  void addFavorite(String code) {
    if (favorites.add(code)) {
      notifyListeners();
    }
  }

  bool isFavorite(String code) {
    return favorites.contains(code);
  }
}

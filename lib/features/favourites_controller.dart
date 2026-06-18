// ═══════════════════════════════════════════════════════════════════
//  favourites_controller.dart
//  Singleton — manages saved/favourite experts across the app
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class SavedExpert {
  final String name;
  final String title;
  final String imageUrl;
  final String location;
  final String level;
  final String specialization;
  final double rating;
  final double pricePerHour;
  final int reviews;
  final List<String> skills;
  final bool isPaid;

  const SavedExpert({
    required this.name,
    required this.title,
    required this.imageUrl,
    required this.location,
    required this.level,
    required this.specialization,
    required this.rating,
    required this.pricePerHour,
    required this.reviews,
    required this.skills,
    required this.isPaid,
  });
}

class FavouritesController extends ChangeNotifier {
  static final FavouritesController instance = FavouritesController._();
  FavouritesController._();

  final List<SavedExpert> _experts = [];

  List<SavedExpert> get all => List.unmodifiable(_experts);
  int get count => _experts.length;

  bool isFavourite(String name) => _experts.any((e) => e.name == name);

  void toggle(SavedExpert expert) {
    if (isFavourite(expert.name)) {
      _experts.removeWhere((e) => e.name == expert.name);
    } else {
      _experts.add(expert);
    }
    notifyListeners();
  }

  void remove(String name) {
    _experts.removeWhere((e) => e.name == name);
    notifyListeners();
  }

  void clearAll() {
    _experts.clear();
    notifyListeners();
  }
}
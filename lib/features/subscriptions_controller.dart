// ═══════════════════════════════════════════════════════════════════
//  subscriptions_controller.dart
//  Singleton — manages user's purchased courses, packages, and boost plans
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

enum SubType { course, package, boost }

class Subscription {
  final String id;
  final SubType type;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? instructor;
  final double price;
  final DateTime purchaseDate;
  final DateTime? expiryDate;        // for boost plans
  final int? totalSessions;          // for packages
  final int? usedSessions;           // for packages
  final double? progress;            // for courses (0.0 - 1.0)
  final List<String>? features;      // for boost plans
  final String? category;

  Subscription({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.purchaseDate,
    this.imageUrl,
    this.instructor,
    this.expiryDate,
    this.totalSessions,
    this.usedSessions,
    this.progress,
    this.features,
    this.category,
  });
}

class SubscriptionsController extends ChangeNotifier {
  static final SubscriptionsController instance = SubscriptionsController._();
  SubscriptionsController._();

  // Demo data so the page isn't empty on first load
  final List<Subscription> _items = [
    Subscription(
      id: 'demo-1',
      type: SubType.course,
      title: 'Flutter from Zero to Pro',
      subtitle: 'Mobile Development',
      instructor: 'Marwan Hussien',
      imageUrl: 'https://i.postimg.cc/z3ZzXWGc/Marwan.webp',
      price: 899,
      purchaseDate: DateTime.now().subtract(const Duration(days: 12)),
      progress: 0.45,
      category: 'Mobile Development',
    ),
    Subscription(
      id: 'demo-2',
      type: SubType.package,
      title: 'Growth Pack',
      subtitle: '10 sessions • 15 hours • 20% off',
      price: 1680,
      purchaseDate: DateTime.now().subtract(const Duration(days: 5)),
      totalSessions: 10,
      usedSessions: 3,
    ),
  ];

  // ── Getters ──
  List<Subscription> get all => List.unmodifiable(_items.reversed);

  List<Subscription> get courses =>
      _items.where((s) => s.type == SubType.course).toList().reversed.toList();

  List<Subscription> get packages =>
      _items.where((s) => s.type == SubType.package).toList().reversed.toList();

  List<Subscription> get boostPlans =>
      _items.where((s) => s.type == SubType.boost).toList().reversed.toList();

  int get totalCount => _items.length;
  int get coursesCount => courses.length;
  int get packagesCount => packages.length;
  int get boostCount => boostPlans.length;

  double get totalSpent => _items.fold(0.0, (sum, s) => sum + s.price);

  // ── Actions ──

  void addCourse({
    required String title,
    required String instructor,
    required String imageUrl,
    required String category,
    required double price,
  }) {
    _items.add(Subscription(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: SubType.course,
      title: title,
      subtitle: category,
      instructor: instructor,
      imageUrl: imageUrl,
      price: price,
      purchaseDate: DateTime.now(),
      progress: 0.0,
      category: category,
    ));
    notifyListeners();
  }

  void addPackage({
    required String name,
    required int sessions,
    required int hours,
    required double discount,
    required double totalPrice,
  }) {
    _items.add(Subscription(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: SubType.package,
      title: name,
      subtitle: '$sessions sessions • $hours hours • ${discount.toStringAsFixed(0)}% off',
      price: totalPrice,
      purchaseDate: DateTime.now(),
      totalSessions: sessions,
      usedSessions: 0,
    ));
    notifyListeners();
  }

  void addBoostPlan({
    required String name,
    required String description,
    required double price,
    required List<String> features,
  }) {
    _items.add(Subscription(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: SubType.boost,
      title: name,
      subtitle: description,
      price: price,
      purchaseDate: DateTime.now(),
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      features: features,
    ));
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  /// Use one session from a package (when booking)
  /// Returns true if successful, false if no remaining sessions
  bool useSessionFromPackage(String packageId) {
    final idx = _items.indexWhere((s) => s.id == packageId && s.type == SubType.package);
    if (idx == -1) return false;
    final pkg = _items[idx];
    final used = pkg.usedSessions ?? 0;
    final total = pkg.totalSessions ?? 0;
    if (used >= total) return false; // no remaining

    _items[idx] = Subscription(
      id: pkg.id, type: pkg.type, title: pkg.title, subtitle: pkg.subtitle,
      price: pkg.price, purchaseDate: pkg.purchaseDate,
      totalSessions: total, usedSessions: used + 1,
      expiryDate: pkg.expiryDate, progress: pkg.progress,
      features: pkg.features, category: pkg.category,
      imageUrl: pkg.imageUrl, instructor: pkg.instructor,
    );
    notifyListeners();
    return true;
  }

  /// Return a session to package (when session is rejected/cancelled)
  void returnSessionToPackage(String packageId) {
    final idx = _items.indexWhere((s) => s.id == packageId && s.type == SubType.package);
    if (idx == -1) return;
    final pkg = _items[idx];
    final used = pkg.usedSessions ?? 0;
    if (used <= 0) return;

    _items[idx] = Subscription(
      id: pkg.id, type: pkg.type, title: pkg.title, subtitle: pkg.subtitle,
      price: pkg.price, purchaseDate: pkg.purchaseDate,
      totalSessions: pkg.totalSessions, usedSessions: used - 1,
      expiryDate: pkg.expiryDate, progress: pkg.progress,
      features: pkg.features, category: pkg.category,
      imageUrl: pkg.imageUrl, instructor: pkg.instructor,
    );
    notifyListeners();
  }

  /// Get available packages (with remaining sessions)
  List<Subscription> get availablePackages => _items.where((s) =>
    s.type == SubType.package &&
    (s.usedSessions ?? 0) < (s.totalSessions ?? 0)
  ).toList();

  String timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7)  return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7} weeks ago';
    return '${diff.inDays ~/ 30} months ago';
  }
}
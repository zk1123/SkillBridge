import 'package:flutter/foundation.dart';

/// Manages reviews for users across the app.
/// Each user (mentor/student) has a list of reviews.
class ReviewsController extends ChangeNotifier {
  static final ReviewsController instance = ReviewsController._();
  ReviewsController._();

  // Map: userId → List<Review>
  final Map<String, List<Review>> _reviewsByUser = {
    // Seed initial reviews for Mohamed Nukbassy
    'mohamed_nukbassy': [
      Review(
        id: 'r_seed_1',
        userId: 'mohamed_nukbassy',
        reviewerName: 'Nada Sherif',
        reviewerImage: 'https://randomuser.me/api/portraits/women/29.jpg',
        rating: 5.0,
        comment: 'Absolutely the best Flutter mentor I\'ve had. Patient, clear, and very knowledgeable.',
        createdAt: DateTime(2025, 4, 18),
      ),
      Review(
        id: 'r_seed_2',
        userId: 'mohamed_nukbassy',
        reviewerName: 'Omar Fathy',
        reviewerImage: 'https://randomuser.me/api/portraits/men/55.jpg',
        rating: 5.0,
        comment: 'Perfect session every time. Always on time and super insightful.',
        createdAt: DateTime(2025, 4, 1),
      ),
    ],
    // Seed initial reviews for Marwan Hussien
    'marwan_hussien': [
      Review(
        id: 'r_seed_3',
        userId: 'marwan_hussien',
        reviewerName: 'Sara Mostafa',
        reviewerImage: 'https://randomuser.me/api/portraits/women/45.jpg',
        rating: 5.0,
        comment: 'Very professional. Helped me understand Flutter architecture deeply.',
        createdAt: DateTime(2025, 3, 15),
      ),
    ],
  };

  /// Get all reviews for a specific user
  List<Review> getReviewsFor(String userId) {
    final list = _reviewsByUser[userId] ?? [];
    return List.from(list)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get count of reviews for a user
  int countFor(String userId) => _reviewsByUser[userId]?.length ?? 0;

  /// Get average rating for a user
  double averageRatingFor(String userId) {
    final reviews = _reviewsByUser[userId] ?? [];
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold<double>(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }

  /// Add a new review for a user
  void addReview({
    required String userId,
    required String reviewerName,
    required String reviewerImage,
    required double rating,
    required String comment,
  }) {
    final review = Review(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      reviewerName: reviewerName,
      reviewerImage: reviewerImage,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    _reviewsByUser.putIfAbsent(userId, () => []).add(review);
    notifyListeners();
  }

  /// Delete a review
  void deleteReview(String userId, String reviewId) {
    _reviewsByUser[userId]?.removeWhere((r) => r.id == reviewId);
    notifyListeners();
  }
}

class Review {
  final String id;
  final String userId;        // ID of the user being reviewed
  final String reviewerName;
  final String reviewerImage;
  final double rating;        // 1.0 to 5.0
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.reviewerName,
    required this.reviewerImage,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  String get formattedDate {
    const months = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[createdAt.month]} ${createdAt.day}, ${createdAt.year}';
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 30) return formattedDate;
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
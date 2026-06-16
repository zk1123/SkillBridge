import 'package:flutter/material.dart';
import 'notifications_controller.dart';
import 'bottomnavbar.dart'; // SkillBridgeLogo + appScaffoldKey
import 'favourites_controller.dart';
import 'payment_helper.dart';
import 'booking_helper.dart';

// ═══════════════════════════════════════════════════════════════════
//  COLORS & STYLES
// ═══════════════════════════════════════════════════════════════════

class AppColors {
  static const primary = Color(0xFF2563EB);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFEEF2FF);
  static const card = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF0F172A);
  static const textMid = Color(0xFF475569);
  static const textLight = Color(0xFF94A3B8);
  static const divider = Color(0xFFE2E8F0);
  static const success = Color(0xFF10B981);
  static const successBg = Color(0xFFD1FAE5);
  static const tag = Color(0xFFEFF6FF);
  static const tagText = Color(0xFF3B82F6);
  static const warning = Color(0xFFF59E0B);
  static const warningBg = Color(0xFFFEF3C7);
  static const danger = Color(0xFFEF4444);
  static const dangerBg = Color(0xFFFEE2E2);
  static const gold = Color(0xFFFFD700);
  static const goldDark = Color(0xFFB8860B);
  static const green = Color(0xFF059669);
  static const purple = Color(0xFF7C3AED);
  static const purpleDark = Color(0xFF5B21B6);

  static const LinearGradient grad = LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gold for top-rated (4.9+)
  static const LinearGradient goldGrad = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Purple for Elite Boost subscribers
  static const LinearGradient eliteGrad = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Blue for Pro Boost subscribers
  static const LinearGradient proGrad = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Mixed: Top-rated + Elite (gold + purple)
  static const LinearGradient goldEliteGrad = LinearGradient(
    colors: [
      Color(0xFFFFD700),
      Color(0xFFFFB300),
      Color(0xFF7C3AED),
      Color(0xFF5B21B6),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 0.5, 1.0],
  );

  // Mixed: Top-rated + Pro (gold + blue)
  static const LinearGradient goldProGrad = LinearGradient(
    colors: [
      Color(0xFFFFD700),
      Color(0xFFFFB300),
      Color(0xFF2563EB),
      Color(0xFF1E40AF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 0.5, 1.0],
  );
}

class AppTextStyles {
  static const titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.2,
  );
  static const titleMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMid,
    height: 1.6,
  );
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    letterSpacing: 0.2,
  );
  static const label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textMid,
  );
}

// ═══════════════════════════════════════════════════════════════════
//  ENUMS
// ═══════════════════════════════════════════════════════════════════

enum BoostTier { none, basic, pro, elite }

// ═══════════════════════════════════════════════════════════════════
//  MODELS
// ═══════════════════════════════════════════════════════════════════

class ReviewData {
  final String reviewer, comment, date, reviewerImage;
  final double rating;
  const ReviewData({
    required this.reviewer,
    required this.comment,
    required this.date,
    required this.rating,
    required this.reviewerImage,
  });
}

class ExpertData {
  final String name, title, imageUrl, location, level, specialization, bio;
  final double rating;
  final double pricePerHourEGP;
  final int reviews, experienceYears, completedSessions;
  final List<String> skills;
  final bool available, isPaid;
  final BoostTier boost;
  final List<ReviewData> reviewList;

  const ExpertData({
    required this.name,
    required this.title,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.location,
    required this.skills,
    required this.available,
    required this.reviewList,
    required this.level,
    required this.specialization,
    required this.experienceYears,
    required this.isPaid,
    required this.pricePerHourEGP,
    required this.completedSessions,
    required this.bio,
    this.boost = BoostTier.none,
  });

  bool get isTopRated => rating >= 4.9;
  bool get isAffordable => isPaid && pricePerHourEGP <= 200 && rating <= 4.3;
  bool get isFree => !isPaid;
}

// ═══════════════════════════════════════════════════════════════════
//  DATA
// ═══════════════════════════════════════════════════════════════════

const _allUsers = [
  // Top-rated GOLD (4.9) — no boost (Mohamed first now)
  ExpertData(
    name: 'Mohamed Nukbassy',
    title: 'Senior Data Analyst',
    imageUrl: 'https://i.postimg.cc/9f0r3cSF/Mo-nakbas.jpg',
    rating: 5.0,
    reviews: 218,
    location: 'Cairo, Egypt',
    skills: ['Python', 'SQL', 'Tableau', 'ML'],
    available: true,
    level: 'Senior',
    specialization: 'Data Analysis',
    experienceYears: 3,
    isPaid: true,
    pricePerHourEGP: 475,
    completedSessions: 187,
    bio:
        'Expert in Python & Tableau with experience helping 200+ students land data roles at top companies.',
    boost: BoostTier.none,
    reviewList: [
      ReviewData(
        reviewer: 'Ahmed Ali',
        reviewerImage: 'https://randomuser.me/api/portraits/men/11.jpg',
        comment:
            'Amazing session! Explained pandas so clearly. Definitely the best data analyst I\'ve worked with.',
        date: 'Apr 15, 2025',
        rating: 5.0,
      ),
      ReviewData(
        reviewer: 'Sara Mostafa',
        reviewerImage: 'https://randomuser.me/api/portraits/women/45.jpg',
        comment:
            'Very professional and patient. Highly recommended for anyone starting in data analysis.',
        date: 'Mar 28, 2025',
        rating: 5.0,
      ),
    ],
  ),

  // Top-rated GOLD (5.0) — no boost (Marwan second)
  ExpertData(
    name: 'Marwan Hussien',
    title: 'Senior Mobile Developer',
    imageUrl: 'https://i.postimg.cc/z3ZzXWGc/Marwan.webp',
    rating: 5.0,
    reviews: 450,
    location: 'Cairo, Egypt',
    skills: ['Flutter', 'Dart', 'Firebase', 'iOS'],
    available: true,
    level: 'Senior',
    specialization: 'Mobile Development',
    experienceYears: 8,
    isPaid: true,
    pricePerHourEGP: 600,
    completedSessions: 320,
    bio:
        'Lead Flutter engineer with 8+ years building production apps. Passionate about clean architecture and performance optimization.',
    boost: BoostTier.none,
    reviewList: [
      ReviewData(
        reviewer: 'Nada Sherif',
        reviewerImage: 'https://randomuser.me/api/portraits/women/29.jpg',
        comment:
            'Absolutely the best Flutter mentor I\'ve had. Marwan explains complex topics with great patience.',
        date: 'Apr 18, 2025',
        rating: 5.0,
      ),
      ReviewData(
        reviewer: 'Omar Fathy',
        reviewerImage: 'https://randomuser.me/api/portraits/men/55.jpg',
        comment:
            'Perfect session every time. Always on time and super knowledgeable about the latest Flutter features.',
        date: 'Apr 1, 2025',
        rating: 5.0,
      ),
    ],
  ),

  // Pure Elite (no top-rated)
  ExpertData(
    name: 'Layla Hassan',
    title: 'AI & ML Engineer',
    imageUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
    rating: 4.7,
    reviews: 176,
    location: 'Cairo, Egypt',
    skills: ['Python', 'PyTorch', 'NLP', 'CV'],
    available: true,
    level: 'Mid',
    specialization: 'Machine Learning',
    experienceYears: 4,
    isPaid: true,
    pricePerHourEGP: 550,
    completedSessions: 145,
    bio:
        'Researcher turned mentor. Specialises in NLP and computer vision with PyTorch. Loves teaching ML from first principles.',
    boost: BoostTier.elite,
    reviewList: [
      ReviewData(
        reviewer: 'Omar Nasser',
        reviewerImage: 'https://randomuser.me/api/portraits/men/22.jpg',
        comment:
            'Best ML sessions I\'ve ever had. Super clear explanations and great practical examples.',
        date: 'Apr 20, 2025',
        rating: 5.0,
      ),
    ],
  ),

  // Gold + Pro (mixed)
  ExpertData(
    name: 'Nadia Petrov',
    title: 'iOS Developer',
    imageUrl: 'https://randomuser.me/api/portraits/women/17.jpg',
    rating: 4.9,
    reviews: 159,
    location: 'Moscow, Russia',
    skills: ['Swift', 'SwiftUI', 'UIKit', 'Xcode'],
    available: true,
    level: 'Senior',
    specialization: 'Mobile Development',
    experienceYears: 7,
    isPaid: true,
    pricePerHourEGP: 500,
    completedSessions: 210,
    bio:
        'SwiftUI & UIKit veteran with 12 published apps on the App Store. Passionate about iOS architecture patterns.',
    boost: BoostTier.pro,
    reviewList: [
      ReviewData(
        reviewer: 'Ali Hassan',
        reviewerImage: 'https://randomuser.me/api/portraits/men/41.jpg',
        comment:
            'Nadia is incredibly patient and knowledgeable. Best iOS mentor I\'ve had.',
        date: 'Apr 12, 2025',
        rating: 5.0,
      ),
    ],
  ),

  // Pure Pro
  ExpertData(
    name: 'Sara Khalil',
    title: 'UI/UX Designer',
    imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    rating: 4.5,
    reviews: 134,
    location: 'Alexandria, Egypt',
    skills: ['Figma', 'Sketch', 'Prototyping', 'Design Systems'],
    available: false,
    level: 'Mid',
    specialization: 'UI/UX Design',
    experienceYears: 5,
    isPaid: false,
    pricePerHourEGP: 0,
    completedSessions: 98,
    bio:
        'Design systems enthusiast. Ex-Figma Community contributor. Makes every pixel count.',
    boost: BoostTier.pro,
    reviewList: [
      ReviewData(
        reviewer: 'Youssef Maher',
        reviewerImage: 'https://randomuser.me/api/portraits/men/15.jpg',
        comment:
            'Sara helped me create a beautiful design system. Great mentor for designers.',
        date: 'Apr 10, 2025',
        rating: 5.0,
      ),
    ],
  ),

  // Affordable (low rating, low price)
  ExpertData(
    name: 'Ahmed Tarek',
    title: 'Backend Engineer',
    imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    rating: 4.2,
    reviews: 92,
    location: 'Giza, Egypt',
    skills: ['Node.js', 'PostgreSQL', 'Docker', 'AWS'],
    available: true,
    level: 'Junior',
    specialization: 'Backend Development',
    experienceYears: 2,
    isPaid: true,
    pricePerHourEGP: 150,
    completedSessions: 45,
    bio:
        'Node.js & PostgreSQL specialist. Loves teaching REST APIs and containerisation to beginners.',
    boost: BoostTier.none,
    reviewList: [
      ReviewData(
        reviewer: 'Hassan Ramzy',
        reviewerImage: 'https://randomuser.me/api/portraits/men/63.jpg',
        comment: 'Great session on REST APIs. Very affordable and helpful.',
        date: 'Apr 5, 2025',
        rating: 4.0,
      ),
    ],
  ),

  // Free / Affordable
  ExpertData(
    name: 'Omar Fathy',
    title: 'Junior Developer',
    imageUrl: 'https://i.pravatar.cc/300?img=14',
    rating: 4.0,
    reviews: 45,
    location: 'Cairo, Egypt',
    skills: ['HTML', 'CSS', 'JavaScript'],
    available: true,
    level: 'Junior',
    specialization: 'Web Development',
    experienceYears: 1,
    isPaid: false,
    pricePerHourEGP: 0,
    completedSessions: 22,
    bio:
        'Passionate junior developer offering free pair-programming sessions to help others learn.',
    boost: BoostTier.none,
    reviewList: [
      ReviewData(
        reviewer: 'Mona Adel',
        reviewerImage: 'https://randomuser.me/api/portraits/women/38.jpg',
        comment: 'Free sessions and very dedicated. Thank you Omar!',
        date: 'Mar 25, 2025',
        rating: 4.5,
      ),
    ],
  ),

  // Top-rated (gold)
  ExpertData(
    name: 'Khaled Mansour',
    title: 'Cybersecurity Expert',
    imageUrl: 'https://randomuser.me/api/portraits/men/33.jpg',
    rating: 4.9,
    reviews: 167,
    location: 'Cairo, Egypt',
    skills: ['Pentesting', 'OWASP', 'Network Security'],
    available: true,
    level: 'Senior',
    specialization: 'Cybersecurity',
    experienceYears: 6,
    isPaid: true,
    pricePerHourEGP: 650,
    completedSessions: 178,
    bio:
        'Certified ethical hacker with 6 years of experience. Specializes in penetration testing and network security.',
    boost: BoostTier.none,
    reviewList: [
      ReviewData(
        reviewer: 'Mostafa K.',
        reviewerImage: 'https://randomuser.me/api/portraits/men/41.jpg',
        comment: 'Top-tier security expert. His insights are invaluable.',
        date: 'Apr 22, 2025',
        rating: 5.0,
      ),
    ],
  ),
];

// Sort: Mohamed and Marwan are pinned at top first,
// then gold + boost combos, then gold, then elite, then pro, then by rating
List<ExpertData> _sortedUsers(List<ExpertData> users) {
  // Pinned names always come first in this exact order
  const pinnedNames = ['Mohamed Nukbassy', 'Marwan Hussien'];

  int score(ExpertData u) {
    // Force pinned users to the very top
    final pinIndex = pinnedNames.indexOf(u.name);
    if (pinIndex == 0) return 10000; // Mohamed
    if (pinIndex == 1) return 9999; // Marwan

    int s = 0;
    if (u.isTopRated && u.boost == BoostTier.elite)
      s += 1000;
    else if (u.isTopRated && u.boost == BoostTier.pro)
      s += 900;
    else if (u.isTopRated)
      s += 800;
    else if (u.boost == BoostTier.elite)
      s += 700;
    else if (u.boost == BoostTier.pro)
      s += 600;
    s += (u.rating * 10).toInt();
    return s;
  }

  final indexed = users.asMap().entries.toList();
  indexed.sort((a, b) {
    final scoreDiff = score(b.value).compareTo(score(a.value));
    if (scoreDiff != 0) return scoreDiff;
    return a.key.compareTo(b.key); // stable order by original index
  });
  return indexed.map((e) => e.value).toList();
}

// ═══════════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════

Widget _netImg(String url, double size, {double radius = 14}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        color: AppColors.tag,
        child: const Icon(Icons.person, color: AppColors.primary),
      ),
    ),
  );
}

class _SkillTag extends StatelessWidget {
  final String label;
  const _SkillTag({required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.tag,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.primary.withOpacity(0.15)),
    ),
    child: Text(
      label,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.tagText,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _MiniStat extends StatelessWidget {
  final String value, label;
  final Color? valueColor;
  const _MiniStat({required this.value, required this.label, this.valueColor});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: valueColor ?? AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════
//  NOTIFICATION BELL (kept from original)
// ═══════════════════════════════════════════════════════════════════

class _NotifBell extends StatefulWidget {
  const _NotifBell();
  @override
  State<_NotifBell> createState() => _NotifBellState();
}

class _NotifBellState extends State<_NotifBell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake;
  late final Animation<double> _shakeAnim;
  final _ctrl = NotificationsController.instance;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween(
      begin: -0.05,
      end: 0.05,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shake);
    _ctrl.addListener(_onNotif);
  }

  void _onNotif() {
    if (mounted) {
      setState(() {});
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onNotif);
    _shake.dispose();
    super.dispose();
  }

  void _openNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotificationsSheet(),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final unread = _ctrl.unreadCount;
    return GestureDetector(
      onTap: _openNotifications,
      child: AnimatedBuilder(
        animation: _shakeAnim,
        builder: (_, child) =>
            Transform.rotate(angle: _shakeAnim.value, child: child),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: unread > 0
                    ? AppColors.grad
                    : LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.green.withOpacity(0.1),
                        ],
                      ),
                borderRadius: BorderRadius.circular(13),
                border: unread > 0
                    ? null
                    : Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Icon(
                unread > 0
                    ? Icons.notifications_rounded
                    : Icons.notifications_outlined,
                size: 20,
                color: unread > 0 ? Colors.white : AppColors.primary,
              ),
            ),
            if (unread > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  FEED PAGE
// ═══════════════════════════════════════════════════════════════════

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  String _searchQuery = '';
  List<ExpertData> _filteredUsers = _sortedUsers(_allUsers);
  String? _selectedSpecialization;
  double _minRating = 4.0;
  String? _selectedPricing;
  int _minExperience = 1;
  int _maxExperience = 10;
  String? _selectedLevel;

  void _applyFilters() {
    setState(() {
      final filtered = _allUsers.where((u) {
        final matchSearch =
            _searchQuery.isEmpty ||
            u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            u.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            u.skills.any(
              (s) => s.toLowerCase().contains(_searchQuery.toLowerCase()),
            );
        final matchSpec =
            _selectedSpecialization == null ||
            u.specialization == _selectedSpecialization;
        final matchRating = u.rating >= _minRating;
        final matchPricing =
            _selectedPricing == null ||
            (_selectedPricing == 'Paid' && u.isPaid) ||
            (_selectedPricing == 'Free' && !u.isPaid);
        final matchExp =
            u.experienceYears >= _minExperience &&
            u.experienceYears <= _maxExperience;
        final matchLevel = _selectedLevel == null || u.level == _selectedLevel;
        return matchSearch &&
            matchSpec &&
            matchRating &&
            matchPricing &&
            matchExp &&
            matchLevel;
      }).toList();
      _filteredUsers = _sortedUsers(filtered);
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedSpecialization = null;
      _minRating = 4.0;
      _selectedPricing = null;
      _minExperience = 1;
      _maxExperience = 10;
      _selectedLevel = null;
      _filteredUsers = _sortedUsers(_allUsers);
    });
  }

  void _openSearch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.grad,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Search Experts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search by name, skill...',
            hintStyle: const TextStyle(color: AppColors.textLight),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.primary,
            ),
          ),
          onChanged: (v) {
            _searchQuery = v;
            _applyFilters();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchQuery = '';
              _applyFilters();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setS) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.grad,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Filter Experts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setS(() {});
                        _resetFilters();
                      },
                      child: const Text(
                        'Reset All',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _FilterSection(
                      icon: Icons.workspace_premium_rounded,
                      title: 'Experience Level',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            [
                              'Junior',
                              'Mid',
                              'Senior',
                              'Lead',
                              'Principal',
                            ].map((l) {
                              final sel = _selectedLevel == l;
                              return _FilterChip(
                                label: l,
                                selected: sel,
                                onTap: () => setS(() {
                                  _selectedLevel = sel ? null : l;
                                  _applyFilters();
                                }),
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FilterSection(
                      icon: Icons.code_rounded,
                      title: 'Specialization',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            [
                              'Data Analysis',
                              'Mobile Development',
                              'Web Development',
                              'Backend Development',
                              'Frontend Development',
                              'UI/UX Design',
                              'DevOps',
                              'Machine Learning',
                              'Cybersecurity',
                              'Cloud Computing',
                              'Game Development',
                              'Embedded Systems',
                              'Blockchain',
                            ].map((spec) {
                              final sel = _selectedSpecialization == spec;
                              return _FilterChip(
                                label: spec,
                                selected: sel,
                                onTap: () => setS(() {
                                  _selectedSpecialization = sel ? null : spec;
                                  _applyFilters();
                                }),
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FilterSection(
                      icon: Icons.star_rounded,
                      title: 'Minimum Rating',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.gold,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _minRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                              const Text(
                                ' and above',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMid,
                                ),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: AppColors.primary,
                              thumbColor: AppColors.primary,
                              overlayColor: AppColors.primary.withOpacity(0.1),
                              inactiveTrackColor: AppColors.divider,
                            ),
                            child: Slider(
                              value: _minRating,
                              min: 4.0,
                              max: 5.0,
                              divisions: 10,
                              onChanged: (v) => setS(() {
                                _minRating = v;
                                _applyFilters();
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FilterSection(
                      icon: Icons.attach_money_rounded,
                      title: 'Session Type',
                      child: Row(
                        children: [
                          Expanded(
                            child: _FilterChip(
                              label: '💰 Paid',
                              selected: _selectedPricing == 'Paid',
                              onTap: () => setS(() {
                                _selectedPricing = _selectedPricing == 'Paid'
                                    ? null
                                    : 'Paid';
                                _applyFilters();
                              }),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _FilterChip(
                              label: '🆓 Free',
                              selected: _selectedPricing == 'Free',
                              onTap: () => setS(() {
                                _selectedPricing = _selectedPricing == 'Free'
                                    ? null
                                    : 'Free';
                                _applyFilters();
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FilterSection(
                      icon: Icons.timeline_rounded,
                      title: 'Years of Experience',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.timeline_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$_minExperience - $_maxExperience years',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          RangeSlider(
                            values: RangeValues(
                              _minExperience.toDouble(),
                              _maxExperience.toDouble(),
                            ),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            activeColor: AppColors.primary,
                            inactiveColor: AppColors.divider,
                            onChanged: (v) => setS(() {
                              _minExperience = v.start.round();
                              _maxExperience = v.end.round();
                              _applyFilters();
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      gradient: AppColors.grad,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'Show ${_filteredUsers.length} Results',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFDBEAFE), Color(0xFFD1FAE5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── AppBar ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                border: Border(
                  bottom: BorderSide(color: AppColors.divider.withOpacity(0.5)),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.green.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.menu_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const SkillBridgeLogo(fontSize: 22),
                  const Spacer(),
                  GestureDetector(
                    onTap: _openSearch,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.green.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const _NotifBell(),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _openFilter,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: AppColors.grad,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Tier Legend ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _legendChip('🥇 Top Rated', AppColors.gold),
                  const SizedBox(width: 6),
                  _legendChip('💎 Elite', AppColors.purple),
                  const SizedBox(width: 6),
                  _legendChip('🔵 Pro', AppColors.primary),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('Top Experts Near You', style: AppTextStyles.titleLarge),
                  const Spacer(),
                  Text(
                    '${_filteredUsers.length} results',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: _filteredUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.1),
                                  AppColors.green.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.search_off_rounded,
                              size: 36,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No experts found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try changing your filters',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _resetFilters,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Reset Filters'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: _filteredUsers.length,
                      itemBuilder: (_, i) =>
                          _ExpertCard(user: _filteredUsers[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  FILTER WIDGETS
// ═══════════════════════════════════════════════════════════════════

class _FilterSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _FilterSection({
    required this.icon,
    required this.title,
    required this.child,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.grad,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      child,
    ],
  );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: selected ? AppColors.grad : null,
        color: selected ? null : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? Colors.transparent : AppColors.divider,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? Colors.white : AppColors.textMid,
        ),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════
//  EXPERT CARD — with tier system & smart badges
// ═══════════════════════════════════════════════════════════════════

class _ExpertCard extends StatefulWidget {
  final ExpertData user;
  const _ExpertCard({required this.user});
  @override
  State<_ExpertCard> createState() => _ExpertCardState();
}

class _ExpertCardState extends State<_ExpertCard> {
  // Returns the appropriate gradient for the card based on tier
  LinearGradient? get _tierGradient {
    final u = widget.user;
    if (u.isTopRated && u.boost == BoostTier.elite)
      return AppColors.goldEliteGrad;
    if (u.isTopRated && u.boost == BoostTier.pro) return AppColors.goldProGrad;
    if (u.isTopRated) return AppColors.goldGrad;
    if (u.boost == BoostTier.elite) return AppColors.eliteGrad;
    if (u.boost == BoostTier.pro) return AppColors.proGrad;
    return null;
  }

  Color get _borderColor {
    final u = widget.user;
    if (u.isTopRated && u.boost == BoostTier.elite) return AppColors.purpleDark;
    if (u.isTopRated && u.boost == BoostTier.pro) return AppColors.primary;
    if (u.isTopRated) return AppColors.gold;
    if (u.boost == BoostTier.elite) return AppColors.purple;
    if (u.boost == BoostTier.pro) return AppColors.primary;
    return AppColors.divider.withOpacity(0.6);
  }

  String? get _tierBanner {
    final u = widget.user;
    if (u.isTopRated && u.boost == BoostTier.elite)
      return '⭐ Top Rated • 💎 Elite Expert';
    if (u.isTopRated && u.boost == BoostTier.pro)
      return '⭐ Top Rated • 🔵 Pro Expert';
    if (u.isTopRated) return '⭐ Top Rated Expert';
    if (u.boost == BoostTier.elite) return '💎 Elite Expert';
    if (u.boost == BoostTier.pro) return '🔵 Pro Expert';
    return null;
  }

  // Affordability badge
  Widget? _priceBadge() {
    final u = widget.user;
    if (u.isFree) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: const Text(
          '🆓 Free Sessions',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.success,
          ),
        ),
      );
    }
    if (u.isAffordable) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.green.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.green.withOpacity(0.3)),
        ),
        child: const Text(
          '💸 Budget-Friendly',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.green,
          ),
        ),
      );
    }
    return null;
  }

  void _toggleFavourite() {
    final user = widget.user;
    final wasInFav = FavouritesController.instance.isFavourite(user.name);
    FavouritesController.instance.toggle(
      SavedExpert(
        name: user.name,
        title: user.title,
        imageUrl: user.imageUrl,
        location: user.location,
        level: user.level,
        specialization: user.specialization,
        rating: user.rating,
        pricePerHour: user.pricePerHourEGP,
        reviews: user.reviews,
        skills: user.skills,
        isPaid: user.isPaid,
      ),
    );
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !wasInFav
              ? '❤️ ${user.name} added to favourites!'
              : '💔 ${user.name} removed from favourites.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final isFav = FavouritesController.instance.isFavourite(user.name);
    final hasTier = _tierGradient != null;
    final priceBadge = _priceBadge();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderColor, width: hasTier ? 1.5 : 1),
        boxShadow: hasTier
            ? [
                BoxShadow(
                  color: _borderColor.withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          // Tier banner
          if (_tierBanner != null && _tierGradient != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: _tierGradient,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _tierBanner!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _AvatarWidget(user: user),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user.name,
                                  style: AppTextStyles.titleMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user.title,
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.grad,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user.level,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: AppColors.textLight,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  user.location,
                                  style: AppTextStyles.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _toggleFavourite,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isFav
                              ? Colors.red.withOpacity(0.1)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isFav
                                ? Colors.red.withOpacity(0.3)
                                : AppColors.divider,
                          ),
                        ),
                        child: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: isFav ? Colors.red : AppColors.textLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExpertProfilePage(user: user),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: user.isTopRated
                              ? AppColors.gold.withOpacity(0.15)
                              : AppColors.warningBg,
                          borderRadius: BorderRadius.circular(12),
                          border: user.isTopRated
                              ? Border.all(
                                  color: AppColors.gold.withOpacity(0.5),
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: user.isTopRated
                                  ? AppColors.gold
                                  : AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: user.isTopRated
                                    ? AppColors.goldDark
                                    : const Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Price + affordability badges
                Row(
                  children: [
                    if (user.isPaid)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.grad,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'EGP ${user.pricePerHourEGP.toStringAsFixed(0)} / hour',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.success, AppColors.green],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'FREE Sessions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    if (priceBadge != null) ...[
                      const SizedBox(width: 8),
                      priceBadge,
                    ],
                    const Spacer(),
                    if (user.available)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Available',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: 14),

                Row(
                  children: [
                    _MiniStat(value: '${user.reviews}', label: 'Reviews'),
                    Container(width: 1, height: 28, color: AppColors.divider),
                    _MiniStat(
                      value: '${user.experienceYears} yrs',
                      label: 'Experience',
                    ),
                    Container(width: 1, height: 28, color: AppColors.divider),
                    _MiniStat(
                      value: '${user.completedSessions}',
                      label: 'Sessions',
                      valueColor: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: user.skills
                      .map((s) => _SkillTag(label: s))
                      .toList(),
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExpertProfilePage(user: user),
                          ),
                        ),
                        icon: const Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                        ),
                        label: const Text(
                          'View Profile',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.divider),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: user.available
                            ? () => showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => _BookSessionSheet(user: user),
                              )
                            : null,
                        icon: const Icon(
                          Icons.calendar_month_rounded,
                          size: 15,
                        ),
                        label: Text(
                          user.available ? 'Book Session' : 'Unavailable',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: user.isTopRated
                              ? AppColors.gold
                              : AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.divider,
                          elevation: user.isTopRated ? 4 : 0,
                          shadowColor: user.isTopRated
                              ? AppColors.gold.withOpacity(0.4)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  final ExpertData user;
  const _AvatarWidget({required this.user});
  @override
  Widget build(BuildContext context) {
    Color borderColor;
    if (user.isTopRated) {
      borderColor = AppColors.gold;
    } else if (user.boost == BoostTier.elite) {
      borderColor = AppColors.purple;
    } else if (user.boost == BoostTier.pro) {
      borderColor = AppColors.primary;
    } else {
      borderColor = AppColors.divider;
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
              width: borderColor == AppColors.divider ? 2 : 2.5,
            ),
            boxShadow: borderColor != AppColors.divider
                ? [
                    BoxShadow(
                      color: borderColor.withOpacity(0.4),
                      blurRadius: 12,
                    ),
                  ]
                : [],
          ),
          child: _netImg(user.imageUrl, 66, radius: 16),
        ),
        if (user.available)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  BOOK SESSION SHEET — combines date, time, message, and payment
// ═══════════════════════════════════════════════════════════════════

class _BookSessionSheet extends StatefulWidget {
  final ExpertData user;
  const _BookSessionSheet({required this.user});
  @override
  State<_BookSessionSheet> createState() => _BookSessionSheetState();
}

class _BookSessionSheetState extends State<_BookSessionSheet> {
  final _msgCtrl = TextEditingController();
  DateTime? _pickedDate;
  TimeOfDay? _pickedTime;
  int _hours = 1;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _pickedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (t != null) setState(() => _pickedTime = t);
  }

  String _fmtDate(DateTime d) {
    const m = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${m[d.month]} ${d.day}, ${d.year}';
  }

  Future<void> _confirmBooking() async {
    if (_pickedDate == null || _pickedTime == null) return;

    final u = widget.user;
    final totalCost = u.pricePerHourEGP * _hours;
    final dateStr =
        '${_fmtDate(_pickedDate!)} | ${_pickedTime!.format(context)} • ${_hours}h';

    final booked = await showBookingDialog(
      context: context,
      mentorName: u.name,
      mentorImage: u.imageUrl,
      subject: u.specialization,
      date: dateStr,
      tags: u.skills.take(3).toList(),
      amount: totalCost,
      isPaid: u.isPaid,
    );

    if (booked && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 Session request sent to ${u.name.split(' ').first}!',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final canBook = _pickedDate != null && _pickedTime != null;
    final totalCost = u.pricePerHourEGP * _hours;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Mentor header
            Row(
              children: [
                _netImg(u.imageUrl, 56, radius: 14),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Book Session with',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        u.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            u.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(u.specialization, style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            Container(height: 1, color: AppColors.divider),
            const SizedBox(height: 18),

            // Duration
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Session Duration',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(3, (i) {
                final hrs = i + 1;
                final sel = _hours == hrs;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _hours = hrs),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        gradient: sel ? AppColors.grad : null,
                        color: sel ? null : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel ? Colors.transparent : AppColors.divider,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${hrs}h',
                          style: TextStyle(
                            color: sel ? Colors.white : AppColors.textMid,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // Date
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Date',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _pickedDate != null
                        ? AppColors.primary
                        : AppColors.divider,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: _pickedDate != null
                      ? AppColors.tag
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: _pickedDate != null
                          ? AppColors.primary
                          : AppColors.textLight,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _pickedDate != null
                          ? _fmtDate(_pickedDate!)
                          : 'Choose a date',
                      style: TextStyle(
                        color: _pickedDate != null
                            ? AppColors.primary
                            : AppColors.textLight,
                        fontWeight: _pickedDate != null
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Time
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Time',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _pickedTime != null
                        ? AppColors.primary
                        : AppColors.divider,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: _pickedTime != null
                      ? AppColors.tag
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: _pickedTime != null
                          ? AppColors.primary
                          : AppColors.textLight,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _pickedTime != null
                          ? _pickedTime!.format(context)
                          : 'Choose a time',
                      style: TextStyle(
                        color: _pickedTime != null
                            ? AppColors.primary
                            : AppColors.textLight,
                        fontWeight: _pickedTime != null
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Message
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Message (optional)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: TextField(
                controller: _msgCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Introduce yourself and what you want to learn...',
                  hintStyle: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Cost summary
            if (u.isPaid)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: AppColors.grad,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Total Cost',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      'EGP ${totalCost.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.success, AppColors.green],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.celebration_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This session is FREE!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: canBook ? _confirmBooking : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: canBook ? AppColors.grad : null,
                  color: canBook ? null : AppColors.divider,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    canBook
                        ? (u.isPaid ? 'Confirm & Pay' : 'Confirm Booking')
                        : 'Pick date & time first',
                    style: TextStyle(
                      color: canBook ? Colors.white : AppColors.textLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textLight, fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  EXPERT PROFILE PAGE — full profile with reviews, stats, bio
// ═══════════════════════════════════════════════════════════════════

class ExpertProfilePage extends StatelessWidget {
  final ExpertData user;
  const ExpertProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEF2FF), Color(0xFFDBEAFE), Color(0xFFD1FAE5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ──
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.divider.withOpacity(0.5),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.1),
                              AppColors.green.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Expert Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ── Hero Card with avatar, name, badge ──
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: user.isTopRated
                              ? AppColors.gold.withOpacity(0.4)
                              : user.boost == BoostTier.elite
                              ? AppColors.purple.withOpacity(0.4)
                              : user.boost == BoostTier.pro
                              ? AppColors.primary.withOpacity(0.4)
                              : AppColors.divider.withOpacity(0.7),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: user.isTopRated
                                        ? AppColors.gold
                                        : user.boost == BoostTier.elite
                                        ? AppColors.purple
                                        : user.boost == BoostTier.pro
                                        ? AppColors.primary
                                        : AppColors.divider,
                                    width: 3,
                                  ),
                                  boxShadow: user.isTopRated
                                      ? [
                                          BoxShadow(
                                            color: AppColors.gold.withOpacity(
                                              0.4,
                                            ),
                                            blurRadius: 16,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    user.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.tag,
                                      child: const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (user.available)
                                Positioned(
                                  bottom: 6,
                                  right: 6,
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.title,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.grad,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user.level,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.textLight,
                              ),
                              const SizedBox(width: 3),
                              Text(user.location, style: AppTextStyles.caption),
                            ],
                          ),
                          if (user.isTopRated ||
                              user.boost != BoostTier.none) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (user.isTopRated)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.goldGrad,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      '🥇 Top Rated',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                if (user.boost == BoostTier.elite)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.eliteGrad,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      '💎 Elite Expert',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                if (user.boost == BoostTier.pro)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.proGrad,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      '🔵 Pro Expert',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Quick Stats Grid ──
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            Icons.star_rounded,
                            AppColors.gold,
                            user.rating.toStringAsFixed(1),
                            'Rating',
                            '${user.reviews} reviews',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statCard(
                            Icons.event_available_rounded,
                            AppColors.primary,
                            '${user.completedSessions}',
                            'Sessions',
                            'Completed',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            Icons.work_history_rounded,
                            AppColors.purple,
                            '${user.experienceYears}+ yrs',
                            'Experience',
                            user.level,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statCard(
                            Icons.attach_money_rounded,
                            user.isPaid ? AppColors.green : AppColors.success,
                            user.isPaid
                                ? 'EGP ${user.pricePerHourEGP.toStringAsFixed(0)}'
                                : 'FREE',
                            'Per Hour',
                            user.isPaid ? 'Hourly rate' : 'No charge',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ── Specialization ──
                    _sectionHeader(
                      Icons.workspace_premium_rounded,
                      'Specialization',
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.divider.withOpacity(0.7),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: AppColors.grad,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.code_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.specialization,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Primary expertise area',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Bio / About ──
                    _sectionHeader(Icons.person_outline_rounded, 'About'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.divider.withOpacity(0.7),
                        ),
                      ),
                      child: Text(user.bio, style: AppTextStyles.body),
                    ),

                    const SizedBox(height: 18),

                    // ── Skills ──
                    _sectionHeader(Icons.bolt_rounded, 'Skills & Expertise'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.divider.withOpacity(0.7),
                        ),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: user.skills
                            .map((s) => _SkillTag(label: s))
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Reviews ──
                    Row(
                      children: [
                        Expanded(
                          child: _sectionHeader(
                            Icons.reviews_rounded,
                            'Reviews & Feedback',
                          ),
                        ),
                        Text(
                          '${user.reviewList.length} of ${user.reviews}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...user.reviewList.map(
                      (r) =>
                          _ReviewCard(review: r, isTopRated: user.isTopRated),
                    ),

                    const SizedBox(height: 24),

                    // ── Book Button ──
                    GestureDetector(
                      onTap: user.available
                          ? () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => _BookSessionSheet(user: user),
                            )
                          : null,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: user.available ? AppColors.grad : null,
                          color: user.available ? null : AppColors.divider,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: user.available
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_month_rounded,
                                color: user.available
                                    ? Colors.white
                                    : AppColors.textLight,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                user.available
                                    ? 'Book a Session'
                                    : 'Currently Unavailable',
                                style: TextStyle(
                                  color: user.available
                                      ? Colors.white
                                      : AppColors.textLight,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: AppColors.grad,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    IconData icon,
    Color color,
    String value,
    String label,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMid,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewData review;
  final bool isTopRated;
  const _ReviewCard({required this.review, required this.isTopRated});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.divider.withOpacity(0.7)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _netImg(review.reviewerImage, 40, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.reviewer,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    review.date,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < review.rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 14,
                  color: isTopRated ? AppColors.gold : AppColors.warning,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(review.comment, style: AppTextStyles.body.copyWith(fontSize: 13)),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════
//  NOTIFICATIONS BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════

class _NotificationsSheet extends StatefulWidget {
  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  final _ctrl = NotificationsController.instance;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ctrl.removeListener(_rebuild);
    super.dispose();
  }

  _NotifStyle _styleFor(NotifType t) {
    switch (t) {
      case NotifType.sessionAccepted:
        return _NotifStyle(
          icon: Icons.check_circle_rounded,
          gradColors: [const Color(0xFF059669), const Color(0xFF10B981)],
          bgColor: AppColors.successBg,
          labelColor: const Color(0xFF065F46),
        );
      case NotifType.sessionCancelled:
        return _NotifStyle(
          icon: Icons.cancel_rounded,
          gradColors: [const Color(0xFFEF4444), const Color(0xFFFF6B6B)],
          bgColor: AppColors.dangerBg,
          labelColor: const Color(0xFF991B1B),
        );
      case NotifType.sessionBooked:
        return _NotifStyle(
          icon: Icons.calendar_month_rounded,
          gradColors: [const Color(0xFF2563EB), const Color(0xFF059669)],
          bgColor: AppColors.tag,
          labelColor: AppColors.primary,
        );
      case NotifType.sessionPending:
        return _NotifStyle(
          icon: Icons.hourglass_top_rounded,
          gradColors: [const Color(0xFFF59E0B), const Color(0xFFFFB300)],
          bgColor: AppColors.warningBg,
          labelColor: const Color(0xFF92400E),
        );
      case NotifType.newMessage:
        return _NotifStyle(
          icon: Icons.chat_bubble_rounded,
          gradColors: [const Color(0xFF7C3AED), const Color(0xFFA78BFA)],
          bgColor: const Color(0xFFEDE9FE),
          labelColor: const Color(0xFF5B21B6),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifs = _ctrl.all;
    final unread = _ctrl.unreadCount;

    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.divider.withOpacity(0.5)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.grad,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (unread > 0)
                      Text(
                        '$unread unread',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                if (unread > 0)
                  GestureDetector(
                    onTap: () {
                      _ctrl.markAllRead();
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.grad,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Mark all read',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                if (notifs.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _ctrl.clearAll();
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.dangerBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Clear all',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: notifs.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: notifs.length,
                    itemBuilder: (_, i) =>
                        _buildNotifCard(notifs[i], _styleFor(notifs[i].type)),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.green.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 38,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No notifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Updates will appear here',
            style: TextStyle(fontSize: 13, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifCard(AppNotification n, _NotifStyle style) {
    return Dismissible(
      key: Key(n.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        _ctrl.remove(n.id);
        setState(() {});
      },
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.dangerBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.danger,
          size: 22,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          _ctrl.markRead(n.id);
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: n.isRead
                ? AppColors.surface
                : style.bgColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: n.isRead ? AppColors.divider : style.bgColor,
              width: n.isRead ? 1 : 1.5,
            ),
            boxShadow: n.isRead
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: style.gradColors[0].withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.network(
                      n.avatarUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppColors.grad,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: style.gradColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(style.icon, size: 11, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: n.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        if (!n.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: style.gradColors,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.body,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMid,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: style.gradColors),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(style.icon, size: 8, color: Colors.white),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _ctrl.timeAgo(n.time),
                          style: TextStyle(
                            fontSize: 11,
                            color: style.labelColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifStyle {
  final IconData icon;
  final List<Color> gradColors;
  final Color bgColor, labelColor;
  const _NotifStyle({
    required this.icon,
    required this.gradColors,
    required this.bgColor,
    required this.labelColor,
  });
}

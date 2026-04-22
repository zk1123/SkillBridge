import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  static const primary = Color(0xFF2563EB);
  static const surface = Color(0xFFF7F8FC);
  static const background = Color(0xFFF7F8FC);
  static const card = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF0F172A);
  static const textMid = Color(0xFF475569);
  static const textLight = Color(0xFF94A3B8);
  static const divider = Color(0xFFE2E8F0);
  static const success = Color(0xFF10B981);
  static const tag = Color(0xFFEFF6FF);
  static const tagText = Color(0xFF3B82F6);
  static const warning = Color(0xFFF59E0B);
  static const warningBg = Color(0xFFFEF3C7);
  static const gold = Color(0xFFFFD700);
  static const goldDark = Color(0xFFB8860B);
  static const green = Color(0xFF059669);
}

// ═══════════════════════════════════════════════════════════════════
//  TEXT STYLES
// ═══════════════════════════════════════════════════════════════════

class AppTextStyles {
  static const displayLarge = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.5,
  );
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
//  MODELS
// ═══════════════════════════════════════════════════════════════════

class _ReviewData {
  final String reviewer, comment, date, reviewerImage;
  final double rating;
  const _ReviewData({
    required this.reviewer,
    required this.comment,
    required this.date,
    required this.rating,
    required this.reviewerImage,
  });
}

class _UserData {
  final String name, title, imageUrl, location;
  final double rating;
  final int reviews;
  final List<String> skills;
  final bool available;
  final List<_ReviewData> reviewList;
  const _UserData({
    required this.name,
    required this.title,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.location,
    required this.skills,
    required this.available,
    required this.reviewList,
  });
}

// ═══════════════════════════════════════════════════════════════════
//  DATA
// ═══════════════════════════════════════════════════════════════════

const _allUsers = [
  _UserData(
    name: "Marwan Hussien",
    title: "Senior Mobile Developer",
    imageUrl: "https://i.postimg.cc/z3ZzXWGc/Marwan.webp",
    rating: 5.0,
    reviews: 450,
    location: "Cairo, Egypt",
    skills: ["Flutter", "Dart", "Firebase", "iOS"],
    available: true,
    reviewList: [
      _ReviewData(
        reviewer: "Nada Sherif",
        reviewerImage: "https://i.pravatar.cc/150?img=47",
        comment:
            "Absolutely the best Flutter mentor I've had. Explained state management like no one else.",
        date: "Apr 18, 2025",
        rating: 5.0,
      ),
      _ReviewData(
        reviewer: "Omar Fathy",
        reviewerImage: "https://i.pravatar.cc/150?img=14",
        comment:
            "Perfect session every time. Always on time and super knowledgeable.",
        date: "Apr 1, 2025",
        rating: 5.0,
      ),
      _ReviewData(
        reviewer: "Laila Kamal",
        reviewerImage: "https://i.pravatar.cc/150?img=32",
        comment: "5 stars isn't enough! Helped me ship my first Flutter app.",
        date: "Mar 20, 2025",
        rating: 5.0,
      ),
    ],
  ),
  _UserData(
    name: "Mohamed Nukbassy",
    title: "Senior Data Analyst",
    imageUrl: "https://i.postimg.cc/9f0r3cSF/Mo-nakbas.jpg",
    rating: 4.9,
    reviews: 218,
    location: "Cairo, Egypt",
    skills: ["Python", "SQL", "Tableau", "ML"],
    available: true,
    reviewList: [
      _ReviewData(
        reviewer: "Ahmed Ali",
        reviewerImage: "https://i.pravatar.cc/150?img=11",
        comment:
            "Amazing session! Explained pandas so clearly. My data cleaning skills improved massively.",
        date: "Apr 15, 2025",
        rating: 5.0,
      ),
      _ReviewData(
        reviewer: "Sara Mostafa",
        reviewerImage: "https://i.pravatar.cc/150?img=45",
        comment:
            "Very professional and patient. Helped me debug a tricky SQL query in minutes.",
        date: "Mar 28, 2025",
        rating: 5.0,
      ),
      _ReviewData(
        reviewer: "Karim Nour",
        reviewerImage: "https://i.pravatar.cc/150?img=13",
        comment: "Great mentor! Would definitely book again.",
        date: "Mar 10, 2025",
        rating: 4.5,
      ),
    ],
  ),
  _UserData(
    name: "Sara Khalil",
    title: "UI/UX Designer",
    imageUrl: "https://i.pravatar.cc/150?img=47",
    rating: 4.8,
    reviews: 134,
    location: "Alexandria, Egypt",
    skills: ["Figma", "Sketch", "Prototyping", "Design Systems"],
    available: false,
    reviewList: [
      _ReviewData(
        reviewer: "Youssef Maher",
        reviewerImage: "https://i.pravatar.cc/150?img=15",
        comment:
            "Sara helped me create a beautiful design system from scratch. Super talented!",
        date: "Apr 10, 2025",
        rating: 5.0,
      ),
      _ReviewData(
        reviewer: "Mona Adel",
        reviewerImage: "https://i.pravatar.cc/150?img=44",
        comment: "Very detailed feedback on my Figma prototype. Learned a lot!",
        date: "Mar 25, 2025",
        rating: 4.5,
      ),
    ],
  ),
  _UserData(
    name: "Ahmed Tarek",
    title: "Backend Engineer",
    imageUrl: "https://i.pravatar.cc/150?img=12",
    rating: 4.7,
    reviews: 92,
    location: "Giza, Egypt",
    skills: ["Node.js", "PostgreSQL", "Docker", "AWS"],
    available: true,
    reviewList: [
      _ReviewData(
        reviewer: "Hassan Ramzy",
        reviewerImage: "https://i.pravatar.cc/150?img=16",
        comment: "Great session on REST APIs. Clear and concise explanations.",
        date: "Apr 5, 2025",
        rating: 5.0,
      ),
      _ReviewData(
        reviewer: "Dina Samir",
        reviewerImage: "https://i.pravatar.cc/150?img=43",
        comment: "Helped me set up Docker for the first time. Very patient!",
        date: "Mar 18, 2025",
        rating: 4.5,
      ),
    ],
  ),
];

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
  Widget build(BuildContext context) {
    return Container(
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
}

class _MiniStat extends StatelessWidget {
  final String value, label;
  final Color? valueColor;
  const _MiniStat({required this.value, required this.label, this.valueColor});
  @override
  Widget build(BuildContext context) {
    return Expanded(
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
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  const _HeaderIconBtn({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.divider),
      ),
      child: Icon(icon, size: 20, color: AppColors.textDark),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  FEED PAGE
// ═══════════════════════════════════════════════════════════════════

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Centered Logo Header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            color: AppColors.surface,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.green],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.hub_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Skill",
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: -1,
                            ),
                          ),
                          TextSpan(
                            text: "Bridge",
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: AppColors.green,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Find your perfect skill match",
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Row(
                    children: [
                      _HeaderIconBtn(icon: Icons.search_rounded),
                      const SizedBox(width: 8),
                      _HeaderIconBtn(icon: Icons.tune_rounded),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Category chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: const [
                _CategoryChip(label: "All", active: true),
                _CategoryChip(label: "Development"),
                _CategoryChip(label: "Design"),
                _CategoryChip(label: "Data"),
                _CategoryChip(label: "Product"),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text("Top Experts Near You", style: AppTextStyles.titleLarge),
                const Spacer(),
                Text(
                  "See all",
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Expert cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: _allUsers.length,
              itemBuilder: (_, i) => _ExpertCard(user: _allUsers[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool active;
  const _CategoryChip({required this.label, this.active = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.divider,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : AppColors.textMid,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  EXPERT CARD
// ═══════════════════════════════════════════════════════════════════

class _ExpertCard extends StatelessWidget {
  final _UserData user;
  const _ExpertCard({required this.user});

  bool get _isPerfect => user.rating >= 4.9;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: _isPerfect
            ? Border.all(color: AppColors.gold.withOpacity(0.7), width: 1.5)
            : Border.all(color: AppColors.divider.withOpacity(0.6)),
        boxShadow: _isPerfect
            ? [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          // Gold banner
          if (_isPerfect)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD700),
                    Color(0xFFFFB300),
                    Color(0xFFFFD700),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "⭐ Perfect Score — Top Rated Expert",
                    style: TextStyle(
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
                // Avatar + Info + Clickable Rating
                Row(
                  children: [
                    _Avatar(user: user, isPerfect: _isPerfect),
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
                              if (_isPerfect)
                                const Icon(
                                  Icons.workspace_premium_rounded,
                                  color: AppColors.gold,
                                  size: 18,
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
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: AppColors.textLight,
                              ),
                              const SizedBox(width: 3),
                              Text(user.location, style: AppTextStyles.caption),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Clickable Rating Badge
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReviewsPage(user: user),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: _isPerfect
                              ? AppColors.gold.withOpacity(0.15)
                              : AppColors.warningBg,
                          borderRadius: BorderRadius.circular(12),
                          border: _isPerfect
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
                              color: _isPerfect
                                  ? AppColors.gold
                                  : AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _isPerfect
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

                const SizedBox(height: 16),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: 14),

                // Stats
                Row(
                  children: [
                    _MiniStat(value: "${user.reviews}", label: "Reviews"),
                    Container(width: 1, height: 28, color: AppColors.divider),
                    _MiniStat(
                      value: user.rating.toStringAsFixed(1),
                      label: "Rating",
                    ),
                    Container(width: 1, height: 28, color: AppColors.divider),
                    _MiniStat(
                      value: user.available ? "Open" : "Busy",
                      label: "Status",
                      valueColor: user.available
                          ? AppColors.success
                          : AppColors.textLight,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Skills
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: user.skills
                      .map((s) => _SkillTag(label: s))
                      .toList(),
                ),

                const SizedBox(height: 18),

                // Buttons
                Row(
                  children: [
                    // Message Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => _MessageSheet(user: user),
                        ),
                        icon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 14,
                        ),
                        label: const Text(
                          "Message",
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

                    // View Profile Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewsPage(user: user),
                          ),
                        ),
                        icon: const Icon(
                          Icons.person_outline_rounded,
                          size: 15,
                        ),
                        label: const Text(
                          "View Profile",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPerfect
                              ? AppColors.gold
                              : AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: _isPerfect ? 4 : 0,
                          shadowColor: _isPerfect
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

class _Avatar extends StatelessWidget {
  final _UserData user;
  final bool isPerfect;
  const _Avatar({required this.user, required this.isPerfect});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: isPerfect
                ? Border.all(color: AppColors.gold, width: 2.5)
                : Border.all(color: AppColors.divider, width: 2),
            boxShadow: isPerfect
                ? [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.4),
                      blurRadius: 14,
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
//  MESSAGE SHEET
// ═══════════════════════════════════════════════════════════════════

class _MessageSheet extends StatefulWidget {
  final _UserData user;
  const _MessageSheet({required this.user});
  @override
  State<_MessageSheet> createState() => _MessageSheetState();
}

class _MessageSheetState extends State<_MessageSheet> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _netImg(widget.user.imageUrl, 44, radius: 13),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Message ${widget.user.name.split(' ').first}",
                      style: AppTextStyles.titleMedium,
                    ),
                    Text(widget.user.title, style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Write your message...",
                  hintStyle: TextStyle(color: AppColors.textLight),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Message sent to ${widget.user.name.split(' ').first}! 🎉",
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text(
                  "Send Message",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
//  REVIEWS PAGE
// ═══════════════════════════════════════════════════════════════════

class ReviewsPage extends StatelessWidget {
  final _UserData user;
  const ReviewsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isPerfect = user.rating >= 4.9;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            _netImg(user.imageUrl, 36, radius: 10),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${user.name.split(' ').first}'s Profile",
                  style: AppTextStyles.titleMedium,
                ),
                Text("${user.reviews} reviews", style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Rating Summary
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: isPerfect
                  ? const LinearGradient(
                      colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isPerfect
                    ? AppColors.gold.withOpacity(0.4)
                    : AppColors.primary.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                if (isPerfect) ...[
                  const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.gold,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Top Rated Expert!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.goldDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Highly reviewed and trusted by the community",
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.goldDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: isPerfect
                            ? AppColors.goldDark
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (i) => Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Icon(
                                Icons.star_rounded,
                                size: 24,
                                color: i < user.rating
                                    ? (isPerfect
                                          ? AppColors.gold
                                          : AppColors.warning)
                                    : AppColors.divider,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${user.reviews} total reviews",
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Text("What people say", style: AppTextStyles.titleLarge),
              const Spacer(),
              Text(
                "${user.reviewList.length} reviews",
                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...user.reviewList.map(
            (r) => _ReviewCard(review: r, isPerfect: isPerfect),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final _ReviewData review;
  final bool isPerfect;
  const _ReviewCard({required this.review, required this.isPerfect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _netImg(review.reviewerImage, 44, radius: 13),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.reviewer, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 2),
                    Text(review.date, style: AppTextStyles.caption),
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
                    size: 15,
                    color: isPerfect ? AppColors.gold : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(review.comment, style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }
}

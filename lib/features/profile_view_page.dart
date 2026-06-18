import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/review_model.dart';
import 'block_button.dart';

// ═══════════════════════════════════════════════════════════════════
//  COLORS — mirrors profile_page.dart AppColors
// ═══════════════════════════════════════════════════════════════════

class _C {
  static const primary = Color(0xFF2563EB);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF1F5F9);
  static const card = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF0F172A);
  static const textMid = Color(0xFF475569);
  static const textLight = Color(0xFF94A3B8);
  static const divider = Color(0xFFE2E8F0);
  static const tag = Color(0xFFEFF6FF);
  static const tagText = Color(0xFF3B82F6);
  static const gradStart = Color(0xFF1D4ED8);
  static const gradMid = Color(0xFF2563EB);
  static const gradEnd = Color(0xFF34D399);
  static const learnColor = Color(0xFF8B5CF6);
  static const star = Color(0xFFF59E0B);
}

// ═══════════════════════════════════════════════════════════════════
//  VIEW PROFILE PAGE
// ═══════════════════════════════════════════════════════════════════

class ViewProfilePage extends StatefulWidget {
  final String uid;

  const ViewProfilePage({super.key, required this.uid});

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  UserModel? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      if (!mounted) return;
      if (doc.exists) {
        setState(() {
          _user = UserModel.fromMap(doc.data()!);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'User profile not found.';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load profile: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _C.background,
        body: Center(child: CircularProgressIndicator(color: _C.primary)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: _C.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: _C.textMid),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: _fetchUser, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final user = _user!;
    final hasPhoto = user.profilePicUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: _C.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _ProfileHeader(user: user, hasPhoto: hasPhoto),
          ),

          // ── Body ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats
                  _StatsRow(user: user),
                  const SizedBox(height: 24),

                  // About
                  if (user.bio.isNotEmpty) ...[
                    _CardSection(
                      title: 'About',
                      child: Text(
                        user.bio,
                        style: const TextStyle(
                          fontSize: 14,
                          color: _C.textMid,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Teach skills
                  _CardSection(
                    title: 'Skills They Can Teach',
                    titleIcon: Icons.school_outlined,
                    titleIconColor: _C.primary,
                    child: user.teachSkills.isEmpty
                        ? const Text(
                            'No teaching skills added yet.',
                            style: TextStyle(
                              fontSize: 13,
                              color: _C.textLight,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: user.teachSkills
                                .map(
                                  (s) => _SkillTag(label: s, color: _C.primary),
                                )
                                .toList(),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Learn skills
                  _CardSection(
                    title: 'Skills They Want to Learn',
                    titleIcon: Icons.auto_stories_outlined,
                    titleIconColor: _C.learnColor,
                    child: user.learnSkills.isEmpty
                        ? const Text(
                            'No learning goals added yet.',
                            style: TextStyle(
                              fontSize: 13,
                              color: _C.textLight,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: user.learnSkills
                                .map(
                                  (s) =>
                                      _SkillTag(label: s, color: _C.learnColor),
                                )
                                .toList(),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Reviews section
                  _ReviewsSection(uid: widget.uid),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  PROFILE HEADER — read-only version of profile_page.dart header
// ═══════════════════════════════════════════════════════════════════

class _ProfileHeader extends StatelessWidget {
  final UserModel user;
  final bool hasPhoto;

  const _ProfileHeader({required this.user, required this.hasPhoto});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.gradStart, _C.gradMid, _C.gradEnd],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.07,
              child: CustomPaint(painter: _DotPatternPainter()),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (FirebaseAuth.instance.currentUser?.uid != user.uid)
                        BlockButton(
                          targetUserId: user.uid,
                          targetUserName: user.name,
                          onBlockSuccess: () => Navigator.pop(context),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Avatar
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.white24,
                    backgroundImage: hasPhoto
                        ? NetworkImage(user.profilePicUrl)
                        : null,
                    child: !hasPhoto
                        ? Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Name
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Georgia',
                    letterSpacing: -0.3,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                  ),
                ),
                const SizedBox(height: 4),

                // Rating badge — only show if they have reviews
                if (user.reviewCount > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: _C.star,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${user.averageRating.toStringAsFixed(1)}  ·  ${user.reviewCount} review${user.reviewCount != 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  STATS ROW
// ═══════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  final UserModel user;
  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _PStat(
            value: '${user.teachSkills.length}',
            label: 'Teaching',
            icon: Icons.school_outlined,
            iconColor: _C.primary,
          ),
          _VDivider(),
          _PStat(
            value: '${user.learnSkills.length}',
            label: 'Learning',
            icon: Icons.auto_stories_outlined,
            iconColor: _C.learnColor,
          ),
          _VDivider(),
          _PStat(
            value: user.reviewCount > 0
                ? user.averageRating.toStringAsFixed(1)
                : '—',
            label: '${user.reviewCount} Reviews',
            icon: Icons.star_rounded,
            iconColor: _C.star,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  REVIEWS SECTION
// ═══════════════════════════════════════════════════════════════════

class _ReviewsSection extends StatelessWidget {
  final String uid;
  const _ReviewsSection({required this.uid});

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      title: 'Reviews',
      titleIcon: Icons.star_rounded,
      titleIconColor: _C.star,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .where('reviewedId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: _C.primary),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No reviews yet.',
                style: TextStyle(
                  fontSize: 13,
                  color: _C.textLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }

          return Column(
            children: docs.map((doc) {
              final review = ReviewModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
              return _ReviewCard(review: review);
            }).toList(),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  REVIEW CARD
// ═══════════════════════════════════════════════════════════════════

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(review.reviewerId)
          .get(),
      builder: (context, snapshot) {
        final reviewerName = snapshot.hasData && snapshot.data!.exists
            ? (snapshot.data!.data() as Map<String, dynamic>)['name']
                      as String? ??
                  'Someone'
            : 'Someone';
        final reviewerPic = snapshot.hasData && snapshot.data!.exists
            ? (snapshot.data!.data() as Map<String, dynamic>)['profilePicUrl']
                      as String? ??
                  ''
            : '';

        final hasPhoto = reviewerPic.isNotEmpty;
        final date = review.createdAt.toDate();
        final dateStr = _formatDate(date);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Reviewer info + stars ──
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _C.tag,
                    child: hasPhoto
                        ? ClipOval(
                            child: Image.network(
                              reviewerPic,
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Text(
                                reviewerName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _C.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            reviewerName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: _C.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reviewerName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _C.textDark,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _C.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Stars
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < review.rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: i < review.rating ? _C.star : _C.divider,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),

              // ── Review text ──
              if (review.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  review.text,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _C.textMid,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
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
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════

class _CardSection extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? titleIcon;
  final Color? titleIconColor;

  const _CardSection({
    required this.title,
    required this.child,
    this.titleIcon,
    this.titleIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.divider.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [titleIconColor ?? _C.primary, _C.gradEnd],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              if (titleIcon != null) ...[
                Icon(titleIcon, size: 16, color: titleIconColor),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _C.textDark,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SkillTag extends StatelessWidget {
  final String label;
  final Color color;
  const _SkillTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _PStat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color iconColor;

  const _PStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _C.textDark,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _C.textLight,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 48, color: _C.divider);
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    const spacing = 22.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

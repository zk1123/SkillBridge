import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
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
}

class AppTextStyles {
  static const displayMedium = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.3,
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
//  DATA
// ═══════════════════════════════════════════════════════════════════

class _ExperienceData {
  final String title, company, date;
  const _ExperienceData(this.title, this.company, this.date);
}

// ═══════════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════════════
//  PROFILE PAGE
// ═══════════════════════════════════════════════════════════════════

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const _exp = [
    _ExperienceData("Senior Developer", "SkillBridge Tech", "2022 – Present"),
    _ExperienceData("Mobile Lead", "AppWorld Egypt", "2019 – 2022"),
    _ExperienceData("Junior Programmer", "Startup Hub", "2016 – 2019"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _ProfileSliverHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatsRow(),
                  const SizedBox(height: 24),
                  _CardSection(
                    title: "About",
                    child: const Text(
                      "Passionate Mobile Developer specializing in high-performance Flutter apps and creative video storytelling. Based in Cairo, working globally.",
                      style: AppTextStyles.body,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CardSection(
                    title: "Skills",
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        "Flutter",
                        "Dart",
                        "Firebase",
                        "iOS",
                        "Android",
                        "Video Editing",
                        "Figma",
                      ].map((s) => _SkillTag(label: s)).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CardSection(
                    title: "Experience",
                    child: Column(
                      children: _exp
                          .asMap()
                          .entries
                          .map(
                            (e) => _ExperienceRow(
                              data: e.value,
                              isLast: e.key == _exp.length - 1,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CardSection(
                    title: "Contact",
                    child: Column(
                      children: [
                        _ContactRow(
                          icon: Icons.email_outlined,
                          text: "marwan.dev@example.com",
                        ),
                        _ContactRow(
                          icon: Icons.phone_android_outlined,
                          text: "+20 112 345 6789",
                        ),
                        _ContactRow(
                          icon: Icons.language_outlined,
                          text: "www.marwan-dev.com",
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
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
//  PROFILE SLIVER HEADER
// ═══════════════════════════════════════════════════════════════════

class _ProfileSliverHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradStart, AppColors.gradMid, AppColors.gradEnd],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Dot pattern background
            Positioned.fill(
              child: Opacity(
                opacity: 0.07,
                child: CustomPaint(painter: _DotPatternPainter()),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // ── Top bar: back + more ──
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _GlassBtn(icon: Icons.arrow_back_rounded),
                        _GlassBtn(icon: Icons.more_horiz_rounded),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Avatar ──
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
                    child: const CircleAvatar(
                      radius: 46,
                      backgroundImage: NetworkImage(
                        "https://i.postimg.cc/z3ZzXWGc/Marwan.webp",
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Name ──
                  const Text(
                    "Marwan Hussien",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Georgia',
                      letterSpacing: -0.3,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // ── Title / subtitle ──
                  Text(
                    "Flutter Expert & Video Editor",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.82),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Action Buttons Row ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      children: [
                        // Edit Profile – filled white
                        Expanded(
                          flex: 3,
                          child: _HeaderActionBtn(
                            label: "Edit Profile",
                            icon: Icons.edit_outlined,
                            filled: true,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Share – ghost outline
                        Expanded(
                          flex: 2,
                          child: _HeaderActionBtn(
                            label: "Share",
                            icon: Icons.ios_share_outlined,
                            filled: false,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Hire Me – accent green pill
                        Expanded(
                          flex: 3,
                          child: _HeaderActionBtn(
                            label: "Hire Me",
                            icon: Icons.handshake_outlined,
                            filled: false,
                            accent: true,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── زر الهيدر بأشكال مختلفة ──
class _HeaderActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final bool accent;
  final VoidCallback onTap;

  const _HeaderActionBtn({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = filled
        ? Colors.white
        : accent
        ? const Color(0xFF34D399).withOpacity(0.22)
        : Colors.white.withOpacity(0.15);

    final Color fgColor = filled ? AppColors.primary : Colors.white;

    final Border? border = filled
        ? null
        : Border.all(
            color: accent
                ? const Color(0xFF34D399).withOpacity(0.7)
                : Colors.white.withOpacity(0.45),
            width: 1.2,
          );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: border,
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: fgColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: fgColor,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassBtn extends StatelessWidget {
  final IconData icon;
  const _GlassBtn({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  STATS ROW
// ═══════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.tag,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Cairo, Egypt",
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.tagText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF059669),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "Available",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF065F46),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider.withOpacity(0.6)),
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
                value: "450",
                label: "Reviews",
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFF59E0B),
              ),
              _VDivider(),
              _PStat(
                value: "12k",
                label: "Followers",
                icon: Icons.people_alt_outlined,
                iconColor: AppColors.primary,
              ),
              _VDivider(),
              _PStat(
                value: "8 yrs",
                label: "Experience",
                icon: Icons.workspace_premium_outlined,
                iconColor: const Color(0xFF8B5CF6),
              ),
            ],
          ),
        ),
      ],
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
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textDark,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 48, color: AppColors.divider);
}

// ═══════════════════════════════════════════════════════════════════
//  CARD SECTION
// ═══════════════════════════════════════════════════════════════════

class _CardSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _CardSection({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withOpacity(0.6)),
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
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.gradEnd],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  EXPERIENCE ROW
// ═══════════════════════════════════════════════════════════════════

class _ExperienceRow extends StatelessWidget {
  final _ExperienceData data;
  final bool isLast;
  const _ExperienceRow({required this.data, required this.isLast});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.tag,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.work_outline_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            if (!isLast)
              Container(width: 1.5, height: 24, color: AppColors.divider),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(data.title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(data.company, style: AppTextStyles.label),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tag,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    data.date,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.tagText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  CONTACT ROW
// ═══════════════════════════════════════════════════════════════════

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLast;
  const _ContactRow({
    required this.icon,
    required this.text,
    this.isLast = false,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.tag,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Text(text, style: AppTextStyles.label),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DOT PATTERN PAINTER
// ═══════════════════════════════════════════════════════════════════

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

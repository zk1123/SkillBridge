import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({super.key});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  // 0 = "I Want to Learn", 1 = "I Want to Teach"
  int _modeIndex = 0;

  // Bottom nav index (Match = index 1)
  int _navIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      // ── TOP APP BAR ──────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.appBg,
        elevation: 0,
        titleSpacing: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 13),
          child: Icon(Icons.menu, color: AppColors.primaryBlue),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.primaryBlue],
          ).createShader(bounds),
          child: Text(
            'SkillBridge',
            style: GoogleFonts.inter(
              color: Colors.white, // ShaderMask overrides this color
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        actions: const [
          Icon(Icons.search, color: AppColors.subheadline),
          SizedBox(width: 12),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.notifications_rounded,
              color: AppColors.subheadline,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),

          // ── MODE TOGGLE ────────────────────────────
          _ModeToggle(
            selected: _modeIndex,
            onChanged: (i) => setState(() => _modeIndex = i),
          ),

          const SizedBox(height: 20),

          // ── PROFILE CARD ───────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ProfileCard(),
            ),
          ),

          const SizedBox(height: 24),

          // ── ACTION BUTTONS ─────────────────────────
          const _ActionButtons(),

          const SizedBox(height: 16),
        ],
      ),

      // ── BOTTOM NAV ─────────────────────────────────
      bottomNavigationBar: _BottomNav(
        current: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MODE TOGGLE  ("I Want to Learn" / "I Want to Teach")
// ─────────────────────────────────────────────
class _ModeToggle extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _ModeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _ToggleTab(
            label: 'I Want to Learn',
            isActive: selected == 0,
            onTap: () => onChanged(0),
          ),
          _ToggleTab(
            label: 'I Want to Teach',
            isActive: selected == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  )
                : null,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.gradientStart.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.subheadline,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PROFILE CARD
// ─────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Dark card background — same deep navy as in the design
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(24),
        // Subtle teal border glow matching the design's dashed outline
        border: Border.all(color: AppColors.teal.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // ── BACKGROUND GRADIENT OVERLAY ────────
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppColors.teal.withOpacity(0.15),
                      Colors.transparent,
                      AppColors.primaryBlue.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),

            //image
            Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  'assets/images/mentor.jfif',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            // Dark gradient overlay on top of the image
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                      Colors.black.withOpacity(1.0),
                    ],
                    stops: const [0.0, 0.2, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // ── TOP MENTOR BADGE ───────────────────
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.star, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Top Mentor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── MAIN CARD CONTENT ──────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Push content down, leaving room for the illustration at top
                  const SizedBox(height: 120),

                  // Name + rating row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Name & age
                      const Expanded(
                        child: Text(
                          'Marcus Thorne, 29',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                      ),
                      // Rating badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.star,
                              color: Color(0xFFFBBF24),
                              size: 16,
                            ),
                            SizedBox(height: 2),
                            Text(
                              '4.9',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'RATING',
                              style: TextStyle(
                                color: AppColors.placeholder,
                                fontSize: 7,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Location
                  Row(
                    children: const [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColors.placeholder,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Berlin, Germany',
                        style: TextStyle(
                          color: AppColors.placeholder,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Skill chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _SkillChip(label: 'Python - Expert'),
                      _SkillChip(label: 'React - Intermediate'),
                      _SkillChip(label: 'Architecture - Lead'),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Mentor mode label
                  Text(
                    'MENTOR: NORMAL NATURAL',
                    style: TextStyle(
                      color: AppColors.teal,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Bio
                  Text(
                    'Lead Engineer at TechScale. I specialize in building scalable distributed systems and mentoring junior devs on clean code...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SKILL CHIP
// ─────────────────────────────────────────────
class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ACTION BUTTONS  (X, refresh, heart)
// ─────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Dismiss button
        _RoundButton(
          onTap: () {},
          child: const Icon(Icons.close, color: AppColors.red, size: 26),
          size: 56,
          bgColor: AppColors.cardBg,
          hasShadow: true,
        ),

        const SizedBox(width: 24),

        // Refresh / main action — gradient
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gradientStart.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.refresh, color: Colors.white, size: 30),
          ),
        ),

        const SizedBox(width: 24),

        // Like button
        _RoundButton(
          onTap: () {},
          child: const Icon(Icons.check, color: AppColors.success, size: 26),
          size: 56,
          bgColor: AppColors.cardBg,
          hasShadow: true,
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final double size;
  final Color bgColor;
  final bool hasShadow;

  const _RoundButton({
    required this.onTap,
    required this.child,
    required this.size,
    required this.bgColor,
    this.hasShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  BOTTOM NAVIGATION BAR
// ─────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.feed_outlined, label: 'Feed'),
      _NavItem(icon: Icons.compare_arrows, label: 'Match'),
      _NavItem(icon: Icons.calendar_today_outlined, label: 'Sessions'),
      _NavItem(icon: Icons.chat_bubble_outline, label: 'Chat'),
      _NavItem(icon: Icons.person_outline, label: 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (i) => GestureDetector(
                onTap: () => onTap(i),
                child: _NavButton(item: items[i], isActive: i == current),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isActive;

  const _NavButton({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          item.icon,
          color: isActive ? AppColors.activeIcon : AppColors.iconInactive,
          size: 22,
        ),
        const SizedBox(height: 3),
        Text(
          item.label,
          style: TextStyle(
            color: isActive ? AppColors.activeIcon : AppColors.iconInactive,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

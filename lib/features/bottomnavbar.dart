import 'package:flutter/material.dart';
import 'messages_page.dart';
import 'match_page.dart';
import 'sessions_page.dart';
import 'profile_page.dart';
import 'feed_page.dart';
import 'login_page.dart';
import 'app_drawer.dart';
import 'package:google_fonts/google_fonts.dart';

const _kGrad = LinearGradient(
  colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF059669)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class AppBottomNavBar extends StatefulWidget {
  const AppBottomNavBar({super.key});

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class SkillBridgeLogo extends StatelessWidget {
  final double fontSize;
  const SkillBridgeLogo({super.key, this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: fontSize + 12,
          height: fontSize + 12,
          decoration: BoxDecoration(
            gradient: _kGrad,
            borderRadius: BorderRadius.circular((fontSize + 12) * 0.28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.hub_rounded,
            color: Colors.white,
            size: fontSize * 0.85,
          ),
        ),
        const SizedBox(width: 8),
        ShaderMask(
          shaderCallback: (b) => _kGrad.createShader(b),
          child: Text(
            'SkillBridge',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: fontSize,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}

final GlobalKey<ScaffoldState> appScaffoldKey = GlobalKey<ScaffoldState>();

class _AppBottomNavBarState extends State<AppBottomNavBar> {
  //default page
  int _currentIndex = 0;

  // Page names
  final List<Widget> _pages = [
    FeedPage(),
    MatchPage(),
    SessionsPage(),
    MessagePage(),
    ProfilePage(),
  ];

  // Navigation bar items
  final List<Map<String, dynamic>> _items = [
    {
      'icon': Icons.dynamic_feed_outlined,
      'activeIcon': Icons.dynamic_feed,
      'label': 'Feed',
    },
    {
      'icon': Icons.all_inclusive,
      'activeIcon': Icons.all_inclusive,
      'label': 'Match',
    },
    {
      'icon': Icons.event_available_outlined,
      'activeIcon': Icons.event_available,
      'label': 'Sessions',
    },
    {'icon': Icons.forum_outlined, 'activeIcon': Icons.forum, 'label': 'Chat'},
    {
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      'label': 'Profile',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The current page body
      key: appScaffoldKey,
      drawer: AppDrawer(activePage: _items[_currentIndex]['label'] as String),
      body: _pages[_currentIndex],

      // The nav bar
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Nav bar UI ─────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _items.asMap().entries.map((entry) {
              final int index = entry.key; // 0, 1, 2, 3, 4
              final Map item = entry.value; // the icon/label data
              final bool isActive = index == _currentIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = index; // ← re-render with new active tab
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: isActive ? 20 : 12,
                    vertical: 8,
                  ),
                  decoration: isActive
                      ? BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF005DA7), Color(0xFF2976C7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF005DA7).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        )
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive
                            ? item['activeIcon'] as IconData
                            : item['icon'] as IconData,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF94A3B8),
                        size: 22,
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Text(
                          item['label'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

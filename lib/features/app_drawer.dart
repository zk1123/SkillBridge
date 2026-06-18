import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bottomnavbar.dart' show appScaffoldKey;
import 'skill_store_page.dart';
import 'user_settings.dart';
import 'help_page.dart';
import 'my_earnings.dart';
import 'wallet_page.dart';
import 'saved_experts_page.dart';
import 'my_subscriptions_page.dart';
import 'explore_experts_page.dart';
import 'sessions_page.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

const _grad = LinearGradient(
  colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF059669)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ═══════════════════════════════════════════════════════════════════
//  APP DRAWER
// ═══════════════════════════════════════════════════════════════════

class AppDrawer extends StatelessWidget {
  final String activePage;
  const AppDrawer({super.key, this.activePage = 'feed'});

  void _push(BuildContext context, Widget page) {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 250), () {
      Navigator.of(
        appScaffoldKey.currentContext!,
        rootNavigator: false,
      ).push(MaterialPageRoute(builder: (_) => page));
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFEF4444),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Logout',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.inter(
            color: const Color(0xFF475569),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF475569)),
            ),
          ),
          GestureDetector(
            onTap: () async {
              Navigator.pop(context); // close dialog
              await AuthService().signOut();
              if (appScaffoldKey.currentContext != null) {
                Navigator.of(appScaffoldKey.currentContext!).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: 285,
      child: Column(
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
            decoration: const BoxDecoration(gradient: _grad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.hub_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [Colors.white, Color(0xFF86EFAC)],
                  ).createShader(b),
                  child: Text(
                    'SkillBridge',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find your perfect skill match',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Items ──
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _Item(
                  icon: Icons.workspace_premium_rounded,
                  label: 'Explore Experts',
                  badge: '🥇',
                  active: activePage == 'explore',
                  onTap: () => _push(context, const ExploreExpertsPage()),
                ),

                _Item(
                  icon: Icons.store_rounded,
                  label: 'SkillStore',
                  badge: '🛍️',
                  active: activePage == 'store',
                  onTap: () => _push(context, const SkillStorePage()),
                ),

                _Item(
                  icon: Icons.subscriptions_rounded,
                  label: 'My Subscriptions',
                  badge: '📦',
                  active: activePage == 'subs',
                  onTap: () => _push(context, const MySubscriptionsPage()),
                ),

                _Item(
                  icon: Icons.event_available_rounded,
                  label: 'My Sessions',
                  badge: '📅',
                  active: activePage == 'sessions',
                  onTap: () => _push(context, const SessionsPage()),
                ),

                _Item(
                  icon: Icons.bookmark_rounded,
                  label: 'Saved Experts',
                  badge: '❤️',
                  active: activePage == 'saved',
                  onTap: () => _push(context, const SavedExpertsPage()),
                ),

                _Item(
                  icon: Icons.trending_up_rounded,
                  label: 'My Earnings',
                  active: activePage == 'earnings',
                  onTap: () => _push(context, const MyEarningsPage()),
                ),

                _Item(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Wallet',
                  badge: '💰',
                  active: activePage == 'wallet',
                  onTap: () => _push(context, const WalletPage()),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Divider(),
                ),

                _Item(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  active: activePage == 'settings',
                  onTap: () => _push(context, const UserSettingsPage()),
                ),

                _Item(
                  icon: Icons.help_rounded,
                  label: 'Help & Support',
                  active: activePage == 'help',
                  onTap: () => _push(context, const HelpPage()),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Divider(),
                ),

                _Item(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  isRed: true,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),

          // ── Version ──
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'SkillBridge v1.0.0',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  _Item Widget
// ═══════════════════════════════════════════════════════════════════

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool isRed;
  final String? badge;
  final VoidCallback onTap;

  const _Item({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.isRed = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        gradient: active && !isRed
            ? LinearGradient(
                colors: [
                  const Color(0xFF2563EB).withOpacity(0.1),
                  const Color(0xFF2563EB).withOpacity(0.04),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(14),
        border: active && !isRed
            ? Border.all(color: const Color(0xFF2563EB).withOpacity(0.2))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                // Icon box
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: active && !isRed
                        ? _grad
                        : isRed
                        ? const LinearGradient(
                            colors: [Colors.red, Color(0xFFFF6B6B)],
                          )
                        : null,
                    color: active || isRed ? null : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: active && !isRed
                        ? [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : isRed
                        ? [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: active || isRed
                        ? Colors.white
                        : const Color(0xFF475569),
                  ),
                ),
                const SizedBox(width: 14),

                // Label
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active && !isRed
                          ? const Color(0xFF2563EB)
                          : isRed
                          ? Colors.red
                          : const Color(0xFF475569),
                    ),
                  ),
                ),

                // Badge or arrow
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: _grad,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else if (!isRed)
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: Color(0xFFCBD5E1),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

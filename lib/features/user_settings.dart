import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'block_controller.dart';
import 'block_page.dart';

const _primary = Color(0xFF2563EB);
const _green = Color(0xFF059669);
const _textDark = Color(0xFF0F172A);
const _textMid = Color(0xFF475569);
const _textLight = Color(0xFF94A3B8);
const _divider = Color(0xFFE2E8F0);
const _bg = Color(0xFFEEF2FF);
const _tag = Color(0xFFEFF6FF);
const _danger = Color(0xFFEF4444);
const _success = Color(0xFF10B981);
const _warning = Color(0xFFF59E0B);
const _purple = Color(0xFF7C3AED);

const _grad = LinearGradient(
  colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF059669)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const _pageBg = LinearGradient(
  colors: [Color(0xFFEEF2FF), Color(0xFFDBEAFE), Color(0xFFD1FAE5)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.0, 0.5, 1.0],
);

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});
  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  bool _notifSessions = true;
  bool _notifMessages = true;
  bool _notifReviews = false;
  bool _notifMarketing = false;
  bool _darkMode = false;
  bool _biometric = false;
  bool _publicProfile = true;
  bool _showOnline = true;

  @override
  void initState() {
    super.initState();
    BlockController.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    BlockController.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter()),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: _textDark,
      ),
    );
  }

  void _showDialog({
    required String title,
    required IconData icon,
    required Widget child,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: _grad,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              child,
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _divider),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              color: _textMid,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: onConfirm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: _grad,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Save',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon, {
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _divider),
          ),
          child: TextField(
            controller: ctrl,
            obscureText: obscure,
            style: GoogleFonts.inter(fontSize: 14, color: _textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: _textLight, fontSize: 13),
              prefixIcon: Icon(icon, size: 18, color: _primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final blockedCount = BlockController.instance.count;
    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        decoration: const BoxDecoration(gradient: _pageBg),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  border: Border(
                    bottom: BorderSide(color: _divider.withOpacity(0.5)),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _primary.withOpacity(0.1),
                                  _green.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: _primary.withOpacity(0.2),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: _primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Settings',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),

              // ── Gradient Banner ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                decoration: const BoxDecoration(gradient: _grad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manage your account & preferences.',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  children: [
                    // ── Account ──
                    _sectionHeader(Icons.person_rounded, 'Account'),
                    const SizedBox(height: 10),
                    _card([
                      _tile(
                        Icons.email_rounded,
                        _primary,
                        'Change Email',
                        'user@example.com',
                        onTap: () => _showDialog(
                          title: 'Change Email',
                          icon: Icons.email_rounded,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _dialogField(
                                TextEditingController(text: 'user@example.com'),
                                'New Email',
                                'Enter new email',
                                Icons.email_outlined,
                              ),
                              const SizedBox(height: 12),
                              _dialogField(
                                TextEditingController(),
                                'Current Password',
                                'Enter password',
                                Icons.lock_outline_rounded,
                                obscure: true,
                              ),
                            ],
                          ),
                          onConfirm: () {
                            Navigator.pop(context);
                            _toast('✅ Email updated successfully!');
                          },
                        ),
                      ),
                      _div(),
                      _tile(
                        Icons.lock_rounded,
                        _purple,
                        'Change Password',
                        'Last changed 3 months ago',
                        onTap: () => _showDialog(
                          title: 'Change Password',
                          icon: Icons.lock_rounded,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _dialogField(
                                TextEditingController(),
                                'Current Password',
                                'Enter current password',
                                Icons.lock_outline_rounded,
                                obscure: true,
                              ),
                              const SizedBox(height: 12),
                              _dialogField(
                                TextEditingController(),
                                'New Password',
                                'Min 8 characters',
                                Icons.lock_rounded,
                                obscure: true,
                              ),
                              const SizedBox(height: 12),
                              _dialogField(
                                TextEditingController(),
                                'Confirm Password',
                                'Repeat new password',
                                Icons.lock_rounded,
                                obscure: true,
                              ),
                            ],
                          ),
                          onConfirm: () {
                            Navigator.pop(context);
                            _toast('✅ Password changed!');
                          },
                        ),
                      ),
                      _div(),
                      _tile(
                        Icons.phone_rounded,
                        _green,
                        'Phone Number',
                        '+20 112 345 6789',
                        onTap: () => _showDialog(
                          title: 'Change Phone',
                          icon: Icons.phone_rounded,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _dialogField(
                                TextEditingController(text: '+20 112 345 6789'),
                                'Phone Number',
                                '+20 1XX XXX XXXX',
                                Icons.phone_outlined,
                              ),
                              const SizedBox(height: 12),
                              _dialogField(
                                TextEditingController(),
                                'Verification Code',
                                'Enter OTP',
                                Icons.verified_rounded,
                              ),
                            ],
                          ),
                          onConfirm: () {
                            Navigator.pop(context);
                            _toast('✅ Phone updated!');
                          },
                        ),
                      ),
                      _div(),
                      _tile(
                        Icons.language_rounded,
                        _warning,
                        'Language',
                        'English',
                        onTap: () =>
                            _toast('🌐 Language settings coming soon!'),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // ── Notifications ──
                    _sectionHeader(
                      Icons.notifications_rounded,
                      'Notifications',
                    ),
                    const SizedBox(height: 10),
                    _card([
                      _toggle(
                        Icons.event_available_rounded,
                        _primary,
                        'Session Updates',
                        'Confirmations & reminders',
                        _notifSessions,
                        (v) => setState(() => _notifSessions = v),
                      ),
                      _div(),
                      _toggle(
                        Icons.chat_bubble_rounded,
                        _green,
                        'New Messages',
                        'When someone messages you',
                        _notifMessages,
                        (v) => setState(() => _notifMessages = v),
                      ),
                      _div(),
                      _toggle(
                        Icons.star_rounded,
                        _warning,
                        'Review Notifications',
                        'When someone reviews you',
                        _notifReviews,
                        (v) => setState(() => _notifReviews = v),
                      ),
                      _div(),
                      _toggle(
                        Icons.campaign_rounded,
                        const Color(0xFFEC4899),
                        'Marketing & Promotions',
                        'Special offers and updates',
                        _notifMarketing,
                        (v) => setState(() => _notifMarketing = v),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // ── Privacy & Safety (with 🆕 Blocked Users) ──
                    _sectionHeader(Icons.shield_rounded, 'Privacy & Safety'),
                    const SizedBox(height: 10),
                    _card([
                      _blockedUsersTile(blockedCount),
                      _div(),
                      _toggle(
                        Icons.public_rounded,
                        _primary,
                        'Public Profile',
                        'Anyone can view your profile',
                        _publicProfile,
                        (v) => setState(() => _publicProfile = v),
                      ),
                      _div(),
                      _toggle(
                        Icons.circle,
                        _success,
                        'Show Online Status',
                        'Let others see when you\'re active',
                        _showOnline,
                        (v) => setState(() => _showOnline = v),
                      ),
                      _div(),
                      _toggle(
                        Icons.fingerprint_rounded,
                        _purple,
                        'Biometric Login',
                        'Use fingerprint or Face ID',
                        _biometric,
                        (v) => setState(() => _biometric = v),
                      ),
                      _div(),
                      _tile(
                        Icons.security_rounded,
                        _green,
                        'Two-Factor Authentication',
                        'Add extra security',
                        onTap: () => _toast('🔒 2FA coming soon!'),
                      ),
                      _div(),
                      _tile(
                        Icons.download_rounded,
                        _primary,
                        'Download My Data',
                        'Export your account data',
                        onTap: () => _toast('📦 Data export submitted!'),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // ── Appearance ──
                    _sectionHeader(Icons.palette_rounded, 'Appearance'),
                    const SizedBox(height: 10),
                    _card([
                      _toggle(
                        Icons.dark_mode_rounded,
                        _textDark,
                        'Dark Mode',
                        'Switch to dark theme',
                        _darkMode,
                        (v) => setState(() {
                          _darkMode = v;
                          _toast('🌙 Dark mode coming soon!');
                        }),
                      ),
                      _div(),
                      _tile(
                        Icons.text_fields_rounded,
                        _primary,
                        'Text Size',
                        'Medium',
                        onTap: () => _toast('🔤 Text size coming soon!'),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // ── About ──
                    _sectionHeader(Icons.info_rounded, 'About'),
                    const SizedBox(height: 10),
                    _card([
                      _tile(
                        Icons.new_releases_rounded,
                        _primary,
                        'App Version',
                        'v1.0.0',
                        showArrow: false,
                      ),
                      _div(),
                      _tile(
                        Icons.description_rounded,
                        _textMid,
                        'Terms of Service',
                        null,
                        onTap: () => _toast('📄 Opening Terms...'),
                      ),
                      _div(),
                      _tile(
                        Icons.privacy_tip_rounded,
                        _textMid,
                        'Privacy Policy',
                        null,
                        onTap: () => _toast('🔐 Opening Privacy Policy...'),
                      ),
                      _div(),
                      _tile(
                        Icons.rate_review_rounded,
                        _warning,
                        'Rate the App',
                        'Enjoying SkillBridge?',
                        onTap: () => _toast('⭐ Opening rating...'),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // ── Danger Zone ──
                    _sectionHeader(
                      Icons.warning_rounded,
                      'Danger Zone',
                      isRed: true,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _danger.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: _danger.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _tile(
                            Icons.block_rounded,
                            _danger,
                            'Deactivate Account',
                            'Temporarily disable your account',
                            titleColor: _danger,
                            onTap: () => _toast('⚠️ Deactivation coming soon!'),
                          ),
                          _div(),
                          _tile(
                            Icons.delete_forever_rounded,
                            _danger,
                            'Delete Account',
                            'Permanently delete all your data',
                            titleColor: _danger,
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                title: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _danger.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.delete_forever_rounded,
                                        color: _danger,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Delete Account',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Text(
                                  'This will permanently delete your account. This cannot be undone.',
                                  style: GoogleFonts.inter(
                                    color: _textMid,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.inter(color: _textMid),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      _toast('Account deletion submitted.');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _danger,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Delete',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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

  // 🆕 Blocked Users tile with red badge
  Widget _blockedUsersTile(int count) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BlockedAccountsPage()),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.block_rounded,
                  size: 18,
                  color: _danger,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Blocked Users',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      count == 0
                          ? 'No blocked users'
                          : '$count user${count > 1 ? "s" : ""} blocked',
                      style: GoogleFonts.inter(fontSize: 12, color: _textLight),
                    ),
                  ],
                ),
              ),
              if (count > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _danger,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: _textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, {bool isRed = false}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: isRed
                ? const LinearGradient(colors: [_danger, Color(0xFFFF6B6B)])
                : const LinearGradient(
                    colors: [Color(0xFF1E40AF), Color(0xFF059669)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 16, color: isRed ? _danger : _primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isRed ? _danger : _textDark,
          ),
        ),
      ],
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _divider.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _tile(
    IconData icon,
    Color iconColor,
    String title,
    String? subtitle, {
    VoidCallback? onTap,
    bool showArrow = true,
    Color? titleColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? _textDark,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _textLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showArrow && onTap != null)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: _textLight,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggle(
    IconData icon,
    Color iconColor,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 12, color: _textLight),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: _primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: _divider,
          ),
        ],
      ),
    );
  }

  Widget _div() => Container(
    height: 1,
    margin: const EdgeInsets.only(left: 68),
    color: _divider.withOpacity(0.6),
  );
}

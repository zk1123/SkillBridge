import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bottomnavbar.dart';
import 'notifications_controller.dart';
import 'wallet_controller.dart';
import 'subscriptions_controller.dart';
import 'live_invite_controller.dart';
import 'live_invite_sheet.dart';
import 'create_live_session_sheet.dart';
import 'chat_page_ui.dart';
import 'sessions_controller.dart';

// ═══════════════════════════════════════════════════════════════════
//  COLORS
// ═══════════════════════════════════════════════════════════════════

class AppColors {
  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1E40AF);
  static const green = Color(0xFF059669);
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
  static const purple = Color(0xFF7C3AED);
}

class AppGradients {
  static const pageBackground = LinearGradient(
    colors: [Color(0xFFEEF2FF), Color(0xFFDBEAFE), Color(0xFFD1FAE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );
  static const primary = LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const live = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

// ═══════════════════════════════════════════════════════════════════
//  Sessions Page
// ═══════════════════════════════════════════════════════════════════

class SessionsPage extends StatefulWidget {
  /// 🆕 Current user (for live invites)
  final String currentUserName;
  final String currentUserImage;
  final String currentUserId;

  const SessionsPage({
    super.key,
    this.currentUserName = 'You',
    this.currentUserImage = '',
    this.currentUserId = 'me',
  });

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _ctrl = SessionsController.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _ctrl.addListener(() => setState(() {}));
    LiveInviteController.instance.addListener(_onInvitesChanged);

    // Check for any pending invite when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkInvitesForMe());
  }

  @override
  void dispose() {
    LiveInviteController.instance.removeListener(_onInvitesChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onInvitesChanged() {
    if (!mounted) return;
    setState(() {});
    _checkInvitesForMe();
  }

  void _checkInvitesForMe() {
    final myInvites = LiveInviteController.instance.pending
        .where((inv) => inv.studentId == widget.currentUserId)
        .toList();
    if (myInvites.isNotEmpty) {
      LiveInviteSheet.show(context, myInvites.first);
    }
  }

  String _initials(String name) =>
      name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase();

  void _showToast(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter()),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: color ?? AppColors.textDark,
      ),
    );
  }

  // 🆕 Open the Create Live Session sheet
  void _openCreateLiveSession() {
    final accepted = _ctrl.accepted;
    final students = accepted
        .map(
          (s) => AcceptedStudent(
            id: s.id,
            name: s.name,
            imageUrl: s.avatarUrl,
            subject: s.subject,
          ),
        )
        .toList();

    if (students.isEmpty) {
      _showToast(
        '⚠️ You need accepted sessions before inviting students',
        color: AppColors.warning,
      );
      return;
    }

    CreateLiveSessionSheet.show(
      context,
      mentorName: widget.currentUserName,
      mentorImage: widget.currentUserImage,
      students: students,
    );
  }

  // 🆕 Open chat with the accepted person
  // Uses slugified name as userId so reviews link to the right profile.
  // e.g. "Mohamed Nukbassy" → "mohamed_nukbassy"
  void _openChat(Session session) {
    final userId = session.name.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      '_',
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          userId: userId,
          name: session.name,
          imageUrl: session.avatarUrl,
          avatarText: _initials(session.name),
          isOnline: true,
        ),
      ),
    );
  }

  // ── Reschedule Dialog ──
  Future<void> _showRescheduleDialog(Session session) async {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.event_repeat_rounded,
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
                            'Reschedule Session',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'with ${session.name}',
                            style: GoogleFonts.inter(
                              color: AppColors.textMid,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final p = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (p != null) setS(() => selectedDate = p);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: GoogleFonts.inter(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final p = await showTimePicker(
                      context: ctx,
                      initialTime: selectedTime,
                    );
                    if (p != null) setS(() => selectedTime = p);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          selectedTime.format(ctx),
                          style: GoogleFonts.inter(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(
                                color: AppColors.textMid,
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
                        onTap: () {
                          const months = [
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
                          final newDate =
                              '${months[selectedDate.month]} ${selectedDate.day}, ${selectedDate.year} | ${selectedTime.format(ctx)}';
                          _ctrl.reschedule(session, newDate);
                          Navigator.pop(ctx);
                          _showToast(
                            '📅 Session rescheduled with ${session.name}!',
                            color: AppColors.success,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: AppGradients.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Confirm',
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
      ),
    );
  }

  Future<bool> _confirmAction(
    String title,
    String message,
    String confirmLabel,
    Color confirmColor,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: confirmColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: confirmColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textMid,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Center(
                          child: Text(
                            'Keep',
                            style: GoogleFonts.inter(
                              color: AppColors.textMid,
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
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: confirmColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            confirmLabel,
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
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final acceptedCount = _ctrl.accepted.length;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.pageBackground),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSessionList(_ctrl.upcoming, isUpcoming: true),
                    _buildSessionList(_ctrl.past, isUpcoming: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // 🆕 Floating Action Button - the "+" icon
      floatingActionButton: GestureDetector(
        onTap: _openCreateLiveSession,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: acceptedCount > 0
                ? AppGradients.live
                : AppGradients.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:
                    (acceptedCount > 0 ? AppColors.success : AppColors.primary)
                        .withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 36),
              if (acceptedCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.success, width: 1.5),
                    ),
                    child: Text(
                      '$acceptedCount',
                      style: GoogleFonts.inter(
                        color: AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
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

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        border: Border(
          bottom: BorderSide(color: AppColors.divider.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => appScaffoldKey.currentState?.openDrawer(),
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
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.menu_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const SkillBridgeLogo(fontSize: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final pendingCount = _ctrl.upcoming
        .where((s) => s.status == SessionStatus.pending)
        .length;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppGradients.primary),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Sessions',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_ctrl.upcoming.length} upcoming • ${_ctrl.past.length} past',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (pendingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$pendingCount Pending',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMid,
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        tabs: const [
          Tab(text: 'Upcoming'),
          Tab(text: 'Past'),
        ],
      ),
    );
  }

  Widget _buildSessionList(List<Session> sessions, {required bool isUpcoming}) {
    if (sessions.isEmpty) {
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
                Icons.event_busy_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'No upcoming sessions' : 'No past sessions',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isUpcoming
                  ? 'Book a session to get started!'
                  : 'Your completed sessions will appear here',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      itemCount: sessions.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildSessionCard(sessions[i]),
      ),
    );
  }

  Widget _buildSessionCard(Session session) {
    final isPending = session.status == SessionStatus.pending;
    final isConfirmed = session.status == SessionStatus.confirmed;
    final isCompleted = session.status == SessionStatus.completed;
    final isCancelled =
        session.status == SessionStatus.cancelled ||
        session.status == SessionStatus.rejected;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPending
              ? AppColors.warning.withOpacity(0.3)
              : isConfirmed
              ? AppColors.success.withOpacity(0.3)
              : AppColors.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _avatar(session.name, session.avatarUrl),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.name,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        session.subject,
                        style: GoogleFonts.inter(
                          color: AppColors.textMid,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _statusBadge(session.status),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  session.date,
                  style: GoogleFonts.inter(
                    color: AppColors.textMid,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (session.amount > 0 || session.source != PaymentSource.free)
            _paymentInfoRow(session),

          const SizedBox(height: 10),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: session.tags
                .map(
                  (t) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tag,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      t,
                      style: GoogleFonts.inter(
                        color: AppColors.tagText,
                        fontSize: 11,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (isPending) ...[
                _actionBtn(
                  label: 'Accept',
                  icon: Icons.check_rounded,
                  bg: AppColors.successBg,
                  textColor: const Color(0xFF065F46),
                  onTap: () {
                    _ctrl.accept(session);
                    _showToast(
                      '✅ Session confirmed with ${session.name}! You can now message them.',
                      color: AppColors.success,
                    );
                  },
                ),
                _actionBtn(
                  label: 'Reschedule',
                  icon: Icons.event_repeat_rounded,
                  bg: AppColors.warningBg,
                  textColor: const Color(0xFF92400E),
                  onTap: () => _showRescheduleDialog(session),
                ),
                _actionBtn(
                  label: 'Reject',
                  icon: Icons.close_rounded,
                  bg: AppColors.dangerBg,
                  textColor: const Color(0xFF991B1B),
                  onTap: () async {
                    final ok = await _confirmAction(
                      'Reject Session?',
                      session.amount > 0
                          ? 'EGP ${session.amount.toStringAsFixed(0)} will be refunded to your wallet.'
                          : session.source == PaymentSource.package
                          ? '1 session will be returned to your package.'
                          : 'This action cannot be undone.',
                      'Reject',
                      AppColors.danger,
                    );
                    if (ok) {
                      _ctrl.reject(session);
                      _showRefundToast(session);
                    }
                  },
                ),
              ],
              if (isConfirmed) ...[
                // 🆕 Message button - opens chat with the accepted person
                _actionBtn(
                  label: 'Message',
                  icon: Icons.chat_bubble_outline_rounded,
                  gradient: AppGradients.primary,
                  textColor: Colors.white,
                  onTap: () => _openChat(session),
                ),
                _actionBtn(
                  label: 'Reschedule',
                  icon: Icons.event_repeat_rounded,
                  bg: AppColors.warningBg,
                  textColor: const Color(0xFF92400E),
                  onTap: () => _showRescheduleDialog(session),
                ),
                _actionBtn(
                  label: 'Cancel',
                  icon: Icons.close_rounded,
                  bg: AppColors.dangerBg,
                  textColor: const Color(0xFF991B1B),
                  onTap: () async {
                    final ok = await _confirmAction(
                      'Cancel Session?',
                      session.amount > 0
                          ? 'EGP ${session.amount.toStringAsFixed(0)} will be refunded to your wallet.'
                          : session.source == PaymentSource.package
                          ? '1 session will be returned to your package.'
                          : 'This action cannot be undone.',
                      'Cancel Session',
                      AppColors.danger,
                    );
                    if (ok) {
                      _ctrl.cancel(session);
                      _showRefundToast(session);
                    }
                  },
                ),
              ],
              if (isCompleted)
                _actionBtn(
                  label: 'Leave Review',
                  icon: Icons.star_rounded,
                  gradient: AppGradients.primary,
                  textColor: Colors.white,
                  onTap: () => _showToast('⭐ Opening review form...'),
                ),
              if (isCancelled && session.refunded)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        session.source == PaymentSource.wallet
                            ? 'Refunded to wallet'
                            : 'Session returned to package',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentInfoRow(Session session) {
    IconData icon;
    String label;
    Color color;

    switch (session.source) {
      case PaymentSource.wallet:
        icon = Icons.account_balance_wallet_rounded;
        label = 'Paid EGP ${session.amount.toStringAsFixed(0)} from Wallet';
        color = AppColors.primary;
        break;
      case PaymentSource.package:
        icon = Icons.card_giftcard_rounded;
        label = 'Used 1 session from package';
        color = AppColors.purple;
        break;
      case PaymentSource.free:
        icon = Icons.celebration_rounded;
        label = 'Free Session';
        color = AppColors.success;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRefundToast(Session session) {
    String msg;
    Color color = AppColors.success;
    if (session.source == PaymentSource.wallet && session.amount > 0) {
      msg =
          '💰 EGP ${session.amount.toStringAsFixed(0)} refunded to your wallet';
    } else if (session.source == PaymentSource.package) {
      msg = '📦 1 session returned to your package';
    } else {
      msg = '❌ Session cancelled';
      color = AppColors.textDark;
    }
    _showToast(msg, color: color);
  }

  Widget _avatar(String name, String avatarUrl) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.tag,
      backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
      child: avatarUrl.isEmpty
          ? Text(
              _initials(name),
              style: GoogleFonts.inter(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            )
          : null,
    );
  }

  Widget _statusBadge(SessionStatus status) {
    late Color bg, fg;
    late String label;
    switch (status) {
      case SessionStatus.confirmed:
        bg = AppColors.successBg;
        fg = const Color(0xFF065F46);
        label = 'CONFIRMED';
        break;
      case SessionStatus.pending:
        bg = AppColors.warningBg;
        fg = const Color(0xFF92400E);
        label = 'PENDING';
        break;
      case SessionStatus.completed:
        bg = AppColors.tag;
        fg = AppColors.tagText;
        label = 'COMPLETED';
        break;
      case SessionStatus.cancelled:
        bg = AppColors.dangerBg;
        fg = const Color(0xFF991B1B);
        label = 'CANCELLED';
        break;
      case SessionStatus.rejected:
        bg = AppColors.dangerBg;
        fg = const Color(0xFF991B1B);
        label = 'REJECTED';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    Color? bg,
    LinearGradient? gradient,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: gradient == null ? bg : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'subscriptions_controller.dart';

class _SColors {
  static const Color primary  = Color(0xFF2563EB);
  static const Color green    = Color(0xFF059669);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMid  = Color(0xFF475569);
  static const Color textLight= Color(0xFF94A3B8);
  static const Color divider  = Color(0xFFE2E8F0);
  static const Color bg       = Color(0xFFEEF2FF);
  static const Color success  = Color(0xFF10B981);
  static const Color danger   = Color(0xFFEF4444);
  static const Color warning  = Color(0xFFF59E0B);
  static const Color purple   = Color(0xFF7C3AED);
  static const Color gold     = Color(0xFFFFD700);

  static const LinearGradient grad = LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pageBg = LinearGradient(
    colors: [Color(0xFFEEF2FF), Color(0xFFDBEAFE), Color(0xFFD1FAE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );
}

class MySubscriptionsPage extends StatefulWidget {
  const MySubscriptionsPage({super.key});
  @override
  State<MySubscriptionsPage> createState() => _MySubscriptionsPageState();
}

class _MySubscriptionsPageState extends State<MySubscriptionsPage> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _SColors.bg,
      body: Container(
        decoration: const BoxDecoration(gradient: _SColors.pageBg),
        child: SafeArea(child: ListenableBuilder(
          listenable: SubscriptionsController.instance,
          builder: (_, __) {
            final c = SubscriptionsController.instance;
            return Column(children: [

              // ── Top Bar ──
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  border: Border(bottom: BorderSide(color: _SColors.divider.withOpacity(0.5)))),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [_SColors.primary.withOpacity(0.1), _SColors.green.withOpacity(0.1)]),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: _SColors.primary.withOpacity(0.2))),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _SColors.primary))),
                  const SizedBox(width: 12),
                  Text('My Subscriptions',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: _SColors.textDark)),
                ]),
              ),

              // ── Hero Card ──
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: _SColors.grad,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: _SColors.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.3))),
                      child: const Icon(Icons.subscriptions_rounded, color: Colors.white, size: 22)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${c.totalCount} Active Subscriptions',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                      Text('Total spent: EGP ${c.totalSpent.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.85))),
                    ])),
                  ]),
                  const SizedBox(height: 16),
                  Container(height: 1, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 14),
                  Row(children: [
                    _heroStat('${c.coursesCount}', 'Courses', Icons.school_rounded),
                    Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
                    _heroStat('${c.packagesCount}', 'Packages', Icons.card_giftcard_rounded),
                    Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
                    _heroStat('${c.boostCount}', 'Boost Plans', Icons.rocket_launch_rounded),
                  ]),
                ]),
              ),

              // ── Tabs ──
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _SColors.divider.withOpacity(0.5))),
                child: TabBar(
                  controller: _tab,
                  indicator: BoxDecoration(
                    gradient: _SColors.grad,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: _SColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]),
                  dividerColor: Colors.transparent,
                  labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13),
                  labelColor: Colors.white,
                  unselectedLabelColor: _SColors.textMid,
                  tabs: [
                    Tab(text: '📚 Courses (${c.coursesCount})'),
                    Tab(text: '🎯 Packages (${c.packagesCount})'),
                    Tab(text: '⭐ Boost (${c.boostCount})'),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Tab content ──
              Expanded(child: TabBarView(controller: _tab, children: [
                _buildCoursesTab(c.courses),
                _buildPackagesTab(c.packages),
                _buildBoostTab(c.boostPlans),
              ])),
            ]);
          },
        )),
      ),
    );
  }

  Widget _heroStat(String value, String label, IconData icon) {
    return Expanded(child: Column(children: [
      Icon(icon, color: Colors.white.withOpacity(0.9), size: 16),
      const SizedBox(height: 6),
      Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
      Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withOpacity(0.85))),
    ]));
  }

  // ── COURSES TAB ──
  Widget _buildCoursesTab(List<Subscription> courses) {
    if (courses.isEmpty) {
      return _buildEmpty(Icons.school_rounded, 'No courses yet', 'Visit SkillStore to enroll in courses');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      itemCount: courses.length,
      itemBuilder: (_, i) => _courseCard(courses[i]),
    );
  }

  Widget _courseCard(Subscription c) {
    final progress = c.progress ?? 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _SColors.divider.withOpacity(0.7)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: c.imageUrl != null
                ? Image.network(c.imageUrl!, width: 56, height: 56, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 56, height: 56,
                      color: const Color(0xFFEFF6FF), child: const Icon(Icons.person, color: _SColors.primary)))
                : Container(width: 56, height: 56,
                    color: const Color(0xFFEFF6FF),
                    child: const Icon(Icons.school_rounded, color: _SColors.primary))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.title,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _SColors.textDark),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            if (c.instructor != null)
              Text(c.instructor!,
                style: GoogleFonts.inter(fontSize: 11, color: _SColors.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(gradient: _SColors.grad, borderRadius: BorderRadius.circular(20)),
              child: Text(c.subtitle,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))),
          ])),
        ]),
        const SizedBox(height: 14),

        // Progress bar
        Row(children: [
          Text('Progress',
            style: GoogleFonts.inter(fontSize: 11, color: _SColors.textMid, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('${(progress * 100).toStringAsFixed(0)}%',
            style: GoogleFonts.inter(fontSize: 12, color: _SColors.primary, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: _SColors.bg,
            valueColor: const AlwaysStoppedAnimation<Color>(_SColors.primary)),
        ),

        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.calendar_today_rounded, size: 12, color: _SColors.textLight),
          const SizedBox(width: 4),
          Text('Purchased ${SubscriptionsController.instance.timeAgo(c.purchaseDate)}',
            style: GoogleFonts.inter(fontSize: 10, color: _SColors.textLight)),
          const Spacer(),
          Text('EGP ${c.price.toStringAsFixed(0)}',
            style: GoogleFonts.inter(fontSize: 13, color: _SColors.success, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 12),

        // Continue button
        GestureDetector(
          onTap: () => _toast('▶️ Resume ${c.title}'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(gradient: _SColors.grad, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(progress > 0 ? 'Continue Learning' : 'Start Course',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            ])),
          ),
        ),
      ]),
    );
  }

  // ── PACKAGES TAB ──
  Widget _buildPackagesTab(List<Subscription> packages) {
    if (packages.isEmpty) {
      return _buildEmpty(Icons.card_giftcard_rounded, 'No packages yet', 'Browse SkillStore to find session packages');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      itemCount: packages.length,
      itemBuilder: (_, i) => _packageCard(packages[i]),
    );
  }

  Widget _packageCard(Subscription p) {
    final used = p.usedSessions ?? 0;
    final total = p.totalSessions ?? 1;
    final remaining = total - used;
    final usageRatio = used / total;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _SColors.purple.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: _SColors.purple.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [_SColors.purple, _SColors.primary],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
          child: Column(children: [
            Row(children: [
              Container(width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 20)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.title,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(p.subtitle,
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withOpacity(0.85))),
              ])),
            ]),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Usage stats
            Row(children: [
              Expanded(child: _packageStat('$used', 'Used', _SColors.warning)),
              Container(width: 1, height: 32, color: _SColors.divider),
              Expanded(child: _packageStat('$remaining', 'Remaining', _SColors.success)),
              Container(width: 1, height: 32, color: _SColors.divider),
              Expanded(child: _packageStat('$total', 'Total', _SColors.primary)),
            ]),
            const SizedBox(height: 14),
            // Progress
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: usageRatio,
                minHeight: 8,
                backgroundColor: _SColors.bg,
                valueColor: const AlwaysStoppedAnimation<Color>(_SColors.purple)),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Icon(Icons.calendar_today_rounded, size: 12, color: _SColors.textLight),
              const SizedBox(width: 4),
              Text('Purchased ${SubscriptionsController.instance.timeAgo(p.purchaseDate)}',
                style: GoogleFonts.inter(fontSize: 10, color: _SColors.textLight)),
              const Spacer(),
              Text('EGP ${p.price.toStringAsFixed(0)}',
                style: GoogleFonts.inter(fontSize: 13, color: _SColors.success, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _toast('📅 Book your next session'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_SColors.purple, _SColors.primary]),
                  borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text('Book Session',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _packageStat(String value, String label, Color color) {
    return Column(children: [
      Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.inter(fontSize: 10, color: _SColors.textLight)),
    ]);
  }

  // ── BOOST TAB ──
  Widget _buildBoostTab(List<Subscription> boostPlans) {
    if (boostPlans.isEmpty) {
      return _buildEmpty(Icons.rocket_launch_rounded, 'No boost plans yet', 'Boost your profile from SkillStore');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      itemCount: boostPlans.length,
      itemBuilder: (_, i) => _boostCard(boostPlans[i]),
    );
  }

  Widget _boostCard(Subscription b) {
    final daysLeft = b.expiryDate != null
        ? b.expiryDate!.difference(DateTime.now()).inDays
        : 30;
    final isActive = daysLeft > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _SColors.gold.withOpacity(0.4), width: 1.5),
        boxShadow: [BoxShadow(color: _SColors.gold.withOpacity(0.15), blurRadius: 14, offset: const Offset(0, 4))]),
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
          child: Row(children: [
            Container(width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(11)),
              child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b.title,
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
              Text(b.subtitle,
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withOpacity(0.9))),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? _SColors.success : _SColors.danger,
                borderRadius: BorderRadius.circular(20)),
              child: Text(isActive ? 'ACTIVE' : 'EXPIRED',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Days remaining
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _SColors.gold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _SColors.gold.withOpacity(0.3))),
              child: Row(children: [
                const Icon(Icons.timer_rounded, color: Color(0xFFB8860B), size: 18),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('$daysLeft days remaining',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFFB8860B))),
                  Text('Expires ${b.expiryDate != null ? "${b.expiryDate!.day}/${b.expiryDate!.month}/${b.expiryDate!.year}" : "soon"}',
                    style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFB8860B))),
                ])),
              ]),
            ),
            const SizedBox(height: 12),
            // Features
            if (b.features != null) ...b.features!.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded, color: _SColors.success, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(f,
                  style: GoogleFonts.inter(fontSize: 12, color: _SColors.textMid))),
              ]),
            )),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.calendar_today_rounded, size: 12, color: _SColors.textLight),
              const SizedBox(width: 4),
              Text('Activated ${SubscriptionsController.instance.timeAgo(b.purchaseDate)}',
                style: GoogleFonts.inter(fontSize: 10, color: _SColors.textLight)),
              const Spacer(),
              Text('EGP ${b.price.toStringAsFixed(0)}/mo',
                style: GoogleFonts.inter(fontSize: 13, color: _SColors.success, fontWeight: FontWeight.w800)),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _buildEmpty(IconData icon, String title, String subtitle) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 100, height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_SColors.primary.withOpacity(0.1), _SColors.green.withOpacity(0.1)]),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _SColors.primary.withOpacity(0.2))),
        child: Icon(icon, size: 50, color: _SColors.primary)),
      const SizedBox(height: 20),
      Text(title,
        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: _SColors.textDark)),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 13, color: _SColors.textMid, height: 1.5))),
      const SizedBox(height: 20),
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
          decoration: BoxDecoration(gradient: _SColors.grad, borderRadius: BorderRadius.circular(20)),
          child: Text('Browse SkillStore',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)))),
    ]));
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter()),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: _SColors.textDark,
    ));
  }
}
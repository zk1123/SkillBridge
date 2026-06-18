import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const _primary = Color(0xFF2563EB);
const _green = Color(0xFF059669);
const _textDark = Color(0xFF0F172A);
const _textMid = Color(0xFF475569);
const _textLight = Color(0xFF94A3B8);
const _divider = Color(0xFFE2E8F0);
const _bg = Color(0xFFEEF2FF);
const _gold = Color(0xFFFFD700);
const _success = Color(0xFF10B981);
const _warning = Color(0xFFF59E0B);
const _purple = Color(0xFF7C3AED);
const _danger = Color(0xFFEF4444);

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

class MyEarningsPage extends StatefulWidget {
  const MyEarningsPage({super.key});
  @override
  State<MyEarningsPage> createState() => _MyEarningsPageState();
}

class _MyEarningsPageState extends State<MyEarningsPage> {
  // Demo data
  final double _totalEarnings = 12450.0;
  final double _availableBalance = 8200.0;
  final double _pendingAmount = 1250.0;
  final double _withdrawnAmount = 3000.0;
  final int _totalSessions = 87;
  final int _activeStudents = 24;
  final double _averageRating = 4.9;
  final int _completionRate = 98;

  // 🆕 Selected month index for chart interactivity
  int _selectedMonthIdx = 5; // last month by default

  // Monthly chart data - extended with session counts and growth %
  final List<Map<String, dynamic>> _monthlyData = [
    {
      'month': 'Jun',
      'amount': 1200.0,
      'sessions': 8,
      'growth': 0.0,
      'color': Color(0xFF6366F1),
    }, // indigo
    {
      'month': 'Jul',
      'amount': 1850.0,
      'sessions': 12,
      'growth': 54.2,
      'color': Color(0xFF8B5CF6),
    }, // violet
    {
      'month': 'Aug',
      'amount': 2100.0,
      'sessions': 14,
      'growth': 13.5,
      'color': Color(0xFFEC4899),
    }, // pink
    {
      'month': 'Sep',
      'amount': 1650.0,
      'sessions': 11,
      'growth': -21.4,
      'color': Color(0xFFF59E0B),
    }, // amber
    {
      'month': 'Oct',
      'amount': 2400.0,
      'sessions': 16,
      'growth': 45.5,
      'color': Color(0xFF10B981),
    }, // emerald
    {
      'month': 'Nov',
      'amount': 3250.0,
      'sessions': 22,
      'growth': 35.4,
      'color': Color(0xFF2563EB),
    }, // blue
  ];

  // Recent sessions
  final List<Map<String, dynamic>> _recentSessions = [
    {
      'student': 'Omar Fathy',
      'image': 'https://i.pravatar.cc/150?img=14',
      'subject': 'Flutter Development',
      'date': 'Today, 3:00 PM',
      'amount': 240.0,
      'duration': '2h',
      'status': 'Completed',
    },
    {
      'student': 'Nada Sherif',
      'image': 'https://i.pravatar.cc/150?img=45',
      'subject': 'State Management',
      'date': 'Yesterday, 5:00 PM',
      'amount': 120.0,
      'duration': '1h',
      'status': 'Completed',
    },
    {
      'student': 'Hassan Ramzy',
      'image': 'https://i.pravatar.cc/150?img=16',
      'subject': 'Firebase Integration',
      'date': 'Nov 28, 2:00 PM',
      'amount': 360.0,
      'duration': '3h',
      'status': 'Completed',
    },
    {
      'student': 'Dina Samir',
      'image': 'https://i.pravatar.cc/150?img=43',
      'subject': 'API Design',
      'date': 'Nov 25, 4:00 PM',
      'amount': 240.0,
      'duration': '2h',
      'status': 'Pending',
    },
    {
      'student': 'Karim Nour',
      'image': 'https://i.pravatar.cc/150?img=13',
      'subject': 'Clean Architecture',
      'date': 'Nov 22, 1:00 PM',
      'amount': 120.0,
      'duration': '1h',
      'status': 'Completed',
    },
  ];

  // Top earning subjects
  final List<Map<String, dynamic>> _topSubjects = [
    {
      'name': 'Flutter Development',
      'sessions': 32,
      'earnings': 4800.0,
      'icon': Icons.phone_android_rounded,
      'color': _primary,
    },
    {
      'name': 'Firebase & Backend',
      'sessions': 24,
      'earnings': 3600.0,
      'icon': Icons.cloud_rounded,
      'color': _warning,
    },
    {
      'name': 'State Management',
      'sessions': 18,
      'earnings': 2160.0,
      'icon': Icons.architecture_rounded,
      'color': _purple,
    },
    {
      'name': 'API Integration',
      'sessions': 13,
      'earnings': 1890.0,
      'icon': Icons.api_rounded,
      'color': _green,
    },
  ];

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

  void _showWithdrawDialog() {
    final ctrl = TextEditingController();
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: _grad,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Withdraw Earnings',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: _textDark,
                        ),
                      ),
                      Text(
                        'Available: \$${_availableBalance.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Amount to withdraw',
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
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: _textDark,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: GoogleFonts.inter(
                      color: _textLight,
                      fontSize: 16,
                    ),
                    prefixText: '\$ ',
                    prefixStyle: GoogleFonts.inter(
                      color: _primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: _warning,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Withdrawals take 2-3 business days',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                      onTap: () {
                        Navigator.pop(context);
                        _toast('💰 Withdrawal request submitted!');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: _grad,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Withdraw',
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

  // 🆕 When user taps a month bar
  void _selectMonth(int idx) {
    HapticFeedback.lightImpact();
    setState(() => _selectedMonthIdx = idx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        decoration: const BoxDecoration(gradient: _pageBg),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ──
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  border: Border(
                    bottom: BorderSide(color: _divider.withOpacity(0.5)),
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
                              _primary.withOpacity(0.1),
                              _green.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: _primary.withOpacity(0.2)),
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
                      'My Earnings',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  children: [
                    // ── Total Earnings Hero Card ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: _grad,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.trending_up_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Total Earnings',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.85),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.arrow_upward_rounded,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '+18%',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '\$${_totalEarnings.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '+ \$1,250 from last month',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _heroStat(
                                'Available',
                                '\$${_availableBalance.toStringAsFixed(0)}',
                                Icons.account_balance_wallet_rounded,
                              ),
                              Container(
                                width: 1,
                                height: 36,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              _heroStat(
                                'Pending',
                                '\$${_pendingAmount.toStringAsFixed(0)}',
                                Icons.hourglass_top_rounded,
                              ),
                              Container(
                                width: 1,
                                height: 36,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              _heroStat(
                                'Withdrawn',
                                '\$${_withdrawnAmount.toStringAsFixed(0)}',
                                Icons.check_circle_rounded,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Withdraw Button ──
                    GestureDetector(
                      onTap: _showWithdrawDialog,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _success.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _success.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_success, _green],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Withdraw Earnings',
                              style: GoogleFonts.inter(
                                color: _success,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Stats Grid ──
                    _sectionHeader(Icons.bar_chart_rounded, 'Quick Stats'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            Icons.event_available_rounded,
                            _primary,
                            '$_totalSessions',
                            'Total Sessions',
                            '+12 this month',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            Icons.people_rounded,
                            _purple,
                            '$_activeStudents',
                            'Active Students',
                            '+5 new',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            Icons.star_rounded,
                            _gold,
                            _averageRating.toStringAsFixed(1),
                            'Avg. Rating',
                            'Top Rated ⭐',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            Icons.check_circle_rounded,
                            _success,
                            '$_completionRate%',
                            'Completion',
                            'Excellent rate',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── 🆕 INTERACTIVE Monthly Chart ──
                    _sectionHeader(Icons.timeline_rounded, 'Earnings Trend'),
                    const SizedBox(height: 12),
                    _buildInteractiveChart(),

                    const SizedBox(height: 24),

                    // ── Top Earning Subjects ──
                    _sectionHeader(
                      Icons.workspace_premium_rounded,
                      'Top Earning Skills',
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _divider.withOpacity(0.7)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: List.generate(_topSubjects.length, (i) {
                          final s = _topSubjects[i];
                          final isLast = i == _topSubjects.length - 1;
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: (s['color'] as Color)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        s['icon'] as IconData,
                                        size: 22,
                                        color: s['color'] as Color,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s['name'] as String,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: _textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${s['sessions']} sessions',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: _textLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${(s['earnings'] as double).toStringAsFixed(0)}',
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: _success,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'earned',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: _textLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                Container(
                                  height: 1,
                                  margin: const EdgeInsets.only(left: 74),
                                  color: _divider.withOpacity(0.6),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Recent Sessions ──
                    Row(
                      children: [
                        Expanded(
                          child: _sectionHeader(
                            Icons.history_rounded,
                            'Recent Sessions',
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _toast('📅 View all sessions'),
                          child: Text(
                            'View All',
                            style: GoogleFonts.inter(
                              color: _primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._recentSessions.map((s) => _sessionCard(s)),

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

  // ═══════════════════════════════════════════════════════════════
  //  🆕 INTERACTIVE CHART — pro look with selected month details
  // ═══════════════════════════════════════════════════════════════

  Widget _buildInteractiveChart() {
    final selected = _monthlyData[_selectedMonthIdx];
    final selectedColor = selected['color'] as Color;
    final selectedAmount = selected['amount'] as double;
    final selectedSessions = selected['sessions'] as int;
    final growth = selected['growth'] as double;
    final isPositive = growth >= 0;

    // Compute max for scaling
    final maxAmount = _monthlyData
        .map((e) => e['amount'] as double)
        .reduce((a, b) => a > b ? a : b);
    final avgAmount =
        _monthlyData.map((e) => e['amount'] as double).reduce((a, b) => a + b) /
        _monthlyData.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _divider.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Last 6 Months',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      size: 11,
                      color: _primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tap a bar',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: _primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 🆕 Selected month detail card (changes color with selection!)
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  selectedColor.withOpacity(0.12),
                  selectedColor.withOpacity(0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selectedColor.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Month icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [selectedColor, selectedColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: selectedColor.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      selected['month'] as String,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '\$${selectedAmount.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: _textDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_selectedMonthIdx > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: (isPositive ? _success : _danger)
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPositive
                                        ? Icons.arrow_upward_rounded
                                        : Icons.arrow_downward_rounded,
                                    size: 10,
                                    color: isPositive ? _success : _danger,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${isPositive ? "+" : ""}${growth.toStringAsFixed(1)}%',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isPositive ? _success : _danger,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.event_available_rounded,
                            size: 11,
                            color: _textMid,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$selectedSessions sessions',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: _textMid,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: _textLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '\$${(selectedAmount / selectedSessions).toStringAsFixed(0)}/session',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: _textMid,
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

          const SizedBox(height: 20),

          // 🆕 The interactive chart with Y-axis labels + grid + bars
          SizedBox(
            height: 216,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-axis labels
                SizedBox(
                  width: 36,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${maxAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: _textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${(maxAmount * 0.66).toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: _textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${(maxAmount * 0.33).toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: _textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$0',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: _textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18), // space for x-axis labels
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                // Chart area
                Expanded(
                  child: Stack(
                    children: [
                      // Grid lines
                      Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            4,
                            (_) => Container(
                              height: 1,
                              color: _divider.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      // Avg line (dashed-like)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom:
                            22 + ((avgAmount / maxAmount) * (200 - 22 - 18)),
                        child: Row(
                          children: List.generate(
                            40,
                            (i) => Expanded(
                              child: Container(
                                height: 1,
                                color: i.isEven
                                    ? _warning.withOpacity(0.5)
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Avg label — now on the LEFT to not overlap bars
                      Positioned(
                        left: 0,
                        bottom:
                            22 +
                            ((avgAmount / maxAmount) * (200 - 22 - 18)) -
                            8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _warning.withOpacity(0.5),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            'AVG',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              color: _warning,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      // Bars
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _monthlyData.asMap().entries.map((entry) {
                          final i = entry.key;
                          final d = entry.value;
                          final isSelected = i == _selectedMonthIdx;
                          final color = d['color'] as Color;
                          final heightRatio =
                              (d['amount'] as double) / maxAmount;
                          final barHeight = (200 - 18 - 8) * heightRatio;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => _selectMonth(i),
                              behavior: HitTestBehavior.opaque,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Amount label on top of selected bar
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      margin: const EdgeInsets.only(bottom: 4),
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: color.withOpacity(0.4),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '\$${(d['amount'] as double).toStringAsFixed(0)}',
                                        style: GoogleFonts.inter(
                                          fontSize: 9,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  // The bar
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeOutCubic,
                                    width: isSelected ? 32 : 22,
                                    height: barHeight,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isSelected
                                            ? [color, color.withOpacity(0.6)]
                                            : [
                                                color.withOpacity(0.35),
                                                color.withOpacity(0.18),
                                              ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: color.withOpacity(0.4),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Month label
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 250),
                                    style: GoogleFonts.inter(
                                      fontSize: isSelected ? 12 : 11,
                                      color: isSelected ? color : _textMid,
                                      fontWeight: isSelected
                                          ? FontWeight.w900
                                          : FontWeight.w600,
                                    ),
                                    child: Text(d['month'] as String),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🆕 Footer with summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _chartFooterStat(
                  'Total (6mo)',
                  '\$${_monthlyData.fold<double>(0, (s, d) => s + (d['amount'] as double)).toStringAsFixed(0)}',
                  _primary,
                ),
                Container(width: 1, height: 28, color: _divider),
                _chartFooterStat(
                  'Average',
                  '\$${avgAmount.toStringAsFixed(0)}',
                  _warning,
                ),
                Container(width: 1, height: 28, color: _divider),
                _chartFooterStat(
                  'Best Month',
                  '\$${maxAmount.toStringAsFixed(0)}',
                  _success,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartFooterStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: _textLight,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.85)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
        ],
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
            gradient: const LinearGradient(
              colors: [Color(0xFF1E40AF), Color(0xFF059669)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 16, color: _primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _textDark,
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
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: _textMid,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sessionCard(Map<String, dynamic> s) {
    final isPending = s['status'] == 'Pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _divider.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              s['image'] as String,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 48,
                height: 48,
                color: const Color(0xFFEFF6FF),
                child: const Icon(Icons.person, color: _primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s['student'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s['subject'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 11,
                      color: _textLight,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      s['date'] as String,
                      style: GoogleFonts.inter(fontSize: 10, color: _textLight),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s['duration'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: _primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${(s['amount'] as double).toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: _success,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPending
                      ? _warning.withOpacity(0.1)
                      : _success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  s['status'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isPending ? _warning : _success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

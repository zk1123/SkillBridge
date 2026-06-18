import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page_new.dart';
import 'register_page.dart';

// ═══════════════════════════════════════════════════════════════════
//  WELCOME PAGE — First screen of SkillBridge
// ═══════════════════════════════════════════════════════════════════

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _logoCtrl;
  late final AnimationController _contentCtrl;
  late final AnimationController _pulseCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _pulseAnim;

  // ─── Premium color palette ──────────────────────────────────────
  static const _navy = Color(0xFF0A1F44);
  static const _navyDk = Color(0xFF060F2C);
  static const _primary = Color(0xFF2563EB);
  static const _primaryDk = Color(0xFF1E40AF);
  static const _accent = Color(0xFF06B6D4); // Cyan accent
  static const _gold = Color(0xFFF59E0B);
  static const _green = Color(0xFF10B981);
  static const _purple = Color(0xFF8B5CF6);
  static const _textWhite = Color(0xFFFFFFFF);
  static const _textGray = Color(0xFFCBD5E1);
  static const _textMute = Color(0xFF94A3B8);

  static const _heroGrad = LinearGradient(
    colors: [_navyDk, _navy, _primaryDk],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const _btnGrad = LinearGradient(
    colors: [_primary, _accent, _green],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.85,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _logoScale = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn);

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeIn);
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic),
        );

    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _logoCtrl.dispose();
    _contentCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ─── Navigation handlers ────────────────────────────────────────
  void _onGetStarted() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  void _onLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = size.width * 0.55;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: _heroGrad),
        child: Stack(
          children: [
            // ═══════════════════════════════════════════════════════
            //  ANIMATED BACKGROUND SHAPES
            // ═══════════════════════════════════════════════════════
            AnimatedBuilder(
              animation: _bgCtrl,
              builder: (_, __) => CustomPaint(
                size: Size.infinite,
                painter: _FloatingShapesPainter(_bgCtrl.value),
              ),
            ),

            // Subtle dot pattern overlay
            CustomPaint(size: Size.infinite, painter: _DotPatternPainter()),

            // Dark gradient overlay at bottom for readability
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: size.height * 0.5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      _navyDk.withOpacity(0.6),
                      _navyDk,
                    ],
                  ),
                ),
              ),
            ),

            // ═══════════════════════════════════════════════════════
            //  CONTENT
            // ═══════════════════════════════════════════════════════
            SafeArea(
              child: Column(
                children: [
                  // Top brand badge
                  FadeTransition(
                    opacity: _contentFade,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _buildTopBadge(),
                    ),
                  ),

                  // Logo (centered in upper half)
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: _buildPremiumLogo(logoSize),
                        ),
                      ),
                    ),
                  ),

                  // Bottom content
                  Expanded(
                    flex: 5,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: FadeTransition(
                        opacity: _contentFade,
                        child: SingleChildScrollView(
                          child: _buildBottomContent(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TOP BADGE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTopBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: _green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: _green.withOpacity(0.6), blurRadius: 8),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'WELCOME TO SKILLBRIDGE',
              style: GoogleFonts.inter(
                color: _textWhite,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  PREMIUM LOGO — bigger, with pulsing glow and ring
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPremiumLogo(double size) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulsing glow
          Transform.scale(
            scale: _pulseAnim.value,
            child: Container(
              width: size * 1.6,
              height: size * 1.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _accent.withOpacity(0.25),
                    _primary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Inner subtle ring
          Container(
            width: size * 1.25,
            height: size * 1.25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
          ),

          // Decorative arc
          Transform.rotate(
            angle: _bgCtrl.value * 2 * math.pi,
            child: CustomPaint(
              size: Size(size * 1.15, size * 1.15),
              painter: _ArcPainter(),
            ),
          ),

          // Logo white container with shadow
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: _accent.withOpacity(0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(size * 0.1),
              child: ClipOval(
                child: Image.network(
                  'https://i.postimg.cc/PqSw4Tkc/final-logo.png',
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation(_primary),
                          strokeWidth: 3,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: _btnGrad,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.hub_rounded,
                      color: Colors.white,
                      size: size * 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  BOTTOM CONTENT — tagline + feature cards + buttons
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBottomContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bridge to your',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: _textWhite,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -1.0,
            ),
          ),
          ShaderMask(
            shaderCallback: (b) =>
                const LinearGradient(colors: [_accent, _green]).createShader(b),
            child: Text(
              'next skill.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                height: 1.1,
                letterSpacing: -1.0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Learn from real practitioners. Earn from your expertise.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: _textGray,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _featureCard(
                  icon: Icons.school_rounded,
                  color: _accent,
                  title: 'Learn',
                  subtitle: 'From experts',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _featureCard(
                  icon: Icons.attach_money_rounded,
                  color: _gold,
                  title: 'Earn',
                  subtitle: 'Your skills',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _featureCard(
                  icon: Icons.hub_rounded,
                  color: _green,
                  title: 'Connect',
                  subtitle: 'With peers',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _featureCard(
                  icon: Icons.trending_up_rounded,
                  color: _purple,
                  title: 'Grow',
                  subtitle: 'Your career',
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Primary button
          GestureDetector(
            onTap: _onGetStarted,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                gradient: _btnGrad,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Get Started',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Secondary button
          GestureDetector(
            onTap: _onLogin,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  'I Already Have an Account',
                  style: GoogleFonts.inter(
                    color: _textWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Terms
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 12, color: _textMute),
              const SizedBox(width: 5),
              Text(
                'By continuing, you agree to our ',
                style: GoogleFonts.inter(
                  color: _textMute,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Terms',
                style: GoogleFonts.inter(
                  color: _accent,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              color: _textWhite,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: _textMute,
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ANIMATED BACKGROUND SHAPES
// ═══════════════════════════════════════════════════════════════════
class _FloatingShapesPainter extends CustomPainter {
  final double t;
  _FloatingShapesPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final shapes = [
      _Shape(0.15, 0.20, 80, const Color(0xFF06B6D4), 0.12),
      _Shape(0.85, 0.15, 110, const Color(0xFF2563EB), 0.10),
      _Shape(0.10, 0.55, 130, const Color(0xFF8B5CF6), 0.08),
      _Shape(0.90, 0.50, 90, const Color(0xFF10B981), 0.12),
      _Shape(0.30, 0.80, 100, const Color(0xFFF59E0B), 0.06),
      _Shape(0.75, 0.85, 70, const Color(0xFF06B6D4), 0.10),
    ];

    for (final shape in shapes) {
      final offsetX = math.sin(t * 2 * math.pi + shape.x * 10) * 20;
      final offsetY = math.cos(t * 2 * math.pi + shape.y * 8) * 25;

      final center = Offset(
        size.width * shape.x + offsetX,
        size.height * shape.y + offsetY,
      );

      final glowPaint = Paint()
        ..color = shape.color.withOpacity(shape.opacity * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
      canvas.drawCircle(center, shape.radius * 1.3, glowPaint);

      final paint = Paint()
        ..color = shape.color.withOpacity(shape.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(center, shape.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_FloatingShapesPainter oldDelegate) => true;
}

class _Shape {
  final double x, y;
  final double radius;
  final Color color;
  final double opacity;
  _Shape(this.x, this.y, this.radius, this.color, this.opacity);
}

// ═══════════════════════════════════════════════════════════════════
//  DOT PATTERN BACKGROUND
// ═══════════════════════════════════════════════════════════════════
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.04);
    const gap = 30.0;
    for (double x = 0; x < size.width; x += gap) {
      for (double y = 0; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPatternPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════
//  ROTATING ARC AROUND LOGO
// ═══════════════════════════════════════════════════════════════════
class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final arc1Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFF06B6D4), Color(0xFF10B981)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi / 2.5,
      false,
      arc1Paint,
    );

    final arc2Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFF2563EB)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi / 2,
      math.pi / 2.5,
      false,
      arc2Paint,
    );

    final dotPaint = Paint()..color = const Color(0xFF06B6D4);
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) - math.pi / 4;
      final dotCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawCircle(dotCenter, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) => false;
}

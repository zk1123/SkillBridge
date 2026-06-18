import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _primary   = Color(0xFF2563EB);
const _green     = Color(0xFF059669);
const _textDark  = Color(0xFF0F172A);
const _textMid   = Color(0xFF475569);
const _textLight = Color(0xFF94A3B8);
const _divider   = Color(0xFFE2E8F0);
const _bg        = Color(0xFFEEF2FF);
const _tag       = Color(0xFFEFF6FF);
const _warning   = Color(0xFFF59E0B);
const _purple    = Color(0xFF7C3AED);
const _gold      = Color(0xFFFFD700);

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

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});
  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final _msgCtrl   = TextEditingController();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController(text: 'user@example.com');
  int? _expandedFaq;
  bool _msgSent = false;
  String _selectedTopic = 'Session Issue';

  final _faqs = [
    {'q': 'How does SkillBridge work?', 'a': 'SkillBridge connects learners with expert mentors for 1-on-1 sessions. Browse experts, book a session, pay securely, and start learning.'},
    {'q': 'How do I book a session?', 'a': 'Go to the Match or Feed page, find an expert, tap their profile, choose session duration, pick a date and time, then confirm your booking.'},
    {'q': 'How does payment work?', 'a': 'Session prices are shown per hour in Egyptian Pounds (EGP). Multi-hour bookings receive automatic discounts. Payment is held securely until the session is completed.'},
    {'q': 'Can I cancel or reschedule?', 'a': 'Yes — go to My Sessions, find your session, and tap Reschedule or Cancel. Cancellations 24+ hours before receive a full refund.'},
    {'q': 'How do I become a mentor?', 'a': 'Go to the Match page and switch to "I Want to Teach" mode. Complete your profile with your skills and hourly rate. Once approved, students can book you.'},
    {'q': 'How are reviews handled?', 'a': 'After each session, both parties can leave a review. Mentors with 4.9+ rating earn the Top Rated badge and appear first in search results.'},
    {'q': 'What is SkillStore?', 'a': 'SkillStore is our marketplace for courses, packages, and learning materials created by top mentors.'},
    {'q': 'How do I report a problem?', 'a': 'Use the contact form below or email us at support@skillbridge.app. We respond within 24 hours.'},
  ];

  final _policies = [
    {'icon': Icons.verified_user_rounded, 'color': _primary,  'title': 'Code of Conduct',        'summary': 'All users must treat each other with respect. Harassment or inappropriate content will result in immediate account suspension.'},
    {'icon': Icons.payments_rounded,      'color': _green,    'title': 'Payment & Refund Policy', 'summary': 'Payments are held securely until session completion. Refunds issued for cancellations 24h+ before the session.'},
    {'icon': Icons.privacy_tip_rounded,   'color': _purple,   'title': 'Privacy Policy',          'summary': 'We never sell your personal data. Your information is used only to connect you with mentors.'},
    {'icon': Icons.gavel_rounded,         'color': _warning,  'title': 'Terms of Service',        'summary': 'By using SkillBridge you agree to our terms. Accounts used for fraud will be permanently banned.'},
    {'icon': Icons.workspace_premium_rounded, 'color': _gold, 'title': 'VIP Membership',          'summary': 'VIP members get priority matching, unlimited bookings, exclusive SkillStore discounts, and top search placement.'},
  ];

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter()),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: _textDark,
    ));
  }

  @override
  void dispose() { _msgCtrl.dispose(); _nameCtrl.dispose(); _emailCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        decoration: const BoxDecoration(gradient: _pageBg),
        child: SafeArea(child: Column(children: [

          // ── Header ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              border: Border(bottom: BorderSide(color: _divider.withOpacity(0.5)))),
            child: Column(children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [_primary.withOpacity(0.1), _green.withOpacity(0.1)]),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: _primary.withOpacity(0.2))),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _primary))),
                const SizedBox(width: 12),
                Text('Help & Support', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
              ]),
              const SizedBox(height: 14),
            ]),
          ),

          // ── Gradient Banner ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            decoration: const BoxDecoration(gradient: _grad),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Help & Support', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
              const SizedBox(height: 6),
              Text('Policies, FAQ & contact our team.', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 13)),
            ]),
          ),

          Expanded(child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [

              // ── Quick Contact ──
              Row(children: [
                Expanded(child: _quickCard(Icons.chat_bubble_rounded, 'Live Chat', 'Avg. 5 min', _primary, () => _toast('💬 Opening live chat...'))),
                const SizedBox(width: 10),
                Expanded(child: _quickCard(Icons.email_rounded, 'Email Us', 'Within 24h', _green, () => _toast('📧 Opening email...'))),
                const SizedBox(width: 10),
                Expanded(child: _quickCard(Icons.phone_rounded, 'Call Us', '9AM – 6PM', _purple, () => _toast('📞 Calling support...'))),
              ]),

              const SizedBox(height: 24),

              // ── Policies ──
              _sectionTitle(Icons.gavel_rounded, 'Policies & Guidelines'),
              const SizedBox(height: 12),
              ..._policies.map((p) => _policyCard(p['icon'] as IconData, p['color'] as Color, p['title'] as String, p['summary'] as String)),

              const SizedBox(height: 24),

              // ── FAQ ──
              _sectionTitle(Icons.quiz_rounded, 'Frequently Asked Questions'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _divider.withOpacity(0.7)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))]),
                child: Column(children: List.generate(_faqs.length, (i) {
                  final faq = _faqs[i];
                  final isExpanded = _expandedFaq == i;
                  final isLast = i == _faqs.length - 1;
                  return Column(children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => setState(() => _expandedFaq = isExpanded ? null : i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(children: [
                            Container(width: 28, height: 28,
                              decoration: BoxDecoration(
                                gradient: isExpanded ? _grad : null,
                                color: isExpanded ? null : _tag,
                                borderRadius: BorderRadius.circular(8)),
                              child: Center(child: Text('${i + 1}',
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800,
                                  color: isExpanded ? Colors.white : _primary)))),
                            const SizedBox(width: 12),
                            Expanded(child: Text(faq['q']!,
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
                                color: isExpanded ? _primary : _textDark))),
                            Icon(isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                              color: isExpanded ? _primary : _textLight, size: 20),
                          ]),
                        ),
                      ),
                    ),
                    if (isExpanded)
                      Container(
                        margin: const EdgeInsets.fromLTRB(56, 0, 16, 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _tag, borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _primary.withOpacity(0.15))),
                        child: Text(faq['a']!, style: GoogleFonts.inter(fontSize: 13, color: _textMid, height: 1.6))),
                    if (!isLast)
                      Container(height: 1, margin: const EdgeInsets.only(left: 56), color: _divider.withOpacity(0.6)),
                  ]);
                })),
              ),

              const SizedBox(height: 24),

              // ── Contact Form ──
              _sectionTitle(Icons.support_agent_rounded, 'Send Us a Message'),
              const SizedBox(height: 12),
              _msgSent ? _successCard() : _contactForm(),
            ],
          )),
        ])),
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(children: [
      Container(width: 4, height: 18,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF059669)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          borderRadius: BorderRadius.circular(4))),
      const SizedBox(width: 10),
      Icon(icon, size: 16, color: _primary),
      const SizedBox(width: 6),
      Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
    ]);
  }

  Widget _quickCard(IconData icon, String label, String sub, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _divider),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))]),
        child: Column(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, color: color, size: 22)),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
          const SizedBox(height: 2),
          Text(sub, style: GoogleFonts.inter(fontSize: 10, color: _textLight)),
        ]),
      ),
    );
  }

  Widget _policyCard(IconData icon, Color color, String title, String summary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _divider.withOpacity(0.7)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 42, height: 42,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: color)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
          const SizedBox(height: 5),
          Text(summary, style: GoogleFonts.inter(fontSize: 12, color: _textMid, height: 1.5)),
        ])),
      ]),
    );
  }

  Widget _successCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _green.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: _green.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 4))]),
      child: Column(children: [
        Container(width: 64, height: 64,
          decoration: const BoxDecoration(gradient: _grad, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 32)),
        const SizedBox(height: 16),
        Text('Message Sent! 🎉', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark)),
        const SizedBox(height: 8),
        Text('Our support team will get back to you within 24 hours.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 13, color: _textMid, height: 1.5)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => setState(() { _msgSent = false; _msgCtrl.clear(); }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(gradient: _grad, borderRadius: BorderRadius.circular(20)),
            child: Text('Send Another Message', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)))),
      ]),
    );
  }

  Widget _contactForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _divider.withOpacity(0.7)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your Name', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
        const SizedBox(height: 6),
        _formField(_nameCtrl, 'Enter your name', Icons.person_outline_rounded),
        const SizedBox(height: 14),
        Text('Email Address', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
        const SizedBox(height: 6),
        _formField(_emailCtrl, 'your@email.com', Icons.email_outlined),
        const SizedBox(height: 14),
        Text('Topic', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _divider)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTopic, isExpanded: true,
              style: GoogleFonts.inter(fontSize: 14, color: _textDark),
              items: ['Session Issue', 'Payment Problem', 'Account Help', 'Technical Bug', 'Feature Request', 'Other']
                .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _selectedTopic = v!)))),
        const SizedBox(height: 14),
        Text('Message', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _divider)),
          child: TextField(
            controller: _msgCtrl, maxLines: 5,
            style: GoogleFonts.inter(fontSize: 14, color: _textDark),
            decoration: InputDecoration(
              hintText: 'Describe your issue or question...',
              hintStyle: GoogleFonts.inter(color: _textLight, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14)))),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            if (_msgCtrl.text.trim().isEmpty || _nameCtrl.text.trim().isEmpty) {
              _toast('⚠️ Please fill in all fields.');
              return;
            }
            setState(() => _msgSent = true);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(gradient: _grad, borderRadius: BorderRadius.circular(14)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('Send Message', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            ]))),
      ]),
    );
  }

  Widget _formField(TextEditingController ctrl, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _divider)),
      child: TextField(
        controller: ctrl,
        style: GoogleFonts.inter(fontSize: 14, color: _textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: _textLight, fontSize: 13),
          prefixIcon: Icon(icon, size: 18, color: _primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12))));
  }
}
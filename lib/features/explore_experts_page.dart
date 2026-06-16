// ═══════════════════════════════════════════════════════════════════
//  explore_experts_page.dart
//  Showcase page for Top-Rated experts only (4.9+ rating, no boost)
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'feed_page.dart' show ExpertProfilePage, ExpertData, ReviewData, BoostTier;
import 'favourites_controller.dart';
import 'payment_helper.dart';
import 'booking_helper.dart';

class _EColors {
  static const Color primary    = Color(0xFF2563EB);
  static const Color textDark   = Color(0xFF0F172A);
  static const Color textMid    = Color(0xFF475569);
  static const Color textLight  = Color(0xFF94A3B8);
  static const Color divider    = Color(0xFFE2E8F0);
  static const Color bg         = Color(0xFFEEF2FF);
  static const Color success    = Color(0xFF10B981);
  static const Color gold       = Color(0xFFFFD700);
  static const Color goldDark   = Color(0xFFB8860B);
  static const Color goldBg     = Color(0xFFFFFBEB);

  static const LinearGradient goldGrad = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static const LinearGradient richGoldGrad = LinearGradient(
    colors: [Color(0xFFFFE082), Color(0xFFFFD700), Color(0xFFFFB300), Color(0xFFB8860B)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient pageBg = LinearGradient(
    colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7), Color(0xFFFDE68A)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );
}

// ═══════════════════════════════════════════════════════════════════
//  Top-Rated Experts (4.9+ rating, NO boost subscription)
//  Uses ExpertData from feed_page so View Profile works seamlessly.
// ═══════════════════════════════════════════════════════════════════

const _topExperts = <ExpertData>[
  ExpertData(
    name: 'Mohamed Nukbassy', title: 'Senior Data Analyst',
    imageUrl: 'https://i.postimg.cc/9f0r3cSF/Mo-nakbas.jpg',
    rating: 5.0, reviews: 218, location: 'Cairo, Egypt',
    skills: ['Python', 'SQL', 'Tableau', 'ML'], available: true,
    level: 'Senior', specialization: 'Data Analysis',
    experienceYears: 3, isPaid: true, pricePerHourEGP: 475,
    completedSessions: 187,
    bio: 'Expert in Python & Tableau with experience helping 200+ students land data roles at top companies.',
    boost: BoostTier.none,
    reviewList: [
      ReviewData(reviewer: 'Ahmed Ali', reviewerImage: 'https://randomuser.me/api/portraits/men/11.jpg',
        comment: 'Amazing session! Explained pandas so clearly.',
        date: 'Apr 15, 2025', rating: 5.0),
      ReviewData(reviewer: 'Sara Mostafa', reviewerImage: 'https://randomuser.me/api/portraits/women/45.jpg',
        comment: 'Very professional and patient. Highly recommended.',
        date: 'Mar 28, 2025', rating: 5.0),
    ],
  ),
  ExpertData(
    name: 'Marwan Hussien', title: 'Senior Mobile Developer',
    imageUrl: 'https://i.postimg.cc/z3ZzXWGc/Marwan.webp',
    rating: 5.0, reviews: 450, location: 'Cairo, Egypt',
    skills: ['Flutter', 'Dart', 'Firebase', 'iOS'], available: true,
    level: 'Senior', specialization: 'Mobile Development',
    experienceYears: 8, isPaid: true, pricePerHourEGP: 600,
    completedSessions: 320,
    bio: 'Lead Flutter engineer with 8+ years building production apps. Passionate about clean architecture.',
    boost: BoostTier.none,
    reviewList: [
      ReviewData(reviewer: 'Nada Sherif', reviewerImage: 'https://randomuser.me/api/portraits/women/29.jpg',
        comment: 'Absolutely the best Flutter mentor I\'ve had.',
        date: 'Apr 18, 2025', rating: 5.0),
      ReviewData(reviewer: 'Omar Fathy', reviewerImage: 'https://randomuser.me/api/portraits/men/55.jpg',
        comment: 'Perfect session every time. Super knowledgeable.',
        date: 'Apr 1, 2025', rating: 5.0),
    ],
  ),
  ExpertData(
    name: 'Khaled Mansour', title: 'Cybersecurity Expert',
    imageUrl: 'https://randomuser.me/api/portraits/men/33.jpg',
    rating: 4.9, reviews: 167, location: 'Cairo, Egypt',
    skills: ['Pentesting', 'OWASP', 'Network Security'], available: true,
    level: 'Senior', specialization: 'Cybersecurity',
    experienceYears: 6, isPaid: true, pricePerHourEGP: 650,
    completedSessions: 178,
    bio: 'Certified ethical hacker with 6 years of experience. Specializes in penetration testing and network security.',
    boost: BoostTier.none,
    reviewList: [
      ReviewData(reviewer: 'Mostafa K.', reviewerImage: 'https://randomuser.me/api/portraits/men/41.jpg',
        comment: 'Top-tier security expert. His insights are invaluable.',
        date: 'Apr 22, 2025', rating: 5.0),
    ],
  ),
];

// ═══════════════════════════════════════════════════════════════════
//  EXPLORE EXPERTS PAGE
// ═══════════════════════════════════════════════════════════════════

class ExploreExpertsPage extends StatelessWidget {
  const ExploreExpertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _EColors.bg,
      body: Container(
        decoration: const BoxDecoration(gradient: _EColors.pageBg),
        child: SafeArea(child: Column(children: [

          // ── Top Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              border: Border(bottom: BorderSide(color: _EColors.divider.withOpacity(0.5)))),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [_EColors.gold.withOpacity(0.15), _EColors.goldDark.withOpacity(0.1)]),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: _EColors.gold.withOpacity(0.3))),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _EColors.goldDark))),
              const SizedBox(width: 12),
              Text('Explore Experts',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: _EColors.textDark)),
            ]),
          ),

          Expanded(child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
            children: [
              // Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: _EColors.richGoldGrad,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(color: _EColors.gold.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.4))),
                      child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 26)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Top-Rated Experts',
                        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                      const SizedBox(height: 2),
                      Text('Hand-picked by community ratings',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500)),
                    ])),
                  ]),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3))),
                    child: Row(children: [
                      const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text('All experts here have 4.9+ rating earned through real sessions — no paid promotions',
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600, height: 1.4))),
                    ]),
                  ),
                ]),
              ),

              const SizedBox(height: 18),

              // Stats Row
              Row(children: [
                Expanded(child: _statBox('${_topExperts.length}', 'Elite Experts', Icons.star_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _statBox('${_topExperts.fold(0, (sum, e) => sum + e.reviews)}',
                  'Total Reviews', Icons.reviews_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _statBox('${_topExperts.fold(0, (sum, e) => sum + e.completedSessions)}',
                  'Sessions Done', Icons.event_available_rounded)),
              ]),

              const SizedBox(height: 22),

              // Section Header
              Row(children: [
                Container(width: 4, height: 18,
                  decoration: BoxDecoration(gradient: _EColors.goldGrad, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 10),
                const Icon(Icons.workspace_premium_rounded, size: 18, color: _EColors.goldDark),
                const SizedBox(width: 6),
                Text('Meet the Best',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: _EColors.textDark)),
                const Spacer(),
                Text('${_topExperts.length} experts',
                  style: GoogleFonts.inter(fontSize: 12, color: _EColors.goldDark, fontWeight: FontWeight.w700)),
              ]),

              const SizedBox(height: 14),

              // Cards
              ..._topExperts.asMap().entries.map((entry) =>
                _TopExpertCard(expert: entry.value, rank: entry.key + 1)),

              const SizedBox(height: 20),

              // Footer Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _EColors.gold.withOpacity(0.3))),
                child: Row(children: [
                  Container(width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _EColors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(11)),
                    child: const Icon(Icons.tips_and_updates_rounded, color: _EColors.goldDark, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('How experts qualify',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: _EColors.textDark)),
                    const SizedBox(height: 2),
                    Text('Earned 4.9+ stars from real student sessions, no paid boost.',
                      style: GoogleFonts.inter(fontSize: 11, color: _EColors.textMid, height: 1.4)),
                  ])),
                ]),
              ),
            ],
          )),
        ])),
      ),
    );
  }

  Widget _statBox(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _EColors.gold.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: _EColors.gold.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Column(children: [
        Container(width: 32, height: 32,
          decoration: BoxDecoration(
            gradient: _EColors.goldGrad, borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: Colors.white, size: 16)),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: _EColors.goldDark)),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 10, color: _EColors.textMid, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TOP EXPERT CARD
// ═══════════════════════════════════════════════════════════════════

class _TopExpertCard extends StatefulWidget {
  final ExpertData expert;
  final int rank;
  const _TopExpertCard({required this.expert, required this.rank});

  @override
  State<_TopExpertCard> createState() => _TopExpertCardState();
}

class _TopExpertCardState extends State<_TopExpertCard> {

  void _toggleFavourite() {
    final e = widget.expert;
    final wasInFav = FavouritesController.instance.isFavourite(e.name);
    FavouritesController.instance.toggle(SavedExpert(
      name: e.name, title: e.title, imageUrl: e.imageUrl,
      location: e.location, level: e.level,
      specialization: e.specialization, rating: e.rating,
      pricePerHour: e.pricePerHourEGP, reviews: e.reviews,
      skills: e.skills, isPaid: e.isPaid));
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(!wasInFav ? '❤️ ${e.name} added to favourites!' : '💔 ${e.name} removed from favourites.'),
      behavior: SnackBarBehavior.floating, backgroundColor: _EColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16), duration: const Duration(seconds: 2),
    ));
  }

  void _bookSession() async {
    final e = widget.expert;
    final now = DateTime.now().add(const Duration(days: 1));
    final dateStr = '${now.day}/${now.month}/${now.year} | 10:00 AM • 1h';

    final booked = await showBookingDialog(
      context: context,
      mentorName: e.name,
      mentorImage: e.imageUrl,
      subject: e.specialization,
      date: dateStr,
      tags: e.skills.take(3).toList(),
      amount: e.pricePerHourEGP,
      isPaid: e.isPaid,
    );

    if (booked && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('🎉 Session request sent to ${e.name.split(' ').first}!'),
        backgroundColor: _EColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.expert;
    final isFav = FavouritesController.instance.isFavourite(e.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _EColors.gold.withOpacity(0.5), width: 1.5),
        boxShadow: [BoxShadow(color: _EColors.gold.withOpacity(0.18), blurRadius: 16, offset: const Offset(0, 5))]),
      child: Column(children: [
        // Rank banner
        Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            gradient: _EColors.richGoldGrad,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text('#${widget.rank} • Top Rated Expert',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.3)),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Stack(children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _EColors.gold, width: 3),
                    boxShadow: [BoxShadow(color: _EColors.gold.withOpacity(0.4), blurRadius: 14)]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(e.imageUrl, width: 70, height: 70, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 70, height: 70,
                        color: const Color(0xFFEFF6FF), child: const Icon(Icons.person, color: _EColors.primary)))),
                ),
                if (e.available)
                  Positioned(right: 2, bottom: 2,
                    child: Container(width: 16, height: 16,
                      decoration: BoxDecoration(color: _EColors.success, shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2)))),
              ]),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(e.name,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: _EColors.textDark))),
                  const Icon(Icons.workspace_premium_rounded, color: _EColors.gold, size: 20),
                ]),
                const SizedBox(height: 3),
                Text(e.title, style: GoogleFonts.inter(fontSize: 12, color: _EColors.primary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(gradient: _EColors.goldGrad, borderRadius: BorderRadius.circular(20)),
                    child: Text(e.level, style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
                  const SizedBox(width: 6),
                  const Icon(Icons.location_on_outlined, size: 12, color: _EColors.textLight),
                  const SizedBox(width: 3),
                  Expanded(child: Text(e.location, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 11, color: _EColors.textLight))),
                ]),
              ])),
              GestureDetector(
                onTap: _toggleFavourite,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: isFav ? Colors.red.withOpacity(0.1) : _EColors.bg,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: isFav ? Colors.red.withOpacity(0.3) : _EColors.divider)),
                  child: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 18, color: isFav ? Colors.red : _EColors.textLight),
                ),
              ),
            ]),

            const SizedBox(height: 16),

            // Rating bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _EColors.goldBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _EColors.gold.withOpacity(0.3))),
              child: Row(children: [
                Text(e.rating.toStringAsFixed(1),
                  style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: _EColors.goldDark)),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: List.generate(5, (i) => const Padding(
                    padding: EdgeInsets.only(right: 1),
                    child: Icon(Icons.star_rounded, size: 14, color: _EColors.gold)))),
                  const SizedBox(height: 2),
                  Text('${e.reviews} reviews',
                    style: GoogleFonts.inter(fontSize: 11, color: _EColors.goldDark, fontWeight: FontWeight.w600)),
                ]),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${e.completedSessions}',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: _EColors.goldDark)),
                  Text('sessions',
                    style: GoogleFonts.inter(fontSize: 10, color: _EColors.goldDark)),
                ]),
              ]),
            ),

            const SizedBox(height: 12),

            Wrap(spacing: 6, runSpacing: 6, children: e.skills.map((s) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _EColors.primary.withOpacity(0.15))),
                child: Text(s, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: _EColors.primary)))).toList()),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: _EColors.goldGrad, borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.attach_money_rounded, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text('EGP ${e.pricePerHourEGP.toStringAsFixed(0)} / hour',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
              ]),
            ),

            const SizedBox(height: 14),

            // Buttons — View Profile now opens ExpertProfilePage from feed_page
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ExpertProfilePage(user: e))),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: _EColors.bg, borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: _EColors.divider)),
                  child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.person_outline_rounded, size: 14, color: _EColors.primary),
                    const SizedBox(width: 5),
                    Text('View Profile', style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w700, color: _EColors.primary)),
                  ])),
                ),
              )),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: GestureDetector(
                onTap: e.available ? _bookSession : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    gradient: e.available ? _EColors.goldGrad : null,
                    color: e.available ? null : _EColors.divider,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: e.available
                        ? [BoxShadow(color: _EColors.gold.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 3))]
                        : []),
                  child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.calendar_month_rounded,
                      size: 14, color: e.available ? Colors.white : _EColors.textLight),
                    const SizedBox(width: 5),
                    Text(e.available ? 'Book Now' : 'Unavailable',
                      style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w800,
                        color: e.available ? Colors.white : _EColors.textLight)),
                  ])),
                ),
              )),
            ]),
          ]),
        ),
      ]),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'favourites_controller.dart';

const _primary   = Color(0xFF2563EB);
const _green     = Color(0xFF059669);
const _textDark  = Color(0xFF0F172A);
const _textMid   = Color(0xFF475569);
const _textLight = Color(0xFF94A3B8);
const _divider   = Color(0xFFE2E8F0);
const _bg        = Color(0xFFEEF2FF);
const _gold      = Color(0xFFFFD700);
const _success   = Color(0xFF10B981);

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

class SavedExpertsPage extends StatelessWidget {
  const SavedExpertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        decoration: const BoxDecoration(gradient: _pageBg),
        child: SafeArea(child: Column(children: [

          // ── Header ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              border: Border(bottom: BorderSide(color: _divider.withOpacity(0.5)))),
            child: Row(children: [
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
              Text('Saved Experts', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
            ]),
          ),

          // ── Gradient Banner ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            decoration: const BoxDecoration(gradient: _grad),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3))),
                  child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Saved Experts', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('Your favourite mentors in one place ❤️',
                    style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 12)),
                ])),
              ]),
            ]),
          ),

          // ── List ──
          Expanded(child: ListenableBuilder(
            listenable: FavouritesController.instance,
            builder: (_, __) {
              final experts = FavouritesController.instance.all;
              if (experts.isEmpty) {
                return _buildEmpty(context);
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                itemCount: experts.length,
                itemBuilder: (_, i) => _ExpertCard(expert: experts[i]),
              );
            },
          )),
        ])),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 100, height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_primary.withOpacity(0.1), _green.withOpacity(0.1)]),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _primary.withOpacity(0.2))),
        child: const Icon(Icons.favorite_border_rounded, size: 50, color: _primary)),
      const SizedBox(height: 20),
      Text('No Saved Experts Yet',
        style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          'Tap the heart icon ❤️ on any expert in the Match page to save them here.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 13, color: _textMid, height: 1.5))),
      const SizedBox(height: 24),
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          decoration: BoxDecoration(gradient: _grad, borderRadius: BorderRadius.circular(20)),
          child: Text('Find Experts',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)))),
    ]));
  }
}

// ═══════════════════════════════════════════════════════════════════
//  EXPERT CARD
// ═══════════════════════════════════════════════════════════════════

class _ExpertCard extends StatelessWidget {
  final SavedExpert expert;
  const _ExpertCard({required this.expert});

  @override
  Widget build(BuildContext context) {
    final isTopRated = expert.rating >= 4.9;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isTopRated ? _gold.withOpacity(0.4) : _divider.withOpacity(0.6)),
        boxShadow: [BoxShadow(
          color: isTopRated ? _gold.withOpacity(0.1) : Colors.black.withOpacity(0.04),
          blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            // Avatar
            Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(expert.imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 60, height: 60,
                    color: const Color(0xFFEFF6FF), child: const Icon(Icons.person, color: _primary)))),
              if (isTopRated)
                Positioned(top: -4, right: -4,
                  child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFB300)]),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)),
                    child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 12))),
            ]),
            const SizedBox(width: 12),
            // Info
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(expert.name,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 2),
              Text(expert.title,
                style: GoogleFonts.inter(fontSize: 12, color: _primary, fontWeight: FontWeight.w600),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.star_rounded, color: _gold, size: 14),
                const SizedBox(width: 3),
                Text(expert.rating.toStringAsFixed(1),
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
                const SizedBox(width: 4),
                Text('(${expert.reviews})', style: GoogleFonts.inter(fontSize: 11, color: _textLight)),
                const SizedBox(width: 10),
                const Icon(Icons.location_on_outlined, size: 12, color: _textLight),
                const SizedBox(width: 3),
                Expanded(child: Text(expert.location,
                  style: GoogleFonts.inter(fontSize: 11, color: _textLight),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ])),
            // Remove button
            GestureDetector(
              onTap: () {
                FavouritesController.instance.remove(expert.name);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${expert.name} removed from favourites'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: _textDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                ));
              },
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.favorite_rounded, color: Colors.red, size: 18)),
            ),
          ]),

          const SizedBox(height: 12),

          // Skills
          Wrap(spacing: 6, runSpacing: 6, children: expert.skills.take(4).map((s) =>
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _primary.withOpacity(0.15))),
              child: Text(s, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: _primary)),
            )).toList()),

          const SizedBox(height: 12),

          // Bottom: price + level + book button
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: expert.isPaid ? _primary.withOpacity(0.1) : _success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
              child: Text(
                expert.isPaid ? '\$${expert.pricePerHour.toInt()}/hr' : 'FREE',
                style: GoogleFonts.inter(
                  color: expert.isPaid ? _primary : _success,
                  fontSize: 11, fontWeight: FontWeight.w800))),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: _grad, borderRadius: BorderRadius.circular(20)),
              child: Text(expert.level,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
            const Spacer(),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('💬 Opening chat with ${expert.name}...'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: _primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.all(16),
              )),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(gradient: _grad, borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 13),
                  const SizedBox(width: 5),
                  Text('Message', style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'live_invite_controller.dart';
import 'live_session_page.dart';

const _primary   = Color(0xFF2563EB);
const _textDark  = Color(0xFF0F172A);
const _textMid   = Color(0xFF475569);
const _textLight = Color(0xFF94A3B8);
const _divider   = Color(0xFFE2E8F0);
const _danger    = Color(0xFFEF4444);
const _success   = Color(0xFF10B981);

const _grad = LinearGradient(
  colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF059669)],
  begin: Alignment.topLeft, end: Alignment.bottomRight);

class LiveInviteSheet {
  static Future<void> show(BuildContext context, LiveInvite invite) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _Sheet(invite: invite));
  }
}

class _Sheet extends StatefulWidget {
  final LiveInvite invite;
  const _Sheet({required this.invite});
  @override
  State<_Sheet> createState() => _SheetState();
}

class _SheetState extends State<_Sheet> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 50, height: 5,
          decoration: BoxDecoration(color: _divider, borderRadius: BorderRadius.circular(3))),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _danger,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: _danger.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, _) => Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4 + _pulse.value * 0.6),
                  shape: BoxShape.circle))),
            const SizedBox(width: 6),
            Text('LIVE INVITE',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5)),
          ]),
        ),

        const SizedBox(height: 20),

        AnimatedBuilder(
          animation: _pulse,
          builder: (_, _) {
            return Stack(alignment: Alignment.center, children: [
              Container(
                width: 120 + (_pulse.value * 20),
                height: 120 + (_pulse.value * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _success.withOpacity(0.2 * (1 - _pulse.value)))),
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _success, width: 3)),
                child: ClipOval(
                  child: widget.invite.mentorImage.isNotEmpty
                      ? Image.network(widget.invite.mentorImage, fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _fallback())
                      : _fallback()),
              ),
            ]);
          },
        ),

        const SizedBox(height: 16),
        Text(widget.invite.mentorName,
          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: _textDark)),
        const SizedBox(height: 4),
        Text('is inviting you to a live session',
          style: GoogleFonts.inter(fontSize: 13, color: _textMid, fontStyle: FontStyle.italic)),

        const SizedBox(height: 20),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _divider)),
          child: Row(children: [
            Container(width: 38, height: 38,
              decoration: BoxDecoration(color: _primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.topic_rounded, color: _primary, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('TOPIC',
                style: GoogleFonts.inter(fontSize: 10, color: _textLight, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
              Text(widget.invite.topic,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _success.withOpacity(0.3))),
              child: Row(children: [
                const Icon(Icons.timer_outlined, color: _success, size: 12),
                const SizedBox(width: 4),
                Text('${widget.invite.durationMinutes} min',
                  style: GoogleFonts.inter(color: _success, fontSize: 12, fontWeight: FontWeight.w800)),
              ]),
            ),
          ]),
        ),

        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(children: [
            Expanded(child: GestureDetector(
              onTap: _decline,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _danger, width: 2)),
                child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.close_rounded, color: _danger, size: 20),
                  const SizedBox(width: 6),
                  Text('Decline',
                    style: GoogleFonts.inter(color: _danger, fontSize: 14, fontWeight: FontWeight.w700)),
                ])),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: GestureDetector(
              onTap: _accept,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  gradient: _grad,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: _success.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]),
                child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.videocam_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text('Accept & Join Live',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                ])),
              ),
            )),
          ]),
        ),

        SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
      ]),
    );
  }

  Widget _fallback() {
    return Container(
      color: _primary.withOpacity(0.1),
      child: Center(child: Text(
        widget.invite.mentorName.isNotEmpty ? widget.invite.mentorName[0].toUpperCase() : '?',
        style: GoogleFonts.inter(color: _primary, fontWeight: FontWeight.w800, fontSize: 40))),
    );
  }

  void _decline() {
    LiveInviteController.instance.decline(widget.invite.id);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Declined ${widget.invite.mentorName}\'s invite', style: GoogleFonts.inter()),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: _textMid));
  }

  void _accept() {
    HapticFeedback.mediumImpact();
    LiveInviteController.instance.accept(widget.invite.id);
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => LiveSessionPage(
        sessionId: widget.invite.id,
        personName: widget.invite.mentorName,
        personImage: widget.invite.mentorImage,
        topic: widget.invite.topic,
        durationMinutes: widget.invite.durationMinutes,
        isMentor: false)));
  }
}
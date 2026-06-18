import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'leave_review_sheet.dart';

class LiveSessionPage extends StatefulWidget {
  final String   sessionId;
  final String   personName;
  final String?  personImage;
  final String?  avatarText;
  final String   topic;
  final int      durationMinutes;
  final bool     isMentor;
  // 🆕 The ID of the person being called (used to save the review for them)
  final String?  personId;

  const LiveSessionPage({
    super.key,
    required this.sessionId,
    required this.personName,
    this.personImage,
    this.avatarText,
    required this.topic,
    this.durationMinutes = 60,
    this.isMentor = false,
    this.personId,
  });

  @override
  State<LiveSessionPage> createState() => _LiveSessionPageState();
}

class _LiveSessionPageState extends State<LiveSessionPage> {
  bool _muted     = false;
  bool _cameraOff = false;
  bool _sharing   = false;
  bool _showCtrls = true;
  int  _elapsed   = 0;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _elapsed++);
      _tick();
    });
  }

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(children: [
        GestureDetector(
          onTap: () => setState(() => _showCtrls = !_showCtrls),
          child: Container(
            width: double.infinity, height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 140, height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF10B981), width: 3),
                  boxShadow: [BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.4),
                    blurRadius: 30, spreadRadius: 4)]),
                child: ClipOval(
                  child: widget.personImage != null && widget.personImage!.isNotEmpty
                      ? Image.network(widget.personImage!, fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _avatarFallback())
                      : _avatarFallback()),
              ),
              const SizedBox(height: 18),
              Text(widget.personName,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('LIVE',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ]),
              ),
            ])),
          ),
        ),

        Positioned(
          top: 60, right: 16,
          child: Container(
            width: 110, height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white24, width: 2)),
            child: Center(child: Icon(
              _cameraOff ? Icons.videocam_off_rounded : Icons.person_rounded,
              color: Colors.white54, size: _cameraOff ? 32 : 60)),
          ),
        ),

        if (_showCtrls)
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16, right: 16, bottom: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent])),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context)),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.topic,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  Row(children: [
                    const Icon(Icons.timer_outlined, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(_fmt(_elapsed), style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                  ]),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.wifi_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text('HD',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ]),
            ),
          ),

        if (_showCtrls)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: 20, left: 24, right: 24,
                bottom: MediaQuery.of(context).padding.bottom + 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent])),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _ctrlBtn(_muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  bg: _muted ? Colors.red : Colors.white24,
                  onTap: () => setState(() => _muted = !_muted)),
                _ctrlBtn(_cameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                  bg: _cameraOff ? Colors.red : Colors.white24,
                  onTap: () => setState(() => _cameraOff = !_cameraOff)),
                _ctrlBtn(Icons.screen_share_rounded,
                  bg: _sharing ? const Color(0xFF2563EB) : Colors.white24,
                  onTap: () => setState(() => _sharing = !_sharing)),
                _ctrlBtn(Icons.chat_bubble_outline_rounded, bg: Colors.white24, onTap: () {}),
                _ctrlBtn(Icons.call_end_rounded,
                  bg: Colors.red, size: 64, iconSize: 30, onTap: _confirmEnd),
              ]),
            ),
          ),
      ]),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: const Color(0xFF2563EB).withOpacity(0.3),
      child: Center(child: Text(
        widget.avatarText?.isNotEmpty == true
            ? widget.avatarText!
            : (widget.personName.isNotEmpty ? widget.personName[0].toUpperCase() : '?'),
        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 56))),
    );
  }

  Widget _ctrlBtn(IconData icon, {required Color bg, required VoidCallback onTap, double size = 56, double iconSize = 24}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: iconSize)),
    );
  }

  void _confirmEnd() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 56, height: 56,
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.call_end_rounded, color: Colors.red, size: 28)),
            const SizedBox(height: 14),
            Text('End Session?',
              style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Text('Are you sure you want to end this live session?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF475569))),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Center(child: Text('Cancel',
                    style: GoogleFonts.inter(color: const Color(0xFF475569), fontWeight: FontWeight.w600)))))),
              const SizedBox(width: 10),
              Expanded(child: GestureDetector(
                onTap: () async {
                  Navigator.pop(context);          // close confirm dialog
                  await _endCallAndShowReview();   // 🆕 show review sheet then exit
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text('End Call',
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)))))),
            ]),
          ]),
        ),
      ),
    );
  }

  // 🆕 End the call AND show the review sheet
  Future<void> _endCallAndShowReview() async {
    final callDuration = _elapsed;

    // Resolve userId (use personId if given, else slug from name)
    final userId = widget.personId ?? _slugify(widget.personName);

    // Show review sheet
    await LeaveReviewSheet.show(
      context,
      userId: userId,
      userName: widget.personName,
      userImage: widget.personImage,
      callDurationSeconds: callDuration,
    );

    if (!mounted) return;
    Navigator.pop(context); // close the live session page
  }

  /// "Mohamed Nukbassy" → "mohamed_nukbassy"
  String _slugify(String name) {
    return name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  }
}
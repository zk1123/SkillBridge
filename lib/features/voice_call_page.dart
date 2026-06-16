import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VoiceCallPage extends StatefulWidget {
  final String  personName;
  final String? personImage;
  final String? avatarText;

  const VoiceCallPage({
    super.key,
    required this.personName,
    this.personImage,
    this.avatarText,
  });

  @override
  State<VoiceCallPage> createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {
  bool _muted     = false;
  bool _speakerOn = false;
  bool _connected = false;
  int  _elapsed   = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _connected = true);
      _tick();
    });
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || !_connected) return;
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF059669)],
            begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            const SizedBox(height: 40),
            Text(_connected ? 'Voice Call' : 'Calling...',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 14, letterSpacing: 2.5)),
            const SizedBox(height: 12),
            if (_connected)
              Text(_fmt(_elapsed),
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(color: const Color(0xFF10B981), width: 4),
                boxShadow: [BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.4),
                  blurRadius: 30, spreadRadius: 6)]),
              child: ClipOval(
                child: widget.personImage != null && widget.personImage!.isNotEmpty
                    ? Image.network(widget.personImage!, fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _fallback())
                    : _fallback()),
            ),
            const SizedBox(height: 24),
            Text(widget.personName,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            const Spacer(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _btn(_muted ? Icons.mic_off_rounded : Icons.mic_rounded, _muted ? 'Unmute' : 'Mute',
                bg: _muted ? Colors.red : Colors.white24,
                onTap: () => setState(() => _muted = !_muted)),
              _btn(Icons.call_end_rounded, 'End',
                bg: Colors.red, size: 72, iconSize: 32,
                onTap: () => Navigator.pop(context)),
              _btn(_speakerOn ? Icons.volume_up_rounded : Icons.volume_down_rounded, 'Speaker',
                bg: _speakerOn ? const Color(0xFF10B981) : Colors.white24,
                onTap: () => setState(() => _speakerOn = !_speakerOn)),
            ]),
            const SizedBox(height: 40),
          ]),
        )),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFF1E40AF).withOpacity(0.3),
      child: Center(child: Text(
        widget.avatarText?.isNotEmpty == true
            ? widget.avatarText!
            : (widget.personName.isNotEmpty ? widget.personName[0].toUpperCase() : '?'),
        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 70))),
    );
  }

  Widget _btn(IconData icon, String label, {required Color bg, required VoidCallback onTap, double size = 60, double iconSize = 26}) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: iconSize))),
      const SizedBox(height: 8),
      Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
    ]);
  }
}
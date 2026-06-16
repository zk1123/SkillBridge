import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'live_invite_controller.dart';

const _primary   = Color(0xFF2563EB);
const _green     = Color(0xFF059669);
const _textDark  = Color(0xFF0F172A);
const _textMid   = Color(0xFF475569);
const _textLight = Color(0xFF94A3B8);
const _divider   = Color(0xFFE2E8F0);
const _bg        = Color(0xFFEEF2FF);
const _success   = Color(0xFF10B981);
const _successBg = Color(0xFFD1FAE5);

const _grad = LinearGradient(
  colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF059669)],
  begin: Alignment.topLeft, end: Alignment.bottomRight);

/// Student that can be invited (from accepted sessions)
class AcceptedStudent {
  final String  id;
  final String  name;
  final String? imageUrl;
  final String  subject;

  AcceptedStudent({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.subject,
  });
}

class CreateLiveSessionSheet {
  static Future<void> show(
    BuildContext context, {
    required String mentorName,
    required String mentorImage,
    required List<AcceptedStudent> students,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _Sheet(
        mentorName: mentorName,
        mentorImage: mentorImage,
        students: students));
  }
}

class _Sheet extends StatefulWidget {
  final String mentorName;
  final String mentorImage;
  final List<AcceptedStudent> students;

  const _Sheet({
    required this.mentorName,
    required this.mentorImage,
    required this.students,
  });

  @override
  State<_Sheet> createState() => _SheetState();
}

class _SheetState extends State<_Sheet> {
  final Set<String> _selected = {};
  final TextEditingController _topicCtrl = TextEditingController();
  int _duration = 60;

  @override
  void dispose() { _topicCtrl.dispose(); super.dispose(); }

  bool get _canSend => _topicCtrl.text.trim().isNotEmpty && _selected.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 50, height: 5,
            decoration: BoxDecoration(color: _divider, borderRadius: BorderRadius.circular(3))),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Row(children: [
              Container(width: 44, height: 44,
                decoration: BoxDecoration(gradient: _grad, borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: _green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]),
                child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Start Live Session',
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: _textDark)),
                Text('Invite students to join you live now',
                  style: GoogleFonts.inter(fontSize: 12, color: _textMid)),
              ])),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.close_rounded, size: 18, color: _textMid))),
            ]),
          ),
          Container(height: 1, color: _divider.withOpacity(0.5)),

          Expanded(child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            children: [
              Text('SESSION TOPIC',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: _textDark, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: _bg, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _divider)),
                child: TextField(
                  controller: _topicCtrl,
                  onChanged: (_) => setState(() {}),
                  style: GoogleFonts.inter(fontSize: 14, color: _textDark),
                  decoration: InputDecoration(
                    hintText: 'e.g. Flutter Q&A Session',
                    hintStyle: GoogleFonts.inter(color: _textLight, fontSize: 13),
                    prefixIcon: const Icon(Icons.topic_outlined, size: 18, color: _primary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12))),
              ),

              const SizedBox(height: 18),
              Text('DURATION',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: _textDark, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Row(children: [
                _durChip(30, '30 min'),
                const SizedBox(width: 8),
                _durChip(60, '1 hour'),
                const SizedBox(width: 8),
                _durChip(90, '1.5 hr'),
                const SizedBox(width: 8),
                _durChip(120, '2 hr'),
              ]),

              const SizedBox(height: 22),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('SELECT STUDENTS',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: _textDark, letterSpacing: 1.2)),
                if (widget.students.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() {
                      if (_selected.length == widget.students.length) {
                        _selected.clear();
                      } else {
                        _selected
                          ..clear()
                          ..addAll(widget.students.map((s) => s.id));
                      }
                    }),
                    child: Text(
                      _selected.length == widget.students.length ? 'Deselect All' : 'Select All',
                      style: GoogleFonts.inter(color: _primary, fontSize: 12, fontWeight: FontWeight.w800)),
                  ),
              ]),
              const SizedBox(height: 4),
              Text('Only students with accepted sessions',
                style: GoogleFonts.inter(fontSize: 11, color: _textLight, fontStyle: FontStyle.italic)),
              const SizedBox(height: 10),

              if (widget.students.isEmpty)
                _emptyStudents()
              else
                ...widget.students.map(_studentTile),
            ],
          )),

          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20,
                MediaQuery.of(context).viewInsets.bottom + 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: _divider.withOpacity(0.5))),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -3))]),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (_selected.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _successBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _success.withOpacity(0.3))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: _success),
                    const SizedBox(width: 5),
                    Text('${_selected.length} student${_selected.length > 1 ? "s" : ""} selected',
                      style: GoogleFonts.inter(fontSize: 11, color: _success, fontWeight: FontWeight.w800)),
                  ]),
                ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _canSend ? _send : null,
                child: Container(
                  width: double.infinity, height: 54,
                  decoration: BoxDecoration(
                    gradient: _canSend ? _grad : null,
                    color: _canSend ? null : _divider,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: _canSend ? [BoxShadow(color: _green.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 5))] : null),
                  child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.send_rounded, color: _canSend ? Colors.white : _textLight, size: 18),
                    const SizedBox(width: 8),
                    Text('Send Invites & Go Live',
                      style: GoogleFonts.inter(color: _canSend ? Colors.white : _textLight, fontSize: 15, fontWeight: FontWeight.w800)),
                  ])),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _durChip(int mins, String label) {
    final selected = _duration == mins;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _duration = mins),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? _grad : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? Colors.transparent : _divider, width: 1.5)),
        alignment: Alignment.center,
        child: Text(label,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700,
            color: selected ? Colors.white : _textMid)),
      ),
    ));
  }

  Widget _emptyStudents() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _bg, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _divider)),
      child: Column(children: [
        const Icon(Icons.person_off_rounded, size: 44, color: _textLight),
        const SizedBox(height: 10),
        Text('No accepted students yet',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
        const SizedBox(height: 4),
        Text('Students with accepted sessions will appear here',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 12, color: _textLight)),
      ]),
    );
  }

  Widget _studentTile(AcceptedStudent s) {
    final selected = _selected.contains(s.id);
    return GestureDetector(
      onTap: () => setState(() {
        if (selected) { _selected.remove(s.id); } else { _selected.add(s.id); }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? _success.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _success : _divider,
            width: selected ? 2 : 1)),
        child: Row(children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _primary.withOpacity(0.1),
            backgroundImage: s.imageUrl != null && s.imageUrl!.isNotEmpty
                ? NetworkImage(s.imageUrl!) : null,
            child: s.imageUrl == null || s.imageUrl!.isEmpty
                ? Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                    style: GoogleFonts.inter(color: _primary, fontWeight: FontWeight.w800, fontSize: 16))
                : null),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.name,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 3),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: _successBg, borderRadius: BorderRadius.circular(4)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.check_circle_rounded, size: 9, color: _success),
                  const SizedBox(width: 3),
                  Text('Accepted',
                    style: GoogleFonts.inter(color: _success, fontSize: 9, fontWeight: FontWeight.w800)),
                ]),
              ),
              const SizedBox(width: 6),
              Expanded(child: Text(s.subject,
                style: GoogleFonts.inter(fontSize: 11, color: _textMid),
                overflow: TextOverflow.ellipsis)),
            ]),
          ])),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: selected ? _success : Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: selected ? _success : _textLight, width: 2)),
            child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null),
        ]),
      ),
    );
  }

  void _send() {
    for (final id in _selected) {
      final student = widget.students.firstWhere((s) => s.id == id);
      LiveInviteController.instance.send(
        mentorName: widget.mentorName,
        mentorImage: widget.mentorImage,
        studentId: id,
        studentName: student.name,
        studentImage: student.imageUrl ?? '',
        topic: _topicCtrl.text.trim(),
        durationMinutes: _duration,
      );
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.send_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('Invites Sent!',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
          Text('${_selected.length} student${_selected.length > 1 ? "s" : ""} notified',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
        ])),
      ]),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: _success,
      duration: const Duration(seconds: 3)));
  }
}
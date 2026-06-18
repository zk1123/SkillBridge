import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reviews_controller.dart';

const _primary    = Color(0xFF2563EB);
const _green      = Color(0xFF059669);
const _textDark   = Color(0xFF0F172A);
const _textMid    = Color(0xFF475569);
const _textLight  = Color(0xFF94A3B8);
const _divider    = Color(0xFFE2E8F0);
const _bg         = Color(0xFFEEF2FF);
const _gold       = Color(0xFFF59E0B);
const _success    = Color(0xFF10B981);

const _grad = LinearGradient(
  colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF059669)],
  begin: Alignment.topLeft, end: Alignment.bottomRight);

/// Bottom sheet for leaving a review after a video/voice call ends.
/// Shows: avatar, star rating, comment input.
class LeaveReviewSheet {
  static Future<bool> show(
    BuildContext context, {
    required String userId,
    required String userName,
    String? userImage,
    String reviewerName = 'You',
    String reviewerImage = '',
    int? callDurationSeconds,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _Sheet(
        userId: userId,
        userName: userName,
        userImage: userImage,
        reviewerName: reviewerName,
        reviewerImage: reviewerImage,
        callDurationSeconds: callDurationSeconds));
    return result ?? false;
  }
}

class _Sheet extends StatefulWidget {
  final String  userId;
  final String  userName;
  final String? userImage;
  final String  reviewerName;
  final String  reviewerImage;
  final int?    callDurationSeconds;

  const _Sheet({
    required this.userId,
    required this.userName,
    this.userImage,
    required this.reviewerName,
    required this.reviewerImage,
    this.callDurationSeconds,
  });

  @override
  State<_Sheet> createState() => _SheetState();
}

class _SheetState extends State<_Sheet> {
  double _rating = 0;
  final TextEditingController _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() { _commentCtrl.dispose(); super.dispose(); }

  bool get _canSubmit => _rating > 0 && _commentCtrl.text.trim().isNotEmpty;

  String _ratingLabel() {
    if (_rating == 0) return 'Tap a star to rate';
    if (_rating <= 1) return 'Poor 😞';
    if (_rating <= 2) return 'Fair 😕';
    if (_rating <= 3) return 'Good 🙂';
    if (_rating <= 4) return 'Very Good 😊';
    return 'Excellent! 🤩';
  }

  String _callDurationLabel() {
    if (widget.callDurationSeconds == null) return '';
    final s = widget.callDurationSeconds!;
    final m = (s ~/ 60);
    if (m == 0) return '${s}s call';
    return '${m}m ${s % 60}s call';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: SafeArea(top: false, child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 50, height: 5,
              decoration: BoxDecoration(color: _divider, borderRadius: BorderRadius.circular(3))),

            // Header with close button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                Container(width: 40, height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_gold, Color(0xFFFFB300)]),
                    borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.star_rounded, color: Colors.white, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('How was your session?',
                    style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: _textDark)),
                  if (widget.callDurationSeconds != null)
                    Text(_callDurationLabel(),
                      style: GoogleFonts.inter(fontSize: 11, color: _textLight)),
                ])),
                GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: Container(width: 32, height: 32,
                    decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.close_rounded, size: 16, color: _textMid))),
              ]),
            ),

            const SizedBox(height: 24),

            // Avatar of person being reviewed
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [_primary, _green],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))]),
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3)),
                child: ClipOval(
                  child: widget.userImage != null && widget.userImage!.isNotEmpty
                      ? Image.network(widget.userImage!, fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _fallback())
                      : _fallback()),
              ),
            ),

            const SizedBox(height: 14),
            Text(widget.userName,
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark)),
            const SizedBox(height: 4),
            Text('Rate your experience',
              style: GoogleFonts.inter(fontSize: 13, color: _textMid)),

            const SizedBox(height: 24),

            // Star rating
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) {
              final starValue = (i + 1).toDouble();
              final filled = _rating >= starValue;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _rating = starValue);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedScale(
                    scale: filled ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: filled ? _gold : _textLight,
                      size: 44))),
              );
            })),

            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _ratingLabel(),
                key: ValueKey(_rating),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _rating == 0 ? _textLight : _gold))),

            const SizedBox(height: 24),

            // Comment field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('YOUR REVIEW',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: _textDark, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _bg, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _divider)),
                  child: TextField(
                    controller: _commentCtrl,
                    onChanged: (_) => setState(() {}),
                    maxLines: 4,
                    minLines: 4,
                    maxLength: 250,
                    style: GoogleFonts.inter(fontSize: 14, color: _textDark),
                    decoration: InputDecoration(
                      hintText: 'Share your experience... What did you like? Anything to improve?',
                      hintStyle: GoogleFonts.inter(color: _textLight, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                      counterStyle: GoogleFonts.inter(fontSize: 11, color: _textLight))),
                ),
              ]),
            ),

            const SizedBox(height: 20),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Expanded(child: GestureDetector(
                  onTap: _submitting ? null : () => Navigator.pop(context, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _bg, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _divider)),
                    child: Center(child: Text('Skip',
                      style: GoogleFonts.inter(color: _textMid, fontWeight: FontWeight.w700, fontSize: 14)))))),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: GestureDetector(
                  onTap: _canSubmit && !_submitting ? _submit : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: _canSubmit ? _grad : null,
                      color: _canSubmit ? null : _divider,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: _canSubmit ? [BoxShadow(
                        color: _primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : null),
                    child: Center(child: _submitting
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.send_rounded,
                            color: _canSubmit ? Colors.white : _textLight, size: 16),
                          const SizedBox(width: 8),
                          Text('Submit Review',
                            style: GoogleFonts.inter(
                              color: _canSubmit ? Colors.white : _textLight,
                              fontWeight: FontWeight.w800, fontSize: 14)),
                        ])),
                  ),
                )),
              ]),
            ),

            const SizedBox(height: 20),
          ]),
        )),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: _primary.withOpacity(0.1),
      child: Center(child: Text(
        widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
        style: GoogleFonts.inter(color: _primary, fontWeight: FontWeight.w800, fontSize: 32))),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);

    // Save the review
    ReviewsController.instance.addReview(
      userId: widget.userId,
      reviewerName: widget.reviewerName,
      reviewerImage: widget.reviewerImage,
      rating: _rating,
      comment: _commentCtrl.text.trim(),
    );

    // Simulate small delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    Navigator.pop(context, true);

    HapticFeedback.mediumImpact();

    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('Review Submitted! ⭐',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
          Text('Your feedback for ${widget.userName} is live',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
        ])),
      ]),
      backgroundColor: _success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      duration: const Duration(seconds: 3)));
  }
}
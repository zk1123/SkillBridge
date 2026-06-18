import 'package:flutter/material.dart';
import '../services/report_service.dart';

const _kReasons = [
  'Spam',
  'Harassment',
  'Inappropriate content',
  'Fake profile',
];

Future<void> showReportSheet(
  BuildContext context, {
  required String reportedId,
  required String targetType,
  required String targetId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ReportSheet(
      reportedId: reportedId,
      targetType: targetType,
      targetId: targetId,
    ),
  );
}

class _ReportSheet extends StatefulWidget {
  final String reportedId;
  final String targetType;
  final String targetId;

  const _ReportSheet({
    required this.reportedId,
    required this.targetType,
    required this.targetId,
  });

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  String? _selectedReason;
  final _detailsController = TextEditingController();
  bool _submitting = false;

  static const _danger = Color(0xFFEF4444);
  static const _textDark = Color(0xFF191C21);
  static const _textMid = Color(0xFF64748B);
  static const _textLight = Color(0xFF94A3B8);
  static const _surface = Colors.white;
  static const _divider = Color(0xFFF2F3FB);

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a reason.')));
      return;
    }

    setState(() => _submitting = true);

    try {
      await ReportService.submitReport(
        reportedId: widget.reportedId,
        targetType: widget.targetType,
        targetId: widget.targetId,
        reason: _selectedReason!,
        details: _detailsController.text,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted. Our team will review it.'),
          backgroundColor: Color(0xFF22C55E),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit report: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.flag_rounded, color: _danger, size: 18),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  Text(
                    'Help us keep SkillBridge safe',
                    style: TextStyle(fontSize: 12, color: _textMid),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Reason chips
          const Text(
            'What\'s the issue?',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kReasons.map((reason) {
              final selected = _selectedReason == reason;
              return GestureDetector(
                onTap: () => setState(() => _selectedReason = reason),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? _danger.withOpacity(0.08) : _divider,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? _danger.withOpacity(0.5)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    reason,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? _danger : _textMid,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          // Optional details
          const Text(
            'Additional details (optional)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _detailsController,
            maxLines: 3,
            maxLength: 300,
            decoration: InputDecoration(
              hintText: 'Describe what happened…',
              hintStyle: const TextStyle(color: _textLight, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8F9FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _danger, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _danger,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Submit Report',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

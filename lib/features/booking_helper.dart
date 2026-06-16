// ═══════════════════════════════════════════════════════════════════
//  booking_helper.dart
//  Smart booking dialog — chooses between wallet payment or package use
//  Adds session to Sessions page after successful booking
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wallet_controller.dart';
import 'wallet_page.dart';
import 'subscriptions_controller.dart';
import 'sessions_controller.dart';

class _BColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color green = Color(0xFF059669);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMid = Color(0xFF475569);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color bg = Color(0xFFEEF2FF);
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color purple = Color(0xFF7C3AED);

  static const LinearGradient grad = LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGrad = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Shows a smart booking dialog that lets user pay from wallet OR use a package.
/// Adds the session to Sessions page after successful booking.
/// Returns true if booking succeeded, false otherwise.
Future<bool> showBookingDialog({
  required BuildContext context,
  required String mentorName,
  required String mentorImage,
  required String subject,
  required String date,
  required List<String> tags,
  required double amount,
  required bool isPaid,
}) async {
  // Free session — book directly
  if (!isPaid || amount == 0) {
    SessionsController.instance.addBookedSession(
      mentorName: mentorName,
      mentorImage: mentorImage,
      subject: subject,
      date: date,
      tags: tags,
      amount: 0,
      source: PaymentSource.free,
    );
    return true;
  }

  // Paid session — show booking method dialog
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _BookingDialog(
      mentorName: mentorName,
      mentorImage: mentorImage,
      subject: subject,
      date: date,
      tags: tags,
      amount: amount,
    ),
  );
  return result ?? false;
}

class _BookingDialog extends StatefulWidget {
  final String mentorName;
  final String mentorImage;
  final String subject;
  final String date;
  final List<String> tags;
  final double amount;

  const _BookingDialog({
    required this.mentorName,
    required this.mentorImage,
    required this.subject,
    required this.date,
    required this.tags,
    required this.amount,
  });

  @override
  State<_BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<_BookingDialog> {
  bool _processing = false;
  bool _success = false;
  String _successMethod = '';

  Future<void> _bookFromWallet() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final ok = WalletController.instance.pay(
      widget.amount,
      'Session with ${widget.mentorName}',
      recipient: widget.mentorName,
    );

    if (!mounted) return;

    if (ok) {
      // Add to Sessions
      SessionsController.instance.addBookedSession(
        mentorName: widget.mentorName,
        mentorImage: widget.mentorImage,
        subject: widget.subject,
        date: widget.date,
        tags: widget.tags,
        amount: widget.amount,
        source: PaymentSource.wallet,
      );
      setState(() {
        _processing = false;
        _success = true;
        _successMethod = 'wallet';
      });
      await Future.delayed(const Duration(milliseconds: 1400));
      if (mounted) Navigator.pop(context, true);
    } else {
      setState(() => _processing = false);
      _showInsufficientBalanceDialog();
    }
  }

  Future<void> _bookFromPackage(Subscription package) async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final ok = SubscriptionsController.instance.useSessionFromPackage(
      package.id,
    );

    if (!mounted) return;

    if (ok) {
      // Add to Sessions
      SessionsController.instance.addBookedSession(
        mentorName: widget.mentorName,
        mentorImage: widget.mentorImage,
        subject: widget.subject,
        date: widget.date,
        tags: widget.tags,
        amount: 0,
        source: PaymentSource.package,
        packageId: package.id,
      );
      setState(() {
        _processing = false;
        _success = true;
        _successMethod = 'package';
      });
      await Future.delayed(const Duration(milliseconds: 1400));
      if (mounted) Navigator.pop(context, true);
    } else {
      setState(() => _processing = false);
    }
  }

  void _showInsufficientBalanceDialog() {
    final shortage = widget.amount - WalletController.instance.balance;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _BColors.danger.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: _BColors.danger,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Insufficient Balance',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _BColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You need EGP ${shortage.toStringAsFixed(2)} more to book this session.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _BColors.textMid,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context, false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _BColors.bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _BColors.divider),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              color: _BColors.textMid,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context, false);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WalletPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: _BColors.grad,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Top Up',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = WalletController.instance.balance;
    final canAfford = balance >= widget.amount;
    final availablePackages =
        SubscriptionsController.instance.availablePackages;

    // Success state
    if (_success) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  gradient: _BColors.grad,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Booking Sent! 🎉',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _BColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _successMethod == 'wallet'
                    ? 'EGP ${widget.amount.toStringAsFixed(0)} paid from wallet'
                    : 'Session used from your package',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: _BColors.textMid),
              ),
              const SizedBox(height: 6),
              Text(
                'Waiting for ${widget.mentorName.split(' ').first}\'s confirmation',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: _BColors.textLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: _BColors.grad,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Book Session',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: _BColors.textDark,
                          ),
                        ),
                        Text(
                          'Choose payment method',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: _BColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Session info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _BColors.bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _BColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.mentorImage,
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 38,
                              height: 38,
                              color: _BColors.divider,
                              child: const Icon(
                                Icons.person,
                                color: _BColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.mentorName,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _BColors.textDark,
                                ),
                              ),
                              Text(
                                widget.subject,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: _BColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'EGP ${widget.amount.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: _BColors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: _BColors.textLight,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.date,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: _BColors.textMid,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Choose how to pay',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _BColors.textDark,
                ),
              ),
              const SizedBox(height: 10),

              // Available packages (FREE — no money charged)
              if (availablePackages.isNotEmpty) ...[
                ...availablePackages.map((pkg) => _packageOption(pkg)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(height: 1, color: _BColors.divider),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'OR',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: _BColors.textLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(height: 1, color: _BColors.divider),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Pay from wallet
              _walletOption(canAfford, balance),

              const SizedBox(height: 18),

              // Cancel button
              GestureDetector(
                onTap: _processing ? null : () => Navigator.pop(context, false),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        color: _BColors.textLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _packageOption(Subscription pkg) {
    final used = pkg.usedSessions ?? 0;
    final total = pkg.totalSessions ?? 1;
    final remaining = total - used;

    return GestureDetector(
      onTap: _processing ? null : () => _bookFromPackage(pkg),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: _BColors.purpleGrad,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _BColors.purple.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Use from ${pkg.title}',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$remaining sessions remaining • FREE',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (_processing)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 14,
              ),
          ],
        ),
      ),
    );
  }

  Widget _walletOption(bool canAfford, double balance) {
    return GestureDetector(
      onTap: (_processing || !canAfford) ? null : _bookFromWallet,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: canAfford ? _BColors.grad : null,
          color: canAfford ? null : _BColors.divider.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          boxShadow: canAfford
              ? [
                  BoxShadow(
                    color: _BColors.primary.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: canAfford
                    ? Colors.white.withOpacity(0.2)
                    : _BColors.textLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: canAfford ? Colors.white : _BColors.textMid,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pay from Wallet',
                    style: GoogleFonts.inter(
                      color: canAfford ? Colors.white : _BColors.textMid,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    canAfford
                        ? 'Balance: EGP ${balance.toStringAsFixed(0)} • Charge: EGP ${widget.amount.toStringAsFixed(0)}'
                        : 'Insufficient balance (EGP ${balance.toStringAsFixed(0)})',
                    style: GoogleFonts.inter(
                      color: canAfford
                          ? Colors.white.withOpacity(0.9)
                          : _BColors.danger,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (_processing && canAfford)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              Icon(
                canAfford
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.lock_rounded,
                color: canAfford ? Colors.white : _BColors.textLight,
                size: 14,
              ),
          ],
        ),
      ),
    );
  }
}

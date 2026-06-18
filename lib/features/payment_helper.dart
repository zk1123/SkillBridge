// ═══════════════════════════════════════════════════════════════════
//  payment_helper.dart
//  Reusable payment dialog — used by SkillStore, Match, and other pages
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wallet_controller.dart';
import 'wallet_page.dart';

class _PColors {
  static const Color primary  = Color(0xFF2563EB);
  static const Color green    = Color(0xFF059669);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMid  = Color(0xFF475569);
  static const Color textLight= Color(0xFF94A3B8);
  static const Color divider  = Color(0xFFE2E8F0);
  static const Color bg       = Color(0xFFEEF2FF);
  static const Color success  = Color(0xFF10B981);
  static const Color danger   = Color(0xFFEF4444);
  static const Color warning  = Color(0xFFF59E0B);

  static const LinearGradient grad = LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFF2563EB), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Shows a payment confirmation dialog and processes payment from wallet.
/// Returns true if payment succeeded, false otherwise.
Future<bool> showPaymentDialog({
  required BuildContext context,
  required String title,
  required String description,
  required double amount,
  String? recipient,
  IconData icon = Icons.shopping_cart_rounded,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _PaymentDialog(
      title: title,
      description: description,
      amount: amount,
      recipient: recipient,
      icon: icon,
    ),
  );
  return result ?? false;
}

class _PaymentDialog extends StatefulWidget {
  final String title;
  final String description;
  final double amount;
  final String? recipient;
  final IconData icon;

  const _PaymentDialog({
    required this.title,
    required this.description,
    required this.amount,
    required this.icon,
    this.recipient,
  });

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  bool _processing = false;
  bool _success = false;

  Future<void> _processPayment() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final ok = WalletController.instance.pay(
      widget.amount,
      widget.description,
      recipient: widget.recipient,
    );

    if (!mounted) return;

    if (ok) {
      setState(() { _processing = false; _success = true; });
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) Navigator.pop(context, true);
    } else {
      setState(() => _processing = false);
      _showInsufficientBalanceDialog();
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
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 64, height: 64,
              decoration: BoxDecoration(
                color: _PColors.danger.withOpacity(0.1),
                shape: BoxShape.circle),
              child: const Icon(Icons.account_balance_wallet_rounded, color: _PColors.danger, size: 32)),
            const SizedBox(height: 16),
            Text('Insufficient Balance',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: _PColors.textDark)),
            const SizedBox(height: 8),
            Text('You need EGP ${shortage.toStringAsFixed(2)} more to complete this payment.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: _PColors.textMid, height: 1.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _PColors.bg, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Text('Wallet Balance:', style: GoogleFonts.inter(fontSize: 12, color: _PColors.textMid)),
                const Spacer(),
                Text('EGP ${WalletController.instance.balance.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: _PColors.danger)),
              ]),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () { Navigator.pop(context); Navigator.pop(context, false); },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: _PColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _PColors.divider)),
                  child: Center(child: Text('Cancel', style: GoogleFonts.inter(color: _PColors.textMid, fontWeight: FontWeight.w600)))))),
              const SizedBox(width: 10),
              Expanded(child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context, false);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletPage()));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(gradient: _PColors.grad, borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text('Top Up', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)))))),
            ]),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = WalletController.instance.balance;
    final newBalance = balance - widget.amount;
    final canAfford = balance >= widget.amount;
    final Color afterColor = canAfford ? _PColors.success : _PColors.danger;

    if (_success) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 72, height: 72,
              decoration: const BoxDecoration(gradient: _PColors.grad, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 38)),
            const SizedBox(height: 16),
            Text('Payment Successful! 🎉',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: _PColors.textDark)),
            const SizedBox(height: 8),
            Text('EGP ${widget.amount.toStringAsFixed(0)} deducted from wallet',
              style: GoogleFonts.inter(fontSize: 13, color: _PColors.textMid)),
          ]),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 44, height: 44,
                decoration: BoxDecoration(gradient: _PColors.grad, borderRadius: BorderRadius.circular(12)),
                child: Icon(widget.icon, color: Colors.white, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Confirm Payment',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16, color: _PColors.textDark)),
                Text('Pay from your wallet',
                  style: GoogleFonts.inter(fontSize: 11, color: _PColors.textLight)),
              ])),
            ]),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _PColors.bg, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _PColors.divider)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.title,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _PColors.textDark)),
                const SizedBox(height: 4),
                Text(widget.description,
                  style: GoogleFonts.inter(fontSize: 12, color: _PColors.textMid)),
              ]),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _PColors.divider)),
              child: Column(children: [
                Row(children: [
                  Text('Amount', style: GoogleFonts.inter(fontSize: 13, color: _PColors.textMid)),
                  const Spacer(),
                  Text('EGP ${widget.amount.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _PColors.textDark)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Text('Wallet Balance', style: GoogleFonts.inter(fontSize: 13, color: _PColors.textMid)),
                  const Spacer(),
                  Text('EGP ${balance.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(fontSize: 13, color: _PColors.textMid)),
                ]),
                const SizedBox(height: 10),
                Container(height: 1, color: _PColors.divider),
                const SizedBox(height: 10),
                Row(children: [
                  Text('Balance After', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: _PColors.textDark)),
                  const Spacer(),
                  Text('EGP ${newBalance.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: afterColor,
                    )),
                ]),
              ]),
            ),

            if (!canAfford) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _PColors.danger.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _PColors.danger.withOpacity(0.3))),
                child: Row(children: [
                  const Icon(Icons.warning_rounded, color: _PColors.danger, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Insufficient balance. Please top up your wallet.',
                    style: GoogleFonts.inter(fontSize: 11, color: _PColors.danger, fontWeight: FontWeight.w600))),
                ]),
              ),
            ],

            const SizedBox(height: 20),

            Row(children: [
              Expanded(child: GestureDetector(
                onTap: _processing ? null : () => Navigator.pop(context, false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(color: _PColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _PColors.divider)),
                  child: Center(child: Text('Cancel', style: GoogleFonts.inter(color: _PColors.textMid, fontWeight: FontWeight.w600)))))),
              const SizedBox(width: 10),
              Expanded(child: GestureDetector(
                onTap: _processing ? null : _processPayment,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: canAfford ? _PColors.grad : null,
                    color: canAfford ? null : _PColors.textLight,
                    borderRadius: BorderRadius.circular(12)),
                  child: Center(child: _processing
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(canAfford ? 'Pay Now' : 'Top Up First',
                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)))))),
            ]),
          ]),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wallet_controller.dart';

const _primary   = Color(0xFF2563EB);
const _green     = Color(0xFF059669);
const _textDark  = Color(0xFF0F172A);
const _textMid   = Color(0xFF475569);
const _textLight = Color(0xFF94A3B8);
const _divider   = Color(0xFFE2E8F0);
const _bg        = Color(0xFFEEF2FF);
const _success   = Color(0xFF10B981);
const _warning   = Color(0xFFF59E0B);
const _danger    = Color(0xFFEF4444);
const _purple    = Color(0xFF7C3AED);

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

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});
  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {

  void _toast(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter()),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: color ?? _textDark,
    ));
  }

  // ── Top-up Dialog ──
  void _showTopUpDialog() {
    final amountCtrl = TextEditingController();
    String selectedMethod = 'Visa';

    // Visa fields
    final cardNumCtrl  = TextEditingController();
    final cardNameCtrl = TextEditingController();
    final cardExpCtrl  = TextEditingController();
    final cardCvvCtrl  = TextEditingController();

    // Mobile wallet fields
    String mobileProvider = 'Vodafone Cash'; // for mobile wallet selection
    final phoneCtrl = TextEditingController();

    // InstaPay phone
    final instaPhoneCtrl = TextEditingController();

    final methods = ['Visa', 'Mobile Wallet', 'InstaPay'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(gradient: _grad, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.add_card_rounded, color: Colors.white, size: 22)),
                const SizedBox(width: 12),
                Text('Top Up Wallet', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16, color: _textDark)),
              ]),
              const SizedBox(height: 20),

              Text('Amount (EGP)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _divider)),
                child: TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(fontSize: 16, color: _textDark, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: GoogleFonts.inter(color: _textLight, fontSize: 16),
                    prefixText: 'EGP ',
                    prefixStyle: GoogleFonts.inter(color: _primary, fontSize: 14, fontWeight: FontWeight.w700),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14))),
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 6, children: [100, 200, 500, 1000].map((amt) =>
                GestureDetector(
                  onTap: () => setS(() => amountCtrl.text = '$amt'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _bg, borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _divider)),
                    child: Text('+ $amt', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _primary)),
                  ),
                )).toList()),
              const SizedBox(height: 16),

              Text('Payment Method', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
              const SizedBox(height: 6),
              ...methods.map((m) {
                final selected = selectedMethod == m;
                return GestureDetector(
                  onTap: () => setS(() => selectedMethod = m),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? _primary.withOpacity(0.08) : _bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? _primary : _divider, width: selected ? 1.5 : 1)),
                    child: Row(children: [
                      Icon(_methodIcon(m), size: 18, color: selected ? _primary : _textLight),
                      const SizedBox(width: 10),
                      Text(m, style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? _primary : _textMid)),
                      const Spacer(),
                      if (selected) const Icon(Icons.check_circle_rounded, color: _primary, size: 18),
                    ]),
                  ),
                );
              }),

              const SizedBox(height: 14),

              // ── Method-specific fields ──
              if (selectedMethod == 'Visa') ...[
                Text('Card Details', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
                const SizedBox(height: 8),
                _smallField(cardNumCtrl, 'Card Number', '1234 5678 9012 3456', Icons.credit_card_rounded),
                const SizedBox(height: 8),
                _smallField(cardNameCtrl, 'Cardholder Name', 'Full name on card', Icons.person_outline_rounded),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _smallField(cardExpCtrl, 'Expiry', 'MM/YY', Icons.calendar_today_rounded)),
                  const SizedBox(width: 8),
                  Expanded(child: _smallField(cardCvvCtrl, 'CVV', '123', Icons.lock_outline_rounded, obscure: true)),
                ]),
              ],

              if (selectedMethod == 'Mobile Wallet') ...[
                Text('Choose Provider', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _providerChip('Vodafone Cash', '🔴', const Color(0xFFE60000), mobileProvider, (v) => setS(() => mobileProvider = v))),
                  const SizedBox(width: 6),
                  Expanded(child: _providerChip('Orange Cash', '🟠', const Color(0xFFFF6600), mobileProvider, (v) => setS(() => mobileProvider = v))),
                  const SizedBox(width: 6),
                  Expanded(child: _providerChip('Etisalat Cash', '🟢', const Color(0xFF00A651), mobileProvider, (v) => setS(() => mobileProvider = v))),
                ]),
                const SizedBox(height: 10),
                _smallField(phoneCtrl, 'Mobile Number', '01XXXXXXXXX', Icons.phone_android_rounded, keyboard: TextInputType.phone),
              ],

              if (selectedMethod == 'InstaPay') ...[
                Text('InstaPay Details', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
                const SizedBox(height: 8),
                _smallField(instaPhoneCtrl, 'Mobile Number', '01XXXXXXXXX', Icons.phone_android_rounded, keyboard: TextInputType.phone),
              ],

              const SizedBox(height: 18),

              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _divider)),
                    child: Center(child: Text('Cancel', style: GoogleFonts.inter(color: _textMid, fontWeight: FontWeight.w600)))))),
                const SizedBox(width: 10),
                Expanded(child: GestureDetector(
                  onTap: () {
                    final amount = double.tryParse(amountCtrl.text);
                    if (amount == null || amount <= 0) {
                      _toast('⚠️ Enter a valid amount', color: _warning);
                      return;
                    }

                    // Validate based on method
                    String methodLabel = selectedMethod;
                    if (selectedMethod == 'Visa') {
                      if (cardNumCtrl.text.length < 4 || cardNameCtrl.text.isEmpty) {
                        _toast('⚠️ Please fill card details', color: _warning);
                        return;
                      }
                      methodLabel = 'Visa';
                    } else if (selectedMethod == 'Mobile Wallet') {
                      if (phoneCtrl.text.length < 11) {
                        _toast('⚠️ Enter a valid mobile number', color: _warning);
                        return;
                      }
                      methodLabel = mobileProvider;
                    } else if (selectedMethod == 'InstaPay') {
                      if (instaPhoneCtrl.text.length < 11) {
                        _toast('⚠️ Enter a valid mobile number', color: _warning);
                        return;
                      }
                      methodLabel = 'InstaPay';
                    }

                    WalletController.instance.topUp(amount, methodLabel);
                    Navigator.pop(context);
                    _toast('✅ EGP ${amount.toStringAsFixed(0)} added to wallet!', color: _success);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(gradient: _grad, borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text('Top Up', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)))))),
              ]),
            ]),
          ),
        ),
      )),
    );
  }

  Widget _smallField(TextEditingController ctrl, String label, String hint, IconData icon, {bool obscure = false, TextInputType? keyboard}) {
    return Container(
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _divider)),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboard,
        style: GoogleFonts.inter(fontSize: 13, color: _textDark, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: _textLight, fontSize: 12),
          prefixIcon: Icon(icon, size: 16, color: _primary),
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 11, color: _textMid, fontWeight: FontWeight.w600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4))),
    );
  }

  Widget _providerChip(String name, String emoji, Color color, String selected, Function(String) onTap) {
    final isSelected = selected == name;
    final shortName = name.split(' ').first; // Vodafone, Orange, Etisalat
    return GestureDetector(
      onTap: () => onTap(name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : _bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : _divider, width: isSelected ? 1.5 : 1)),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(shortName, style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? color : _textMid)),
        ]),
      ),
    );
  }

  // ── Add Card Dialog ──
  void _showAddCardDialog() {
    final numCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final expCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(gradient: _grad, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.credit_card_rounded, color: Colors.white, size: 22)),
                const SizedBox(width: 12),
                Text('Add New Card', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16, color: _textDark)),
              ]),
              const SizedBox(height: 20),

              _dialogField(numCtrl, 'Card Number', '1234 5678 9012 3456', Icons.credit_card_rounded),
              const SizedBox(height: 12),
              _dialogField(nameCtrl, 'Cardholder Name', 'Full name on card', Icons.person_outline_rounded),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _dialogField(expCtrl, 'Expiry', 'MM/YY', Icons.calendar_today_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _dialogField(cvvCtrl, 'CVV', '123', Icons.lock_outline_rounded, obscure: true)),
              ]),
              const SizedBox(height: 20),

              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _divider)),
                    child: Center(child: Text('Cancel', style: GoogleFonts.inter(color: _textMid, fontWeight: FontWeight.w600)))))),
                const SizedBox(width: 10),
                Expanded(child: GestureDetector(
                  onTap: () {
                    if (numCtrl.text.length < 4 || nameCtrl.text.isEmpty) {
                      _toast('⚠️ Please fill all fields', color: _warning);
                      return;
                    }
                    final last4 = numCtrl.text.replaceAll(' ', '');
                    WalletController.instance.addCard(PaymentCard(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      number: last4.length >= 4 ? last4.substring(last4.length - 4) : last4,
                      holderName: nameCtrl.text,
                      expiry: expCtrl.text.isEmpty ? '00/00' : expCtrl.text,
                      type: 'Visa',
                    ));
                    Navigator.pop(context);
                    _toast('✅ Card added successfully!', color: _success);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(gradient: _grad, borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text('Add Card', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)))))),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label, String hint, IconData icon, {bool obscure = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _divider)),
        child: TextField(
          controller: ctrl, obscureText: obscure,
          style: GoogleFonts.inter(fontSize: 14, color: _textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: _textLight, fontSize: 13),
            prefixIcon: Icon(icon, size: 18, color: _primary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12)))),
    ]);
  }

  IconData _methodIcon(String method) {
    switch (method) {
      case 'Visa':
      case 'Mastercard': return Icons.credit_card_rounded;
      case 'Mobile Wallet':
      case 'Vodafone Cash':
      case 'Orange Cash':
      case 'Etisalat Cash': return Icons.phone_android_rounded;
      case 'InstaPay': return Icons.bolt_rounded;
      default: return Icons.payment_rounded;
    }
  }

  IconData _txIcon(TxType t) {
    switch (t) {
      case TxType.topup: return Icons.arrow_downward_rounded;
      case TxType.payment: return Icons.arrow_upward_rounded;
      case TxType.withdraw: return Icons.account_balance_rounded;
      case TxType.refund: return Icons.replay_rounded;
    }
  }

  Color _txColor(TxType t) {
    switch (t) {
      case TxType.topup: return _success;
      case TxType.payment: return _danger;
      case TxType.withdraw: return _warning;
      case TxType.refund: return _primary;
    }
  }

  String _txPrefix(TxType t) {
    switch (t) {
      case TxType.topup:
      case TxType.refund: return '+';
      case TxType.payment:
      case TxType.withdraw: return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        decoration: const BoxDecoration(gradient: _pageBg),
        child: SafeArea(child: Column(children: [

          // ── Top Bar ──
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
              Text('Wallet', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
            ]),
          ),

          Expanded(child: ListenableBuilder(
            listenable: WalletController.instance,
            builder: (_, __) {
              final w = WalletController.instance;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                children: [

                  // ── Balance Hero Card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: _grad,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.3))),
                          child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 22)),
                        const SizedBox(width: 12),
                        Text('Wallet Balance',
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Icon(Icons.visibility_outlined, color: Colors.white.withOpacity(0.7), size: 18),
                      ]),
                      const SizedBox(height: 16),
                      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('EGP', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.85))),
                        const SizedBox(width: 8),
                        Text(w.balance.toStringAsFixed(2),
                          style: GoogleFonts.inter(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
                      ]),
                      const SizedBox(height: 20),
                      Row(children: [
                        Expanded(child: GestureDetector(
                          onTap: _showTopUpDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14)),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const Icon(Icons.add_rounded, color: _primary, size: 18),
                              const SizedBox(width: 6),
                              Text('Top Up', style: GoogleFonts.inter(color: _primary, fontWeight: FontWeight.w800, fontSize: 13)),
                            ]),
                          ),
                        )),
                        const SizedBox(width: 10),
                        Expanded(child: GestureDetector(
                          onTap: () => _toast('💸 Send money coming soon!'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withOpacity(0.3))),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 6),
                              Text('Send', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                            ]),
                          ),
                        )),
                      ]),
                    ]),
                  ),

                  const SizedBox(height: 16),

                  // ── Mini Stats ──
                  Row(children: [
                    Expanded(child: _miniStat('Total Spent', 'EGP ${w.totalSpent.toStringAsFixed(0)}', Icons.shopping_bag_rounded, _danger)),
                    const SizedBox(width: 12),
                    Expanded(child: _miniStat('Total Topped Up', 'EGP ${w.totalToppedUp.toStringAsFixed(0)}', Icons.add_circle_rounded, _success)),
                  ]),

                  const SizedBox(height: 24),

                  // ── Payment Methods ──
                  Row(children: [
                    Expanded(child: _sectionHeader(Icons.credit_card_rounded, 'Payment Methods')),
                    GestureDetector(
                      onTap: _showAddCardDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(gradient: _grad, borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.add_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text('Add', style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  if (w.cards.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _divider.withOpacity(0.7))),
                      child: Column(children: [
                        Icon(Icons.credit_card_off_rounded, size: 36, color: _textLight),
                        const SizedBox(height: 8),
                        Text('No cards added yet', style: GoogleFonts.inter(fontSize: 13, color: _textLight, fontWeight: FontWeight.w600)),
                      ]),
                    )
                  else
                    SizedBox(
                      height: 170,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: w.cards.length,
                        itemBuilder: (_, i) => _cardWidget(w.cards[i], i),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // ── Transactions ──
                  Row(children: [
                    Expanded(child: _sectionHeader(Icons.receipt_long_rounded, 'Recent Transactions')),
                    Text('${w.transactions.length} total',
                      style: GoogleFonts.inter(fontSize: 12, color: _primary, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 12),
                  if (w.transactions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _divider.withOpacity(0.7))),
                      child: Center(child: Text('No transactions yet',
                        style: GoogleFonts.inter(fontSize: 13, color: _textLight))),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _divider.withOpacity(0.7)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))]),
                      child: Column(children: List.generate(w.transactions.length, (i) {
                        final tx = w.transactions[i];
                        final isLast = i == w.transactions.length - 1;
                        return Column(children: [
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(children: [
                              Container(width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: _txColor(tx.type).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(11)),
                                child: Icon(_txIcon(tx.type), color: _txColor(tx.type), size: 18)),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(tx.description,
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: _textDark),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(WalletController.instance.timeAgo(tx.time),
                                  style: GoogleFonts.inter(fontSize: 11, color: _textLight)),
                              ])),
                              Text('${_txPrefix(tx.type)}EGP ${tx.amount.toStringAsFixed(0)}',
                                style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w800,
                                  color: _txColor(tx.type))),
                            ]),
                          ),
                          if (!isLast) Container(height: 1, margin: const EdgeInsets.only(left: 66), color: _divider.withOpacity(0.6)),
                        ]);
                      })),
                    ),
                ],
              );
            },
          )),
        ])),
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _divider.withOpacity(0.7)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 32, height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: color, size: 16)),
        const SizedBox(height: 10),
        Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: _textLight, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(children: [
      Container(width: 4, height: 18,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF059669)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter),
          borderRadius: BorderRadius.circular(4))),
      const SizedBox(width: 10),
      Icon(icon, size: 16, color: _primary),
      const SizedBox(width: 6),
      Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
    ]);
  }

  Widget _cardWidget(PaymentCard card, int index) {
    final colors = [
      [const Color(0xFF1E40AF), const Color(0xFF7C3AED)],
      [const Color(0xFF059669), const Color(0xFF2563EB)],
      [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
    ];
    final cardColors = colors[index % colors.length];

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: cardColors,
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: cardColors[0].withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 6))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 24,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4)),
            child: const Icon(Icons.contactless_rounded, color: Colors.white, size: 14)),
          const Spacer(),
          Text(card.type, style: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, fontStyle: FontStyle.italic)),
        ]),
        const Spacer(),
        Text('•••• •••• •••• ${card.number}',
          style: GoogleFonts.inter(
            fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 2)),
        const SizedBox(height: 12),
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CARDHOLDER', style: GoogleFonts.inter(fontSize: 8, color: Colors.white.withOpacity(0.7), letterSpacing: 1)),
            const SizedBox(height: 2),
            Text(card.holderName, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
          ]),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('EXPIRES', style: GoogleFonts.inter(fontSize: 8, color: Colors.white.withOpacity(0.7), letterSpacing: 1)),
            const SizedBox(height: 2),
            Text(card.expiry, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
          ]),
        ]),
      ]),
    );
  }
}
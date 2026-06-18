// ═══════════════════════════════════════════════════════════════════
//  wallet_controller.dart
//  Singleton — manages wallet balance, transactions, and payment cards
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

enum TxType {
  topup,      // شحن المحفظه
  payment,    // دفع لجلسة أو كورس
  withdraw,   // سحب
  refund,     // استرجاع
}

class Transaction {
  final String id;
  final TxType type;
  final double amount;
  final String description;
  final DateTime time;
  final String? recipient;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.time,
    this.recipient,
  });
}

class PaymentCard {
  final String id;
  final String number;        // last 4 digits only for display
  final String holderName;
  final String expiry;
  final String type;          // Visa, Mastercard, etc.

  const PaymentCard({
    required this.id,
    required this.number,
    required this.holderName,
    required this.expiry,
    required this.type,
  });
}

class WalletController extends ChangeNotifier {
  static final WalletController instance = WalletController._();
  WalletController._();

  double _balance = 2500.0; // الرصيد الافتراضي بالجنيه المصري

  final List<Transaction> _transactions = [
    Transaction(
      id: '1', type: TxType.topup, amount: 1000,
      description: 'Wallet top-up via Visa',
      time: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Transaction(
      id: '2', type: TxType.payment, amount: 240,
      description: 'Session with Marwan Hussien',
      recipient: 'Marwan Hussien',
      time: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Transaction(
      id: '3', type: TxType.topup, amount: 2000,
      description: 'Wallet top-up via Vodafone Cash',
      time: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Transaction(
      id: '4', type: TxType.payment, amount: 749,
      description: 'Python & Data Science Course',
      recipient: 'SkillStore',
      time: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  final List<PaymentCard> _cards = [
    const PaymentCard(
      id: '1', number: '4532',
      holderName: 'Marwan Hussien',
      expiry: '12/27', type: 'Visa',
    ),
  ];

  // ── Getters ──
  double get balance => _balance;
  List<Transaction> get transactions => List.unmodifiable(_transactions.reversed);
  List<PaymentCard> get cards => List.unmodifiable(_cards);
  int get cardCount => _cards.length;

  double get totalSpent => _transactions
      .where((t) => t.type == TxType.payment)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalToppedUp => _transactions
      .where((t) => t.type == TxType.topup)
      .fold(0.0, (sum, t) => sum + t.amount);

  // ── Actions ──

  /// شحن المحفظه
  void topUp(double amount, String method) {
    _balance += amount;
    _transactions.add(Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TxType.topup,
      amount: amount,
      description: 'Wallet top-up via $method',
      time: DateTime.now(),
    ));
    notifyListeners();
  }

  /// دفع من المحفظه (يرجع true لو نجح، false لو الرصيد مش كافي)
  bool pay(double amount, String description, {String? recipient}) {
    if (_balance < amount) return false;
    _balance -= amount;
    _transactions.add(Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TxType.payment,
      amount: amount,
      description: description,
      recipient: recipient,
      time: DateTime.now(),
    ));
    notifyListeners();
    return true;
  }

  /// إضافة كارت جديد
  void addCard(PaymentCard card) {
    _cards.add(card);
    notifyListeners();
  }

  /// استرجاع فلوس (refund) — لما السيشن تترفض
  void refund(double amount, String description, {String? recipient}) {
    _balance += amount;
    _transactions.add(Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TxType.refund,
      amount: amount,
      description: description,
      recipient: recipient,
      time: DateTime.now(),
    ));
    notifyListeners();
  }

  /// حذف كارت
  void removeCard(String id) {
    _cards.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  String timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    if (diff.inDays    == 1) return 'Yesterday';
    if (diff.inDays    < 7)  return '${diff.inDays} days ago';
    return '${diff.inDays ~/ 7} weeks ago';
  }
}
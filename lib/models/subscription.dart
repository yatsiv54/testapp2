import 'dart:convert';

class Subscription {
  final String id;
  final String name;
  final double amount;
  final String periodicity; // "Daily", "Weekly", "Monthly", "Yearly"
  final DateTime nextPaymentDate;
  final String category;
  final String? logoPath;
  final bool hasReminder;
  final String status; // "Active", "Paused", "Archived"

  Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.periodicity,
    required this.nextPaymentDate,
    required this.category,
    this.logoPath,
    this.hasReminder = false,
    this.status = 'Active',
  });

  Subscription copyWith({
    String? id,
    String? name,
    double? amount,
    String? periodicity,
    DateTime? nextPaymentDate,
    String? category,
    String? logoPath,
    bool? hasReminder,
    String? status,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      periodicity: periodicity ?? this.periodicity,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      category: category ?? this.category,
      logoPath: logoPath ?? this.logoPath,
      hasReminder: hasReminder ?? this.hasReminder,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'periodicity': periodicity,
      'nextPaymentDate': nextPaymentDate.millisecondsSinceEpoch,
      'category': category,
      'logoPath': logoPath,
      'hasReminder': hasReminder,
      'status': status,
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      periodicity: map['periodicity'] ?? 'Monthly',
      nextPaymentDate: DateTime.fromMillisecondsSinceEpoch(map['nextPaymentDate'] ?? 0),
      category: map['category'] ?? 'General',
      logoPath: map['logoPath'],
      hasReminder: map['hasReminder'] ?? false,
      status: map['status'] ?? 'Active',
    );
  }

  String toJson() => json.encode(toMap());

  factory Subscription.fromJson(String source) => Subscription.fromMap(json.decode(source));
}

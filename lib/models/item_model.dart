// lib/models/item_model.dart

import 'package:equatable/equatable.dart';

enum ItemStatus { safe, warning, urgent }

class ItemModel extends Equatable {
  final String id;
  final String name;
  final String quantityDescription;
  final int expectedDays;
  final DateTime createdAt;
  final bool notificationsEnabled;
  final int safeThresholdDays;
  final int warningThresholdDays;
  final int urgentThresholdDays;
  final DateTime? lastRefreshedAt;
  final String? notes;

  const ItemModel({
    required this.id,
    required this.name,
    this.quantityDescription = '',
    required this.expectedDays,
    required this.createdAt,
    this.notificationsEnabled = true,
    this.safeThresholdDays = 20,
    this.warningThresholdDays = 10,
    this.urgentThresholdDays = 3,
    this.lastRefreshedAt,
    this.notes,
  });

  // ─── SQLite serialization ───────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantityDescription': quantityDescription,
      'expectedDays': expectedDays,
      'createdAt': createdAt.toIso8601String(),
      'notificationsEnabled': notificationsEnabled ? 1 : 0,
      'safeThresholdDays': safeThresholdDays,
      'warningThresholdDays': warningThresholdDays,
      'urgentThresholdDays': urgentThresholdDays,
      'lastRefreshedAt': lastRefreshedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as String,
      name: map['name'] as String,
      quantityDescription: map['quantityDescription'] as String? ?? '',
      expectedDays: map['expectedDays'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      notificationsEnabled: (map['notificationsEnabled'] as int? ?? 1) == 1,
      safeThresholdDays: map['safeThresholdDays'] as int? ?? 20,
      warningThresholdDays: map['warningThresholdDays'] as int? ?? 10,
      urgentThresholdDays: map['urgentThresholdDays'] as int? ?? 3,
      lastRefreshedAt: map['lastRefreshedAt'] != null
          ? DateTime.parse(map['lastRefreshedAt'] as String)
          : null,
      notes: map['notes'] as String?,
    );
  }

  // ─── Domain logic ───────────────────────────────────────────────────────────

  DateTime get expectedExpiryDate {
    final base = lastRefreshedAt ?? createdAt;
    return base.add(Duration(days: expectedDays));
  }

  int get remainingDays {
    final now = DateTime.now();
    final expiry = expectedExpiryDate;
    return expiry.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  String get remainingDaysText {
    final days = remainingDays;
    if (days > 0) return 'يكفي $days يوم';
    if (days == 0) return 'ينتهي اليوم';
    return 'انتهى منذ ${-days} يوم';
  }

  ItemStatus get status {
    final days = remainingDays;
    if (days <= urgentThresholdDays) return ItemStatus.urgent;
    if (days <= warningThresholdDays) return ItemStatus.warning;
    return ItemStatus.safe;
  }

  ItemModel copyWith({
    String? id,
    String? name,
    String? quantityDescription,
    int? expectedDays,
    DateTime? createdAt,
    bool? notificationsEnabled,
    int? safeThresholdDays,
    int? warningThresholdDays,
    int? urgentThresholdDays,
    DateTime? lastRefreshedAt,
    String? notes,
    bool clearLastRefreshedAt = false,
    bool clearNotes = false,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      quantityDescription: quantityDescription ?? this.quantityDescription,
      expectedDays: expectedDays ?? this.expectedDays,
      createdAt: createdAt ?? this.createdAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      safeThresholdDays: safeThresholdDays ?? this.safeThresholdDays,
      warningThresholdDays: warningThresholdDays ?? this.warningThresholdDays,
      urgentThresholdDays: urgentThresholdDays ?? this.urgentThresholdDays,
      lastRefreshedAt: clearLastRefreshedAt
          ? null
          : (lastRefreshedAt ?? this.lastRefreshedAt),
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        quantityDescription,
        expectedDays,
        createdAt,
        notificationsEnabled,
        safeThresholdDays,
        warningThresholdDays,
        urgentThresholdDays,
        lastRefreshedAt,
        notes,
      ];

  @override
  bool get stringify => true;
}
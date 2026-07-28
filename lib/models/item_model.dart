// lib/models/item_model.dart

import 'dart:convert';
import 'package:equatable/equatable.dart';

enum ItemStatus { safe, warning, urgent }

class ItemModel extends Equatable {
  final String id;
  final String name;
  final String quantityDescription;
  final int expectedDays;
  final DateTime createdAt;
  final bool notificationsEnabled;
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
      'warningThresholdDays': warningThresholdDays,
      'urgentThresholdDays': urgentThresholdDays,
      'lastRefreshedAt': lastRefreshedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory ItemModel.fromJson(String source) =>
      ItemModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    final rawNotifications = map['notificationsEnabled'];
    final bool notifications = rawNotifications is bool
        ? rawNotifications
        : ((rawNotifications as int? ?? 1) == 1);

    return ItemModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      quantityDescription: map['quantityDescription'] as String? ?? '',
      expectedDays: (map['expectedDays'] as num?)?.toInt() ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      notificationsEnabled: notifications,
      warningThresholdDays: (map['warningThresholdDays'] as num?)?.toInt() ?? 10,
      urgentThresholdDays: (map['urgentThresholdDays'] as num?)?.toInt() ?? 3,
      lastRefreshedAt: map['lastRefreshedAt'] != null
          ? DateTime.parse(map['lastRefreshedAt'] as String)
          : null,
      notes: map['notes'] as String?,
    );
  }

  // ─── Domain logic ───────────────────────────────────────────────────────────

  DateTime get expectedExpiryDate {
    final base = lastRefreshedAt ?? createdAt;
    
    // Written this way to avoid DST-related issues.
    return DateTime(
      base.year,
      base.month,
      base.day + expectedDays,
      base.hour,
      base.minute,
      base.second,
      base.millisecond,
      base.microsecond,
    );
  }

  int remainingDaysAt(DateTime now) {
    final cleanExpiry = DateTime(
      expectedExpiryDate.year,
      expectedExpiryDate.month,
      expectedExpiryDate.day,
    );

    final cleanNow = DateTime(
      now.year,
      now.month,
      now.day,
    );

    return cleanExpiry.difference(cleanNow).inDays;
  }

  int get remainingDays => remainingDaysAt(DateTime.now());

  ItemStatus statusAt(DateTime now) {
    final days = remainingDaysAt(now);
    if (days <= urgentThresholdDays) return ItemStatus.urgent;
    if (days <= warningThresholdDays) return ItemStatus.warning;
    return ItemStatus.safe;
  }

  ItemStatus get status => statusAt(DateTime.now());

  ItemModel copyWith({
    String? id,
    String? name,
    String? quantityDescription,
    int? expectedDays,
    DateTime? createdAt,
    bool? notificationsEnabled,
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
        warningThresholdDays,
        urgentThresholdDays,
        lastRefreshedAt,
        notes,
      ];

  @override
  bool get stringify => true;
}
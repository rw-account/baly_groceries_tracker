// lib/models/item_change_log_model.dart

import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'item_model.dart';

class ItemActionType {
  static const String create = 'CREATE';
  static const String update = 'UPDATE';
  static const String restock = 'RESTOCK';
  static const String stockCorrection = 'STOCK_CORRECTION';
  static const String delete = 'DELETE';
}

class ItemChangeLogModel extends Equatable {
  final int? id;
  final String itemId;
  final String actionType;
  final String timestamp; // UTC ISO-8601 string
  final String? previousState; // JSON string
  final String? newState; // JSON string
  final String? description;

  const ItemChangeLogModel({
    this.id,
    required this.itemId,
    required this.actionType,
    required this.timestamp,
    this.previousState,
    this.newState,
    this.description,
  });

  DateTime get timestampDateTime {
    try {
      return DateTime.parse(timestamp);
    } catch (_) {
      return DateTime.now();
    }
  }

  ItemModel? get parsedPreviousState {
    if (previousState == null || previousState!.trim().isEmpty) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(previousState!);
      return ItemModel.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  ItemModel? get parsedNewState {
    if (newState == null || newState!.trim().isEmpty) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(newState!);
      return ItemModel.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'item_id': itemId,
      'action_type': actionType,
      'timestamp': timestamp,
      'previous_state': previousState,
      'new_state': newState,
      'description': description,
    };
  }

  factory ItemChangeLogModel.fromMap(Map<String, dynamic> map) {
    return ItemChangeLogModel(
      id: map['id'] as int?,
      itemId: map['item_id'] as String,
      actionType: map['action_type'] as String,
      timestamp: map['timestamp'] as String,
      previousState: map['previous_state'] as String?,
      newState: map['new_state'] as String?,
      description: map['description'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        itemId,
        actionType,
        timestamp,
        previousState,
        newState,
        description,
      ];
}

// lib/router/item_loader_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item_model.dart';
import '../screens/add_edit_item/add_edit_item_screen.dart';
import 'error_screen.dart';
import 'item_by_id_provider.dart';

/// Intermediate resolver screen that supplies an [ItemModel] to [AddEditItemScreen].
///
/// Handles two flows:
/// 1) Normal in‑app navigation – the item is passed via `extra` and used immediately.
/// 2) Deep link – no `extra` was provided, so the item is fetched by [itemByIdProvider]
///    using the `itemId` extracted from the route path.
/// 
/// NOTE:
/// This screen is mainly required for deep link navigation.
/// It loads the item using `itemId` when no `extraItem` is provided,
/// then forwards it to AddEditItemScreen.
///
/// In normal in-app navigation, the item is already passed via `extraItem`,
/// so no loading is required and the screen acts as a simple passthrough
/// to AddEditItemScreen.
class ItemLoaderScreen extends ConsumerWidget {
  final String itemId;
  final ItemModel? extraItem;

  const ItemLoaderScreen({
    super.key,
    required this.itemId,
    this.extraItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    // Normal in-app navigation case:
    // If the item is already provided via `extraItem`, we don't need to fetch anything.
    // We directly forward the user to AddEditItemScreen with the existing data.
    if (extraItem != null) {
      return AddEditItemScreen(item: extraItem);
    }

    try {
      final itemAsync = ref.watch(itemByIdProvider(itemId));

      return itemAsync.when(
        data: (item) {
          if (item == null) {
            return ErrorScreen.itemNotFound(context);
          }
          return AddEditItemScreen(item: item);
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stackTrace) => const ErrorScreen(
          title: 'تعذّر تحميل العنصر',
          message: 'حدث خطأ أثناء جلب بيانات العنصر، يرجى المحاولة مرة أخرى.',
          icon: Icons.cloud_off_rounded,
        ),
      );
    } catch (_) {
      // Last line of defense: any unexpected build error is shown as a friendly
      // screen instead of crashing the app.
      return const ErrorScreen(
        title: 'تعذّر تحميل العنصر',
        message: 'حدث خطأ غير متوقع أثناء تحميل هذه الشاشة.',
        icon: Icons.error_outline_rounded,
      );
    }
  }
}

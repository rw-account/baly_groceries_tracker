// lib/screens/expiry/utils/item_list_extensions.dart

import '../../../models/item_model.dart';

extension ItemModelListX on List<ItemModel> {
  /// Items that need attention (i.e., any item whose status is not "safe").
  List<ItemModel> get needingAttention =>
      where((item) => item.status != ItemStatus.safe).toList();
}

// lib/screens/expiry/utils/item_list_extensions.dart

import '../../../models/item_model.dart';


extension ItemModelListX on List<ItemModel> {
  /// العناصر التي تحتاج إلى انتباه (أي عنصر ليست حالته "آمنة").
  List<ItemModel> get needingAttention =>
      where((item) => item.status != ItemStatus.safe).toList();
}

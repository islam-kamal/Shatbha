import '../../../../core/utils/json.dart';

class ExpenseItem {
  const ExpenseItem({
    required this.id,
    required this.entryDate,
    required this.title,
    required this.amount,
    this.categoryId,
    this.categoryName,
    this.notes,
  });

  final int id;
  final String entryDate;
  final String title;
  final String amount;
  final int? categoryId;
  final String? categoryName;
  final String? notes;

  factory ExpenseItem.fromJson(Map<String, dynamic> json) => ExpenseItem(
        id: json['id'] as int,
        entryDate: jsonDate(json['entry_date']),
        title: json['title'] as String,
        amount: jsonMoney(json['amount']),
        categoryId: json['category_id'] as int?,
        categoryName: json['category'] is Map
            ? json['category']['name'] as String?
            : null,
        notes: json['notes'] as String?,
      );
}

class CategoryTotal {
  const CategoryTotal({required this.category, required this.total});
  final String category;
  final String total;

  factory CategoryTotal.fromJson(Map<String, dynamic> json) => CategoryTotal(
        category: json['category'] as String,
        total: jsonMoney(json['total']),
      );
}

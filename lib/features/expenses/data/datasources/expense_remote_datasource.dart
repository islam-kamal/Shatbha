import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json.dart';
import '../models/expense_models.dart';

class ExpenseRemoteDatasource {
  ExpenseRemoteDatasource(this._dio);
  final Dio _dio;

  Future<(List<ExpenseItem>, String)> expenses({String? from, String? to}) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/expenses',
        queryParameters: {
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
      );
      return (
        jsonList(res.data, ExpenseItem.fromJson),
        (res.data!['total'] ?? '0.00').toString(),
      );
    });
  }

  Future<ExpenseItem> createExpense(Map<String, dynamic> body) {
    return guardDio(() async {
      final res = await _dio.post<Map<String, dynamic>>('/expenses', data: body);
      return ExpenseItem.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<List<CategoryTotal>> expensesByCategory() {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/reports/expenses');
      return jsonList(res.data, CategoryTotal.fromJson);
    });
  }
}

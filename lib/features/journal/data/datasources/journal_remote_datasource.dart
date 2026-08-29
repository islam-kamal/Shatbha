import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json.dart';
import '../models/journal_models.dart';

class JournalRemoteDatasource {
  JournalRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<JournalEntry>> customerEntries({
    String? from,
    String? to,
    int? customerId,
  }) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/customer-entries',
        queryParameters: {
          if (from != null) 'from': from,
          if (to != null) 'to': to,
          if (customerId != null) 'customer_id': customerId,
        },
      );
      return jsonList(res.data, JournalEntry.fromJson);
    });
  }

  Future<JournalEntry> createEntry(Map<String, dynamic> body) {
    return guardDio(() async {
      final res =
          await _dio.post<Map<String, dynamic>>('/customer-entries', data: body);
      return JournalEntry.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Future<StatementData> statement(int customerId, {String? from, String? to}) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/customers/$customerId/statement',
        queryParameters: {
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
      );
      return StatementData.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }
}

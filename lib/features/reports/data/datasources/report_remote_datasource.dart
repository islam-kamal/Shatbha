import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json.dart';
import '../models/report_models.dart';

class ReportRemoteDatasource {
  ReportRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<CustomerReportRow>> customerReport() {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/reports/customers');
      return jsonList(res.data, CustomerReportRow.fromJson);
    });
  }

  Future<List<ContractorReportRow>> contractorReport() {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>('/reports/contractors');
      return jsonList(res.data, ContractorReportRow.fromJson);
    });
  }

  Future<IncomeStatement> incomeStatement({String? from, String? to}) {
    return guardDio(() async {
      final res = await _dio.get<Map<String, dynamic>>(
        '/reports/income-statement',
        queryParameters: {
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
      );
      return IncomeStatement.fromJson(res.data!['data'] as Map<String, dynamic>);
    });
  }
}

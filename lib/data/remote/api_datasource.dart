import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import '../models/models.dart';

class ApiDatasource {
  ApiDatasource(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/login',
        data: {'email': email, 'password': password},
      );
      return res.data!;
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<AuthUser> me() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/me');
      return AuthUser.fromJson(res.data!['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post<void>('/logout');
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<CompanyInfo> company() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/company');
      return CompanyInfo.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<CompanyInfo> updateCompany(Map<String, dynamic> body) async {
    try {
      final res = await _dio.put<Map<String, dynamic>>('/company', data: body);
      return CompanyInfo.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<List<Party>> parties(String type) async {
    try {
      final path = type == 'contractor' ? '/contractors' : '/customers';
      final res = await _dio.get<Map<String, dynamic>>(path);
      return _list(res.data, Party.fromJson);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<Party> createParty(Map<String, dynamic> body) async {
    try {
      final path = body['type'] == 'contractor' ? '/contractors' : '/customers';
      final res = await _dio.post<Map<String, dynamic>>(path, data: body);
      return Party.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<List<NamedItem>> workTypes() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/work-types');
      return _list(res.data, NamedItem.fromJson);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<NamedItem> createWorkType(String name) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/work-types',
        data: {'name': name},
      );
      return NamedItem.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<List<NamedItem>> expenseCategories() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/expense-categories');
      return _list(res.data, NamedItem.fromJson);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<NamedItem> createExpenseCategory(String name) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/expense-categories',
        data: {'name': name},
      );
      return NamedItem.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<List<JournalEntry>> customerEntries({
    String? from,
    String? to,
    int? customerId,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/customer-entries',
        queryParameters: {
          if (from != null) 'from': from,
          if (to != null) 'to': to,
          if (customerId != null) 'customer_id': customerId,
        },
      );
      return _list(res.data, JournalEntry.fromJson);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<JournalEntry> createEntry(Map<String, dynamic> body) async {
    try {
      final res =
          await _dio.post<Map<String, dynamic>>('/customer-entries', data: body);
      return JournalEntry.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<StatementData> statement(int customerId, {String? from, String? to}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/customers/$customerId/statement',
        queryParameters: {
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
      );
      return StatementData.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<(List<ExpenseItem>, String)> expenses({String? from, String? to}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/expenses',
        queryParameters: {
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
      );
      return (
        _list(res.data, ExpenseItem.fromJson),
        (res.data!['total'] ?? '0.00').toString(),
      );
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<ExpenseItem> createExpense(Map<String, dynamic> body) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>('/expenses', data: body);
      return ExpenseItem.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<List<CategoryTotal>> expensesByCategory() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/reports/expenses');
      return _list(res.data, CategoryTotal.fromJson);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<List<ContractorJob>> jobs() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/jobs');
      return _list(res.data, ContractorJob.fromJson);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<ContractorJob> createJob(Map<String, dynamic> body) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>('/jobs', data: body);
      return ContractorJob.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<ContractorJob> payJob(int jobId, Map<String, dynamic> body) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/jobs/$jobId/payments',
        data: body,
      );
      return ContractorJob.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<List<CustomerReportRow>> customerReport() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/reports/customers');
      return _list(res.data, CustomerReportRow.fromJson);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<List<ContractorReportRow>> contractorReport() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/reports/contractors');
      return _list(res.data, ContractorReportRow.fromJson);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<IncomeStatement> incomeStatement({String? from, String? to}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/reports/income-statement',
        queryParameters: {
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
      );
      return IncomeStatement.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  Future<void> replay(String method, String path, Map<String, dynamic> body) async {
    try {
      await _dio.request<void>(
        path,
        data: body,
        options: Options(method: method),
      );
    } on DioException catch (e) {
      throw mapDio(e);
    }
  }

  List<T> _list<T>(
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>) parse,
  ) {
    final rows = data?['data'] as List<dynamic>? ?? const [];
    return rows.map((e) => parse(e as Map<String, dynamic>)).toList();
  }
}

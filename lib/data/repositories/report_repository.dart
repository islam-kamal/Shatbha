import '../models/models.dart';
import '../remote/api_datasource.dart';

class ReportRepository {
  ReportRepository(this._api);
  final ApiDatasource _api;

  Future<List<CustomerReportRow>> customers() => _api.customerReport();

  Future<List<ContractorReportRow>> contractors() => _api.contractorReport();

  Future<IncomeStatement> incomeStatement({String? from, String? to}) {
    return _api.incomeStatement(from: from, to: to);
  }
}

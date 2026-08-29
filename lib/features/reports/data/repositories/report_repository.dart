import '../datasources/report_remote_datasource.dart';
import '../models/report_models.dart';

class ReportRepository {
  ReportRepository(this._api);
  final ReportRemoteDatasource _api;

  Future<List<CustomerReportRow>> customers() => _api.customerReport();

  Future<List<ContractorReportRow>> contractors() => _api.contractorReport();

  Future<IncomeStatement> incomeStatement({String? from, String? to}) {
    return _api.incomeStatement(from: from, to: to);
  }
}

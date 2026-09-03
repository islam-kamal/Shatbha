import '../datasources/quote_remote_datasource.dart';
import '../models/quote_models.dart';

class QuoteRepository {
  QuoteRepository(this._api);
  final QuoteRemoteDatasource _api;

  Future<List<QuoteRequest>> list({int? projectId}) =>
      _api.list(projectId: projectId);

  Future<QuoteRequest> create(Map<String, dynamic> body) => _api.create(body);

  Future<QuoteRequest> respond(int id, Map<String, dynamic> body) =>
      _api.respond(id, body);

  Future<QuoteRequest> accept(int id) => _api.accept(id);

  Future<QuoteRequest> reject(int id) => _api.reject(id);

  Future<QuoteRequest> get(int id) => _api.get(id);
}

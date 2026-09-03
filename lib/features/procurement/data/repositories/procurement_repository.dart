import '../datasources/procurement_remote_datasource.dart';
import '../models/procurement_models.dart';

class ProcurementRepository {
  ProcurementRepository(this._api);
  final ProcurementRemoteDatasource _api;

  Future<List<PurchaseOrder>> list({int? projectId}) =>
      _api.purchaseOrders(projectId: projectId);

  Future<PurchaseOrder> create(Map<String, dynamic> body) =>
      _api.createPurchaseOrder(body);

  Future<PurchaseOrder> get(int id) => _api.getPurchaseOrder(id);

  Future<GoodsReceipt> receive(int poId, Map<String, dynamic> body) =>
      _api.receiveGoods(poId, body);
}

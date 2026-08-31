import '../datasources/warehouse_remote_datasource.dart';
import '../models/warehouse_models.dart';

class WarehouseRepository {
  WarehouseRepository(this._api);
  final WarehouseRemoteDatasource _api;

  Future<List<Warehouse>> warehouses() => _api.warehouses();

  Future<Warehouse> createWarehouse(Map<String, dynamic> body) =>
      _api.createWarehouse(body);

  Future<List<StockLevel>> stock({int? warehouseId}) =>
      _api.stock(warehouseId: warehouseId);

  Future<StockMovement> moveStock(Map<String, dynamic> body) =>
      _api.createMovement(body);

  Future<DeliveryNote> deliveryNote(Map<String, dynamic> body) =>
      _api.createDeliveryNote(body);
}

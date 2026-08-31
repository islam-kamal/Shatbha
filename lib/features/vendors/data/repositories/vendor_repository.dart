import '../datasources/vendor_remote_datasource.dart';
import '../models/vendor_models.dart';

class VendorRepository {
  VendorRepository(this._api);
  final VendorRemoteDatasource _api;

  Future<List<Vendor>> list({String? type}) => _api.list(type: type);

  Future<Vendor> get(int id) => _api.get(id);

  Future<List<Review>> reviews({int? vendorId}) =>
      _api.reviews(vendorId: vendorId);

  Future<Review> createReview(Map<String, dynamic> body) =>
      _api.createReview(body);
}

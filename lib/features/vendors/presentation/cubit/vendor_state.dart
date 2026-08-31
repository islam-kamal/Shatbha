import 'package:equatable/equatable.dart';

import '../../data/models/vendor_models.dart';

class VendorState extends Equatable {
  const VendorState({
    this.loading = false,
    this.vendors = const [],
    this.selected,
    this.reviews = const [],
    this.filterType = 'contractor',
    this.error,
  });

  final bool loading;
  final List<Vendor> vendors;
  final Vendor? selected;
  final List<Review> reviews;
  final String filterType;
  final String? error;

  List<Vendor> get filtered => vendors
      .where((v) => v.type == filterType)
      .toList(growable: false);

  VendorState copyWith({
    bool? loading,
    List<Vendor>? vendors,
    Vendor? selected,
    List<Review>? reviews,
    String? filterType,
    String? error,
  }) {
    return VendorState(
      loading: loading ?? this.loading,
      vendors: vendors ?? this.vendors,
      selected: selected ?? this.selected,
      reviews: reviews ?? this.reviews,
      filterType: filterType ?? this.filterType,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [loading, vendors, selected, reviews, filterType, error];
}

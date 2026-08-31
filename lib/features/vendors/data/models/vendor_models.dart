class Vendor {
  const Vendor({
    required this.id,
    required this.name,
    required this.type,
    this.phone,
    this.email,
    this.rating = 0,
    this.reviewCount = 0,
    this.specialties = const [],
    this.logoUrl,
    this.description,
    this.location,
  });

  final int id;
  final String name;
  final String type;
  final String? phone;
  final String? email;
  final double rating;
  final int reviewCount;
  final List<String> specialties;
  final String? logoUrl;
  final String? description;
  final String? location;

  bool get isContractor => type == 'contractor';
  bool get isSupplier => type == 'supplier';

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
        id: json['id'] as int,
        name: json['name'] as String,
        type: json['type'] as String? ?? 'contractor',
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: json['review_count'] as int? ?? 0,
        specialties: (json['specialties'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        logoUrl: json['logo_url'] as String?,
        description: json['description'] as String?,
        location: json['location'] as String?,
      );
}

class Review {
  const Review({
    required this.id,
    required this.vendorId,
    required this.rating,
    this.comment,
    this.authorName,
    this.createdAt,
  });

  final int id;
  final int vendorId;
  final int rating;
  final String? comment;
  final String? authorName;
  final String? createdAt;

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as int,
        vendorId: json['vendor_id'] as int,
        rating: json['rating'] as int,
        comment: json['comment'] as String?,
        authorName: json['author_name'] as String?,
        createdAt: json['created_at']?.toString(),
      );
}

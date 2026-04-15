class PremiumPlanModel {
  final String id;
  final String title;
  final String description;
  final String priceId;
  final num price;
  final String duration;
  final String paymentType;
  final String productId;
  final String paymentLink;
  final String status;
  final Limits limits;

  PremiumPlanModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priceId,
    required this.price,
    required this.duration,
    required this.paymentType,
    required this.productId,
    required this.paymentLink,
    required this.status,
    required this.limits,
  });

  factory PremiumPlanModel.fromJson(Map<String, dynamic> json) {
    return PremiumPlanModel(
      id: json['_id'] ?? '',
      title: json['name'] ?? '',
      description: json['description'] ?? '',
      priceId: json['stripePriceId'] ?? '',
      price: json['price'] ?? 0,
      duration: json['interval'] ?? '',
      paymentType: json['tier'] ?? '',
      productId: json['stripeProductId'] ?? '',
      paymentLink: json['paymentLink'] ?? '',
      status: (json['isActive'] ?? false) ? 'active' : 'inactive',
      limits: Limits.fromJson(json), // Passing the whole json since limits are top-level
    );
  }
}

class Limits {
  final int reelsPerWeek;
  final int postsPerWeek;
  final int storiesPerWeek;
  final int businessesManageable;
  final int carouselPerWeek;

  Limits({
    required this.reelsPerWeek,
    required this.postsPerWeek,
    required this.storiesPerWeek,
    required this.businessesManageable,
    required this.carouselPerWeek,
  });

  factory Limits.fromJson(Map<String, dynamic> json) {
    return Limits(
      reelsPerWeek: json['reelsPerWeek'] ?? 0,
      postsPerWeek: json['postsPerWeek'] ?? 0,
      storiesPerWeek: json['storiesPerWeek'] ?? 0,
      businessesManageable: json['businessesManageable'] ?? 0,
      carouselPerWeek: json['carouselPerWeek'] ?? 0,
    );
  }
}

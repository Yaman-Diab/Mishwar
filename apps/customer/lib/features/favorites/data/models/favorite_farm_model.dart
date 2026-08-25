import '../../domain/entities/favorite_farm_entity.dart';

class FavoriteFarmModel extends FavoriteFarmEntity {
  const FavoriteFarmModel({
    required super.farmId,
    required super.name,
    required super.region,
    required super.pricePerDay,
    required super.isVerified,
    required super.rating,
  });

  /// [map] صف من `favorites` مع علاقة `farms` مضمَّنة عبر
  /// `.select('farm_id, farms(name, region, price_per_day, status)')`.
  factory FavoriteFarmModel.fromMap(Map<String, dynamic> map) {
    final farm = map['farms'] as Map<String, dynamic>;
    return FavoriteFarmModel(
      farmId: map['farm_id'] as String,
      name: farm['name'] as String? ?? '',
      region: farm['region'] as String?,
      pricePerDay: (farm['price_per_day'] as num?)?.toDouble() ?? 0,
      isVerified: farm['status'] == 'verified',
      rating: null,
    );
  }
}

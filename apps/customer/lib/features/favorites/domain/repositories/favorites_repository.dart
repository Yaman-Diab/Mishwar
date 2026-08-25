import 'package:dartz/dartz.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../entities/favorite_farm_entity.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<FavoriteFarmEntity>>> getFavorites();

  /// عملية idempotent — إعادة إضافة مزرعة مفضّلة أصلاً لا تُعتبر فشلاً
  /// (قيد UNIQUE على `(customer_id, farm_id)` يُعامَل كنجاح صامت).
  Future<Either<Failure, void>> addFavorite(String farmId);

  Future<Either<Failure, void>> removeFavorite(String farmId);
}

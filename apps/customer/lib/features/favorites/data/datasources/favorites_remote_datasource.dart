import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_logger.dart';
import '../models/favorite_farm_model.dart';

@lazySingleton
class FavoritesRemoteDataSource {
  final SupabaseClient _client;

  const FavoritesRemoteDataSource(this._client);

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const ServerException('favorites_error_generic');
    return id;
  }

  Future<List<FavoriteFarmModel>> getFavorites() async {
    try {
      final rows = await _client
          .from(SupabaseTables.favorites)
          .select('farm_id, farms(name, region, price_per_day, status)')
          .eq('customer_id', _userId);
      return (rows as List)
          .map((row) => FavoriteFarmModel.fromMap(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e, st) {
      appLogger.e('getFavorites failed', error: e, stackTrace: st);
      throw const ServerException('favorites_error_generic');
    }
  }

  Future<void> addFavorite(String farmId) async {
    try {
      await _client.from(SupabaseTables.favorites).insert({
        'customer_id': _userId,
        'farm_id': farmId,
      });
    } on PostgrestException catch (e, st) {
      // 23505 = unique_violation — مفضّلة أصلاً، هذا نجاح صامت لا خطأ.
      if (e.code == '23505') return;
      appLogger.e('addFavorite failed', error: e, stackTrace: st);
      throw const ServerException('favorites_error_generic');
    }
  }

  Future<void> removeFavorite(String farmId) async {
    try {
      await _client
          .from(SupabaseTables.favorites)
          .delete()
          .eq('customer_id', _userId)
          .eq('farm_id', farmId);
    } on PostgrestException catch (e, st) {
      appLogger.e('removeFavorite failed', error: e, stackTrace: st);
      throw const ServerException('favorites_error_generic');
    }
  }
}

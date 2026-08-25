import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../domain/entities/favorite_farm_entity.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/remove_favorite.dart';
import 'favorites_state.dart';

/// إزالة "متفائلة" (Optimistic) مع مهلة تراجع: [removeOptimistically]
/// تُخفي العنصر من القائمة فوراً بلا نداء خادم؛ [undoRemoval] يعيده
/// بلا أي نداء خادم أيضاً (لم يُحذف فعلياً بعد)؛ [commitPendingRemoval]
/// هو الوحيد الذي يحذف فعلياً من `favorites` — يُستدعى من الصفحة عند
/// إغلاق SnackBar التراجع بغير زر "تراجع" (مهلة/سحب/إلخ).
@injectable
class FavoritesCubit extends Cubit<FavoritesState> {
  final GetFavorites _getFavorites;
  final RemoveFavorite _removeFavorite;

  FavoritesCubit(this._getFavorites, this._removeFavorite) : super(const FavoritesState());

  Future<void> load() async {
    emit(state.copyWith(loading: true, errorMessageKey: null));
    final result = await _getFavorites(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(loading: false, errorMessageKey: failure.message)),
      (favorites) => emit(state.copyWith(loading: false, favorites: favorites)),
    );
  }

  void removeOptimistically(FavoriteFarmEntity farm) {
    final index = state.favorites.indexOf(farm);
    if (index < 0) return;

    // لو في إزالة سابقة معلَّقة، ثبّتها فعلياً أولاً — لا يمكن أن يبقى
    // أكثر من إزالة واحدة "معلَّقة" بآن واحد.
    if (state.pendingRemoval != null) {
      commitPendingRemoval();
    }

    final updated = List<FavoriteFarmEntity>.of(state.favorites)..removeAt(index);
    emit(
      state.copyWith(
        favorites: updated,
        pendingRemoval: farm,
        pendingRemovalIndex: index,
      ),
    );
  }

  void undoRemoval() {
    final pending = state.pendingRemoval;
    final index = state.pendingRemovalIndex;
    if (pending == null || index == null) return;

    final updated = List<FavoriteFarmEntity>.of(state.favorites)
      ..insert(index.clamp(0, state.favorites.length), pending);
    emit(state.copyWith(favorites: updated, clearPending: true));
  }

  Future<void> commitPendingRemoval() async {
    final pending = state.pendingRemoval;
    final index = state.pendingRemovalIndex;
    if (pending == null) return;

    final result = await _removeFavorite(RemoveFavoriteParams(farmId: pending.farmId));
    result.fold(
      (failure) {
        // فشل الحذف فعلياً بالخادم — نعيد العنصر لمكانه بدل ترك تناقض
        // صامت بين ما تعرضه الواجهة وما هو محفوظ فعلياً.
        final restored = List<FavoriteFarmEntity>.of(state.favorites)
          ..insert((index ?? 0).clamp(0, state.favorites.length), pending);
        emit(
          state.copyWith(
            favorites: restored,
            errorMessageKey: failure.message,
            clearPending: true,
          ),
        );
      },
      (_) => emit(state.copyWith(clearPending: true)),
    );
  }

  @override
  Future<void> close() {
    // المستخدم غادر الشاشة أثناء مهلة التراجع — نُثبّت الحذف فعلياً
    // بدل تركه معلَّقاً للأبد (بلا emit لاحق، Cubit مغلق أصلاً).
    final pending = state.pendingRemoval;
    if (pending != null) {
      _removeFavorite(RemoveFavoriteParams(farmId: pending.farmId));
    }
    return super.close();
  }
}

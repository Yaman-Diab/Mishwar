import 'package:equatable/equatable.dart';

import '../../domain/entities/favorite_farm_entity.dart';

class FavoritesState extends Equatable {
  final List<FavoriteFarmEntity> favorites;
  final bool loading;
  final String? errorMessageKey;
  final FavoriteFarmEntity? pendingRemoval;
  final int? pendingRemovalIndex;

  const FavoritesState({
    this.favorites = const [],
    this.loading = false,
    this.errorMessageKey,
    this.pendingRemoval,
    this.pendingRemovalIndex,
  });

  FavoritesState copyWith({
    List<FavoriteFarmEntity>? favorites,
    bool? loading,
    String? errorMessageKey,
    FavoriteFarmEntity? pendingRemoval,
    int? pendingRemovalIndex,
    bool clearPending = false,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      loading: loading ?? this.loading,
      errorMessageKey: errorMessageKey,
      pendingRemoval: clearPending ? null : (pendingRemoval ?? this.pendingRemoval),
      pendingRemovalIndex: clearPending ? null : (pendingRemovalIndex ?? this.pendingRemovalIndex),
    );
  }

  @override
  List<Object?> get props => [
    favorites,
    loading,
    errorMessageKey,
    pendingRemoval,
    pendingRemovalIndex,
  ];
}

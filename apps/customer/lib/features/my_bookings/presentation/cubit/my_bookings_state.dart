import 'package:equatable/equatable.dart';

import '../../../booking/domain/entities/booking_entity.dart';

class MyBookingsState extends Equatable {
  final List<BookingEntity> bookings;
  final bool loading;
  final String? errorMessageKey;

  const MyBookingsState({
    this.bookings = const [],
    this.loading = false,
    this.errorMessageKey,
  });

  MyBookingsState copyWith({
    List<BookingEntity>? bookings,
    bool? loading,
    String? errorMessageKey,
  }) {
    return MyBookingsState(
      bookings: bookings ?? this.bookings,
      loading: loading ?? this.loading,
      errorMessageKey: errorMessageKey,
    );
  }

  @override
  List<Object?> get props => [bookings, loading, errorMessageKey];
}

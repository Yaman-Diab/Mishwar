import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../domain/usecases/get_my_bookings.dart';
import 'my_bookings_state.dart';

@injectable
class MyBookingsCubit extends Cubit<MyBookingsState> {
  final GetMyBookings _getMyBookings;

  MyBookingsCubit(this._getMyBookings) : super(const MyBookingsState(loading: true)) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true, errorMessageKey: null));
    final result = await _getMyBookings(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(loading: false, errorMessageKey: failure.message)),
      (bookings) => emit(state.copyWith(loading: false, bookings: bookings, errorMessageKey: null)),
    );
  }
}

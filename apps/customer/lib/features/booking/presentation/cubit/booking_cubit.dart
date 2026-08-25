import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/booking_entity.dart';
import '../../domain/usecases/cancel_booking_request.dart';
import '../../domain/usecases/get_booking_status.dart';
import '../../domain/usecases/get_farm_availability.dart';
import '../../domain/usecases/request_booking.dart';
import 'booking_state.dart';

/// يدير تدفّق الحجز الكامل: تحميل التوفر ← إرسال الطلب (عبر دالة
/// `request_booking` الذرية) ← تتبّع القفل المؤقت حتى يردّ المالك أو
/// تنتهي المهلة. القرار النهائي بشأن "منتهي/مؤكَّد/مرفوض" **دائماً**
/// من إعادة جلب الحجز من الخادم، لا من وصول العدّاد المحلي للصفر —
/// راجع توثيق [BookingStatus] لتفصيل هذا القيد.
@injectable
class BookingCubit extends Cubit<BookingState> {
  final GetFarmAvailability _getFarmAvailability;
  final RequestBooking _requestBooking;
  final GetBookingStatus _getBookingStatus;
  final CancelBookingRequest _cancelBookingRequest;

  Timer? _countdownTimer;
  Timer? _pollTimer;

  BookingCubit(
    this._getFarmAvailability,
    this._requestBooking,
    this._getBookingStatus,
    this._cancelBookingRequest,
  ) : super(const BookingState());

  Future<void> loadAvailability({
    required String farmId,
    required DateTime from,
    required DateTime to,
  }) async {
    emit(state.copyWith(loadingAvailability: true, errorMessageKey: null));
    final result = await _getFarmAvailability(
      GetFarmAvailabilityParams(farmId: farmId, from: from, to: to),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(loadingAvailability: false, errorMessageKey: failure.message),
      ),
      (days) => emit(state.copyWith(loadingAvailability: false, availability: days)),
    );
  }

  Future<void> submit({
    required String farmId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
  }) async {
    if (state.submitting) return;
    emit(state.copyWith(submitting: true, errorMessageKey: null, conflict: false));

    final result = await _requestBooking(
      RequestBookingParams(farmId: farmId, checkIn: checkIn, checkOut: checkOut, guests: guests),
    );

    result.fold(
      (failure) {
        if (failure.message == 'booking_error_dates_unavailable') {
          emit(state.copyWith(submitting: false, conflict: true));
        } else {
          emit(state.copyWith(submitting: false, errorMessageKey: failure.message));
        }
      },
      (booking) {
        emit(
          state.copyWith(
            submitting: false,
            step: BookingStep.awaiting,
            booking: booking,
          ),
        );
        _startTracking(booking);
      },
    );
  }

  void _startTracking(BookingEntity booking) {
    _clearTimers();

    void tick() {
      final expires = booking.lockExpiresAt;
      final remaining = expires == null
          ? Duration.zero
          : expires.difference(DateTime.now());
      if (remaining <= Duration.zero) {
        emit(state.copyWith(remaining: Duration.zero, verifyingExpiry: true));
      } else {
        emit(state.copyWith(remaining: remaining));
      }
    }

    tick();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => tick());

    // فحص دوري لحالة الحجز الفعلية بالخادم — كل 8 ثوانٍ عادةً، وأسرع
    // (3 ثوانٍ) بعد وصول العدّاد للصفر بانتظار قرار الخادم النهائي.
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) => _pollStatus());
  }

  Future<void> _pollStatus() async {
    final booking = state.booking;
    if (booking == null || state.step != BookingStep.awaiting) return;

    final result = await _getBookingStatus(GetBookingStatusParams(bookingId: booking.id));
    result.fold(
      (_) {}, // فشل مؤقت بالشبكة — نحاول مجدداً بالجولة القادمة، لا نعرض خطأ يقاطع الانتظار
      (updated) {
        if (updated.status != BookingStatus.pending) {
          _clearTimers();
          emit(
            state.copyWith(
              step: BookingStep.resolved,
              booking: updated,
              verifyingExpiry: false,
            ),
          );
          return;
        }

        // ما زال pending فعلياً بالخادم رغم انتهاء العدّاد المحلي —
        // نسرّع الفحص وننتظر قرار pg_cron بدل افتراض الانتهاء بأنفسنا.
        if (state.verifyingExpiry) {
          _pollTimer?.cancel();
          _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pollStatus());
        }
      },
    );
  }

  Future<void> cancelRequest() async {
    final booking = state.booking;
    if (booking == null) return;
    _clearTimers();
    await _cancelBookingRequest(CancelBookingRequestParams(bookingId: booking.id));
    emit(const BookingState());
  }

  void retry() {
    _clearTimers();
    emit(const BookingState());
  }

  void _clearTimers() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    _countdownTimer = null;
    _pollTimer = null;
  }

  @override
  Future<void> close() {
    _clearTimers();
    return super.close();
  }
}

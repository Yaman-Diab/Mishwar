import 'package:equatable/equatable.dart';

import '../../domain/entities/availability_day_entity.dart';
import '../../domain/entities/booking_entity.dart';

enum BookingStep { selecting, awaiting, resolved }

class BookingState extends Equatable {
  final BookingStep step;
  final List<AvailabilityDayEntity> availability;
  final bool loadingAvailability;
  final bool submitting;
  final String? errorMessageKey;
  final bool conflict;
  final BookingEntity? booking;
  final Duration remaining;

  /// true فقط باللحظة اللي توصل فيها العدّ التنازلي للصفر وننتظر رد
  /// خادم يؤكّد الحالة الفعلية — لا نفترض "منتهي" من طرف العميل.
  final bool verifyingExpiry;

  const BookingState({
    this.step = BookingStep.selecting,
    this.availability = const [],
    this.loadingAvailability = false,
    this.submitting = false,
    this.errorMessageKey,
    this.conflict = false,
    this.booking,
    this.remaining = Duration.zero,
    this.verifyingExpiry = false,
  });

  BookingState copyWith({
    BookingStep? step,
    List<AvailabilityDayEntity>? availability,
    bool? loadingAvailability,
    bool? submitting,
    String? errorMessageKey,
    bool? conflict,
    BookingEntity? booking,
    Duration? remaining,
    bool? verifyingExpiry,
  }) {
    return BookingState(
      step: step ?? this.step,
      availability: availability ?? this.availability,
      loadingAvailability: loadingAvailability ?? this.loadingAvailability,
      submitting: submitting ?? this.submitting,
      errorMessageKey: errorMessageKey,
      conflict: conflict ?? this.conflict,
      booking: booking ?? this.booking,
      remaining: remaining ?? this.remaining,
      verifyingExpiry: verifyingExpiry ?? this.verifyingExpiry,
    );
  }

  @override
  List<Object?> get props => [
    step,
    availability,
    loadingAvailability,
    submitting,
    errorMessageKey,
    conflict,
    booking,
    remaining,
    verifyingExpiry,
  ];
}

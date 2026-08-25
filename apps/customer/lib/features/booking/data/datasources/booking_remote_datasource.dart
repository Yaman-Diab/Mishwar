import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_logger.dart';
import '../models/availability_day_model.dart';
import '../models/booking_model.dart';

@lazySingleton
class BookingRemoteDataSource {
  final SupabaseClient _client;

  const BookingRemoteDataSource(this._client);

  Future<List<AvailabilityDayModel>> getFarmAvailability({
    required String farmId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final rows = await _client
          .from(SupabaseTables.availabilityDays)
          .select()
          .eq('farm_id', farmId)
          .gte('day', _dateOnly(from))
          .lte('day', _dateOnly(to));
      return (rows as List)
          .map((row) => AvailabilityDayModel.fromMap(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e, st) {
      appLogger.e('getFarmAvailability failed', error: e, stackTrace: st);
      throw const ServerException('booking_error_generic');
    }
  }

  /// ⚠️ الدالة `request_booking(p_farm_id, p_check_in, p_check_out,
  /// p_guests) returns uuid` يجب أن تكون منفَّذة فعلياً بمشروع Supabase
  /// (راجع Dev_Kickoff_Guide) — هذا الاستدعاء يطابق توقيعها بالضبط ولا
  /// يخترع منطقاً بديلاً. الدالة **لا تحسب** `total_price`؛ نعيد جلب
  /// الحجز فقط بعد النجاح، والسعر المعروض بالواجهة محسوب بالعميل
  /// (ليالٍ × سعر اليوم) للعرض فقط لا للتخزين.
  Future<BookingModel> requestBooking({
    required String farmId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
  }) async {
    try {
      final bookingId = await _client.rpc(
        'request_booking',
        params: {
          'p_farm_id': farmId,
          'p_check_in': _dateOnly(checkIn),
          'p_check_out': _dateOnly(checkOut),
          'p_guests': guests,
        },
      ) as String;
      return getBooking(bookingId);
    } on PostgrestException catch (e, st) {
      if (e.message.contains('DATES_NOT_AVAILABLE')) {
        throw const ServerException('booking_error_dates_unavailable');
      }
      appLogger.e('requestBooking failed', error: e, stackTrace: st);
      throw const ServerException('booking_error_generic');
    }
  }

  Future<BookingModel> getBooking(String bookingId) async {
    try {
      final row = await _client
          .from(SupabaseTables.bookings)
          .select('*, farms(name)')
          .eq('id', bookingId)
          .single();
      return BookingModel.fromMap(row);
    } on PostgrestException catch (e, st) {
      appLogger.e('getBooking failed', error: e, stackTrace: st);
      throw const ServerException('booking_error_generic');
    }
  }

  /// ⚠️ لا توجد دالة إلغاء ذرّية موثّقة (بخلاف `request_booking`) —
  /// هذا تحديث مباشر لعمود `status` يعتمد على RLS لضمان أن العميل
  /// يلغي حجزه هو فقط (`customer_id = auth.uid()`).
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _client
          .from(SupabaseTables.bookings)
          .update({'status': 'cancelled'})
          .eq('id', bookingId);
    } on PostgrestException catch (e, st) {
      appLogger.e('cancelBooking failed', error: e, stackTrace: st);
      throw const ServerException('booking_error_generic');
    }
  }

  Future<List<BookingModel>> getMyBookings() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const ServerException('booking_error_generic');
    }
    try {
      final rows = await _client
          .from(SupabaseTables.bookings)
          .select('*, farms(name)')
          .eq('customer_id', userId)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((row) => BookingModel.fromMap(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e, st) {
      appLogger.e('getMyBookings failed', error: e, stackTrace: st);
      throw const ServerException('booking_error_generic');
    }
  }

  String _dateOnly(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}

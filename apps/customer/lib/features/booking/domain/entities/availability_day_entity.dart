import 'package:equatable/equatable.dart';

enum DayStatus { available, reserved, booked, blocked }

class AvailabilityDayEntity extends Equatable {
  final DateTime day;
  final DayStatus status;

  const AvailabilityDayEntity({required this.day, required this.status});

  bool get isBookable => status == DayStatus.available;

  @override
  List<Object?> get props => [day, status];
}

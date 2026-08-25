import '../../domain/entities/availability_day_entity.dart';

class AvailabilityDayModel extends AvailabilityDayEntity {
  const AvailabilityDayModel({required super.day, required super.status});

  factory AvailabilityDayModel.fromMap(Map<String, dynamic> map) {
    return AvailabilityDayModel(
      day: DateTime.parse(map['day'] as String),
      status: DayStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => DayStatus.available,
      ),
    );
  }
}

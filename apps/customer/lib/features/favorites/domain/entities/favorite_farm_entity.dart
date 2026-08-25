import 'package:equatable/equatable.dart';

class FavoriteFarmEntity extends Equatable {
  final String farmId;
  final String name;
  final String? region;
  final double pricePerDay;
  final bool isVerified;

  /// ⚠️ لا عمود تقييم مجمَّع بجدول `farms` الموثّق — يحتاج استعلام
  /// تجميعي على `reviews` أو Materialized View غير موجودة بعد. يبقى
  /// null حتى ذلك، والواجهة تُخفي شارة التقييم حينها (مطابق لسلوك
  /// التصميم نفسه مع المزرعة الرابعة التجريبية بلا تقييم).
  final double? rating;

  const FavoriteFarmEntity({
    required this.farmId,
    required this.name,
    required this.region,
    required this.pricePerDay,
    required this.isVerified,
    required this.rating,
  });

  @override
  List<Object?> get props => [farmId, name, region, pricePerDay, isVerified, rating];
}

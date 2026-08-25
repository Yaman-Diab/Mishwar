import 'package:intl/intl.dart';

/// تنسيق مبالغ الليرة السورية حسب لغة الواجهة — مكان واحد يُستخدم من
/// أي ميزة تحسب سعراً فعلياً (بدل نصوص أسعار جاهزة كبيانات تجريبية).
class PriceFormatter {
  const PriceFormatter._();

  static String syp(num amount, {required String localeCode}) {
    final formatted = NumberFormat.decimalPattern(localeCode).format(amount.round());
    return localeCode.startsWith('ar') ? '$formatted ل.س' : '$formatted SYP';
  }
}

import 'package:logger/logger.dart';

/// نسخة واحدة مشتركة — تُستخدم فقط بنقاط تُبتلع فيها استثناءات حقيقية
/// (مثل أخطاء Supabase الخام بطبقة الـdata) قبل تحويلها لمفتاح ترجمة
/// عام لا يحمل أي تفاصيل تشخيصية. ليست أداة تسجيل عامة لكل الطبقات.
final Logger appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.none,
  ),
);

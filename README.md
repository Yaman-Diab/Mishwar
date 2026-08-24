# مشوار — Monorepo

منصة حجز مزارع واستراحات ريفية بسوريا. حسب SRS القسم 2.4، النظام مبني من
ثلاث واجهات مستقلة تتشارك خلفية Supabase واحدة:

```
mishwar/
├── apps/
│   ├── customer/    تطبيق العميل (Flutter، جوال) — قيد التطوير حالياً
│   ├── owner/        تطبيق صاحب المزرعة (Flutter، جوال) — لم يُبدأ بعد
│   └── admin/        لوحة تحكم الإدارة (Flutter Web) — لم يُبدأ بعد
└── packages/
    └── mashwar_core/ الحزمة المشتركة بين التطبيقات الثلاث
```

## `packages/mashwar_core`

يعتمد عليها كل تطبيق عبر `path` dependency. تحتوي **فقط** ما هو عام
فعلاً وله أكثر من مستهلك:

- `theme/` — الهوية البصرية (فاتح/داكن) عبر `ThemeExtension`
- `error/` — `Failure` و`Exception` الأساسية
- `usecase/` — عقد `UseCase<ResultType, Params>`
- `widgets/` — `AppButton`, `AppCard`
- `utils/` — `Validators`
- `constants/` — أسماء جداول Supabase

**لا** تحتوي `di/` ولا `router/` ولا أي `features/` — هذه تبقى مستقلة
بكل تطبيق (كل تطبيق له مساراته وميزاته وربط DI الخاص به)، حسب قاعدة
"لا تُشارك feature استباقياً، فقط لما يصير عندها أكثر من مستهلك فعلي".

الحزمة تستخدم `easy_localization`، `flutter_screenutil`، `dartz`،
`equatable` — على كل تطبيق يستهلكها أن يهيّئ `EasyLocalization` و
`ScreenUtilInit` بنفسه (المفاتيح النصية التي يتوقعها `Validators` لازم
تكون موجودة بترجمات كل تطبيق: `validation_email_required` وأخواتها).

## التعديل على `mashwar_core`

أي تغيير هنا ينعكس على كل التطبيقات فوراً (path dependency، لا حاجة
لنشر إصدار). بعد أي تعديل: `flutter pub get` بكل تطبيق يستهلكها.

## `apps/owner` و`apps/admin`

سيُبنيان بنفس أسلوب `apps/customer` (Clean Architecture + Cubit +
get_it/injectable) فور البدء بهما — راجع [apps/owner/README.md](apps/owner/README.md)
و[apps/admin/README.md](apps/admin/README.md).

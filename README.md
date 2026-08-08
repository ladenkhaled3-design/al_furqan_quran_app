<div align="center">

# 📖 تطبيق الفرقان | Al-Furqan Quran App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![State Management](https://img.shields.io/badge/Riverpod-3.x-0553B1?style=for-the-badge&logo=flutter&logoColor=white)](https://riverpod.dev)
[![Architecture](https://img.shields.io/badge/Clean%20Architecture-Feature--Sliced-green?style=for-the-badge)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-brightgreen?style=for-the-badge)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

<p align="center">
  <b>تطبيق قرآني حديث، يعمل بدون إنترنت (Offline-First)، مبني بأحدث تقنيات Flutter و Clean Architecture، مصمم لتقديم تجربة قراءة فائقة السلاسة والجمال.</b>
</p>

</div>

---

## 🌟 مميزات المشروع (Key Features)

- **📖 المصحف الكامل بدون إنترنت:** يحتوي على جميع السور الـ 114 والآيات الـ 6,236 مع رسم العثماني والبسملة وتصنيفات السور (مكية/مدنية) ورقم الجزء.
- **⚡ معالجة فائقة السرعة بدون تعطيل الواجهة (Isolate-based Concurrency):** يتم تحليل وفك تشفير بيانات المصحف كاملة عبر خيط عزل خلفي (`Isolate.run`) لمنع أي تهنيج في واجهة المستخدم (60 FPS Performance).
- **🔍 بحث ذكي مجرد من التشكيل (`textPlain`):** محرك بحث شامل في كلمات القرآن الكريم متجاهل لعلامات التشكيل للوصول الفوري لأي آية أو سورة.
- **📍 تتبع تلقائي لموقع القراءة (Auto Last-Read Tracking):** تتبع مرئي ذكي للآيات الظاهرة أثناء القراءة وحفظ موقع آخر سورة وآية تلقائيًا.
- **🔖 إشارات مرجعية ومفضلة (Bookmarks System):** إمكانية حفظ وإدارة الآيات المفضلة مع حفظ دائم في الجهاز.
- **🎨 دعم كامل للمظهر الفاتح والداكن (Material 3 Dark & Light Themes):** دعم التبديل السلس بين المظهر الفاتح والداكن وحسب نظام الجهاز مع خطوط عربية فاخرة (**الأُميري** و **كايرو**).
- **🔤 التحكم الحرفي في حجم الخط:** شريط سحب ديناميكي لتغيير حجم خط القراءة مع معاينة حية ومباشرة.
- **🌐 دعم RTL وتوطين كامل (Full Arabic RTL & Localizations):** تصميم مبني أصليًا باللغة العربية والاتجاه من اليمين لليسار.

---

## 🏗️ معمارية المشروع (Architecture & Tech Stack)

يعتمد التطبيق على معمارية **Clean Architecture** المبتكرة مع تصميم المقاطع الوظيفية (**Feature-Sliced Design**)، مما يضمن فصل المسؤوليات وسهولة الاختبار والصيانة:

```text
lib/
├── app/                        # إعدادات التطبيق العامة (Theme, Router, App Entry)
├── config/
│   └── dependency_injection/   # رسم بياني للحقن باستخدام Riverpod (No GetIt)
├── core/                       # الثوابت، الأخطاء، والسجلات المشتركة (Constants, Failures, Logger)
├── common/                     # المكونات المكررة (Loading, Error, Empty State Widgets)
└── features/
    └── quran/                  # ميزة القرآن الرئيسية
        ├── domain/             # الطبقة الرئيسية: الكيانات وحالات الاستخدام (Entities, Use Cases)
        ├── data/               # طبقة البيانات: النماذج والمصادر ومحرك Isolate
        └── presentation/       # طبقة الواجهة: الشاشات والـ Riverpod Providers
```

### 🛠️ التقنيات والمكتبات المستعملة (Technologies Used)
- **Framework:** [Flutter SDK](https://flutter.dev) (Dart 3)
- **State Management & DI:** [Flutter Riverpod 3](https://riverpod.dev)
- **Navigation:** [GoRouter 17](https://pub.dev/packages/go_router)
- **Typography:** [Google Fonts](https://pub.dev/packages/google_fonts) (Amiri & Cairo)
- **Error Handling:** [Dartz](https://pub.dev/packages/dartz) (`Either<Failure, T>`)
- **Local Storage:** `SharedPreferences`
- **Concurrency:** Native Dart `Isolate.run`

---

## 📸 الشاشات والواجهات (App Screens)

| الشاشة الرئيسية | قائمة السور والفلترة | قارئ القرآن الكلاسيكي |
| :---: | :---: | :---: |
| واجهة الفرقان مع بطاقة آخر قراءة | فلترة فورية وحساب عدد الآيات | قراءة بخط الأُميري وتتبع مرئي |

| البحث الشامل | الآيات المحفوظة | إعدادات المظهر والخط |
| :---: | :---: | :---: |
| بحث مجرد بدون تشكيل | قائمة بالمفضلة وإدارتها | معاينة حية لحجم الخط والمظهر |

---

## 🚀 طريقة التشغيل والبناء (Installation & Build Guide)

### 1. المتطلبات الأساسية
- مثبت Flutter SDK (الإصدار 3.19 فما فوق).
- Android Studio / VS Code.

### 2. استنساخ المشروع وتثبيت التبعيات
```bash
# 1. استنساخ المستودع
git clone https://github.com/USERNAME/quran_app.git

# 2. الدخول لمجلد المشروع
cd quran_app

# 3. تثبيت حزم البرمجة
flutter pub get
```

### 3. تشغيل التطبيق على محاكي أو جهاز حقيقي
```bash
flutter run
```

### 4. بناء ملف الـ Release APK النهائي
```bash
flutter build apk --release
```
تجد ملف الـ APK النظيف في المسار:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📝 الترخيص (License)

هذا المشروع متاح بموجب ترخيص [MIT License](LICENSE).

<div align="center">
  <sub>تم التطوير بكل حب وشغف لخدمة كتاب الله الكريم 🤍</sub>
</div>

import 'package:quran_app/features/quran/domain/entities/surah.dart';

// ─── Arabic diacritic stripping ───────────────────────────────────────────────
//
// Strips tashkeel (harakat), shadda, tanween, and other combining marks from
// an Arabic string to produce a plain text suitable for search matching.
//
// Unicode ranges removed:
//   U+0610–U+061A  Arabic Extended marks
//   U+064B–U+065F  Harakat (fathah, kasrah, dammah, shadda, etc.)
//   U+0670         Arabic letter superscript alef
//   U+06D6–U+06DC  Quranic annotation signs
//   U+06DF–U+06E4  Quranic annotation signs
//   U+06E7–U+06E8  Quranic annotation signs
//   U+06EA–U+06ED  Quranic annotation signs
//   U+FC5E–U+FC62  Ligature presentation forms (optional safety strip)

String _stripDiacritics(String text) {
  return text.replaceAll(
    RegExp(
      r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E4\u06E7\u06E8\u06EA-\u06ED\uFC5E-\uFC62]',
    ),
    '',
  );
}

// ─── SurahModel ───────────────────────────────────────────────────────────────

class SurahModel extends Surah {
  const SurahModel({
    required super.id,
    required super.name,
    required super.nameArabic,
    required super.nameEnglish,
    required super.totalVerses,
    required super.revelationType,
    super.ayahs,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? ayahsJson = json['ayahs'] as List<dynamic>?;
    return SurahModel(
      id: json['id'] as int,
      name: json['name'] as String,
      nameArabic: json['nameArabic'] as String,
      nameEnglish: json['nameEnglish'] as String,
      totalVerses: json['totalVerses'] as int,
      revelationType: json['revelationType'] as String,
      ayahs: ayahsJson
          ?.map(
            (a) => AyahModel.fromJson(a as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameArabic': nameArabic,
        'nameEnglish': nameEnglish,
        'totalVerses': totalVerses,
        'revelationType': revelationType,
        'ayahs': ayahs?.map((a) => (a as AyahModel).toJson()).toList(),
      };
}

// ─── AyahModel ────────────────────────────────────────────────────────────────

class AyahModel extends Ayah {
  const AyahModel({
    required super.number,
    required super.text,
    required super.textPlain,
    super.juz,
    super.page,
    super.hizbQuarter,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) {
    final text = json['text'] as String;

    // textPlain is read from the dataset if already provided (e.g. datasets that
    // include a separate plain-text field). Otherwise it is derived by stripping
    // diacritics from the canonical text at parse time — inside the isolate.
    final textPlain = json['textPlain'] as String? ?? _stripDiacritics(text);

    return AyahModel(
      number: json['number'] as int,
      text: text,
      textPlain: textPlain,
      juz: json['juz'] as int?,
      page: json['page'] as int?,
      hizbQuarter: json['hizbQuarter'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'text': text,
        'textPlain': textPlain,
        'juz': juz,
        'page': page,
        'hizbQuarter': hizbQuarter,
      };
}

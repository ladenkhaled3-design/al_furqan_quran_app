import 'package:equatable/equatable.dart';

class Surah extends Equatable {
  final int id;
  final String name;
  final String nameArabic;
  final String nameEnglish;
  final int totalVerses;
  final String revelationType;
  final List<Ayah>? ayahs;

  const Surah({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.nameEnglish,
    required this.totalVerses,
    required this.revelationType,
    this.ayahs,
  });

  @override
  List<Object?> get props => [id, name, nameArabic];
}

class Ayah extends Equatable {
  final int number;

  /// Full Arabic text with tashkeel (diacritics). Used for display only.
  /// Must never be modified or generated manually — sourced from the Quran dataset.
  final String text;

  /// Plain Arabic text stripped of tashkeel and special Unicode markers.
  /// Derived from [text] at parse time. Used exclusively for search/filtering.
  /// Must never be displayed to the user as the primary Quran text.
  final String textPlain;

  final int? juz;
  final int? page;
  final int? hizbQuarter;

  const Ayah({
    required this.number,
    required this.text,
    required this.textPlain,
    this.juz,
    this.page,
    this.hizbQuarter,
  });

  @override
  List<Object?> get props => [number, text];
}

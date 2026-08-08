import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:quran_app/core/constants/app_constants.dart';
import 'package:quran_app/core/logger/app_logger.dart';
import 'package:quran_app/features/quran/data/models/surah_model.dart';

// ─── Abstract contract ────────────────────────────────────────────────────────

abstract class QuranLocalDataSource {
  Future<List<SurahModel>> getSurahs();
}

// ─── Isolate helper ───────────────────────────────────────────────────────────
//
// This top-level function is the isolate entry point.
// It must be top-level (or static) — closures cannot be sent to isolates.
//
// It receives the raw JSON string and performs the full decode + model mapping
// entirely off the UI thread. textPlain stripping (inside AyahModel.fromJson)
// also runs here, not on the main isolate.

List<SurahModel> _parseQuranJson(String jsonString) {
  final List<dynamic> jsonData = json.decode(jsonString);
  return jsonData
      .map((item) => SurahModel.fromJson(item as Map<String, dynamic>))
      .toList();
}

// ─── Implementation ───────────────────────────────────────────────────────────

class QuranLocalDataSourceImpl implements QuranLocalDataSource {
  @override
  Future<List<SurahModel>> getSurahs() async {
    try {
      // Step 1: Load the raw JSON string on the platform channel (UI thread).
      // rootBundle.loadString is fast — it only reads bytes; no parsing here.
      final String jsonString = await rootBundle.loadString(
        AppConstants.quranJsonPath,
      );

      // Step 2: Decode + map models in a background isolate.
      // Isolate.run spawns a short-lived isolate, executes the function,
      // and returns the result to the calling isolate automatically.
      final List<SurahModel> surahs = await Isolate.run(
        () => _parseQuranJson(jsonString),
      );

      return surahs;
    } catch (e) {
      AppLogger.error('خطأ في تحميل بيانات القرآن', e);
      rethrow;
    }
  }
}

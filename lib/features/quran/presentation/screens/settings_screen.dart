import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/core/constants/app_constants.dart';
import 'package:quran_app/features/quran/presentation/providers/quran_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('الإعدادات', style: GoogleFonts.amiri(fontSize: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Theme section ─────────────────────────────────────────────
          Text(
            'المظهر والتصميم',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  selected: {settings.themeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateThemeMode(newSelection.first);
                  },
                  segments: [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      label: Text('النظام', style: GoogleFonts.cairo(fontSize: 12)),
                      icon: const Icon(Icons.settings_suggest_rounded, size: 18),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      label: Text('فاتح', style: GoogleFonts.cairo(fontSize: 12)),
                      icon: const Icon(Icons.light_mode_rounded, size: 18),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      label: Text('داكن', style: GoogleFonts.cairo(fontSize: 12)),
                      icon: const Icon(Icons.dark_mode_rounded, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ─── Font Size section ─────────────────────────────────────────
          Text(
            'حجم خط المصحف',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text('صغير', style: GoogleFonts.cairo(fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: settings.fontSize,
                          min: 18.0,
                          max: 36.0,
                          divisions: 9,
                          label: '${settings.fontSize.toInt()}',
                          onChanged: (val) {
                            ref
                                .read(settingsProvider.notifier)
                                .updateFontSize(val);
                          },
                        ),
                      ),
                      Text('كبير', style: GoogleFonts.cairo(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'معاينة الخط:',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.amiri(
                            fontSize: settings.fontSize,
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ─── About section ─────────────────────────────────────────────
          Text(
            'عن التطبيق',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.info_outline_rounded, color: scheme.primary),
              title: Text(
                AppConstants.appName,
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'تطبيق القرآن الكريم الإلكتروني الشامل • يعمل بدون إنترنت',
                style: GoogleFonts.cairo(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

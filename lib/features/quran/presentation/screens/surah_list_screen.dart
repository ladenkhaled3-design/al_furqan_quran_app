import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/common/widgets/app_error_widget.dart';
import 'package:quran_app/common/widgets/app_loading_widget.dart';
import 'package:quran_app/common/widgets/empty_state_widget.dart';
import 'package:quran_app/features/quran/domain/entities/surah.dart';
import 'package:quran_app/features/quran/presentation/providers/quran_provider.dart';

// ─── Inline filter provider (local to this screen) ───────────────────────────

class _SurahFilterNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

final _surahFilterProvider =
    NotifierProvider.autoDispose<_SurahFilterNotifier, String>(
  _SurahFilterNotifier.new,
);

class SurahListScreen extends ConsumerWidget {
  const SurahListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quranAsync = ref.watch(quranDataProvider);
    final filter = ref.watch(_surahFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('سور القرآن الكريم', style: GoogleFonts.amiri(fontSize: 20)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _SearchBar(
            onChanged: (v) =>
                ref.read(_surahFilterProvider.notifier).update(v),
          ),
        ),
      ),
      body: quranAsync.when(
        loading: () => const AppLoadingWidget(message: 'جاري تحميل القرآن الكريم...'),
        error: (e, _) => AppErrorWidget(
          message: 'تعذّر تحميل القرآن\n${e.toString()}',
          onRetry: () => ref.invalidate(quranDataProvider),
        ),
        data: (surahs) {
          final filtered = filter.isEmpty
              ? surahs
              : surahs.where((s) {
                  final q = filter.trim();
                  return s.nameArabic.contains(q) ||
                      s.nameEnglish.toLowerCase().contains(q.toLowerCase()) ||
                      s.id.toString() == q;
                }).toList();

          if (filtered.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.search_off_rounded,
              title: 'لا توجد نتائج',
              subtitle: 'جرّب كلمة بحث مختلفة',
            );
          }

          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) =>
                _SurahListTile(surah: filtered[index]),
          );
        },
      ),
    );
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        onChanged: onChanged,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'ابحث باسم السورة أو رقمها...',
          hintStyle: GoogleFonts.cairo(fontSize: 14),
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ─── Surah tile ───────────────────────────────────────────────────────────────

class _SurahListTile extends StatelessWidget {
  final Surah surah;

  const _SurahListTile({required this.surah});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => context.pushNamed(
        'reader',
        pathParameters: {'id': '${surah.id}'},
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // رقم السورة
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${surah.id}',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // اسم السورة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.nameArabic,
                    style: GoogleFonts.amiri(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  Text(
                    '${surah.nameEnglish} • ${surah.totalVerses} آية',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            // نوع السورة
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: surah.revelationType == 'Meccan'
                    ? Colors.orange.withValues(alpha: 0.12)
                    : Colors.blue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: surah.revelationType == 'Meccan'
                      ? Colors.orange[800]
                      : Colors.blue[800],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: scheme.onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}

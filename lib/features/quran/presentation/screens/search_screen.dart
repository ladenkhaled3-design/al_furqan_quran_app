import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/common/widgets/app_error_widget.dart';
import 'package:quran_app/common/widgets/app_loading_widget.dart';
import 'package:quran_app/common/widgets/empty_state_widget.dart';
import 'package:quran_app/features/quran/presentation/providers/quran_provider.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('البحث الشامل', style: GoogleFonts.amiri(fontSize: 20)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              autofocus: true,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث في كلمات القرآن أو أسماء السور...',
                hintStyle: GoogleFonts.cairo(fontSize: 14),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => ref
                            .read(searchQueryProvider.notifier)
                            .clear(),
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) =>
                  ref.read(searchQueryProvider.notifier).setQuery(val),
            ),
          ),
        ),
      ),
      body: query.trim().isEmpty
          ? const EmptyStateWidget(
              icon: Icons.search_rounded,
              title: 'ابحث في القرآن الكريم',
              subtitle: 'يمكنك البحث عن أي كلمة أو اسم سورة أو رقم سورة',
            )
          : resultsAsync.when(
              loading: () =>
                  const AppLoadingWidget(message: 'جاري البحث...'),
              error: (err, stack) => AppErrorWidget(
                message: 'حدث خطأ أثناء البحث\n$err',
              ),
              data: (results) {
                if (results.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'لم يتم العثور على نتائج',
                    subtitle: 'لا توجد نتائج تطابق "$query"',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: results.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = results[index];
                    return _SearchResultTile(item: item);
                  },
                );
              },
            ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final SearchResultItem item;

  const _SearchResultTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isSurah = item.matchType == 'surah';

    return ListTile(
      onTap: () {
        context.pushNamed(
          'reader',
          pathParameters: {'id': '${item.surah.id}'},
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSurah
              ? scheme.primary.withValues(alpha: 0.12)
              : scheme.secondary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSurah ? Icons.menu_book_rounded : Icons.format_quote_rounded,
          color: isSurah ? scheme.primary : scheme.secondary,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Text(
            item.surah.nameArabic,
            style: GoogleFonts.amiri(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'سورة رقم ${item.surah.id}',
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const Spacer(),
          if (!isSurah && item.ayah != null)
            Chip(
              visualDensity: VisualDensity.compact,
              label: Text(
                'آية ${item.ayah!.number}',
                style: GoogleFonts.cairo(fontSize: 11),
              ),
            ),
        ],
      ),
      subtitle: !isSurah && item.ayah != null
          ? Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                item.ayah!.text,
                textDirection: TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  height: 1.6,
                  color: scheme.onSurface,
                ),
              ),
            )
          : Text(
              '${item.surah.nameEnglish} • ${item.surah.totalVerses} آية',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
    );
  }
}

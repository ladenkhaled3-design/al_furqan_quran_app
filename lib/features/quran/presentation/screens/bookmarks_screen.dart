import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/common/widgets/empty_state_widget.dart';
import 'package:quran_app/features/quran/presentation/providers/quran_provider.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('الآيات المحفوظة', style: GoogleFonts.amiri(fontSize: 20)),
      ),
      body: bookmarks.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.bookmark_border_rounded,
              title: 'لا توجد آيات محفوظة',
              subtitle: 'يمكنك حفظ الآيات أثناء القراءة للرجوع إليها لاحقًا',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final item = bookmarks[index];
                return _BookmarkTile(item: item);
              },
            ),
    );
  }
}

class _BookmarkTile extends ConsumerWidget {
  final BookmarkItem item;

  const _BookmarkTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.bookmark_rounded,
                    color: scheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  item.surahNameArabic,
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '•  آية ${item.ayahNumber}',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: scheme.error,
                  tooltip: 'إزالة الحفظ',
                  onPressed: () {
                    ref.read(bookmarksProvider.notifier).toggleBookmark(item);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                context.pushNamed(
                  'reader',
                  pathParameters: {'id': '${item.surahId}'},
                );
              },
              child: Text(
                item.ayahText,
                textDirection: TextDirection.rtl,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  height: 1.8,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

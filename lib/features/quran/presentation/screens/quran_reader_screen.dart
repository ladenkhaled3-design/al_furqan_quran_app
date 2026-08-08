import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/common/widgets/app_error_widget.dart';
import 'package:quran_app/common/widgets/app_loading_widget.dart';
import 'package:quran_app/features/quran/domain/entities/surah.dart';
import 'package:quran_app/features/quran/presentation/providers/quran_provider.dart';

class QuranReaderScreen extends ConsumerStatefulWidget {
  final int surahId;

  const QuranReaderScreen({super.key, required this.surahId});

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Saves last-read position when user reaches an ayah.
  void _saveLastRead(int ayahNumber) {
    ref.read(saveLastReadProvider)(widget.surahId, ayahNumber);
  }

  @override
  Widget build(BuildContext context) {
    final surahAsync = ref.watch(surahDetailProvider(widget.surahId));

    return Scaffold(
      body: surahAsync.when(
        loading: () => const AppLoadingWidget(message: 'جاري تحميل السورة...'),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: AppErrorWidget(
            message: e.toString(),
            onRetry: () => ref.invalidate(surahDetailProvider(widget.surahId)),
          ),
        ),
        data: (surah) => _ReaderView(
          surah: surah,
          scrollController: _scrollController,
          onAyahVisible: _saveLastRead,
        ),
      ),
    );
  }
}

// ─── Reader View ──────────────────────────────────────────────────────────────

class _ReaderView extends StatelessWidget {
  final Surah surah;
  final ScrollController scrollController;
  final ValueChanged<int> onAyahVisible;

  const _ReaderView({
    required this.surah,
    required this.scrollController,
    required this.onAyahVisible,
  });

  @override
  Widget build(BuildContext context) {
    final ayahs = surah.ayahs ?? [];
    final scheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        // ─── AppBar ───────────────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          title: Column(
            children: [
              Text(
                surah.nameArabic,
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                surah.nameEnglish,
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Chip(
                label: Text(
                  'آياتها ${surah.totalVerses}',
                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.white),
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),

        // ─── Basmala (for all surahs except At-Tawbah id=9) ──────────
        if (surah.id != 9)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Text(
                'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiri(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
            ),
          ),

        // ─── Ayahs ────────────────────────────────────────────────────
        if (ayahs.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Text(
                'لا تتوفر آيات لهذه السورة في البيانات الحالية',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final ayah = ayahs[index];
                return _AyahTile(
                  ayah: ayah,
                  surahId: surah.id,
                  surahNameArabic: surah.nameArabic,
                  onVisible: () => onAyahVisible(ayah.number),
                );
              },
              childCount: ayahs.length,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// ─── Ayah Tile ────────────────────────────────────────────────────────────────

class _AyahTile extends ConsumerStatefulWidget {
  final Ayah ayah;
  final int surahId;
  final String surahNameArabic;
  final VoidCallback onVisible;

  const _AyahTile({
    required this.ayah,
    required this.surahId,
    required this.surahNameArabic,
    required this.onVisible,
  });

  @override
  ConsumerState<_AyahTile> createState() => _AyahTileState();
}

class _AyahTileState extends ConsumerState<_AyahTile> {
  bool _notified = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fontSize = ref.watch(settingsProvider).fontSize;

    return VisibilityDetectorWrapper(
      onVisible: () {
        if (!_notified) {
          _notified = true;
          widget.onVisible();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─ Ayah number badge + juz label ─
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${widget.ayah.number}',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (widget.ayah.juz != null)
                      Text(
                        'الجزء ${widget.ayah.juz}',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    const Spacer(),
                    _AyahActionBar(
                      ayah: widget.ayah,
                      surahId: widget.surahId,
                      surahNameArabic: widget.surahNameArabic,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // ─ Arabic ayah text ─
                Text(
                  widget.ayah.text,
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    fontSize: fontSize,
                    height: 2.0,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Ayah Action Bar ──────────────────────────────────────────────────────────

class _AyahActionBar extends ConsumerWidget {
  final Ayah ayah;
  final int surahId;
  final String surahNameArabic;

  const _AyahActionBar({
    required this.ayah,
    required this.surahId,
    required this.surahNameArabic,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = ref.watch(bookmarksProvider.notifier).isBookmarked(
          surahId,
          ayah.number,
        );

    final bookmarkItem = BookmarkItem(
      surahId: surahId,
      ayahNumber: ayah.number,
      surahNameArabic: surahNameArabic,
      ayahText: ayah.text,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bookmark toggle button
        IconButton(
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: Icon(
            isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: isBookmarked ? Theme.of(context).colorScheme.primary : null,
          ),
          tooltip: isBookmarked ? 'إزالة من المحفوظات' : 'حفظ الآية',
          onPressed: () {
            ref.read(bookmarksProvider.notifier).toggleBookmark(bookmarkItem);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isBookmarked ? 'تمت إزالة الآية من المحفوظات' : 'تم حفظ الآية في المحفوظات',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        // Copy button
        IconButton(
          iconSize: 18,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: const Icon(Icons.copy_rounded),
          tooltip: 'نسخ',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: ayah.text));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم نسخ الآية'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─── Visibility Detector ──────────────────────────────────────────────────────

class VisibilityDetectorWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onVisible;

  const VisibilityDetectorWrapper({
    super.key,
    required this.child,
    required this.onVisible,
  });

  @override
  State<VisibilityDetectorWrapper> createState() =>
      _VisibilityDetectorWrapperState();
}

class _VisibilityDetectorWrapperState extends State<VisibilityDetectorWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onVisible();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

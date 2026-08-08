import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/features/quran/domain/entities/surah.dart';
import 'package:quran_app/features/quran/presentation/providers/quran_provider.dart';
import 'package:quran_app/features/quran/presentation/widgets/home_section_title.dart';
import 'package:quran_app/features/quran/presentation/widgets/quran_header.dart';

import 'package:quran_app/core/constants/app_constants.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastReadAsync = ref.watch(lastReadProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            flexibleSpace: const FlexibleSpaceBar(
              background: QuranHeader(),
            ),
            title: Text(
              AppConstants.appName,
              style: GoogleFonts.amiri(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // ─── Last Read ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: lastReadAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
              data: (surah) {
                if (surah == null) return const SizedBox.shrink();
                return _LastReadBanner(surah: surah);
              },
            ),
          ),

          // ─── Section: القرآن الكريم ───────────────────────────────────
          const SliverToBoxAdapter(
            child: HomeSectionTitle(title: 'القرآن الكريم'),
          ),

          // ─── Feature cards ────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _HomeFeatureCard(
                  icon: Icons.menu_book_rounded,
                  label: 'قراءة القرآن',
                  color: const Color(0xFF2E7D32),
                  onTap: () => context.pushNamed('surahs'),
                ),
                _HomeFeatureCard(
                  icon: Icons.search_rounded,
                  label: 'البحث',
                  color: const Color(0xFF1565C0),
                  onTap: () => context.pushNamed('search'),
                ),
                _HomeFeatureCard(
                  icon: Icons.bookmark_rounded,
                  label: 'المفضلة',
                  color: const Color(0xFF6A1B9A),
                  onTap: () => context.pushNamed('bookmarks'),
                ),
                _HomeFeatureCard(
                  icon: Icons.settings_rounded,
                  label: 'الإعدادات',
                  color: const Color(0xFF37474F),
                  onTap: () => context.pushNamed('settings'),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ─── Last Read Banner ─────────────────────────────────────────────────────────

class _LastReadBanner extends StatelessWidget {
  final Surah surah;

  const _LastReadBanner({required this.surah});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.pushNamed(
          'reader',
          pathParameters: {'id': '${surah.id}'},
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bookmark, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'آخر قراءة',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      surah.nameArabic,
                      style: GoogleFonts.amiri(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B5E20),
                      ),
                    ),
                    Text(
                      '${surah.nameEnglish} • ${surah.totalVerses} آية',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF2E7D32),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Feature Card ─────────────────────────────────────────────────────────────

class _HomeFeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _HomeFeatureCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

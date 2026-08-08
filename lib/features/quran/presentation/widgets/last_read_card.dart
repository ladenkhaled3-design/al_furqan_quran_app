import 'package:flutter/material.dart';
import 'package:quran_app/features/quran/domain/entities/surah.dart';
import 'package:google_fonts/google_fonts.dart';

class LastReadCard extends StatelessWidget {
  final Surah surah;

  const LastReadCard({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            color: Colors.green.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bookmark, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
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
                  'سورة ${surah.nameEnglish} • ${surah.totalVerses} آية',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: فتح السورة
            },
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF2E7D32),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

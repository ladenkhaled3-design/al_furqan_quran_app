import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const HomeSectionTitle({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.amiri(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B5E20),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }
}

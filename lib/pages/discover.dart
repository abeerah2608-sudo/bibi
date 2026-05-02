import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/bloc_exports.dart';
import '../services/language_strings.dart';
import 'favourites.dart';
import 'testimonial.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        final language = state is LanguageSelected ? state.language : 'English';
        final isRtl = language == 'Urdu';

        return Scaffold(
          backgroundColor: const Color(0xFFFFF5F5),
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, language),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _DiscoverTile(
                          label: _tr(language, 'testimonial'),
                          isRtl: isRtl,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TestimonialsPage(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DiscoverTile(
                          label: _tr(language, 'favorites'),
                          isRtl: isRtl,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FavoritesPage(language: language),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DiscoverTile(
                          label: _tr(language, 'meet_doctor'),
                          isRtl: isRtl,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, String language) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            _tr(language, 'discover'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE86A8D),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF8B5E3C),
                  size: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverTile extends StatelessWidget {
  final String label;
  final bool isRtl;
  final VoidCallback onTap;

  const _DiscoverTile({
    required this.label,
    required this.isRtl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Expanded(
              child: Text(
                label,
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF5C3D2E),
                ),
              ),
            ),
            Icon(
              isRtl ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded,
              size: 14,
              color: const Color(0xFFBB8B77),
            ),
          ],
        ),
      ),
    );
  }
}

String _tr(String language, String key) {
  const Map<String, Map<String, String>> strings = {
    'discover': {
      'English': 'Discover',
      'Urdu': 'دریافت کریں',
      'Roman Urdu': 'Daryaft Karein',
    },
    'testimonial': {
      'English': 'Testimonial',
      'Urdu': 'تجربات',
      'Roman Urdu': 'Tajrubaat',
    },
    'favorites': {
      'English': 'Favorites',
      'Urdu': 'پسندیدہ',
      'Roman Urdu': 'Pasandida',
    },
    'meet_doctor': {
      'English': 'Meet the Doctor',
      'Urdu': 'ڈاکٹر سے ملیں',
      'Roman Urdu': 'Doctor se Milein',
    },
  };

  return strings[key]?[language] ?? strings[key]?['English'] ?? key;
}

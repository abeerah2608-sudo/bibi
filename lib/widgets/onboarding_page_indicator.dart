import 'package:flutter/material.dart';

class OnboardingPageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Color activeColor;
  final Color inactiveColor;

  const OnboardingPageIndicator({
    super.key,
    required this.currentPage,
    this.totalPages = 6,
    this.activeColor = const Color(0xFFE86A8D),
    this.inactiveColor = const Color(0xFFE8C4D3),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => _buildDot(index),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: index == currentPage ? activeColor : inactiveColor,
        ),
      ),
    );
  }
}

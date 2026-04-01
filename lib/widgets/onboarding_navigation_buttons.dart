import 'package:flutter/material.dart';

class OnboardingNavigationButtons extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onNextPressed;
  final bool showBackButton;

  const OnboardingNavigationButtons({
    super.key,
    this.onBackPressed,
    this.onNextPressed,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBackButton)
            ElevatedButton(
              onPressed: onBackPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE86A8D), width: 2),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFFE86A8D),
                size: 24,
              ),
            )
          else
            const SizedBox(width: 80),
          if (onNextPressed != null)
            ElevatedButton(
              onPressed: onNextPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE86A8D),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }
}

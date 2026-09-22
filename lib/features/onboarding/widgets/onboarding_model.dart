import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'package:jconnect/routes/approute.dart';

class OnboardingMainWidget extends StatelessWidget {
  final String image, title, subtitle, buttonText;
  final String? highlightText;
  final Color? highlightColor;
  final VoidCallback onPressed;

  const OnboardingMainWidget({
    super.key,
    required this.image,
    required this.title,
    this.highlightText,
    this.highlightColor,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  String? get _effectiveHighlightText {
    if (highlightText != null) return highlightText;
    final trimmed = title.trim();
    final lastSpace = trimmed.lastIndexOf(' ');
    if (lastSpace != -1) {
      return trimmed.substring(lastSpace + 1);
    }
    return null;
  }

  Widget _buildTitle() {
    final highlight = _effectiveHighlightText;
    final titleStyle = GoogleFonts.bebasNeue(
      fontSize: sp(50),
      letterSpacing: 1.5,
      color: Colors.white,
    );

    if (highlight != null &&
        highlight.isNotEmpty &&
        title.contains(highlight)) {
      final startIndex = title.indexOf(highlight);
      final before = title.substring(0, startIndex);
      final after = title.substring(startIndex + highlight.length);

      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: titleStyle,
          children: [
            if (before.isNotEmpty) TextSpan(text: before),
            TextSpan(
              text: highlight,
              style: titleStyle.copyWith(
                color: highlightColor ?? const Color(0xFFDE1B38),
              ),
            ),
            if (after.isNotEmpty) TextSpan(text: after),
          ],
        ),
      );
    }

    return Text(title, textAlign: TextAlign.center, style: titleStyle);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight < 700 ? 210.0 : 240.0;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              height: imageHeight,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            _buildTitle(),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: getTextStyle(
                color: Colors.white,
                fontsize: 15,
                fontweight: FontWeight.w400,
              ).copyWith(height: 1.45),
            ),
            const SizedBox(height: 28),

            CustomPrimaryButton(buttonText: buttonText, onTap: onPressed),
            const SizedBox(height: 6),
            if (buttonText != 'Get Started')
              TextButton(
                onPressed: () {
                  Get.toNamed(AppRoute.loginScreen);
                },
                child: Text(
                  'Skip',
                  style: getTextStyle(color: AppColors.primaryTextColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

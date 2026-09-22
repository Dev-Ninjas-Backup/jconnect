import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/features/onboarding/controller/onboarding_controller.dart';
import 'package:jconnect/features/onboarding/widgets/onboarding_model.dart';
import 'package:jconnect/features/onboarding/widgets/onboarding_progress_bar.dart';
import 'package:jconnect/routes/approute.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    final pages = [
      OnboardingMainWidget(
        image: Imagepath.onboarding1,
        title: "GET SEEN.",
        highlightText: "SEEN.",
        subtitle:
            "The right people create opportunity.\nDa Connect helps you get in front of them.",
        buttonText: 'Next',
        onPressed: controller.nextPage,
      ),
      OnboardingMainWidget(
        image: Imagepath.onboarding2,
        title: "BUY IT. SELL IT.\nCONNECT.",
        highlightText: "CONNECT.",
        subtitle: "Find what you need. Offer what you have.",
        buttonText: 'Next',
        onPressed: controller.nextPage,
      ),
      OnboardingMainWidget(
        image: Imagepath.onboarding3,
        title: "EVERYBODY IS A CONNECT.",
        highlightText: "CONNECT.",
        subtitle: "Build your profile, showcase your work, and connect with real opportunities.",
        buttonText: 'Get Started',
        onPressed: () {
          Get.toNamed(AppRoute.loginScreen);
        },
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16),
            OnboardingProgressBar(),
            SizedBox(height: 24),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: pages.length,
                itemBuilder: (context, index) => pages[index],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

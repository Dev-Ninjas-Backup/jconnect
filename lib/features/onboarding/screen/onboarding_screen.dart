import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';
import 'package:jconnect/features/onboarding/controller/onboarding_controller.dart';
import 'package:jconnect/features/onboarding/widgets/onboarding_model.dart';
import 'package:jconnect/features/onboarding/widgets/onboarding_progress_bar.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    final pages = [
      OnboardingMainWidget(
        image: Imagepath.onboarding1,
        title: 'Connect. Collaborate. Create.',
        subtitle: 'Join a global network of DJs, artists, and influencers.',
        buttonText: 'Next',
        onPressed: controller.nextPage,
      ),
      OnboardingMainWidget(
        image: Imagepath.onboarding2,
        title: 'Turn your talent into real deals.',
        subtitle:
            'Post your services, get discovered, and collaborate securely.',
        buttonText: 'Next',
        onPressed: controller.nextPage,
      ),
      OnboardingMainWidget(
        image: Imagepath.onboarding3,
        title: 'Let the Collabs Begin.',
        subtitle:
            'Connect, share vibes, and grow your sound — all in one place.',
        buttonText: 'Get Started',
        onPressed: () {
          // TODO: Navigate to main app screen
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

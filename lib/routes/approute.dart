import 'package:get/get_navigation/get_navigation.dart';
import 'package:jconnect/features/onboarding/screen/onboarding_screen.dart';
import 'package:jconnect/features/splash/screen/splash_screen.dart';

class AppRoute {
  static String splashScreen = '/splashScreen';
  static String onboardingScreen = '/onboardingScreen';
  static String getSplashScreen() => splashScreen;
  static String getOnboardingScreen() => onboardingScreen;

  static List<GetPage> routes = [
    GetPage(name: splashScreen, page: () => SplashScreen()),
    GetPage(name: onboardingScreen, page: () => OnboardingScreen()),
  ];
}

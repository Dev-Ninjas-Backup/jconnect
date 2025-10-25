import 'package:get/get_navigation/get_navigation.dart';
import 'package:jconnect/features/auth/forget_password/screen/forget_password_screen.dart';
import 'package:jconnect/features/auth/login/screen/login_screen.dart';
import 'package:jconnect/features/auth/new_password/screen/create_new_password.dart';
import 'package:jconnect/features/auth/otp/screen/otp_verification_screen.dart';
import 'package:jconnect/features/onboarding/screen/onboarding_screen.dart';
import 'package:jconnect/features/splash/screen/splash_screen.dart';

class AppRoute {
  static String splashScreen = '/splashScreen';
  static String onboardingScreen = '/onboardingScreen';
  static String loginScreen = '/loginScreen';
  static String forgetPassword = '/forgetPassword';
  static String otpVerificationScreen = '/otpVerificationScreen';
  static String newPasswordScreen = '/newPasswordScreen';

  static String getSplashScreen() => splashScreen;
  static String getOnboardingScreen() => onboardingScreen;
  static String getLoginScreen() => loginScreen;
  static String getForgetPassword() => forgetPassword;
  static String getOtpVerificationScreen() => otpVerificationScreen;
  static String getNewPasswordScreen() => newPasswordScreen;

  static List<GetPage> routes = [
    GetPage(name: splashScreen, page: () => SplashScreen()),
    GetPage(name: onboardingScreen, page: () => OnboardingScreen()),
    GetPage(name: loginScreen, page: () => LoginScreen()),
    GetPage(name: forgetPassword, page: () => ForgetPasswordScreen()),
    GetPage(name: otpVerificationScreen, page: () => OtpVerificationScreen()),
    GetPage(name: newPasswordScreen, page: () => CreateNewPassword()),
  ];
}

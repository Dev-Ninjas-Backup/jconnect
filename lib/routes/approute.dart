import 'package:get/get_navigation/get_navigation.dart';
import 'package:jconnect/features/add_services/screen/add_services_screen1.dart';
import 'package:jconnect/features/auth/forget_password/screen/forget_password_screen.dart';
import 'package:jconnect/features/auth/login/screen/login_screen.dart';
import 'package:jconnect/features/auth/new_password/screen/create_new_password.dart';
import 'package:jconnect/features/auth/email_otp/screen/otp_verification_screen.dart';
import 'package:jconnect/features/auth/phone_verification/screen/phone_verification_screen.dart';
import 'package:jconnect/features/auth/signup/screen/signup_screen.dart';
import 'package:jconnect/features/bottom_navbar/screen/bottom_navbar_screen.dart';

import 'package:jconnect/features/home/artists_screen/screen/artists_screen.dart';

import 'package:jconnect/features/my_orders/order_details/screen/order_details_screen.dart';

import 'package:jconnect/features/onboarding/screen/onboarding_screen.dart';
import 'package:jconnect/features/profile_setup/screen/profile_setup_screen.dart';
import 'package:jconnect/features/splash/screen/splash_screen.dart';

class AppRoute {
  static String splashScreen = '/splashScreen';
  static String onboardingScreen = '/onboardingScreen';
  static String loginScreen = '/loginScreen';
  static String forgetPassword = '/forgetPassword';
  static String otpVerificationScreen = '/otpVerificationScreen';
  static String newPasswordScreen = '/newPasswordScreen';
  static String signupScreen = '/signupScreen';
  static String phoneVerification = '/phoneVerification';
  static String profileSetupScreen = '/profileSetupScreen';
  static String addServiceScreen = '/addServiceScreen';
  static String orderDetails = '/orderDetails';

  ///navBar
  static String navBarScreen = '/navBarScreen';
  //home
  static String artistsScreen = '/home/artistsScreen';

  static String getSplashScreen() => splashScreen;
  static String getOnboardingScreen() => onboardingScreen;
  static String getLoginScreen() => loginScreen;
  static String getForgetPassword() => forgetPassword;
  static String getOtpVerificationScreen() => otpVerificationScreen;
  static String getNewPasswordScreen() => newPasswordScreen;
  static String getSignupScreen() => signupScreen;
  static String getPhoneVerificationScreen() => phoneVerification;
  static String getProfileSetupScreen() => profileSetupScreen;
  //navbar
  static String getNavBarScreen() => navBarScreen;
  static String getAddserviceScreen() => addServiceScreen;
  //home
  static String getArtistsScreen() => artistsScreen;

  static String getOrderDetails() => orderDetails;


  static List<GetPage> routes = [
    GetPage(name: splashScreen, page: () => SplashScreen()),
    GetPage(name: onboardingScreen, page: () => OnboardingScreen()),
    GetPage(name: loginScreen, page: () => LoginScreen()),
    GetPage(name: forgetPassword, page: () => ForgetPasswordScreen()),
    GetPage(name: otpVerificationScreen, page: () => OtpVerificationScreen()),
    GetPage(name: newPasswordScreen, page: () => CreateNewPassword()),
    GetPage(name: signupScreen, page: () => SignupScreen()),
    GetPage(name: phoneVerification, page: () => PhoneVerificationScreen()),
    GetPage(name: profileSetupScreen, page: () => ProfileSetupScreen()),
    //navBar
    GetPage(name: navBarScreen, page: () => NavBarScreen()),
    GetPage(name: addServiceScreen, page: () => AddServiceScreen()),
    //home
    GetPage(name: artistsScreen, page: ()=>ArtistsScreen()),

    GetPage(name: navBarScreen, page: () => NavBarScreen()),
    GetPage(name: addServiceScreen, page: () => AddServiceScreen()),
    GetPage(name: orderDetails, page: () => OrderDetailsScreen()),
  ];
}

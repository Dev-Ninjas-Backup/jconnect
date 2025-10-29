import 'package:get/get_navigation/get_navigation.dart';
import 'package:jconnect/features/add_services/screen/add_services_screen1.dart';
import 'package:jconnect/features/auth/forget_password/screen/forget_password_screen.dart';
import 'package:jconnect/features/auth/login/screen/login_screen.dart';
import 'package:jconnect/features/auth/new_password/screen/create_new_password.dart';
import 'package:jconnect/features/auth/email_otp/screen/otp_verification_screen.dart';
import 'package:jconnect/features/auth/phone_verification/screen/phone_verification_screen.dart';
import 'package:jconnect/features/auth/signup/screen/signup_screen.dart';
import 'package:jconnect/features/bottom_navbar/screen/bottom_navbar_screen.dart';
import 'package:jconnect/features/home/artists_details_screen/screen/artists_details_page.dart';

import 'package:jconnect/features/home/artists_screen/screen/artists_screen.dart';

import 'package:jconnect/features/my_orders/order_details/screen/order_details_screen.dart';

import 'package:jconnect/features/onboarding/screen/onboarding_screen.dart';
import 'package:jconnect/features/profile_setup/screen/profile_setup_screen.dart';
import 'package:jconnect/features/splash/screen/splash_screen.dart';
import 'package:jconnect/features/user_profile/earning_and_payouts/screen/earning_and_payouts_screen.dart';
import 'package:jconnect/features/user_profile/edit_profile/screen/edit_profile_screen.dart';
import 'package:jconnect/features/user_profile/payment_method/add_stripe/screen/add_stripe.dart';
import 'package:jconnect/features/user_profile/payment_method/manage_via_stripe/screen/manage_via_stripe.dart';
import 'package:jconnect/features/user_profile/privacy_security/screen/privacy_security_screen.dart';
import 'package:jconnect/features/user_profile/profile/screen/profile_screen.dart';
import 'package:jconnect/features/user_profile/reviews/screen/review_screen.dart';

import '../features/home/confirm_your_promotion/screen/confirm_your_promotion.dart';
import '../features/home/request_service/screen/request_service_screen.dart';

class AppRoute {
  //splash
  static String splashScreen = '/splashScreen';
  //onboarding
  static String onboardingScreen = '/onboardingScreen';
  //auth
  static String loginScreen = '/loginScreen';
  static String forgetPassword = '/forgetPassword';
  static String otpVerificationScreen = '/otpVerificationScreen';
  static String newPasswordScreen = '/newPasswordScreen';
  static String signupScreen = '/signupScreen';
  static String phoneVerification = '/phoneVerification';
  //services
  static String addServiceScreen = '/addServiceScreen';
  //order
  static String orderDetails = '/orderDetails';
  //profile
  static String profileSetupScreen = '/profileSetupScreen';
  static String profileScreen = '/profileScreen';
  static String editProfileScreen = '/editProfileScreen';
  static String privacySecurity = '/privacySecurity';
  static String earningsAndPayouts = '/earningsAndPayouts';
  static String reviewScreen = '/reviewScreen';
  static String addStripe = '/addStripe';
  static String manageViaStripe = '/manageViaStripe';

  ///navBar
  static String navBarScreen = '/navBarScreen';
  //home
  static String artistsScreen = '/home/artistsScreen';
  static String artistsDetailsPage = '/home/artistsDetailsPage';
  static String requestServiceScreen = '/home/requestServiceScreen';
  static String confirmYourPromotion = '/home/confirmYourPromotion';

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
  static String getArtistsDetailsPage() => artistsDetailsPage;
  static String getRequestServiceScreen() => requestServiceScreen;
  static String getConfirmYourPromotion() => confirmYourPromotion;

  static String getOrderDetails() => orderDetails;

  static String getProfileScreen() => profileScreen;
  static String getEditProfileScreen() => editProfileScreen;
  static String getPrivacySecurity() => privacySecurity;
  static String getEarningsAndPayouts() => earningsAndPayouts;
  static String getReviewScreen() => reviewScreen;
  static String getAddStripe() => addStripe;
  static String getManageViaStripe() => manageViaStripe;
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
    GetPage(name: artistsScreen, page: () => ArtistsScreen()),
    GetPage(name: artistsDetailsPage, page: () => ArtistsDetailsPage()),
    GetPage(name: requestServiceScreen, page: () => RequestServiceScreen()),
    GetPage(name: confirmYourPromotion, page: () => ConfirmYourPromotion()),

    GetPage(name: navBarScreen, page: () => NavBarScreen()),
    GetPage(name: addServiceScreen, page: () => AddServiceScreen()),
    GetPage(name: orderDetails, page: () => OrderDetailsScreen()),
    GetPage(name: profileScreen, page: () => ProfileScreen()),
    GetPage(name: editProfileScreen, page: () => EditProfileScreen()),
    GetPage(name: privacySecurity, page: () => PrivacySecurityScreen()),
    GetPage(name: earningsAndPayouts, page: () => EarningAndPayoutsScreen()),
    GetPage(name: reviewScreen, page: () => ReviewScreen()),
    GetPage(name: addStripe, page: () => AddStripe()),
    GetPage(name: manageViaStripe, page: () => ManageViaStripe()),
  ];
}

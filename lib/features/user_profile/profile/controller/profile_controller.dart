import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/features/user_profile/profile/model/profile_model.dart';

class ProfileController extends GetxController {
  // ───────────────────────────────
  // USER PROFILE DATA
  // ───────────────────────────────
  final Rx<ProfileModel> user = ProfileModel(
    name: 'DJ Kinseki',
    imageUrl: 'assets/images/dj.png',
    followers: 132,
    earnings: 2450,
    rating: 4.9,
  ).obs;

  // ───────────────────────────────
  // RATES SECTION
  // ───────────────────────────────
  final RxList<RateModel> rates = <RateModel>[
    RateModel(
      title: '30 Sec New Track Review',
      description: 'Short review of a new track with quick feedback',
      price: 25.0,
    ),
    RateModel(
      title: 'Social Shoutout',
      description: 'Post your track to my 10k+ audience',
      price: 60.0,
    ),
  ].obs;

  void addNewRate() {
    rates.add(
      RateModel(
        title: 'New Custom Rate',
        description: 'Describe your service...',
        price: 0.0,
      ),
    );
  }




  final RxBool notificationsEnabled = true.obs;
  final RxBool darkModeEnabled = false.obs;
  final RxBool privacyModeEnabled = false.obs;

  
  }

  

  // ───────────────────────────────
  // NAVIGATION + ACCOUNT ACTIONS
  // ───────────────────────────────
  void navigateTo(String route) {
    // You can replace this with Get.toNamed(route) when routing is set up
  }

  void deleteAccount() {
    Get.snackbar(
      'Deleted',
      'Your account has been deleted.',
      backgroundColor: AppColors.redColor.withValues(alpha: .8),
      colorText: AppColors.backGroundColor,
    );


    
  }


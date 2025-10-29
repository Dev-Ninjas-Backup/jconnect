// ignore_for_file: file_names

import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';

class StripeController extends GetxController {
  var stripeStatus = 'Connected to Stripe'.obs;
  var accountStatus = 'Verified'.obs;
  var lastPayout = '\$320 - Oct 10, 2025'.obs;
  var profileImage = Imagepath.profileImage.obs;

  void updateStripeStatus(String status) {
    stripeStatus.value = status;
  }

  void updateAccountStatus(String status) {
    accountStatus.value = status;
  }

  void updateLastPayout(String payout) {
    lastPayout.value = payout;
  }

  void updateProfileImage(String newImage) {
    profileImage.value = newImage;
  }
}

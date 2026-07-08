import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/service/network_service/network_client.dart';
import 'package:jconnect/features/repost/buyer_review_post/model/buyer_review_post_model.dart';
import 'package:jconnect/features/repost/repost_status/model/repost_status_model.dart';
import 'package:jconnect/features/repost/repost_status/service/repost_status_service.dart';
import 'package:jconnect/features/repost/buyer_review_post/widgets/order_complete.dart';

class BuyerReviewPostController extends GetxController {
  final RepostStatusItem item;
  late final BuyerReviewPostModel reviewModel;

  final RepostStatusService _service = RepostStatusService(
    client: NetworkClient(
      onUnAuthorize: () {
        if (kDebugMode) {
          print('unauthorized');
        }
      },
    ),
  );

  BuyerReviewPostController({required this.item}) {
    reviewModel = BuyerReviewPostModel(
      id: item.id,
      proofImageUrl: item.proofFiles.isNotEmpty
          ? item.proofFiles.first
          : 'https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=800&q=80',
      sellerName: item.seller?.username ?? 'Unknown Seller',
      submittedAt: item.proofSubmittedAt ??
          item.createdAt.add(const Duration(minutes: 15)),
      amount: item.amount,
      originalItem: item,
      proofNote: item.proofNote,
    );
  }

  final isProcessing = false.obs;
  final redoController = TextEditingController();
  final redoText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    redoController.addListener(() {
      redoText.value = redoController.text;
    });
  }

  @override
  void onClose() {
    redoController.dispose();
    super.onClose();
  }

  Future<void> acceptAndReleaseFunds() async {
    isProcessing.value = true;
    EasyLoading.show(status: 'Releasing funds...');
    try {
      final updatedItem = await _service.reviewRepostOrder(
        orderId: item.id,
        action: 'ACCEPT',
        instructions: '',
      );
      EasyLoading.dismiss();
      isProcessing.value = false;
      
      Get.to(() => OrderComplete(item: updatedItem));
    } catch (e) {
      EasyLoading.dismiss();
      isProcessing.value = false;
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  Future<void> processRejection() async {
    isProcessing.value = true;
    EasyLoading.show(status: 'Rejecting proof...');
    try {
      await _service.reviewRepostOrder(
        orderId: item.id,
        action: 'REJECT',
        instructions: '',
      );
      EasyLoading.dismiss();
      isProcessing.value = false;

      Get.snackbar(
        'Proof Rejected',
        'You have rejected the submission. The order status has been updated.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Go back to status page
      Future.delayed(const Duration(seconds: 1), () {
        Get.back(); // close the current screen
      });
    } catch (e) {
      EasyLoading.dismiss();
      isProcessing.value = false;
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  Future<void> submitRedoRequest(String instructions) async {
    if (instructions.trim().isEmpty) {
      Get.snackbar(
        'Warning',
        'Please enter instructions for the seller.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber,
        colorText: Colors.black,
      );
      return;
    }

    isProcessing.value = true;
    EasyLoading.show(status: 'Submitting request...');
    try {
      await _service.reviewRepostOrder(
        orderId: item.id,
        action: 'REDO',
        instructions: instructions,
      );
      EasyLoading.dismiss();
      isProcessing.value = false;

      Get.snackbar(
        'Redo Requested',
        'Instructions have been sent to ${reviewModel.sellerName}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Go back to review window screen
      Future.delayed(const Duration(seconds: 1), () {
        Get.back();
      });
    } catch (e) {
      EasyLoading.dismiss();
      isProcessing.value = false;
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }
}

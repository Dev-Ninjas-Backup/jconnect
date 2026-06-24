import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/repost/repost_status/model/repost_status_model.dart';
import 'package:jconnect/features/repost/repost_proof_upload/widgets/proof_success_dialog.dart';

class RepostProofUploadController extends GetxController {
  final RepostStatusItem item;
  RepostProofUploadController({required this.item});

  final noteController = TextEditingController();
  final noteText = ''.obs;
  final selectedFile = Rxn<File>();
  final isVideo = false.obs;

  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    noteController.addListener(() {
      noteText.value = noteController.text;
    });
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }

  /// Pick file (supports multiple file types)
  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'mp4', 'jpg', 'jpeg', 'png', 'gif', 'pdf', 'mov', 'avi', 'flv', 'wav', 'aac'],
      );

      if (result != null && result.files.single.path != null) {
        selectedFile.value = File(result.files.single.path!);
        final ext = result.files.single.name.split('.').last.toLowerCase();
        isVideo.value = ['mp4', 'mov', 'avi', 'flv'].contains(ext);
      }
    } catch (e) {
      EasyLoading.showError("Failed to pick file: $e");
    }
  }

  /// Capture image or video from camera
  Future<void> pickFromCamera({bool video = false}) async {
    try {
      if (video) {
        final XFile? xfile = await _picker.pickVideo(source: ImageSource.camera);
        if (xfile != null) {
          selectedFile.value = File(xfile.path);
          isVideo.value = true;
        }
      } else {
        final XFile? xfile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
        if (xfile != null) {
          selectedFile.value = File(xfile.path);
          isVideo.value = false;
        }
      }
    } catch (e) {
      EasyLoading.showError("Failed to capture media: $e");
    }
  }

  /// Pick image or video from gallery/photos
  Future<void> pickFromGallery({bool video = false}) async {
    try {
      if (video) {
        final XFile? xfile = await _picker.pickVideo(source: ImageSource.gallery);
        if (xfile != null) {
          selectedFile.value = File(xfile.path);
          isVideo.value = true;
        }
      } else {
        final XFile? xfile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
        if (xfile != null) {
          selectedFile.value = File(xfile.path);
          isVideo.value = false;
        }
      }
    } catch (e) {
      EasyLoading.showError("Failed to pick media: $e");
    }
  }

  Future<void> pickProofFile() async {
    Get.bottomSheet(
      SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primaryTextColor),
              title: Text('Take Photo', style: getTextStyle(color: AppColors.primaryTextColor)),
              onTap: () {
                Get.back();
                pickFromCamera(video: false);
              },
            ),
            ListTile(
              leading: Icon(Icons.videocam, color: AppColors.primaryTextColor),
              title: Text('Record Video', style: getTextStyle(color: AppColors.primaryTextColor)),
              onTap: () {
                Get.back();
                pickFromCamera(video: true);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primaryTextColor),
              title: Text('Choose File', style: getTextStyle(color: AppColors.primaryTextColor)),
              onTap: () {
                Get.back();
                pickFile();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo, size: 20, color: AppColors.primaryTextColor),
              title: Text('Choose Photo', style: getTextStyle(color: AppColors.primaryTextColor)),
              onTap: () {
                Get.back();
                pickFromGallery(video: false);
              },
            ),
            ListTile(
              leading: Icon(Icons.videocam, color: AppColors.primaryTextColor),
              title: Text('Choose Video', style: getTextStyle(color: AppColors.primaryTextColor)),
              onTap: () {
                Get.back();
                pickFromGallery(video: true);
              },
            ),
            ListTile(
              leading: Icon(Icons.close, color: AppColors.primaryTextColor),
              title: Text('Cancel', style: getTextStyle(color: AppColors.primaryTextColor)),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.backGroundColor,
    );
  }

  void clearSelectedFile() {
    selectedFile.value = null;
    isVideo.value = false;
  }

  Future<void> submitProof() async {
    if (selectedFile.value == null) {
      Get.snackbar(
        'Warning',
        'Please upload a screenshot or video proof first.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber,
        colorText: Colors.black,
      );
      return;
    }

    EasyLoading.show(status: 'Submitting proof...');
    // Simulate file upload delay
    await Future.delayed(const Duration(seconds: 2));
    EasyLoading.dismiss();

    Get.dialog(
      const ProofSuccessDialog(),
      barrierDismissible: false,
    );
  }
}

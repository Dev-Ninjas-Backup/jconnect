// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/widgets/custom_snackbar.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/widgets/custom_app_bar2.dart';
import 'package:jconnect/core/common/widgets/custom_primary_button.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/my_orders/controller/my_order_controller.dart';
import 'package:jconnect/features/my_orders/order_details/controller/order_details_controller.dart';
import 'package:jconnect/features/my_orders/order_details/widgets/order_timeline_widget.dart';
import 'package:jconnect/features/my_orders/order_details/widgets/reviewer_details_widget.dart';
import 'package:jconnect/features/my_orders/order_details/widgets/review_popup.dart';
import 'package:jconnect/features/my_orders/order_details/widgets/expandable_text.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'package:jconnect/core/utils/image_helper.dart';
import 'package:jconnect/features/messages/chat_details/screen/chat_details_screen.dart';
import 'package:jconnect/features/my_orders/order_details/model/order_details_model.dart';
import 'package:jconnect/features/my_orders/order_details/widgets/order_escrow_deadline_banner.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  /// Pick any file type and show confirmation dialog before uploading
  Future<void> _pickAndConfirmProofUpload(
    BuildContext context,
    OrderDetailsController controller,
    MyOrdersController orderController,
  ) async {
    final picker = ImagePicker();

    Future<void> _showConfirm(File file, String fileName) async {
      final ext = fileName.split('.').last.toLowerCase();
      final isImage = ['jpg', 'jpeg', 'png', 'gif'].contains(ext);

      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (dialogContext) => Dialog(
          backgroundColor: AppColors.backGroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.secondaryTextColor),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Confirm Upload',
                    style: getTextStyle(
                      color: AppColors.primaryTextColor,
                      fontweight: FontWeight.w600,
                      fontsize: 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  if (isImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 280,
                          maxWidth: 300,
                        ),
                        child: Image.file(file, fit: BoxFit.contain),
                      ),
                    )
                  else
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backGroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.secondaryTextColor),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _getFileIcon(ext),
                            size: 64,
                            color: AppColors.primaryTextColor.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            fileName,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: getTextStyle(
                              color: AppColors.primaryTextColor,
                              fontsize: 12,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${ext.toUpperCase()} • ${(file.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                            style: getTextStyle(
                              color: AppColors.secondaryTextColor,
                              fontsize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 20),
                  Text(
                    'Are you sure you want to upload this proof?',
                    style: getTextStyle(
                      color: AppColors.secondaryTextColor,
                      fontsize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text(
                            'Cancel',
                            style: getTextStyle(
                              color: AppColors.redColor,
                              fontweight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            Get.back();
                            final success = await controller.uploadProof(file);
                            if (success) {
                              showGradientSnackBar(
                                title: 'Success',
                                message: 'Proof uploaded',
                              );
                              try {
                                await orderController.loadOrders();
                              } catch (_) {}
                            }
                          },
                          child: Text(
                            'Confirm',
                            style: getTextStyle(
                              color: AppColors.redColor,
                              fontweight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Show bottom sheet with selection options
    if (!context.mounted) return;
    Get.bottomSheet(
      Material(
        color: AppColors.backGroundColor,
        child: SafeArea(
          child: Wrap(
            children: [
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(
                    Icons.camera_alt,
                    color: AppColors.primaryTextColor,
                  ),
                  title: Text(
                    'Take Photo',
                    style: getTextStyle(color: AppColors.primaryTextColor),
                  ),
                  onTap: () async {
                    Get.back();
                    final XFile? xfile = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                    );
                    if (xfile == null) return;
                    await _showConfirm(File(xfile.path), xfile.name);
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(
                    Icons.videocam,
                    color: AppColors.primaryTextColor,
                  ),
                  title: Text(
                    'Record Video',
                    style: getTextStyle(color: AppColors.primaryTextColor),
                  ),
                  onTap: () async {
                    Get.back();
                    final XFile? xfile = await picker.pickVideo(
                      source: ImageSource.camera,
                    );
                    if (xfile == null) return;
                    await _showConfirm(File(xfile.path), xfile.name);
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color: AppColors.primaryTextColor,
                  ),
                  title: Text(
                    'Choose File',
                    style: getTextStyle(color: AppColors.primaryTextColor),
                  ),
                  onTap: () async {
                    Get.back();
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: [
                        'mp3',
                        'mp4',
                        'jpg',
                        'jpeg',
                        'png',
                        'gif',
                        'pdf',
                        'mov',
                        'avi',
                        'flv',
                        'wav',
                        'aac',
                      ],
                    );
                    if (result == null || result.files.single.path == null)
                      return;
                    final file = File(result.files.single.path!);
                    await _showConfirm(file, result.files.single.name);
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(
                    Icons.photo,
                    size: 20,
                    color: AppColors.primaryTextColor,
                  ),
                  title: Text(
                    'Choose Photo',
                    style: getTextStyle(color: AppColors.primaryTextColor),
                  ),
                  onTap: () async {
                    Get.back();
                    final XFile? xfile = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (xfile == null) return;
                    await _showConfirm(File(xfile.path), xfile.name);
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(
                    Icons.videocam,
                    color: AppColors.primaryTextColor,
                  ),
                  title: Text(
                    'Choose Video',
                    style: getTextStyle(color: AppColors.primaryTextColor),
                  ),
                  onTap: () async {
                    Get.back();
                    final XFile? xfile = await picker.pickVideo(
                      source: ImageSource.gallery,
                    );
                    if (xfile == null) return;
                    await _showConfirm(File(xfile.path), xfile.name);
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(Icons.close, color: AppColors.primaryTextColor),
                  title: Text(
                    'Cancel',
                    style: getTextStyle(color: AppColors.primaryTextColor),
                  ),
                  onTap: () => Get.back(),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: AppColors.backGroundColor,
    );
  }

  /// Get file icon based on extension
  IconData _getFileIcon(String ext) {
    if (['mp3', 'wav', 'aac'].contains(ext)) {
      return Icons.audio_file;
    } else if (['mp4', 'mov', 'avi', 'flv'].contains(ext)) {
      return Icons.video_library;
    } else if (ext == 'pdf') {
      return Icons.picture_as_pdf;
    }
    return Icons.insert_drive_file;
  }

  void _viewFile(BuildContext context, String url) {
    final ext = url.split('.').last.split('?').first.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
    final isVideo = ['mp4', 'mov', 'avi', 'flv', 'mkv', 'webm'].contains(ext);
    final isAudio = ['mp3', 'wav', 'aac', 'm4a', 'flac'].contains(ext);
    final isPdf = ext == 'pdf';

    if (isImage) {
      // Show image preview with PhotoView
      Get.to(
        () => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'View Image',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: PhotoView(
            imageProvider: getSafeImageProvider(url),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            loadingBuilder: (_, __) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorBuilder: (_, __, ___) => const Center(
              child: Text(
                'Failed to load image',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),
      );
    } else if (isVideo) {
      // Show video player
      Get.to(() => VideoViewerScreen(videoUrl: url));
    } else if (isAudio) {
      // Show audio player dialog
      _showAudioPlayerDialog(context, url);
    } else if (isPdf) {
      // Open PDF in browser or show download dialog
      _showPdfViewDialog(context, url);
    } else {
      // For other file types, show download dialog
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Open File', style: TextStyle(color: Colors.white)),
          content: Text(
            'File type ($ext) cannot be previewed. Download to view?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _downloadFile(url);
              },
              child: const Text(
                'Download',
                style: TextStyle(color: Colors.greenAccent),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showAudioPlayerDialog(BuildContext context, String url) {
    Get.to(() => AudioPlayerScreen(audioUrl: url));
  }

  void _showPdfViewDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('PDF File', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            const Text(
              'PDF file detected',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              url.split('/').last.split('?').first,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
              } else {
                _downloadFile(url);
              }
            },
            child: const Text(
              'Open',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _downloadFile(url);
            },
            child: const Text(
              'Download',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadFile(String fileUrl) async {
    try {
      EasyLoading.show(
        status: 'Downloading...',
        maskType: EasyLoadingMaskType.black,
      );

      // Step 1: Download the file
      final response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode != 200 && response.statusCode != 201) {
        EasyLoading.dismiss();
        EasyLoading.showError(
          'Download failed: ${response.statusCode}',
          duration: const Duration(seconds: 2),
        );
        return;
      }

      // Step 2: Extract file name and type
      final String fileName = fileUrl.split('/').last.split('?').first;

      // Step 3: Save to temporary directory first
      final tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(response.bodyBytes);

      EasyLoading.dismiss();

      // Step 4: Show file info
      final fileSizeInMB = (response.bodyBytes.length / (1024 * 1024))
          .toStringAsFixed(2);
      debugPrint('✅ File downloaded successfully');
      debugPrint('📁 File name: $fileName');
      debugPrint('📊 File size: $fileSizeInMB MB');
      debugPrint('📱 Temp path: ${tempFile.path}');

      // Step 5: Show success message and open share sheet immediately
      EasyLoading.showSuccess(
        '📥 Tap to save to Files',
        duration: const Duration(seconds: 2),
      );

      // Step 6: Open iOS Share Sheet to save to Files app
      await Future.delayed(const Duration(milliseconds: 500));
      _openShareSheet(tempFile, fileName);
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('❌ Download error: $e');
      EasyLoading.showError(
        'Error downloading: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _openShareSheet(File file, String fileName) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Downloaded file: $fileName',
        ),
      );

      debugPrint('📤 Share sheet result: $result');
    } catch (e) {
      debugPrint('❌ Share sheet error: $e');
      EasyLoading.showError(
        'Error sharing: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _shareFile(String fileUrl) async {
    try {
      await SharePlus.instance.share(
        ShareParams(text: fileUrl, subject: 'Order attachment'),
      );
    } catch (e) {
      EasyLoading.showError(
        'Error sharing file: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _showDirectCancelDialog({
    required BuildContext context,
    required OrderDetailsModel order,
    required OrderDetailsController controller,
    required MyOrdersController orderController,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.backGroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.secondaryTextColor.withValues(alpha: 0.3),
          ),
        ),
        title: Text(
          'Cancel Order',
          style: getTextStyle(
            color: AppColors.primaryTextColor,
            fontweight: FontWeight.w600,
            fontsize: 18,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this order?',
          style: getTextStyle(
            color: AppColors.secondaryTextColor,
            fontsize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'No, Keep Order',
              style: getTextStyle(color: AppColors.secondaryTextColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              EasyLoading.show(status: 'Cancelling...');
              try {
                final success = await orderController.updateOrderStatus(
                  orderId: order.id.toString(),
                  status: OrderStatus.CANCELLED,
                );
                if (success) {
                  await controller.fetchOrderDetails(order.id.toString());
                }
              } finally {
                EasyLoading.dismiss();
              }
            },
            child: Text(
              'Yes, Cancel',
              style: getTextStyle(
                color: AppColors.redColor,
                fontweight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRequestCancellationDialog({
    required BuildContext context,
    required OrderDetailsModel order,
    required OrderDetailsController controller,
    required MyOrdersController orderController,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.backGroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.secondaryTextColor.withValues(alpha: 0.3),
          ),
        ),
        title: Text(
          'Request Cancellation',
          style: getTextStyle(
            color: AppColors.primaryTextColor,
            fontweight: FontWeight.w600,
            fontsize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Since this order is currently in progress, a cancellation request will be sent to the seller for approval.',
              style: getTextStyle(
                color: AppColors.secondaryTextColor,
                fontsize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Once the seller accepts, the order will be cancelled and your payment will be refunded.',
              style: getTextStyle(
                color: AppColors.primaryTextColor.withValues(alpha: 0.8),
                fontsize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: getTextStyle(color: AppColors.secondaryTextColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.requestCancellation(order.id);
            },
            child: Text(
              'Send Request',
              style: getTextStyle(
                color: AppColors.redColor,
                fontweight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAcceptCancellationDialog({
    required BuildContext context,
    required OrderDetailsModel order,
    required OrderDetailsController controller,
    required MyOrdersController orderController,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.backGroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.secondaryTextColor.withValues(alpha: 0.3),
          ),
        ),
        title: Text(
          'Accept Cancellation',
          style: getTextStyle(
            color: AppColors.primaryTextColor,
            fontweight: FontWeight.w600,
            fontsize: 18,
          ),
        ),
        content: Text(
          'Are you sure you want to accept this cancellation request? The order will be cancelled and payment refunded to the buyer.',
          style: getTextStyle(
            color: AppColors.secondaryTextColor,
            fontsize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Back',
              style: getTextStyle(color: AppColors.secondaryTextColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.acceptCancellation(order.id);
            },
            child: Text(
              'Accept & Cancel',
              style: getTextStyle(
                color: AppColors.redColor,
                fontweight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeclineCancellationDialog({
    required BuildContext context,
    required OrderDetailsModel order,
    required OrderDetailsController controller,
    required MyOrdersController orderController,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.backGroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.secondaryTextColor.withValues(alpha: 0.3),
          ),
        ),
        title: Text(
          'Decline Cancellation',
          style: getTextStyle(
            color: AppColors.primaryTextColor,
            fontweight: FontWeight.w600,
            fontsize: 18,
          ),
        ),
        content: Text(
          'Are you sure you want to decline this cancellation request? The order will remain in progress and you can continue fulfilling it.',
          style: getTextStyle(
            color: AppColors.secondaryTextColor,
            fontsize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Back',
              style: getTextStyle(color: AppColors.secondaryTextColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.declineCancellation(order.id);
            },
            child: Text(
              'Decline Request',
              style: getTextStyle(
                color: AppColors.primaryTextColor,
                fontweight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportIssueDialog({
    required BuildContext context,
    required OrderDetailsModel order,
    required OrderDetailsController controller,
  }) {
    final TextEditingController descController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final Rxn<File> selectedFile = Rxn<File>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: AppColors.backGroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: AppColors.secondaryTextColor.withValues(alpha: 0.3),
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flag_outlined,
                        color: Color(0xFFF59E0B),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Report an Issue',
                            style: getTextStyle(
                              color: AppColors.primaryTextColor,
                              fontweight: FontWeight.w600,
                              fontsize: 17,
                            ),
                          ),
                          Text(
                            'Order: ${order.orderCode}',
                            style: getTextStyle(
                              color: AppColors.secondaryTextColor,
                              fontsize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(bottomSheetContext),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Explain what went wrong:',
                  style: getTextStyle(
                    color: AppColors.secondaryTextColor,
                    fontsize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descController,
                  maxLines: 4,
                  style: getTextStyle(
                    color: AppColors.primaryTextColor,
                    fontsize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Describe the problem in detail...',
                    hintStyle: getTextStyle(
                      color: AppColors.secondaryTextColor.withValues(
                        alpha: 0.6,
                      ),
                      fontsize: 13,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.secondaryTextColor.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.secondaryTextColor.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFF59E0B)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please describe the issue';
                    }
                    if (value.trim().length < 10) {
                      return 'Please provide more details (at least 10 characters)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Attach Evidence / Proof (Optional):',
                  style: getTextStyle(
                    color: AppColors.secondaryTextColor,
                    fontsize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final file = selectedFile.value;
                  if (file != null) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.image,
                            color: Color(0xFFF59E0B),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              file.path.split('/').last,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: getTextStyle(
                                color: AppColors.primaryTextColor,
                                fontsize: 12,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white54,
                              size: 18,
                            ),
                            onPressed: () => selectedFile.value = null,
                          ),
                        ],
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (picked != null) {
                        selectedFile.value = File(picked.path);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.secondaryTextColor.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.cloud_upload_outlined,
                            size: 28,
                            color: Colors.white54,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap to upload screenshot or photo proof',
                            style: getTextStyle(
                              color: AppColors.secondaryTextColor,
                              fontsize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: CustomPrimaryButton(
                    buttonText: 'Submit Dispute',
                    gradientColor: const [
                      Color.fromARGB(255, 120, 60, 0),
                      Color.fromARGB(255, 217, 119, 6),
                      Color.fromARGB(255, 120, 60, 0),
                    ],
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        final desc = descController.text.trim();
                        final file = selectedFile.value;
                        Navigator.pop(bottomSheetContext);
                        await controller.reportAnIssue(
                          orderId: order.id,
                          description: desc,
                          proofFile: file,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onTap,
    Color? borderColor,
    Color? textColor,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              borderColor ??
              AppColors.secondaryTextColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: textColor ?? AppColors.primaryTextColor,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getTextStyle(
                      color: textColor ?? AppColors.primaryTextColor,
                      fontsize: 14,
                      fontweight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisputeLockedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1C08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Under Review by DaConnect',
                  style: getTextStyle(
                    color: const Color(0xFFF59E0B),
                    fontweight: FontWeight.bold,
                    fontsize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'A dispute has been submitted for this order. Proof uploads, fund releases, and cancellations are temporarily locked while DaConnect reviews the case.',
            style: getTextStyle(
              color: AppColors.primaryTextColor.withValues(alpha: 0.9),
              fontsize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerCancelRequestedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: Color(0xFF60A5FA),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cancellation Requested',
                  style: getTextStyle(
                    color: const Color(0xFF93C5FD),
                    fontweight: FontWeight.w600,
                    fontsize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Waiting for the creator to accept or decline your cancellation request.',
                  style: getTextStyle(
                    color: AppColors.secondaryTextColor,
                    fontsize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCancelRequestedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2C1616),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.redColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.redColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: AppColors.redColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cancellation Request Received',
                  style: getTextStyle(
                    color: AppColors.redColor,
                    fontweight: FontWeight.w600,
                    fontsize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'The buyer has requested to cancel this order. Please accept to refund the buyer, or decline to continue fulfilling.',
                  style: getTextStyle(
                    color: AppColors.primaryTextColor.withValues(alpha: 0.9),
                    fontsize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Delete previous instance and create a fresh one for each order
    // The onReady() callback will ensure arguments are properly read
    if (Get.isRegistered<OrderDetailsController>()) {
      Get.delete<OrderDetailsController>(force: true);
    }
    final controller = Get.put(OrderDetailsController());
    final orderController = Get.isRegistered<MyOrdersController>()
        ? Get.find<MyOrdersController>()
        : Get.put(MyOrdersController());

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(right: 16, left: 16, top: 74, bottom: 60),
          child: Column(
            children: [
              CustomAppBar2(
                title: 'Order Details',
                leadingIconUrl: Iconpath.backIcon,
                onLeadingTap: () async {
                  // Refresh orders list before going back
                  try {
                    await orderController.loadOrders();
                  } catch (_) {}
                  Get.back();
                },
              ),
              SizedBox(height: 32),
              Obx(() {
                if (controller.isLoading.value &&
                    controller.order.value == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(
                        color: AppColors.redColor,
                      ),
                    ),
                  );
                }

                final order = controller.order.value;
                if (order == null) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReviewerDetails(order: order),
                    SizedBox(height: 16),
                    FutureBuilder<String?>(
                      future: (() {
                        try {
                          return Get.find<SharedPreferencesHelperController>()
                              .getUserId();
                        } catch (_) {
                          return Get.put(
                            SharedPreferencesHelperController(),
                          ).getUserId();
                        }
                      })(),
                      builder: (context, snapshot) {
                        final loggedInUserId = snapshot.data;
                        final isBuyer =
                            loggedInUserId != null &&
                            loggedInUserId == order.buyerId;
                        return OrderEscrowDeadlineBanner(
                          order: order,
                          isBuyer: isBuyer,
                          hasOpenDispute: controller.hasOpenDispute.value,
                          onExpired: () =>
                              controller.handleDeadlineExpired(order.id),
                        );
                      },
                    ),
                    SizedBox(height: 8),

                    Text(
                      'Order Details',
                      style: getTextStyle(
                        color: AppColors.primaryTextColor,
                        fontweight: FontWeight.w600,
                        fontsize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.backGroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.secondaryTextColor),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Order ID', order.orderCode),
                          _buildDetailRow(
                            'Order Created',
                            _formatDate(order.orderCreated),
                          ),
                          if (order.status.toUpperCase() == 'CANCELLED' ||
                              order.cancelledAt.isNotEmpty)
                            _buildDetailRow(
                              'Cancelled Date',
                              _formatDate(
                                order.cancelledAt.isNotEmpty
                                    ? order.cancelledAt
                                    : order.orderCreated,
                              ),
                            )
                          else if (order.status.toUpperCase() == 'RELEASED' ||
                              order.status.toUpperCase() == 'COMPLETED' ||
                              order.status.toUpperCase() == 'COMPLETE' ||
                              order.status.toUpperCase() == 'PROOF_SUBMITTED')
                            _buildDetailRow(
                              'Delivered Date',
                              _formatDate(_resolveDeliveredDate(order)),
                            )
                          else
                            _buildDetailRow(
                              'Delivery Date',
                              _formatDate(order.deliveryDate),
                            ),
                          _buildDetailRow(
                            'Service Price',
                            '\$${(order.servicePrice / 100).toStringAsFixed(2)}',
                          ),
                          _buildDetailRow(
                            'Platform Fee (${order.platformRate}%)',
                            '\$${(order.platformFee / 100).toStringAsFixed(2)}',
                          ),
                          Divider(
                            color: AppColors.secondaryTextColor.withValues(
                              alpha: .4,
                            ),
                            height: 20,
                          ),
                          _buildDetailRow(
                            'Total',
                            '\$${((order.servicePrice + order.platformFee) / 100).toStringAsFixed(2)}',
                            isBold: true,
                          ),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0xFF353434),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.verified_user,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Payment is held securely until post is confirmed live.',
                                    style: getTextStyle(
                                      color: AppColors.secondaryTextColor,
                                      fontsize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Secured by',
                                style: getTextStyle(
                                  color: Colors.white38,
                                  fontsize: 11,
                                  fontweight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(width: 8),
                              Image.asset(Iconpath.stripeIcon),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (order.status.toUpperCase() != 'CANCELLED') ...[
                      SizedBox(height: 24),
                      Text(
                        'Promotion Info',
                        style: getTextStyle(
                          color: AppColors.primaryTextColor,
                          fontweight: FontWeight.w600,
                          fontsize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.backGroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (order.promotionDate.isNotEmpty) ...[
                              _buildDetailRow(
                                'Promotion Date',
                                _formatDate(order.promotionDate),
                              ),
                              Divider(
                                color: AppColors.secondaryTextColor.withValues(
                                  alpha: .2,
                                ),
                                height: 20,
                              ),
                            ],
                            Text(
                              'Caption / Instructions',
                              style: getTextStyle(
                                color: AppColors.secondaryTextColor,
                                fontsize: 13,
                                fontweight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 6),
                            ExpandableText(
                              text: order.captionOrInstructions.isNotEmpty
                                  ? order.captionOrInstructions
                                  : 'No instructions provided.',
                              style: getTextStyle(
                                color: AppColors.primaryTextColor,
                                fontsize: 14,
                              ),
                            ),
                            if (order.specialNotes.isNotEmpty) ...[
                              Divider(
                                color: AppColors.secondaryTextColor.withValues(
                                  alpha: .2,
                                ),
                                height: 24,
                              ),
                              Text(
                                'Special Notes',
                                style: getTextStyle(
                                  color: AppColors.secondaryTextColor,
                                  fontsize: 13,
                                  fontweight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 6),
                              ExpandableText(
                                text: order.specialNotes,
                                style: getTextStyle(
                                  color: AppColors.primaryTextColor,
                                  fontsize: 14,
                                ),
                              ),
                            ],
                            if (order.files.isNotEmpty) ...[
                              Divider(
                                color: AppColors.secondaryTextColor.withValues(
                                  alpha: .2,
                                ),
                                height: 24,
                              ),
                              Text(
                                'Attachments',
                                style: getTextStyle(
                                  color: AppColors.secondaryTextColor,
                                  fontsize: 13,
                                  fontweight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              ...order.files.map((fileUrl) {
                                final fileName = fileUrl
                                    .split('/')
                                    .last
                                    .split('?')
                                    .first;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E1E1E),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.attach_file,
                                          color: AppColors.redColor,
                                          size: 20,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            fileName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: getTextStyle(
                                              color: AppColors.primaryTextColor,
                                              fontsize: 13,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'View attachment',
                                          onPressed: () =>
                                              _viewFile(context, fileUrl),
                                          icon: Icon(
                                            Icons.visibility_outlined,
                                            color: AppColors.secondaryTextColor,
                                            size: 19,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Download attachment',
                                          onPressed: () =>
                                              _downloadFile(fileUrl),
                                          icon: Icon(
                                            Icons.download_outlined,
                                            color: AppColors.secondaryTextColor,
                                            size: 19,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Share attachment',
                                          onPressed: () => _shareFile(fileUrl),
                                          icon: Icon(
                                            Icons.share_outlined,
                                            color: AppColors.redColor,
                                            size: 19,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 24),

                    Text(
                      'Order Timeline',
                      style: getTextStyle(
                        color: AppColors.primaryTextColor,
                        fontweight: FontWeight.w600,
                        fontsize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    OrderTimelineWidget(
                      timeline: order.timeline,
                      proofUrl: order.proofUrl,
                      status: order.status,
                    ),
                  ],
                );
              }),
              SizedBox(height: 18),
              Obx(() {
                final order = controller.order.value;
                if (order == null) return const SizedBox.shrink();

                final statusUpper = order.status.toUpperCase().trim();
                final hasOpenDispute = controller.hasOpenDispute.value;
                final isCancelRequested = order.isCancelRequested;

                return FutureBuilder<String?>(
                  future: (() {
                    try {
                      return Get.find<SharedPreferencesHelperController>()
                          .getUserId();
                    } catch (_) {
                      return Get.put(
                        SharedPreferencesHelperController(),
                      ).getUserId();
                    }
                  })(),
                  builder: (context, snapshot) {
                    final loggedInUserId = snapshot.data;
                    final isBuyer =
                        loggedInUserId != null &&
                        loggedInUserId == order.buyerId;

                    // 1. TERMINAL STATE: CANCELLED (no actions)
                    if (statusUpper == 'CANCELLED') {
                      return const SizedBox.shrink();
                    }

                    // 2. TERMINAL STATE: RELEASED / COMPLETED
                    if (statusUpper == 'RELEASED' ||
                        statusUpper == 'COMPLETE' ||
                        statusUpper == 'COMPLETED') {
                      if (isBuyer) {
                        return CustomPrimaryButton(
                          buttonText: 'Post Review',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => ReviewPopup(
                                onSubmit: (rating, reviewText) async {
                                  final success = await controller.postReview(
                                    rating: rating,
                                    reviewText: reviewText,
                                  );
                                  if (success) {
                                    showGradientSnackBar(
                                      title: 'Success',
                                      message: 'Review posted successfully!',
                                    );
                                    try {
                                      await orderController.loadOrders();
                                    } catch (_) {}
                                  }
                                },
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    // 3. DISPUTE UNDER REVIEW (LOCKED STATE FOR BOTH PARTIES)
                    if (hasOpenDispute) {
                      return _buildDisputeLockedBanner();
                    }

                    // 4. PENDING STATUS (PRE-ACCEPTANCE)
                    if (statusUpper == 'PENDING') {
                      if (!isBuyer) {
                        // Seller: Receive Order & Direct Cancel
                        return Row(
                          children: [
                            Expanded(
                              child: CustomPrimaryButton(
                                buttonText: 'Receive Order',
                                onTap: () async {
                                  await orderController.updateOrderStatus(
                                    orderId: order.id.toString(),
                                    status: OrderStatus.IN_PROGRESS,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSecondaryButton(
                                text: 'Cancel Order',
                                textColor: AppColors.redColor,
                                borderColor: AppColors.redColor.withValues(
                                  alpha: 0.4,
                                ),
                                onTap: () => _showDirectCancelDialog(
                                  context: context,
                                  order: order,
                                  controller: controller,
                                  orderController: orderController,
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Buyer: Direct Cancel
                        return CustomPrimaryButton(
                          buttonText: 'Cancel Order',
                          onTap: () => _showDirectCancelDialog(
                            context: context,
                            order: order,
                            controller: controller,
                            orderController: orderController,
                          ),
                        );
                      }
                    }

                    // 5. IN_PROGRESS / PROOF_SUBMITTED / RESUBMIT
                    // CASE A: isCancelRequested == true
                    if (isCancelRequested) {
                      if (isBuyer) {
                        // Buyer: Waiting Banner + Report an Issue button
                        return Column(
                          children: [
                            _buildBuyerCancelRequestedBanner(),
                            const SizedBox(height: 14),
                            _buildSecondaryButton(
                              text: 'Report an Issue',
                              icon: Icons.flag_outlined,
                              textColor: const Color(0xFFF59E0B),
                              borderColor: const Color(
                                0xFFF59E0B,
                              ).withValues(alpha: 0.4),
                              onTap: () => _showReportIssueDialog(
                                context: context,
                                order: order,
                                controller: controller,
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Seller: Notice + Accept Cancellation + Decline Cancellation
                        return Column(
                          children: [
                            _buildSellerCancelRequestedBanner(),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomPrimaryButton(
                                    buttonText: 'Accept Cancellation',
                                    fontSize: 14,
                                    gradientColor: const [
                                      Color.fromARGB(255, 96, 0, 15),
                                      Color.fromARGB(255, 187, 2, 36),
                                      Color.fromARGB(255, 96, 0, 15),
                                    ],
                                    onTap: () => _showAcceptCancellationDialog(
                                      context: context,
                                      order: order,
                                      controller: controller,
                                      orderController: orderController,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSecondaryButton(
                                    text: 'Decline',
                                    textColor: AppColors.primaryTextColor,
                                    onTap: () => _showDeclineCancellationDialog(
                                      context: context,
                                      order: order,
                                      controller: controller,
                                      orderController: orderController,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    }

                    // CASE B: isCancelRequested == false
                    if (isBuyer) {
                      // Buyer options based on status
                      if (statusUpper == 'PROOF_SUBMITTED' &&
                          !order.isCancalProofSubmitted) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: CustomPrimaryButton(
                                    buttonText: 'Confirm Order',
                                    onTap: () async {
                                      final success = await controller
                                          .confirmOrder();
                                      if (success) {
                                        EasyLoading.showSuccess(
                                          'Order confirmed & payment released',
                                        );
                                        try {
                                          await orderController.loadOrders();
                                        } catch (_) {}
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSecondaryButton(
                                    text: 'Reject Proof',
                                    textColor: AppColors.redColor,
                                    borderColor: AppColors.redColor.withValues(
                                      alpha: 0.4,
                                    ),
                                    onTap: () => _showRejectProofDialog(
                                      context: context,
                                      controller: controller,
                                      orderController: orderController,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSecondaryButton(
                                    text: 'Request Cancellation',
                                    textColor: AppColors.secondaryTextColor,
                                    onTap: () => _showRequestCancellationDialog(
                                      context: context,
                                      order: order,
                                      controller: controller,
                                      orderController: orderController,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSecondaryButton(
                                    text: 'Report an Issue',
                                    icon: Icons.flag_outlined,
                                    textColor: const Color(0xFFF59E0B),
                                    borderColor: const Color(
                                      0xFFF59E0B,
                                    ).withValues(alpha: 0.4),
                                    onTap: () => _showReportIssueDialog(
                                      context: context,
                                      order: order,
                                      controller: controller,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }

                      if (statusUpper == 'RESUBMIT' ||
                          (statusUpper == 'PROOF_SUBMITTED' &&
                              order.isCancalProofSubmitted)) {
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.redColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.redColor.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Proof Rejected. Waiting for seller to re-submit proof.',
                                textAlign: TextAlign.center,
                                style: getTextStyle(
                                  color: AppColors.primaryTextColor,
                                  fontsize: 13,
                                  fontweight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSecondaryButton(
                                    text: 'Request Cancellation',
                                    textColor: AppColors.secondaryTextColor,
                                    onTap: () => _showRequestCancellationDialog(
                                      context: context,
                                      order: order,
                                      controller: controller,
                                      orderController: orderController,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSecondaryButton(
                                    text: 'Report an Issue',
                                    icon: Icons.flag_outlined,
                                    textColor: const Color(0xFFF59E0B),
                                    borderColor: const Color(
                                      0xFFF59E0B,
                                    ).withValues(alpha: 0.4),
                                    onTap: () => _showReportIssueDialog(
                                      context: context,
                                      order: order,
                                      controller: controller,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }

                      // IN_PROGRESS: Buyer sees Request Cancellation and Report an Issue
                      return Row(
                        children: [
                          Expanded(
                            child: _buildSecondaryButton(
                              text: 'Request Cancellation',
                              textColor: AppColors.secondaryTextColor,
                              onTap: () => _showRequestCancellationDialog(
                                context: context,
                                order: order,
                                controller: controller,
                                orderController: orderController,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSecondaryButton(
                              text: 'Report an Issue',
                              icon: Icons.flag_outlined,
                              textColor: const Color(0xFFF59E0B),
                              borderColor: const Color(
                                0xFFF59E0B,
                              ).withValues(alpha: 0.4),
                              onTap: () => _showReportIssueDialog(
                                context: context,
                                order: order,
                                controller: controller,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Seller options based on status
                      if (statusUpper == 'RESUBMIT' ||
                          (statusUpper == 'PROOF_SUBMITTED' &&
                              order.isCancalProofSubmitted)) {
                        return Column(
                          children: [
                            CustomPrimaryButton(
                              buttonText: 'Re-submit Proof',
                              onTap: () => _pickAndConfirmProofUpload(
                                context,
                                controller,
                                orderController,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildSecondaryButton(
                              text: 'Cancel Order',
                              textColor: AppColors.redColor,
                              borderColor: AppColors.redColor.withValues(
                                alpha: 0.4,
                              ),
                              onTap: () => _showDirectCancelDialog(
                                context: context,
                                order: order,
                                controller: controller,
                                orderController: orderController,
                              ),
                            ),
                          ],
                        );
                      }

                      if (statusUpper == 'PROOF_SUBMITTED') {
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(
                                    0xFF3B82F6,
                                  ).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                'Proof submitted. Waiting for buyer review.',
                                textAlign: TextAlign.center,
                                style: getTextStyle(
                                  color: AppColors.primaryTextColor,
                                  fontsize: 13,
                                  fontweight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildSecondaryButton(
                              text: 'Cancel Order',
                              textColor: AppColors.redColor,
                              borderColor: AppColors.redColor.withValues(
                                alpha: 0.4,
                              ),
                              onTap: () => _showDirectCancelDialog(
                                context: context,
                                order: order,
                                controller: controller,
                                orderController: orderController,
                              ),
                            ),
                          ],
                        );
                      }

                      // IN_PROGRESS: Seller sees Upload Proof & Cancel Order
                      return Row(
                        children: [
                          Expanded(
                            child: CustomPrimaryButton(
                              buttonText: 'Upload Proof',
                              onTap: () => _pickAndConfirmProofUpload(
                                context,
                                controller,
                                orderController,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSecondaryButton(
                              text: 'Cancel Order',
                              textColor: AppColors.redColor,
                              borderColor: AppColors.redColor.withValues(
                                alpha: 0.4,
                              ),
                              onTap: () => _showDirectCancelDialog(
                                context: context,
                                order: order,
                                controller: controller,
                                orderController: orderController,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _resolveDeliveredDate(OrderDetailsModel order) {
    if (order.releasedAt.isNotEmpty) return order.releasedAt;
    if (order.proofSubmittedAt.isNotEmpty) return order.proofSubmittedAt;
    if (order.deliveryDate.isNotEmpty) return order.deliveryDate;
    for (final step in order.timeline.reversed) {
      if (step.isCompleted && step.dateTime.isNotEmpty) {
        return step.dateTime;
      }
    }
    return order.orderCreated;
  }

  String _formatDate(String raw) {
    if (raw.trim().isEmpty || raw.trim() == '-') return '-';
    try {
      final trimmed = raw.trim();
      DateTime dt;
      if (RegExp(r'^\d+$').hasMatch(trimmed)) {
        int ts = int.parse(trimmed);
        if (trimmed.length <= 10) {
          ts *= 1000;
        }
        dt = DateTime.fromMillisecondsSinceEpoch(ts).toLocal();
      } else {
        DateTime? parsed = DateTime.tryParse(trimmed);
        if (parsed == null) {
          for (final fmt in [
            'MM/dd/yyyy',
            'dd/MM/yyyy',
            'yyyy-MM-dd',
            'dd MMM yyyy',
            'd MMM yyyy',
            'MMM d, yyyy',
            'MMMM d, yyyy',
            'd MMMM yyyy',
          ]) {
            try {
              parsed = DateFormat(fmt).parse(trimmed);
              break;
            } catch (_) {}
          }
        }
        if (parsed != null) {
          dt = parsed.toLocal();
        } else {
          return raw;
        }
      }
      return DateFormat('MMM d, yyyy · h:mm a').format(dt);
    } catch (_) {
      return raw;
    }
  }

  Widget _buildDetailRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: getTextStyle(
              color: AppColors.secondaryTextColor,
              fontsize: 13,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: getTextStyle(
                color: AppColors.primaryTextColor,
                fontsize: 13,
                fontweight: isBold ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectProofDialog({
    required BuildContext context,
    required OrderDetailsController controller,
    required MyOrdersController orderController,
  }) {
    final TextEditingController reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.backGroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.secondaryTextColor.withValues(alpha: 0.3),
          ),
        ),
        title: Text(
          'Reject Proof',
          style: getTextStyle(
            color: AppColors.primaryTextColor,
            fontweight: FontWeight.w600,
            fontsize: 18,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please specify the reason for rejecting the proof:',
                style: getTextStyle(
                  color: AppColors.secondaryTextColor,
                  fontsize: 13,
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: reasonController,
                maxLines: 3,
                style: getTextStyle(
                  color: AppColors.primaryTextColor,
                  fontsize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter reason (required)...',
                  hintStyle: getTextStyle(
                    color: AppColors.secondaryTextColor,
                    fontsize: 13,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.secondaryTextColor.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.secondaryTextColor.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.redColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Reason is required to reject proof';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: getTextStyle(color: AppColors.secondaryTextColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final reason = reasonController.text.trim();
                Get.back();
                final success = await controller.rejectProof(reason: reason);
                if (success) {
                  EasyLoading.showSuccess(
                    'Proof rejected. Seller can now re-submit.',
                  );
                  try {
                    await orderController.loadOrders();
                  } catch (_) {}
                }
              }
            },
            child: Text(
              'Reject Proof',
              style: getTextStyle(
                color: AppColors.redColor,
                fontweight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

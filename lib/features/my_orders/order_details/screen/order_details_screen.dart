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
                  leading: Icon(Icons.videocam, color: AppColors.primaryTextColor),
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
                    if (result == null || result.files.single.path == null) return;
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
                  leading: Icon(Icons.videocam, color: AppColors.primaryTextColor),
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
      Get.to(() => Scaffold(
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
          ));
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
          title: const Text(
            'Open File',
            style: TextStyle(color: Colors.white),
          ),
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
        title: const Text(
          'PDF File',
          style: TextStyle(color: Colors.white),
        ),
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
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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
      final fileSizeInMB = (response.bodyBytes.length / (1024 * 1024)).toStringAsFixed(2);
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
        ShareParams(
          text: fileUrl,
          subject: 'Order attachment',
        ),
      );
    } catch (e) {
      EasyLoading.showError(
        'Error sharing file: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _cancelOrder({
    required BuildContext context,
    required OrderDetailsModel order,
    required OrderDetailsController controller,
    required MyOrdersController orderController,
  }) async {
    final prefs = Get.find<SharedPreferencesHelperController>();
    final loggedInUserId = await prefs.getUserId();
    final isBuyer = loggedInUserId != null && loggedInUserId == order.buyerId;
    final isProofSubmittedOrRejected =
        order.status.toUpperCase() == 'PROOF_SUBMITTED' ||
        order.status.toUpperCase() == 'RESUBMIT' ||
        order.isCancalProofSubmitted ||
        order.proofUrl.isNotEmpty;

    if (isBuyer && isProofSubmittedOrRejected) {
      EasyLoading.showError(
        'You cannot cancel the order once proof has been submitted.',
        duration: const Duration(seconds: 3),
      );
      return;
    }

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
                    SizedBox(height: 24),

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
                              order.status.toUpperCase() == 'COMPLETE')
                            _buildDetailRow(
                              'Delivered Date',
                              _formatDate(order.deliveryDate),
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
                          border: Border.all(color: AppColors.secondaryTextColor),
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
                                final fileName = fileUrl.split('/').last.split('?').first;
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
                                          onPressed: () => _viewFile(context, fileUrl),
                                          icon: Icon(
                                            Icons.visibility_outlined,
                                            color: AppColors.secondaryTextColor,
                                            size: 19,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Download attachment',
                                          onPressed: () => _downloadFile(fileUrl),
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

                // If order is PENDING we may show both Receive and Cancel buttons
                if (order.status == 'PENDING') {
                  return FutureBuilder<String?>(
                    future: (() {
                      try {
                        return Get.find<SharedPreferencesHelperController>()
                            .getUserId();
                      } catch (_) {
                        // Ensure the SharedPreferences controller exists
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

                      final showReceive = !isBuyer;

                      if (showReceive) {
                        // Show both Receive and Cancel side-by-side
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
                            SizedBox(width: 12),
                            Expanded(
                              child: CustomPrimaryButton(
                                buttonText: 'Cancel Order',
                                onTap: () => _cancelOrder(
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

                      // If buyer, only show Cancel button (they requested cancel kept)
                      return CustomPrimaryButton(
                        buttonText: 'Cancel Order',
                        onTap: () => _cancelOrder(
                          context: context,
                          order: order,
                          controller: controller,
                          orderController: orderController,
                        ),
                      );
                    },
                  );
                }

                // For IN_PROGRESS: show Upload Proof (for seller) and Cancel
                if (order.status == 'IN_PROGRESS') {
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

                      // Seller (not buyer) can upload proof
                      if (!isBuyer) {
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
                            SizedBox(width: 12),
                            Expanded(
                              child: CustomPrimaryButton(
                                buttonText: 'Cancel Order',
                                onTap: () => _cancelOrder(
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

                      // Buyer sees Cancel button
                      return CustomPrimaryButton(
                        buttonText: 'Cancel Order',
                        onTap: () => _cancelOrder(
                          context: context,
                          order: order,
                          controller: controller,
                          orderController: orderController,
                        ),
                      );
                    },
                  );
                }

                // For RESUBMIT status (proof was rejected)
                if (order.status == 'RESUBMIT' || (order.status == 'PROOF_SUBMITTED' && order.isCancalProofSubmitted)) {
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

                      // Seller view: can re-submit proof
                      if (!isBuyer) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: CustomPrimaryButton(
                                    buttonText: 'Re-submit Proof',
                                    onTap: () => _pickAndConfirmProofUpload(
                                      context,
                                      controller,
                                      orderController,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            CustomPrimaryButton(
                              buttonText: 'Cancel Order',
                              onTap: () => _cancelOrder(
                                context: context,
                                order: order,
                                controller: controller,
                                orderController: orderController,
                              ),
                            ),
                          ],
                        );
                      }

                      // Buyer view: waiting for seller to resubmit proof + Cancel button
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.redColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.redColor.withValues(alpha: 0.3),
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
                          SizedBox(height: 12),
                          CustomPrimaryButton(
                            buttonText: 'Cancel Order',
                            onTap: () => _cancelOrder(
                              context: context,
                              order: order,
                              controller: controller,
                              orderController: orderController,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }

                // For PROOF_SUBMITTED: show Confirm Order, Reject Proof, and Cancel Order (for buyer)
                if (order.status == 'PROOF_SUBMITTED') {
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

                      // Buyer can confirm, reject, or cancel order
                      if (isBuyer) {
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
                                        // Refresh orders list in My Orders screen
                                        try {
                                          await orderController.loadOrders();
                                        } catch (_) {}
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomPrimaryButton(
                                    buttonText: 'Reject Proof',
                                    onTap: () => _showRejectProofDialog(
                                      context: context,
                                      controller: controller,
                                      orderController: orderController,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            CustomPrimaryButton(
                              buttonText: 'Cancel Order',
                              onTap: () => _cancelOrder(
                                context: context,
                                order: order,
                                controller: controller,
                                orderController: orderController,
                              ),
                            ),
                          ],
                        );
                      }

                      // Seller sees Cancel button when proof is pending review
                      return CustomPrimaryButton(
                        buttonText: 'Cancel Order',
                        onTap: () => _cancelOrder(
                          context: context,
                          order: order,
                          controller: controller,
                          orderController: orderController,
                        ),
                      );
                    },
                  );
                }

                // For RELEASED status: no buttons for anyone
                if (order.status == 'RELEASED') {
                  return FutureBuilder<String?>(
                    future: (() {
                      try {
                        final prefs =
                            Get.find<SharedPreferencesHelperController>();
                        return prefs.getUserId();
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

                      // Buyer can post a review
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
                                    // Refresh orders list in My Orders screen
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

                      // Seller sees nothing on RELEASED
                      return const SizedBox.shrink();
                    },
                  );
                }

                // For other non-PENDING statuses show the Cancel button as before
                // Do not show cancel button if the order is already CANCELLED
                if (order.status.toUpperCase() == 'CANCELLED') {
                  return const SizedBox.shrink();
                }

                return CustomPrimaryButton(
                  buttonText: 'Cancel Order',
                  onTap: () => _cancelOrder(
                    context: context,
                    order: order,
                    controller: controller,
                    orderController: orderController,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '-';
    try {
      DateTime dt;
      if (RegExp(r'^\d+$').hasMatch(raw)) {
        dt = DateTime.fromMillisecondsSinceEpoch(int.parse(raw)).toLocal();
      } else {
        dt = DateTime.parse(raw).toLocal();
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
          Text(
            value,
            style: getTextStyle(
              color: AppColors.primaryTextColor,
              fontweight: isBold ? FontWeight.w600 : FontWeight.w400,
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

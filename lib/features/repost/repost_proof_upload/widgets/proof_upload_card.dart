import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/features/repost/repost_proof_upload/controller/repost_proof_upload_controller.dart';

class ProofUploadCard extends StatelessWidget {
  final RepostProofUploadController controller;
  const ProofUploadCard({required this.controller, super.key});

  bool _isImageFile(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  IconData _getFileIcon(String path) {
    final ext = path.split('.').last.toLowerCase();
    if (['mp4', 'mov', 'avi', 'flv'].contains(ext)) {
      return Icons.videocam_outlined;
    } else if (['mp3', 'wav', 'aac'].contains(ext)) {
      return Icons.audio_file_outlined;
    } else if (ext == 'pdf') {
      return Icons.picture_as_pdf_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  String _getFileTypeLabel(String path, bool isVideo) {
    final ext = path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
      return 'Image File';
    } else if (['mp4', 'mov', 'avi', 'flv'].contains(ext) || isVideo) {
      return 'Video File';
    } else if (['mp3', 'wav', 'aac'].contains(ext)) {
      return 'Audio File';
    } else if (ext == 'pdf') {
      return 'PDF Document';
    }
    return 'Document File';
  }

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      options: RectDottedBorderOptions(
        color: Colors.white.withValues(alpha: 0.12),
        dashPattern: const [6, 4],
        strokeWidth: 1.5,
      ),
      child: Container(
        width: double.infinity,
        height: 150.h,
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: InkWell(
          onTap: () => controller.pickProofFile(),
          borderRadius: BorderRadius.circular(12.r),
          child: Obx(() {
            if (controller.selectedFile.value == null) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 36.r,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Upload Screenshot or Video',
                    style: getTextStyle(
                      fontsize: 13,
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                ],
              );
            } else {
              final isVideoFile = controller.isVideo.value;
              final fileName = controller.selectedFile.value!.path.split('/').last;
              final isImage = _isImageFile(fileName);

              return Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    // Thumbnail / Icon Container
                    Container(
                      width: 72.w,
                      height: 72.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Center(
                        child: isImage
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.file(
                                  controller.selectedFile.value!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : Icon(
                                _getFileIcon(fileName),
                                color: AppColors.redColor,
                                size: 28.r,
                              ),
                      ),
                    ),
                    SizedBox(width: 14.w),

                    // File Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: getTextStyle(
                              fontsize: 13,
                              fontweight: FontWeight.w600,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _getFileTypeLabel(fileName, isVideoFile),
                            style: getTextStyle(
                              fontsize: 11,
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Clear Button
                    IconButton(
                      icon: const Icon(Icons.cancel_rounded, color: Colors.grey),
                      onPressed: () => controller.clearSelectedFile(),
                    ),
                  ],
                ),
              );
            }
          }),
        ),
      ),
    );
  }
}

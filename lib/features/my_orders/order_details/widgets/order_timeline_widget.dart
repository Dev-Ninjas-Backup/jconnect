import 'package:flutter/material.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/features/my_orders/order_details/model/order_timeline_step.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:io';

class OrderTimelineWidget extends StatelessWidget {
  final List<OrderTimelineStep> timeline;
  final List<String> proofUrl;

  const OrderTimelineWidget({
    super.key,
    required this.timeline,
    required this.proofUrl,
  });

  String _formatDateShort(String iso) {
    try {
      final dt = DateTime.parse(iso);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month - 1];
      int hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$day $month • $hour:$minute $ampm';
    } catch (_) {
      return iso;
    }
  }

  Future<void> _viewAttachment(BuildContext context) async {
    if (proofUrl.isEmpty) {
      EasyLoading.showError('No attachment available');
      return;
    }

    try {
      final url = proofUrl.last;

      // Show dialog with image preview
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: AppColors.backGroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.secondaryTextColor),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400, maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attachment Preview',
                        style: getTextStyle(
                          color: AppColors.primaryTextColor,
                          fontweight: FontWeight.w600,
                          fontsize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: AppColors.secondaryTextColor.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            'Failed to load image',
                            style: getTextStyle(
                              color: AppColors.secondaryTextColor,
                              fontsize: 14,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.redColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      EasyLoading.showError('Error: $e');
    }
  }

  Future<void> _downloadAttachment() async {
    if (proofUrl.isEmpty) {
      EasyLoading.showError('No attachment available');
      return;
    }

    try {
      EasyLoading.show(status: 'Downloading...');

      // Download the latest proof (last index)
      final url = proofUrl.last;
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final dir = await getDownloadsDirectory();
        if (dir == null) {
          EasyLoading.showError('Downloads directory not found');
          return;
        }
        final fileName =
            'attachment_${DateTime.now().millisecondsSinceEpoch}.${_getFileExtension(url)}';
        final filePath = '${dir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        EasyLoading.dismiss();
        EasyLoading.showSuccess('Downloaded proof file to: $filePath');
      } else {
        EasyLoading.showError('Download failed');
      }
    } catch (e) {
      EasyLoading.showError('Error: $e');
    }
  }

  String _getFileExtension(String url) {
    if (url.contains('.jpg')) return 'jpg';
    if (url.contains('.jpeg')) return 'jpeg';
    if (url.contains('.png')) return 'png';
    if (url.contains('.pdf')) return 'pdf';
    if (url.contains('.gif')) return 'gif';
    if (url.contains('.mp4')) return 'mp4';
    if (url.contains('.webp')) return 'webp';
    return 'jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backGroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryTextColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(timeline.length, (index) {
          final step = timeline[index];
          final isLast = index == timeline.length - 1;
          final isWaitingForProof = step.title == 'Waiting for proof';
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: step.isCompleted
                              ? AppColors.redColor
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: step.isCompleted
                            ? Icon(Icons.check, color: Colors.white, size: 12)
                            : null,
                      ),
                      if (!isLast)
                        Container(width: 2, height: 35, color: Colors.white24),
                    ],
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: getTextStyle(
                                    color: AppColors.primaryTextColor,
                                    fontweight: FontWeight.w500,
                                  ),
                                ),
                                if (isWaitingForProof &&
                                    timeline
                                        .sublist(0, index)
                                        .every((s) => s.isCompleted) &&
                                    proofUrl.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _viewAttachment(context),
                                          child: Text(
                                            'View Attachment',
                                            style: getTextStyle(
                                              color: AppColors.redColor,
                                              fontsize: 10,
                                              fontweight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        GestureDetector(
                                          onTap: _downloadAttachment,
                                          child: Text(
                                            'Download Attachment',
                                            style: getTextStyle(
                                              color: AppColors.redColor,
                                              fontsize: 10,
                                              fontweight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (step.dateTime.isNotEmpty && index == 0)
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 140),
                              child: Text(
                                _formatDateShort(step.dateTime),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: getTextStyle(
                                  color: AppColors.secondaryTextColor,
                                  fontsize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

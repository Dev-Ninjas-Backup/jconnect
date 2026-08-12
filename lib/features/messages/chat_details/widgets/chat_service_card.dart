import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/features/messages/chat_details/controller/chat_details_controller.dart';
import 'package:jconnect/features/messages/model/chat_conversation_model.dart';
import 'package:jconnect/features/payment/payment_screen.dart';

class ChatServiceCard extends StatelessWidget {
  final ChatMessage msgItem;
  final bool isMine;
  final ChatDetailsController controller;

  const ChatServiceCard({
    super.key,
    required this.msgItem,
    required this.isMine,
    required this.controller,
  });

  String _formatDateFromDateTime(DateTime dt) {
    const months = <String>[
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
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Widget _buildReceiverFileActions(
    BuildContext context,
    ChatMessage msgItem,
    String url,
  ) {
    final sr = msgItem.serviceRequest!;
    final isAccepted = sr.isAccepted;
    final isDeclined = sr.isDeclined;
    final isPending = !isAccepted && !isDeclined;

    return Center(
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 15,
        runSpacing: 6,
        children: [
          if (isPending)
            GestureDetector(
              onTap: () {
                final srId = sr.id;
                if (srId != null && srId.isNotEmpty) {
                  controller.acceptServiceRequest(srId);
                }
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.greenAccent,
                    size: 12,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Accept',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (isPending)
            GestureDetector(
              onTap: () {
                final srId = sr.id;
                if (srId != null && srId.isNotEmpty) {
                  controller.declineServiceRequest(srId);
                }
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    color: Colors.redAccent,
                    size: 12,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Decline',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (isAccepted)
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 18),
                SizedBox(width: 3),
                Text(
                  'Accepted',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          if (isDeclined)
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cancel, color: Colors.red, size: 18),
                SizedBox(width: 3),
                Text(
                  'Declined',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          GestureDetector(
            onTap: () => controller.viewFile(context, url),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility_outlined,
                  color: Colors.blueAccent,
                  size: 18,
                ),
                SizedBox(width: 3),
                Text(
                  'View',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isAccepted)
            GestureDetector(
              onTap: () => controller.downloadFile(url),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.download_outlined,
                    color: Colors.cyanAccent,
                    size: 18,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Download',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
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
    if (msgItem.serviceId == null || msgItem.service == null) {
      return const SizedBox.shrink();
    }

    final service = msgItem.service!;
    final serviceRequest = msgItem.serviceRequest;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey[700]!,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with service name and price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${service.serviceName} - \$${service.price}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                if (service.serviceType == 'SOCIAL_POST' &&
                    (serviceRequest?.uploadedFileUrl.isNotEmpty ?? false) &&
                    serviceRequest?.requestStatus !=
                        ServiceRequestStatus.cancelled)
                  GestureDetector(
                    onTap: () => controller.shareFiles(
                      serviceRequest!.uploadedFileUrl,
                      service.serviceName,
                    ),
                    child: const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Delivery date
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white70,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Date: ${_formatDateFromDateTime(msgItem.createdAt)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            // Service request extra details
            if (serviceRequest?.hasExtraDetails == true &&
                serviceRequest?.requestStatus !=
                    ServiceRequestStatus.cancelled) ...[
              const SizedBox(height: 10),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 10),

              // Caption / Instructions
              if (serviceRequest?.captionOrInstructions?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.notes,
                        color: Colors.white54,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Instructions',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              serviceRequest!.captionOrInstructions!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Special Notes
              if (serviceRequest?.specialNotes?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.sticky_note_2_outlined,
                        color: Colors.white54,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Special Notes',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              serviceRequest!.specialNotes!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Promotion Date
              if (serviceRequest?.promotionDate?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event,
                        color: Colors.white54,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Promotion Date',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              () {
                                try {
                                  final dt = DateTime.parse(
                                    serviceRequest!.promotionDate!,
                                  ).toLocal();
                                  return DateFormat(
                                    "MMM d, yyyy · h:mm a",
                                  ).format(dt);
                                } catch (_) {
                                  return serviceRequest!.promotionDate!;
                                }
                              }(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Uploaded Files
              if (serviceRequest != null &&
                  serviceRequest.uploadedFileUrl
                      .where(
                        (u) =>
                            u.trim().isNotEmpty &&
                            u.trim().toLowerCase() != 'no file',
                      )
                      .isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.attach_file,
                            color: Colors.white54,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Attachments',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: serviceRequest.uploadedFileUrl
                            .where(
                              (u) =>
                                  u.trim().isNotEmpty &&
                                  u.trim().toLowerCase() != 'no file',
                            )
                            .map((url) {
                              final name = url.split('/').last;
                              final displayName = name.length > 18
                                  ? '${name.substring(0, 15)}...'
                                  : name;
                              return Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white12,
                                    width: 0.8,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        8,
                                        8,
                                        8,
                                        6,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.insert_drive_file_outlined,
                                            color: Colors.white54,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              displayName,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(
                                      color: Colors.white12,
                                      height: 1,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 4,
                                      ),
                                      child: isMine
                                          ? (serviceRequest.isDeclined == true
                                              ? Center(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      final srId =
                                                          serviceRequest.id;
                                                      if (srId != null &&
                                                          srId.isNotEmpty) {
                                                        controller.showUploadOptions(
                                                          context,
                                                          srId,
                                                        );
                                                      }
                                                    },
                                                    child: const Column(
                                                      children: [
                                                        Icon(
                                                          Icons.upload_file,
                                                          color: Colors.orangeAccent,
                                                          size: 18,
                                                        ),
                                                        SizedBox(height: 3),
                                                        Text(
                                                          'Upload Here',
                                                          style: TextStyle(
                                                            color: Colors.orangeAccent,
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () =>
                                                          controller.viewFile(
                                                            context,
                                                            url,
                                                          ),
                                                      child: const Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.visibility_outlined,
                                                            color: Colors.blueAccent,
                                                            size: 18,
                                                          ),
                                                          SizedBox(width: 3),
                                                          Text(
                                                            'View',
                                                            style: TextStyle(
                                                              color: Colors.blueAccent,
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 35),
                                                    GestureDetector(
                                                      onTap: () =>
                                                          controller.downloadFile(
                                                            url,
                                                          ),
                                                      child: const Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.download_outlined,
                                                            color: Colors.greenAccent,
                                                            size: 18,
                                                          ),
                                                          SizedBox(width: 3),
                                                          Text(
                                                            'Download',
                                                            style: TextStyle(
                                                              color: Colors.greenAccent,
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ))
                                          : _buildReceiverFileActions(
                                              context,
                                              msgItem,
                                              url,
                                            ),
                                    ),
                                  ],
                                ),
                              );
                            })
                            .toList(),
                      ),
                    ],
                  ),
                ),
            ],

            const SizedBox(height: 12),

            // Pay Now / Paid / Cancelled button logic
            Builder(
              builder: (context) {
                final isBuyer = service.isCustom == true ? !isMine : isMine;
                final status = serviceRequest?.requestStatus;

                if (status == null) return const SizedBox.shrink();

                if (isBuyer) {
                  if (status == ServiceRequestStatus.paid) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Paid',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    );
                  } else if (status == ServiceRequestStatus.cancelled) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red[700],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Cancelled',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    );
                  } else {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.redColor,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () async {
                          final result = await Get.to(
                            () => PaymentPage(),
                            arguments: msgItem,
                          );
                          if (result == true) {
                            controller.messagesController.markMessageAsPaid(
                              msgItem.id,
                            );
                          }
                        },
                        child: const Text(
                          'Pay Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }
                } else {
                  if (status == ServiceRequestStatus.cancelled) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red[700],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Cancelled',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

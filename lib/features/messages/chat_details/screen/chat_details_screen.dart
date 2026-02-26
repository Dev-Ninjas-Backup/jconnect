// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/messages/controller/custom_service_controller.dart';
import 'package:jconnect/features/messages/controller/messages_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jconnect/features/messages/widget/addcustomwidgets.dart';
import 'package:jconnect/features/payment/payment_screen.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jconnect/core/endpoint.dart';
import 'package:share_plus/share_plus.dart';

class ChatDetailsScreen extends StatelessWidget {
  ChatDetailsScreen({super.key});

  late final ScrollController _scrollController = ScrollController();
  late final ImagePicker _imagePicker = ImagePicker();
  late final RxList<String> selectedFiles = <String>[].obs;
  late final RxBool _initialServiceRequestSent = false.obs;

  final addCustomServiceController = Get.put(AddCustomServiceController());
  late final controller = Get.find<MessagesController>();
  late final dynamic arguments = Get.arguments;

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

  Future<void> _pickFile() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        EasyLoading.show(
          status: 'Uploading file...',
          maskType: EasyLoadingMaskType.black,
        );

        final request = http.MultipartRequest(
          'POST',
          Uri.parse(Endpoint.fileUpload),
        );

        final file = await http.MultipartFile.fromPath('file', image.path);
        request.files.add(file);

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        EasyLoading.dismiss();

        if (response.statusCode == 200 || response.statusCode == 201) {
          final jsonResponse = jsonDecode(responseBody);
          final fileUrl = jsonResponse['file'];

          if (fileUrl != null) {
            selectedFiles.add(fileUrl);
            EasyLoading.showSuccess(
              'File uploaded successfully',
              duration: Duration(seconds: 1),
            );
          } else {
            EasyLoading.showError(
              'Failed to get file URL',
              duration: Duration(seconds: 2),
            );
          }
        } else {
          EasyLoading.showError(
            'Upload failed: ${response.statusCode}',
            duration: Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(
        'Error uploading file: $e',
        duration: Duration(seconds: 2),
      );
    }
  }

  Future<void> _downloadFile(String fileUrl) async {
    try {
      EasyLoading.show(
        status: 'Downloading...',
        maskType: EasyLoadingMaskType.black,
      );

      final Directory? downloadDir = await getDownloadsDirectory();
      if (downloadDir == null) {
        EasyLoading.dismiss();
        EasyLoading.showError(
          'Downloads directory not available',
          duration: Duration(seconds: 2),
        );
        return;
      }

      final String fileName = fileUrl.split('/').last;
      final String filePath = '${downloadDir.path}/$fileName';

      final response = await http.get(Uri.parse(fileUrl));

      if (response.statusCode == 200) {
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        EasyLoading.dismiss();
        EasyLoading.showSuccess(
          'Downloaded to:\n$filePath',
          duration: Duration(seconds: 3),
        );
      } else {
        EasyLoading.dismiss();
        EasyLoading.showError(
          'Download failed: ${response.statusCode}',
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(
        'Error downloading file: $e',
        duration: Duration(seconds: 2),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _initializeAndLoadConversation() async {
    await _initializeSocketConnection();

    await Future.delayed(Duration(milliseconds: 500));

    if (arguments != null) {
      if (arguments is Map) {
        final chatItem = arguments['chatItem'];
        final recipientId = arguments['recipientId'];
        final isNewConversation = arguments['isNewConversation'] ?? false;

        if (isNewConversation && recipientId != null) {
          controller.initNewConversation(
            recipientId: recipientId,
            recipientParticipant: chatItem?.participant,
          );

          await _maybeSendInitialServiceRequest(recipientId.toString());
        } else if (chatItem?.chatId != null) {
          await controller.initConversationFromAPI(
            conversationId: chatItem.chatId,
          );

          if (recipientId != null) {
            await _maybeSendInitialServiceRequest(recipientId.toString());
          }
        }
      } else {
        await controller.initConversationFromAPI(
          conversationId: arguments.chatId ?? '',
        );

        final legacyRecipientId = arguments?.participant?.id;
        if (legacyRecipientId != null) {
          await _maybeSendInitialServiceRequest(legacyRecipientId.toString());
        }
      }
    }
  }

  Future<void> _maybeSendInitialServiceRequest(String recipientId) async {
    if (_initialServiceRequestSent.value) return;
    if (arguments is! Map) return;

    final shouldSend = arguments['sendInitialServiceRequest'] == true;
    final serviceId = arguments['initialServiceId'];

    if (!shouldSend || serviceId == null) return;
    final sid = serviceId.toString().trim();
    if (sid.isEmpty) return;

    _initialServiceRequestSent.value = true;

    final prefHelper = Get.find<SharedPreferencesHelperController>();
    final userId = await prefHelper.getUserId();
    if (userId != null && userId.isNotEmpty) {
      controller.initUserId(userId);
    }

    await Future.delayed(Duration(milliseconds: 300));

    final serviceRequestId = (arguments['serviceRequestId'] as String?)?.trim();

    controller.sendMessage(
      recipientId: recipientId,
      content: '',
      serviceId: sid,
      serviceRequestId: serviceRequestId?.isNotEmpty == true
          ? serviceRequestId
          : null,
    );

    await Future.delayed(Duration(milliseconds: 2000));

    if (controller.messages.isNotEmpty) {
      final lastMsg = controller.messages.last;
      if (lastMsg.conversationId.isNotEmpty && lastMsg.serviceId != null) {
        await controller.initConversationFromAPI(
          conversationId: lastMsg.conversationId,
          force: true,
        );
        await controller.fetchallchatMethod();
      }
    }
  }

  Future<void> _initializeSocketConnection() async {
    try {
      await controller.initializeSocketConnection();
    } catch (e) {
      // Socket initialization error handled in controller
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    _initializeAndLoadConversation();

    ever(controller.messages, (_) {
      _scrollToBottom();
    });

    // Get participant info from arguments
    dynamic chatParticipant;
    String recipientId = '';

    if (arguments is Map) {
      chatParticipant = arguments['chatItem']?.participant;
      recipientId = arguments['recipientId'] ?? '';
    } else {
      chatParticipant = arguments?.participant;
      recipientId = chatParticipant?.id ?? '';
    }

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          chatParticipant?.profilePhoto ?? '',
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chatParticipant?.fullName ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Active now',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      Spacer(),
                      // GestureDetector(
                      //   onTap: controller.toggleSidebar,
                      //   child: Icon(Icons.more_vert, color: Colors.white),
                      // ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'You started a chat with ${chatParticipant?.fullName ?? ''}',
                      style: getTextStyle(
                        fontsize: 12,
                        fontweight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  return controller.messages.isEmpty
                      ? Center(
                          child: Text(
                            'No messages yet\nSend a message to start the conversation',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          itemCount: controller.messages.length,
                          itemBuilder: (context, index) {
                            final msgItem = controller.messages[index];
                            final isMine = controller.isMyMessage(msgItem);

                            return Align(
                              alignment: isMine
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: isMine
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  // Service info card (if message has service)
                                  if (msgItem.serviceId != null &&
                                      msgItem.service != null)
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            0.75,
                                      ),
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 8),
                                        padding: EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[900],
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[700]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Title with service name and price
                                            Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '${msgItem.service!.serviceName} - \$${msgItem.service!.price}',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),

                                                if (msgItem.service!.serviceType == 'SOCIAL_POST' &&
                                                    (msgItem.serviceRequest?.uploadedFileUrl.isNotEmpty ?? false))
                                                  GestureDetector(
                                                    onTap: () {
                                                      final urls = msgItem
                                                          .serviceRequest!
                                                          .uploadedFileUrl
                                                          .join('\n');
                                                      SharePlus.instance.share(
                                                        ShareParams(
                                                          text: urls,
                                                          subject: msgItem.service!.serviceName,
                                                        ),
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.share,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  )
                                                else
                                                  SizedBox.shrink(),
                                              ],
                                            ),
                                            SizedBox(height: 12),
                                            // Delivery date
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  color: Colors.white70,
                                                  size: 14,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'Date: ${_formatDateFromDateTime(msgItem.createdAt)}',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Service request extra details
                                            if (msgItem
                                                    .serviceRequest
                                                    ?.hasExtraDetails ==
                                                true) ...[
                                              SizedBox(height: 10),
                                              Divider(
                                                color: Colors.white12,
                                                height: 1,
                                              ),
                                              SizedBox(height: 10),

                                              // Caption / Instructions
                                              if (msgItem
                                                      .serviceRequest!
                                                      .captionOrInstructions
                                                      ?.isNotEmpty ==
                                                  true)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: 8,
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Icon(
                                                        Icons.notes,
                                                        color: Colors.white54,
                                                        size: 14,
                                                      ),
                                                      SizedBox(width: 6),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Instructions',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white38,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            SizedBox(height: 2),
                                                            Text(
                                                              msgItem
                                                                  .serviceRequest!
                                                                  .captionOrInstructions!,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white70,
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
                                              if (msgItem
                                                      .serviceRequest!
                                                      .specialNotes
                                                      ?.isNotEmpty ==
                                                  true)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: 8,
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .sticky_note_2_outlined,
                                                        color: Colors.white54,
                                                        size: 14,
                                                      ),
                                                      SizedBox(width: 6),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Special Notes',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white38,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            SizedBox(height: 2),
                                                            Text(
                                                              msgItem
                                                                  .serviceRequest!
                                                                  .specialNotes!,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white70,
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
                                              if (msgItem
                                                      .serviceRequest!
                                                      .promotionDate
                                                      ?.isNotEmpty ==
                                                  true)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: 8,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.event,
                                                        color: Colors.white54,
                                                        size: 14,
                                                      ),
                                                      SizedBox(width: 6),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Promotion Date',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white38,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            SizedBox(height: 2),
                                                            Text(
                                                              msgItem
                                                                  .serviceRequest!
                                                                  .promotionDate!,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white70,
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
                                              if (msgItem
                                                  .serviceRequest!
                                                  .uploadedFileUrl
                                                  .isNotEmpty)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: 8,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.attach_file,
                                                            color:
                                                                Colors.white54,
                                                            size: 14,
                                                          ),
                                                          SizedBox(width: 6),
                                                          Text(
                                                            'Attachments',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white38,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 6),
                                                      Wrap(
                                                        spacing: 6,
                                                        runSpacing: 4,
                                                        children: msgItem.serviceRequest!.uploadedFileUrl.map((
                                                          url,
                                                        ) {
                                                          final name = url
                                                              .split('/')
                                                              .last;
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                _downloadFile(
                                                                  url,
                                                                ),
                                                            child: Container(
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical: 4,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .grey[700],
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      6,
                                                                    ),
                                                              ),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .download,
                                                                    color: Colors
                                                                        .white70,
                                                                    size: 12,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 4,
                                                                  ),
                                                                  Text(
                                                                    name.length >
                                                                            18
                                                                        ? '${name.substring(0, 15)}...'
                                                                        : name,
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .white70,
                                                                      fontSize:
                                                                          11,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],

                                            SizedBox(height: 12),
                                            // Pay Now / Paid button logic:
                                            // - For custom services: only recipient (not mine) should pay
                                            // - For regular services: only sender (me) should pay
                                            if (msgItem.service!.isCustom ==
                                                    true
                                                ? !isMine // Custom: show to recipient only
                                                : isMine) // Regular: show to sender only
                                              SizedBox(
                                                width: double.infinity,
                                                child:
                                                    msgItem
                                                            .serviceRequest
                                                            ?.isPaid ==
                                                        true
                                                    ? Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 10,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Colors.green[700],
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          'Paid',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      )
                                                    : ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              AppColors
                                                                  .redColor,
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                vertical: 10,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  6,
                                                                ),
                                                          ),
                                                        ),
                                                        onPressed: () async {
                                                          final result =
                                                              await Get.to(
                                                                () =>
                                                                    PaymentPage(),
                                                                arguments:
                                                                    msgItem,
                                                              );
                                                          if (result == true) {
                                                            controller
                                                                .markMessageAsPaid(
                                                                  msgItem.id,
                                                                );
                                                          }
                                                        },
                                                        child: Text(
                                                          'Pay Now',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  // Regular message - only show if content is not empty
                                  if (msgItem.content.trim().isNotEmpty)
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isMine
                                            ? AppColors.redColor
                                            : Colors.grey[800],
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                          bottomLeft: isMine
                                              ? Radius.circular(20)
                                              : Radius.circular(0),
                                          bottomRight: isMine
                                              ? Radius.circular(0)
                                              : Radius.circular(20),
                                        ),
                                      ),
                                      child: Text(
                                        msgItem.content,
                                        style: TextStyle(
                                          color: isMine
                                              ? Colors.white
                                              : Colors.white70,
                                        ),
                                      ),
                                    ),
                                  // Files display
                                  if (msgItem.files.isNotEmpty)
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Attachments (${msgItem.files.length})',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: msgItem.files.map((file) {
                                              final fileName = file
                                                  .split('/')
                                                  .last;
                                              return GestureDetector(
                                                onTap: () =>
                                                    _downloadFile(file),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[700],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.download,
                                                        color: Colors.white70,
                                                        size: 14,
                                                      ),
                                                      SizedBox(width: 6),
                                                      Flexible(
                                                        child: Text(
                                                          fileName.length > 20
                                                              ? '${fileName.substring(0, 17)}...'
                                                              : fileName,
                                                          style: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontSize: 11,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                }),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  children: [
                    // Selected files preview
                    Obx(() {
                      if (selectedFiles.isEmpty) {
                        return SizedBox.shrink();
                      }
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: selectedFiles.length,
                            itemBuilder: (context, index) {
                              final fileName = selectedFiles[index]
                                  .split('/')
                                  .last;
                              return Container(
                                margin: EdgeInsets.only(right: 8),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.redColor,
                                    width: 1,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image,
                                          color: Colors.white70,
                                          size: 24,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          fileName.length > 15
                                              ? '${fileName.substring(0, 12)}...'
                                              : fileName,
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          selectedFiles.removeAt(index);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.redColor,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: EdgeInsets.all(2),
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),
                    // Message input row
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showAddServiceSheet(
                              context,
                              addCustomServiceController,
                              recipientId: recipientId,
                            );
                          },

                          child: Icon(
                            Icons.file_copy_sharp,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),

                        GestureDetector(
                          onTap: _pickFile,
                          child: Image.asset(
                            Iconpath.cekol,
                            height: 20,
                            width: 20,
                          ),
                        ),
                        SizedBox(width: 10),

                        Expanded(
                          child: TextField(
                            controller: controller.messageController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              hintStyle: TextStyle(color: Colors.white38),
                              filled: true,
                              fillColor: Colors.grey[900],
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.white38),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white38),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Image.asset(
                            Iconpath.send,
                            height: 20,
                            width: 20,
                          ),
                          onPressed: () {
                            controller.sendMessage(
                              recipientId: recipientId,
                              content: controller.messageController.text,
                              files: selectedFiles.isNotEmpty
                                  ? selectedFiles.toList()
                                  : null,
                            );
                            controller.messageController.clear();
                            selectedFiles.clear();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }
}

void showAddServiceSheet(
  BuildContext context,
  AddCustomServiceController controller, {
  required String recipientId,
}) {
  Get.bottomSheet(
    StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomServiceFormWidget(
                controller,
                // onChanged: (_) => checkFields()
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (Get.arguments is Map) {
                          Get.arguments['sendInitialServiceRequest'] = false;
                          Get.arguments['initialServiceId'] = null;
                        }

                        final created = await controller.saveService();

                        if (created != null) {
                          final dynamic maybeId =
                              created['id'] ??
                              created['_id'] ??
                              created['serviceId'] ??
                              (created['service'] is Map
                                  ? created['service']['id']
                                  : null);

                          final serviceIdStr = maybeId?.toString();

                          if (recipientId.isNotEmpty &&
                              serviceIdStr != null &&
                              serviceIdStr.isNotEmpty) {
                            try {
                              final msgCtrl = Get.find<MessagesController>();
                              msgCtrl.sendMessage(
                                recipientId: recipientId,
                                content: '',
                                serviceId: serviceIdStr,
                                files: null,
                              );
                              Get.back();
                              Get.snackbar('Success', 'Service sent');
                            } catch (e) {
                              Get.back();
                              Get.snackbar('Error', 'Failed to send service');
                            }
                          } else {
                            Get.back();
                            Get.snackbar(
                              'Info',
                              'Service creation issue. Please try again.',
                            );
                          }
                        } else {
                          Get.back();
                        }
                      },

                      // onPressed:
                      //     //  controller.isSaveEnabled.value
                      //     () async {
                      //       await controller.saveService();
                      //       Get.back();
                      //     },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Send"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
    isScrollControlled: true,
  );
}

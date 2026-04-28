// ignore_for_file: avoid_print, must_be_immutable, unused_field, prefer_final_fields

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/constants/iconpath.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/features/home/request_service/controller/request_service_controller.dart';
import 'package:jconnect/features/messages/controller/custom_service_controller.dart';
import 'package:jconnect/features/messages/controller/messages_controller.dart';
import 'package:jconnect/features/messages/model/chat_conversation_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:jconnect/features/messages/widget/addcustomwidgets.dart';
import 'package:jconnect/features/payment/payment_screen.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jconnect/core/endpoint.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio/just_audio.dart';

class ChatDetailsScreen extends StatelessWidget {
  ChatDetailsScreen({super.key});

  late final ScrollController _scrollController = ScrollController();
  late final ImagePicker _imagePicker = ImagePicker();
  late final RxList<String> selectedFiles = <String>[].obs;
  late final RxBool _initialServiceRequestSent = false.obs;
  final RequestServiceController requestServiceController = Get.put(
    RequestServiceController(),
  );

  final addCustomServiceController = Get.put(AddCustomServiceController());
  late final controller = Get.find<MessagesController>();
  late final dynamic arguments = Get.arguments;
  Timer? _autoRefreshTimer;
  bool _isOnScreen = true;

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

  Future<void> _acceptServiceRequest(String serviceRequestId) async {
    try {
      EasyLoading.show(
        status: 'Accepting...',
        maskType: EasyLoadingMaskType.black,
      );

      final prefHelper = Get.find<SharedPreferencesHelperController>();
      final token = await prefHelper.getAccessRowToken();

      final response = await http.patch(
        Uri.parse(Endpoint.acceptServiceRequest(serviceRequestId)),
        headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
      );

      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.showSuccess(
          'Service request accepted',
          duration: const Duration(seconds: 2),
        );
        await _refreshConversation();
      } else {
        EasyLoading.showError(
          'Failed to accept: ${response.statusCode}',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: $e', duration: const Duration(seconds: 2));
    }
  }

  Future<void> _declineServiceRequest(String serviceRequestId) async {
    try {
      EasyLoading.show(
        status: 'Declining...',
        maskType: EasyLoadingMaskType.black,
      );

      final prefHelper = Get.find<SharedPreferencesHelperController>();
      final token = await prefHelper.getAccessRowToken();

      final response = await http.patch(
        Uri.parse(Endpoint.declineServiceRequest(serviceRequestId)),
        headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
      );

      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.showSuccess(
          'Service request declined',
          duration: const Duration(seconds: 2),
        );
        await _refreshConversation();
      } else {
        EasyLoading.showError(
          'Failed to decline: ${response.statusCode}',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: $e', duration: const Duration(seconds: 2));
    }
  }

  /// Builds the file action buttons for receiver/seller based on accept/decline state
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
          // Accept button - only show if pending (not accepted, not declined)
          if (isPending)
            GestureDetector(
              onTap: () {
                final srId = sr.id;
                if (srId != null && srId.isNotEmpty) {
                  _acceptServiceRequest(srId);
                }
              },
              child: Row(
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
          // Decline button - only show if pending (not accepted, not declined)
          if (isPending)
            GestureDetector(
              onTap: () {
                final srId = sr.id;
                if (srId != null && srId.isNotEmpty) {
                  _declineServiceRequest(srId);
                }
              },
              child: Row(
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
          // Status indicator when already decided
          if (isAccepted)
            Row(
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
            Row(
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
          // View button - always available
          GestureDetector(
            onTap: () => _viewFile(context, url),
            child: Row(
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
          // Download button - only available if accepted
          if (isAccepted)
            GestureDetector(
              onTap: () => _downloadFile(url),
              child: Row(
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

  Future<void> _uploadReplacementFile(String serviceRequestId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'mp4', 'jpg', 'jpeg', 'png', 'gif', 'pdf', 'mov', 'avi', 'flv', 'wav', 'aac'],
      );
      if (result == null || result.files.single.path == null) return;

      final filePath = result.files.single.path!;

      EasyLoading.show(
        status: 'Uploading to S3...',
        maskType: EasyLoadingMaskType.black,
      );

      // ── Step 1: upload file to S3 via the generic file-upload endpoint ──
      final uploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(Endpoint.fileUpload),
      );
      uploadRequest.files.add(
        await http.MultipartFile.fromPath('file', filePath),
      );

      final uploadResponse = await uploadRequest.send();
      final uploadBody = await uploadResponse.stream.bytesToString();

      if (uploadResponse.statusCode != 200 &&
          uploadResponse.statusCode != 201) {
        EasyLoading.dismiss();
        EasyLoading.showError(
          'Upload failed: ${uploadResponse.statusCode}\n$uploadBody',
          duration: const Duration(seconds: 3),
        );
        return;
      }

      final fileUrl =
          (jsonDecode(uploadBody) as Map<String, dynamic>)['file'] as String?;
      if (fileUrl == null || fileUrl.isEmpty) {
        EasyLoading.dismiss();
        EasyLoading.showError(
          'Could not get file URL from server',
          duration: const Duration(seconds: 2),
        );
        return;
      }

      // ── Step 2: PATCH service request with the S3 URL as JSON ────────────
      EasyLoading.show(
        status: 'Saving...',
        maskType: EasyLoadingMaskType.black,
      );

      final prefHelper = Get.find<SharedPreferencesHelperController>();
      final token = await prefHelper.getAccessRowToken();

      final patchResponse = await http.patch(
        Uri.parse(Endpoint.uploadServiceRequestFiles(serviceRequestId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'uploadedFileUrl': [fileUrl],
        }),
      );

      EasyLoading.dismiss();

      if (patchResponse.statusCode == 200 || patchResponse.statusCode == 201) {
        EasyLoading.showSuccess(
          'File uploaded successfully',
          duration: const Duration(seconds: 2),
        );
        await _refreshConversation();
      } else {
        EasyLoading.showError(
          'Save failed: ${patchResponse.statusCode}\n${patchResponse.body}',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e, stackTrace) {
      EasyLoading.dismiss();
      print('Error uploading file: $e');
      print('Stack trace: $stackTrace');
      EasyLoading.showError(
        'Error uploading file: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _refreshConversation() async {
    String? conversationId;

    // Try to get conversation ID from messages
    if (controller.messages.isNotEmpty) {
      conversationId = controller.messages.first.conversationId;
    }

    // Fallback to arguments
    if ((conversationId == null || conversationId.isEmpty) &&
        arguments != null) {
      if (arguments is Map) {
        conversationId = arguments['chatItem']?.chatId;
      } else {
        conversationId = arguments?.chatId;
      }
    }

    if (conversationId != null && conversationId.isNotEmpty) {
      await controller.initConversationFromAPI(
        conversationId: conversationId,
        force: true,
      );
    }
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

  void _viewFile(BuildContext context, String url) {
    final ext = url.split('.').last.split('?').first.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
    final isVideo = ['mp4', 'mov', 'avi', 'flv', 'mkv', 'webm'].contains(ext);
    final isAudio = ['mp3', 'wav', 'aac', 'm4a', 'flac'].contains(ext);
    final isPdf = ext == 'pdf';

    if (isImage) {
      // Show image preview with PhotoView
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Scaffold(
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
              imageProvider: NetworkImage(url),
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
        ),
      );
    } else if (isVideo) {
      // Show video player
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _VideoViewerScreen(videoUrl: url),
        ),
      );
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _AudioPlayerScreen(audioUrl: url),
      ),
    );
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
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
              Navigator.pop(dialogContext);
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

      if (response.statusCode == 200 || response.statusCode == 201) {
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

  Future<void> _shareFiles(List<String> urls, String subject) async {
    try {
      EasyLoading.show(
        status: 'Preparing files...',
        maskType: EasyLoadingMaskType.black,
      );

      final tempDir = await getTemporaryDirectory();
      final List<XFile> xFiles = [];

      for (final url in urls) {
        final fileName = url.split('/').last;
        final filePath = '${tempDir.path}/$fileName';
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          xFiles.add(XFile(filePath));
        }
      }

      EasyLoading.dismiss();

      if (xFiles.isEmpty) {
        EasyLoading.showError('No files available to share');
        return;
      }

      await SharePlus.instance.share(
        ShareParams(files: xFiles, subject: subject),
      );
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Attachment not attached');
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
    // _startAutoRefresh();

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

  // void _startAutoRefresh() {
  //   _autoRefreshTimer?.cancel();
  //   _autoRefreshTimer = Timer.periodic(Duration(seconds: 10), (_) async {
  //     if (_isOnScreen) {
  //       await _refreshConversation();
  //     }
  //   });
  // }

  // void _stopAutoRefresh() {
  //   _isOnScreen = false;
  //   _autoRefreshTimer?.cancel();
  //   _autoRefreshTimer = null;
  // }

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
    String senderUsername = '';

    if (arguments is Map) {
      chatParticipant = arguments['chatItem']?.participant;
      recipientId = arguments['recipientId'] ?? '';
      senderUsername = arguments['senderUsername'] ?? '';
    } else {
      chatParticipant = arguments?.participant;
      recipientId = chatParticipant?.id ?? '';
      senderUsername = arguments?.senderUsername ?? '';
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
                        onTap: () {
                          //    _stopAutoRefresh();
                          Get.back();
                        },
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
                            senderUsername.isNotEmpty
                                ? senderUsername
                                : (chatParticipant?.username ?? ''),
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
                      'You started a chat with ${senderUsername.isNotEmpty ? senderUsername : (chatParticipant?.username ?? '')}',
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
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${msgItem.service!.serviceName} - \$${msgItem.service!.price}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 4,),

                                                if (msgItem
                                                            .service!
                                                            .serviceType ==
                                                        'SOCIAL_POST' &&
                                                    (msgItem
                                                            .serviceRequest
                                                            ?.uploadedFileUrl
                                                            .isNotEmpty ??
                                                        false))
                                                  GestureDetector(
                                                    onTap: () => _shareFiles(
                                                      msgItem
                                                          .serviceRequest!
                                                          .uploadedFileUrl,
                                                      msgItem
                                                          .service!
                                                          .serviceName,
                                                    ),
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
                                                              () {
                                                                try {
                                                                  final dt = DateTime.parse(
                                                                    msgItem
                                                                        .serviceRequest!
                                                                        .promotionDate!,
                                                                  ).toLocal();
                                                                  return DateFormat(
                                                                    "MMM d, yyyy · h:mm a",
                                                                  ).format(dt);
                                                                } catch (_) {
                                                                  return msgItem
                                                                      .serviceRequest!
                                                                      .promotionDate!;
                                                                }
                                                              }(),
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
                                                  .where(
                                                    (u) =>
                                                        u.trim().isNotEmpty &&
                                                        u.trim().toLowerCase() !=
                                                            'no file',
                                                  )
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
                                                        spacing: 8,
                                                        runSpacing: 8,
                                                        children: msgItem
                                                            .serviceRequest!
                                                            .uploadedFileUrl
                                                            .where(
                                                              (u) =>
                                                                  u
                                                                      .trim()
                                                                      .isNotEmpty &&
                                                                  u.trim().toLowerCase() !=
                                                                      'no file',
                                                            )
                                                            .map((url) {
                                                              final name = url
                                                                  .split('/')
                                                                  .last;
                                                              final displayName =
                                                                  name.length >
                                                                      18
                                                                  ? '${name.substring(0, 15)}...'
                                                                  : name;
                                                              return Container(
                                                                width: double
                                                                    .infinity,
                                                                decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .grey[800],
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                  border: Border.all(
                                                                    color: Colors
                                                                        .white12,
                                                                    width: 0.8,
                                                                  ),
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          EdgeInsets.fromLTRB(
                                                                            8,
                                                                            8,
                                                                            8,
                                                                            6,
                                                                          ),
                                                                      child: Row(
                                                                        children: [
                                                                          Icon(
                                                                            Icons.insert_drive_file_outlined,
                                                                            color:
                                                                                Colors.white54,
                                                                            size:
                                                                                14,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                4,
                                                                          ),
                                                                          Expanded(
                                                                            child: Text(
                                                                              displayName,
                                                                              style: TextStyle(
                                                                                color: Colors.white70,
                                                                                fontSize: 11,
                                                                              ),
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Divider(
                                                                      color: Colors
                                                                          .white12,
                                                                      height: 1,
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            4,
                                                                        vertical:
                                                                            4,
                                                                      ),
                                                                      child:
                                                                          isMine
                                                                          // Sender/Buyer view
                                                                          ? (msgItem.serviceRequest!.isDeclined ==
                                                                                    true
                                                                                ? Center(
                                                                                    child: GestureDetector(
                                                                                      onTap: () {
                                                                                        final srId = msgItem.serviceRequest!.id;
                                                                                        if (srId !=
                                                                                                null &&
                                                                                            srId.isNotEmpty) {
                                                                                          _uploadReplacementFile(
                                                                                            srId,
                                                                                          );
                                                                                        }
                                                                                      },
                                                                                      child: Column(
                                                                                        children: [
                                                                                          Icon(
                                                                                            Icons.upload_file,
                                                                                            color: Colors.orangeAccent,
                                                                                            size: 18,
                                                                                          ),
                                                                                          SizedBox(
                                                                                            height: 3,
                                                                                          ),
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
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                    children: [
                                                                                      GestureDetector(
                                                                                        onTap: () => _viewFile(
                                                                                          context,
                                                                                          url,
                                                                                        ),
                                                                                        child: Row(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: [
                                                                                            Icon(
                                                                                              Icons.visibility_outlined,
                                                                                              color: Colors.blueAccent,
                                                                                              size: 18,
                                                                                            ),
                                                                                            SizedBox(
                                                                                              width: 3,
                                                                                            ),
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
                                                                                      SizedBox(
                                                                                        width: 35,
                                                                                      ),
                                                                                      GestureDetector(
                                                                                        onTap: () => _downloadFile(
                                                                                          url,
                                                                                        ),
                                                                                        child: Row(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: [
                                                                                            Icon(
                                                                                              Icons.download_outlined,
                                                                                              color: Colors.greenAccent,
                                                                                              size: 18,
                                                                                            ),
                                                                                            SizedBox(
                                                                                              width: 3,
                                                                                            ),
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
                                                                          // Receiver/Seller view - conditional based on accept/decline state
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
                              final reqCtrl =
                                  Get.find<RequestServiceController>();
                              final price =
                                  (created['price'] ?? created['amount'] ?? 0)
                                      .toDouble();
                              final srData = await reqCtrl.submitServiceRequest(
                                serviceId: serviceIdStr,
                                price: price,
                              );
                              final serviceRequestId = srData?['id']
                                  ?.toString();
                              print(
                                '🔥 [CUSTOM SERVICE] serviceRequestId: $serviceRequestId',
                              );

                              final messagesController =
                                  Get.find<MessagesController>();

                              // Apply service request info to cache so
                              // isPaid (and other fields) are available in
                              // the chat message card, even if the backend
                              // doesn't embed serviceRequest in the send-
                              // message response for custom services.
                              if (srData != null) {
                                final srId = srData['id']?.toString() ?? '';
                                if (srId.isNotEmpty) {
                                  messagesController.applyServiceRequest(
                                    srId,
                                    ServiceRequestInfo.fromJson(srData),
                                  );
                                }
                              }

                              messagesController.sendMessage(
                                recipientId: recipientId,
                                content: '',
                                serviceId: serviceIdStr,
                                serviceRequestId:
                                    serviceRequestId?.isNotEmpty == true
                                    ? serviceRequestId
                                    : null,
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

/// Video player screen for viewing video files
class _VideoViewerScreen extends StatefulWidget {
  final String videoUrl;

  const _VideoViewerScreen({required this.videoUrl});

  @override
  State<_VideoViewerScreen> createState() => _VideoViewerScreenState();
}

class _VideoViewerScreenState extends State<_VideoViewerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Watch Video',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading video: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          });
                        },
                        backgroundColor: Colors.blueAccent,
                        child: Icon(
                          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Colors.blueAccent,
                            bufferedColor: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        backgroundColor: Colors.redAccent,
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
        },
      ),
    );
  }
}

/// Audio player screen for viewing audio files with direct playback
class _AudioPlayerScreen extends StatefulWidget {
  final String audioUrl;

  const _AudioPlayerScreen({required this.audioUrl});

  @override
  State<_AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<_AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;
  late Future<void> _initializeAudioFuture;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeAudioFuture = _audioPlayer.setUrl(widget.audioUrl);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours == 0) {
      return '$minutes:$seconds';
    } else {
      return '$hours:$minutes:$seconds';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.audioUrl.split('/').last.split('?').first;
    
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Audio Player',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeAudioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading audio: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Audio visualizer / Icon
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.blueAccent, Colors.cyan],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // File name
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        fileName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Progress and time info
                    StreamBuilder<Duration>(
                      stream: _audioPlayer.positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        final duration = _audioPlayer.duration ?? Duration.zero;

                        return Column(
                          children: [
                            // Progress slider
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 14,
                                  ),
                                ),
                                child: Slider(
                                  value: position.inMilliseconds.toDouble(),
                                  max: duration.inMilliseconds.toDouble(),
                                  activeColor: Colors.blueAccent,
                                  inactiveColor: Colors.white12,
                                  onChanged: (value) {
                                    _audioPlayer.seek(
                                      Duration(milliseconds: value.toInt()),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Time display
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(position),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(duration),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Play/Pause button
                    StreamBuilder<PlayerState>(
                      stream: _audioPlayer.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final isPlaying = playerState?.playing ?? false;

                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.blueAccent, Colors.cyan],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.4),
                                blurRadius: 16,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                if (isPlaying) {
                                  await _audioPlayer.pause();
                                } else {
                                  await _audioPlayer.play();
                                }
                              },
                              borderRadius: BorderRadius.circular(40),
                              child: Center(
                                child: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Speed control button
                    Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                _showSpeedDialog();
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: const Center(
                                child: Icon(
                                  Icons.speed,
                                  color: Colors.blueAccent,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Speed',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          }
        },
      ),
    );
  }

  void _showSpeedDialog() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Playback Speed',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: speeds
              .map(
                (speed) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    onTap: () {
                      _audioPlayer.setSpeed(speed);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${speed}x',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          if (speed == 1.0)
                            const Icon(
                              Icons.check,
                              color: Colors.blueAccent,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

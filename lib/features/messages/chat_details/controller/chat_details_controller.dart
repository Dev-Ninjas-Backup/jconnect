import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/endpoint.dart';
import 'package:jconnect/core/service/local_service/shared_preferences_helper.dart';
import 'package:jconnect/core/utils/image_helper.dart';
import 'package:jconnect/features/home/request_service/controller/request_service_controller.dart';
import 'package:jconnect/features/messages/chat_details/widgets/audio_player_screen.dart';
import 'package:jconnect/features/messages/chat_details/widgets/video_viewer_screen.dart';
import 'package:jconnect/features/messages/controller/custom_service_controller.dart';
import 'package:jconnect/features/messages/controller/messages_controller.dart';

class ChatDetailsController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final ImagePicker imagePicker = ImagePicker();
  final RxList<String> selectedFiles = <String>[].obs;
  final RxBool initialServiceRequestSent = false.obs;

  late final RequestServiceController requestServiceController;
  late final AddCustomServiceController addCustomServiceController;
  late final MessagesController messagesController;

  final AudioRecorder _audioRecorder = AudioRecorder();
  final RxBool isRecording = false.obs;
  final RxInt recordDuration = 0.obs;
  Timer? recordTimer;

  dynamic arguments;

  @override
  void onInit() {
    super.onInit();
    requestServiceController = Get.isRegistered<RequestServiceController>()
        ? Get.find<RequestServiceController>()
        : Get.put(RequestServiceController());

    addCustomServiceController = Get.isRegistered<AddCustomServiceController>()
        ? Get.find<AddCustomServiceController>()
        : Get.put(AddCustomServiceController());

    messagesController = Get.find<MessagesController>();
    arguments = Get.arguments;

    initializeAndLoadConversation();
  }

  @override
  void onClose() {
    recordTimer?.cancel();
    _audioRecorder.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void initializeAndLoadConversation() async {
    await initializeSocketConnection();

    await Future.delayed(const Duration(milliseconds: 500));

    if (arguments != null) {
      if (arguments is Map) {
        final chatItem = arguments['chatItem'];
        final recipientId = arguments['recipientId'];
        final isNewConversation = arguments['isNewConversation'] ?? false;

        if (isNewConversation && recipientId != null) {
          messagesController.initNewConversation(
            recipientId: recipientId,
            recipientParticipant: chatItem?.participant,
          );

          await maybeSendInitialServiceRequest(recipientId.toString());
        } else if (chatItem?.chatId != null) {
          await messagesController.initConversationFromAPI(
            conversationId: chatItem.chatId,
          );

          if (recipientId != null) {
            await maybeSendInitialServiceRequest(recipientId.toString());
          }
        }
      } else {
        await messagesController.initConversationFromAPI(
          conversationId: arguments.chatId ?? '',
        );

        final legacyRecipientId = arguments?.participant?.id;
        if (legacyRecipientId != null) {
          await maybeSendInitialServiceRequest(legacyRecipientId.toString());
        }
      }
    }
  }

  Future<void> initializeSocketConnection() async {
    try {
      await messagesController.initializeSocketConnection();
    } catch (e) {
      // Socket initialization error handled in controller
    }
  }

  Future<void> maybeSendInitialServiceRequest(String recipientId) async {
    if (initialServiceRequestSent.value) return;
    if (arguments is! Map) return;

    final shouldSend = arguments['sendInitialServiceRequest'] == true;
    final serviceId = arguments['initialServiceId'];

    if (!shouldSend || serviceId == null) return;
    final sid = serviceId.toString().trim();
    if (sid.isEmpty) return;

    initialServiceRequestSent.value = true;

    final prefHelper = Get.find<SharedPreferencesHelperController>();
    final userId = await prefHelper.getUserId();
    if (userId != null && userId.isNotEmpty) {
      messagesController.initUserId(userId);
    }

    await Future.delayed(const Duration(milliseconds: 300));

    final serviceRequestId =
        (arguments['serviceRequestId'] as String?)?.trim();

    messagesController.sendMessage(
      recipientId: recipientId,
      content: '',
      serviceId: sid,
      serviceRequestId: serviceRequestId?.isNotEmpty == true
          ? serviceRequestId
          : null,
    );

    await Future.delayed(const Duration(milliseconds: 2000));

    if (messagesController.messages.isNotEmpty) {
      final lastMsg = messagesController.messages.last;
      if (lastMsg.conversationId.isNotEmpty && lastMsg.serviceId != null) {
        await messagesController.initConversationFromAPI(
          conversationId: lastMsg.conversationId,
          force: true,
        );
        await messagesController.fetchallchatMethod();
      }
    }
  }

  Future<void> acceptServiceRequest(String serviceRequestId) async {
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
        await refreshConversation();
      } else {
        String errorMessage = 'Failed to accept: ${response.statusCode}';
        try {
          final bodyJson = jsonDecode(response.body);
          if (bodyJson['message'] != null) {
            errorMessage = bodyJson['message'];
          }
        } catch (_) {}

        EasyLoading.showError(
          errorMessage,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: $e', duration: const Duration(seconds: 2));
    }
  }

  Future<void> declineServiceRequest(String serviceRequestId) async {
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
        await refreshConversation();
      } else {
        String errorMessage = 'Failed to decline: ${response.statusCode}';
        try {
          final bodyJson = jsonDecode(response.body);
          if (bodyJson['message'] != null) {
            errorMessage = bodyJson['message'];
          }
        } catch (_) {}

        EasyLoading.showError(
          errorMessage,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Error: $e', duration: const Duration(seconds: 2));
    }
  }

  Future<void> uploadReplacementFile(
    String serviceRequestId, {
    String? predefinedFilePath,
  }) async {
    try {
      String filePath;

      if (predefinedFilePath != null) {
        filePath = predefinedFilePath;
      } else {
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
        filePath = result.files.single.path!;
      }

      EasyLoading.show(
        status: 'Uploading to S3...',
        maskType: EasyLoadingMaskType.black,
      );

      // Step 1: upload file to S3
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

      // Step 2: PATCH service request with S3 URL
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
        await refreshConversation();
      } else {
        EasyLoading.showError(
          'Save failed: ${patchResponse.statusCode}\n${patchResponse.body}',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e, stackTrace) {
      EasyLoading.dismiss();
      debugPrint('Error uploading file: $e');
      debugPrint('Stack trace: $stackTrace');
      EasyLoading.showError(
        'Error uploading file: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }

  void showUploadOptions(BuildContext context, String srId) {
    Get.bottomSheet(
      Material(
        color: AppColors.backGroundColor,
        child: SafeArea(
          child: Wrap(
            children: [
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(Icons.camera_alt, color: AppColors.primaryTextColor),
                  title: Text('Take Photo', style: getTextStyle(color: AppColors.primaryTextColor)),
                  onTap: () async {
                    Get.back();
                    final picked = await imagePicker.pickImage(source: ImageSource.camera);
                    if (picked != null) uploadReplacementFile(srId, predefinedFilePath: picked.path);
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(Icons.videocam, color: AppColors.primaryTextColor),
                  title: Text('Record Video', style: getTextStyle(color: AppColors.primaryTextColor)),
                  onTap: () async {
                    Get.back();
                    final picked = await imagePicker.pickVideo(source: ImageSource.camera);
                    if (picked != null) uploadReplacementFile(srId, predefinedFilePath: picked.path);
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(Icons.photo_library, color: AppColors.primaryTextColor),
                  title: Text('Choose File', style: getTextStyle(color: AppColors.primaryTextColor)),
                  onTap: () {
                    Get.back();
                    uploadReplacementFile(srId);
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(Icons.photo, size: 20, color: AppColors.primaryTextColor),
                  title: Text('Choose Photo', style: getTextStyle(color: AppColors.primaryTextColor)),
                  onTap: () async {
                    Get.back();
                    final picked = await imagePicker.pickImage(source: ImageSource.gallery);
                    if (picked != null) uploadReplacementFile(srId, predefinedFilePath: picked.path);
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(Icons.videocam, color: AppColors.primaryTextColor),
                  title: Text('Choose Video', style: getTextStyle(color: AppColors.primaryTextColor)),
                  onTap: () async {
                    Get.back();
                    final picked = await imagePicker.pickVideo(source: ImageSource.gallery);
                    if (picked != null) uploadReplacementFile(srId, predefinedFilePath: picked.path);
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(Icons.close, color: AppColors.primaryTextColor),
                  title: Text('Cancel', style: getTextStyle(color: AppColors.primaryTextColor)),
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

  Future<void> refreshConversation() async {
    String? conversationId;

    if (messagesController.messages.isNotEmpty) {
      conversationId = messagesController.messages.first.conversationId;
    }

    if ((conversationId == null || conversationId.isEmpty) &&
        arguments != null) {
      if (arguments is Map) {
        conversationId = arguments['chatItem']?.chatId;
      } else {
        conversationId = arguments?.chatId;
      }
    }

    if (conversationId != null && conversationId.isNotEmpty) {
      await messagesController.initConversationFromAPI(
        conversationId: conversationId,
        force: true,
      );
    }
  }

  Future<void> pickFile() async {
    try {
      final XFile? image = await imagePicker.pickImage(
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
              duration: const Duration(seconds: 1),
            );
          } else {
            EasyLoading.showError(
              'Failed to get file URL',
              duration: const Duration(seconds: 2),
            );
          }
        } else {
          EasyLoading.showError(
            'Upload failed: ${response.statusCode}',
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(
        'Error uploading file: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }

  String formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Future<void> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath,
        );

        recordDuration.value = 0;
        isRecording.value = true;
        recordTimer?.cancel();
        recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          recordDuration.value++;
        });
      } else {
        EasyLoading.showError('Microphone permission required');
      }
    } catch (e) {
      if (e.toString().contains('MissingPluginException')) {
        EasyLoading.showError(
            'Please stop & restart/rebuild the app to compile the new native recording plugin.');
      } else {
        EasyLoading.showError('Could not start recording: $e');
      }
    }
  }

  Future<void> cancelRecording() async {
    try {
      recordTimer?.cancel();
      final path = await _audioRecorder.stop();
      isRecording.value = false;
      recordDuration.value = 0;
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      isRecording.value = false;
    }
  }

  Future<void> stopAndSendVoice(String recipientId) async {
    try {
      recordTimer?.cancel();
      final path = await _audioRecorder.stop();
      isRecording.value = false;
      final durationSeconds = recordDuration.value;
      recordDuration.value = 0;

      if (path == null || path.isEmpty) {
        EasyLoading.showError('Failed to record audio');
        return;
      }

      final file = File(path);
      if (!await file.exists() || (await file.length()) == 0) {
        EasyLoading.showError('Recorded audio file is empty');
        return;
      }

      EasyLoading.show(
        status: 'Uploading voice message...',
        maskType: EasyLoadingMaskType.black,
      );

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Endpoint.fileUpload),
      );

      final multipartFile = await http.MultipartFile.fromPath('file', path);
      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      EasyLoading.dismiss();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
        final fileUrl = jsonResponse['file'];

        if (fileUrl != null) {
          messagesController.sendMessage(
            recipientId: recipientId,
            content: 'Voice Message (${formatDuration(durationSeconds)})',
            files: [fileUrl],
          );
          EasyLoading.showSuccess(
            'Voice message sent',
            duration: const Duration(seconds: 1),
          );
        } else {
          EasyLoading.showError('Failed to get uploaded audio URL');
        }
      } else {
        EasyLoading.showError('Voice upload failed: ${response.statusCode}');
      }
    } catch (e) {
      EasyLoading.dismiss();
      isRecording.value = false;
      EasyLoading.showError('Error sending voice message: $e');
    }
  }

  void viewFile(BuildContext context, String url) {
    final ext = url.split('.').last.split('?').first.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
    final isVideo = ['mp4', 'mov', 'avi', 'flv', 'mkv', 'webm'].contains(ext);
    final isAudio = ['mp3', 'wav', 'aac', 'm4a', 'flac'].contains(ext);
    final isPdf = ext == 'pdf';

    if (isImage) {
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
      Get.to(() => VideoViewerScreen(videoUrl: url));
    } else if (isAudio) {
      showAudioPlayerDialog(context, url);
    } else if (isPdf) {
      showPdfViewDialog(context, url);
    } else {
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
                downloadFile(url);
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

  void showAudioPlayerDialog(BuildContext context, String url) {
    Get.to(() => AudioPlayerScreen(audioUrl: url));
  }

  void showPdfViewDialog(BuildContext context, String url) {
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
                downloadFile(url);
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
              downloadFile(url);
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

  Future<void> downloadFile(String fileUrl) async {
    try {
      EasyLoading.show(
        status: 'Downloading...',
        maskType: EasyLoadingMaskType.black,
      );

      final response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode != 200 && response.statusCode != 201) {
        EasyLoading.dismiss();
        EasyLoading.showError(
          'Download failed: ${response.statusCode}',
          duration: const Duration(seconds: 2),
        );
        return;
      }

      final String fileName = fileUrl.split('/').last.split('?').first;
      final tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(response.bodyBytes);

      EasyLoading.dismiss();

      final fileSizeInMB = (response.bodyBytes.length / (1024 * 1024))
          .toStringAsFixed(2);
      debugPrint('✅ File downloaded successfully: $fileName ($fileSizeInMB MB)');

      EasyLoading.showSuccess(
        '📥 Tap to save to Files',
        duration: const Duration(seconds: 2),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      openShareSheet(tempFile, fileName);
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('❌ Download error: $e');
      EasyLoading.showError(
        'Error downloading: $e',
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> openShareSheet(File file, String fileName) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Downloaded file: $fileName',
        ),
      );

      debugPrint('📤 Share sheet result: $result');

      if (Platform.isIOS) {
        EasyLoading.showInfo(
          '✅ File available to save',
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      debugPrint('Share sheet error: $e');
    }
  }

  Future<void> shareFiles(List<String> urls, String subject) async {
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
      EasyLoading.showError('Error downloading file: $e');
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

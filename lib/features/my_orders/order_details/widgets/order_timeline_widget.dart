// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/features/my_orders/order_details/model/order_timeline_step.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';
import 'package:just_audio/just_audio.dart';

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

  bool _isImageFile(String url) {
    final ext = url.split('.').last.split('?').first.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
  }

  bool _isVideoFile(String url) {
    final ext = url.split('.').last.split('?').first.toLowerCase();
    return ['mp4', 'mov', 'avi', 'flv', 'mkv', 'webm'].contains(ext);
  }

  bool _isAudioFile(String url) {
    final ext = url.split('.').last.split('?').first.toLowerCase();
    return ['mp3', 'wav', 'aac', 'm4a', 'flac'].contains(ext);
  }

  bool _isPdfFile(String url) {
    final ext = url.split('.').last.split('?').first.toLowerCase();
    return ext == 'pdf';
  }

  Future<void> _downloadFile(String url) async {
    try {
      EasyLoading.show(status: 'Downloading...');
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
        EasyLoading.showSuccess('Downloaded to: $fileName');
      } else {
        EasyLoading.showError('Download failed');
      }
    } catch (e) {
      EasyLoading.showError('Error: $e');
    }
  }

  Future<void> _showAudioPlayerDialog(BuildContext context, String url) async {
    // Open a full-screen audio player for better UX
    Get.to(() => _AudioPlayerScreen(audioUrl: url));
  }

  Future<void> _showPdfViewDialog(BuildContext context, String url) async {
    final fileName = url.split('/').last.split('?').first;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backGroundColor,
        title: Row(
          children: [
            Icon(Icons.picture_as_pdf, color: AppColors.redColor),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: getTextStyle(
                  color: AppColors.primaryTextColor,
                  fontweight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'PDF document - open in browser or download',
          style: getTextStyle(color: AppColors.secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: getTextStyle(color: AppColors.redColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                } else {
                  _downloadFile(url);
                }
              } catch (e) {
                _downloadFile(url);
              }
            },
            child: Text(
              'Open',
              style: getTextStyle(color: AppColors.redColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _downloadFile(url);
            },
            child: Text(
              'Download',
              style: getTextStyle(color: AppColors.redColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _viewAttachment(BuildContext context) async {
    if (proofUrl.isEmpty) {
      EasyLoading.showError('No attachment available');
      return;
    }

    try {
      final url = proofUrl.last;

      if (_isImageFile(url)) {
        // Show image with PhotoView for zoom
        Get.to(() => Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.black,
                leading: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ),
              backgroundColor: Colors.black,
              body: PhotoView(
                imageProvider: NetworkImage(url),
                loadingBuilder: (context, event) => Center(
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.redColor),
                  ),
                ),
              ),
            ));
      } else if (_isVideoFile(url)) {
        Get.to(() => _VideoViewerScreen(videoUrl: url));
      } else if (_isAudioFile(url)) {
        _showAudioPlayerDialog(context, url);
      } else if (_isPdfFile(url)) {
        _showPdfViewDialog(context, url);
      } else {
        // Generic file viewer
        final fileName = url.split('/').last.split('?').first;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.backGroundColor,
            title: Row(
              children: [
                Icon(Icons.insert_drive_file, color: AppColors.redColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fileName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: getTextStyle(
                      color: AppColors.primaryTextColor,
                      fontweight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              'File attachment - tap Download to save',
              style: getTextStyle(color: AppColors.secondaryTextColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Close',
                  style: getTextStyle(color: AppColors.redColor),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  _downloadFile(url);
                },
                child: Text(
                  'Download',
                  style: getTextStyle(color: AppColors.redColor),
                ),
              ),
            ],
          ),
        );
      }
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
    try {
      final ext = url.split('.').last.split('?').first.toLowerCase();
      if (['jpg', 'jpeg', 'png', 'pdf', 'gif', 'mp4', 'webp', 'mp3', 'wav', 'aac', 'mov', 'avi', 'flv', 'mkv', 'webm', 'bmp', 'm4a', 'flac'].contains(ext)) {
        return ext;
      }
      return 'bin';
    } catch (_) {
      return 'bin';
    }
  }

  void _showReasonDialog(BuildContext context, String reason) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: AppColors.backGroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: Colors.grey.shade800, width: 1),
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: SingleChildScrollView(
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
                SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.redColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.redColor,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Proof Rejection Reason',
                        style: getTextStyle(
                          color: Colors.white,
                          fontsize: 16,
                          fontweight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.white54, size: 20),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.redColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.redColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    reason,
                    style: getTextStyle(
                      color: AppColors.primaryTextColor,
                      fontsize: 13,
                      fontweight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Close',
                      style: getTextStyle(
                        color: Colors.white,
                        fontsize: 14,
                        fontweight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
          return IntrinsicHeight(
            child: Row(
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
                        border: Border.all(
                          color: step.isCompleted
                              ? AppColors.redColor
                              : Colors.white24,
                          width: 2,
                        ),
                      ),
                      child: step.isCompleted
                          ? Icon(Icons.check, color: Colors.white, size: 12)
                          : null,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: (step.isCompleted &&
                                  index < timeline.length - 1 &&
                                  timeline[index + 1].isCompleted)
                              ? AppColors.redColor.withValues(alpha: 0.5)
                              : Colors.white24,
                          margin: EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 2, bottom: isLast ? 0 : 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              if (step.description != null &&
                                  step.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: GestureDetector(
                                    onTap: () => _showReasonDialog(
                                      context,
                                      step.description!,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.redColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColors.redColor.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                size: 14,
                                                color: AppColors.redColor,
                                              ),
                                              SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  'Reason: ${step.description}',
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: getTextStyle(
                                                    color: AppColors
                                                        .primaryTextColor,
                                                    fontsize: 11,
                                                    fontweight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                'View Reason',
                                                style: getTextStyle(
                                                  color: AppColors.redColor,
                                                  fontsize: 10,
                                                  fontweight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(width: 2),
                                              Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                color: AppColors.redColor,
                                                size: 9,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (proofUrl.isNotEmpty &&
                                  (isWaitingForProof ||
                                      step.title
                                          .toLowerCase()
                                          .contains('proof') ||
                                      (!timeline.any((s) => s.title
                                          .toLowerCase()
                                          .contains('proof')) &&
                                          index == 0)))
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.attach_file_rounded,
                                              size: 14,
                                              color: AppColors.redColor,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'Proof Attachment (${proofUrl.length})',
                                              style: getTextStyle(
                                                color:
                                                    AppColors.primaryTextColor,
                                                fontsize: 11,
                                                fontweight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () =>
                                                  _viewAttachment(context),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.redColor
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: AppColors.redColor
                                                        .withValues(
                                                      alpha: 0.4,
                                                    ),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .visibility_outlined,
                                                      size: 12,
                                                      color: AppColors.redColor,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'View',
                                                      style: getTextStyle(
                                                        color:
                                                            AppColors.redColor,
                                                        fontsize: 10,
                                                        fontweight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: _downloadAttachment,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white10,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: Colors.white24,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.download_rounded,
                                                      size: 12,
                                                      color: Colors.white70,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Download',
                                                      style: getTextStyle(
                                                        color: Colors.white,
                                                        fontsize: 10,
                                                        fontweight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (step.isCompleted && step.dateTime.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ConstrainedBox(
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
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _VideoViewerScreen extends StatefulWidget {
  final String videoUrl;

  const _VideoViewerScreen({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  @override
  State<_VideoViewerScreen> createState() => _VideoViewerScreenState();
}

/// Audio player screen for viewing audio files with direct playback
class _AudioPlayerScreen extends StatefulWidget {
  final String audioUrl;

  const _AudioPlayerScreen({Key? key, required this.audioUrl}) : super(key: key);

  @override
  State<_AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<_AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;
  late Future<void> _initializeAudioFuture;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeAudioFuture = _audioPlayer.setUrl(widget.audioUrl).then((_) async {
      final d = _audioPlayer.duration;
      if (d != null) setState(() => _duration = d);
    });

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });

    _audioPlayer.positionStream.listen((pos) {
      setState(() {
        _position = pos;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.audioUrl.split('/').last.split('?').first;
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          fileName,
          style: const TextStyle(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeAudioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading audio',
                  style: getTextStyle(color: AppColors.secondaryTextColor),
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.audiotrack, size: 72, color: AppColors.redColor),
                  SizedBox(height: 20),
                  Text(fileName, style: getTextStyle(color: AppColors.primaryTextColor)),
                  SizedBox(height: 20),
                  Slider(
                    value: _position.inMilliseconds.toDouble().clamp(0, _duration.inMilliseconds.toDouble()),
                    max: _duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                    onChanged: (v) async {
                      final pos = Duration(milliseconds: v.toInt());
                      await _audioPlayer.seek(pos);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(_position), style: getTextStyle(color: AppColors.secondaryTextColor)),
                        Text(_formatDuration(_duration), style: getTextStyle(color: AppColors.secondaryTextColor)),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  FloatingActionButton(
                    backgroundColor: AppColors.redColor,
                    onPressed: () async {
                      if (_isPlaying) {
                        await _audioPlayer.pause();
                      } else {
                        await _audioPlayer.play();
                      }
                    },
                    child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                FloatingActionButton(
                  backgroundColor: AppColors.redColor,
                  onPressed: () {
                    setState(() {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                    });
                  },
                  child: Icon(
                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: AppColors.redColor,
                      bufferedColor: Colors.grey,
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading video',
                style: getTextStyle(color: AppColors.secondaryTextColor),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.redColor),
              ),
            );
          }
        },
      ),
    );
  }
}

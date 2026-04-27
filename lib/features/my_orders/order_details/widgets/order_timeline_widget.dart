import 'package:flutter/material.dart';
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
    final fileName = url.split('/').last.split('?').first;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backGroundColor,
        title: Row(
          children: [
            Icon(Icons.audio_file, color: AppColors.redColor),
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
          'Audio file - tap Download to save',
          style: getTextStyle(color: AppColors.secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: getTextStyle(color: AppColors.redColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
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
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: getTextStyle(color: AppColors.redColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
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
              Navigator.pop(context);
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.black,
                leading: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
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
            ),
          ),
        );
      } else if (_isVideoFile(url)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _VideoViewerScreen(videoUrl: url),
          ),
        );
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
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: getTextStyle(color: AppColors.redColor),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
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
                                    child: Row(
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
                                        SizedBox(width: 20),
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

class _VideoViewerScreen extends StatefulWidget {
  final String videoUrl;

  const _VideoViewerScreen({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

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
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
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

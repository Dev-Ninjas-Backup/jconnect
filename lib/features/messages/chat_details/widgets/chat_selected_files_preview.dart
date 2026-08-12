import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/features/messages/chat_details/controller/chat_details_controller.dart';

class ChatSelectedFilesPreview extends StatelessWidget {
  final ChatDetailsController controller;

  const ChatSelectedFilesPreview({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.selectedFiles.isEmpty) {
        return const SizedBox.shrink();
      }
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        child: SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.selectedFiles.length,
            itemBuilder: (context, index) {
              final fileName = controller.selectedFiles[index].split('/').last;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.image,
                          color: Colors.white70,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fileName.length > 15
                              ? '${fileName.substring(0, 12)}...'
                              : fileName,
                          style: const TextStyle(
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
                          controller.selectedFiles.removeAt(index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.redColor,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(
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
    });
  }
}

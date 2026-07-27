import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';
import 'package:jconnect/core/common/style/global_text_style.dart';

class ExpandableText extends StatelessWidget {
  final String text;
  final int maxLines;
  final TextStyle style;

  const ExpandableText({
    super.key,
    required this.text,
    this.maxLines = 4,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textSpan = TextSpan(text: text, style: style);
        final textPainter = TextPainter(
          text: textSpan,
          maxLines: maxLines,
          textDirection: ui.TextDirection.ltr,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);

        final isOverflowing = textPainter.didExceedMaxLines;

        if (!isOverflowing) {
          return Text(
            text,
            style: style,
          );
        }

        return ObxValue<RxBool>(
          (isExpanded) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                maxLines: isExpanded.value ? null : maxLines,
                overflow: isExpanded.value ? TextOverflow.visible : TextOverflow.ellipsis,
                style: style,
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => isExpanded.value = !isExpanded.value,
                child: Text(
                  isExpanded.value ? 'Show less' : 'Read more',
                  style: getTextStyle(
                    color: AppColors.redColor,
                    fontsize: 12,
                    fontweight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          false.obs,
        );
      },
    );
  }
}

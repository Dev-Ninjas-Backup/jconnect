import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jconnect/core/utils/image_helper.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';

class CustomImageWidget extends StatelessWidget {
  final String? urlOrPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool isCircle;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CustomImageWidget({
    super.key,
    required this.urlOrPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.isCircle = false,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (urlOrPath == null || urlOrPath!.trim().isEmpty) {
      return _buildAssetImage(Imagepath.daconnectProfile);
    }

    final trimmed = urlOrPath!.trim();

    Widget imageWidget;

    // Resolve using the cached safe image provider helper
    final provider = getSafeImageProvider(trimmed);

    if (provider is CachedNetworkImageProvider) {
      imageWidget = CachedNetworkImage(
        imageUrl: provider.url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildErrorWidget(),
      );
    } else if (provider is FileImage) {
      imageWidget = Image.file(
        provider.file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildErrorWidget(),
      );
    } else if (provider is AssetImage) {
      imageWidget = Image.asset(
        provider.assetName,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildErrorWidget(),
      );
    } else {
      imageWidget = Image(
        image: provider,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildErrorWidget(),
      );
    }

    if (isCircle) {
      return ClipOval(child: imageWidget);
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildAssetImage(String assetPath) {
    Widget image = Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
    );
    if (isCircle) {
      return ClipOval(child: image);
    }
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade900,
      width: width,
      height: height,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey.shade900,
      width: width,
      height: height,
      child: Icon(
        Icons.person,
        size: (width != null) ? (width! / 2).clamp(16.0, 48.0) : 24.0,
        color: Colors.white38,
      ),
    );
  }
}

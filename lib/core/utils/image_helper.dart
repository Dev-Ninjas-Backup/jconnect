import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jconnect/core/common/constants/imagepath.dart';

// In-memory cache to prevent recreating ImageProviders during widget list rebuilds/scrolling
final Map<String, ImageProvider> _imageProviderCache = {};

ImageProvider getSafeImageProvider(String? urlOrPath) {
  if (urlOrPath == null || urlOrPath.trim().isEmpty) {
    return AssetImage(Imagepath.daconnectProfile);
  }

  final trimmed = urlOrPath.trim();

  // Return cached provider instantly if already resolved
  if (_imageProviderCache.containsKey(trimmed)) {
    return _imageProviderCache[trimmed]!;
  }

  late final ImageProvider provider;

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    provider = CachedNetworkImageProvider(trimmed);
  } else if (trimmed.startsWith('//')) {
    provider = CachedNetworkImageProvider('https:$trimmed');
  } else if (trimmed.startsWith('www.')) {
    provider = CachedNetworkImageProvider('https://$trimmed');
  } else if (trimmed.startsWith('file://')) {
    try {
      final uri = Uri.parse(trimmed);
      provider = FileImage(File(uri.toFilePath()));
    } catch (e) {
      final cleanPath = trimmed.replaceFirst('file://', '');
      provider = FileImage(File(cleanPath));
    }
  } else if (trimmed.startsWith('/') ||
      trimmed.contains('/') ||
      trimmed.contains('\\')) {
    if (trimmed.startsWith('assets/')) {
      provider = AssetImage(trimmed);
    } else {
      provider = FileImage(File(trimmed));
    }
  } else {
    provider = AssetImage(trimmed);
  }

  // Cache the resolved provider for future lookups
  _imageProviderCache[trimmed] = provider;
  return provider;
}

Widget getSafeImage(
  String? urlOrPath, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  if (urlOrPath == null || urlOrPath.trim().isEmpty) {
    return Image.asset(
      Imagepath.daconnectProfile,
      width: width,
      height: height,
      fit: fit,
    );
  }

  final trimmed = urlOrPath.trim();

  Widget fallbackError(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    if (errorBuilder != null) {
      return errorBuilder(context, error, stackTrace);
    }
    return Container(
      color: Colors.grey.shade900,
      width: width,
      height: height,
      child: Icon(
        Icons.person,
        size: (width != null) ? (width / 2) : 40,
        color: Colors.white38,
      ),
    );
  }

  // Use the cached safe provider to build the Image widget
  final provider = getSafeImageProvider(trimmed);

  if (provider is CachedNetworkImageProvider) {
    return CachedNetworkImage(
      imageUrl: provider.url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
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
      ),
      errorWidget: (context, url, error) =>
          fallbackError(context, url, StackTrace.fromString(error.toString())),
    );
  } else if (provider is FileImage) {
    return Image.file(
      provider.file,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: fallbackError,
    );
  } else if (provider is AssetImage) {
    return Image.asset(
      provider.assetName,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: fallbackError,
    );
  }

  return Image(
    image: provider,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: fallbackError,
  );
}

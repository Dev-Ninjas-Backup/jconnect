import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class SocialLinkLauncher {
  /// Opens a social media post URL in the corresponding native app if installed,
  /// otherwise falls back to opening it in the default web browser.
  static Future<void> launchSocialLink(String urlString) async {
    if (urlString.isEmpty) return;

    final trimmedUrl = urlString.trim();
    final uri = Uri.tryParse(trimmedUrl);
    if (uri == null) return;

    final String host = uri.host.toLowerCase();

    try {
      // Check if the URL is for Facebook, Instagram, X (Twitter), TikTok, or YouTube
      if (host.contains('facebook.com') || host.contains('fb.watch') || host.contains('fb.com')) {
        await _launchFacebook(trimmedUrl);
      } else if (host.contains('instagram.com')) {
        await _launchInstagram(trimmedUrl);
      } else if (host.contains('twitter.com') || host.contains('x.com')) {
        await _launchTwitter(trimmedUrl);
      } else if (host.contains('tiktok.com')) {
        await _launchTikTok(trimmedUrl);
      } else if (host.contains('youtube.com') || host.contains('youtu.be')) {
        await _launchYouTube(trimmedUrl);
      } else {
        await _launchFallback(uri);
      }
    } catch (e) {
      await _launchFallback(uri);
    }
  }

  static Future<void> _launchFacebook(String urlString) async {
    // For Facebook, fb://facewebmodal/fpage?href=... is a reliable way to open any URL in the native app.
    final nativeUri = Uri.parse('fb://facewebmodal/fpage?href=${Uri.encodeComponent(urlString)}');
    try {
      final launched = await launchUrl(nativeUri, mode: LaunchMode.externalNonBrowserApplication);
      if (!launched) {
        await _launchFallback(Uri.parse(urlString));
      }
    } catch (_) {
      await _launchFallback(Uri.parse(urlString));
    }
  }

  static Future<void> _launchInstagram(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      // Try opening as external non-browser application first to trigger Instagram native app
      final launched = await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      if (!launched) {
        await _launchFallback(uri);
      }
    } catch (_) {
      await _launchFallback(uri);
    }
  }

  static Future<void> _launchTwitter(String urlString) async {
    final uri = Uri.parse(urlString);
    final segments = uri.pathSegments;
    final statusIndex = segments.indexOf('status');

    if (statusIndex != -1 && statusIndex + 1 < segments.length) {
      final statusId = segments[statusIndex + 1];
      final nativeUri = Uri.parse('twitter://status?id=$statusId');
      try {
        final launched = await launchUrl(nativeUri, mode: LaunchMode.externalNonBrowserApplication);
        if (launched) return;
      } catch (_) {}
    }

    // Try opening the main tweet URL natively
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      if (!launched) {
        await _launchFallback(uri);
      }
    } catch (_) {
      await _launchFallback(uri);
    }
  }

  static Future<void> _launchTikTok(String urlString) async {
    final uri = Uri.parse(urlString);
    final segments = uri.pathSegments;
    final videoIndex = segments.indexOf('video');

    if (videoIndex != -1 && videoIndex + 1 < segments.length) {
      final videoId = segments[videoIndex + 1];
      final nativeUri = Uri.parse('tiktok://video/$videoId');
      try {
        final launched = await launchUrl(nativeUri, mode: LaunchMode.externalNonBrowserApplication);
        if (launched) return;
      } catch (_) {}
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      if (!launched) {
        await _launchFallback(uri);
      }
    } catch (_) {
      await _launchFallback(uri);
    }
  }

  static Future<void> _launchYouTube(String urlString) async {
    final uri = Uri.parse(urlString);
    String? videoId;

    if (uri.host.contains('youtu.be')) {
      if (uri.pathSegments.isNotEmpty) {
        videoId = uri.pathSegments.first;
      }
    } else {
      final segments = uri.pathSegments;
      final shortsIndex = segments.indexOf('shorts');
      if (shortsIndex != -1 && shortsIndex + 1 < segments.length) {
        videoId = segments[shortsIndex + 1];
      } else {
        videoId = uri.queryParameters['v'];
      }
    }

    if (videoId != null && videoId.isNotEmpty) {
      final nativeUri = Platform.isAndroid
          ? Uri.parse('vnd.youtube:$videoId')
          : Uri.parse('youtube://watch?v=$videoId');

      try {
        final launched = await launchUrl(nativeUri, mode: LaunchMode.externalNonBrowserApplication);
        if (launched) return;
      } catch (_) {}
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      if (!launched) {
        await _launchFallback(uri);
      }
    } catch (_) {
      await _launchFallback(uri);
    }
  }

  static Future<void> _launchFallback(Uri uri) async {
    try {
      // Standard web browser fallback
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Opens in external default browser
      );
    } catch (_) {
      // If external application fails, fallback to platformDefault
      try {
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      } catch (_) {}
    }
  }
}

import 'package:get/get.dart';

class RepostListingModel {
  final String id;
  final String sellerId;
  final String platform;
  final double price;
  final int followerCount;
  final String description;
  final bool isActive;
  final bool isPaused;
  final bool isSpotlight;
  final String defaultTurnaround;
  final int totalPurchases;
  final int totalAccepts;
  final int totalProofs;
  final int totalRedos;
  final int totalAutoReleases;
  final int totalCompleted;
  final String createdAt;
  final String updatedAt;
  final RepostSeller? seller;

  RepostListingModel({
    required this.id,
    required this.sellerId,
    required this.platform,
    required this.price,
    required this.followerCount,
    required this.description,
    required this.isActive,
    required this.isPaused,
    required this.isSpotlight,
    required this.defaultTurnaround,
    required this.totalPurchases,
    required this.totalAccepts,
    required this.totalProofs,
    required this.totalRedos,
    required this.totalAutoReleases,
    required this.totalCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.seller,
  });

  factory RepostListingModel.fromJson(Map<String, dynamic> json) {
    return RepostListingModel(
      id: json['id'] ?? '',
      sellerId: json['sellerId'] ?? '',
      platform: json['platform'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      followerCount: json['followerCount'] ?? 0,
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? false,
      isPaused: json['isPaused'] ?? false,
      isSpotlight: json['isSpotlight'] ?? false,
      defaultTurnaround: json['defaultTurnaround'] ?? '',
      totalPurchases: json['totalPurchases'] ?? 0,
      totalAccepts: json['totalAccepts'] ?? 0,
      totalProofs: json['totalProofs'] ?? 0,
      totalRedos: json['totalRedos'] ?? 0,
      totalAutoReleases: json['totalAutoReleases'] ?? 0,
      totalCompleted: json['totalCompleted'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      seller: json['seller'] != null ? RepostSeller.fromJson(json['seller']) : null,
    );
  }

  String get platformDisplayName {
    switch (platform.toUpperCase()) {
      case 'INSTAGRAM_STORY':
        return 'Instagram Story Repost';
      case 'INSTAGRAM_FEED':
        return 'Instagram Feed Repost';
      case 'INSTAGRAM_REEL':
        return 'Instagram Reel Repost';
      case 'TIKTOK':
        return 'Tiktok Repost';
      case 'TIKTOK_DUET':
        return 'Tiktok Duet/Stitch Repost';
      case 'TWITTER':
      case 'X':
        return 'X Repost';
      case 'TWITTER_QUOTE':
      case 'X_QUOTE':
        return 'X Quote Repost';
      case 'YOUTUBE_COMMUNITY_POST':
        return 'YouTube Community Post Repost';
      case 'YOUTUBE_SHORTS':
        return 'YouTube Video Repost (Shorts)';
      case 'FACEBOOK_POST':
        return 'Facebook Post Repost';
      case 'FACEBOOK_STORY':
        return 'Facebook Story Repost';
      default:
        return platform.replaceAll('_', ' ');
    }
  }

  String get platformIcon {
    final lower = platform.toLowerCase();
    if (lower.contains('instagram')) {
      return 'assets/icons/instagram.png';
    } else if (lower.contains('tiktok')) {
      return 'assets/icons/tiktok.png';
    } else if (lower.contains('twitter') || lower.contains('x')) {
      return 'assets/icons/twitter.png';
    } else if (lower.contains('facebook')) {
      return 'assets/icons/facebook.png';
    } else if (lower.contains('youtube')) {
      return 'assets/icons/youtube.png';
    }
    return 'assets/icons/social-media.png';
  }

  String get formattedFollowerCount {
    if (followerCount >= 1000000) {
      return '${(followerCount / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
    } else if (followerCount >= 1000) {
      return '${(followerCount / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
    }
    return followerCount.toString();
  }

  String get formattedTurnaround {
    switch (defaultTurnaround.toUpperCase()) {
      case 'TWENTY_FOUR_HOURS':
        return '24 Hour Duration';
      case 'ONE_HOUR':
        return '1 Hour Duration';
      case 'TWO_HOURS':
        return '2 Hour Duration';
      case 'FOUR_HOURS':
        return '4 Hour Duration';
      case 'EIGHT_HOURS':
        return '8 Hour Duration';
      case 'TWELVE_HOURS':
        return '12 Hour Duration';
      default:
        return defaultTurnaround.replaceAll('_', ' ').toLowerCase().capitalizeFirst ?? defaultTurnaround;
    }
  }
}

class RepostSeller {
  final String id;
  final String fullName;
  final String username;
  final String? profilePhoto;
  final bool isProfileVerified;

  RepostSeller({
    required this.id,
    required this.fullName,
    required this.username,
    this.profilePhoto,
    required this.isProfileVerified,
  });

  factory RepostSeller.fromJson(Map<String, dynamic> json) {
    return RepostSeller(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      username: json['username'] ?? '',
      profilePhoto: json['profilePhoto'],
      isProfileVerified: json['isProfileVerified'] ?? false,
    );
  }
}

class RepostListingModel {
  final String id;
  final String sellerId;
  final String platform;
  final int price;
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
  });

  factory RepostListingModel.fromJson(Map<String, dynamic> json) {
    return RepostListingModel(
      id: json['id'] ?? '',
      sellerId: json['sellerId'] ?? '',
      platform: json['platform'] ?? '',
      price: json['price'] ?? 0,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'platform': platform,
      'price': price,
      'followerCount': followerCount,
      'description': description,
      'isActive': isActive,
      'isPaused': isPaused,
      'isSpotlight': isSpotlight,
      'defaultTurnaround': defaultTurnaround,
      'totalPurchases': totalPurchases,
      'totalAccepts': totalAccepts,
      'totalProofs': totalProofs,
      'totalRedos': totalRedos,
      'totalAutoReleases': totalAutoReleases,
      'totalCompleted': totalCompleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  String get platformDisplayName {
    switch (platform) {
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
        return 'X Repost';
      case 'TWITTER_QUOTE':
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
        return platform;
    }
  }

  String get platformIcon {
    final lower = platform.toLowerCase();
    if (lower.contains('instagram')) {
      return 'assets/icons/instagram.png';
    } else if (lower.contains('tiktok')) {
      return 'assets/icons/tiktok.png';
    } else if (lower.contains('twitter') || lower.contains('twitter_quote')) {
      return 'assets/icons/twitter.png';
    } else if (lower.contains('facebook')) {
      return 'assets/icons/facebook.png';
    } else if (lower.contains('youtube')) {
      return 'assets/icons/youtube.png';
    }
    return 'assets/icons/social-media.png';
  }
}
